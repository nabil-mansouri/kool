import 'package:meta/meta.dart';
import 'package:optional/optional.dart';
import 'actions.dart';

typedef STATE ReducerCallback<STATE, PAYLOAD>(Action<PAYLOAD> a, STATE s);

_askPrint(Object object) {
  print(object);
}

class Reducer<STATE, PAYLOAD> {
  final ReducerCallback<STATE, PAYLOAD> callback;
  Reducer(this.callback);
  STATE execute(Object action, Object state) {
    return this.callback(action as Action<PAYLOAD>, state as STATE);
  }
}

class StoreAware<STATE> {
  void beforeReduce(
      Action<Object> action, STATE previousState, STATE currentState) {}
  void afterReduce(
      Action<Object> action, STATE previousState, STATE currentState) {}
}

class Store<STATE extends Object> {
  STATE _statePrevious;
  STATE _state;
  Store parent;
  bool logging = false;
  final Set<StoreAware> _listeners = Set<StoreAware>();
  final List<Store> _children = [];
  final Map<Symbol, List<Reducer>> _reducers = {};
  Store(this._state);
  STATE get statePrevious => _statePrevious;
  STATE get state => _state;
  List<Store> get children => this._children;
  setState(STATE s) {
    _state = s;
  }

  print(Object object) {
    if (logging) _askPrint(object);
  }

  @mustCallSuper
  start() {
    //only parent can send start
    if (this.parent != null) {
      this.parent.sendAction(StoreActions.storeStartAction);
    } else {
      this.sendAction(StoreActions.storeStartAction);
    }
  }

  @mustCallSuper
  stop() {
    //only parent can send stop
    if (this.parent != null) {
      this.parent.sendAction(StoreActions.storeStopAction);
    } else {
      this.sendAction(StoreActions.storeStopAction);
    }
  }

  Optional<T> getChild<T extends Store>(Type name) {
    return Optional.ofNullable(children
        .firstWhere((test) => test.runtimeType == name, orElse: () => null));
  }

  addChild(Store store) {
    store.parent = this;
    _children.add(store);
  }

  removeChild(Store store) {
    store.parent = null;
    _children.remove(store);
  }

  void addListener(StoreAware listener) {
    this._listeners.add(listener);
    // print("Number of listener after add: ${this._listeners.length}");
  }

  void removeListener(StoreAware listener) {
    this._listeners.remove(listener);
    //print("Number of listener after remove: ${this._listeners.length}");
  }

  void _callReducers<PAYLOAD>(Action<PAYLOAD> action, {bool recursive: true}) {
    this._statePrevious = this._state; //backup state before reduce
    var temp = this._state;
    if (this._reducers.containsKey(action.key)) {
      for (var reducer in this._reducers[action.key]) {
        temp = reducer.execute(action, state);
      }
    }
    if (recursive) {
      this._children.forEach(
          (child) => child._callReducers(action, recursive: recursive));
    }
    this._state = temp;
  }

  void _callBeforeListeners<PAYLOAD>(Action<PAYLOAD> action,
      {bool recursive: true}) {
    this._listeners.forEach(
        (f) => f.beforeReduce(action, this._statePrevious, this._state));
    if (recursive) {
      this._children.forEach(
          (child) => child._callBeforeListeners(action, recursive: recursive));
    }
  }

  void _callAfterListeners<PAYLOAD>(Action<PAYLOAD> action,
      {bool recursive: true}) {
    this._listeners.forEach(
        (f) => f.afterReduce(action, this._statePrevious, this._state));
    if (recursive) {
      this._children.forEach(
          (child) => child._callAfterListeners(action, recursive: recursive));
    }
  }

  void _sendAction<PAYLOAD>(Action<PAYLOAD> action, {bool recursive: true}) {
    try {
      //depth update state then call listeners
      this._callBeforeListeners(action, recursive: recursive);
      this._callReducers(action, recursive: recursive);
      this._callAfterListeners(action, recursive: recursive);
      //
    } catch (e) {
      print("[STORE][ERROR] while sending actions $e");
    }
  }

  sendAction<PAYLOAD>(Action<PAYLOAD> action, [bool fromRoot = true]) {
    //by default send action from root
    if (fromRoot && this.parent != null) {
      return this.parent.sendAction(action, true);
    } else {
      print("[Store] send action :${action.key}");
      this._sendAction(action, recursive: true);
    }
  }

  Future<Object> sendActionFuture<PAYLOAD>(ActionFuture<PAYLOAD> action) async {
    this.sendAction(action);
    PAYLOAD res;
    try {
      res = await action.payload;
      this.sendAction(action.success.withPayload(res));
    } catch (e) {
      this.print("[Store] send actionfuture (${action.key}) failed: $e => $res");
      this.sendAction(action.fail.withPayload(e));
    }
    return null;
  }

  _addReducer<PAYLOAD>(Action<PAYLOAD> action, Reducer<STATE, PAYLOAD> reducer,
      [unique = false]) {
    if (unique) {
      this._reducers.remove(action.key);
    }
    //
    this._reducers.putIfAbsent(action.key, () => []);
    var reducersForActions = _reducers[action.key];
    //
    reducersForActions.add(reducer);
  }

  addReducerForAction<PAYLOAD extends Object>(
      Action<PAYLOAD> action, Reducer<STATE, PAYLOAD> reducer,
      [unique = false]) {
    this._addReducer(action, reducer, unique);
  }

  removeReducerForAction<PAYLOAD>(
      Action<PAYLOAD> action, Reducer<STATE, PAYLOAD> reducer,
      [unique = false]) {
    this._reducers.putIfAbsent(action.key, () => []);
    var reducersForActions = _reducers[action.key];
    reducersForActions.removeWhere((reduc) => reduc == reducer);
  }

  Optional<T> _findState<T>(Type name) {
    if ((this._state).runtimeType == name) {
      return Optional.ofNullable(this._state as T);
    }
    for (var child in this._children) {
      var founded = child._findState<T>(name);
      if (founded.isPresent) {
        return founded;
      }
    }
    return Optional.empty();
  }

  T getStateFor<T>(Type name) {
    //find from root
    if (this.parent != null) {
      return this.parent.getStateFor(name);
    }
    return this
        ._findState(name)
        .orElseThrow(() => "Could not found state for type $name");
  }

  Optional<T> _findPreviousState<T>(Type name) {
    if ((this._statePrevious).runtimeType == name) {
      return Optional.ofNullable(this._statePrevious as T);
    }
    for (var child in this._children) {
      var founded = child._findPreviousState<T>(name);
      if (founded.isPresent) {
        return founded;
      }
    }
    return Optional.empty();
  }

  T getPreviousStateFor<T>(Type name) {
    //find from root
    if (this.parent != null) {
      return this.parent.getPreviousStateFor(name);
    }
    return this
        ._findPreviousState(name)
        .orElseThrow(() => "Could not found previous state for type $name");
  }

  Optional<T> _findStore<T>(Type name) {
    if (this.runtimeType == name) {
      return Optional.ofNullable(this as T);
    }
    for (var child in this._children) {
      var founded = child._findStore<T>(name);
      if (founded.isPresent) {
        return founded;
      }
    }
    return Optional.empty();
  }

  T getStore<T>(Type name) {
    //find from root
    if (this.parent != null) {
      return this.parent.getStore(name);
    }
    return this
        ._findStore(name)
        .orElseThrow(() => "Could not found store for type $name");
  }
}
