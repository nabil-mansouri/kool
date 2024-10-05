import 'package:flutter_test/flutter_test.dart' hide group;
import 'package:test/test.dart' show group;
import 'package:food/multiflow/multiflow.dart';
import '../store/store.dart';

startWorkflowTest() {
  group("[Workflow]", () {
    final LocationStore store = LocationStore();
    StoreMonitor<LocationState> monitor = new StoreMonitor();

    setUpAll(() async {
      store.setState(LocationState()); //reset state
      store.workflow.locationService.removeRecentPlaces();
      store.addListener(monitor);
    });

    test('should get current position', () async {
      // === waiting for getting current position
      final eventFetch = monitor.waitForFirst(
          kind: MonitorEventKind.AfterReduce,
          action: LocationActions.doCurrentPosition.request);
      final eventFetchSuccess = monitor.waitForFirst(
          kind: MonitorEventKind.AfterReduce,
          action: LocationActions.doCurrentPosition.success);
      // ===fetch
      store.getCurrentPosition(askPermIfNeeded: true, lastKnownIfneeded: true);
      await eventFetch;
      await eventFetchSuccess;
      // === should have loaded current position
      expect(store.state.hasCurrent, equals(true));
      expect(store.state.current.hasPlace, equals(true));
    });

    test('should save current to recent place', () async {
      // === waiting for fetch current places
      final eventFetch = monitor.waitForFirst(
          kind: MonitorEventKind.AfterReduce,
          action: LocationActions.doSaveRecentPlace.request);
      final eventFetchSuccess = monitor.waitForFirst(
          kind: MonitorEventKind.AfterReduce,
          action: LocationActions.doSaveRecentPlace.success);
      store.saveRecentPlace(store.state.current.place);
      await eventFetch;
      await eventFetchSuccess;
    });

    test('should fetch recent place', () async {
      // === waiting for recent place
      final eventFetch = monitor.waitForFirst(
          kind: MonitorEventKind.AfterReduce,
          action: LocationActions.doFetchRecentPlaces.request);
      final eventFetchSuccess = monitor.waitForFirst(
          kind: MonitorEventKind.AfterReduce,
          action: LocationActions.doFetchRecentPlaces.success);
      store.fetchRecentPlaces();
      await eventFetch;
      await eventFetchSuccess;
      expect(store.state.recents.length, equals(1));
      expect(store.state.recentsFetchedOn, isNotNull);
    });

    test('should search place', () async {
      // === waiting for search query adn success
      final eventFetch = monitor.waitForFirst(
          kind: MonitorEventKind.AfterReduce,
          action: LocationActions.doSearchPlace.request);
      final eventFetchSuccess = monitor.waitForFirst(
          kind: MonitorEventKind.AfterReduce,
          action: LocationActions.doSearchPlace.success);
      store.searchPlace("71200 Le Creusot");
      await eventFetch;
      await eventFetchSuccess;
      expect(store.state.searchResults.length, isNot(equals(0)));
    });
  });
}
