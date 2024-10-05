import '../domain/domain.dart';

class RestaurantState {
  bool fetchFailed = false;
  bool loadingFirst = false;
  bool loadingMore = false;
  bool loadMoreReady = false;
  RestaurantQuery currentQuery;

  List<RestaurantModel> restaurants = [];
  //
  RestaurantModel current;
  RestaurantDetailModel currentDetail;
  bool loadingDetail = false;
  //
  copy() {
    var copy = RestaurantState();
    copy
      ..currentQuery = this.currentQuery
      ..fetchFailed = this.fetchFailed
      ..loadingFirst = this.loadingFirst
      ..loadMoreReady = this.loadMoreReady
      ..loadingMore = this.loadingMore
      ..restaurants = this.restaurants
      ..current = this.current
      ..loadingDetail = this.loadingDetail
      ..currentDetail = this.currentDetail;
    return copy;
  }

  resetCurrent() {
    this.current = null;
    this.currentDetail = null;
    this.loadingDetail = false;
  }
}
