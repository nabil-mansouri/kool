import 'package:flutter_test/flutter_test.dart';
import '../geo.dart';

unitTestNearestSegment() {
  final leCreusot = Point(46.8, 4.4333);
  group('[NearestSegment]', () {
    test('should found nearest point to be start because it is before segment',
        () {
      final start = leCreusot.transform(10, 0);
      final vector = start.transformToVector(10, 0);
      final segment = NearestPointOnSegment.fromSegment(vector, 0, leCreusot);
      expect(segment.hasIntersect, isFalse);
      expect(segment.metersFromSegmentToPoint.round(), equals(10));
      expect(segment.startToClosest.distanceInMeter.round(), equals(0));
      expect(segment.closestToPoint.distanceInMeter.round(), equals(10));
      expect(segment.closestPoint, equals(start));
      expect(segment.type, equals(ClosestPointType.Start));
      expect(segment.startToIntersect, equals(Vector.infinity));
    });
    test(
        'should found nearest point to be start because it is before segment but not in same bearing',
        () {
      final start = leCreusot.transform(10, 20);
      final vector = start.transformToVector(10, 0);
      final segment = NearestPointOnSegment.fromSegment(vector, 0, leCreusot);
      expect(segment.hasIntersect, isFalse);
      expect(segment.metersFromSegmentToPoint.round(), equals(10));
      expect(segment.startToClosest.distanceInMeter.round(), equals(0));
      expect(segment.closestToPoint.distanceInMeter.round(), equals(10));
      expect(segment.closestPoint, equals(start));
      expect(segment.type, equals(ClosestPointType.Start));
      expect(segment.startToIntersect, equals(Vector.infinity));
    });
    test('should found nearest point to be start it is perpendicular to start',
        () {
      final start = leCreusot.transform(10, -90);
      final vector = start.transformToVector(10, 0);
      final segment = NearestPointOnSegment.fromSegment(vector, 0, leCreusot);
      expect(segment.hasIntersect, isFalse);
      expect(segment.metersFromSegmentToPoint.round(), equals(10));
      expect(segment.startToClosest.distanceInMeter.round(), equals(0));
      expect(segment.closestToPoint.distanceInMeter.round(), equals(10));
      expect(segment.closestPoint, equals(start));
      expect(segment.type, equals(ClosestPointType.Start));
      expect(segment.startToIntersect, equals(Vector.infinity));
    });
    test('should found nearest point to be in 1/4 of segment', () {
      final start = leCreusot.transform(-25, 0);
      final vector = start.transformToVector(100, 0);
      final segment = NearestPointOnSegment.fromSegment(vector, 0, leCreusot);
      expect(segment.hasIntersect, isTrue);
      expect(segment.metersFromSegmentToPoint.round(), equals(0));
      expect(segment.startToClosest.distanceInMeter.round(), equals(25));
      expect(segment.closestToPoint.distanceInMeter.round(), equals(0));
      expect(segment.type, equals(ClosestPointType.Intersect));
      expect(segment.startToIntersect.distanceInMeter.round(), equals(25));
    });
    test('should found nearest point to be in half of segment', () {
      final start = leCreusot.transform(-50, 0);
      final vector = start.transformToVector(100, 0);
      final segment = NearestPointOnSegment.fromSegment(vector, 0, leCreusot);
      expect(segment.hasIntersect, isTrue);
      expect(segment.metersFromSegmentToPoint.round(), equals(0));
      expect(segment.startToClosest.distanceInMeter.round(), equals(50));
      expect(segment.closestToPoint.distanceInMeter.round(), equals(0));
      expect(segment.type, equals(ClosestPointType.Intersect));
      expect(segment.startToIntersect.distanceInMeter.round(), equals(50));
    });
    test('should found nearest point to be in 3/4 of segment', () {
      final start = leCreusot.transform(-75, 0);
      final vector = start.transformToVector(100, 0);
      final segment = NearestPointOnSegment.fromSegment(vector, 0, leCreusot);
      expect(segment.hasIntersect, isTrue);
      expect(segment.metersFromSegmentToPoint.round(), equals(0));
      expect(segment.startToClosest.distanceInMeter.round(), equals(75));
      expect(segment.closestToPoint.distanceInMeter.round(), equals(0));
      expect(segment.type, equals(ClosestPointType.Intersect));
      expect(segment.startToIntersect.distanceInMeter.round(), equals(75));
    });
    // perpendicular to segment (1/4 , 1/2 et 3/4)
    test(
        'should found nearest point to be in segment because it is perpendicular to 1/4',
        () {
      final start = leCreusot;
      final middle = leCreusot.transform(25, 0);
      final point = middle.transform(50, -90);
      final vector = start.transformToVector(100, 0);
      final segment = NearestPointOnSegment.fromSegment(vector, 0, point);
      expect(segment.hasIntersect, isTrue);
      expect(segment.metersFromSegmentToPoint.round(), equals(50));
      expect(segment.startToClosest.distanceInMeter.round(), equals(25));
      expect(segment.startToPoint.distanceInMeter.round(), greaterThan(50));
      expect(segment.closestToPoint.distanceInMeter.round(), equals(50));
      expect(segment.closestPoint.toKey(fractionDigits: 6),
          equals(middle.toKey(fractionDigits: 6)));
      expect(segment.type, equals(ClosestPointType.Intersect));
      expect(segment.startToIntersect.distanceInMeter.round(), equals(25));
    });
    test(
        'should found nearest point to be in segment because it is perpendicular to half',
        () {
      final start = leCreusot;
      final middle = leCreusot.transform(50, 0);
      final point = middle.transform(50, -90);
      final vector = start.transformToVector(100, 0);
      final segment = NearestPointOnSegment.fromSegment(vector, 0, point);
      expect(segment.hasIntersect, isTrue);
      expect(segment.metersFromSegmentToPoint.round(), equals(50));
      expect(segment.startToClosest.distanceInMeter.round(), equals(50));
      expect(segment.startToPoint.distanceInMeter.round(), greaterThan(50));
      expect(segment.closestToPoint.distanceInMeter.round(), equals(50));
      expect(segment.closestPoint.toKey(fractionDigits: 6),
          equals(middle.toKey(fractionDigits: 6)));
      expect(segment.type, equals(ClosestPointType.Intersect));
      expect(segment.startToIntersect.distanceInMeter.round(), equals(50));
    });
    test(
        'should found nearest point to be in segment because it is perpendicular to 3/4',
        () {
      final start = leCreusot;
      final middle = leCreusot.transform(75, 0);
      final point = middle.transform(50, -90);
      final vector = start.transformToVector(100, 0);
      final segment = NearestPointOnSegment.fromSegment(vector, 0, point);
      expect(segment.hasIntersect, isTrue);
      expect(segment.metersFromSegmentToPoint.round(), equals(50));
      expect(segment.startToClosest.distanceInMeter.round(), equals(75));
      expect(segment.startToPoint.distanceInMeter.round(), greaterThan(50));
      expect(segment.closestToPoint.distanceInMeter.round(), equals(50));
      expect(segment.closestPoint.toKey(fractionDigits: 6),
          equals(middle.toKey(fractionDigits: 6)));
      expect(segment.type, equals(ClosestPointType.Intersect));
      expect(segment.startToIntersect.distanceInMeter.round(), equals(75));
    });
    test(
        'should found nearest point to be in segment because it is perpendicular with positive bearing',
        () {
      final start = leCreusot;
      final middle = leCreusot.transform(50, 0);
      final point = middle.transform(50, 90);
      final vector = start.transformToVector(100, 0);
      final segment = NearestPointOnSegment.fromSegment(vector, 0, point);
      expect(segment.hasIntersect, isTrue);
      expect(segment.metersFromSegmentToPoint.round(), equals(50));
      expect(segment.startToClosest.distanceInMeter.round(), equals(50));
      expect(segment.startToPoint.distanceInMeter.round(), greaterThan(50));
      expect(segment.closestToPoint.distanceInMeter.round(), equals(50));
      expect(segment.closestPoint.toKey(fractionDigits: 6),
          equals(middle.toKey(fractionDigits: 6)));
      expect(segment.type, equals(ClosestPointType.Intersect));
      expect(segment.startToIntersect.distanceInMeter.round(), equals(50));
    });
    //
    test('should found nearest point to be end it is perpendicular to end', () {
      final start = leCreusot;
      final vector = start.transformToVector(100, 0);
      final point = vector.end.transform(10, 90);
      final segment = NearestPointOnSegment.fromSegment(vector, 0, point);
      expect(segment.hasIntersect, isTrue);
      expect(segment.metersFromSegmentToPoint.round(), equals(10));
      expect(segment.startToClosest.distanceInMeter.round(), equals(100));
      expect(segment.closestToPoint.distanceInMeter.round(), equals(10));
      expect(segment.closestPoint, equals(vector.end));
      expect(segment.type, equals(ClosestPointType.End));
      expect(segment.startToIntersect.distanceInMeter.round(), equals(100));
    });
    test('should found nearest point to be end because it is after segment',
        () {
      final start = leCreusot;
      final vector = start.transformToVector(100, 0);
      final point = vector.end.transform(10, 0);
      final segment = NearestPointOnSegment.fromSegment(vector, 0, point);
      expect(segment.hasIntersect, isFalse);
      expect(segment.metersFromSegmentToPoint.round(), equals(10));
      expect(segment.startToClosest.distanceInMeter.round(), equals(100));
      expect(segment.closestToPoint.distanceInMeter.round(), equals(10));
      expect(segment.closestPoint, equals(vector.end));
      expect(segment.type, equals(ClosestPointType.End));
      expect(segment.startToIntersect, equals(Vector.infinity));
    });
    test(
        'should found nearest point to be end because it is after segment but not in same bearing',
        () {
      final start = leCreusot;
      final vector = start.transformToVector(100, 0);
      final point = vector.end.transform(10, 20);
      final segment = NearestPointOnSegment.fromSegment(vector, 0, point);
      expect(segment.hasIntersect, isFalse);
      expect(segment.metersFromSegmentToPoint.round(), equals(10));
      expect(segment.startToClosest.distanceInMeter.round(), equals(100));
      expect(segment.closestToPoint.distanceInMeter.round(), equals(10));
      expect(segment.closestPoint, equals(vector.end));
      expect(segment.type, equals(ClosestPointType.End));
      expect(segment.startToIntersect, equals(Vector.infinity));
    });
  });
}
