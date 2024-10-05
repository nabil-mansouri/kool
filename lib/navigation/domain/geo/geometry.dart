import 'dart:math';
import 'package:meta/meta.dart';
import 'package:optional/optional.dart';
import 'helper.dart' as helper;
import 'intersect.dart';

enum TransportType { Car, Bike, Walk }

class Point {
  final double latitude;
  final double longitude;
  Point(this.latitude, this.longitude);
  factory Point.fromName(
      {@required double latitude, @required double longitude}) {
    return Point(latitude, longitude);
  }
  factory Point.fromGeoJson(List<double> vals) {
    return Point(vals[1], vals[0]);
  }
  bool equals(Point other) {
    return other?.latitude == latitude && other?.longitude == longitude;
  }

  String toKey({int fractionDigits}) {
    if (fractionDigits != null) {
      return "${latitude.toStringAsFixed(fractionDigits)}|${longitude.toStringAsFixed(fractionDigits)}";
    }
    return "$latitude|$longitude";
  }

  num distanceInMeter(Point to) {
    final dLat = helper.toRadians((to.latitude - latitude));
    final dLon = helper.toRadians((to.longitude - longitude));
    final lat1 = helper.toRadians(latitude);
    final lat2 = helper.toRadians(to.latitude);
    final a =
        pow(sin(dLat / 2), 2) + pow(sin(dLon / 2), 2) * cos(lat1) * cos(lat2);
    return helper.radiansToMeters(2 * atan2(sqrt(a), sqrt(1 - a)));
  }

  Vector transformToVector(num distanceMetr, num bearingDegree) {
    return Vector(this, transform(distanceMetr, bearingDegree));
  }

  Point transform(num distanceMetr, num bearingDegree) {
    // Handle input
    final longitude1 = helper.toRadians(longitude);
    final latitude1 = helper.toRadians(latitude);
    final bearingRad = helper.toRadians(bearingDegree);
    final radians = helper.metersToRadians(distanceMetr);

    // Main
    final latitude2 = asin(sin(latitude1) * cos(radians) +
        cos(latitude1) * sin(radians) * cos(bearingRad));
    final longitude2 = longitude1 +
        atan2(sin(bearingRad) * sin(radians) * cos(latitude1),
            cos(radians) - sin(latitude1) * sin(latitude2));
    final lng = helper.toDegrees(longitude2);
    final lat = helper.toDegrees(latitude2);
    return Point(lat, lng);
  }

  Vector toVector(Point dest) {
    return Vector(this, dest);
  }

  double shortedDistanceToStartOrEnd(Vector vector) {
    final distStart = this.distanceInMeter(vector.start);
    final distEnd = this.distanceInMeter(vector.end);
    return min(distStart, distEnd);
  }

  Vector toVectorTime(Point dest, int seconds) {
    return VectorTime(this, dest, Duration(seconds: seconds));
  }

  static final Point infinity = Point(double.infinity, double.infinity);
  String get jsGoogleMap {
    return """var markerStart = new google.maps.Marker({
      position: new google.maps.LatLng($latitude, $longitude),
      map: map,
      icon: "http://1.bp.blogspot.com/_GZzKwf6g1o8/S6xwK6CSghI/AAAAAAAAA98/_iA3r4Ehclk/s1600/marker-green.png"
    });  """;
  }

  String toString() {
    return "($latitude,$longitude)";
  }
}

class Bounds {
  final Point northEast;
  final Point southWest;
  Point _center;
  static final Bounds infinity =
      Bounds(northEast: Point.infinity, southWest: Point.infinity);

  Bounds({@required this.northEast, @required this.southWest});
  factory Bounds.fromPoints(List<Point> points) {
    var minLon = double.infinity,
        minLat = double.infinity,
        maxLon = double.negativeInfinity,
        maxLat = double.negativeInfinity;
    points.forEach((point) {
      if (minLon > point.longitude) minLon = point.longitude;
      if (minLat > point.latitude) minLat = point.latitude;
      if (maxLon < point.longitude) maxLon = point.longitude;
      if (maxLat < point.latitude) maxLat = point.latitude;
    });
    if (minLon == double.infinity ||
        minLat == double.infinity ||
        maxLon == double.negativeInfinity ||
        maxLat == double.negativeInfinity) {
      return Bounds.infinity;
    }
    return Bounds(
        northEast: Point.fromName(latitude: maxLat, longitude: maxLon),
        southWest: Point.fromName(latitude: minLat, longitude: minLon));
  }
  factory Bounds.fromPolyline(PolyLine line) {
    return Bounds.fromPoints(line.points);
  }

  factory Bounds.getSquareAround(Point point,
      {@required double distanceToEastSide,
      @required double distanceToSouthSide}) {
    final northPoint =
        point.transform(distanceToSouthSide, 0); // Get north point
    final northEastPoint =
        northPoint.transform(distanceToEastSide, 90); // Get east point
    final southPt =
        point.transform(distanceToSouthSide, 180); // Get south point
    final southWestPoint =
        southPt.transform(distanceToEastSide, -90); // Get west point
    //southWest to northEast
    return Bounds(southWest: southWestPoint, northEast: northEastPoint);
  }
  factory Bounds.getRectAround(Point point,
      {@required double distanceToEastSide,
      @required double distanceToWestSide,
      @required double distanceToSouthSide,
      @required double distanceToNorthSide}) {
    final northPoint =
        point.transform(distanceToNorthSide, 0); // Get north point
    final northEastPoint =
        northPoint.transform(distanceToEastSide, 90); // Get east point
    final southPt =
        point.transform(distanceToSouthSide, 180); // Get south point
    final southWestPoint =
        southPt.transform(distanceToWestSide, -90); // Get west point
    //southWest to northEast
    return Bounds(southWest: southWestPoint, northEast: northEastPoint);
  }
  bool get isValidBounds {
    return this != Bounds.infinity;
  }

  bool isInBounds(Point point) {
    final eastBound = point.longitude <= northEast.longitude;
    final westBound = point.longitude >= southWest.longitude;
    var inLong;
    if (northEast.longitude < southWest.longitude) {
      inLong = eastBound || westBound;
    } else {
      inLong = eastBound && westBound;
    }
    final inLat = point.latitude >= southWest.latitude &&
        point.latitude <= northEast.latitude;
    return inLat && inLong;
  }

  Point get center {
    if (_center == null) {
      _center = Vector(southWest, northEast).midPoint();
    }
    return _center;
  }

  double get eastToWestMeters {
    if (!isValidBounds) return double.infinity;
    final southLatitude = southWest.latitude;
    final point1 = southWest;
    final point2 = Point(southLatitude, northEast.longitude);
    return point1.distanceInMeter(point2);
  }

  double get southToNorthMeters {
    if (!isValidBounds) return double.infinity;
    final westLongitude = southWest.longitude;
    final point1 = southWest;
    final point2 = Point(northEast.latitude, westLongitude);
    return point1.distanceInMeter(point2);
  }

  double get maxDistanceMeters => southWest.distanceInMeter(northEast);
  String get jsGoogleMap {
    return """var rectangle = new google.maps.Rectangle({
       strokeColor: '#FF0000',
       strokeOpacity: 0.8,
       strokeWeight: 2,
       fillColor: '#ffffff',
       fillOpacity: 0.35,
       map: map,
       bounds: new google.maps.LatLngBounds(
       new google.maps.LatLng(${southWest.latitude}, ${southWest.longitude}),
       new google.maps.LatLng(${northEast.latitude},${northEast.longitude})
       )
     });
   }""";
  }

  String toString() {
    return "[${southWest.toString()}->${northEast.toString()}]";
  }
}

class Vector {
  final Point start;
  final Point end;
  double _distance;
  double _bearing;
  Vector(this.start, this.end, {double distance, double bearing})
      : _distance = distance,
        _bearing = bearing;
  static final Vector infinity =
      Vector(Point.infinity, Point.infinity, distance: double.infinity);
  String toKey({int fractionDigits}) {
    return "${start?.toKey(fractionDigits: fractionDigits)}->${end?.toKey(fractionDigits: fractionDigits)}";
  }

  VectorTime toVectorTime(int seconds) {
    return VectorTime(start, end, Duration(seconds: seconds));
  }

  num get distanceInMeter {
    if (_distance == null) {
      _distance = start.distanceInMeter(end);
    }
    return _distance;
  }

  num get bearingDegree {
    if (_bearing == null) {
      _bearing = helper.bearingInDegrees(start, end);
    }
    return _bearing;
  }

  Vector get reverseVector {
    return Vector(end, start);
  }

  Vector perpendicularVectorFromPoint(Point pt) {
    //start
    final startToPt = Vector(start, pt);
    //stop
    final stopToPt = Vector(end, pt);
    return perpendicularVector(startToPt, stopToPt);
  }

  Vector perpendicularVector(Vector startToPt, Vector stopToPt) {
    //pt
    final pt = startToPt.end;
    //
    final maxDistance =
        max(startToPt.distanceInMeter, stopToPt.distanceInMeter);
    final direction = this.bearingDegree;
    final perpendicularPt1 = pt.transform(maxDistance, direction + 90);
    final perpendicularPt2 = pt.transform(maxDistance, direction - 90);
    return Vector(perpendicularPt1, perpendicularPt2);
  }

  Optional<Point> intersection(Vector other) {
    final intersection = intersects(
        start1: this.start,
        end1: this.end,
        start2: other.start,
        end2: other.end);
    return Optional.ofNullable(intersection);
  }

  num computeAngleBetweenAsDegrees(Point to) {
    Vector other = Vector(start, to);
    final bearing1 = bearingDegree;
    final bearing2 = other.bearingDegree;
    return helper.relativeBearingDegrees(bearing1, bearing2);
  }

  Point midPoint() {
    return interpolate(0.5);
  }

  Point interpolate(double fraction) {
    final bearing = this.bearingDegree;
    final distance = this.distanceInMeter;
    return start.transform(fraction * distance, bearing);
  }

  Point pointAtMeter(int meters) {
    final bearing = this.bearingDegree;
    return start.transform(meters, bearing);
  }
}

class VectorTime extends Vector {
  final Duration duration;
  double _meterPerSeconds;
  VectorTime(Point start, Point end, this.duration,
      {double distance, double bearing})
      : super(start, end, distance: distance, bearing: bearing);
  double get meterPerSeconds {
    if (_meterPerSeconds == null) {
      final seconds = duration.inMilliseconds / 1000;
      _meterPerSeconds =
          seconds > 0 ? distanceInMeter / seconds : double.infinity;
    }
    return _meterPerSeconds;
  }

  bool get hasSpeed => meterPerSeconds != double.infinity;
}

class PolyLine {
  final List<Point> points;
  //cache
  List<Vector> _vectors;
  double _distance;
  PolyLine(this.points, [this._vectors]);
  _reset() {
    _vectors = null;
    _distance = null;
  }

  int get nbPoints => points.length;
  Point get firstPoint => points.first;
  Point get lastPoint => points.last;
  void addFirst(Point point) {
    this.points.insert(0, point);
    _reset();
  }

  PolyLine addLast(Point point) {
    this.points.add(point);
    _reset();
    return this;
  }

  List<Vector> get vectors {
    if (_vectors == null) {
      _vectors = [];
      for (var i = 0; i < points.length - 1; i++) {
        _vectors.add(Vector(points[i], points[i + 1]));
      }
    }
    return _vectors;
  }

  int get countVectors {
    if (points.length <= 1) {
      return 0;
    }
    return _vectors != null ? _vectors.length : points.length - 1;
  }

  PolyLine subLine(int fromIndex, int toIndex) {
    assert(fromIndex <= toIndex, "fromIndex should be lesser than toIndex");
    if (0 <= fromIndex && fromIndex < points.length && 0 < toIndex) {
      toIndex = min(toIndex, points.length);
      return PolyLine(points.sublist(fromIndex, toIndex),
          vectors.sublist(fromIndex, toIndex - 1));
    } else {
      return PolyLine([]);
    }
  }

  double distanceMeterUntilPoint(int index, {bool inclusive = false}) {
    double distance = 0;
    int maxPoint = inclusive ? index : index - 1;
    int vectorIndex = maxPoint - 1;
    final c = this.vectors;
    for (int i = 0; i <= vectorIndex && i < c.length; i++) {
      distance += c[i].distanceInMeter;
    }
    return distance;
  }

  double get distanceInMeter {
    if (_distance == null) {
      if (vectors.length == 0) {
        _distance = 0;
      } else {
        _distance =
            vectors.map((v) => v.distanceInMeter).reduce((a1, a2) => a1 + a2);
      }
    }
    return _distance;
  }

  Optional<Point> getPointAtMeter(int distanceMeter, {double epsilon = 0.5}) {
    var travelled = 0;
    var i = 0;
    //case if no point
    if (nbPoints == 0) {
      return Optional.empty();
    }
    //case is first point (take care of negative less than epsilon)
    if (distanceMeter.abs() <= epsilon) {
      return Optional.ofNullable(firstPoint);
    }
    //case is first point (take care of negative less than epsilon)
    if ((distanceMeter - distanceInMeter).abs() <= epsilon) {
      return Optional.ofNullable(lastPoint);
    }
    //iterate
    for (; i < vectors.length && travelled < distanceMeter; i++) {
      final current = vectors[i];
      travelled += current.distanceInMeter.round();
    }
    //check if travelled is equal
    final absDiff = (travelled - distanceMeter).abs();
    final isEqual = absDiff < epsilon;
    if (isEqual && i > 0) {
      return Optional.ofNullable(vectors[i - 1].end);
    } else if (travelled > distanceMeter && i > 0) {
      final vector = vectors[i - 1];
      final meter = vector.distanceInMeter - absDiff;
      final point = vector.pointAtMeter(meter.round());
      return Optional.ofNullable(point);
    } else {
      return Optional.empty();
    }
  }

  bool isPointOnLine(Point point) {
    for (var vector in vectors) {
      final isOnSegment = isPointOnLineSegment(
          lineSegmentStart: vector.start,
          lineSegmentEnd: vector.end,
          excludeBoundary: ExcludeBoundary.None,
          pt: point);
      if (isOnSegment) return true;
    }
    return false;
  }

  String get jsGoogleMap {
    var pointsJS = points
        .map((f) => "{lat: ${f.latitude}, lng: ${f.longitude}}")
        .join(",");
    return """
      var pathCoords = [
          $pointsJS
        ];
      var path = new google.maps.Polyline({
          path: pathCoords,
          geodesic: true,
          strokeColor: '#FF0000',
          strokeOpacity: 1.0,
          strokeWeight: 2
        });
      path.setMap(map);
    """;
  }
}
