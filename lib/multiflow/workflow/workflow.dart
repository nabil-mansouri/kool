import 'dart:async';
import '../actions.dart';
import '../store.dart';
import 'effects.dart';
export 'effects.dart';

typedef Future EffectCallback<T>(T action);

_askPrint(Object object) {
  print(object);
}

class WorkflowAware<STATE> {
  void onAction(Workflow workflow, Action action, STATE state) {}
  void onAddWorkflowChild(Workflow workflow) {}
  void onRemoveWorkflowChild(Workflow workflow) {}
  void onRegisterEffect(Workflow w, Effect e) {}
}

class WorkflowMutex {
  bool mutex = false;
}

abstract class Workflow<STATE> with StoreAware<STATE>, WorkflowDelegate {
  bool logging = false;
  //
  List<Effect> registered = [];
  //needed for compile
  final Store<STATE> store;
  final List<Workflow> children = [];
  Workflow parent;
  Future<Object> future;
  final Set<WorkflowAware<STATE>> _listeners = Set<WorkflowAware<STATE>>();
  Workflow(this.store, {this.parent});
  Workflow<STATE> start() {
    this.store.addListener(this);
    this.future = this._workflowZone();
    return this;
  }

  print(Object object) {
    if (logging) _askPrint(object);
  }

  Future _workflowZone() {
    Completer completer = Completer.sync();
    runZoned<Future>(() {
      try {
        return this
            .workflow()
            .then((e) => completer.complete(e))
            .catchError((error) => completer.complete(error));
      } catch (e) {
        completer.complete(e);
      }
    }, onError: (error, stacktrace) {
      if (!completer.isCompleted) {
        completer.complete(error);
      }
    });
    completer.future.then((onValue) {
      if (onValue.runtimeType == EffectCancelError) {
        print("Workflow $this canceled with $onValue");
        this.onCanceled(onValue);
      } else if (onValue is Error || onValue is Exception) {
        print("Workflow $this stopped with error $onValue");
        this.onError(onValue);
      } else {
        print("Workflow $this finished success $onValue");
        this.onSuccess(onValue);
      }
    });
    return completer.future;
  }

  void addListener(WorkflowAware listener) {
    this._listeners.add(listener);
  }

  void removeListener(WorkflowAware listener) {
    this._listeners.remove(listener);
  }

  beforeReduce(Action<Object> action, STATE previousState, STATE currentState) {
    this._sendAction(action, currentState);
  }

  afterReduce(Action<Object> action, STATE previousState, STATE currentState) {}
  onCanceled(e) {}
  onSuccess(value) {}
  onError(e) {}

  Future stop() {
    this.store.removeListener(this);
    this.cancelAll();
    return this.future;
  }

  dispose() {
    this.stop();
    if (this.parent != null) {
      this.parent.removeChild(this);
    }
    this._listeners.clear();
  }

  onSendAction<PAYLOAD>(Action<PAYLOAD> action, STATE state) {}

  _sendAction<PAYLOAD>(Action<PAYLOAD> action, STATE state) {
    this.onSendAction(action, state);
    registered.forEach((f) => f.send(action, state));
    _listeners.forEach((f) => f.onAction(this, action, state));
  }

  publishAction<PAYLOAD>(Action<PAYLOAD> action,
      [bool publishToStore = false]) {
    this._sendAction(action, this.store.state);
    //dont publish to store multiple times
    this.children.forEach((child) => child.publishAction(action, false));
    //
    if (publishToStore) {
      if (action is ActionFuture) {
        this.store.sendActionFuture(action as ActionFuture);
      } else {
        this.store.sendAction(action);
      }
    }
  }

  addChild(Workflow store) {
    store.parent = this;
    children.add(store);
    _listeners.forEach((f) => f.onAddWorkflowChild(store));
  }

  removeChild(Workflow store) {
    store.parent = null;
    children.remove(store);
    _listeners.forEach((f) => f.onRemoveWorkflowChild(store));
  }

  Future cancelAll() async {
    try {
      var futures = this.registered.map((effect) => cancel(effect)).toList();
      await Future.wait(futures);
    } catch (_) {}
    return null;
  }

  Future<Object> cancel(Effect effect) async {
    if (effect == null) {
      return Future.value();
    }
    return effect.cancel(EffectCancelError("cancel effect"));
  }

  Effect<Object> fork<Object>(Workflow child, {String name}) {
    this.addChild(child);
    final effect = new EffectFork<Object>(child, name: name);
    return register(effect);
  }

  Effect<Object> waitTime(int milliseconds, {String name}) {
    return waitFuture(Future.delayed(Duration(milliseconds: milliseconds)),
        name: name);
  }

  EffectStream<Action<PAYLOAD>> takeEvery<PAYLOAD>(Action<PAYLOAD> action,
      {String name,
      bool unique,
      int debounceMs,
      int throttleMs,
      WorkflowMutex mutex,
      EffectCallback<Action<PAYLOAD>> callback}) {
    final effect = EffectTakeEvery<PAYLOAD>(action,
        name: name,
        unique: unique,
        debounceMs: debounceMs,
        throttleMs: throttleMs);
    if (callback != null) {
      effect.observable.listen((data) async {
        if (mutex != null && mutex.mutex) return;
        try {
          if (mutex != null) mutex.mutex = true;
          await callback(data);
        } finally {
          if (mutex != null) mutex.mutex = false;
        }
      });
    }
    return register(effect);
  }

  Effect<Action<PAYLOAD>> takeAction<PAYLOAD>(Action<PAYLOAD> action,
      {String name}) {
    return register(EffectTakeAction<PAYLOAD>(action, name: name));
  }

  Effect<Action<PAYLOAD>> takeLatestAction<PAYLOAD>(
      Action<PAYLOAD> action, int debounceMs,
      {String name}) {
    return register(
        EffectTakeLattestAction<PAYLOAD>(action, debounceMs, name: name));
  }

  Effect<PAYLOAD> waitFuture<PAYLOAD>(Future<PAYLOAD> action, {String name}) {
    return register(EffectWaitFuture<PAYLOAD>(action, name: name));
  }

  Effect<Effect> race(List<Effect> effects, {String name}) {
    Effect effect = register(EffectRace(effects, name: name));
    //unregister all when finish
    effect.future.whenComplete(() {
      effects.forEach((f) => this.unregister(f));
    });
    return effect;
  }

  Effect<List<Effect>> join(List<Effect> effects, {String name}) {
    return register(EffectJoin(effects, name: name));
  }

  Effect register(Effect e) {
    this.registered.add(e);
    _listeners.forEach((f) => f.onRegisterEffect(this, e));
    e.future.then((value) {
      e.finished = true;
      e.result = value;
      unregister(e);
    }).catchError((error) {
      e.finished = true;
      e.error = error;
      unregister(e);
      return Future.value(null);
    });
    return e;
  }

  unregister(Effect e) {
    this.registered.remove(e);
    return e;
  }

  Future<Object> workflow();
}
