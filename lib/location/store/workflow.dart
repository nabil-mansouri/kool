import 'dart:async';
import 'package:food/multiflow/multiflow.dart';
import '../domain/domain.dart';
import 'state.dart';
import 'actions.dart';

class LocationWorkflow extends Workflow<LocationState> {
  final locationService = getLocationService();
  LocationWorkflow(Store<LocationState> store) : super(store) {
    logging = true;
  }

  EffectStream<Action<CurrentPositionActionPayload>>
      _forEachLoadCurrentPosition() {
    // === On Ask position => fetch
    print("[Workflow][Location] start listening current position");
    return takeEvery(LocationActions.doCurrentPosition.query, debounceMs: 250,
        callback: (action) async {
      print("[Workflow][Location] load current position");
      final address = locationService.currentAddress(
        askPermission: action.payload.askPermIfNeeded,
      );
      this.store.sendActionFuture(
          LocationActions.doCurrentPosition.request.withPayload(address));
      print("[Workflow][Location] sent current position");
    });
  }

  EffectStream<Action<FetchRecentPlacesActionPayload>>
      _forEachFetchRecentPlaces() {
    // === On Ask position => fetch
    print("[Workflow][Location] start listening fetch recent places");
    return takeEvery(LocationActions.doFetchRecentPlaces.query, debounceMs: 150,
        callback: (action) async {
      print("[Workflow][Location] fetch recent places");
      final recent = locationService.getRecentPlaces();
      this.store.sendActionFuture(
          LocationActions.doFetchRecentPlaces.request.withPayload(recent));
    });
  }

  EffectStream<Action<SearchPlaceActionPayload>> _forEachSearchPlace() {
    // === On Ask position => fetch
    print("[Workflow][Location] start listening search places");
    return takeEvery(LocationActions.doSearchPlace.query, debounceMs: 150,
        callback: (action) async {
      print("[Workflow][Location] search places");
      final recent = locationService.getPositionFromAddress(
          action.payload.textSearch,
          keepOnlyFullAddress: action.payload.keepOnlyAddress);
      this.store.sendActionFuture(
          LocationActions.doSearchPlace.request.withPayload(recent));
    });
  }

  EffectStream<Action<GeoPlace>> _forEachSaveRecentPlace() {
    // === On Ask position => fetch
    print("[Workflow][Location] start listening save recent places");
    return takeEvery(LocationActions.doSaveRecentPlace.query, debounceMs: 150,
        callback: (action) async {
      print("[Workflow][Location] save recent places");
      final recent = locationService.addToRecentPlace(action.payload);
      this.store.sendActionFuture(
          LocationActions.doSaveRecentPlace.request.withPayload(recent));
    });
  }

  @override
  Future<Object> workflow() async {
    // when ask current position =>
    try {
      print("[Workflow][Location] starting...");
      await join([
        _forEachLoadCurrentPosition(),
        _forEachFetchRecentPlaces(),
        _forEachSearchPlace(),
        _forEachSaveRecentPlace()
      ]).future;
      return true;
    } catch (e) {
      print("[Workflow][Location] ended with error !!!!!! " + e);
      return false;
    } finally {
      print("[Workflow][Location] ended");
    }
  }
}
