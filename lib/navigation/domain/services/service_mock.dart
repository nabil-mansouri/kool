import 'dart:convert' as JSON;
import 'dart:async';
import 'package:meta/meta.dart';
import 'package:optional/optional.dart';
import 'package:flutter/services.dart' show rootBundle;
import './position_simulated.dart';
import 'contract.dart';
import '../geo/geo.dart';
import 'navigation.dart';
import 'service_mapkit.dart';
import 'navigation_infos/navigation_infos.dart';


class MockNavigationService
    with GeolocationSimulatedListener
    implements NavigationService {
  static final kHertz = 60;
  static final kWindowSeconds = 20;
  static final kSpeed = SpeedProviderByRange(
      fractions: [0, 0.25, 0.5, 0.75, 1],
      meterSeconds: [0, 60, 90, 60, 0],
      proportionnal: true);
  static final kSpeed200 = SpeedProviderByRange(
      fractions: [0, 0.25, 0.5, 0.75, 1],
      meterSeconds: [0, 50, 200, 100, 0],
      proportionnal: true);
  final NavigationInfosConfig config;
  var hertz = kHertz;
  var speed = kSpeed;
  var jsonString =
      rootBundle.loadString('output/creusot_montceau.json', cache: false);
  MockNavigationService(this.config);
  Optional<Direction> _direction;
  Future<List<Place>> searchPlaces(String search) {
    return Future.value([]);
  }

  Future<Optional<Direction>> fetchDirection(
      {@required Point from,
      @required Point to,
      @required TransportType type}) async {
    if (_direction != null) return _direction;
    final jsonText = await jsonString;
    final json = JSON.jsonDecode(jsonText);
    final direction = DirectionMapKit.fromRoutes(json);
    _direction = Optional.of(direction);
    return _direction;
  }

  createSimulator() async {
    final direction =
        await fetchDirection(from: null, to: null, type: TransportType.Car);
    final meters = direction.value.distanceInMeter;
    ;
    return Simulator.fromSpeed(direction.value.polyline,
        speed: speed, totalMeters: meters, hertz: hertz);
  }

  Navigation createNavigation() {
    return NavigationImpl(service: this, config: config);
  }
}
