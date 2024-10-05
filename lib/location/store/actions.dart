import 'package:food/multiflow/multiflow.dart';
import '../domain/domain.dart';
import 'workflow.dart';
import 'state.dart';

abstract class LocationActions {
  static AsyncAction<GeoAddressResult, CurrentPositionActionPayload>
      doCurrentPosition = AsyncAction.create("locations.current");
  static AsyncAction<List<GeoPlace>, FetchRecentPlacesActionPayload>
      doFetchRecentPlaces = AsyncAction.create("locations.recents.fetch");
  static AsyncAction<GeoPlace, GeoPlace> doSaveRecentPlace =
      AsyncAction.create("locations.recents.save");
  static AsyncAction<List<GeoPlace>, SearchPlaceActionPayload> doSearchPlace =
      AsyncAction.create("locations.search");

  LocationState getState();
  LocationWorkflow getWorkflow();

  getCurrentPosition(
      {bool askPermIfNeeded = false, bool lastKnownIfneeded = false}) {
    getWorkflow().publishAction(
        doCurrentPosition.query.withPayload(CurrentPositionActionPayload(
            askPermIfNeeded: askPermIfNeeded,
            lastKnownIfneeded: lastKnownIfneeded)),
        true);
  }

  getCurrentPositionIfNotAlready(
      {bool askPermIfNeeded = false, bool lastKnownIfneeded = false}) {
    if (getState().nbGeolocalisation == 0) {
      getCurrentPosition(
          askPermIfNeeded: askPermIfNeeded,
          lastKnownIfneeded: lastKnownIfneeded);
    }
  }

  fetchRecentPlaces({bool reloadIfAlreadyFetched = false}) {
    if (!reloadIfAlreadyFetched && getState().hasFetchRecentPlaces) {
      return;
    }
    getWorkflow().publishAction(doFetchRecentPlaces.query.withPayload(
        FetchRecentPlacesActionPayload(
            reloadIfAlreadyFetched: reloadIfAlreadyFetched)));
  }

  saveRecentPlace(GeoPlace place) {
    getWorkflow().publishAction(doSaveRecentPlace.query.withPayload(place));
  }

  searchPlace(String textSearch, {bool keepOnlyAddress}) {
    if (textSearch == null || textSearch.length < 2) {
      return;
    }
    getWorkflow().publishAction(doSearchPlace.query.withPayload(
        SearchPlaceActionPayload(textSearch,
            keepOnlyAddress: keepOnlyAddress)));
  }
}

class SearchPlaceActionPayload {
  final String textSearch;
  final bool keepOnlyAddress;
  SearchPlaceActionPayload(this.textSearch, {this.keepOnlyAddress = false});
}

class CurrentPositionActionPayload {
  final bool askPermIfNeeded;
  final bool lastKnownIfneeded;
  CurrentPositionActionPayload({this.askPermIfNeeded, this.lastKnownIfneeded});
}

class FetchRecentPlacesActionPayload {
  final bool reloadIfAlreadyFetched;
  FetchRecentPlacesActionPayload({this.reloadIfAlreadyFetched});
}
