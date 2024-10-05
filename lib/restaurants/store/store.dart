import 'package:food/multiflow/multiflow.dart';
import 'package:food/location/location.dart';
import 'package:food/commerce/commerce.dart';
import '../domain/domain.dart';
import 'workflow/workflow.dart';
import 'states.dart';
import 'actions.dart';
//
export 'routes.dart';
export 'workflow/workflow.dart';
export 'states.dart';
export 'actions.dart';
/*
 *STORE AND ACTION KEYS
 */

class RestaurantStore extends Store<RestaurantState> with RestaurantActions {
  RestaurantWorkflow workflow;
  final LocationActions locationActions;
  final CartActions cartActions;
  getWorkflow() => workflow;
  RestaurantStore(this.locationActions, this.cartActions)
      : super(RestaurantState()) {
    logging = true;
    this.workflow =
        RestaurantWorkflow(this, this.locationActions, this.cartActions)
            .start();
    //QUERY CHANGE
    this.addReducerForAction<RestaurantQuery>(
        RestaurantActions.doQueryChange, Reducer((_onQueryChange)));
    //FETCH
    this.addReducerForAction(
        RestaurantActions.doFetch.query, Reducer(_onFetchQuery));
    this.addReducerForAction(
        RestaurantActions.doFetch.request, Reducer(_onFetchRequest));
    this.addReducerForAction<List<RestaurantModel>>(
        RestaurantActions.doFetch.success, Reducer(_onFetchSuccess));
    this.addReducerForAction(
        RestaurantActions.doFetch.failed, Reducer(_onFetchFailed));
    //LOAD MORE
    this.addReducerForAction(
        RestaurantActions.doLoadMore, Reducer(_onLoadMore));
    //DETAIL
    this.addReducerForAction<RestaurantModel>(
        RestaurantActions.doLoadDetail.query, Reducer(_onLoadDetailQuery));
    this.addReducerForAction(
        RestaurantActions.doLoadDetail.request, Reducer(_onLoadDetailRequest));
    this.addReducerForAction(
        RestaurantActions.doLoadDetail.success, Reducer(_onLoadDetailSuccess));
    this.addReducerForAction(
        RestaurantActions.doLoadDetail.failed, Reducer(_onLoadDetailFailed));
  }

  RestaurantState _onQueryChange(
      Action<RestaurantQuery> action, RestaurantState state) {
    state = state.copy();
    state.currentQuery = action.payload;
    return state;
  }

  RestaurantState _onFetchQuery(Action action, RestaurantState state) {
    state = state.copy();
    state.loadingMore = false;
    state.loadMoreReady = true;
    return state;
  }

  RestaurantState _onFetchRequest(Action action, RestaurantState state) {
    state = state.copy();
    state.loadingFirst = true;
    state.loadingMore = false;
    state.loadMoreReady = false;
    return state;
  }

  RestaurantState _onFetchSuccess(
      Action<List<RestaurantModel>> action, RestaurantState state) {
    state = state.copy();
    if (state.loadingMore) {
      var copy = List<RestaurantModel>.from(state.restaurants ?? []);
      copy.addAll(action.payload);
      state.restaurants = copy;
    } else {
      state.restaurants = action.payload;
    }
    //after
    state.loadingFirst = false;
    state.loadingMore = false;
    state.loadMoreReady = true;
    return state;
  }

  RestaurantState _onFetchFailed(Action action, RestaurantState state) {
    state = state.copy();
    state.loadingFirst = false;
    state.loadingMore = false;
    state.loadMoreReady = true;
    return state;
  }

  RestaurantState _onLoadMore(Action action, RestaurantState state) {
    state = state.copy();
    state.loadingFirst = false;
    state.loadingMore = true;
    state.loadMoreReady = false;
    return state;
  }

  RestaurantState _onLoadDetailQuery(
      Action<RestaurantModel> action, RestaurantState state) {
    state = state.copy();
    state.current = action.payload;
    return state;
  }

  RestaurantState _onLoadDetailRequest(Action action, RestaurantState state) {
    state = state.copy();
    state.loadingDetail = true;
    return state;
  }

  RestaurantState _onLoadDetailSuccess(
      Action<RestaurantDetailModel> action, RestaurantState state) {
    state = state.copy();
    state.loadingDetail = false;
    state.currentDetail = action.payload;
    return state;
  }

  RestaurantState _onLoadDetailFailed(
      Action<dynamic> action, RestaurantState state) {
    state = state.copy();
    state.loadingDetail = false;
    return state;
  }
}
