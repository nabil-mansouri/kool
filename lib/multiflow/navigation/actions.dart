import '../actions.dart';
import 'package:optional/optional.dart';
import 'package:meta/meta.dart';

class Routes {
  final String previous;
  final String current;
  Routes({this.previous, @required this.current});
}

class RouteAction extends Action<Routes> {
  List<Object> args = [];
  RouteAction(Symbol key, {Routes payload}) : super(key, payload: payload);
  static string(String key, {Routes payload}) {
    return RouteAction(Symbol(key), payload: payload);
  }

  get current => this.payload != null ? this.payload.current : null;

  RouteAction withCurrent(String current) {
    return RouteAction(this.key, payload: Routes(current: current));
  }

  RouteAction withPayload(Routes p) {
    return RouteAction(this.key, payload: p);
  }

  RouteAction addArg(Object arg) {
    this.args.add(arg);
    return this;
  }

  RouteAction withArgs(List<Object> args) {
    this.args = List.from(args);
    return this;
  }

  Optional<T> getArgOfType<T>(Type t, Object defaut) {
    return Optional.ofNullable(
        args.firstWhere((test) => test.runtimeType == t, orElse: () => defaut));
  }

  List<T> getArgsOfType<T>(Type t) {
    return args.where((test) => test.runtimeType == t).toList();
  }
}

enum NavigationChange { Push, Pop }

class NavigationActions {
  static final RouteAction doPush =
      RouteAction.string("store.navigation.dopush");
  static final RouteAction doPop = RouteAction.string("store.navigation.dopop");
  static final RouteAction doChanged =
      RouteAction.string("store.navigation.changed");

  static RouteAction createPush(String current) {
    return doPush.withCurrent(current);
  }

  static RouteAction createPop() {
    return doPop;
  }

  static RouteAction createPopChanged(Routes routes) {
    return NavigationActions.doChanged
        .withPayload(routes)
        .addArg(NavigationChange.Pop);
  }

  static RouteAction createPushChanged(Routes routes) {
    return NavigationActions.doChanged
        .withPayload(routes)
        .addArg(NavigationChange.Push);
  }
}
