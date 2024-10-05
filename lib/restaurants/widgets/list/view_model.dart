import 'package:intl/intl.dart';
import 'package:food/multiflow/multiflow.dart';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';
import 'package:food/location/location.dart';
import '../../store/store.dart';
import '../../domain/domain.dart';

class RestaurantListViewModel extends AbstractModel<RestaurantState> {
  List<RestaurantModel> restaurants = [];
  bool loadingMore;
  bool loadingFirst;
  bool loadMoreReady;
  Subject<bool> onLoadMoreChanged = PublishSubject();
  get hasRestaurants => this.restaurants.length > 0;
  onDispose() {
    onLoadMoreChanged.close();
    super.onDispose();
  }

  bool refresh(RestaurantState state) {
    var changed = false;
    if (this.restaurants != state.restaurants) {
      this.restaurants = state.restaurants;
      changed = true;
    }
    if (this.loadMoreReady != state.loadMoreReady) {
      this.loadMoreReady = state.loadMoreReady;
      //Dont need to trigger change
    }
    if (this.loadingFirst != state.loadingFirst) {
      this.loadingFirst = state.loadingFirst;
      changed = true;
    }
    if (this.loadingMore != state.loadingMore) {
      this.loadingMore = state.loadingMore;
      onLoadMoreChanged.add(this.loadingMore);
      changed = true;
    }
    return changed;
  }

  void loadMore(BuildContext context) {
    RestaurantActions actions =
        getStore<RestaurantStore>(context, RestaurantStore);
    actions.loadMore();
  }

  void seeRestaurantDetails(BuildContext context, RestaurantModel model) {
    RestaurantActions actions =
        getStore<RestaurantStore>(context, RestaurantStore);
    actions.seeRestaurantDetails(model);
  }
}

class RestaurantListAppBarViewModel extends AbstractModel<RestaurantState> {
  final formatter = new DateFormat("EEE. d MMMM 'dès' HH:mm"); //TODO
  String formattedAddress = "";
  DateTime forDate;
  bool forNow = true;
  bool _hasRestaurant = false;

  bool refresh(RestaurantState state) {
    var changed = false;
    if (this.formattedAddress !=
        state.currentQuery?.location?.formattedAddress) {
      this.formattedAddress = state.currentQuery?.location?.formattedAddress;
      changed = true;
    }
    if (this.forDate != state.currentQuery?.forDate) {
      this.forDate = state.currentQuery?.forDate;
      changed = true;
    }
    if (this.forNow != state.currentQuery?.forNow) {
      this.forNow = state.currentQuery?.forNow;
      changed = true;
    }
    if (this._hasRestaurant != state.restaurants?.isNotEmpty) {
      this._hasRestaurant = state.restaurants?.isNotEmpty;
      changed = true;
    }
    return changed;
  }

  get hasRestaurant => _hasRestaurant ?? false;
  openSearchView(BuildContext context) {
    getStore<RestaurantStore>(context, RestaurantStore).searchRestaurants();
  }

  String get currentLocationFormat {
    return formattedAddress ?? "";
  }

  String get currentDelayFormat {
    //TODO
    return forNow == true
        ? "DES QUE POSSIBLE"
        : forDate != null ? formatter.format(forDate) : "";
  }
}

class EmptyListViewModel extends AbstractModel<RestaurantState> {
  //
  @override
  bool refresh(RestaurantState state) {
    bool changed = false;
    return changed;
  }

  submitSearch(GeoPlace place) {
    RestaurantQuery query = RestaurantQuery();
    query.location = place;
    query.forNow = true;
    getStore<RestaurantStore>(lastContext.value, RestaurantStore)
        .submitSearch(query);
  }
}
