import 'dart:async';
import 'package:meta/meta.dart';

class Action<PAYLOAD> {
  PAYLOAD payload;
  Symbol key;
  Action(this.key, {this.payload});
  static string<PAYLOAD>(String key, {PAYLOAD payload}) {
    return Action<PAYLOAD>(Symbol(key), payload: payload);
  }

  withPayload(PAYLOAD p) {
    return Action<PAYLOAD>(this.key, payload: p);
  }
}

class ActionFuture<PAYLOAD> extends Action<Future<PAYLOAD>> {
  Action<PAYLOAD> success;
  Action<dynamic> fail;
  ActionFuture(Symbol key,
      {@required this.success,
      @required this.fail,
      PAYLOAD payload,
      Future<PAYLOAD> futurePayload})
      : super(key, payload: Future.value(payload)) {
    //if future payload is send instead of payload
    if (payload == null && futurePayload != null) {
      this.payload = futurePayload;
    }
  }
  static string<PAYLOAD>(String key,
      {@required Action<PAYLOAD> success,
      @required Action<dynamic> fail,
      PAYLOAD payload}) {
    return ActionFuture<PAYLOAD>(Symbol(key),
        success: success, fail: fail, payload: payload);
  }

  withPayload(Future<PAYLOAD> p) {
    return ActionFuture<PAYLOAD>(this.key,
        futurePayload: p, success: this.success, fail: this.fail);
  }
}

class AsyncAction<MODEL, QUERY> {
  final ActionFuture<MODEL> request;
  final Action<QUERY> query;
  AsyncAction({this.request, this.query});
  factory AsyncAction.create(String action) {
    final Action<QUERY> query = Action.string<QUERY>("$action.query");
    final Action<MODEL> success = Action.string<MODEL>("$action.success");
    final Action<dynamic> failed = Action.string<dynamic>("$action.failed");
    final ActionFuture<MODEL> request = ActionFuture.string<MODEL>(
        "$action.request",
        success: success,
        fail: failed);
    return AsyncAction(request: request, query: query);
  }
  get failed => this.request.fail;
  Action<MODEL> get success => this.request.success;
}

class StoreActions {
  static final Action storeStartAction = Action.string("store.start");
  static final Action storeStopAction = Action.string("store.stop");
}
