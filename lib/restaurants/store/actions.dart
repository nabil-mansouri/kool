import 'package:food/multiflow/multiflow.dart';
import 'package:food/commerce/commerce.dart';
import 'package:optional/optional.dart';
import '../domain/domain.dart';
import 'workflow/workflow.dart';

///
/// ACTIONS
///
abstract class RestaurantActions {
  //FETCH
  static final AsyncAction<List<RestaurantModel>, Object> doFetch =
      AsyncAction.create("restaurants.fetch");
  static final Action<RestaurantQuery> doQueryChange =
      Action.string<RestaurantQuery>("restaurants.query.changed");
//LOAD MORE
  static final Action<Object> doAskLoadMore =
      Action.string<Object>("restaurants.loadmore.askloadmore");
  static final ActionFuture<List<RestaurantModel>> doLoadMore =
      ActionFuture.string<List<RestaurantModel>>("restaurants.loadmore",
          success: doFetch.success, fail: doFetch.failed);
//DETAIL
  static final AsyncAction<RestaurantDetailModel, RestaurantModel>
      doLoadDetail = AsyncAction<RestaurantDetailModel, RestaurantModel>.create(
          "restaurants.detail.load");
  static final Action doRefreshDetail =
      Action.string("restaurants.detail.askrefresh");
  static final Action<ProductModel> doSelectProductDetails =
      Action.string<ProductModel>("restaurants.detail.product");
  //SEARCH
  static final AsyncAction<Optional<RestaurantQuery>, Object> doLoadSearch =
      AsyncAction<Optional<RestaurantQuery>, Object>.create(
          "restaurants.search.load");
  static final AsyncAction<RestaurantQuery, RestaurantQuery> doSubmitSearch =
      AsyncAction<RestaurantQuery, RestaurantQuery>.create(
          "restaurants.search.submit");

  //
  RestaurantWorkflow getWorkflow();

  listRestaurants() {
    getWorkflow().publishAction(doFetch.query);
  }

  loadMore() {
    getWorkflow().publishAction(doAskLoadMore);
  }

  seeRestaurantDetails(RestaurantModel model) {
    getWorkflow().store.sendAction(doLoadDetail.query.withPayload(model));
  }

  selectProduct(ProductModel product) {
    getWorkflow().publishAction(doSelectProductDetails.withPayload(product));
  }

  searchRestaurants() {
    getWorkflow().publishAction(doLoadSearch.query);
  }

  submitSearch(RestaurantQuery query) {
    getWorkflow().publishAction(doSubmitSearch.query.withPayload(query));
  }
}
