import 'package:flutter/widgets.dart';
import '../store.dart';
import '../widgets/provider.dart';
import 'actions.dart';

class RouteObserverStore extends RouteObserver<PageRoute> {
  final Store store;
  RouteObserverStore(this.store);
  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    //when popping curent route is previous
    this.store.sendAction(NavigationActions.createPopChanged(Routes(
        current: previousRoute?.settings?.name,
        previous: route?.settings?.name)));
    super.didPop(route, previousRoute);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    this.store.sendAction(NavigationActions.createPushChanged(Routes(
        previous: previousRoute?.settings?.name,
        current: route?.settings?.name)));
    super.didPush(route, previousRoute);
  }
}

class StoreNavigation extends StatelessWidget {
  final Widget child;
  final RouteObserverStore routeObserver;
  StoreNavigation({@required this.child, @required this.routeObserver});
  build(context) {
    var store = StoreProvider.of(context);
    return _StoreNavigation(
        store: store, child: this.child, routeObserver: this.routeObserver);
  }
}

class _StoreNavigation extends StatefulWidget {
  final Store store;
  final Widget child;
  final RouteObserverStore routeObserver;
  _StoreNavigation(
      {Key key,
      @required this.store,
      @required this.child,
      @required this.routeObserver})
      : assert(store != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _StoreNavigationState();
  }
}

class _StoreNavigationState extends State<_StoreNavigation>
    with RouteAware, StoreAware {
  NavigatorState get navigator => this.widget.routeObserver.navigator;
  Store<Object> get widgetStore => this.widget.store;

  @override
  beforeReduce(action, previousState, currentState) {}
  @override
  afterReduce(action, previousState, currentState) {
    if (this.mounted) {
      if (action.key == NavigationActions.doPush.key) {
        this.navigator.pushNamed((action as RouteAction).payload.current);
      } else if (action.key == NavigationActions.doPop.key) {
        this.navigator.pop();
      }
    }
  }

  @override
  void initState() {
    this.widgetStore.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    this.widgetStore.removeListener(this);
    super.dispose();
  }

  @override
  void didUpdateWidget(_StoreNavigation oldWidget) {
    if (this.widgetStore != oldWidget.store) {
      oldWidget.store.removeListener(this);
      this.widgetStore.addListener(this);
    }
    super.didUpdateWidget(oldWidget);
  }

  build(context) {
    return this.widget.child;
  }
}
