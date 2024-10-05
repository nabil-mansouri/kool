import 'package:optional/optional.dart';
import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:meta/meta.dart';
import 'geometry.dart';

double _computeTimeFromSpeed(
    {@required num meterSecondI,
    @required num meterSecondF,
    @required num meters}) {
  //a = (vf-vi)/t
  //d = (vi*t)+ 0.5 * a * t2
  //d = (vi*t) + 0.5 * (vf-vi)*t*t/t
  //d = (vi*t) + 0.5 * (vf-vi)*t
  //d = t * (vi + 0.5 (vf-vi))
  //t = d / (vi + 0.5 (vf-vi)) => if vi=vf => d/vi
  final diff = meterSecondF - meterSecondI;
  final denom = (meterSecondI + 0.5 * diff);
  return denom == 0 ? 0 : meters / denom;
}

double computeFinalSpeedFromTime(
    {@required num meterSecondI, @required num seconds, @required num meters}) {
  //a = (vf-vi)/t
  //d = (vi*t)+ 0.5 * a * t2
  //d = (vi*t) + 0.5 * (vf-vi)*t*t/t
  //d = (vi*t) + 0.5 * (vf-vi)*t
  //0.5 * (vf-vi)*t = d - (vi*t)
  //(vf-vi)= 2 * (d - (vi*t))/t
  //vf = 2d/t - 2vi + vi
  //vf = 2d/t - vi
  final meanSpeed = seconds == 0 ? 0 : meters / seconds;
  return 2 * meanSpeed - meterSecondI;
}

abstract class SpeedProvider {
  double currentMeterSeconds(double fraction);
  int getSeconds({@required int forMeters});
  double meanMeterPerSeconds({@required int forMeters}) {
    final seconds = getSeconds(forMeters: forMeters);
    if (seconds == 0) return 0;
    return forMeters / seconds;
  }
}

class SpeedProviderConstant extends SpeedProvider {
  final num speed;
  SpeedProviderConstant(this.speed);
  double currentMeterSeconds(double fraction) {
    return this.speed;
  }

  int getSeconds({@required int forMeters}) {
    return _computeTimeFromSpeed(
            meters: forMeters, meterSecondI: speed, meterSecondF: speed)
        .round();
  }
}

class SpeedProviderProportionnal extends SpeedProvider {
  final num maxSpeed;
  final num initialSpeed;

  SpeedProviderProportionnal(this.maxSpeed, {this.initialSpeed = 0});
  double currentMeterSeconds(double fraction) {
    return range * fraction;
  }

  num get range => maxSpeed - initialSpeed;
  int getSeconds({@required int forMeters}) {
    return _computeTimeFromSpeed(
            meters: forMeters,
            meterSecondI: initialSpeed,
            meterSecondF: maxSpeed)
        .round();
  }
}

class SpeedProviderByRange extends SpeedProvider {
  final List<double> meterSeconds;
  final List<double> fractions;
  final bool proportionnal;
  SpeedProviderByRange(
      {@required this.meterSeconds,
      @required this.fractions,
      this.proportionnal = false})
      : assert(fractions.contains(0), "shoyld contain initial speed"),
        assert(fractions.contains(1), "sould contains final speed"),
        assert(fractions.length == meterSeconds.length,
            "should have same number of speeds/fractions values");

  double currentMeterSeconds(double fraction) {
    int i = 0;
    while (i < fractions.length && fraction > fractions[i]) {
      i++;
    }
    if (proportionnal) {
      if (0 < i && i < fractions.length) {
        final vi = meterSeconds[i - 1];
        final vf = meterSeconds[i];
        final diffV = vf - vi;
        final frI = fractions[i - 1];
        final frF = fractions[i];
        final diffF = frF - frI;
        final ratio = diffF == 0 ? 0 : (fraction - frI) / diffF;
        return vi + diffV * ratio;
      } else if (i == 0) {
        return meterSeconds.first;
      } else {
        return meterSeconds.last;
      }
    } else {
      if (i < fractions.length) {
        return meterSeconds[i];
      }
      return meterSeconds.last;
    }
  }

  int getSeconds({@required int forMeters}) {
    double seconds = 0;
    for (int i = 1; i < fractions.length; i++) {
      final vi = meterSeconds[i - 1];
      final vf = meterSeconds[i];
      final frI = fractions[i - 1];
      final frF = fractions[i];
      final df = (forMeters * frF) - (forMeters * frI);
      if (proportionnal) {
        seconds += _computeTimeFromSpeed(
            meters: df, meterSecondI: vi, meterSecondF: vf);
      } else {
        seconds += _computeTimeFromSpeed(
            meters: df, meterSecondI: vi, meterSecondF: vi);
      }
    }
    return seconds.round();
  }
}

enum SimulatorState { Idle, Running, Finished, Aborted }

class Simulator {
  final PolyLine line;
  final SpeedProvider speed;
  final int millisecondsStep;
  final int totalMilliseconds;
  final double meanMeterPerSeconds;
  final double epsilonMeters = 0.5;
  final bool stopAtEndOfLine;
  final int totalDistance;
  final double stopAtFraction;
  //dont round to int because if frequency is very high, distance stay 0
  double _spentMeters = 0;
  int _spentMilliseconds = 0;
  double _spentMetersOld = 0;
  double _fraction = 0;
  double _currentSpeed = 0;
  Completer<bool> _completer;
  StreamSubscription _subscription;
  SimulatorState _state = SimulatorState.Idle;
  Optional<VectorTime> _vector = Optional.empty();
  //
  Simulator(this.line,
      {@required this.speed,
      @required this.millisecondsStep,
      @required this.totalMilliseconds,
      @required this.meanMeterPerSeconds,
      @required this.totalDistance,
      this.stopAtEndOfLine = true,
      this.stopAtFraction = 1});
  factory Simulator.fromSpeed(PolyLine line,
      {@required final SpeedProvider speed,
      final int totalMeters,
      double stopAtFraction = 1,
      int hertz = 20}) {
    final ms = hertz == 0 ? 0 : 1000 / hertz;
    final int totalDistance = totalMeters ?? line.distanceInMeter.round();
    final totalSeconds = speed.getSeconds(forMeters: totalDistance);
    final totalMS = (totalSeconds * 1000).round();
    return Simulator(line,
        speed: speed,
        millisecondsStep: ms.round(),
        totalDistance: totalDistance,
        meanMeterPerSeconds:
            speed.meanMeterPerSeconds(forMeters: totalDistance),
        totalMilliseconds: totalMS,
        stopAtFraction: stopAtFraction);
  }
  //
  double get currentSpeed => _currentSpeed;
  double get fraction => _fraction;
  int get spentMilliseconds => _spentMilliseconds;
  int get spentSeconds => (_spentMilliseconds / 1000).round();
  int get spentMeters => _spentMeters.round();
  bool get running => _state == SimulatorState.Running;
  bool get finished => _state == SimulatorState.Finished;
  bool get aborted => _state == SimulatorState.Aborted;
  num get deltaMeters => _spentMeters - _spentMetersOld;
  //
  Optional<VectorTime> _tick(int index) {
    _spentMilliseconds += millisecondsStep;
    _fraction =
        totalMilliseconds == 0 ? 1 : _spentMilliseconds / totalMilliseconds;
    _currentSpeed = speed.currentMeterSeconds(fraction);
    final distance = (_currentSpeed / 1000) * millisecondsStep;
    _spentMetersOld = _spentMeters;
    _spentMeters += distance;
    if (_spentMeters > totalDistance && stopAtEndOfLine) {
      _spentMeters = totalDistance.toDouble();
    }
    final diff = (totalDistance - _spentMeters).abs();
    //print("#############################################################");
    //print("#############################################################");
    var point =
        line.getPointAtMeter(_spentMeters.round(), epsilon: epsilonMeters);
    if (diff <= epsilonMeters || stopAtFraction <= _fraction) {
      point = Optional.of(line.lastPoint);
      Future.delayed(Duration(milliseconds: 0), () {
        _finish();
      });
    }
    _vector = point.map((m) {
      if (_vector.isPresent) {
        return VectorTime(
            _vector.value.end, m, Duration(milliseconds: millisecondsStep));
      } else {
        return VectorTime(m, m, Duration(milliseconds: millisecondsStep));
      }
    });
    //print(
    //    "$index: Fraction($fraction), DeltaMeters=$deltaMeters, SpentMS($spentMilliseconds), Speed($currentSpeed), SpentMeter($spentMeters),TotalMeter($totalDistance), Position=${point.orElse(null)}");
    return _vector;
  }

  _createObservable() {
    return Observable.periodic(Duration(milliseconds: millisecondsStep),
        (index) {
      return _tick(index);
    });
  }

  Future<bool> start(void onData(Optional<VectorTime> event)) {
    abort();
    _reset();
    _subscription = _createObservable().listen(onData);
    _completer = Completer();
    _state = SimulatorState.Running;
    return _completer.future;
  }

  _finish() {
    _stop();
    _currentSpeed = 0;
    _state = SimulatorState.Finished;
    _completer?.complete(true);
    _completer = null;
  }

  abort() {
    _stop();
    _currentSpeed = 0;
    _state = SimulatorState.Aborted;
    _completer?.complete(false);
    _completer = null;
  }

  _reset() {
    _fraction = 0;
    _spentMeters = 0;
    _currentSpeed = 0;
    _spentMilliseconds = 0;
    _vector = Optional.empty();
  }

  _stop() {
    _subscription?.cancel();
    _subscription = null;
    //print("canceled");
  }
}
