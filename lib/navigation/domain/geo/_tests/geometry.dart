import 'package:flutter_test/flutter_test.dart';
import '../geo.dart';

unitTestGeometry() {
  group('[Geometry]', () {
    unitTestPoint();
    unitTestBounds();
    unitTestVector();
    unitTestPolyline();
  });
}

unitTestPoint() {
  group('[Point]', () {
    //https://github.com/Turfjs/turf/tree/master/packages/turf-distance/test
    //https://github.com/Turfjs/turf/tree/master/packages/turf-destination/test
    //https://github.com/manuelbieh/Geolib/blob/master/tests/geolib.test.js
    const DISTANCE_100KM = 100 * 1000;
    test('distance when longitude is 180/-180', () {
      expect(
          Point(-90, -180).distanceInMeter(Point(-90, 180)).round(), equals(0));
    });
    test('should compute correct distance', () {
      final origin = Point(39.984, -75.343);
      final dest = Point(39.123, -75.534);
      expect(origin.distanceInMeter(dest).toStringAsFixed(9),
          equals("97129.221189678"));
    });
    test('should distance and ignore direction', () {
      final origin = Point(39.984, -75.343);
      final dest = Point(39.123, -75.534);
      expect(
          origin.distanceInMeter(dest), equals(dest.distanceInMeter(origin)));
    });
    test('should transform a point by distance', () {
      final origin = Point(38.10096062273525, -75);
      final dest = Point(39.000281, -75);
      expect(origin.transform(DISTANCE_100KM, 0).toKey(fractionDigits: 6),
          equals(dest.toKey(fractionDigits: 6)));
    });
    test("should compute distance for random points", () {
      var distance4 =
          Point.fromName(latitude: 41.72977, longitude: -111.77621999999997)
              .distanceInMeter(Point.fromName(
                  latitude: 41.73198, longitude: -111.77636999999999));
      var distance5 =
          Point.fromName(latitude: 41.72977, longitude: -111.77621999999997)
              .distanceInMeter(Point.fromName(
                  latitude: 41.73198, longitude: -111.77636999999999));
      expect(distance4.round(), equals(246),
          reason: "Distance 4 should be 246");
      expect(distance5.round(), equals(246),
          reason: "Distance 5 should be 245.777");
    });
    test('should transform a point by bearing 45', () {
      final origin = Point.fromGeoJson([-75, 39.000281]);
      final dest = Point.fromGeoJson([-74.17429397158796, 39.63329968551747]);
      expect(origin.transform(DISTANCE_100KM, 45).toKey(fractionDigits: 12),
          equals(dest.toKey(fractionDigits: 12)));
    });
    test('should transform a point by bearing 90', () {
      final origin = Point.fromGeoJson([-75, 39]);
      final dest = Point.fromGeoJson([-73.842853, 38.994285]);
      expect(origin.transform(DISTANCE_100KM, 90).toKey(fractionDigits: 6),
          equals(dest.toKey(fractionDigits: 6)));
    });
    test('should transform a point by bearing 180', () {
      final origin = Point.fromGeoJson([-75, 39]);
      final dest = Point.fromGeoJson([-75, 38.10068]);
      expect(origin.transform(DISTANCE_100KM, 180).toKey(fractionDigits: 6),
          equals(dest.toKey(fractionDigits: 6)));
    });
    test('should transform a point by bearing 360', () {
      final origin = Point(38.10096062273525, -75);
      final dest = Point(39.000281, -75);
      expect(origin.transform(DISTANCE_100KM, 360).toKey(fractionDigits: 6),
          equals(dest.toKey(fractionDigits: 6)));
    });
    test('should transform a point by bearing -45', () {
      final origin = Point.fromGeoJson([-75, 39.000281]);
      final dest = Point.fromGeoJson([-75.82570602841206, 39.63329968551747]);
      expect(origin.transform(DISTANCE_100KM, -45).toKey(fractionDigits: 12),
          equals(dest.toKey(fractionDigits: 12)));
    });
    test('should transform a point by bearing -90', () {
      final origin = Point.fromGeoJson([-75, 39.000281]);
      final dest = Point.fromGeoJson([-76.15715136644023, 38.99456590655146]);
      expect(origin.transform(DISTANCE_100KM, -90).toKey(fractionDigits: 12),
          equals(dest.toKey(fractionDigits: 12)));
    });
    test('should transform a point by bearing -180', () {
      final origin = Point(39, -75);
      expect(origin.transform(DISTANCE_100KM, 180).toKey(),
          equals(origin.transform(DISTANCE_100KM, -180).toKey()));
    });
    test('should transform a point by bearing -360', () {
      final origin = Point(39, -75);
      expect(origin.transform(DISTANCE_100KM, 360).toKey(),
          equals(origin.transform(DISTANCE_100KM, -360).toKey()));
      expect(origin.transform(DISTANCE_100KM, 360).toKey(),
          equals(origin.transform(DISTANCE_100KM, 0).toKey()));
    });
    test('should transform a point by distance and bearing far away', () {
      final origin = Point(39, -75);
      final dest = Point(26.440011, -22.885356);
      expect(origin.transform(5000 * 1000, 90).toKey(fractionDigits: 6),
          equals(dest.toKey(fractionDigits: 6)));
    });
    test("should compute destination for random points", () {
      //geolib has not same comuting formula
      var berlin = Point(52.518611, 13.408056);
      var point1 = berlin.transform(15000, 180);
      var point2 = berlin.transform(15000, 135);
      expect(
          point1.toKey(fractionDigits: 3),
          equals(Point(52.383863707382076, 13.408055999999977)
              .toKey(fractionDigits: 3)));
      expect(
          point2.toKey(fractionDigits: 3),
          equals(Point(52.42322722672352, 13.564299057246114)
              .toKey(fractionDigits: 3)));
    });
  });
}

unitTestBounds() {
  group('[Bounds]', () {
    final leCreusot = Point(46.8, 4.4333);
    test('should build square bounds around 0 / 0', () {
      final point = Point(0, 0);
      final bounds = Bounds.getSquareAround(point,
          distanceToEastSide: 10, distanceToSouthSide: 10);
      expect(bounds.isInBounds(point), isTrue);
      expect(bounds.isInBounds(point.transform(11, 0)), isFalse);
      expect(bounds.isInBounds(point.transform(11, 180)), isFalse);
      expect(bounds.isInBounds(point.transform(11, -90)), isFalse);
      expect(bounds.isInBounds(point.transform(11, 90)), isFalse);
      //
      expect(bounds.isInBounds(point.transform(9, 0)), isTrue);
      expect(bounds.isInBounds(point.transform(9, 180)), isTrue);
      expect(bounds.isInBounds(point.transform(9, -90)), isTrue);
      expect(bounds.isInBounds(point.transform(9, 90)), isTrue);
      //
      final center = bounds.center;
      expect(center.distanceInMeter(point), lessThan(0.1));
    });
    //does not work at 90 (pole nord)
    test('should build square bounds around 88 / 180', () {
      final point = Point(88, 180);
      final bounds = Bounds.getSquareAround(point,
          distanceToEastSide: 10, distanceToSouthSide: 10);
      expect(bounds.isInBounds(point), isTrue);
      expect(bounds.isInBounds(point.transform(11, 0)), isFalse);
      expect(bounds.isInBounds(point.transform(11, 180)), isFalse);
      expect(bounds.isInBounds(point.transform(11, -90)), isFalse);
      expect(bounds.isInBounds(point.transform(11, 90)), isFalse);
      //
      expect(bounds.isInBounds(point.transform(9, 0)), isTrue);
      expect(bounds.isInBounds(point.transform(9, 180)), isTrue);
      expect(bounds.isInBounds(point.transform(9, -90)), isTrue);
      expect(bounds.isInBounds(point.transform(9, 90)), isTrue);
      //
      final center = bounds.center;
      expect(center.distanceInMeter(point), lessThan(0.1));
    });
    //does not work at -90 (pole sud)
    test('should build square bounds around -88 / 180', () {
      final point = Point(-88, 180);
      final bounds = Bounds.getSquareAround(point,
          distanceToEastSide: 10, distanceToSouthSide: 10);
      expect(bounds.isInBounds(point), isTrue);
      expect(bounds.isInBounds(point.transform(11, 0)), isFalse);
      expect(bounds.isInBounds(point.transform(11, 180)), isFalse);
      expect(bounds.isInBounds(point.transform(11, -90)), isFalse);
      expect(bounds.isInBounds(point.transform(11, 90)), isFalse);
      //
      expect(bounds.isInBounds(point.transform(9, 0)), isTrue);
      expect(bounds.isInBounds(point.transform(9, 180)), isTrue);
      expect(bounds.isInBounds(point.transform(9, -90)), isTrue);
      expect(bounds.isInBounds(point.transform(9, 90)), isTrue);
      //
      final center = bounds.center;
      expect(center.distanceInMeter(point), lessThan(0.1));
    });
    test('should build square bounds around leCreusot', () {
      final bounds = Bounds.getSquareAround(leCreusot,
          distanceToEastSide: 10, distanceToSouthSide: 10);
      expect(bounds.isInBounds(leCreusot), isTrue);
      expect(bounds.isInBounds(leCreusot.transform(11, 0)), isFalse);
      expect(bounds.isInBounds(leCreusot.transform(11, 180)), isFalse);
      expect(bounds.isInBounds(leCreusot.transform(11, -90)), isFalse);
      expect(bounds.isInBounds(leCreusot.transform(11, 90)), isFalse);
      //
      expect(bounds.isInBounds(leCreusot.transform(9, 0)), isTrue);
      expect(bounds.isInBounds(leCreusot.transform(9, 180)), isTrue);
      expect(bounds.isInBounds(leCreusot.transform(9, -90)), isTrue);
      expect(bounds.isInBounds(leCreusot.transform(9, 90)), isTrue);
      //
      final center = bounds.center;
      expect(center.distanceInMeter(leCreusot), lessThan(0.1));
    });
    //
    test('should build rect bounds around 0 / 0', () {
      final point = Point(0, 0);
      final bounds = Bounds.getRectAround(point,
          distanceToEastSide: 8,
          distanceToSouthSide: 6,
          distanceToWestSide: 4,
          distanceToNorthSide: 2);
      expect(bounds.isInBounds(point), isTrue);
      //north
      expect(bounds.isInBounds(point.transform(1, 0)), isTrue);
      expect(bounds.isInBounds(point.transform(3, 0)), isFalse);
      //south
      expect(bounds.isInBounds(point.transform(5, 180)), isTrue);
      expect(bounds.isInBounds(point.transform(7, 180)), isFalse);
      //west
      expect(bounds.isInBounds(point.transform(3, -90)), isTrue);
      expect(bounds.isInBounds(point.transform(5, -90)), isFalse);
      //est
      expect(bounds.isInBounds(point.transform(7, 90)), isTrue);
      expect(bounds.isInBounds(point.transform(9, 90)), isFalse);
    });
    test('should build rect bounds around 88 / 180', () {
      final point = Point(88, 180);
      final bounds = Bounds.getRectAround(point,
          distanceToEastSide: 8,
          distanceToSouthSide: 6,
          distanceToWestSide: 4,
          distanceToNorthSide: 2);
      expect(bounds.isInBounds(point), isTrue);
      //north
      expect(bounds.isInBounds(point.transform(1, 0)), isTrue);
      expect(bounds.isInBounds(point.transform(3, 0)), isFalse);
      //south
      expect(bounds.isInBounds(point.transform(5, 180)), isTrue);
      expect(bounds.isInBounds(point.transform(7, 180)), isFalse);
      //west
      expect(bounds.isInBounds(point.transform(3, -90)), isTrue);
      expect(bounds.isInBounds(point.transform(5, -90)), isFalse);
      //est
      expect(bounds.isInBounds(point.transform(7, 90)), isTrue);
      expect(bounds.isInBounds(point.transform(9, 90)), isFalse);
    });
    test('should build rect bounds around leCreusot', () {
      final bounds = Bounds.getRectAround(leCreusot,
          distanceToEastSide: 8,
          distanceToSouthSide: 6,
          distanceToWestSide: 4,
          distanceToNorthSide: 2);
      expect(bounds.isInBounds(leCreusot), isTrue);
      //north
      expect(bounds.isInBounds(leCreusot.transform(1, 0)), isTrue);
      expect(bounds.isInBounds(leCreusot.transform(3, 0)), isFalse);
      //south
      expect(bounds.isInBounds(leCreusot.transform(5, 180)), isTrue);
      expect(bounds.isInBounds(leCreusot.transform(7, 180)), isFalse);
      //west
      expect(bounds.isInBounds(leCreusot.transform(3, -90)), isTrue);
      expect(bounds.isInBounds(leCreusot.transform(5, -90)), isFalse);
      //est
      expect(bounds.isInBounds(leCreusot.transform(7, 90)), isTrue);
      expect(bounds.isInBounds(leCreusot.transform(9, 90)), isFalse);
    });
    test('should create bounds from list of points', () {
      final point1 = leCreusot;
      final point2 = point1.transform(1, 0);
      final point3 = point2.transform(1, 90);
      final point4 = point3.transform(1, 90);
      final bounds = Bounds.fromPoints([point1, point2, point3, point4]);
      final notInBounds1 = point1.transform(-1, 0);
      final notInBounds2 = point2.transform(-1, 90);
      final notInBounds3 = point3.transform(3, 90);
      final notInBounds4 = Point(0, 180);
      expect(bounds.isInBounds(point1), isTrue);
      expect(bounds.isInBounds(point2), isTrue);
      expect(bounds.isInBounds(point3), isTrue);
      expect(bounds.isInBounds(point4), isTrue);
      expect(bounds.isInBounds(notInBounds1), isFalse);
      expect(bounds.isInBounds(notInBounds2), isFalse);
      expect(bounds.isInBounds(notInBounds3), isFalse);
      expect(bounds.isInBounds(notInBounds4), isFalse);
      expect(bounds.isValidBounds, isTrue);
    });
    test('should create bounds from one point', () {
      final point1 = leCreusot;
      final bounds = Bounds.fromPoints([point1]);
      final notInBounds1 = point1.transform(-1, 0);
      final notInBounds4 = Point(0, 180);
      expect(bounds.isInBounds(point1), isTrue);
      expect(bounds.isInBounds(notInBounds1), isFalse);
      expect(bounds.isInBounds(notInBounds4), isFalse);
      expect(bounds.isValidBounds, isTrue);
    });
    test('should create bounds from 0 point', () {
      final bounds = Bounds.fromPoints([]);
      expect(bounds.isValidBounds, isFalse);
    });
    test('should compute north/south distance', () {
      final point1 = leCreusot;
      final point2 = point1.transform(10, 0);
      final bounds = Bounds.fromPoints([point1, point2]);
      expect(bounds.southToNorthMeters.round(), equals(10));
      expect(bounds.eastToWestMeters.round(), equals(0));
    });
    test('should compute east/west distance', () {
      final point1 = leCreusot;
      final point2 = point1.transform(10, 90);
      final bounds = Bounds.fromPoints([point1, point2]);
      expect(bounds.southToNorthMeters.round(), equals(0));
      expect(bounds.eastToWestMeters.round(), equals(10));
    });
    test('should compute east/west distance for bounds 1 point', () {
      final bounds = Bounds.fromPoints([leCreusot]);
      expect(bounds.southToNorthMeters.round(), equals(0));
      expect(bounds.eastToWestMeters.round(), equals(0));
    });
    test('should compute east/west distance for infinity bounds', () {
      final bounds = Bounds.fromPoints([]);
      expect(bounds.southToNorthMeters, equals(double.infinity));
      expect(bounds.eastToWestMeters, equals(double.infinity));
    });
  });
}

unitTestVector() {
  group('[Vector]', () {
    test('distance when longitude is 180/-180', () {
      expect(Vector(Point(-90, -180), Point(-90, 180)).distanceInMeter.round(),
          equals(0));
    });
    test('should compute correct distance in meters', () {
      final origin = Point(39.984, -75.343);
      final dest = Point(39.123, -75.534);
      expect(Vector(origin, dest).distanceInMeter.round(), equals(97129));
    });
    test('should distance and ignore direction', () {
      final origin = Point(39.984, -75.343);
      final dest = Point(39.123, -75.534);
      final vector = Vector(origin, dest);
      expect(
          vector.distanceInMeter, equals(vector.reverseVector.distanceInMeter));
    });
    test('should compute bearing for random points', () {
      final start = Point.fromGeoJson([-75, 45]);
      final end = Point.fromGeoJson([20, 60]);
      final vector = Vector(start, end);
      expect(vector.bearingDegree.toStringAsFixed(2), equals("37.75"));
    });
    test('should compute bearing 0', () {
      final start = Point.fromGeoJson([-75.343, 39.984]);
      final end = Point.fromGeoJson([-75.343, 40.70765791571896]);
      final vector = Vector(start, end);
      expect(vector.bearingDegree, equals(0));
    });
    test('should compute bearing 45', () {
      final start = Point.fromGeoJson([-75.343, 39.984]);
      final end = Point.fromGeoJson([-74.67013043393854, 40.493765848461955]);
      final vector = Vector(start, end);
      expect(vector.bearingDegree.round(), equals(45));
    });
    test('should compute bearing 90', () {
      final start = Point.fromGeoJson([-75.343, 39.984]);
      final end = Point.fromGeoJson([-74.39858826442095, 39.98016766669771]);
      final vector = Vector(start, end);
      expect(vector.bearingDegree.round(), equals(90));
    });
    test('should compute bearing 180', () {
      final start = Point.fromGeoJson([-75.343, 39.984]);
      final end = Point.fromGeoJson([-75.343, 39.26034208428105]);
      final vector = Vector(start, end);
      expect(vector.bearingDegree, equals(180));
    });
    test('should compute bearing -45', () {
      final start = Point.fromGeoJson([-75.343, 39.984]);
      final end = Point.fromGeoJson([-76.01586956606147, 40.493765848461955]);
      final vector = Vector(start, end);
      expect(vector.bearingDegree.round(), equals(-45));
    });
    test('should compute perpendicular vector for bearing 0', () {
      final origin = Point.fromGeoJson([-75, 39]);
      final vector = origin.transformToVector(100, 0);
      final otherPoint = origin.transform(100, 90);
      final result = vector.perpendicularVectorFromPoint(otherPoint);
      expect(result.bearingDegree.round(), equals(-90));
    });
    test('should compute perpendicular vector for bearing 20', () {
      final origin = Point.fromGeoJson([-75, 39]);
      final vector = origin.transformToVector(100, 20);
      final otherPoint = origin.transform(100, 90);
      final result = vector.perpendicularVectorFromPoint(otherPoint);
      expect(result.bearingDegree.round(), equals(-70));
    });
    test('should found intersection point at origin', () {
      //intersection should be origin |_
      final origin = Point.fromGeoJson([-75, 39]);
      final vector = origin.transformToVector(100, 0);
      //because of spherique aspect, 90 degres does not intersect
      final otherPoint = origin.transform(10, 89.9);
      final perpendicular = vector.perpendicularVectorFromPoint(otherPoint);
      final result = vector.intersection(perpendicular);
      expect(result.isPresent, isTrue);
      expect(result.value.distanceInMeter(origin), lessThan(0.1));
    });
    test('should found intersection point at middle', () {
      //intersection should be dest |-
      final origin = Point.fromGeoJson([-75, 39]);
      final vector = origin.transformToVector(100, 50);
      final middle = origin.transform(50, 50);
      final otherPoint = middle.transform(0, 50 + 90);
      final perpendicular = vector.perpendicularVectorFromPoint(otherPoint);
      final result = vector.intersection(perpendicular);
      expect(result.isPresent, isTrue);
      expect(result.value.distanceInMeter(middle), lessThan(0.1));
    });
    test('should found intersection point at end', () {
      //intersection should be dest |-
      final origin = Point.fromGeoJson([-75, 39]);
      final vector = origin.transformToVector(100, 0);
      final otherPoint = vector.end.transform(10, 90);
      final perpendicular = vector.perpendicularVectorFromPoint(otherPoint);
      final result = vector.intersection(perpendicular);
      expect(result.isPresent, isTrue);
      expect(result.value.distanceInMeter(vector.end), lessThan(0.1));
    });
    test('should found intersection point if other is origin', () {
      //intersection should be dest |-
      final origin = Point.fromGeoJson([-75, 39]);
      final vector = origin.transformToVector(100, 0);
      //because earth is spherical=>it does see intersection at origin+0.05meters
      final perpendicular =
          vector.perpendicularVectorFromPoint(origin.transform(0.05, 0));
      final result = vector.intersection(perpendicular);
      expect(result.isPresent, isTrue);
      expect(result.value.distanceInMeter(origin), lessThan(0.05));
    });
    test('should found intersection point if other is middle', () {
      //intersection should be dest |-
      final origin = Point.fromGeoJson([-75, 39]);
      final vector = origin.transformToVector(100, 0);
      final middle = origin.transform(50, 0);
      final perpendicular = vector.perpendicularVectorFromPoint(middle);
      final result = vector.intersection(perpendicular);
      expect(result.isPresent, isTrue);
      expect(result.value.distanceInMeter(middle), lessThan(0.05));
    });
    test('should found intersection point if other is end', () {
      //intersection should be dest |-
      final origin = Point.fromGeoJson([-75, 39]);
      final vector = origin.transformToVector(100, 0);
      final perpendicular = vector.perpendicularVectorFromPoint(vector.end);
      final result = vector.intersection(perpendicular);
      expect(result.isPresent, isTrue);
      expect(result.value.distanceInMeter(vector.end), lessThan(0.05));
    });
    test('should not found intersection point because it is before', () {
      //intersection should not be founded - -
      final origin = Point.fromGeoJson([-75, 39]);
      final vector = origin.transformToVector(100, 0);
      final perpendicular =
          vector.perpendicularVectorFromPoint(vector.start.transform(-1, 0));
      final result = vector.intersection(perpendicular);
      expect(result.isPresent, isFalse);
    });
    test('should not found intersection point because it is after', () {
      //intersection should not be founded - -
      final origin = Point.fromGeoJson([-75, 39]);
      final vector = origin.transformToVector(100, 0);
      final perpendicular =
          vector.perpendicularVectorFromPoint(vector.end.transform(1, 0));
      final result = vector.intersection(perpendicular);
      expect(result.isPresent, isFalse);
    });
    test('should not found intersect for parallel vectors', () {
      // parallele vectors ||
      final origin = Point.fromGeoJson([-75, 39]);
      final vector1 = origin.transformToVector(100, 0);
      final vector2 = origin.transform(10, 90).transformToVector(100, 0);
      final res = vector1.intersection(vector2);
      expect(res.isPresent, isFalse);
    });
    test('should not found intersect for non parallel vectors', () {
      // parallele vectors /\
      final origin = Point.fromGeoJson([-75, 39]);
      final vector1 = origin.transformToVector(100, 0);
      final vector2 = origin.transformToVector(100, 10);
      final res = vector1.intersection(vector2);
      expect(res.isPresent, isTrue);
    });
    test('should compute angle between point and vector', () {
      final origin = Point.fromGeoJson([-75, 39]);
      final vector = origin.transformToVector(100, 30);
      final point = origin.transform(100, 40);
      final res = vector.computeAngleBetweenAsDegrees(point);
      expect(res.round(), equals(10));
    });
    test('should compute negative angle between point and vector', () {
      final origin = Point.fromGeoJson([-75, 39]);
      final vector = origin.transformToVector(100, 30);
      final point = origin.transform(100, 20);
      final res = vector.computeAngleBetweenAsDegrees(point);
      expect(res.round(), equals(-10));
    });
    test('should compute 90 angle between point and vector', () {
      final origin = Point.fromGeoJson([-75, 39]);
      final vector = origin.transformToVector(100, 30);
      final point = origin.transform(100, 30 + 90);
      final res = vector.computeAngleBetweenAsDegrees(point);
      expect(res.round(), equals(90));
    });
    test('should compute 180 angle between point and vector', () {
      final origin = Point.fromGeoJson([-75, 39]);
      final vector = origin.transformToVector(100, 30);
      final point = origin.transform(100, 30 + 180);
      final res = vector.computeAngleBetweenAsDegrees(point);
      expect(res.round().abs(), equals(180));
    });
    test('should compute 360 angle between point and vector', () {
      final origin = Point.fromGeoJson([-75, 39]);
      final vector = origin.transformToVector(100, 30);
      final point = origin.transform(100, 30 + 360);
      final res = vector.computeAngleBetweenAsDegrees(point);
      expect(res.round(), equals(0));
    });
    test('should parallel vector not intersect', () {
      final origin = Point.fromGeoJson([-75, 39]);
      final vector = origin.transformToVector(100, 0);
      final point = origin.transform(10, 90);
      final vector2 = point.transformToVector(100, 0);
      expect(vector.intersection(vector2).isPresent, isFalse);
    });
    test('should compute speed for vector time', () {
      final origin = Point.fromGeoJson([-75, 39]);
      final vector = origin.transformToVector(100, 30);
      final vTime = VectorTime(vector.start, vector.end, Duration(seconds: 10));
      expect(vTime.meterPerSeconds.round(), equals(10));
    });
    test('should compute speed for vector of 0meter', () {
      final origin = Point.fromGeoJson([-75, 39]);
      final vector = origin.transformToVector(0, 0);
      final vTime = VectorTime(vector.start, vector.end, Duration(seconds: 10));
      expect(vTime.meterPerSeconds, equals(0));
    });
    test('should compute speed for vector of 0sec', () {
      final origin = Point.fromGeoJson([-75, 39]);
      final vector = origin.transformToVector(100, 30);
      final vTime = VectorTime(vector.start, vector.end, Duration(seconds: 0));
      expect(vTime.meterPerSeconds, equals(double.infinity));
    });
  });
}

unitTestPolyline() {
  group('[Polyline]', () {
    test('should not compute vectors when empty', () {
      PolyLine line = PolyLine([]);
      expect(line.countVectors, equals(0));
      expect(line.nbPoints, equals(0));
      expect(line.distanceInMeter, equals(0));
      expect(line.vectors.length, equals(0));
      expect(line.distanceMeterUntilPoint(1), equals(0));
      expect(line.subLine(0, 4).countVectors, equals(0));
    });
    test('should not compute vectors when 1', () {
      PolyLine line = PolyLine([
        Point.fromGeoJson([-75, 39])
      ]);
      expect(line.countVectors, equals(0));
      expect(line.nbPoints, equals(1));
      expect(line.distanceInMeter, equals(0));
      expect(line.vectors.length, equals(0));
      expect(line.distanceMeterUntilPoint(1), equals(0));
      expect(line.subLine(0, 4).countVectors, equals(0));
    });
    test('should compute vectors when 2', () {
      final point1 = Point.fromGeoJson([-75, 39]);
      final point2 = point1.transform(100, 0);
      PolyLine line = PolyLine([point1, point2]);
      expect(line.countVectors, equals(1));
      expect(line.nbPoints, equals(2));
      expect(line.distanceInMeter.round(), equals(100));
      expect(line.vectors.length, equals(1));
      expect(line.distanceMeterUntilPoint(2).round(), equals(100));
      expect(line.subLine(0, 4).countVectors, equals(1));
    });
    test('should compute vectors when 3', () {
      final point1 = Point.fromGeoJson([-75, 39]);
      final point2 = point1.transform(100, 0);
      final point3 = point2.transform(100, 0);
      PolyLine line = PolyLine([point1, point2, point3]);
      expect(line.countVectors, equals(2));
      expect(line.nbPoints, equals(3));
      expect(line.distanceInMeter.round(), equals(200));
      expect(line.vectors.length, equals(2));
      expect(line.distanceMeterUntilPoint(1, inclusive: true).round(),
          equals(100));
      expect(line.subLine(0, 4).countVectors, equals(2));
    });
    test('should compute vectors when 4', () {
      final point1 = Point.fromGeoJson([-75, 39]);
      final point2 = point1.transform(100, 0);
      final point3 = point2.transform(100, 0);
      final point4 = point3.transform(50, 0);
      PolyLine line = PolyLine([point1, point2, point3, point4]);
      expect(line.countVectors, equals(3));
      expect(line.nbPoints, equals(4));
      expect(line.distanceInMeter.round(), equals(250));
      expect(line.vectors.length, equals(3));
      expect(line.distanceMeterUntilPoint(3, inclusive: false).round(),
          equals(200));
      expect(line.subLine(0, 4).countVectors, equals(3));
    });
    test('should recompute vectors on add first', () {
      final point1 = Point.fromGeoJson([-75, 39]);
      final point2 = point1.transform(100, 0);
      PolyLine line = PolyLine([point1, point2]);
      expect(line.vectors.length, equals(1));
      expect(line.distanceInMeter.round(), equals(100));
      //
      final point3 = point1.transform(100, 90);
      line.addFirst(point3);
      expect(line.vectors.length, equals(2));
      expect(line.distanceInMeter.round(), equals(200));
    });
    test('should recompute vectors on add last', () {
      final point1 = Point.fromGeoJson([-75, 39]);
      final point2 = point1.transform(100, 0);
      PolyLine line = PolyLine([point1, point2]);
      expect(line.vectors.length, equals(1));
      expect(line.distanceInMeter.round(), equals(100));
      //
      final point3 = point2.transform(100, 90);
      line.addLast(point3);
      expect(line.vectors.length, equals(2));
      expect(line.distanceInMeter.round(), equals(200));
    });
    test('should compute distance 0 when index is 0', () {
      final point1 = Point.fromGeoJson([-75, 39]);
      final point2 = point1.transform(100, 0);
      final point3 = point2.transform(100, 0);
      final point4 = point3.transform(50, 0);
      PolyLine line = PolyLine([point1, point2, point3, point4]);
      expect(line.distanceMeterUntilPoint(0).round(), equals(0));
      expect(line.subLine(0, 0).distanceInMeter.round(), equals(0));
    });
    test('should compute distance when index is 1', () {
      final point1 = Point.fromGeoJson([-75, 39]);
      final point2 = point1.transform(100, 0);
      final point3 = point2.transform(100, 0);
      final point4 = point3.transform(50, 0);
      PolyLine line = PolyLine([point1, point2, point3, point4]);
      expect(line.distanceMeterUntilPoint(1, inclusive: true).round(),
          equals(100));
      //only one point
      expect(line.subLine(0, 1).distanceInMeter.round(), equals(0));
    });
    test('should compute distance when index is 2', () {
      final point1 = Point.fromGeoJson([-75, 39]);
      final point2 = point1.transform(100, 0);
      final point3 = point2.transform(100, 0);
      final point4 = point3.transform(50, 0);
      PolyLine line = PolyLine([point1, point2, point3, point4]);
      expect(line.distanceMeterUntilPoint(2, inclusive: true).round(),
          equals(200));
      //2 points
      expect(line.subLine(0, 2).distanceInMeter.round(), equals(100));
    });
    test('should compute distance when index is last', () {
      final point1 = Point.fromGeoJson([-75, 39]);
      final point2 = point1.transform(100, 0);
      final point3 = point2.transform(100, 0);
      final point4 = point3.transform(50, 0);
      PolyLine line = PolyLine([point1, point2, point3, point4]);
      expect(line.distanceMeterUntilPoint(4).round(), equals(250));
      //3 points
      expect(line.subLine(0, 3).distanceInMeter.round(), equals(200));
      expect(line.subLine(0, 4).distanceInMeter.round(), equals(250));
      expect(line.subLine(0, 5).distanceInMeter.round(), equals(250));
    });
    test('should not get point at meter when polyline is empty', () {
      PolyLine line = PolyLine([]);
      expect(line.getPointAtMeter(10).isPresent, isFalse);
    });
    test('should not get point at meter when polyline contains 1point', () {
      PolyLine line = PolyLine([
        Point.fromGeoJson([-75, 39])
      ]);
      expect(line.getPointAtMeter(10).isPresent, isFalse);
    });
    test('should get point at meter when polyline contains 1point', () {
      PolyLine line = PolyLine([
        Point.fromGeoJson([-75, 39])
      ]);
      expect(line.getPointAtMeter(1, epsilon: 1).isPresent, isTrue);
    });
    final point1 = Point.fromGeoJson([-75, 39]);
    final point2 = point1.transform(100, 0);
    final point3 = point2.transform(100, 90);
    final point4 = point3.transform(50, 90);
    PolyLine line = PolyLine([point1, point2, point3, point4]);
    test('should get point at meter near first point', () {
      final point = line.getPointAtMeter(1, epsilon: 1);
      expect(point.isPresent, isTrue);
      expect(point.value.distanceInMeter(point1), equals(0));
    });
    test('should get point at meter between first and point', () {
      final point = line.getPointAtMeter(50, epsilon: 1);
      expect(point.isPresent, isTrue);
      expect(point.value.distanceInMeter(point1).round(), 50);
      expect(point.value.distanceInMeter(point2).round(), 50);
      expect(
          point.value.toVector(point1).reverseVector.bearingDegree, equals(0));
    });
    test('should get point at meter near second point', () {
      final point = line.getPointAtMeter(100, epsilon: 1);
      expect(point.isPresent, isTrue);
      expect(point.value.distanceInMeter(point2), equals(0));
    });
    test('should get point at meter between second and third', () {
      final point = line.getPointAtMeter(150, epsilon: 1);
      expect(point.isPresent, isTrue);
      expect(point.value.distanceInMeter(point2).round(), 50);
      expect(point.value.distanceInMeter(point3).round(), 50);
      expect(
          point.value.toVector(point2).reverseVector.bearingDegree, equals(90));
    });
    test('should get point at meter near third point', () {
      final point = line.getPointAtMeter(200, epsilon: 1);
      expect(point.isPresent, isTrue);
      expect(point.value.distanceInMeter(point3), equals(0));
    });
    test('should get point at meter between third and last', () {
      final point = line.getPointAtMeter(225, epsilon: 1);
      expect(point.isPresent, isTrue);
      expect(point.value.distanceInMeter(point4).round(), 25);
      expect(point.value.distanceInMeter(point3).round(), 25);
      expect(
          point.value.toVector(point3).reverseVector.bearingDegree, equals(90));
    });
    test('should get point at meter near last point', () {
      final point = line.getPointAtMeter(250, epsilon: 1);
      expect(point.isPresent, isTrue);
      expect(point.value.distanceInMeter(point4), 0);
    });
    test('should not get point at meter because it is to far', () {
      final point = line.getPointAtMeter(260, epsilon: 1);
      expect(point.isPresent, isFalse);
    });
    test('should not get point at meter because it is negative', () {
      final point = line.getPointAtMeter(-2, epsilon: 1);
      expect(point.isPresent, isFalse);
    });
    test('should get point at meter because it is negative but near', () {
      final point = line.getPointAtMeter(-1, epsilon: 1);
      expect(point.isPresent, isTrue);
    });
  });
}
