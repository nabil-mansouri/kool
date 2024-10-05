import 'package:geolocator/geolocator.dart';
import '../geo/geo.dart';
import 'contract.dart';

class PositionListenerEventImpl implements PositionListenerEvent {
  final Position position;
  final int count;
  Point _point;
  PositionListenerEventImpl(this.position, this.count);
  Point get coordinate {
    if (_point == null) {
      _point = Point(this.position.latitude, this.position.longitude);
    }
    return _point;
  }

  get first => count == 0;

  DateTime get timestamp => position.timestamp;
  double get accuracyMeter => position.accuracy;
  double get altitudeMeter => position.altitude;
  double get headingDegree => position.heading;
  double get speedMeterSecond => position.speed;
  double get speedAccuracyMeterSecond => position.speedAccuracy;
  String toString() {
    return "Point=$coordinate";
  }
}