import 'dart:math';
import 'geometry.dart';

///bearing
num bearingInDegrees(Point from, Point to) {
  // Reverse calculation
  final lon1 = toRadians(from.longitude);
  final lon2 = toRadians(to.longitude);
  final lat1 = toRadians(from.latitude);
  final lat2 = toRadians(to.latitude);
  final a = sin(lon2 - lon1) * cos(lat2);
  final b = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(lon2 - lon1);
  return toDegrees(atan2(a, b));
}

num relativeBearingDegrees(num bearing1Deg, num bearing2Deg) {
  return toDegrees(
      relativeBearingRadians(toRadians(bearing1Deg), toRadians(bearing2Deg)));
}

num relativeBearingRadians(num bearing1Rad, num bearing2Rad) {
  num b1y = cos(bearing1Rad);
  num b1x = sin(bearing1Rad);
  num b2y = cos(bearing2Rad);
  num b2x = sin(bearing2Rad);
  num crossp = b1y * b2x - b2y * b1x;
  num dotp = b1x * b2x + b1y * b2y;
  if (crossp > 0) return acos(dotp);
  return -acos(dotp);
}

///
num degToRad(num deg) => deg * (pi / 180.0);
num toRadians(num deg) => degToRad(deg);
num radToDeg(num rad) => rad * (180.0 / pi);
num toDegrees(num rad) => radToDeg(rad);

/// Converts any bearing angle from the north line direction (positive clockwise)
/// and returns an angle between 0-360 degrees (positive clockwise), 0 being the north line
///
/// @name bearingToAzimuth
/// @param {number} bearing angle, between -180 and +180 degrees
/// @returns {number} angle between 0 and 360 degrees
num bearingToAzimuth(num bearing) {
  var angle = bearing % 360;
  if (angle < 0) {
    angle += 360;
  }
  return angle;
}

num aigueAngleAzimuth(num angleDegrees360) {
  return min(angleDegrees360, 360 - angleDegrees360);
}

///
const _earthRadius = 6371008.8;
const _meters = _earthRadius;
num radiansToMeters(num radians) {
  final factor = _meters;
  return radians * factor;
}

num metersToRadians(num distance) {
  final factor = _meters;
  return distance / factor;
}
