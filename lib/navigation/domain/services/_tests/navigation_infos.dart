import 'package:optional/optional.dart';
import 'package:meta/meta.dart';
import 'package:flutter_test/flutter_test.dart';
import '../services.dart';

class _DirectionStep extends DirectionStep {
  final PolyLine polyline;
  final int index;
  final _DirectionStep _previous;
  _DirectionStep _next;
  _DirectionStep(this.polyline, this.index, this._previous) {
    if (_previous != null) {
      _previous._next = this;
    }
  }
  Vector get vector => polyline.vectors[index];
  //10m/s
  int get distanceMeters => vector.distanceInMeter.round();
  int get durationSeconds => (distanceMeters / 10).round();
  String get instructions => "instructions$index";
  String get manoeuvreType => "manoeuvreType$index";
  String getImageUrl({String hexColor}) => "imageUrl$index";
  Optional<DirectionStep> get next => Optional.ofNullable(_next);
  Optional<DirectionStep> get previous => Optional.ofNullable(_previous);
}

class _Direction implements Direction {
  final PolyLine polyline;
  final List<_DirectionStep> steps = [];
  _Direction(this.polyline) {
    _DirectionStep previous;
    for (int i = 0; i < stepsCount; i++) {
      _DirectionStep current = _DirectionStep(polyline, i, previous);
      steps.add(current);
      previous = current;
    }
  }
  int get distanceInMeter {
    //8 steps => 100 meter per steps
    return polyline.distanceInMeter.round();
  }

  //10m/s
  int get travelTimeInSec => (distanceInMeter / 10).round();
  int get stepsCount => polyline.countVectors;
  Optional<DirectionStep> stepForIndex({@required int indexOfPoint}) {
    if (indexOfPoint < stepsCount) {
      return Optional.ofNullable(steps[indexOfPoint]);
    }
    return Optional.empty();
  }
}

class _NavigationInfosForTest extends NavigationInfos {
  DateTime now;
  //DONT smmooth bearing
  //HALF SMOOTH SPEED
  //window to 60sec
  _NavigationInfosForTest()
      : super(NavigationInfosConfig(
            secondsWindow: 60, currentBearingWeight: 1, currentSpeedWeight: 1));
  void setCurrent(Point currentPt, [DateTime _now]) {
    if (_now != null) now = _now;
    super.setCurrent(currentPt, _now);
  }

  @override
  DateTime getNow() {
    return now;
  }
}

//https://jsfiddle.net/h7bxteqo/2/
unitTestNavigationInfos() {
  group("[NavigationInfos]", () {
    final leCreusot = Point(46.8, 4.4333);
    final point1 = leCreusot.transform(100, 0);
    final point2 = point1.transform(200, 20);
    final point3 = point2.transform(300, 40);
    final point4 = point3.transform(400, 60);
    final point5 = point4.transform(500, -80);
    final point6 = point5.transform(600, -100);
    final point7 = point6.transform(700, -120);
    final point8 = point7.transform(800, -120);
    final point9 = point8.transform(900, -140);
    final point10 = point9.transform(1000, -160);
    final polyline = PolyLine([
      leCreusot,
      point1,
      point2,
      point3,
      point4,
      point5,
      point6,
      point7,
      point8,
      point9,
      point10
    ]);
    final direction = _Direction(polyline);
    final infos = _NavigationInfosForTest();
    final finder =
        defaultSegmentFinder(type: TransportType.Car, line: polyline);
    test('should infos be in initial state', () {
      //infos from positions
      expect(infos.cameraBounds.isPresent, isFalse);
      expect(infos.cameraPosition.isPresent, isFalse);
      expect(infos.currentBearingDegree.round(), equals(0));
      expect(infos.currentMovement.isPresent, isFalse);
      expect(infos.currentPosition.isPresent, isFalse);
      expect(infos.currentSpeedMeterPerSeconds.round(), equals(0));
      expect(infos.currentStep.isPresent, isFalse);
      expect(infos.defaultAverageMeterSecond.round(),
          equals(CAR_METER_SECONDS.round()));
      expect(infos.direction.isPresent, isFalse);
      expect(infos.hasCurrentStep, isFalse);
      expect(infos.hasDirection, isFalse);
      expect(infos.hasMovement, isFalse);
      expect(infos.isFinished, isFalse);
      expect(infos.isNavigating, isFalse);
      expect(infos.lineAfter.isPresent, isFalse);
      expect(infos.lineBefore.isPresent, isFalse);
      expect(infos.meanMeterPerSeconds.round(), equals(0));
      expect(infos.nexStep.isPresent, isFalse);
      expect(infos.nbSegmentFounded, equals(0));
      expect(infos.nexStep.isPresent, isFalse);
      expect(infos.pastMetersInLine, equals(0));
      expect(infos.realPastMeters, equals(0));
      expect(infos.pastSeconds, equals(0));
      expect(infos.polyline.isPresent, isFalse);
      expect(infos.startedAt, isNull);
      expect(infos.state, equals(NavigationStateEnum.Idle));
      expect(infos.stepRemainingMeters, equals(0));
      expect(infos.totalMeters, equals(0));
      expect(infos.totalRemainingMeters, equals(0));
      expect(infos.totalRemainingSeconds, equals(0));
      expect(infos.totalSeconds, equals(0));
      expect(infos.transportType, isNull);
    });
    test('should infos be in preparing state', () {
      infos.preparing();
      //infos from positions
      expect(infos.cameraBounds.isPresent, isFalse);
      expect(infos.cameraPosition.isPresent, isFalse);
      expect(infos.currentBearingDegree.round(), equals(0));
      expect(infos.currentMovement.isPresent, isFalse);
      expect(infos.currentPosition.isPresent, isFalse);
      expect(infos.currentSpeedMeterPerSeconds.round(), equals(0));
      expect(infos.currentStep.isPresent, isFalse);
      expect(infos.defaultAverageMeterSecond.round(),
          equals(CAR_METER_SECONDS.round()));
      expect(infos.direction.isPresent, isFalse);
      expect(infos.hasCurrentStep, isFalse);
      expect(infos.hasDirection, isFalse);
      expect(infos.hasMovement, isFalse);
      expect(infos.isFinished, isFalse);
      expect(infos.isNavigating, isFalse);
      expect(infos.lineAfter.isPresent, isFalse);
      expect(infos.lineBefore.isPresent, isFalse);
      expect(infos.meanMeterPerSeconds.round(), equals(0));
      expect(infos.nexStep.isPresent, isFalse);
      expect(infos.nbSegmentFounded, equals(0));
      expect(infos.nexStep.isPresent, isFalse);
      expect(infos.pastMetersInLine, equals(0));
      expect(infos.realPastMeters, equals(0));
      expect(infos.pastSeconds, equals(0));
      expect(infos.polyline.isPresent, isFalse);
      expect(infos.startedAt, isNull);
      expect(infos.state, equals(NavigationStateEnum.Preparing));
      expect(infos.stepRemainingMeters, equals(0));
      expect(infos.totalMeters, equals(0));
      expect(infos.totalRemainingMeters, equals(0));
      expect(infos.totalRemainingSeconds, equals(0));
      expect(infos.totalSeconds, equals(0));
      expect(infos.transportType, isNull);
    });
    test('should infos be in notfound state', () {
      infos.notFound();
      //infos from positions
      expect(infos.cameraBounds.isPresent, isFalse);
      expect(infos.cameraPosition.isPresent, isFalse);
      expect(infos.currentBearingDegree.round(), equals(0));
      expect(infos.currentMovement.isPresent, isFalse);
      expect(infos.currentPosition.isPresent, isFalse);
      expect(infos.currentSpeedMeterPerSeconds.round(), equals(0));
      expect(infos.currentStep.isPresent, isFalse);
      expect(infos.defaultAverageMeterSecond.round(),
          equals(CAR_METER_SECONDS.round()));
      expect(infos.direction.isPresent, isFalse);
      expect(infos.hasCurrentStep, isFalse);
      expect(infos.hasDirection, isFalse);
      expect(infos.hasMovement, isFalse);
      expect(infos.isFinished, isFalse);
      expect(infos.isNavigating, isFalse);
      expect(infos.lineAfter.isPresent, isFalse);
      expect(infos.lineBefore.isPresent, isFalse);
      expect(infos.meanMeterPerSeconds.round(), equals(0));
      expect(infos.nexStep.isPresent, isFalse);
      expect(infos.nbSegmentFounded, equals(0));
      expect(infos.nexStep.isPresent, isFalse);
      expect(infos.pastMetersInLine, equals(0));
      expect(infos.realPastMeters, equals(0));
      expect(infos.pastSeconds, equals(0));
      expect(infos.polyline.isPresent, isFalse);
      expect(infos.startedAt, isNull);
      expect(infos.state, equals(NavigationStateEnum.NotFound));
      expect(infos.stepRemainingMeters, equals(0));
      expect(infos.totalMeters, equals(0));
      expect(infos.totalRemainingMeters, equals(0));
      expect(infos.totalRemainingSeconds, equals(0));
      expect(infos.totalSeconds, equals(0));
      expect(infos.transportType, isNull);
    });
    test('should infos be in start state', () {
      infos.now = DateTime.now();
      infos.start(direction, TransportType.Car);
      //
      expect(infos.cameraBounds.isPresent, isTrue);
      expect(infos.cameraBounds.value.isInBounds(point1), isTrue);
      expect(infos.cameraBounds.value.isInBounds(point5), isTrue);
      expect(infos.cameraBounds.value.isInBounds(point10), isTrue);
      expect(infos.cameraPosition.isPresent, isFalse);
      expect(infos.currentBearingDegree.round(), equals(0));
      expect(infos.currentMovement.isPresent, isFalse);
      expect(infos.currentPosition.isPresent, isFalse);
      expect(infos.currentSpeedMeterPerSeconds.round(), equals(0));
      expect(infos.currentStep.isPresent, isFalse);
      expect(infos.defaultAverageMeterSecond.round(),
          equals(CAR_METER_SECONDS.round().round()));
      expect(infos.direction.isPresent, isTrue);
      expect(infos.hasCurrentStep, isFalse);
      expect(infos.hasDirection, isTrue);
      expect(infos.hasMovement, isFalse);
      expect(infos.isFinished, isFalse);
      expect(infos.isNavigating, isTrue);
      expect(infos.lineAfter.isPresent, isTrue);
      expect(infos.lineBefore.isPresent, isTrue);
      expect(infos.meanMeterPerSeconds.round(), equals(0));
      expect(infos.nexStep.isPresent, isFalse);
      expect(infos.nbSegmentFounded, equals(0));
      expect(infos.nexStep.isPresent, isFalse);
      expect(infos.pastMetersInLine, equals(0));
      expect(infos.realPastMeters, equals(0));
      expect(infos.pastSeconds, equals(0));
      expect(infos.polyline.isPresent, isTrue);
      expect(infos.startedAt, isNotNull);
      expect(infos.state, equals(NavigationStateEnum.Navigating));
      expect(infos.stepRemainingMeters, equals(0));
      expect(infos.totalMeters, equals(direction.distanceInMeter));
      expect(infos.totalRemainingMeters, equals(direction.distanceInMeter));
      expect(infos.totalRemainingSeconds, equals(direction.travelTimeInSec));
      expect(infos.totalSeconds, equals(direction.travelTimeInSec));
      expect(infos.transportType, equals(TransportType.Car));
    });
    test('should go to point0', () {
      infos.now = infos.now.add(Duration(seconds: 10));
      infos.setCurrent(leCreusot);
      //14m/s par defaut * 60 sec => 840m
      expect(infos.cameraBounds.isPresent, isTrue);
      expect(infos.cameraBounds.value.isInBounds(point1), isTrue);
      expect(infos.cameraBounds.value.isInBounds(leCreusot), isTrue);
      expect(infos.cameraBounds.value.isInBounds(point10), isFalse);
      expect(infos.cameraBounds.value.isInBounds(point5), isFalse);
      expect(infos.cameraBounds.value.southToNorthMeters,
          moreOrLessEquals(840, epsilon: 10));
      //camera at 1/2 => 420m
      //position at 1/6 => 140m => more or less 300m between
      expect(infos.cameraPosition.isPresent, isTrue);
      expect(infos.cameraPosition.value.distanceInMeter(leCreusot),
          moreOrLessEquals(280, epsilon: 10));
      expect(infos.currentBearingDegree.round(), equals(0));
      expect(infos.currentMovement.isPresent, isTrue);
      expect(infos.currentPosition.isPresent, isTrue);
      expect(infos.currentSpeedMeterPerSeconds.round(), equals(0));
      expect(infos.currentStep.isPresent, isFalse);
      expect(infos.defaultAverageMeterSecond.round(),
          equals(CAR_METER_SECONDS.round().round()));
      expect(infos.direction.isPresent, isTrue);
      expect(infos.hasCurrentStep, isFalse);
      expect(infos.hasDirection, isTrue);
      expect(infos.hasMovement, isTrue);
      expect(infos.isFinished, isFalse);
      expect(infos.isNavigating, isTrue);
      expect(infos.lineAfter.isPresent, isTrue);
      expect(infos.lineBefore.isPresent, isTrue);
      expect(infos.meanMeterPerSeconds.round(), equals(0));
      expect(infos.nexStep.isPresent, isFalse);
      expect(infos.nbSegmentFounded, equals(0));
      expect(infos.nexStep.isPresent, isFalse);
      expect(infos.pastMetersInLine, equals(0));
      expect(infos.realPastMeters, equals(0));
      expect(infos.pastSeconds, equals(10));
      expect(infos.polyline.isPresent, isTrue);
      expect(infos.startedAt, isNotNull);
      expect(infos.state, equals(NavigationStateEnum.Navigating));
      expect(infos.stepRemainingMeters, equals(0));
      expect(infos.totalMeters, equals(direction.distanceInMeter));
      expect(infos.totalRemainingMeters, equals(direction.distanceInMeter));
      expect(infos.totalRemainingSeconds, equals(direction.travelTimeInSec));
      expect(infos.totalSeconds, equals(direction.travelTimeInSec));
      expect(infos.transportType, equals(TransportType.Car));
    });
    test('should set segment 0', () {
      //past 20 second since start and 10sec since last event
      //50/10 => 5m/s m/s instant => 300/min => 18km/h
      //50/20 => 2.5m/s m/s mean => 150/min => 9km/h
      //ponderate mean = 14.5km/h => 3.75m/s
      final metersDone = 50;
      final secondPast = 10;
      final point = leCreusot.transform(metersDone, 0);
      infos.now = infos.now.add(Duration(seconds: secondPast));
      final segment = finder.next(leCreusot.toVectorTime(point, secondPast));
      expect(segment.isPresent, isTrue);
      expect(segment.value.segmentIndex, equals(0));
      infos.setCurrent(point);
      infos.setCurrentSegment(segment.value);
      //3.75m/s * 60 sec => 225m
      //5m/s * 60 =>300
      expect(infos.cameraBounds.isPresent, isTrue);
      expect(infos.cameraBounds.value.southToNorthMeters,
          moreOrLessEquals(300, epsilon: 20));
      expect(infos.cameraBoundsMeters.value.toDouble(),
          moreOrLessEquals(300, epsilon: 40));
      // 50m to point1 200m to point 2
      expect(infos.cameraBounds.value.isInBounds(point1), isTrue);
      expect(infos.cameraBounds.value.isInBounds(point), isTrue);
      expect(infos.cameraBounds.value.isInBounds(point2), isFalse);
      expect(infos.cameraBounds.value.isInBounds(point6), isFalse);
      //camera at 1/2 => 150m
      //position at 1/6 => 50m => more or less 100m between camera and current position
      expect(infos.cameraPosition.isPresent, isTrue);
      expect(
          infos.cameraPosition.value
              .distanceInMeter(infos.currentPosition.value),
          moreOrLessEquals(100, epsilon: 10));
      expect(infos.cameraPosition.value.distanceInMeter(leCreusot),
          moreOrLessEquals((100.0 + metersDone), epsilon: 10));
      expect(infos.currentBearingDegree.round(), equals(0));
      expect(infos.currentMovement.isPresent, isTrue);
      expect(infos.currentPosition.isPresent, isTrue);
      expect(infos.currentSpeedMeterPerSeconds.round(), equals(5));
      expect(infos.currentStep.isPresent, isTrue);
      expect(infos.defaultAverageMeterSecond.round(),
          equals(CAR_METER_SECONDS.round().round()));
      expect(infos.direction.isPresent, isTrue);
      expect(infos.hasCurrentStep, isTrue);
      expect(infos.currentStep.value.instructions, equals("instructions0"));
      expect(infos.hasDirection, isTrue);
      expect(infos.hasMovement, isTrue);
      expect(infos.isFinished, isFalse);
      expect(infos.isNavigating, isTrue);
      expect(infos.lineAfter.isPresent, isTrue);
      //remove first point and replace by current position
      expect(infos.lineAfter.value.nbPoints, equals(polyline.nbPoints));
      expect(infos.lineBefore.isPresent, isTrue);
      expect(infos.lineBefore.value.nbPoints, equals(1));
      expect(infos.meanMeterPerSeconds.round(), equals(3));
      expect(infos.nbSegmentFounded, equals(1));
      expect(infos.nexStep.isPresent, isTrue);
      expect(infos.pastMetersInLine, equals(50));
      expect(infos.realPastMeters, equals(50));
      expect(infos.pastSeconds, equals(20));
      expect(infos.polyline.isPresent, isTrue);
      expect(infos.startedAt, isNotNull);
      expect(infos.state, equals(NavigationStateEnum.Navigating));
      expect(infos.stepRemainingMeters, equals(50));
      expect(infos.totalMeters, equals(direction.distanceInMeter));
      expect(
          infos.totalRemainingMeters, equals(direction.distanceInMeter - 50));
      //estimated 10m/s actual 50m/20s=>5m/s
      //20second past => 50m done so at 10m/s => 5sec consumed (in estimation)
      expect(
          infos.totalRemainingSeconds, equals(direction.travelTimeInSec - 5));
      expect(infos.totalSeconds, equals(direction.travelTimeInSec));
      expect(infos.transportType, equals(TransportType.Car));
    });
    test('should not found segment', () {
      //100m done from last point to new point
      //past 30 second since start and 10sec since last event
      //100/10 => 10m/s m/s instant => 600/min => 36km/h
      //150/30 => 5m/s mean => 300/min => 18km/h
      //ponderate mean = 32km/h => 8.75m/s
      final secondPast = 10;
      final point = leCreusot.transform(50, -180);
      infos.now = infos.now.add(Duration(seconds: secondPast));
      final segment = finder.next(leCreusot.toVectorTime(point, secondPast));
      expect(segment.isPresent, isFalse);
      infos.setCurrent(point);
      //8m/s * 60 sec => 525
      //10m/s * 60 => 600
      expect(infos.cameraBounds.isPresent, isTrue);
      expect(infos.cameraBounds.value.southToNorthMeters,
          moreOrLessEquals(600, epsilon: 20));
      expect(infos.cameraBoundsMeters.value.toDouble(),
          moreOrLessEquals(600, epsilon: 20));
      // 100m to point1 50m to point 0
      expect(infos.cameraBounds.value.isInBounds(leCreusot), isTrue);
      expect(infos.cameraBounds.value.isInBounds(point), isTrue);
      expect(infos.cameraBounds.value.isInBounds(point1), isFalse);
      //camera at 1/2 => 300m
      //position at 1/6 => 100m => more or less 200m between camera and current position
      expect(infos.cameraPosition.isPresent, isTrue);
      expect(
          infos.cameraPosition.value
              .distanceInMeter(infos.currentPosition.value),
          moreOrLessEquals(200, epsilon: 10));
      expect(infos.cameraPosition.value.distanceInMeter(leCreusot),
          moreOrLessEquals((200.0 + 50), epsilon: 10));
      expect(infos.cameraPosition.value.distanceInMeter(point1),
          moreOrLessEquals((200.0 + 50 + 100), epsilon: 10));
      expect(infos.currentBearingDegree.round(), equals(180));
      expect(infos.currentMovement.isPresent, isTrue);
      expect(infos.currentPosition.isPresent, isTrue);
      expect(infos.currentSpeedMeterPerSeconds.round(), equals(10));
      expect(infos.currentStep.isPresent, isTrue);
      expect(infos.defaultAverageMeterSecond.round(),
          equals(CAR_METER_SECONDS.round().round()));
      expect(infos.direction.isPresent, isTrue);
      expect(infos.hasCurrentStep, isTrue);
      expect(infos.currentStep.value.instructions, equals("instructions0"));
      expect(infos.hasDirection, isTrue);
      expect(infos.hasMovement, isTrue);
      expect(infos.isFinished, isFalse);
      expect(infos.isNavigating, isTrue);
      expect(infos.lineAfter.isPresent, isTrue);
      //remove first point and replace by current position
      expect(infos.lineAfter.value.nbPoints, equals(polyline.nbPoints));
      expect(infos.lineBefore.isPresent, isTrue);
      expect(infos.lineBefore.value.nbPoints, equals(1));
      expect(infos.meanMeterPerSeconds.round(), equals(5));
      expect(infos.nbSegmentFounded, equals(1));
      expect(infos.nexStep.isPresent, isTrue);
      expect(infos.pastMetersInLine, equals(50));
      expect(infos.realPastMeters, equals(150));
      expect(infos.pastSeconds, equals(30));
      expect(infos.polyline.isPresent, isTrue);
      expect(infos.startedAt, isNotNull);
      expect(infos.state, equals(NavigationStateEnum.Navigating));
      expect(infos.stepRemainingMeters, equals(50));
      expect(infos.totalMeters, equals(direction.distanceInMeter));
      expect(
          infos.totalRemainingMeters, equals(direction.distanceInMeter - 50));
      //estimated 10m/s actual 50m/20s=>5m/s
      //20second past => 50m done so at 10m/s => 5sec consumed (in estimation)
      expect(
          infos.totalRemainingSeconds, equals(direction.travelTimeInSec - 5));
      expect(infos.totalSeconds, equals(direction.travelTimeInSec));
      expect(infos.transportType, equals(TransportType.Car));
    });
    test('should go to point 3 (speed)', () {
      //625 done from last point to new point
      //past 40 second since start and 10sec since last event
      //625/10 => 62m/s instant => 3720/min => 223km/h
      //775/40 => 20m/s mean => 1200/min => 72km/h
      //ponderate mean = 185km/h => 51m/s
      final secondPast = 10;
      final point = point3;
      infos.now = infos.now.add(Duration(seconds: secondPast));
      final segment = finder.next(leCreusot.toVectorTime(point, secondPast));
      expect(segment.isPresent, isTrue);
      infos.setCurrent(point);
      infos.setCurrentSegment(segment.value);
      //51m/s * 60 sec => 3060
      // 62m/s instant => 3720/min
      expect(infos.cameraBounds.isPresent, isTrue);
      expect(infos.cameraBounds.value.maxDistanceMeters,
          moreOrLessEquals(3720, epsilon: 100));
      expect(infos.cameraBoundsMeters.value.toDouble(),
          moreOrLessEquals(3720, epsilon: 50));
      // 100m to point1 50m to point 0
      expect(infos.cameraBounds.value.isInBounds(leCreusot), isFalse);
      expect(infos.cameraBounds.value.isInBounds(point), isTrue);
      expect(infos.cameraBounds.value.isInBounds(point2), isTrue);
      expect(infos.cameraBounds.value.isInBounds(point3), isTrue);
      //camera at 1/2 => 1860
      //position at 1/6 => 620 => more or less 1240 between camera and current position
      expect(infos.cameraPosition.isPresent, isTrue);
      expect(
          infos.cameraPosition.value
              .distanceInMeter(infos.currentPosition.value),
          moreOrLessEquals(1240, epsilon: 20));
      expect(infos.cameraPosition.value.distanceInMeter(point2),
          moreOrLessEquals((1240.0 + 300), epsilon: 20));
      //degree is not 40 because we started from origin -50
      expect(infos.currentBearingDegree.round(), equals(25));
      expect(infos.currentMovement.isPresent, isTrue);
      expect(infos.currentPosition.isPresent, isTrue);
      expect(infos.currentSpeedMeterPerSeconds.round(), equals(62));
      expect(infos.currentStep.isPresent, isTrue);
      expect(infos.defaultAverageMeterSecond.round(),
          equals(CAR_METER_SECONDS.round().round()));
      expect(infos.direction.isPresent, isTrue);
      expect(infos.hasCurrentStep, isTrue);
      //instruction just before point 3
      expect(infos.currentStep.value.instructions, equals("instructions2"));
      expect(infos.hasDirection, isTrue);
      expect(infos.hasMovement, isTrue);
      expect(infos.isFinished, isFalse);
      expect(infos.isNavigating, isTrue);
      expect(infos.lineAfter.isPresent, isTrue);
      //remove point 0,1,2 but add current
      expect(infos.lineAfter.value.nbPoints, equals(polyline.nbPoints - 2));
      expect(infos.lineBefore.isPresent, isTrue);
      expect(infos.lineBefore.value.nbPoints, equals(3));
      expect(infos.meanMeterPerSeconds.round(), equals(19));
      expect(infos.nbSegmentFounded, equals(2));
      expect(infos.nexStep.isPresent, isTrue);
      //segment0(0 to 1)=100, segment1(1 to 2)=200, segment2(2 to 3)=300
      expect(infos.pastMetersInLine, equals(600));
      expect(infos.realPastMeters, equals(150 + 625));
      expect(infos.pastSeconds, equals(40));
      expect(infos.polyline.isPresent, isTrue);
      expect(infos.startedAt, isNotNull);
      expect(infos.state, equals(NavigationStateEnum.Navigating));
      expect(infos.stepRemainingMeters, equals(0));
      expect(infos.totalMeters, equals(direction.distanceInMeter));
      expect(
          infos.totalRemainingMeters, equals(direction.distanceInMeter - 600));
      //segment0 done => 10s,segment1=>20s, segment2=>30s => 60s
      expect(
          infos.totalRemainingSeconds, equals(direction.travelTimeInSec - 60));
      expect(infos.totalSeconds, equals(direction.travelTimeInSec));
      expect(infos.transportType, equals(TransportType.Car));
    });
    test('should found segment 3', () {
      //200 done from last point to new point
      //past 50 second since start and 10sec since last event
      //200/10 => 20m/s instant => 1200/min => 72km/h
      //975/50 => 19.5/s mean => 1170/min => 70km/h
      //ponderate mean = 71.5km/h => 19.9m/s
      final secondPast = 10;
      final point = point3.transform(200, 60);
      infos.now = infos.now.add(Duration(seconds: secondPast));
      final segment = finder.next(point3.toVectorTime(point, secondPast));
      expect(segment.isPresent, isTrue);
      infos.setCurrent(point);
      infos.setCurrentSegment(segment.value);
      //19.9m/s * 60 sec => 1194
      expect(infos.cameraBounds.isPresent, isTrue);
      expect(infos.cameraBounds.value.maxDistanceMeters,
          moreOrLessEquals(1194, epsilon: 30));
      //
      expect(infos.cameraBounds.value.isInBounds(leCreusot), isFalse);
      expect(infos.cameraBounds.value.isInBounds(point), isTrue);
      expect(infos.cameraBounds.value.isInBounds(point2), isFalse);
      expect(infos.cameraBounds.value.isInBounds(point3.transform(10, 60)),
          isTrue);
      expect(infos.cameraBounds.value.isInBounds(point4), isTrue);
      //camera at 1/2 => 597
      //position at 1/6 => 199 => more or less 398 between camera and current position
      expect(infos.cameraPosition.isPresent, isTrue);
      expect(
          infos.cameraPosition.value
              .distanceInMeter(infos.currentPosition.value),
          moreOrLessEquals(398, epsilon: 20));
      expect(infos.cameraPosition.value.distanceInMeter(point3),
          moreOrLessEquals((398.0 + 200), epsilon: 20));
      //
      expect(infos.currentBearingDegree.round(), equals(60));
      expect(infos.currentMovement.isPresent, isTrue);
      expect(infos.currentPosition.isPresent, isTrue);
      expect(infos.currentSpeedMeterPerSeconds.round(), equals(20));
      expect(infos.currentStep.isPresent, isTrue);
      expect(infos.defaultAverageMeterSecond.round(),
          equals(CAR_METER_SECONDS.round().round()));
      expect(infos.direction.isPresent, isTrue);
      expect(infos.hasCurrentStep, isTrue);
      //instruction just before point 3
      expect(infos.currentStep.value.instructions, equals("instructions3"));
      expect(infos.hasDirection, isTrue);
      expect(infos.hasMovement, isTrue);
      expect(infos.isFinished, isFalse);
      expect(infos.isNavigating, isTrue);
      expect(infos.lineAfter.isPresent, isTrue);
      //remove point 0,1,2,3 but add current
      expect(infos.lineAfter.value.nbPoints, equals(polyline.nbPoints - 3));
      expect(infos.lineBefore.isPresent, isTrue);
      expect(infos.lineBefore.value.nbPoints, equals(4));
      expect(infos.meanMeterPerSeconds.round(), equals(20));
      expect(infos.nbSegmentFounded, equals(3));
      expect(infos.nexStep.isPresent, isTrue);
      //segment0(0 to 1)=100, segment1(1 to 2)=200, segment2(2 to 3)=300 + 200
      expect(infos.pastMetersInLine, equals(800));
      expect(infos.realPastMeters, equals(150 + 625 + 200));
      expect(infos.pastSeconds, equals(50));
      expect(infos.polyline.isPresent, isTrue);
      expect(infos.startedAt, isNotNull);
      expect(infos.state, equals(NavigationStateEnum.Navigating));
      expect(infos.stepRemainingMeters, equals(200));
      expect(infos.totalMeters, equals(direction.distanceInMeter));
      expect(
          infos.totalRemainingMeters, equals(direction.distanceInMeter - 800));
      //segment0 done => 10s,segment1=>20s, segment2=>30s => 60s + half of step
      expect(infos.totalRemainingSeconds,
          equals(direction.travelTimeInSec - 60 - 20));
      expect(infos.totalSeconds, equals(direction.travelTimeInSec));
      expect(infos.transportType, equals(TransportType.Car));
    });
    test('should go in same place', () {
      //0 done from last point to new point
      //past 60 second since start and 10sec since last event
      //0/10 => 0m/s instant => 0/min => 0km/h
      //975/60 => 16.25/s mean => 975/min => 58.5km/h
      //ponderate mean = 14.6km/h => 4m/s
      //instant is 0 so => 14m/s par defaut * 60 sec => 840m
      final secondPast = 10;
      final point = point3.transform(200, 60);
      infos.now = infos.now.add(Duration(seconds: secondPast));
      final segment = finder.next(point3.toVectorTime(point, secondPast));
      expect(segment.isPresent, isTrue);
      infos.setCurrent(point);
      infos.setCurrentSegment(segment.value);
      //0m/s
      expect(infos.cameraBounds.isPresent, isTrue);
      expect(infos.cameraBounds.value.maxDistanceMeters,
          moreOrLessEquals(0, epsilon: 20));
      expect(infos.cameraBoundsMeters.value.toDouble(),
          moreOrLessEquals(0, epsilon: 20));
      //
      expect(infos.cameraBounds.value.isInBounds(leCreusot), isFalse);
      expect(infos.cameraBounds.value.isInBounds(point), isTrue);
      expect(infos.cameraBounds.value.isInBounds(point2), isFalse);
      //camera at 1/2 => 420
      //position at 1/6 => 140 => more or less 280 between camera and current position
      expect(infos.cameraPosition.isPresent, isTrue);
      expect(
          infos.cameraPosition.value
              .distanceInMeter(infos.currentPosition.value),
          moreOrLessEquals(0, epsilon: 20));
      expect(infos.cameraPosition.value.distanceInMeter(point3),
          moreOrLessEquals((0.0 + 200), epsilon: 20));
      //
      expect(infos.currentBearingDegree.round(), equals(60));
      expect(infos.currentMovement.isPresent, isTrue);
      expect(infos.currentPosition.isPresent, isTrue);
      expect(infos.currentSpeedMeterPerSeconds.round(), equals(0));
      expect(infos.currentStep.isPresent, isTrue);
      expect(infos.defaultAverageMeterSecond.round(),
          equals(CAR_METER_SECONDS.round().round()));
      expect(infos.direction.isPresent, isTrue);
      expect(infos.hasCurrentStep, isTrue);
      //instruction just before point 3
      expect(infos.currentStep.value.instructions, equals("instructions3"));
      expect(infos.hasDirection, isTrue);
      expect(infos.hasMovement, isTrue);
      expect(infos.isFinished, isFalse);
      expect(infos.isNavigating, isTrue);
      expect(infos.lineAfter.isPresent, isTrue);
      //remove point 0,1,2,3 but add current
      expect(infos.lineAfter.value.nbPoints, equals(polyline.nbPoints - 3));
      expect(infos.lineBefore.isPresent, isTrue);
      expect(infos.lineBefore.value.nbPoints, equals(4));
      expect(infos.meanMeterPerSeconds.round(), equals(16));
      expect(infos.nbSegmentFounded, equals(4));
      expect(infos.nexStep.isPresent, isTrue);
      //segment0(0 to 1)=100, segment1(1 to 2)=200, segment2(2 to 3)=300 + 200
      expect(infos.pastMetersInLine, equals(800));
      expect(infos.realPastMeters, equals(150 + 625 + 200));
      expect(infos.pastSeconds, equals(60));
      expect(infos.polyline.isPresent, isTrue);
      expect(infos.startedAt, isNotNull);
      expect(infos.state, equals(NavigationStateEnum.Navigating));
      expect(infos.stepRemainingMeters, equals(200));
      expect(infos.totalMeters, equals(direction.distanceInMeter));
      expect(
          infos.totalRemainingMeters, equals(direction.distanceInMeter - 800));
      //segment0 done => 10s,segment1=>20s, segment2=>30s => 60s + half of step
      expect(infos.totalRemainingSeconds,
          equals(direction.travelTimeInSec - 60 - 20));
      expect(infos.totalSeconds, equals(direction.travelTimeInSec));
      expect(infos.transportType, equals(TransportType.Car));
    });
    test('should go back to point2', () {
      // done 492m => 49m/s => instant speed => 3000/min
      //975+492m/70 => 1467/70 => 21m/s mean
      //ponderate mean = 0.75*49+0.25*21 => 42m/s
      // 60*42=2520m en 60sec
      final secondPast = 10;
      final oldPoint = point3.transform(200, 60);
      infos.now = infos.now.add(Duration(seconds: secondPast));
      final vector = oldPoint.toVectorTime(point2, secondPast);
      final segment = finder.next(vector);
      expect(segment.isPresent, isTrue);
      infos.setCurrent(point2);
      infos.setCurrentSegment(segment.value);
      //
      expect(infos.cameraBounds.isPresent, isTrue);
      expect(infos.cameraBounds.value.maxDistanceMeters,
          moreOrLessEquals(3000, epsilon: 50));
      expect(infos.cameraBoundsMeters.value.toDouble(),
          moreOrLessEquals(3000, epsilon: 50));
      //
      expect(infos.cameraBounds.value.isInBounds(point2), isTrue);
      expect(infos.cameraBounds.value.isInBounds(point3), isTrue);
      expect(infos.cameraBounds.value.isInBounds(point4), isFalse);
      //camera at 1/2 => 1500
      //position at 1/6 => 500 => more or less 1000 between camera and current position
      expect(infos.cameraPosition.isPresent, isTrue);
      expect(
          infos.cameraPosition.value
              .distanceInMeter(infos.currentPosition.value),
          moreOrLessEquals(1000, epsilon: 20));
      expect(infos.cameraPosition.value.distanceInMeter(point3),
          moreOrLessEquals((1000.0 + 300), epsilon: 20));
      //
      expect(infos.currentBearingDegree.round(), equals(-132));
      expect(infos.currentMovement.isPresent, isTrue);
      expect(infos.currentPosition.isPresent, isTrue);
      expect(infos.currentSpeedMeterPerSeconds.round(), equals(49));
      expect(infos.currentStep.isPresent, isTrue);
      expect(infos.defaultAverageMeterSecond.round(),
          equals(CAR_METER_SECONDS.round().round()));
      expect(infos.direction.isPresent, isTrue);
      expect(infos.hasCurrentStep, isTrue);
      //instruction just before point 3
      expect(infos.currentStep.value.instructions, equals("instructions2"));
      expect(infos.hasDirection, isTrue);
      expect(infos.hasMovement, isTrue);
      expect(infos.isFinished, isFalse);
      expect(infos.isNavigating, isTrue);
      expect(infos.lineAfter.isPresent, isTrue);
      //remove point 0,1,2
      expect(infos.lineAfter.value.nbPoints, equals(polyline.nbPoints - 3));
      expect(infos.lineBefore.isPresent, isTrue);
      //0,1,current
      expect(infos.lineBefore.value.nbPoints, equals(2));
      expect(infos.meanMeterPerSeconds.round(), equals(21));
      expect(infos.nbSegmentFounded, equals(5));
      expect(infos.nexStep.isPresent, isTrue);
      //segment0(0 to 1)=100, segment1(1 to 2)=200
      expect(infos.pastMetersInLine, equals(300));
      expect(infos.realPastMeters * 1.0,
          moreOrLessEquals(150 + 625 + 200 + 492.0, epsilon: 1));
      expect(infos.pastSeconds, equals(70));
      expect(infos.polyline.isPresent, isTrue);
      expect(infos.startedAt, isNotNull);
      expect(infos.state, equals(NavigationStateEnum.Navigating));
      expect(infos.stepRemainingMeters, equals(300));
      expect(infos.totalMeters, equals(direction.distanceInMeter));
      expect(
          infos.totalRemainingMeters, equals(direction.distanceInMeter - 300));
      //segment0 done => 10s,segment1=>20s
      expect(
          infos.totalRemainingSeconds, equals(direction.travelTimeInSec - 30));
      expect(infos.totalSeconds, equals(direction.travelTimeInSec));
      expect(infos.transportType, equals(TransportType.Car));
    });
    test('should go to before last point', () {
      //done 2630 in 60sec => 44m/s => 44*60=>2640/min
      //975+492+2630/70+60 => 4097/130 => 31.5m/s mean
      //ponderate mean = 0.75*51+0.25*35 => 40.9m/s
      // 60*40.9=2454m en 60sec
      final secondPast = 60;
      final oldPoint = point2;
      infos.now = infos.now.add(Duration(seconds: secondPast));
      final vector = oldPoint.toVectorTime(point9, secondPast);
      final segment = finder.next(vector);
      expect(segment.isPresent, isTrue);
      infos.setCurrent(point9);
      infos.setCurrentSegment(segment.value);
      //
      expect(infos.cameraBounds.isPresent, isTrue);
      expect(infos.cameraBounds.value.maxDistanceMeters,
          moreOrLessEquals(2640, epsilon: 20));
      expect(infos.cameraBoundsMeters.value.toDouble(),
          moreOrLessEquals(2640, epsilon: 20));
      //
      expect(infos.cameraBounds.value.isInBounds(oldPoint), isFalse);
      expect(infos.cameraBounds.value.isInBounds(point7), isFalse);
      expect(infos.cameraBounds.value.isInBounds(point8), isFalse);
      expect(infos.cameraBounds.value.isInBounds(point9), isTrue);
      //camera at 1/2 => 1320
      //position at 1/6 => 440 => more or less 880 between camera and current position
      expect(infos.cameraPosition.isPresent, isTrue);
      expect(
          infos.cameraPosition.value
              .distanceInMeter(infos.currentPosition.value),
          moreOrLessEquals(880, epsilon: 20));
      //
      expect(infos.currentBearingDegree.round(), equals(-113));
      expect(infos.currentMovement.isPresent, isTrue);
      expect(infos.currentPosition.isPresent, isTrue);
      expect(infos.currentSpeedMeterPerSeconds.round(), equals(44));
      expect(infos.currentStep.isPresent, isTrue);
      expect(infos.defaultAverageMeterSecond.round(),
          equals(CAR_METER_SECONDS.round().round()));
      expect(infos.direction.isPresent, isTrue);
      expect(infos.hasCurrentStep, isTrue);
      //instruction just before point 3
      expect(infos.currentStep.value.instructions, equals("instructions8"));
      expect(infos.hasDirection, isTrue);
      expect(infos.hasMovement, isTrue);
      expect(infos.isFinished, isFalse);
      expect(infos.isNavigating, isTrue);
      expect(infos.lineAfter.isPresent, isTrue);
      //remove point 0,1,2,3,4,5,6,7,8 but add current
      expect(infos.lineAfter.value.nbPoints, equals(polyline.nbPoints - 9));
      expect(infos.lineBefore.isPresent, isTrue);
      expect(infos.lineBefore.value.nbPoints, equals(8));
      expect(infos.meanMeterPerSeconds.round(), equals(32));
      expect(infos.nbSegmentFounded, equals(6));
      expect(infos.nexStep.isPresent, isTrue);
      //segment0(0 to 1)=100, segment1(1 to 2)=200,300,400,500
      expect(infos.pastMetersInLine,
          equals(100 + 200 + 300 + 400 + 500 + 600 + 700 + 800 + 900));
      expect(infos.realPastMeters * 1.0,
          moreOrLessEquals(975 + 492.0 + 2630.0, epsilon: 2));
      expect(infos.pastSeconds, equals(70 + 60));
      expect(infos.polyline.isPresent, isTrue);
      expect(infos.startedAt, isNotNull);
      expect(infos.state, equals(NavigationStateEnum.Navigating));
      expect(infos.stepRemainingMeters, equals(0));
      expect(infos.totalMeters, equals(direction.distanceInMeter));
      expect(
          infos.totalRemainingMeters,
          equals(direction.distanceInMeter -
              (100 + 200 + 300 + 400 + 500 + 600 + 700 + 800 + 900)));
      //segment0 done => 10s,segment1=>20s
      expect(
          infos.totalRemainingSeconds,
          equals(direction.travelTimeInSec -
              (10 + 20 + 30 + 40 + 50 + 60 + 70 + 80 + 90)));
      expect(infos.totalSeconds, equals(direction.travelTimeInSec));
      expect(infos.transportType, equals(TransportType.Car));
    });
    test('should go last segment', () {
      //done 500 in 10sec => 50m/s => 50*60=3000/min
      //(975+492+2630+500)/(70+60+10) => 33m/s mean
      //ponderate mean = (0.75*50)+(0.25*33) => 45.8m/s
      // 60*45.8=2748m en 60sec
      final secondPast = 10;
      final newPoint = point9.transform(500, -160);
      infos.now = infos.now.add(Duration(seconds: secondPast));
      final vector = point9.toVectorTime(newPoint, secondPast);
      final segment = finder.next(vector);
      expect(segment.isPresent, isTrue);
      infos.setCurrent(newPoint);
      infos.setCurrentSegment(segment.value);
      //
      expect(infos.cameraBounds.isPresent, isTrue);
      expect(infos.cameraBounds.value.maxDistanceMeters,
          moreOrLessEquals(3000, epsilon: 40));
      expect(infos.cameraBoundsMeters.value.toDouble(),
          moreOrLessEquals(3000, epsilon: 20));
      //
      expect(infos.cameraBounds.value.isInBounds(point8), isFalse);
      expect(infos.cameraBounds.value.isInBounds(point9), isFalse);
      expect(infos.cameraBounds.value.isInBounds(newPoint), isTrue);
      expect(infos.cameraBounds.value.isInBounds(point10), isTrue);
      //camera at 3000*1/2 => 1500
      //position at 3000*1/6 => 500 => more or less 1000 between camera and current position
      expect(infos.cameraPosition.isPresent, isTrue);
      expect(
          infos.cameraPosition.value
              .distanceInMeter(infos.currentPosition.value),
          moreOrLessEquals(1000, epsilon: 20));
      //pt9->(500m)current->(500m)pt10->(416m)camera
      expect(infos.cameraPosition.value.distanceInMeter(point10),
          moreOrLessEquals((500 + 1000.0 - 1000), epsilon: 20));
      //
      expect(infos.currentBearingDegree.round(), equals(-160));
      expect(infos.currentMovement.isPresent, isTrue);
      expect(infos.currentPosition.isPresent, isTrue);
      expect(infos.currentSpeedMeterPerSeconds.round(), equals(50));
      expect(infos.currentStep.isPresent, isTrue);
      expect(infos.defaultAverageMeterSecond.round(),
          equals(CAR_METER_SECONDS.round().round()));
      expect(infos.direction.isPresent, isTrue);
      expect(infos.hasCurrentStep, isTrue);
      //instruction just before point 3
      expect(infos.currentStep.value.instructions, equals("instructions9"));
      expect(infos.hasDirection, isTrue);
      expect(infos.hasMovement, isTrue);
      expect(infos.isFinished, isFalse);
      expect(infos.isNavigating, isTrue);
      expect(infos.lineAfter.isPresent, isTrue);
      //current and last
      expect(infos.lineAfter.value.nbPoints, equals(2));
      expect(infos.lineBefore.isPresent, isTrue);
      //0 to 9 + current
      expect(infos.lineBefore.value.nbPoints, equals(polyline.nbPoints - 1));
      expect(infos.meanMeterPerSeconds.round(), equals(33));
      expect(infos.nbSegmentFounded, equals(7));
      expect(infos.nexStep.isPresent, isFalse);
      //segment0(0 to 1)=100, segment1(1 to 2)=200
      expect(infos.pastMetersInLine,
          equals(100 + 200 + 300 + 400 + 500 + 600 + 700 + 800 + 900 + 500));
      expect(infos.realPastMeters * 1.0,
          moreOrLessEquals(975.0 + 492 + 2630 + 500, epsilon: 2));
      expect(infos.pastSeconds, equals(140));
      expect(infos.polyline.isPresent, isTrue);
      expect(infos.startedAt, isNotNull);
      expect(infos.state, equals(NavigationStateEnum.Navigating));
      expect(infos.stepRemainingMeters, equals(500));
      expect(infos.totalMeters, equals(direction.distanceInMeter));
      expect(infos.totalRemainingMeters, equals(500));
      //segment0 done => 10s,segment1=>20s
      expect(
          infos.totalRemainingSeconds,
          equals(direction.travelTimeInSec -
              (10 + 20 + 30 + 40 + 50 + 60 + 70 + 80 + 90 + 50)));
      expect(infos.totalSeconds, equals(direction.travelTimeInSec));
      expect(infos.transportType, equals(TransportType.Car));
    });
    test('should go to near last point (finish)', () {
      //done 499 in 10sec => 50m/s => 3000/min
      //(975+492+2630+500+499)/(70+60+10+10) => 34m/s mean
      //ponderate mean = (0.75*50)+(0.25*34) => 46m/s
      // 60*46=2760 m en 60sec
      final secondPast = 10;
      final oldPoint = point9.transform(500, -160);
      final newPoint = oldPoint.transform(499, -160);
      infos.now = infos.now.add(Duration(seconds: secondPast));
      final vector = oldPoint.toVectorTime(newPoint, secondPast);
      final segment = finder.next(vector);
      expect(segment.isPresent, isTrue);
      infos.setCurrent(newPoint);
      infos.setCurrentSegment(segment.value);
      //
      expect(infos.cameraBounds.isPresent, isTrue);
      expect(infos.cameraBounds.value.maxDistanceMeters,
          moreOrLessEquals(3000, epsilon: 50));
      expect(infos.cameraBoundsMeters.value.toDouble(),
          moreOrLessEquals(3000, epsilon: 20));
      //
      expect(infos.cameraBounds.value.isInBounds(point8), isFalse);
      expect(infos.cameraBounds.value.isInBounds(point9), isFalse);
      expect(infos.cameraBounds.value.isInBounds(oldPoint), isFalse);
      expect(infos.cameraBounds.value.isInBounds(newPoint), isTrue);
      expect(infos.cameraBounds.value.isInBounds(point10), isTrue);
      //camera at 3000/2 => 1500
      //position at 3000*1/6 => 500 => more or less 1000 between camera and current position
      expect(infos.cameraPosition.isPresent, isTrue);
      expect(
          infos.cameraPosition.value
              .distanceInMeter(infos.currentPosition.value),
          moreOrLessEquals(1000, epsilon: 20));
      //current->(1m)pt10->(460m)camera
      expect(infos.cameraPosition.value.distanceInMeter(point10),
          moreOrLessEquals(1000, epsilon: 20));
      //
      expect(infos.currentBearingDegree.round(), equals(-160));
      expect(infos.currentMovement.isPresent, isTrue);
      expect(infos.currentPosition.isPresent, isTrue);
      expect(infos.currentSpeedMeterPerSeconds.round(), equals(50));
      expect(infos.currentStep.isPresent, isTrue);
      expect(infos.defaultAverageMeterSecond.round(),
          equals(CAR_METER_SECONDS.round().round()));
      expect(infos.direction.isPresent, isTrue);
      expect(infos.hasCurrentStep, isTrue);
      //instruction just before point 3
      expect(infos.currentStep.value.instructions, equals("instructions9"));
      expect(infos.hasDirection, isTrue);
      expect(infos.hasMovement, isTrue);
      expect(infos.isFinished, isTrue);
      expect(infos.isNavigating, isFalse);
      expect(infos.lineAfter.isPresent, isTrue);
      //current and last
      expect(infos.lineAfter.value.nbPoints, equals(2));
      expect(infos.lineBefore.isPresent, isTrue);
      //0 to 9 + current
      expect(infos.lineBefore.value.nbPoints, equals(polyline.nbPoints - 1));
      expect(infos.meanMeterPerSeconds.round(), equals(34));
      expect(infos.nbSegmentFounded, equals(8));
      expect(infos.nexStep.isPresent, isFalse);
      //segment0(0 to 1)=100, segment1(1 to 2)=200
      expect(infos.pastMetersInLine,
          equals(100 + 200 + 300 + 400 + 500 + 600 + 700 + 800 + 900 + 999));
      expect(infos.realPastMeters * 1.0,
          moreOrLessEquals(975.0 + 492 + 2630 + 999, epsilon: 2));
      expect(infos.pastSeconds, equals(150));
      expect(infos.polyline.isPresent, isTrue);
      expect(infos.startedAt, isNotNull);
      expect(infos.state, equals(NavigationStateEnum.Arrived));
      expect(infos.stepRemainingMeters, equals(1));
      expect(infos.totalMeters, equals(direction.distanceInMeter));
      expect(infos.totalRemainingMeters, equals(1));
      //segment0 done => 10s,segment1=>20s
      expect(infos.totalRemainingSeconds, equals(0));
      expect(infos.totalSeconds, equals(direction.travelTimeInSec));
      expect(infos.transportType, equals(TransportType.Car));
    });
    test('should restart navigation', () {
      //infos from positions
      infos.now = DateTime.now();
      infos.start(direction, TransportType.Car);
      //
      expect(infos.cameraBounds.isPresent, isTrue);
      expect(infos.cameraBounds.value.isInBounds(point1), isTrue);
      expect(infos.cameraBounds.value.isInBounds(point5), isTrue);
      expect(infos.cameraBounds.value.isInBounds(point10), isTrue);
      expect(infos.cameraPosition.isPresent, isFalse);
      expect(infos.currentBearingDegree.round(), equals(0));
      expect(infos.currentMovement.isPresent, isFalse);
      expect(infos.currentPosition.isPresent, isFalse);
      expect(infos.currentSpeedMeterPerSeconds.round(), equals(0));
      expect(infos.currentStep.isPresent, isFalse);
      expect(infos.defaultAverageMeterSecond.round(),
          equals(CAR_METER_SECONDS.round().round()));
      expect(infos.direction.isPresent, isTrue);
      expect(infos.hasCurrentStep, isFalse);
      expect(infos.hasDirection, isTrue);
      expect(infos.hasMovement, isFalse);
      expect(infos.isFinished, isFalse);
      expect(infos.isNavigating, isTrue);
      expect(infos.lineAfter.isPresent, isTrue);
      expect(infos.lineBefore.isPresent, isTrue);
      expect(infos.meanMeterPerSeconds.round(), equals(0));
      expect(infos.nexStep.isPresent, isFalse);
      expect(infos.nbSegmentFounded, equals(0));
      expect(infos.nexStep.isPresent, isFalse);
      expect(infos.pastMetersInLine, equals(0));
      expect(infos.realPastMeters, equals(0));
      expect(infos.pastSeconds, equals(0));
      expect(infos.polyline.isPresent, isTrue);
      expect(infos.startedAt, isNotNull);
      expect(infos.state, equals(NavigationStateEnum.Navigating));
      expect(infos.stepRemainingMeters, equals(0));
      expect(infos.totalMeters, equals(direction.distanceInMeter));
      expect(infos.totalRemainingMeters, equals(direction.distanceInMeter));
      expect(infos.totalRemainingSeconds, equals(direction.travelTimeInSec));
      expect(infos.totalSeconds, equals(direction.travelTimeInSec));
      expect(infos.transportType, equals(TransportType.Car));
    });
  });
}
