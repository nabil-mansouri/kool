import 'nearest_point.dart';
import 'geometry.dart';

abstract class SegmentApprover {
  void reset();
  void prepareNext(VectorTime movement);
  bool approve(NearestPointOnSegment vector);
}

class SegmentApproverDistance implements SegmentApprover {
  final double toleranceMeter;
  final bool inclusive;
  SegmentApproverDistance(this.toleranceMeter, {this.inclusive = false});
  void reset() {}
  void prepareNext(VectorTime movement) {}
  bool approve(NearestPointOnSegment near) {
    if (inclusive)
      return near.metersFromSegmentToPoint <= toleranceMeter;
    else
      return near.metersFromSegmentToPoint < toleranceMeter;
  }
}

//heuristic that eliminate triangle with very small angle (and greater than tolerance)
/* NOT SURE
class SegmentApproverTriangleAigue implements SegmentApprover {
  final double toleranceMeter;
  final double degreesTolerance;
  SegmentApproverTriangleAigue(this.toleranceMeter,
      [this.degreesTolerance = 15]);
  void begin(VectorTime movement) {}
  bool approve(NearestPointOnSegment near) {
    bool distToStartGreater =
        near.startToPoint.distanceInMeter > toleranceMeter;
    bool distToEndGreater = near.endToPoint.distanceInMeter > toleranceMeter;
    final angleDegrees =
        near.startToPoint.computeAngleBetweenAsDegrees(near.startToEnd.end);
    final angleDegres360 = bearingToAzimuth(angleDegrees);
    bool angleIsSmall = aigueAngleAzimuth(angleDegres360) <= degreesTolerance;
    bool eliminate = distToStartGreater && distToEndGreater && angleIsSmall;
    return !eliminate;
  }
}
*/
class SegmentApproverIntersect implements SegmentApprover {
  final double toleranceMeter;
  final bool inclusive;
  SegmentApproverIntersect(this.toleranceMeter, {this.inclusive = false});
  void reset() {}
  void prepareNext(VectorTime movement) {}
  bool approve(NearestPointOnSegment near) {
    if (near.hasIntersect) {
      return true;
    }
    if (inclusive) {
      return near.startToPoint.distanceInMeter <= toleranceMeter ||
          near.endToPoint.distanceInMeter <= toleranceMeter;
    } else {
      return near.startToPoint.distanceInMeter < toleranceMeter ||
          near.endToPoint.distanceInMeter < toleranceMeter;
    }
  }
}

class SegmentApproverAnd implements SegmentApprover {
  final List<SegmentApprover> approvers;
  SegmentApproverAnd(this.approvers);
  void reset() {}
  void prepareNext(VectorTime movement) {}
  bool approve(NearestPointOnSegment near) {
    for (SegmentApprover a in approvers) {
      if (!a.approve(near)) {
        return false;
      }
    }
    return true;
  }
}

SegmentApprover defaultSegmentApprover(
    {double toleranceMeter = 1, double toleranceToPoint = 0.5}) {
  return SegmentApproverAnd([
    //SegmentApproverTriangleAigue(toleranceMeter),
    //it should intersect or distance to start and end should be less than tolerance/2
    SegmentApproverIntersect(toleranceToPoint),
    SegmentApproverDistance(toleranceMeter)
  ]);
}
