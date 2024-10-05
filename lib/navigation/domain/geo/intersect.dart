import 'package:meta/meta.dart';
import 'geometry.dart';

///
Point intersects(
    {@required Point start1,
    @required Point end1,
    @required Point start2,
    @required Point end2}) {
  final x1 = start1.longitude;
  final y1 = start1.latitude;
  final x2 = end1.longitude;
  final y2 = end1.latitude;
  //
  final x3 = start2.longitude;
  final y3 = start2.latitude;
  final x4 = end2.longitude;
  final y4 = end2.latitude;
  //
  final denom = ((y4 - y3) * (x2 - x1)) - ((x4 - x3) * (y2 - y1));
  final numeA = ((x4 - x3) * (y1 - y3)) - ((y4 - y3) * (x1 - x3));
  final numeB = ((x2 - x1) * (y1 - y3)) - ((y2 - y1) * (x1 - x3));

  if (denom == 0) {
    if (numeA == 0 && numeB == 0) {
      return null;
    }
    return null;
  }

  final uA = numeA / denom;
  final uB = numeB / denom;

  if (uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1) {
    final x = x1 + (uA * (x2 - x1));
    final y = y1 + (uA * (y2 - y1));
    return Point(y, x);
  }
  return null;
}

enum ExcludeBoundary { Start, End, Both, None }
/*
 * @private
 * @param {Position} lineSegmentStart coord pair of start of line
 * @param {Position} lineSegmentEnd coord pair of end of line
 * @param {Position} pt coord pair of point to check
 * @param ExcludeBoundary excludeBoundary whether the point is allowed to fall on the line ends.
 * If true which end to ignore.
 * @returns {boolean} true/false
 */
bool isPointOnLineSegment(
    {@required Point lineSegmentStart,
    @required Point lineSegmentEnd,
    @required Point pt,
    @required ExcludeBoundary excludeBoundary}) {
  final x = pt.longitude;
  final y = pt.latitude;
  final x1 = lineSegmentStart.longitude;
  final y1 = lineSegmentStart.latitude;
  final x2 = lineSegmentEnd.longitude;
  final y2 = lineSegmentEnd.latitude;
  final dxc = pt.longitude - x1;
  final dyc = pt.latitude - y1;
  final dxl = x2 - x1;
  final dyl = y2 - y1;
  final cross = dxc * dyl - dyc * dxl;
  if (cross != 0) {
    return false;
  }
  if (excludeBoundary == ExcludeBoundary.None) {
    if (dxl.abs() >= dyl.abs()) {
      return dxl > 0 ? x1 <= x && x <= x2 : x2 <= x && x <= x1;
    }
    return dyl > 0 ? y1 <= y && y <= y2 : y2 <= y && y <= y1;
  } else if (excludeBoundary == ExcludeBoundary.Start) {
    if (dxl.abs() >= dyl.abs()) {
      return dxl > 0 ? x1 < x && x <= x2 : x2 <= x && x < x1;
    }
    return dyl > 0 ? y1 < y && y <= y2 : y2 <= y && y < y1;
  } else if (excludeBoundary == ExcludeBoundary.End) {
    if (dxl.abs() >= dyl.abs()) {
      return dxl > 0 ? x1 <= x && x < x2 : x2 < x && x <= x1;
    }
    return dyl > 0 ? y1 <= y && y < y2 : y2 < y && y <= y1;
  } else if (excludeBoundary == ExcludeBoundary.Both) {
    if (dxl.abs() >= dyl.abs()) {
      return dxl > 0 ? x1 < x && x < x2 : x2 < x && x < x1;
    }
    return dyl > 0 ? y1 < y && y < y2 : y2 < y && y < y1;
  }
  return false;
}
