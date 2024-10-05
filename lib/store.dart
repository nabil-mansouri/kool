import 'package:food/restaurants/restaurants.dart';
import 'package:food/location/location.dart';
import 'package:food/multiflow/multiflow.dart';
import 'package:food/navigation/navigation.dart';
import 'commerce/commerce.dart';

class GlobalRoutes {
  static const SPLASHSCREEN = "/";
  static const RESTAURANTS_LIST = RestaurantRoutes.RESTAURANTS_LIST;
  static const RESTAURANTS_DETAIL = RestaurantRoutes.RESTAURANTS_DETAIL;
  static const RESTAURANTS_SEARCH = RestaurantRoutes.RESTAURANTS_SEARCH;
  static const RESTAURANTS_SEARCH_INITIAL =
      RestaurantRoutes.RESTAURANTS_SEARCH_INITIAL;
  static const NAVIGATION = GeoNavigationRoutes.NAVIGATION;
}

class GlobalState {
  copy() {
    GlobalState copy = GlobalState();
    return copy;
  }
}

class GlobalWorkfow extends Workflow<GlobalState> {
  GlobalWorkfow(GlobaleStore store) : super(store);
  workflow() async {
    await takeAction(StoreActions.storeStartAction).future;
    //TODO dynamic login
    print("[Workflow][Global] navigate to first route");
    (store as GlobaleStore).goToRestaurantList();
    takeEvery(NavigationActions.doChanged, callback: (data) async {
      if ((data as RouteAction).payload.current == "/") {
        (store as GlobaleStore).goToRestaurantList();
      }
    });
    //
    await takeAction(StoreActions.storeStopAction).future;
    return null;
  }
}

mixin GlobalActions implements Store<GlobalState> {
  GlobalWorkfow workflow;
  goToRestaurantList() {
    getChild<RestaurantStore>(RestaurantStore).value.listRestaurants();
  }

  goToRestaurantSearch() {
    getChild<RestaurantStore>(RestaurantStore).value.searchRestaurants();
  }

  goToNavigation() {
    sendAction(NavigationActions.createPush(GlobalRoutes.NAVIGATION));
  }
}

class GlobaleStore extends Store<GlobalState> with GlobalActions {
  GlobalWorkfow workflow;
  GlobaleStore() : super(GlobalState()) {
    workflow = GlobalWorkfow(this).start();
  }
}

GlobaleStore _rootStore;
GlobaleStore getRootStore() {
  if (_rootStore == null) {
    final location = LocationStore();
    final cartStore = new CartStore();
    _rootStore = new GlobaleStore();
    _rootStore.addChild(new NavigationStore());
    _rootStore.addChild(location);
    _rootStore.addChild(new RestaurantStore(location, cartStore));
    _rootStore.addChild(cartStore);
    _rootStore.addChild(GeoNavigationStore());
    _rootStore.start();
  }
  return _rootStore;
}
