import 'package:food/multiflow/multiflow.dart';
import 'package:flutter/services.dart';
import 'workflow.dart';
import 'actions.dart';
import 'state.dart';
import 'routes.dart';
import '../domain/domain.dart';

export 'state.dart';
export 'actions.dart';
export 'routes.dart';

class LocationStore extends Store<LocationState> with LocationActions {
  LocationWorkflow workflow;

  LocationState getState() => state;
  LocationWorkflow getWorkflow() => workflow;

  LocationStore() : super(LocationState()) {
    logging = true;
    workflow = LocationWorkflow(this).start();
    //geolocalize
    this.addReducerForAction<CurrentPositionActionPayload>(
        LocationActions.doCurrentPosition.query,
        Reducer(_onCurrentPositionQuery));
    this.addReducerForAction<GeoAddressResult>(
        LocationActions.doCurrentPosition.success,
        Reducer(_onCurrentPositionSuccess));
    this.addReducerForAction(LocationActions.doCurrentPosition.failed,
        Reducer(_onCurrentPositionFailed));
    //search
    this.addReducerForAction<Routes>(
        NavigationActions.doChanged, Reducer(_onNavigationChanged));
    this.addReducerForAction<SearchPlaceActionPayload>(
        LocationActions.doSearchPlace.query, Reducer(_onSearchQuery));
    this.addReducerForAction<List<GeoPlace>>(
        LocationActions.doSearchPlace.success, Reducer(_onSearchSuccess));
    this.addReducerForAction(
        LocationActions.doSearchPlace.failed, Reducer(_onSearchFailed));
    //recent place
    this.addReducerForAction<List<GeoPlace>>(
        LocationActions.doFetchRecentPlaces.success,
        Reducer(_onRecentPlaceSuccess));
  }
  LocationState _onCurrentPositionQuery(
      Action<CurrentPositionActionPayload> action, LocationState state) {
    final clone = state.copy();
    clone.isGeolocalizing = true;
    clone.nbGeolocalisation++;
    return clone;
  }

  LocationState _onCurrentPositionSuccess(
      Action<GeoAddressResult> action, LocationState state) {
    final clone = state.copy();
    clone.current = action.payload;
    clone.isGeolocalizing = false;
    return clone;
  }

  LocationState _onCurrentPositionFailed(Action action, LocationState state) {
    final clone = state.copy();
    clone.isGeolocalizing = false;
    return clone;
  }

  LocationState _onNavigationChanged(
      Action<Routes> action, LocationState state) {
    final routes = action.payload;
    if (routes.current == LocationRoutes.LOCATION_SEARCH) {
      final clone = state.copy();
      clone.searchResults = [];
      clone.emptyResult = false;
      return clone;
    }
    return state;
  }

  LocationState _onSearchQuery(
      Action<SearchPlaceActionPayload> action, LocationState state) {
    final clone = state.copy();
    clone.textSearch = action.payload.textSearch;
    clone.searching = true;
    clone.emptyResult = false;
    return clone;
  }

  LocationState _onSearchSuccess(
      Action<List<GeoPlace>> action, LocationState state) {
    final clone = state.copy();
    clone.emptyResult = action.payload.length > 0;
    clone.searchResults = action.payload;
    clone.searching = false;
    return clone;
  }

  LocationState _onSearchFailed(Action action, LocationState state) {
    final clone = state.copy();
    clone.searching = false;
    if (action.payload is PlatformException) {
      PlatformException err = action.payload as PlatformException;
      if (err.code == "ERROR_GEOCODNG_ADDRESSNOTFOUND") {
        clone.emptyResult = true;
        clone.searchResults = [];
      }
    }
    return clone;
  }

  LocationState _onRecentPlaceSuccess(
      Action<List<GeoPlace>> action, LocationState state) {
    final clone = state.copy();
    clone.recents = action.payload;
    clone.recentsFetchedOn = DateTime.now();
    return clone;
  }
}
