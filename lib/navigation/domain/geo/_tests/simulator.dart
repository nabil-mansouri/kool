import 'package:flutter_test/flutter_test.dart';
import 'package:optional/optional.dart';
import '../geo.dart';

unitTestSimulator() {
  group('[Simulator]', () {
    group('[Speed]', () {
      test('should compute constant speed', () {
        final speed = SpeedProviderConstant(10.0);
        expect(speed.currentMeterSeconds(-1.0), equals(10.0));
        expect(speed.currentMeterSeconds(-.5), equals(10.0));
        expect(speed.currentMeterSeconds(-.0), equals(10.0));
        expect(speed.currentMeterSeconds(0), equals(10.0));
        expect(speed.currentMeterSeconds(.5), equals(10.0));
        expect(speed.currentMeterSeconds(1), equals(10.0));
        expect(speed.meanMeterPerSeconds(forMeters: 10),
            moreOrLessEquals(10.0, epsilon: 0.2));
      });
      test('should compute proportionnal speed', () {
        final speed = SpeedProviderProportionnal(10.0);
        expect(speed.currentMeterSeconds(-1.0), equals(-10.0));
        expect(speed.currentMeterSeconds(-.5), equals(-5.0));
        expect(speed.currentMeterSeconds(-.0), equals(.0));
        expect(speed.currentMeterSeconds(0), equals(.0));
        expect(speed.currentMeterSeconds(.25), equals(2.5));
        expect(speed.currentMeterSeconds(.5), equals(5.0));
        expect(speed.currentMeterSeconds(1), equals(10.0));
        expect(speed.meanMeterPerSeconds(forMeters: 10),
            moreOrLessEquals(5.0, epsilon: 0.2));
      });
      test('should compute ranged speed', () {
        final speed = SpeedProviderByRange(
            fractions: [0, 0.25, 0.5, 0.75, 1],
            meterSeconds: [0, 10, 20, 30, 0],
            proportionnal: false);
        expect(speed.currentMeterSeconds(-1.0), equals(.0));
        expect(speed.currentMeterSeconds(-.5), equals(.0));
        expect(speed.currentMeterSeconds(-.0), equals(.0));
        expect(speed.currentMeterSeconds(0), equals(.0));
        expect(speed.currentMeterSeconds(.1), equals(10));
        expect(speed.currentMeterSeconds(.25), equals(10));
        expect(speed.currentMeterSeconds(.3), equals(20));
        expect(speed.currentMeterSeconds(.5), equals(20));
        expect(speed.currentMeterSeconds(.6), equals(30));
        expect(speed.currentMeterSeconds(.75), equals(30));
        expect(speed.currentMeterSeconds(.8), equals(0));
        expect(speed.currentMeterSeconds(1), equals(0));
        expect(speed.currentMeterSeconds(1.1), equals(0));
        expect(speed.meanMeterPerSeconds(forMeters: 100),
            moreOrLessEquals(20, epsilon: 0.2));
      });
      test('should compute ranged speed proportionnal', () {
        final speed = SpeedProviderByRange(
            fractions: [0, 0.25, 0.5, 0.75, 1],
            meterSeconds: [0, 10, 20, 30, 0],
            proportionnal: true);
        expect(speed.currentMeterSeconds(-1.0), equals(.0));
        expect(speed.currentMeterSeconds(-.5), equals(.0));
        expect(speed.currentMeterSeconds(-.0), equals(.0));
        expect(speed.currentMeterSeconds(0), equals(.0));
        expect(speed.currentMeterSeconds(.12), moreOrLessEquals(5, epsilon: 1));
        expect(speed.currentMeterSeconds(.25), equals(10));
        expect(
            speed.currentMeterSeconds(.37), moreOrLessEquals(15, epsilon: 1));
        expect(speed.currentMeterSeconds(.5), equals(20));
        expect(
            speed.currentMeterSeconds(.62), moreOrLessEquals(25, epsilon: 1));
        expect(speed.currentMeterSeconds(.75), equals(30));
        expect(
            speed.currentMeterSeconds(.87), moreOrLessEquals(15, epsilon: 1));
        expect(speed.currentMeterSeconds(1), equals(0));
        expect(speed.currentMeterSeconds(1.1), equals(0));
        expect(speed.meanMeterPerSeconds(forMeters: 100),
            moreOrLessEquals(11, epsilon: 0.2));
      });
    });
    final leCreusot = Point(46.8, 4.4333);
    final point1 = leCreusot.transform(20, 0);
    final point2 = point1.transform(20, 0);
    final point3 = point2.transform(20, 0);
    final point4 = point3.transform(20, 0);
    final point5 = point4.transform(20, 0);
    final line = PolyLine([leCreusot, point1, point2, point3, point4, point5]);
    final speed = SpeedProviderProportionnal(100);
    final simulator = Simulator.fromSpeed(line, speed: speed, hertz: 10);
    final List<Optional<VectorTime>> vectors = [];
    test('should simulator be in initial state', () {
      expect(simulator.aborted, isFalse);
      expect(simulator.currentSpeed, equals(0));
      expect(simulator.finished, isFalse);
      expect(simulator.fraction, 0);
      expect(simulator.meanMeterPerSeconds, moreOrLessEquals(50, epsilon: 0.2));
      expect(simulator.millisecondsStep, equals(100));
      expect(simulator.running, isFalse);
      expect(simulator.spentMeters, equals(0));
      expect(simulator.spentSeconds, equals(0));
      expect(simulator.totalDistance.round(), equals(100));
    });

    test('should simulate run', () async {
      final future = simulator.start((data) {
        vectors.add(data);
      });
      expect(simulator.aborted, isFalse);
      expect(simulator.currentSpeed, equals(0));
      expect(simulator.finished, isFalse);
      expect(simulator.fraction, 0);
      expect(simulator.meanMeterPerSeconds, moreOrLessEquals(50, epsilon: 0.2));
      expect(simulator.millisecondsStep, equals(100));
      expect(simulator.running, isTrue);
      expect(simulator.spentMeters, equals(0));
      expect(simulator.spentSeconds, equals(0));
      expect(simulator.totalDistance.round(), equals(100));
      final success = await future;
      expect(success, isTrue);
      expect(simulator.aborted, isFalse);
      expect(simulator.currentSpeed, equals(0));
      expect(simulator.finished, isTrue);
      expect(simulator.fraction, moreOrLessEquals(1, epsilon: 0.06));
      expect(simulator.meanMeterPerSeconds, moreOrLessEquals(50, epsilon: 0.2));
      expect(simulator.millisecondsStep, equals(100));
      expect(simulator.running, isFalse);
      expect(simulator.spentMeters, equals(100));
      expect(simulator.spentSeconds, equals(2));
      expect(simulator.totalDistance.toDouble(),
          moreOrLessEquals(100, epsilon: 0.1));
      expect(vectors.length, equals(20));
    });

    test('should vectors be valid', () {
      final finder = defaultSegmentFinder(line: line, type: TransportType.Car);
      for (var v in vectors) {
        expect(v.isPresent, isTrue);
        final found = finder.next(v.value);
        expect(found.isPresent, isTrue);
        expect(found.value.metersFromSegmentToPoint,
            moreOrLessEquals(0, epsilon: 0.1));
      }
    });
    test('should restart and abort', () async {
      vectors.clear();
      final future = simulator.start((data) {
        vectors.add(data);
        if (simulator.fraction == 0.5) simulator.abort();
      });
      expect(simulator.aborted, isFalse);
      expect(simulator.currentSpeed, equals(0));
      expect(simulator.finished, isFalse);
      expect(simulator.fraction, 0);
      expect(simulator.meanMeterPerSeconds, moreOrLessEquals(50, epsilon: 0.2));
      expect(simulator.millisecondsStep, equals(100));
      expect(simulator.running, isTrue);
      expect(simulator.spentMeters, equals(0));
      expect(simulator.spentSeconds, equals(0));
      expect(simulator.totalDistance.round(), equals(100));
      final success = await future;
      expect(success, isFalse);
      expect(simulator.aborted, isTrue);
      expect(simulator.currentSpeed, equals(0));
      expect(simulator.finished, isFalse);
      expect(simulator.fraction, moreOrLessEquals(0.5, epsilon: 0.06));
      expect(simulator.meanMeterPerSeconds, moreOrLessEquals(50, epsilon: 0.2));
      expect(simulator.millisecondsStep, equals(100));
      expect(simulator.running, isFalse);
      expect(simulator.spentMeters.toDouble(), moreOrLessEquals(30.0, epsilon: 2));
      expect(simulator.spentSeconds, equals(1));
      expect(simulator.totalDistance.toDouble(),
          moreOrLessEquals(100, epsilon: 0.1));
      expect(vectors.length * 1.0, moreOrLessEquals(10, epsilon: 1));
    });
  });
}
