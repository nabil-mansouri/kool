part of 'navigation_infos.dart';

mixin _NavigationInfosFromSegment {
  Optional<DirectionStep> _currentStep = Optional.empty();
  Optional<DirectionStep> _nextStep = Optional.empty();
  Optional<NearestPointOnSegment> _currentSegment = Optional.empty();
  int _nbSegmentFounded = 0;
  //cache
  int _pastMetersInTravel;
  int _totalRemainingSeconds;
  int _lastPastMeter = 0;
  int _stepRemainingMeters;
  NearestPointOnSegment _lastKnownSegment;
  Optional<PolyLine> _before = Optional.empty();
  Optional<PolyLine> _after = Optional.empty();
  //getters
  Optional<DirectionStep> get currentStep => _currentStep;
  Optional<DirectionStep> get nexStep => _nextStep;
  bool get hasCurrentStep => currentStep.isPresent;
  bool get hasNextStep => nexStep.isPresent;
  bool get hasSegment => _currentSegment.isPresent;
  NearestPointOnSegment get lastKnownSegment => _lastKnownSegment;
  Optional<NearestPointOnSegment> get segment => _currentSegment;
  int get nbSegmentFounded => _nbSegmentFounded;
  Optional<PolyLine> get lineBefore => _before;
  Optional<PolyLine> get lineAfter => _after;
  //methods

  void setCurrentSegment(NearestPointOnSegment segment) {
    if (!direction.isPresent || isFinished) return;
    //must backup segment before changes
    backupSegmentInfos();
    resetSegmentInfos();
    //
    final _direction = direction.value;
    _currentSegment = Optional.ofNullable(segment);
    if (_currentSegment.isPresent) {
      _nbSegmentFounded++;
      final segmentIndex = _currentSegment.value.segmentIndex;
      final polyline = _direction.polyline;
      _before = Optional.of(polyline.subLine(0, segmentIndex));
      _after =
          Optional.of(polyline.subLine(segmentIndex + 1, polyline.nbPoints));
      if (_currentSegment.value.hasIntersect) {
        _before.value.addLast(_currentSegment.value.startToIntersect.end);
        _after.value.addFirst(_currentSegment.value.startToIntersect.end);
      }
    }
    _currentStep = _direction.stepForIndex(indexOfPoint: segment.segmentIndex);
    _nextStep = _direction.stepForIndex(indexOfPoint: segment.segmentIndex + 1);
    if (totalRemainingMeters <= config.finishEpsilon) {
      finish();
    }
  }

  backupSegmentInfos() {
    if (_pastMetersInTravel != null) _lastPastMeter = _pastMetersInTravel;
    if (_currentSegment.isPresent) _lastKnownSegment = _currentSegment.value;
  }

  resetSegmentInfos() {
    _pastMetersInTravel = null;
    _stepRemainingMeters = null;
    _totalRemainingSeconds = null;
  }

  startInfosFromSegment(Direction direction) {
    resetSegmentInfos();
    _lastPastMeter = 0;
    _lastKnownSegment = null;
    _currentStep = Optional.empty();
    _nextStep = Optional.empty();
    _currentSegment = Optional.empty();
    _nbSegmentFounded = 0;
    _after = Optional.of(direction.polyline);
    _before = Optional.of(PolyLine([]));
  }

  int _computeTotalRemainingSecondsFromSegmen(
      NearestPointOnSegment _lastKnownSegment, int defaultValue) {
    if (!direction.isPresent) return defaultValue;
    final step = direction.value
        .stepForIndex(indexOfPoint: _lastKnownSegment.segmentIndex);
    if (!step.isPresent) return defaultValue;
    final isStart = _lastKnownSegment.type == ClosestPointType.Start;
    if (isStart) {
      return step.value.computeSecondsToEnd(true);
    }
    final remainingMeterForStep = stepRemainingMeters;
    final secondsForThisStep = step.value.durationSeconds;
    final totalMeterForStep = step.value.distanceMeters;
    final ratioKeepDoing =
        totalMeterForStep > 0 ? remainingMeterForStep / totalMeterForStep : 0;
    var _totalRemainingSeconds = ratioKeepDoing * secondsForThisStep;
    _totalRemainingSeconds += step.value.computeSecondsToEnd(false);
    if (_totalRemainingSeconds.isInfinite || _totalRemainingSeconds.isNaN) {
      return totalSeconds;
    }
    return _totalRemainingSeconds.round();
  }

  //computed value
  int get totalMeters {
    if (!direction.isPresent) return 0;
    return direction.value.distanceInMeter;
  }

  int get totalRemainingMeters {
    final value = totalMeters - pastMetersInLine;
    return value > 0 ? value : 0;
  }

  int get pastMetersInLine {
    if (_pastMetersInTravel != null) {
      return _pastMetersInTravel;
    }
    // dont use elseif => try all
    if (_currentStep.isPresent &&
        _currentStep.value.hasDistanceMeters &&
        hasSegment) {
      //Compute from step => better estimation
      final segment = _currentSegment.value;
      final isStepFinished = ClosestPointType.End == segment.type;
      _pastMetersInTravel =
          _currentStep.value.computeMetersToBegin(isStepFinished);
      if (isStepFinished) {
        return _pastMetersInTravel;
      }
      final distanceOfCurrentStep = segment.startToClosest.distanceInMeter;
      _pastMetersInTravel += distanceOfCurrentStep.round();
      return _pastMetersInTravel;
    }
    //Dont use else if here
    if (direction.isPresent && hasSegment) {
      //Compute from polyline
      final segment = _currentSegment.value;
      final distanceUntilPath = direction.value.polyline
          .distanceMeterUntilPoint(segment.segmentIndex + 1);
      final distanceOfCurrentStep = segment.startToClosest.distanceInMeter;
      _pastMetersInTravel = (distanceUntilPath + distanceOfCurrentStep).round();
      return _pastMetersInTravel;
    }
    //
    return _lastPastMeter;
  }

  int get stepRemainingMeters {
    if (!hasCurrentStep || !hasSegment) return 0;
    if (_stepRemainingMeters == null) {
      final segment = _currentSegment.value;
      final value = (_currentStep.value.distanceMeters -
          segment.startToClosest.distanceInMeter);
      _stepRemainingMeters = value.round();
    }
    return _stepRemainingMeters;
  }

  int get pastSeconds {
    if (startedAt == null) return 0;
    final ms =
        (getNow().millisecondsSinceEpoch - startedAt.millisecondsSinceEpoch);
    return (ms / 1000).round();
  }

  int get totalSeconds {
    if (!direction.isPresent) return 0;
    return direction.value.travelTimeInSec;
  }

  int get totalRemainingSeconds {
    if (!direction.isPresent) return 0;
    if (_totalRemainingSeconds == null) {
      if (totalMeters == 0 || totalRemainingMeters == 0) {
        _totalRemainingSeconds = 0;
      } else if (_currentSegment.isPresent) {
        //compute distance remaining by adding next step distances
        _totalRemainingSeconds = _computeTotalRemainingSecondsFromSegmen(
            _currentSegment.value, totalSeconds);
      } else if (_lastKnownSegment != null) {
        //compute distance remaining by adding next step distances
        _totalRemainingSeconds = _computeTotalRemainingSecondsFromSegmen(
            _lastKnownSegment, totalSeconds);
      } else {
        _totalRemainingSeconds = totalSeconds;
      }
    }
    return _totalRemainingSeconds;
  }

  double get meanMeterPerSeconds {
    if (pastSeconds == 0) return 0;
    return realPastMeters / pastSeconds;
  }

  //abstract
  DateTime getNow();
  finish();
  NavigationInfosConfig get config;
  bool get isFinished;
  DateTime startedAt;
  int get realPastMeters;
  Optional<Direction> get direction;
}
