import 'dart:async';
import 'package:meta/meta.dart';
import 'package:optional/optional.dart';
import 'navigation_infos/navigation_infos.dart';
import '../geo/geo.dart';

typedef Future<void> NavigationRestarterCallback();
typedef FutureOr<T> _FutureFactory<T>();
enum _CancelableFutureState { Idle, Cancel, Pending, Finish }

class _CancelableFuture<T> {
  final Duration duration;
  final T canceldValue;
  //
  _CancelableFutureState _state = _CancelableFutureState.Idle;
  Future<T> _future;
  _FutureFactory<T> _computation;
  //
  _CancelableFuture(this.duration, this.canceldValue);
  bool get canceled => _state == _CancelableFutureState.Cancel;
  bool get pending => _state == _CancelableFutureState.Pending;
  bool get finished => _state == _CancelableFutureState.Finish;
  //methods
  cancel() {
    _state = _CancelableFutureState.Cancel;
  }

  Future<T> callback(_FutureFactory<T> c) async {
    _computation = c;
    if (pending) return _future;
    _state = _CancelableFutureState.Pending;
    _future = Future.delayed(duration, () async {
      try {
        if (canceled) return canceldValue;
        final res = await Future.value(_computation());
        return res;
      } finally {
        _state = _CancelableFutureState.Finish;
      }
    });
    return _future;
  }
}

abstract class NavigationRestarter {
  @protected
  bool _checkIfShouldRestart(
      NavigationInfos infos, Optional<NearestPointOnSegment> near);
  @protected
  Future<bool> _doRestart(
      NavigationInfos infos, Optional<NearestPointOnSegment> near);
  @protected
  void _dontRestart();
  @mustCallSuper
  Future<bool> mayRestart(
      NavigationInfos infos, Optional<NearestPointOnSegment> near) {
    if (_checkIfShouldRestart(infos, near)) {
      return _doRestart(infos, near);
    }
    _dontRestart();
    return Future.value(false);
  }
}

//increase time while not found 10*0
class NavigationRestarterAvoidFlood extends NavigationRestarter {
  int _index = 0;
  final int secondsBetween;
  final NavigationRestarter child;
  _CancelableFuture<bool> _lastOperation;
  NavigationRestarterAvoidFlood(
      {this.secondsBetween = 5, @required this.child});
  @protected
  bool _checkIfShouldRestart(
      NavigationInfos infos, Optional<NearestPointOnSegment> near) {
    return child._checkIfShouldRestart(infos, near);
  }

  @protected
  void _dontRestart() {
    _index = 0;
    _lastOperation?.cancel();
    //cancel in case of status changes
    child._dontRestart();
  }

  @protected
  Future<bool> _doRestart(
      NavigationInfos infos, Optional<NearestPointOnSegment> near) {
    final call = () {
      return child._doRestart(infos, near);
    };
    //if an operation is pending => update it
    if (_lastOperation?.pending == true) return _lastOperation.callback(call);
    //else create a new one
    _index++;
    _lastOperation =
        _CancelableFuture(Duration(seconds: secondsBetween * _index), false);
    return _lastOperation.callback(call);
  }
}

class NavigationRestarterFirstPositionMayNotInPolyline
    extends NavigationRestarter {
  final NavigationRestarter child;
  final int maxMetersToTheFirstPoint;
  NavigationRestarterFirstPositionMayNotInPolyline(
      {@required this.child, @required this.maxMetersToTheFirstPoint});

  @protected
  bool _checkIfShouldRestart(
      NavigationInfos infos, Optional<NearestPointOnSegment> near) {
    //not yet ready so dont restart
    if (!infos.currentPosition.isPresent ||
        !infos.polyline.isPresent ||
        infos.polyline.value.nbPoints == 0) {
      return false;
    } else if (infos.nbSegmentFounded == 0) {
      final vector =
          Vector(infos.currentPosition.value, infos.polyline.value.firstPoint);
      return vector.distanceInMeter.round() > maxMetersToTheFirstPoint;
    } else {
      return child._checkIfShouldRestart(infos, near);
    }
  }

  @protected
  Future<bool> _doRestart(
      NavigationInfos infos, Optional<NearestPointOnSegment> near) async {
    return child._doRestart(infos, near);
  }

  @protected
  void _dontRestart() {
    child._dontRestart();
  }
}

class NavigationRestarterDoRestart extends NavigationRestarter {
  final NavigationRestarterCallback callback;
  NavigationRestarterDoRestart(this.callback);
  @protected
  bool _checkIfShouldRestart(
      NavigationInfos infos, Optional<NearestPointOnSegment> near) {
    if (near.isPresent) {
      return false;
    } else {
      return true;
    }
  }

  @protected
  Future<bool> _doRestart(
      NavigationInfos infos, Optional<NearestPointOnSegment> near) async {
    //check because event could be canceled over the time
    await callback();
    return true;
  }

  @protected
  void _dontRestart() {}
}

NavigationRestarter defaultNavigationRestarter(
    NavigationRestarterCallback callback, TransportType type) {
  int defaultMaxDistanceMeters = 500; //500m
  switch (type) {
    case TransportType.Bike: //20km/h (1km/3min) => 250m
      defaultMaxDistanceMeters = 250;
      break;
    case TransportType.Walk: //4km/h (200m/3min) => 75m
      defaultMaxDistanceMeters = 75;
      break;
    case TransportType.Car: //(150km/h => 2.5km/min) => 500m
    default:
      break;
  }
  //if direction founded but first point near => wait
  //if pending restart => cancel if new restart
  //if restarting => wait restart to continue
  return NavigationRestarterFirstPositionMayNotInPolyline(
      maxMetersToTheFirstPoint: defaultMaxDistanceMeters,
      child: NavigationRestarterAvoidFlood(
          child: NavigationRestarterDoRestart(callback)));
}
