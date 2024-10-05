import 'dart:async';
import 'package:food/multiflow/multiflow.dart';
import "package:food/location/location.dart";
import 'package:food/commerce/commerce.dart';
import '../../domain/domain.dart';
import '../states.dart';
import '../routes.dart';
import '../actions.dart';
import 'detail.dart';

/*
 *WORKFLOW 
 */
class RestaurantWorkflow extends Workflow<RestaurantState> {
  static double maxRadius = 30;
  static int minNumberOfData = 10;
  static double addRadius = 5;
  static int limitRestaurants = 100;
  final RestaurantService service = getRestaurantService();
  final LocationActions locationActions;
  final CartActions cartActions;
  RestaurantListCursor restoCursor;
  Effect effectForked;
  RestaurantWorkflow(
      Store<RestaurantState> store, this.locationActions, this.cartActions)
      : super(store) {
    logging = true;
  }

  Future<void> _startRestaurantList(bool redirect) async {
    // === If position not setted go to search
    final last = await service.getLastQuery();
    RestaurantQuery query;
    if (last.isPresent) {
      query = last.value;
    } else {
      query = await _startSearch(onlyIfNeeded: true);
    }
    if (redirect) {
      this.store.sendAction(
          NavigationActions.createPush(RestaurantRoutes.RESTAURANTS_LIST));
    }
    this.store.sendAction(RestaurantActions.doQueryChange.withPayload(query));
    // === If query ready => start cursor
    restoCursor = this.service.fetchCursor(query,
        maxRadius: maxRadius,
        addRadius: addRadius,
        minNumberOfData: minNumberOfData);
    this.store.sendActionFuture(
        RestaurantActions.doFetch.request.withPayload(restoCursor.next()));
    final effectSuccess = takeAction(RestaurantActions.doFetch.success);
    final effectResult = await race([
      effectSuccess,
      takeAction(RestaurantActions.doFetch.failed),
    ]).future;
    // === Waited for cursor
    print(
        "[Workflow][Restaurant] cursor start ${effectResult == effectSuccess ? "succed" : "failed"}");
  }

  Future<RestaurantQuery> _submitSearch() async {
    //always reload to get last selected place
    locationActions.fetchRecentPlaces(reloadIfAlreadyFetched: true);
    while (true) {
      try {
        final action =
            await takeAction(RestaurantActions.doSubmitSearch.query).future;
        final query = action.payload;
        print("[Workflow][Restaurant] submit search ...");
        final futureQuery = service.setLastQuery(query);
        locationActions.saveRecentPlace(query.location);
        this.store.sendActionFuture(
            RestaurantActions.doSubmitSearch.request.withPayload(futureQuery));
        print("[Workflow][Restaurant] wait for submit search $query");
        final querySuccess = await futureQuery;
        return querySuccess;
      } catch (e) {
        print("[Workflow][Restaurant] submit search failed: $e");
      }
    }
  }

  Future<RestaurantQuery> _startSearch({bool onlyIfNeeded = false}) async {
    try {
      print(
          "[Workflow][Restaurant] start search flow only if needed $onlyIfNeeded");
      // === Get last cursor saved
      final lastFuture = service.getLastQuery();
      this.store.sendActionFuture(
          RestaurantActions.doLoadSearch.request.withPayload(lastFuture));
      if (onlyIfNeeded) {
        // === If no query setted => force the user to set one
        final last = await lastFuture;
        print(
            "[Workflow][Restaurant] a previous search query exists? ${last.isPresent}");
        if (last.isPresent) {
          return last.value;
        } else {
          this.store.sendAction(NavigationActions.createPush(
              RestaurantRoutes.RESTAURANTS_SEARCH_INITIAL));
          final query = await _submitSearch();
          // === Go back when succeed
          this.store.sendAction(NavigationActions.createPop());
          return query;
        }
      } else {
        // === Let the user change the query
        this.store.sendAction(
            NavigationActions.createPush(RestaurantRoutes.RESTAURANTS_SEARCH));
        locationActions.getCurrentPosition(
            askPermIfNeeded: true, lastKnownIfneeded: true);
        final query = await _submitSearch();
        // === Go back when succeed
        this.store.sendAction(NavigationActions.createPop());
        return query;
      }
    } finally {
      print("[Workflow][Restaurant] ended search flow");
    }
  }

  EffectStream<Action<RestaurantModel>> _forEachDetailQuery() {
    // === On Ask for fetch => do fetch
    print("[Workflow][Restaurant] start waiting for load more");
    return takeEvery(RestaurantActions.doLoadDetail.query, debounceMs: 250,
        callback: (action) async {
      print(
          "[Workflow][Restaurant] load restaurant detail => cancel previous fork $effectForked");
      store.state.current = action.payload;
      cancel(effectForked);
      effectForked = null;
      print("[Workflow][Restaurant] canceled previous detail workflow");
      effectForked = fork(RestaurantDetailWorkflow(store, cartActions));
      print("[Workflow][Restaurant] started a new detail workflow");
    });
  }

  EffectStream<Action<Object>> _forEachListEvent() {
    // === On Ask for fetch => do fetch
    print("[Workflow][Restaurant] start waiting for load more");
    return takeEvery(RestaurantActions.doFetch.query, debounceMs: 100,
        callback: (action) async {
      _startRestaurantList(true);
    });
  }

  EffectStream<Action> _forEachLoadMoreEvent() {
    // === On refresh event => fetch more from cursor
    print("[Workflow][Restaurant] start waiting for load more");
    return takeEvery(RestaurantActions.doAskLoadMore, debounceMs: 1000,
        callback: (action) async {
      try {
        print("[Workflow][Restaurant] loading more...");
        await this.store.sendActionFuture(
            RestaurantActions.doLoadMore.withPayload(restoCursor.next()));
        print("[Workflow][Restaurant] loaded more");
      } finally {
        print("[Workflow][Restaurant] load more ready");
      }
    });
  }

  EffectStream<Action<Routes>> _forEachNavigationChange() {
    // === For each navigation changes => cancel for if needed
    print("[Workflow][Restaurant] start waiting for restaurant selection");
    return takeEvery(NavigationActions.doChanged, debounceMs: 250,
        callback: (action) async {
      Routes routeActionPayload = action.payload;
      // === If we are comming from detail page => dont forget to cancel previous fork
      if (routeActionPayload.previous != null &&
          routeActionPayload.previous == RestaurantRoutes.RESTAURANTS_DETAIL) {
        //FIX: Dont cancel fork => on back from cart => it cancel detail actions
        //print("[Workflow][Restaurant] quit restaurant detail");
        //cancel(effectForked);
        //effectForked = null;
        //print("[Workflow][Restaurant] canceled previous detail workflow");
      }
    });
  }

  EffectStream<Action<Object>> _forEachSearchEvent() {
    // === For each search event => go to search page
    print("[Workflow][Restaurant] start waiting for search event");
    return takeEvery(RestaurantActions.doLoadSearch.query, debounceMs: 250,
        callback: (action) async {
      await _startSearch(onlyIfNeeded: false);
      _startRestaurantList(false);
    });
  }

  @override
  Future<Object> workflow() async {
    try {
      print("[Workflow][Restaurant] starting...");
      //Map<String, dynamic> restoCursorState = restoCursor.backup();
      await join([
        _forEachListEvent(),
        _forEachLoadMoreEvent(),
        _forEachNavigationChange(),
        _forEachSearchEvent(),
        _forEachDetailQuery()
      ]).future;
      return true;
    } catch (e) {
      print("[Workflow][Restaurant] ended with error !!!!!! " + e);
      return false;
    } finally {
      print("[Workflow][Restaurant] ended");
    }
  }
}
