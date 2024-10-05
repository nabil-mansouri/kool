import 'dart:math';
import 'package:meta/meta.dart';
import 'package:optional/optional.dart';
import 'geometry.dart';

enum ClosestPointType { Start, Intersect, End }

class NearestPointOnSegment {
  final Vector endToPoint;
  final Vector startToPoint;
  final Vector startToEnd;
  final int segmentIndex;
  //cache
  Vector _startToIntersect;
  bool _computed = false;
  Vector _closestToPoint;
  ClosestPointType _type;
  NearestPointOnSegment(
      {@required this.startToPoint,
      @required this.startToEnd,
      @required this.segmentIndex,
      @required this.endToPoint});
  factory NearestPointOnSegment.fromSegment(
      Vector segment, int segmentIndex, Point pt) {
    final startToPt = Vector(segment.start, pt);
    final stopToPt = Vector(segment.end, pt);
    return NearestPointOnSegment(
        startToPoint: startToPt,
        startToEnd: segment,
        endToPoint: stopToPt,
        segmentIndex: segmentIndex);
  }
  //
  String toString(){
    return "NearestPointOnSegment[segmentIndex=$segmentIndex,hasIntersect=$hasIntersect,metersFromSegmentToPoint=$metersFromSegmentToPoint,type=$type,point=${startToPoint.end},startToEnd=$startToEnd]";
  }
  //lazy compute
  void _compute() {
    if (_computed) return;
    final perpendicularVector =
        startToEnd.perpendicularVector(startToPoint, endToPoint);
    final intersect = startToEnd.intersection(perpendicularVector);

    Optional<Vector> intersectToPoint =
        intersect.map((intersectPt) => Vector(intersectPt, startToPoint.end));
    _closestToPoint = Vector.infinity;
    if (startToPoint.distanceInMeter < _closestToPoint.distanceInMeter) {
      _closestToPoint = startToPoint;
      _type = ClosestPointType.Start;
    }
    if (endToPoint.distanceInMeter < _closestToPoint.distanceInMeter) {
      _closestToPoint = endToPoint;
      _type = ClosestPointType.End;
    }
    if (intersectToPoint.isPresent &&
        intersectToPoint.value.distanceInMeter <
            _closestToPoint.distanceInMeter) {
      _closestToPoint = intersectToPoint.value;
      _type = ClosestPointType.Intersect;
    }
    _startToIntersect = intersectToPoint
        .map((f) => Vector(startToPoint.start, f.start))
        .orElse(Vector.infinity);
    _computed = true;
  }

  bool get hasIntersect {
    _compute();
    return startToIntersect != Vector.infinity;
  }

  double get metersFromSegmentToPoint {
    _compute();
    return closestToPoint.distanceInMeter;
  }

  Vector get startToClosest {
    _compute();
    return Vector(startToPoint.start, closestPoint);
  }

  Vector get startToIntersect {
    _compute();
    return _startToIntersect;
  }

  ClosestPointType get type {
    _compute();
    return _type;
  }

  Vector get closestToPoint {
    _compute();
    return _closestToPoint;
  }

  Point get closestPoint {
    _compute();
    switch (type) {
      case ClosestPointType.Start:
        return startToEnd.start;
      case ClosestPointType.Intersect:
        return startToIntersect.end;
      case ClosestPointType.End:
        return startToEnd.end;
    }
    //should never happen
    throw "NearestSegment.closestPoint => Type is not known : $type";
  }
}

bool isPointNearToLine(PolyLine line, Point pt, {double epsilonMeters = 1}) {
  for (var vector in line.vectors) {
    final founded = NearestPointOnSegment.fromSegment(vector, 0, pt);
    if (founded.closestToPoint.distanceInMeter < epsilonMeters) {
      return true;
    }
  }
  return false;
}
