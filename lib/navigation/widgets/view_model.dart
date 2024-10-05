import 'dart:async';
import 'package:flutter/material.dart';
import 'package:food/multiflow/multiflow.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import "../store/store.dart";
import "../domain/domain.dart" hide LatLng;
import 'package:flutter/services.dart' show rootBundle;

class NavigationViewModel extends AbstractModel<GeoNavigationState> {
  final MarkerId myPositionMarkerId = MarkerId("myposition");
  final PolylineId polylineId = PolylineId("plan");
  Completer<GoogleMapController> _controller = Completer();
  MockNavigationService navigationService =
      MockNavigationService(NavigationInfosConfig(secondsWindow: 40));
  Navigation _navigation;
  NavigationInfos _infos;
  Size _size;
  int _count = 0;
  setSize(Size size) {
    _size = size;
  }

  Set<Marker> get markers {
    Set<Marker> markers = Set();
    if (_infos?.currentPosition?.isPresent == true) {
      final position = _infos.currentPosition.value;
      final Marker myPositionMarker = Marker(
          markerId: myPositionMarkerId,
          position: LatLng(position.latitude, position.longitude),
          flat: false);
      markers.add(myPositionMarker);
    }
    return markers;
  }

  preparePlan() async {
    final controller = await _controller.future;
    final direction = await navigationService.fetchDirection(
        from: null, to: null, type: TransportType.Car);
    final bounds = Bounds.fromPolyline(direction.value.polyline);
    final future1 = controller.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
          northeast:
              LatLng(bounds.northEast.latitude, bounds.northEast.longitude),
          southwest:
              LatLng(bounds.southWest.latitude, bounds.southWest.longitude),
        ),
        10));
    //TODO compute width from zoom 2meter
    final points = direction.value.polyline.points
        .map((f) => LatLng(f.latitude, f.longitude))
        .toList();
    final line = Polyline(
        polylineId: polylineId,
        color: Colors.blue.shade500,
        consumeTapEvents: false,
        width: 20,
        visible: true,
        points: points);
    final future2 =
        controller.updatePolylines(PolylineUpdates(add: Set.of([line])));
    await Future.wait([future1, future2]);
    await Future.delayed(Duration(seconds: 5));
  }

  setController(GoogleMapController controller) async {
    _controller.complete(controller);
    print("prepare plan!");
    await preparePlan();
    print("start!");
    //start();
    await startFromDump();
  }

  var _zoom;
  _updateMap(NavigationInfos infos) async {
    _infos = infos;
    //print("#################################################");
    //print("update map: $infos");
    final controller = await _controller.future;
    if (_infos?.cameraPosition?.isPresent == true) {
      final position = _infos.cameraPosition.value;

      if (_size != null) {
        _zoom =
            _infos.getGoogleZoom(heightPX: _size.height, widthPX: _size.width);
      }
      //chargement des map initiale nok => charger tout le bounds du polyline?
      //TODO tester jusqu'à 160km/h
      //TODO deplacement camera + zoom => trop de bruit
      //TODO manque polyline
      //TODO parfois l'orientation est perpendiculaire (en ligne droite)
      //la navigation a 600ms de retard
      //#animateMarker
      //#animatePolyline => anim les points qui ont bougé uniquement
      //#animateAll (anime marker + polyline )
      //pas mal => zoom plus smooth
      //simulation dure 2 min seulement
      //faire les calcul dans isolate? contacter la plateforme via isolate?
      //print(
      //  "Animate camera: $zoom, Bounds meter: ${_infos.cameraBoundsMeters.orElse(null)}");
      if (_count % 5 == 0) {
        controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            zoom: _zoom,
            bearing: _infos.currentSmoothBearingDegree,
            tilt: 90,
            target: LatLng(position.latitude, position.longitude))));
      }
      if (_count == 0) {
        controller.updateMarkers(MarkerUpdates(add: markers));
      } else {
        controller.updateMarkers(MarkerUpdates(changes: markers));
      }
      _count++;
    }
  }

  goToStart(Vector firstVector) async {
    final controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            zoom: 18,
            bearing: firstVector.bearingDegree,
            tilt: 90,
            target: LatLng(
                firstVector.start.latitude, firstVector.start.longitude))));
  }

  bool _lockMove = false;
  startFromDump() async {
    final text = await rootBundle
        .loadString('output/creusot_montceau.dump.json', cache: false);
    final dump = NavigationDumpGenerator.fromJson(text,
        hertz: MockNavigationService.kHertz);
    print("start from dump : ${dump.json.length}");
    await goToStart(Vector(Point(dump.json[0].latitude, dump.json[0].longitude),
        Point(dump.json[1].latitude, dump.json[1].longitude)));
    dump.createObservable().listen((onData) async {
      if (onData == null) return;
      final controller = await _controller.future;
      //camera
      void moveCamera() async {
        if (_lockMove) return;
        try {
          _lockMove = true;
          await controller.moveCamera(CameraUpdate.newCameraPosition(
              CameraPosition(
                  zoom: onData.zoom,
                  bearing: onData.bearing,
                  tilt: onData.tilt,
                  target:
                      LatLng(onData.cameraLatitude, onData.cameraLongitude))));
        } finally {
          _lockMove = false;
        }
      }

      moveCamera();
      //marckers
      void updateMarkers() {
        Set<Marker> markers = Set();
        final Marker myPositionMarker = Marker(
            markerId: myPositionMarkerId,
            position: LatLng(onData.latitude, onData.longitude),
            flat: false);
        markers.add(myPositionMarker);
        if (_count == 0) {
          controller.updateMarkers(MarkerUpdates(add: markers));
        } else {
          controller.updateMarkers(MarkerUpdates(changes: markers));
        }
        _count++;
      }

      updateMarkers();
    });
  }

  start() {
    print("starting navigation");
    _navigation = navigationService.createNavigation();
    _navigation.onChanges.listen(_updateMap);
    _navigation.start(from: null, to: null).then((data) {
      //TODO on finish
      print("finished navigation");
    });
  }

  onDispose() {
    super.onDispose();
    _navigation?.stop();
    _navigation?.dispose();
    _navigation = null;
  }

  @override
  bool refresh(state) {
    return false;
  }
}
