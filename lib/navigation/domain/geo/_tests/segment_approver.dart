import 'package:flutter_test/flutter_test.dart';
import '../geo.dart';

unitTestSegmentApprover() {
  group('[SegmentApprover]', () {
    final leCreusot = Point(46.8, 4.4333);

    test('should approve by distance if point is in segment', () {
      final point = leCreusot;
      final start = leCreusot.transform(-10, 0);
      final vector = start.transformToVector(20, 0);
      final near = NearestPointOnSegment.fromSegment(vector, 0, point);
      final approver = SegmentApproverDistance(1); //tolerance 1m
      expect(approver.approve(near), isTrue);
    });
    test('should approve by distance if point is equal 1m', () {
      final start = leCreusot;
      final vector = start.transformToVector(20, 0);
      //must set 0.99 because of round
      final point = start.transform(10, 0).transform(0.99, 90);
      final near = NearestPointOnSegment.fromSegment(vector, 0, point);
      final approver =
          SegmentApproverDistance(1, inclusive: true); //tolerance 1m
      expect(approver.approve(near), isTrue);
    });
    test('should approve by distance if point is less than 1m', () {
      final start = leCreusot;
      final vector = start.transformToVector(20, 0);
      //must set 0.99 because of round
      final point = start.transform(10, 0).transform(2, 20);
      final near = NearestPointOnSegment.fromSegment(vector, 0, point);
      final approver =
          SegmentApproverDistance(1, inclusive: false); //tolerance 1m
      expect(approver.approve(near), isTrue);
    });
    test('should not approve by distance if point is greater than 1m', () {
      final start = leCreusot;
      final vector = start.transformToVector(20, 0);
      //must set 0.99 because of round
      final point = start.transform(10, 0).transform(2, 90);
      final near = NearestPointOnSegment.fromSegment(vector, 0, point);
      final approver =
          SegmentApproverDistance(1, inclusive: false); //tolerance 1m
      expect(approver.approve(near), isFalse);
    });

    test('should approve by intersect if point is in segment', () {
      final point = leCreusot;
      final start = leCreusot.transform(-10, 0);
      final vector = start.transformToVector(20, 0);
      final near = NearestPointOnSegment.fromSegment(vector, 0, point);
      final approver = SegmentApproverIntersect(0);
      expect(approver.approve(near), isTrue);
    });
    test('should approve by intersect if point intersect', () {
      final start = leCreusot;
      final vector = start.transformToVector(20, 0);
      //must set 0.99 because of round
      final point = start.transform(10, 0).transform(0.99, 90);
      final near = NearestPointOnSegment.fromSegment(vector, 0, point);
      final approver = SegmentApproverIntersect(0);
      expect(approver.approve(near), isTrue);
    });
    test('should approve by intersect if point is start', () {
      final start = leCreusot;
      final vector = start.transformToVector(20, 0);
      //must set 0.99 because of round
      final near = NearestPointOnSegment.fromSegment(vector, 0, start);
      final approver = SegmentApproverIntersect(0.25);
      expect(approver.approve(near), isTrue);
    });
    test('should approve by intersect if point is end', () {
      final start = leCreusot;
      final vector = start.transformToVector(20, 0);
      //must set 0.99 because of round
      final near = NearestPointOnSegment.fromSegment(vector, 0, vector.end);
      final approver = SegmentApproverIntersect(0.25);
      expect(approver.approve(near), isTrue);
    });
    test('should not approve by intersect does not intersect', () {
      final start = leCreusot;
      final vector = start.transformToVector(20, 0);
      //must set 0.99 because of round
      final point = start.transform(-10, 0);
      final near = NearestPointOnSegment.fromSegment(vector, 0, point);
      final approver = SegmentApproverIntersect(0);
      expect(approver.approve(near), isFalse);
    });
    test('should approve and because both approved', () {
      final start = leCreusot;
      final vector = start.transformToVector(20, 0);
      //must set 0.99 because of round
      final point = start.transform(10, 0).transform(0.99, 90);
      final near = NearestPointOnSegment.fromSegment(vector, 0, point);
      final approver1 = SegmentApproverDistance(1);
      final approver2 = SegmentApproverDistance(1.5);
      final approver3 = SegmentApproverAnd([approver1, approver2]);
      expect(approver1.approve(near), isTrue);
      expect(approver2.approve(near), isTrue);
      expect(approver3.approve(near), isTrue);
    });
    test('should not approve and because one is not approved', () {
      final start = leCreusot;
      final vector = start.transformToVector(20, 0);
      //must set 0.99 because of round
      final point = start.transform(10, 0).transform(0.99, 90);
      final near = NearestPointOnSegment.fromSegment(vector, 0, point);
      final approver1 = SegmentApproverDistance(0.5);
      final approver2 = SegmentApproverDistance(1.5);
      final approver3 = SegmentApproverAnd([approver1, approver2]);
      expect(approver1.approve(near), isFalse);
      expect(approver2.approve(near), isTrue);
      expect(approver3.approve(near), isFalse);
    });
    test('should not approve and because both is not approved', () {
      final start = leCreusot;
      final vector = start.transformToVector(20, 0);
      //must set 0.99 because of round
      final point = start.transform(10, 0).transform(0.99, 90);
      final near = NearestPointOnSegment.fromSegment(vector, 0, point);
      final approver1 = SegmentApproverDistance(0.5);
      final approver2 = SegmentApproverDistance(0.5);
      final approver3 = SegmentApproverAnd([approver1, approver2]);
      expect(approver1.approve(near), isFalse);
      expect(approver2.approve(near), isFalse);
      expect(approver3.approve(near), isFalse);
    });
    test('should approve with default', () {
      final start = leCreusot;
      final vector = start.transformToVector(20, 0);
      //must set 0.99 because of round
      final point = start.transform(10, 0).transform(0.99, 90);
      final near = NearestPointOnSegment.fromSegment(vector, 0, point);
      final approver1 = defaultSegmentApprover();
      expect(approver1.approve(near), isTrue);
    });
    test('should not approve with default', () {
      final start = leCreusot;
      final vector = start.transformToVector(20, 0);
      //must set 0.99 because of round
      final point = start.transform(10, 0).transform(3, 90);
      final near = NearestPointOnSegment.fromSegment(vector, 0, point);
      final approver1 = defaultSegmentApprover();
      expect(approver1.approve(near), isFalse);
    });
  });
}
