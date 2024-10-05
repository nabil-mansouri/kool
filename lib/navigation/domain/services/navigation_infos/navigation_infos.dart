import 'package:optional/optional.dart';
import 'package:meta/meta.dart';
import '../../geo/geo.dart';
import 'infos_config.dart';
import '../contract.dart';
export 'infos_config.dart';
part 'infos_location.dart';
part 'infos_segment.dart';
//TODO zoom trop eloigné
//TODO zoom bouge trop => mettre des seuils (arrondir à 0.5 pres? ou 1?)


class NavigationInfos
    with _NavigationInfosFromPosition, _NavigationInfosFromSegment {
  final NavigationInfosConfig config;
  //private attributes
  TransportType _type;
  Optional<Direction> _direction = Optional.empty();
  Optional<PolyLine> _polilyne = Optional.empty();
  DateTime _startedAt;
  DateTime _endedAt;
  NavigationStateEnum _state = NavigationStateEnum.Idle;
  //
  NavigationInfos(this.config);
  //getters
  TransportType get transportType => _type;
  NavigationStateEnum get state => _state;
  Optional<Direction> get direction => _direction;
  Optional<PolyLine> get polyline => _polilyne;
  DateTime get startedAt => _startedAt;
  //methods
  getNow() {
    return DateTime.now();
  }

  start(Direction direction, TransportType type) {
    _type = type;
    _startedAt = getNow();
    _endedAt = null;
    _state = NavigationStateEnum.Navigating;
    _direction = Optional.ofNullable(direction);
    _polilyne = _direction.map((o) => o.polyline);
    startInfosFromPosition();
    startInfosFromSegment(direction);
  }

  finish() {
    _endedAt = getNow();
    _state = NavigationStateEnum.Arrived;
  }

  preparing() {
    _state = NavigationStateEnum.Preparing;
    _direction = Optional.empty();
    _polilyne = Optional.empty();
  }

  notFound() {
    _state = NavigationStateEnum.NotFound;
    _direction = Optional.empty();
    _polilyne = Optional.empty();
  }

  stop() {
    _state = NavigationStateEnum.Idle;
  }

  //computed values
  bool get isFinished => _endedAt != null;

  bool get hasDirection {
    return direction.isPresent && direction.value.stepsCount > 0;
  }

  bool get isNavigating {
    return hasDirection && _state == NavigationStateEnum.Navigating;
  }

  @override
  String toString() {
    return "[SegmentIndex=${_lastKnownSegment?.segmentIndex}, StepRemainMeters=$stepRemainingMeters, PastMeters=$pastMetersInLine, DeltaDistance=${currentMovement.orElse(null)?.distanceInMeter}, Speed=$currentSpeedMeterPerSeconds m/s, TotalDistance=$totalMeters m, DistanceRemaining=$totalRemainingMeters m, TotalTime=$totalSeconds s, TimeRemaining=$totalRemainingSeconds s, CurrentBearing=$currentBearingDegree deg, Bounds=${cameraBounds.orElse(null)?.toString()}, Position=${currentPosition.orElse(null)?.toString()}]";
  }
}
