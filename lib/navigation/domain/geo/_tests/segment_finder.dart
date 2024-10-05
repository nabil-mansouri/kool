import 'package:flutter_test/flutter_test.dart';
import '../geo.dart';

unitTestSegmentFinder() {
  final leCreusot = Point(46.8, 4.4333);
  final point1 = leCreusot.transform(1, 0);
  final point2 = point1.transform(2, 20);
  final point3 = point2.transform(3, 40);
  final point4 = point3.transform(4, 60);
  final point5 = point4.transform(5, -80);
  final point6 = point5.transform(6, -100);
  final point7 = point6.transform(7, -120);
  final point8 = point7.transform(8, -120);
  final point9 = point8.transform(9, -140);
  final point10 = point9.transform(10, -160);
  final line = PolyLine([
    leCreusot,
    point1,
    point2,
    point3,
    point4,
    point5,
    point6,
    point7,
    point8,
    point9,
    point10
  ]);
  final finder = defaultSegmentFinder(line: line, type: TransportType.Car);
  group('[SegmentFinder]', () {
    test('should mandator should accept first', () {
      final mandator = SegmentMandatorAcceptFirst();
      final segment = leCreusot.transformToVector(10, 0);
      final near = NearestPointOnSegment.fromSegment(segment, 0, leCreusot);
      final shouldContinue = mandator.shouldContinue(near, approved: true);
      expect(shouldContinue, isFalse);
      final res = mandator.selectResult([near]);
      expect(res.isPresent, isTrue);
      expect(res.value.closestPoint.toKey(), equals(leCreusot.toKey()));
    });

    test('should mandator should not accept first', () {
      final mandator = SegmentMandatorAcceptFirst();
      final segment = leCreusot.transformToVector(10, 0);
      final near = NearestPointOnSegment.fromSegment(
          segment, 0, leCreusot.transform(-10, 0));
      final shouldContinue = mandator.shouldContinue(near, approved: false);
      expect(shouldContinue, isTrue);
      final res = mandator.selectResult([]);
      expect(res.isPresent, isFalse);
    });

    test('should find next segment (first in line)', () {
      final first = leCreusot.transform(0.5, 0);
      final founded =
          finder.next(VectorTime(leCreusot, first, Duration(seconds: 1)));
      expect(founded.isPresent, isTrue);
      expect(founded.value.segmentIndex, equals(0));
      expect(finder.hasGoneBack, isFalse);
      expect(finder.isInPlace, isFalse);
      expect(finder.hasGoneForward, isTrue);
      expect(finder.hasPrevSegment, isFalse);
      expect(finder.hasCurrentSegment, isTrue);
    });

    test('should find after next segment (2nd in line)', () {
      final first = point1.transform(1, 20);
      final founded =
          finder.next(VectorTime(point1, first, Duration(seconds: 1)));
      expect(founded.isPresent, isTrue);
      expect(founded.value.segmentIndex, equals(1));
      expect(finder.hasGoneBack, isFalse);
      expect(finder.isInPlace, isFalse);
      expect(finder.hasGoneForward, isTrue);
      expect(finder.hasPrevSegment, isTrue);
      expect(finder.hasCurrentSegment, isTrue);
    });

    test('should find prev segment', () {
      final first = point1.transform(-1, 0);
      final founded =
          finder.next(VectorTime(point1, first, Duration(seconds: 1)));
      expect(founded.isPresent, isTrue);
      expect(founded.value.segmentIndex, equals(0));
      expect(finder.hasGoneBack, isTrue);
      expect(finder.isInPlace, isFalse);
      expect(finder.hasGoneForward, isFalse);
      expect(finder.hasPrevSegment, isTrue);
      expect(finder.hasCurrentSegment, isTrue);
    });

    test('should find after next segment again (2nd in line)', () {
      final first = point1.transform(1, 20);
      final founded =
          finder.next(VectorTime(leCreusot, first, Duration(seconds: 1)));
      expect(founded.isPresent, isTrue);
      expect(founded.value.segmentIndex, equals(1));
      expect(finder.hasGoneBack, isFalse);
      expect(finder.isInPlace, isFalse);
      expect(finder.hasGoneForward, isTrue);
      expect(finder.hasPrevSegment, isTrue);
      expect(finder.hasCurrentSegment, isTrue);
    });

    test('should find same segment as previous', () {
      final first = point1.transform(1, 20);
      final founded =
          finder.next(VectorTime(first, first, Duration(seconds: 1)));
      expect(founded.isPresent, isTrue);
      expect(founded.value.segmentIndex, equals(1));
      expect(finder.hasGoneBack, isFalse);
      expect(finder.isInPlace, isTrue);
      expect(finder.hasGoneForward, isFalse);
      expect(finder.hasPrevSegment, isTrue);
      expect(finder.hasCurrentSegment, isTrue);
    });

    test('should not find segment', () {
      final first = point1.transform(10, 0);
      final founded =
          finder.next(VectorTime(first, first, Duration(seconds: 1)));
      expect(founded.isPresent, isFalse);
      expect(finder.hasGoneBack, isFalse);
      expect(finder.isInPlace, isFalse);
      expect(finder.hasGoneForward, isFalse);
      expect(finder.hasPrevSegment, isTrue);
      expect(finder.hasCurrentSegment, isFalse);
    });

    test('should find 6th segment', () {
      final first = point6.transform(1, -120);
      final founded =
          finder.next(VectorTime(point1, first, Duration(seconds: 1)));
      expect(founded.isPresent, isTrue);
      expect(founded.value.segmentIndex, equals(6));
      expect(finder.hasGoneForward, isTrue);
    });
    test('should find 8th segment', () {
      final first = point7.transform(1, -120);
      final founded =
          finder.next(VectorTime(point1, first, Duration(seconds: 1)));
      expect(founded.isPresent, isTrue);
      expect(founded.value.segmentIndex, equals(7));
      expect(finder.hasGoneForward, isTrue);
    });
    test('should find 8th segment', () {
      final first = point9.transform(1, -160);
      final founded =
          finder.next(VectorTime(point1, first, Duration(seconds: 1)));
      expect(founded.isPresent, isTrue);
      expect(founded.value.segmentIndex, equals(9));
      expect(finder.hasGoneForward, isTrue);
    });
    test('should find 6th segment again', () {
      final first = point6.transform(1, -120);
      final founded =
          finder.next(VectorTime(point1, first, Duration(seconds: 1)));
      expect(founded.isPresent, isTrue);
      expect(founded.value.segmentIndex, equals(6));
      expect(finder.hasGoneBack, isTrue);
    });
  });
}
