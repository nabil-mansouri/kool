import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:optional/optional.dart';
import 'package:meta/meta.dart';
import '../geo/geo.dart';
import 'contract.dart';
import 'navigation_infos/navigation_infos.dart';
import 'navigation_restarter.dart';

//TODO custom polyline effect?
//TODO waring infinity numbers shuld not be displayed
//each time position changes
//  update camera position
//  update marker position
//each time segment changes
//  update instruction
//  update time travel expected
//  update distance expected
//update distance expected for current step
//  update poliline forward and backward
class NavigationImpl implements Navigation {
  final NavigationService service;
  //listeners
  PositionListener _listener;
  StreamSubscription _subChange;
  //private attributes
  Point _to;
  Point _from;
  NavigationInfos _infos;
  Optional<SegmentFinder> _segmentFinder = Optional.empty();
  Optional<NavigationRestarter> _restarter = Optional.empty();
  final Subject<NavigationInfos> _onChanges;
  //
  Optional<SegmentFinder> get finder => _segmentFinder;
  Observable<NavigationInfos> get onChanges => _onChanges;
  NavigationImpl(
      {@required this.service,
      NavigationInfosConfig config,
      bool synchrone = true})
      : _onChanges = PublishSubject(sync: synchrone) {
    _infos = NavigationInfos(config ?? NavigationInfosConfig());
  }
  Future<void> restart() async {
    await _fetchDirection(_infos.transportType);
  }

  _onPositionChanged(PositionListenerEvent event) async {
    //update position and speed
    _infos.setCurrent(event.coordinate);
    //find segment
    if (_infos.isNavigating &&
        _segmentFinder.isPresent &&
        _infos.currentMovement.isPresent) {
      final founded = _segmentFinder.value.next(_infos.currentMovement.value);
      if (founded.isPresent) {
        _infos.setCurrentSegment(founded.value);
      }
      //dont do async => because observable will may send info in invalid state
      if (_restarter.isPresent) _restarter.value.mayRestart(_infos, founded);
    }
    _onChanges.add(_infos);
  }

  Future<void> _startListeners() async {
    _stopListeners();
    _listener = await service.listenPositionChanges();
    await _listener.start();
    _subChange = _listener.onChange.listen((data) {
      _onPositionChanged(data);
    });
  }

  void _stopListeners() {
    _subChange?.cancel();
    _listener?.stop();
  }

  Future<void> _fetchDirection(TransportType type) async {
    _infos.preparing();
    final direction =
        await service.fetchDirection(from: _from, to: _to, type: type);
    if (direction.isPresent &&
        direction.value.stepsCount > 0 &&
        direction.value.polyline.nbPoints > 0) {
      _segmentFinder = Optional.ofNullable(
          createSegmentFinder(type: type, line: direction.value.polyline));
      _infos.start(direction.value, type);
    } else {
      _infos.notFound();
    }
  }

  Future<void> start(
      {@required Point from,
      @required Point to,
      @required TransportType type}) async {
    _from = from;
    _to = to;
    _restarter = Optional.ofNullable(createRestarter(type));
    //listen position even if not found
    await _startListeners();
    await _fetchDirection(type);
  }

  NavigationRestarter createRestarter(TransportType type) {
    return defaultNavigationRestarter(restart, type);
  }

  SegmentFinder createSegmentFinder(
      {@required PolyLine line, @required TransportType type}) {
    return defaultSegmentFinder(line: line, type: type);
  }

  void stop() {
    _stopListeners();
    _infos.stop();
  }

  void dispose() {
    _onChanges.close();
  }
}
