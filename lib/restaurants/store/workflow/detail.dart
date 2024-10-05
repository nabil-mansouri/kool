import 'dart:async';
import 'package:food/multiflow/multiflow.dart';
import 'package:food/commerce/commerce.dart';
import '../../domain/domain.dart';
import '../states.dart';
import '../actions.dart';
import '../routes.dart';

class RestaurantDetailWorkflow extends Workflow<RestaurantState> {
  final RestaurantService service = getRestaurantService();
  final CartActions cartAction;
  RestaurantDetailWorkflow(Store<RestaurantState> store, this.cartAction)
      : super(store) {
    logging = true;
  }

  Future<bool> _startLoadDetail() async {
    // === If no current restaurant => redirect
    if (this.store.state.current == null) {
      print("[Workflow][RestaurantDetail] current is null so redirecting...");
      return Future.value(false);
    }
    this.store.sendAction(
        NavigationActions.createPush(RestaurantRoutes.RESTAURANTS_DETAIL));
    // === Fetch restaurant detail
    Future<RestaurantDetailModel> result =
        this.service.fetchDetail(this.store.state.current);
    this.store.sendActionFuture(
        RestaurantActions.doLoadDetail.request.withPayload(result));
    final effectSuccess = takeAction(RestaurantActions.doLoadDetail.success);
    final effectResult = await race([
      effectSuccess,
      takeAction(RestaurantActions.doLoadDetail.failed),
    ]).future;
    // == Wait for detail loaded
    print(
        "[Workflow][RestaurantDetail] detail loaded ${effectResult == effectSuccess}");
    return true;
  }

  EffectStream<Action> _forEachRefreshEvent() {
    // === For each refresh events
    print("[Workflow][RestaurantDetail] start waiting for load more");
    return takeEvery(RestaurantActions.doRefreshDetail, debounceMs: 300,
        callback: (action) async {
      print("[Workflow][RestaurantDetail] refreshing..");
      // === Reload detail
      Future<RestaurantDetailModel> result =
          this.service.fetchDetail(this.store.state.current);
      await this.store.sendActionFuture(
          RestaurantActions.doLoadDetail.request.withPayload(result));
      print("[Workflow][RestaurantDetail] refreshed");
    });
  }

  EffectStream<Action> _forEachProductSelected() {
    // === Foreach product select event
    print("[Workflow][RestaurantDetail] start waiting for product selection");
    return takeEvery(RestaurantActions.doSelectProductDetails, debounceMs: 100,
        callback: (action) async {
      // === send a cartelectProduct Action with product as param
      var product = action.payload;
      print("[Workflow][RestaurantDetail] selected product ${product.name}");
      this.cartAction.loadProduct(product);
      print("[Workflow][RestaurantDetail] pushed a navigation to cart");
    });
  }

  @override
  Future<Object> workflow() async {
    try {
      print("[Workflow][RestaurantDetail] starting...");
      final res = await _startLoadDetail();
      if (!res) return true;
      await join([_forEachRefreshEvent(), _forEachProductSelected()]).future;
      return true;
    } finally {
      print("[Workflow][RestaurantDetail] ended");
    }
  }
}
