import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'contract.dart';

class _SimulatorSmoothListener implements PositionListener {
  final PositionListener real;
  final PositionListener simulated;
  //
  int _lastRealTimestamp = 0;
  _SimulatorSmoothListener({this.real, this.simulated});
  // Getters
  bool get listening => real.listening;
  Observable<PositionListenerEvent> get onChange {
    return simulated.onChange
        .withLatestFrom<PositionListenerEvent, PositionListenerEvent>(
            real.onChange, (PositionListenerEvent realEvent,
                PositionListenerEvent simulatedEvent) {
      final ms = realEvent.timestamp.millisecondsSinceEpoch;
      if (_lastRealTimestamp < ms) {
        _lastRealTimestamp = ms;
        //TODO update simulator => set instant speed
        //set real position
        //what about in place?
        return realEvent;
      } else {
        return simulatedEvent;
      }
    });
  }

  // Methods
  stop() async {
    real.stop();
    simulated.stop();
    return true;
  }

  start() async {
    stop();
    real.start();
    simulated.start();
    return true;
  }

  dispose() {
    real?.dispose();
    simulated.dispose();
  }
}

mixin GeolocationSemiSimulatedListener {
  Future<PositionListener> createSimulated();
  Future<PositionListener> createReal();
  Future<PositionListener> listenPositionChanges() async {
    final simulator = await createSimulated();
    final real = await createReal();
    return _SimulatorSmoothListener(real: real, simulated: simulator);
  }
}
