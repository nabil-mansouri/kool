part of 'navigation_infos.dart';

double _roundByStep(double value, double step) {
  step = step ?? 1.0;
  double inv = 1.0 / step;
  return (value * inv).round() / inv;
}

//1km = 1000m and 1h=60minutes=60sec*60min
const BIKE_METER_SECONDS = 20 * 1000 / 3600; //20 km/H
const CAR_METER_SECONDS = 50 * 1000 / 3600; //50 km/H
const WALK_METER_SECONDS = 6 * 1000 / 3600; //6 km/H

mixin _NavigationInfosFromPosition {
  //attributes
  DateTime _lastUpdate;
  int _realPastMeter = 0;
  Optional<VectorTime> _currentMovement = Optional.empty();
  //cache
  double _googleZoom;
  Bounds _cameraBounds;
  Point _cameraPosition;
  int _cameraBoundsMeters;
  double _currentSmoothSpeed;
  double _currentSmoothBearing;
  //backed up values
  double _lastGoogleZoom; //start null=>first zoom is as this
  double _lastKnownBearing = 0; //start 0 to avoid null at start
  double _lastSmmothSpeed = 0; //start from 0 (smooth initial speed)
  double _lastSmoothBearing; //start null=>first bearing is as this
  //getters
  int get realPastMeters => _realPastMeter;
  Optional<VectorTime> get currentMovement => _currentMovement;
  //methods
  int _pastMilliSeconds(DateTime now) {
    if (_lastUpdate == null) {
      return null;
    }
    final ms = now.millisecondsSinceEpoch - _lastUpdate.millisecondsSinceEpoch;
    return ms;
  }

  void setCurrent(Point currentPt, [DateTime _now]) {
    //TODO use time from event?
    final now = _now == null ? getNow() : _now;
    final durationMSec = _pastMilliSeconds(now);
    //should at least past 1sec since last time=> avoid infinity
    if (durationMSec != null && durationMSec <= 0) {
      return;
    }
    backupInfosFromPosition();
    resetInfosFromPosition();
    VectorTime value;
    //first time set the vector to current position
    if (_currentMovement.isPresent) {
      value = VectorTime(_currentMovement.value.end, currentPt,
          Duration(milliseconds: durationMSec));
      _realPastMeter += value.distanceInMeter.round();
    } else {
      //first time set the vector to current position
      value = VectorTime(currentPt, currentPt, Duration(milliseconds: 0));
    }
    _currentMovement = Optional.ofNullable(value);
    _lastUpdate = now;
    //TODO test if finish (distance to end?)
  }

  resetInfosFromPosition() {
    _cameraBounds = null;
    _cameraPosition = null;
    _cameraBoundsMeters = null;
    _currentSmoothBearing = null;
    _currentSmoothSpeed = null;
    _googleZoom = null;
  }

  startInfosFromPosition() {
    resetInfosFromPosition();
    _lastUpdate = null;
    _realPastMeter = 0;
    _lastKnownBearing = 0;
    _currentMovement = Optional.empty();
  }

  backupInfosFromPosition() {
    _lastGoogleZoom = _googleZoom ?? _lastGoogleZoom;
    _lastSmmothSpeed = _currentSmoothSpeed ?? _lastSmmothSpeed;
    _lastSmoothBearing = _currentSmoothBearing ?? _lastSmoothBearing;
  }

  //computed values
  bool get hasPosition => _currentMovement.isPresent;
  bool get hasMovement => _currentMovement.isPresent;
  double get currentSmoothBearingDegree {
    if (_currentSmoothBearing == null) {
      _currentSmoothBearing = currentBearingDegree;
      if (_lastSmoothBearing != null) {
        _currentSmoothBearing =
            _currentSmoothBearing * config.currentBearingWeight +
                _lastSmoothBearing * config.lastBearingWeight;
      }
    }
    return _currentSmoothBearing;
  }

  Optional<Point> get currentPosition {
    if (_currentMovement.isPresent) {
      return Optional.ofNullable(_currentMovement.value.end);
    } else {
      return Optional.empty();
    }
  }

  Optional<double> get currentSmoothSpeed {
    if (!_currentMovement.isPresent) return Optional.empty();
    if (_currentSmoothSpeed == null) {
      final currentMeterSeconds = _currentMovement.value.meterPerSeconds;
      if (currentMeterSeconds == double.infinity || currentMeterSeconds.isNaN) {
        return Optional.empty();
      }
      //
      _currentSmoothSpeed = currentMeterSeconds * config.currentSpeedWeight +
          _lastSmmothSpeed * config.lastSpeedWeight;
    }
    return Optional.ofNullable(_currentSmoothSpeed);
  }

  Optional<int> get cameraBoundsMeters {
    if (!hasPosition || !hasMovement) return Optional.empty();
    if (_cameraBoundsMeters == null) {
      //use smooth bearing and smooth speed to compute camera position and bounds meters
      final speed = currentSmoothSpeed.orElse(defaultAverageMeterSecond);
      final totalDistance = config.secondsWindow * speed;
      _cameraBoundsMeters = totalDistance.round();
    }
    return Optional.ofNullable(_cameraBoundsMeters);
  }

  Optional<Point> get cameraPosition {
    if (!hasPosition || !hasMovement || !cameraBoundsMeters.isPresent)
      return Optional.empty();
    if (_cameraPosition == null) {
      //camera position
      final cameraBoundsMeter = cameraBoundsMeters.value;
      final bearing = currentSmoothBearingDegree;
      final distanceToCurrentPosition =
          cameraBoundsMeter * config.cameraRatioRelativeToPosition;
      _cameraPosition = _currentMovement.value.end
          .transform(distanceToCurrentPosition, bearing);
    }
    return Optional.ofNullable(_cameraPosition);
  }

  double getGoogleZoom(
      {@required double heightPX,
      @required double widthPX,
      bool verticalOrientation = true}) {
    if (_googleZoom == null) {
      if (cameraBoundsMeters.isPresent && cameraPosition.isPresent) {
        try {
          _googleZoom = getZoom(cameraBoundsMeters.value,
              ratioOnMap: 1,
              latitude: cameraPosition.value.latitude,
              pixels: verticalOrientation ? heightPX : widthPX);
          if (_lastGoogleZoom != null) {
            // _googleZoom = _googleZoom * config.currentZoomWeight +
            //    _lastGoogleZoom * config.lastZoomWeight;
          }
          if (config.zoomRoundStep != 0)
            _googleZoom = _roundByStep(_googleZoom, config.zoomRoundStep);
        } catch (e) {
          //divide by 0...
        }
      }
      //
      if (_googleZoom == null || _googleZoom.isNaN || _googleZoom.isInfinite) {
        _googleZoom = _lastGoogleZoom ?? config.defaultGoogleZoom;
      }
    }
    return _googleZoom;
  }

  Optional<Bounds> get cameraBounds {
    if (hasPosition &&
        hasMovement &&
        cameraPosition.isPresent &&
        cameraBoundsMeters.isPresent) {
      if (_cameraBounds == null) {
        final _cameraPosition = cameraPosition.value;
        final totalDistance = cameraBoundsMeters.value;
        final midDistance = totalDistance * 0.5;
        final sideDistance = 4; //4meter each side
        final pointAfter =
            _cameraPosition.transform(midDistance, currentBearingDegree);
        final pointBefore =
            _cameraPosition.transform(midDistance, currentBearingDegree + 180);
        final pointSide1 =
            _cameraPosition.transform(sideDistance, currentBearingDegree + 90);
        final pointSide2 =
            _cameraPosition.transform(sideDistance, currentBearingDegree - 90);
        _cameraBounds = Bounds.fromPoints(
            [pointAfter, pointBefore, pointSide1, pointSide2]);
      }
      return Optional.ofNullable(_cameraBounds);
    } else {
      //if we cant compute camera from position
      //compute from polyline (direction)
      if (polyline.isPresent) {
        if (_cameraBounds == null) {
          _cameraBounds = Bounds.fromPolyline(polyline.value);
        }
        return Optional.ofNullable(_cameraBounds);
      } else {
        return Optional.empty();
      }
    }
  }

  double get defaultAverageMeterSecond {
    switch (transportType) {
      case TransportType.Bike:
        return BIKE_METER_SECONDS;
      case TransportType.Walk:
        return WALK_METER_SECONDS;
      case TransportType.Car:
      default:
        return CAR_METER_SECONDS;
    }
  }

  //TODO use from device? location send heading?
  double get currentBearingDegree {
    if (!hasMovement || _currentMovement.value.distanceInMeter.round() < 0.2)
      return _lastKnownBearing;
    var bearing = _currentMovement.value.bearingDegree;
    //only positive values
    if (bearing < 0) {
      bearing += 360;
    }
    _lastKnownBearing = bearing;
    return _lastKnownBearing;
  }

  double get currentSpeedMeterPerSeconds {
    if (!hasMovement) return 0;
    final value = _currentMovement.value.meterPerSeconds;
    return value == double.infinity ? 0 : value;
  }

  //abstract
  DateTime getNow();
  Optional<PolyLine> polyline;
  TransportType get transportType;
  double get meanMeterPerSeconds;
  NavigationInfosConfig get config;
}
