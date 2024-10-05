import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:geolocator/geolocator.dart';
import '../geo/geo.dart';
import 'position_commons.dart';
import 'contract.dart';

class _SimulatorPositionListener implements PositionListener {
  final Simulator simulator;
  final bool synchrone;
  // Mutable attributes
  int _index;
  bool _listening;
  Subject<PositionListenerEvent> _observable;
  _SimulatorPositionListener(this.simulator, {this.synchrone = true});
  // Getters
  bool get listening => _listening;
  Observable<PositionListenerEvent> get onChange => _observable;
  // Methods
  stop() async {
    _observable?.close();
    _observable = null;
    _listening = false;
    return true;
  }

  start() async {
    stop();
    _index = 0;
    _listening = true;
    _observable = BehaviorSubject(sync: synchrone);
    simulator.start((onData) {
      if (onData.isPresent) {
        final value = onData.value;
        final pos = Position(
            accuracy: 0,
            altitude: 0,
            heading: value.bearingDegree,
            latitude: value.end.latitude,
            longitude: value.end.longitude,
            speed: value.meterPerSeconds,
            speedAccuracy: 0,
            timestamp: DateTime.now());
        _observable.add(PositionListenerEventImpl(pos, _index++));
      }
    });
    return true;
  }

  dispose() {
    _observable?.close();
    _observable = null;
  }
}

mixin GeolocationSimulatedListener {
  Future<Simulator> createSimulator();
  Future<PositionListener> listenPositionChanges() async {
    final simulator = await createSimulator();
    return _SimulatorPositionListener(simulator);
  }
}
