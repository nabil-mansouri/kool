import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import '../services.dart';

unitTestMapkitService() {
  group("[MapKit]", () {
    final leCreusot = Point(46.8, 4.4333);
    final montceau = Point(46.6667, 4.3667);
    final service = NavigationServiceMapKit.init();
    test('should search place', () async {
      final res = await service.searchPlaces("Le Creusot");
      expect(res.length, greaterThan(0));
      expect(res[0].coordinate, isNotNull);
      expect(res[0].coordinate.latitude, isNotNull);
      expect(res[0].coordinate.longitude, isNotNull);
      expect(res[0].country, isNotNull);
      expect(res[0].formattedAddress, isNotNull);
    });
    test('should fetch direction', () async {
      final res = await service.fetchDirection(
          from: leCreusot, to: montceau, type: TransportType.Car);
      expect(res.isPresent, isTrue);
      expect(res.value.distanceInMeter, greaterThan(1000));
      expect(res.value.travelTimeInSec, greaterThan(1000));
      expect(res.value.polyline.nbPoints, greaterThan(10));
      expect(res.value.stepsCount, greaterThan(10));
      final step = res.value.stepForIndex(indexOfPoint: 1);
      expect(step.isPresent, isTrue);
      final resImg = await service.fetchDirectionImage(step.value);
      expect(resImg.length, greaterThan(200));
      //
      var logFile = File('output/test.png');
      var sink = logFile.openWrite();
      sink.add(resImg);
      await sink.flush();
      await sink.close();
    });
  });
}
