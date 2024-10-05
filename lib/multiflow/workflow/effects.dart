import 'dart:async';
import 'package:rxdart/rxdart.dart';
import '../actions.dart';

class EffectCancelError implements Exception {
  String cause;
  EffectCancelError(this.cause);
}

abstract class Effect<PAYLOAD> {
  final String name;
  bool finished = false;
  bool synchronous = false;
  Object error;
  Object result;
  final Completer<PAYLOAD> _completer;
  Effect({this.name, synchronous = false})
      : _completer = synchronous ? Completer.sync() : Completer(),
        this.synchronous = synchronous;
  Future<PAYLOAD> get future => _completer.future;
  bool get isError => this.error != null;
  bool get isSuccess => this.result != null;
  send(Action action, Object state);
  cancel(Exception error) {
    if (!this._completer.isCompleted) {
      this._completer.completeError(error);
    }
    return this._completer.future;
  }
}

abstract class EffectStream<PAYLOAD> extends Effect<PAYLOAD> {
  Observable<PAYLOAD> get observable;
  Stream<PAYLOAD> get stream;
  EffectStream({String name}) : super(name: name) {
    this.observable.doOnDone(() {
      this._completer.complete();
    });
    this.observable.doOnError((e) {
      this._completer.completeError(e);
    });
  }
  stop();
}

class EffectTakeAction<PAYLOAD> extends Effect<Action<PAYLOAD>> {
  bool received = false;
  final Action<PAYLOAD> intended;
  EffectTakeAction(this.intended, {String name}) : super(name: name);
  send(action, state) {
    if (action.key == this.intended.key) {
      this._completer.complete(action as Action<PAYLOAD>);
    }
  }
}

class EffectTakeEvery<PAYLOAD> extends EffectStream<Action<PAYLOAD>> {
  final Action<PAYLOAD> intended;
  final bool unique;
  final int debounceMs;
  final int throttleMs;
  final Subject<Action<PAYLOAD>> _observable = new PublishSubject();
  get observable {
    Observable temp = this._observable;
    if (this.unique != null && this.unique) {
      temp = temp.distinctUnique(equals: (a1, a2) => a1.key == a2.key);
    }
    if (this.debounceMs != null && this.debounceMs > 0) {
      temp = temp.debounce(Duration(milliseconds: this.debounceMs));
    }
    if (this.throttleMs != null && this.throttleMs > 0) {
      temp = temp.throttle(Duration(milliseconds: this.throttleMs));
    }
    return temp;
  }
  get stream {
    return observable.asBroadcastStream();
  }

  EffectTakeEvery(this.intended,
      {String name, this.unique, this.debounceMs = -1, this.throttleMs = -1})
      : super(name: name);
  send(action, state) {
    if (action.key == this.intended.key) {
      this._observable.add(action);
    }
  }

  cancel(error) {
    super.cancel(error);
    _observable.close();
  }

  stop() {
    _observable.close();
  }
}

class EffectWaitFuture<PAYLOAD> extends Effect<PAYLOAD> {
  EffectWaitFuture(Future<PAYLOAD> future, {String name}) : super(name: name) {
    future
        .then((value) => this._completer.complete(value))
        .catchError((e) => this._completer.completeError(e));
  }
  send(action, state) {}
}

class EffectRace extends Effect<Effect> {
  final List<Effect> effects;
  EffectRace(this.effects, {String name})
      : super(name: name, synchronous: true) {
    //call completer callback synchrnously (when dep finished=> send finish)
    Future.any(this.effects.map((f) => f.future)).whenComplete(() {
      for (var eff in this.effects) {
        if (eff.finished) {
          eff.future.then((e) {
            this._completer.complete(eff);
          }).catchError((e) {
            this._completer.completeError(e);
          });
        }
      }
    });
  }
  send(action, state) {}
}

class EffectJoin extends Effect<List<Effect>> {
  final List<Effect> effects;
  EffectJoin(this.effects, {String name})
      : super(name: name, synchronous: true) {
    //call completer callback synchrnously (when dep finished=> send finish)
    Future.wait(this.effects.map((f) => f.future), eagerError: true).then((e) {
      this._completer.complete(effects);
    }).catchError((error) {
      if (!this._completer.isCompleted) this._completer.completeError(error);
    });
  }
  send(action, state) {}
}

class EffectTakeLattestAction<PAYLOAD> extends Effect<Action<PAYLOAD>> {
  bool received = false;
  final Action<PAYLOAD> intended;
  int debounceMs;
  Subject<Action> observable = new PublishSubject();
  EffectTakeLattestAction(this.intended, this.debounceMs, {String name})
      : super(name: name, synchronous: true) {
    //call completer callback synchrnously (when dep finished=> send finish)
    observable
        .debounce(Duration(milliseconds: this.debounceMs))
        .first
        .asObservable()
        .listen((action) {
      this._completer.complete(action as Action<PAYLOAD>);
    });
  }
  send(action, state) {
    if (action.key == this.intended.key) {
      this.observable.add(action);
    }
  }
}

class WorkflowDelegate {
  WorkflowDelegate start() {
    return this;
  }

  Future<Object> future;
  dispose() {}
}

class EffectFork<T> extends Effect<T> {
  final WorkflowDelegate workflow;
  EffectFork(this.workflow, {String name}) : super(name: name) {
    this.workflow.start().future.then((e) {
      if (!this._completer.isCompleted) this._completer.complete(e);
    }).catchError((error) {
      if (!this._completer.isCompleted) this._completer.completeError(error);
      return Future.value(null);
    });
  }
  send(action, state) {}
  cancel(error) {
    super.cancel(error);
    this.workflow.dispose();
  }
}
