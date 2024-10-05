import 'dart:io';
import 'dart:convert' as JSON;
import 'dart:async';
import 'package:meta/meta.dart';
import 'package:optional/optional.dart';
import 'package:flutter_test/flutter_test.dart';
import '../position_simulated.dart';
import '../services.dart';

class _Logs {
  static final enableDump = true;
  static final enableMetrics = true;
  static final enableLog = true;
  static final enableLogFinder = true;
  static final enableLogLine = true;
  static final dumpLine = File('output/creusot_montceau.line.txt');
  static final dumpFile = File('output/creusot_montceau.dump.json');
  static final logFile = File('output/creusot_montceau.log.txt');
  static final metricsOverTime = File('output/creusot_montceau.metrics.csv');
  static final finderOverTime = File('output/finder.txt');
  static int _logCount = 0;
  static int _metricsCount = 0;
  static int _finderCount = 0;
  static int _lineCount = 0;
  static log(
      {int count,
      int countFailed,
      Duration fromStart,
      NavigationDump dump,
      NavigationInfos infos}) {
    if (!enableLog) return;
    if (_logCount == 0) {
      logFile.writeAsStringSync("");
    }
    _logCount++;
    logFile.writeAsStringSync("""
########################################################
Count: count=$count / countFailed=$countFailed / diff=${fromStart.inMilliseconds}
Data: $infos
Dump: $dump
""", mode: FileMode.writeOnlyAppend, flush: true);
  }

  static logLine(Duration fromStart, PolyLine line, Optional<Point> point) {
    if (!enableLogLine) return;
    if (_lineCount == 0) {
      dumpLine.writeAsStringSync("");
    }
    _lineCount++;
    dumpLine.writeAsStringSync(
        "${fromStart.inMilliseconds};${point.orElse(null)?.toString()}\n\t${line.jsGoogleMap}\n",
        mode: FileMode.writeOnlyAppend,
        flush: true);
  }

  static logFinder(Duration fromStart, NavigationImpl navigation) {
    if (!enableLogFinder) return;
    if (_finderCount == 0) {
      finderOverTime.writeAsStringSync("");
    }
    _finderCount++;
    final finder = navigation.finder.orElse(null);
    finderOverTime.writeAsStringSync(
        "${fromStart.inMilliseconds};${fromStart.inSeconds};${fromStart.inMinutes};${finder?.toString()}\n",
        mode: FileMode.writeOnlyAppend,
        flush: true);
  }

  static logMetrics(
      {Duration fromStart, NavigationDump dump, NavigationInfos infos}) {
    if (!enableMetrics) return;
    if (_metricsCount == 0) {
      metricsOverTime.writeAsStringSync(
          "DurationMS;DurationSec;DurationMin;Zoom;Bearing;BoundsMeters;SmoothSpeed;PastMeterLine;RealPastMeter;TotalRemainingMeter;CurrentSPeed;SegmentIndex\n");
    }
    _metricsCount++;
    metricsOverTime.writeAsStringSync(
        "${fromStart.inMilliseconds};${fromStart.inSeconds};${fromStart.inMinutes};${dump.zoom};${dump.bearing};${infos.cameraBoundsMeters.orElse(0)};${infos.currentSmoothSpeed.orElse(0)};${infos.pastMetersInLine};${infos.realPastMeters};${infos.totalRemainingMeters};${infos.currentSpeedMeterPerSeconds}${infos.lastKnownSegment?.segmentIndex ?? -1}\n",
        mode: FileMode.writeOnlyAppend,
        flush: true);
  }

  static dump(List<NavigationDump> dumps) {
    if (!enableDump) return;
    final json = JSON.jsonEncode(dumps.map((f) => f.toJson()).toList());
    dumpFile.writeAsStringSync(json);
  }
}

class _MockNavigationService
    with GeolocationSimulatedListener
    implements NavigationService {
  final config = NavigationInfosConfig(secondsWindow: 30);
  var directionFile = File('output/creusot_montceau.json');
  Optional<Direction> _direction;
  Future<List<Place>> searchPlaces(String search) {
    return Future.value([]);
  }

  Future<Optional<Direction>> fetchDirection(
      {@required Point from,
      @required Point to,
      @required TransportType type}) async {
    if (_direction != null) return _direction;
    final jsonText = await directionFile.readAsString();
    final json = JSON.jsonDecode(jsonText);
    final direction = DirectionMapKit.fromRoutes(json);
    _direction = Optional.of(direction);
    return _direction;
  }

  createSimulator() async {
    final direction =
        await fetchDirection(from: null, to: null, type: TransportType.Car);
    final meters = direction.value.distanceInMeter;
    final speedMetersPerSecond = meters / 5;
    //try to do it in 5s (mean=>10s)
    //20/second => 10*20=>200 times
    final speed =
        SpeedProviderProportionnal(speedMetersPerSecond, initialSpeed: 1);
    return Simulator.fromSpeed(direction.value.polyline,
        speed: speed, totalMeters: meters);
  }

  Navigation createNavigation() {
    return NavigationImpl(service: this, config: config);
  }
}

class _MockNavigationForRealTestService extends _MockNavigationService {
  final speed = MockNavigationService.kSpeed200;
  Navigation createNavigation() {
    return NavigationImpl(
        service: this,
        config: NavigationInfosConfig(
            secondsWindow: MockNavigationService.kWindowSeconds,
            zoomRoundStep: 0));
  }

  createSimulator() async {
    final direction =
        await fetchDirection(from: null, to: null, type: TransportType.Car);
    final meters = direction.value.distanceInMeter;
    return Simulator.fromSpeed(direction.value.polyline,
        speed: speed, totalMeters: meters, hertz: MockNavigationService.kHertz);
  }
}

unitTestNavigation() {
  //
  group("[Navigation]", () {
    final leCreusot = Point(46.8, 4.4333);
    final montceau = Point(46.6667, 4.3667);
    final List<Point> points = [];
    final List<int> remainMeters = [];
    PolyLine line;
/*
    test('should start navigation', () async {
      final navigationService = _MockNavigationService();
      final navigation = navigationService.createNavigation();
      int index = 0;
      Completer onFinish = Completer();
      navigation.onChanges.listen((onData) {
        if (onData.currentPosition.isPresent) {
          points.add(onData.currentPosition.value);
        }
        line = onData.direction.value.polyline;
        remainMeters.add(onData.totalRemainingMeters);
        //print("$index: " + onData.toString());
        index++;
        if (onData.isFinished) onFinish.complete(true);
      });
      print("starting");
      await navigation.start(
        from: leCreusot,
        to: montceau,
      );
      print("started");
      await onFinish.future;
      print("finished");
      expect(index, equals(200));
    });
    test('should have all points in line', () {
      expect(points.length, equals(200));
      for (Point point in points) {
        expect(isPointNearToLine(line, point), isTrue, reason: "$point");
      }
    });*/
    /*test('should serialize direction', () async {
      final service = NavigationServiceMapKit.init();
      final res = await service.fetchDirection(
          from: leCreusot, to: montceau, type: TransportType.Car);
      if (res.isPresent) {
        var directionFile = File('output/creusot_montceau.json');
        var sink = directionFile.openWrite();
        sink.write(JSON.jsonEncode((res.value as DirectionMapKit).toJson()));
        await sink.flush();
        await sink.close();
      }
    });*/
    //TODO ne pivote pas assez vite
    //TODO du bruit au debut (voir les graph)
    test('should serialize dump', () async {
      //
      int count = 0, countFailed = 0;
      Completer onFinish = Completer();
      final List<NavigationDump> dumps = [];
      final navigationService = _MockNavigationForRealTestService();
      final navigation = navigationService.createNavigation();
      PolyLine currentLine = PolyLine([]);
      DateTime now = DateTime.now();
      navigation.onChanges.listen((onData) {
        final fromStart = DateTime.now().difference(now);
        if (!onData.direction.isPresent) {
          _Logs.logFinder(fromStart, (navigation as NavigationImpl));
          _Logs.logLine(fromStart, currentLine, onData.currentPosition);
          currentLine = PolyLine([]);
          return; //when restarting
        }
        if (onData.currentPosition.isPresent) {
          points.add(onData.currentPosition.value);
          currentLine.addLast(onData.currentPosition.value);
        }
        line = onData.direction.value.polyline;
        remainMeters.add(onData.totalRemainingMeters);
        //print("$index: " + onData.toString());
        if (onData.isFinished) onFinish.complete(true);
        NavigationDump dump;
        if (onData.cameraPosition.isPresent) {
          dump = NavigationDump(
              bearing: onData.currentSmoothBearingDegree,
              cameraLatitude: onData.cameraPosition.value.latitude,
              cameraLongitude: onData.cameraPosition.value.longitude,
              latitude: onData.currentPosition.value.latitude,
              longitude: onData.currentPosition.value.longitude,
              tilt: 90,
              zoom: onData.getGoogleZoom(heightPX: 740, widthPX: 360));
          dumps.add(dump);
          count++;
        } else {
          countFailed++;
        }
        _Logs.log(
            count: count,
            countFailed: countFailed,
            dump: dump,
            fromStart: fromStart,
            infos: onData);
        _Logs.logMetrics(dump: dump, fromStart: fromStart, infos: onData);
      });
      print(
          "start serialized simulation: ${Duration(seconds: navigationService.speed.getSeconds(forMeters: 21171)).inMinutes} minutes");
      await navigation.start(
        from: leCreusot,
        to: montceau,
      );
      await onFinish.future;
      print("end serialized simulation");
      _Logs.dump(dumps);
      print("end serialized dump");
    }, timeout: Timeout(Duration(minutes: 10)));
  });
}
