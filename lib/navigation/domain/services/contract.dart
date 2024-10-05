import 'dart:async';
import 'package:optional/optional.dart';
import 'package:rxdart/rxdart.dart';
import 'package:meta/meta.dart';
import '../geo/geo.dart';
import 'navigation_infos/navigation_infos.dart';

abstract class Place {
  String get name;
  String get country;
  String get url;
  String get formattedAddress;
  String get imageUrl;
  String get phone;
  Point get coordinate;
}

abstract class DirectionStep {
  //
  int _cacheMetersBegin;
  int _cacheMetersEnd;
  int _cacheSecondsBegin;
  int _cacheSecondsEnd;
  //
  int get distanceMeters;
  int get durationSeconds;
  String get instructions;
  String get manoeuvreType;
  String getImageUrl({String hexColor});
  bool get hasNext => next.isPresent;
  bool get hasPrevious => previous.isPresent;
  Optional<DirectionStep> get next;
  Optional<DirectionStep> get previous;
  bool get hasDistanceMeters => distanceMeters != null;
  int computeMetersToBegin(bool includeCurrent) {
    if (_cacheMetersBegin == null) {
      _cacheMetersBegin = 0;
      DirectionStep current = this;
      while (current.hasPrevious) {
        current = current.previous.value;
        _cacheMetersBegin += current.distanceMeters;
      }
    }
    return includeCurrent
        ? _cacheMetersBegin + distanceMeters
        : _cacheMetersBegin;
  }

  int computeMetersToEnd(bool includeCurrent) {
    if (_cacheMetersEnd == null) {
      _cacheMetersEnd = 0;
      DirectionStep current = this;
      while (current.hasNext) {
        current = current.next.value;
        _cacheMetersEnd += current.distanceMeters;
      }
    }
    return includeCurrent ? _cacheMetersEnd + distanceMeters : _cacheMetersEnd;
  }

  int computeSecondsToBegin(bool includeCurrent) {
    if (_cacheSecondsBegin == null) {
      _cacheSecondsBegin = 0;
      DirectionStep current = this;
      while (current.hasPrevious) {
        current = current.previous.value;
        _cacheSecondsBegin += current.durationSeconds;
      }
    }
    return includeCurrent
        ? _cacheSecondsBegin + durationSeconds
        : _cacheSecondsBegin;
  }

  int computeSecondsToEnd(bool includeCurrent) {
    if (_cacheSecondsEnd == null) {
      _cacheSecondsEnd = 0;
      DirectionStep current = this;
      while (current.hasNext) {
        current = current.next.value;
        _cacheSecondsEnd += current.durationSeconds;
      }
    }
    return includeCurrent
        ? _cacheSecondsEnd + durationSeconds
        : _cacheSecondsEnd;
  }
}

abstract class Direction {
  int get distanceInMeter;
  int get travelTimeInSec;
  PolyLine get polyline;
  int get stepsCount;
  Optional<DirectionStep> stepForIndex({@required int indexOfPoint});
}

abstract class DirectionCompatible {
  Direction toDirection();
}

abstract class PositionListenerEvent {
  int get count;
  Point get coordinate;
  get first => count == 0;
  DateTime get timestamp;
  double get accuracyMeter;
  double get altitudeMeter;
  double get headingDegree;
  double get speedMeterSecond;
  double get speedAccuracyMeterSecond;
  String toString() {
    return "Point=$coordinate";
  }
}

abstract class PositionListener {
  bool get listening;
  Observable<PositionListenerEvent> get onChange;
  Future<bool> stop();
  Future<bool> start();
  void dispose();
}

enum NavigationStateEnum { Idle, Preparing, Navigating, Arrived, NotFound }

abstract class Navigation {
  Observable<NavigationInfos> get onChanges;
  Future<void> restart();
  Future<void> start({@required Point from, @required Point to});
  void stop();
  void dispose();
}

abstract class NavigationService {
  Future<List<Place>> searchPlaces(String search);
  Future<Optional<Direction>> fetchDirection(
      {@required Point from, @required Point to, @required TransportType type});
  Future<PositionListener> listenPositionChanges();
  Navigation createNavigation();
}
