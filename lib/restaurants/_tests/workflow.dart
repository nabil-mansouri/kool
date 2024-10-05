import 'package:flutter_test/flutter_test.dart' hide group;
import 'package:test/test.dart' show group;
import 'package:food/multiflow/multiflow.dart';
import 'package:food/location/location.dart';
import 'package:food/commerce/commerce.dart';
import '../restaurants.dart';
import '../domain/factory.dart';
import 'utils.dart';

startWorkflowTest(RestaurantTestUtils testUtils) {
  group("[Workflow]", () {
    final location = LocationStore();
    final cartAction = CartStore();
    final RestaurantStore store = new RestaurantStore(location, cartAction);
    StoreMonitor<RestaurantState> monitor = new StoreMonitor();
    RestaurantWorkflow.maxRadius = 20;
    RestaurantWorkflow.addRadius = 2;
    RestaurantWorkflow.minNumberOfData = 5;
    //
    final restaus = testUtils.restaus;
    final firebase = testUtils.firebase;
    final products = testUtils.products;
    final categories = testUtils.categories;
    final center = testUtils.center;
    //
    setUpAll(() async {
      print("[Restaurant][Workflow] settup all");
      // === Clean database
      await testUtils.deleteAllRestaurants();
      await testUtils.deleteAllProducts();
      await testUtils.deleteAllCategories();
      // === Create restaurants from factory
      final firstResto = restaus[0];
      firstResto.slots = RestaurantFactory.slots(5);
      List<Future> futures =
          restaus.map((f) => firebase.create(f, forceId: f.id)).toList();
      await Future.wait(futures);
      // === Create products from factory
      final firstProduct = products[0];
      firstProduct.categories = []; //Simulate other category
      futures = products
          .map((f) => firebase.createProduct(f, forceId: f.id))
          .toList();
      await Future.wait(futures);
      // === Create categories from factory
      futures = categories
          .map((f) => firebase.createCategory(firstResto.id, f, forceId: f.id))
          .toList();
      await Future.wait(futures);
      // === add listeners
      store.addListener(monitor);
      store.workflow.addListener(monitor);
      store.state.restaurants = [];
      // === Clean cache
      await firebase.removeLastQuery();
      print("[Restaurant][Workflow] finish setup...........");
    });

    test('should start by opening search', () async {
      // === waiting for fetch last search
      final eventFetch = monitor.waitForFirst(
          kind: MonitorEventKind.AfterReduce,
          action: RestaurantActions.doLoadSearch.request);
      final eventFetchSuccess = monitor.waitForFirst(
          kind: MonitorEventKind.AfterReduce,
          action: RestaurantActions.doLoadSearch.success);
      // === Should redirect to search_initial
      final eventRedirect = monitor.waitForFirst(
          kind: MonitorEventKind.AfterReduce,
          action: NavigationActions.doPush,
          route: RestaurantRoutes.RESTAURANTS_SEARCH_INITIAL);
      // === restaurant list should be empty before fetch
      expect(store.state.restaurants.length, equals(0));
      // ===fetch
      store.listRestaurants();
      await eventFetch;
      await eventFetchSuccess;
      await eventRedirect;
    });

    test('should load restaurants', () async {
      // === Should submit search
      final eventSearchSuccess = monitor.waitForFirst(
          kind: MonitorEventKind.AfterReduce,
          action: RestaurantActions.doSubmitSearch.success);
      // === waiting for doFetch request and success
      final eventFetch = monitor.waitForFirst(
          kind: MonitorEventKind.AfterReduce,
          action: RestaurantActions.doFetch.request);
      final eventFetchSuccess = monitor.waitForFirst(
          kind: MonitorEventKind.AfterReduce,
          action: RestaurantActions.doFetch.success);
      // === restaurant list should be empty before fetch
      expect(store.state.restaurants.length, equals(0));
      // ===fetch
      RestaurantQuery query = RestaurantQuery(
          limit: 100,
          order: RestaurantOrderQuery.Position,
          location: GeoPlace.fromLatLon(
              longitude: center.longitude, latitude: center.latitude));
      store.submitSearch(query);
      await eventSearchSuccess;
      await eventFetch;
      await eventFetchSuccess;
      expect(store.state.restaurants.length, equals(7));
    });

    test('should load more restaurants', () async {
      /// === Waiting for load more and fetch success
      final eventLoadMore = monitor.waitForFirst(
          kind: MonitorEventKind.AfterReduce,
          action: RestaurantActions.doLoadMore);
      final eventFetchSuccess = monitor.waitForEventAfter(eventLoadMore,
          kind: MonitorEventKind.AfterReduce,
          action: RestaurantActions.doFetch.success);
      // === restaurants list should contains 7
      expect(store.state.restaurants.length, equals(7));
      // === do load more
      store.loadMore();
      await eventLoadMore;
      await eventFetchSuccess;
      expect(store.state.restaurants.length, equals(10));
    });

    test('should not load more restaurants', () async {
      /// === Waiting for load more and fetch success
      final eventLoadMore = monitor.waitForFirst(
          kind: MonitorEventKind.OnWorkflowAction,
          action: RestaurantActions.doLoadMore);
      final eventFetchSuccess = monitor.waitForEventAfter(eventLoadMore,
          kind: MonitorEventKind.AfterReduce,
          action: RestaurantActions.doFetch.success);
      // === restaurants list should contains 10
      expect(store.state.restaurants.length, equals(10));
      // === do load more
      store.loadMore();
      await eventLoadMore;
      await eventFetchSuccess;
      expect(store.state.restaurants.length, equals(10));
    });

    test('should not switch to detail without arg', () async {
      /// === Waiting for a change page to RESTAURANTS_DETAIL
      final eventStartDetail =
          monitor.waitForFirst(kind: MonitorEventKind.OnAddWorkflowChild);
      //=== waiting for a redirect to RESTAURANT_LIST because of null
      final eventCancelDetail =
          monitor.waitForFirst(kind: MonitorEventKind.OnAddWorkflowChild);
      // === see detail of null => should redirect to list
      store.seeRestaurantDetails(null);
      final resStart = await eventStartDetail;
      expect(resStart.workflow, isInstanceOf<RestaurantDetailWorkflow>());
      final resCancel = await eventCancelDetail;
      expect(resCancel.workflow, isInstanceOf<RestaurantDetailWorkflow>());
    });

    test('should switch to detail view', () async {
      bool finished = false;
      try {
        // === Wait for a redirect to RESTAURANT_DETAILS
        final eventRedirectDetail = monitor.waitForFirst(
            kind: MonitorEventKind.AfterReduce,
            action: NavigationActions.doPush,
            route: RestaurantRoutes.RESTAURANTS_DETAIL);
        // === Wait for a new fork
        final eventNewFork =
            monitor.waitForFirst(kind: MonitorEventKind.OnAddWorkflowChild);
        // === Wait for a load detail succeed
        final eventSuccess = monitor.waitForFirst(
            kind: MonitorEventKind.AfterReduce,
            action: RestaurantActions.doLoadDetail.success);
        //
        store.seeRestaurantDetails(restaus[0]);
        await eventRedirectDetail;
        final newEvent = await eventNewFork;
        expect(newEvent.workflow, isInstanceOf<RestaurantDetailWorkflow>());
        await eventSuccess;
        expect(store.state.currentDetail.products.length, equals(5));
        expect(store.state.currentDetail.categories.length, equals(5));
        expect(store.state.current.slots.length, equals(5));
        finished = true;
      } on EffectCancelError catch (_) {
        print("should switch to detail view : canceled");
        expect(finished, equals(true));
      }
    });

    test('should cancel detail workflow when going anew', () async {
      // === Wait for a redirect to RESTAURANT_LIST
      final eventRedirectDetail = monitor.waitForFirst(
          kind: MonitorEventKind.OnWorkflowAction,
          action: NavigationActions.doPush,
          route: RestaurantRoutes.RESTAURANTS_DETAIL);
      // === Wait for a cancel of detail workflow
      final eventEndWorflow =
          monitor.waitForFirst(kind: MonitorEventKind.OnRemoveWorkflowChild);
      store.seeRestaurantDetails(restaus[0]);
      await eventRedirectDetail;
      final newEvent = await eventEndWorflow;
      expect(newEvent.workflow, isInstanceOf<RestaurantDetailWorkflow>());
    });

    test('should not load more restaurants after going back', () async {
      /// === Wait for pop
      final eventPop = monitor.waitForFirst(
          kind: MonitorEventKind.AfterReduce,
          route: RestaurantRoutes.RESTAURANTS_LIST);
      store.workflow.publishAction(NavigationActions.createPopChanged(Routes(
          previous: RestaurantRoutes.RESTAURANTS_DETAIL,
          current: RestaurantRoutes.RESTAURANTS_LIST)));
      await eventPop;

      /// === Wait for a load more action and fetch success
      final eventLoadMore = monitor.waitForFirst(
          kind: MonitorEventKind.OnWorkflowAction,
          action: RestaurantActions.doLoadMore);
      final eventFetchSuccess = monitor.waitForEventAfter(eventLoadMore,
          kind: MonitorEventKind.AfterReduce,
          action: RestaurantActions.doFetch.success);
      // === Load more restaurants
      expect(store.state.restaurants.length, equals(10));
      store.loadMore();
      await eventLoadMore;
      final event = await eventFetchSuccess;
      expect((event.action.payload as List<RestaurantModel>).length, equals(0));
      expect(store.state.restaurants.length, equals(10));
    });

    test('should not load more restaurants after going back', () async {
      /// === Wait for a load more action and fetch success
      final eventLoadMore = monitor.waitForFirst(
          kind: MonitorEventKind.OnWorkflowAction,
          action: RestaurantActions.doLoadMore);
      final eventFetchSuccess = monitor.waitForEventAfter(eventLoadMore,
          kind: MonitorEventKind.AfterReduce,
          action: RestaurantActions.doFetch.success);
      // === Load more restaurants
      expect(store.state.restaurants.length, equals(10));
      store.loadMore();
      await eventLoadMore;
      final event = await eventFetchSuccess;
      expect((event.action.payload as List<RestaurantModel>).length, equals(0));
      expect(store.state.restaurants.length, equals(10));
    });

    test('should not found restaurants after changing search', () async {
      // === Wait for a redirect to search page
      final eventRedirect = monitor.waitForFirst(
          kind: MonitorEventKind.AfterReduce,
          route: RestaurantRoutes.RESTAURANTS_SEARCH,
          action: NavigationActions.doPush);
      // === Open search
      store.searchRestaurants();
      await eventRedirect;
      // === Wait for submit search
      final eventSearchSuccess = monitor.waitForFirst(
          kind: MonitorEventKind.AfterReduce,
          action: RestaurantActions.doSubmitSearch.success);
      // === Wait for list search
      final eventRestaurantList = monitor.waitForFirst(
          kind: MonitorEventKind.AfterReduce,
          action: RestaurantActions.doFetch.success);
      // === Wait for a redirect back when search succeed
      final eventGoBack = monitor.waitForFirst(
          kind: MonitorEventKind.AfterReduce, action: NavigationActions.doPop);
      // === change search
      expect(store.state.restaurants.length, equals(10));
      RestaurantQuery query = RestaurantQuery(
          limit: 100,
          order: RestaurantOrderQuery.Position,
          location: GeoPlace.fromLatLon(longitude: 0, latitude: 0));
      store.submitSearch(query);
      await eventSearchSuccess;
      await eventGoBack;
      await eventRestaurantList;
      // === should not found restaurant
      expect(store.state.restaurants.length, equals(0));
    });
  });
}
