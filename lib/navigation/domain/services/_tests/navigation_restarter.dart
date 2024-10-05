import 'package:meta/meta.dart';
import 'package:optional/optional.dart';
import 'package:flutter_test/flutter_test.dart';
import '../services.dart';

class _Timer {
  DateTime _measure;
  int _elapsedMS = 0;
  int get elapsedMS => _elapsedMS;
  double get elapsedMSd => _elapsedMS * 1.0;
  startMesure() {
    _elapsedMS = 0;
    _measure = DateTime.now();
    return this;
  }

  endMeasure() {
    _elapsedMS = DateTime.now().difference(_measure).inMilliseconds;
    return this;
  }
}

class _Direction implements Direction {
  final PolyLine polyline;
  _Direction(this.polyline);
  int get distanceInMeter {
    return polyline.distanceInMeter.round();
  }

  //10m/s
  int get travelTimeInSec => (distanceInMeter / 10).round();
  int get stepsCount => polyline.countVectors;
  Optional<DirectionStep> stepForIndex({@required int indexOfPoint}) {
    return Optional.empty();
  }
}

int _restarted = 0;
final leCreusot = Point(46.8, 4.4333);
final near = NearestPointOnSegment(
    segmentIndex: 0,
    endToPoint: Vector(leCreusot, leCreusot),
    startToEnd: Vector(leCreusot, leCreusot),
    startToPoint: Vector(leCreusot, leCreusot));
final point1 = leCreusot.transform(100, 0);
final point2 = point1.transform(200, 20);
final point3 = point2.transform(300, 40);
final polyline = PolyLine([leCreusot, point1, point2, point3]);
final farPoint = leCreusot.transform(-100, -180);
final limitPoint = leCreusot.transform(-10, -180);
final nearPoint = leCreusot.transform(-1, -180);
final inSegPoint = leCreusot.transform(1, 0);
Future<void> _callback() async {
  _restarted++;
}

final restarter = NavigationRestarterDoRestart(_callback);
unitTestNavigationRestarter() {
  group('[NavigationRestarter]', () {
    _unitTestAvoidFlood();
    _unitTestNotInPolyline();
    _unitTestDefaultRestarter();
  });
}

_unitTestAvoidFlood() {
  group('[NavigationRestarterAvoidFlood]', () {
    final infos = NavigationInfos(NavigationInfosConfig());

    test('should restart', () async {
      _restarted = 0;
      final navRestarter =
          NavigationRestarterAvoidFlood(child: restarter, secondsBetween: 1);
      final f1 = navRestarter.mayRestart(infos, Optional.empty());
      expect(_restarted, equals(0));
      final t1 = _Timer().startMesure();
      await f1;
      t1.endMeasure();
      expect(t1.elapsedMSd, moreOrLessEquals(1000, epsilon: 100));
      expect(_restarted, equals(1));
    });
    test('should not restart', () async {
      _restarted = 0;
      final navRestarter =
          NavigationRestarterAvoidFlood(child: restarter, secondsBetween: 1);
      final f1 = navRestarter.mayRestart(infos, Optional.of(near));
      expect(_restarted, equals(0));
      await f1;
      expect(_restarted, equals(0));
    });
    test('should increase restart time', () async {
      _restarted = 0;
      final navRestarter =
          NavigationRestarterAvoidFlood(child: restarter, secondsBetween: 1);
      final f1 = navRestarter.mayRestart(infos, Optional.empty());
      final t1 = _Timer().startMesure();
      await f1;
      t1.endMeasure();
      expect(t1.elapsedMSd, moreOrLessEquals(1000.0, epsilon: 100));
      expect(_restarted, equals(1));
      final f2 = navRestarter.mayRestart(infos, Optional.empty());
      final t2 = _Timer().startMesure();
      await f2;
      t2.endMeasure();
      expect(t2.elapsedMSd, moreOrLessEquals(2000.0, epsilon: 100));
      expect(_restarted, equals(2));
      final f3 = navRestarter.mayRestart(infos, Optional.empty());
      final t3 = _Timer().startMesure();
      await f3;
      t3.endMeasure();
      expect(t3.elapsedMSd, moreOrLessEquals(3000.0, epsilon: 100));
      expect(_restarted, equals(3));
    });
    test('should cancel restart because status change', () async {
      _restarted = 0;
      final navRestarter =
          NavigationRestarterAvoidFlood(child: restarter, secondsBetween: 1);
      final f1 = navRestarter.mayRestart(infos, Optional.empty());
      navRestarter.mayRestart(infos, Optional.of(near));
      await f1;
      expect(_restarted, equals(0));
    });
    test('should reset timer', () async {
      _restarted = 0;
      final navRestarter =
          NavigationRestarterAvoidFlood(child: restarter, secondsBetween: 1);
      final f1 = navRestarter.mayRestart(infos, Optional.empty());
      final t1 = _Timer().startMesure();
      await f1;
      t1.endMeasure();
      expect(t1.elapsedMSd, moreOrLessEquals(1000.0, epsilon: 100));
      expect(_restarted, equals(1));
      //reset timer
      navRestarter.mayRestart(infos, Optional.of(near));
      //
      final f2 = navRestarter.mayRestart(infos, Optional.empty());
      final t2 = _Timer().startMesure();
      await f2;
      t2.endMeasure();
      expect(t2.elapsedMSd, moreOrLessEquals(1000.0, epsilon: 100));
      expect(_restarted, equals(2));
    });
    test('should not reset timer', () async {
      _restarted = 0;
      final navRestarter =
          NavigationRestarterAvoidFlood(child: restarter, secondsBetween: 1);
      final f1 = navRestarter.mayRestart(infos, Optional.empty());
      final t1 = _Timer().startMesure();
      await f1;
      t1.endMeasure();
      expect(t1.elapsedMSd, moreOrLessEquals(1000.0, epsilon: 100));
      expect(_restarted, equals(1));
      //
      final f2 = navRestarter.mayRestart(infos, Optional.empty());
      final t2 = _Timer().startMesure();
      await f2;
      t2.endMeasure();
      expect(t2.elapsedMSd, moreOrLessEquals(2000.0, epsilon: 100));
      expect(_restarted, equals(2));
    });
    test('shouldupdate operation if a pending operation exists', () async {
      _restarted = 0;
      final navRestarter =
          NavigationRestarterAvoidFlood(child: restarter, secondsBetween: 1);
      //call 3 times
      final f1 = navRestarter.mayRestart(infos, Optional.empty());
      navRestarter.mayRestart(infos, Optional.empty());
      navRestarter.mayRestart(infos, Optional.empty());
      await f1;
      expect(_restarted, equals(1));
      final f2 = navRestarter.mayRestart(infos, Optional.empty());
      await f2;
      expect(_restarted, equals(2));
      final f3 = navRestarter.mayRestart(infos, Optional.empty());
      await f3;
      expect(_restarted, equals(3));
    });
  });
}

_unitTestNotInPolyline() {
  group('[NavigationRestarterFirstPositionMayNotInPolyline]', () {
    final infos = NavigationInfos(NavigationInfosConfig());

    test('should not restart because no position', () async {
      _restarted = 0;
      final navRestarter = NavigationRestarterFirstPositionMayNotInPolyline(
          child: restarter, maxMetersToTheFirstPoint: 10);
      final f1 = navRestarter.mayRestart(infos, Optional.of(near));
      expect(_restarted, equals(0));
      await f1;
      expect(_restarted, equals(0));
    });
    test('should not restart because no polyline', () async {
      _restarted = 0;
      infos.setCurrent(leCreusot);
      final navRestarter = NavigationRestarterFirstPositionMayNotInPolyline(
          child: restarter, maxMetersToTheFirstPoint: 10);
      final f1 = navRestarter.mayRestart(infos, Optional.of(near));
      expect(_restarted, equals(0));
      await f1;
      expect(_restarted, equals(0));
    });
    test('should not restart because empty polyline', () async {
      _restarted = 0;
      infos.start(_Direction(PolyLine([])), TransportType.Car);
      infos.setCurrent(leCreusot);
      final navRestarter = NavigationRestarterFirstPositionMayNotInPolyline(
          child: restarter, maxMetersToTheFirstPoint: 10);
      final f1 = navRestarter.mayRestart(infos, Optional.of(near));
      expect(_restarted, equals(0));
      await f1;
      expect(_restarted, equals(0));
    });
    test('should restart because far from segment', () async {
      infos.start(_Direction(polyline), TransportType.Car);
      infos.setCurrent(farPoint);
      _restarted = 0;
      final navRestarter = NavigationRestarterFirstPositionMayNotInPolyline(
          child: restarter, maxMetersToTheFirstPoint: 10);
      final f1 = navRestarter.mayRestart(infos, Optional.of(near));
      await f1;
      expect(_restarted, equals(1));
    });
    test('should not restart because it is at limit from segment', () async {
      infos.start(_Direction(polyline), TransportType.Car);
      infos.setCurrent(limitPoint);
      _restarted = 0;
      final navRestarter = NavigationRestarterFirstPositionMayNotInPolyline(
          child: restarter, maxMetersToTheFirstPoint: 10);
      final f1 = navRestarter.mayRestart(infos, Optional.of(near));
      expect(_restarted, equals(0));
      await f1;
      expect(_restarted, equals(0));
    });
    test('should not restart because it is near segment', () async {
      infos.start(_Direction(polyline), TransportType.Car);
      infos.setCurrent(nearPoint);
      _restarted = 0;
      final navRestarter = NavigationRestarterFirstPositionMayNotInPolyline(
          child: restarter, maxMetersToTheFirstPoint: 10);
      final f1 = navRestarter.mayRestart(infos, Optional.of(near));
      expect(_restarted, equals(0));
      await f1;
      expect(_restarted, equals(0));
    });
    test('should not restart because it is in segment', () async {
      infos.start(_Direction(polyline), TransportType.Car);
      infos.setCurrent(inSegPoint);
      infos.setCurrentSegment(near);
      _restarted = 0;
      final navRestarter = NavigationRestarterFirstPositionMayNotInPolyline(
          child: restarter, maxMetersToTheFirstPoint: 10);
      final f1 = navRestarter.mayRestart(infos, Optional.of(near));
      expect(_restarted, equals(0));
      await f1;
      expect(_restarted, equals(0));
    });
    test('should not restart because near segment founded', () async {
      _restarted = 0;
      final navRestarter = NavigationRestarterFirstPositionMayNotInPolyline(
          child: restarter, maxMetersToTheFirstPoint: 10);
      final f1 = navRestarter.mayRestart(infos, Optional.of(near));
      expect(_restarted, equals(0));
      await f1;
      expect(_restarted, equals(0));
    });
    test('should restart because no near segment', () async {
      _restarted = 0;
      final navRestarter = NavigationRestarterFirstPositionMayNotInPolyline(
          child: restarter, maxMetersToTheFirstPoint: 10);
      final f1 = navRestarter.mayRestart(infos, Optional.empty());
      await f1;
      expect(_restarted, equals(1));
    });
  });
}

_unitTestDefaultRestarter() {
  group('[NavigationRestarterDefault]', () {
    final infos = NavigationInfos(NavigationInfosConfig());

    test('should not restart because not ready', () async {
      _restarted = 0;
      final navRestarter =
          defaultNavigationRestarter(_callback, TransportType.Walk);
      final f1 = navRestarter.mayRestart(infos, Optional.empty());
      expect(_restarted, equals(0));
      await f1;
      expect(_restarted, equals(0));
    });
    test('should restart because far first', () async {
      _restarted = 0;
      infos.start(_Direction(polyline), TransportType.Car);
      infos.setCurrent(farPoint);
      final navRestarter =
          defaultNavigationRestarter(_callback, TransportType.Walk);
      final f1 = navRestarter.mayRestart(infos, Optional.of(near));
      expect(_restarted, equals(0));
      await f1;
      expect(_restarted, equals(1));
    });
    test('should not restart because near first', () async {
      _restarted = 0;
      infos.start(_Direction(polyline), TransportType.Car);
      infos.setCurrent(nearPoint);
      final navRestarter =
          defaultNavigationRestarter(_callback, TransportType.Walk);
      final f1 = navRestarter.mayRestart(infos, Optional.of(near));
      expect(_restarted, equals(0));
      await f1;
      expect(_restarted, equals(0));
    });
    test('should avoid flood', () async {
      _restarted = 0;
      infos.start(_Direction(polyline), TransportType.Car);
      infos.setCurrent(nearPoint);
      infos.setCurrentSegment(near);
      final navRestarter =
          defaultNavigationRestarter(_callback, TransportType.Walk);
      final f1 = navRestarter.mayRestart(infos, Optional.empty());
      final f2 = navRestarter.mayRestart(infos, Optional.empty());
      final f3 = navRestarter.mayRestart(infos, Optional.empty());
      expect(_restarted, equals(0));
      await f1;
      await f2;
      await f3;
      expect(_restarted, equals(1));
    });
    test('should cancel on state changes', () async {
      _restarted = 0;
      infos.start(_Direction(polyline), TransportType.Car);
      infos.setCurrent(nearPoint);
      infos.setCurrentSegment(near);
      final navRestarter =
          defaultNavigationRestarter(_callback, TransportType.Walk);
      final f1 = navRestarter.mayRestart(infos, Optional.empty());
      final f2 = navRestarter.mayRestart(infos, Optional.of(near));
      expect(_restarted, equals(0));
      await f1;
      await f2;
      expect(_restarted, equals(0));
    });
  });
}
