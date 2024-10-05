import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'position_commons.dart';
import 'contract.dart';

class _PositionListenerImpl implements PositionListener {
  final geoLocator = Geolocator();
  final permission = PermissionHandler();
  // Mutable attributes
  int _index;
  bool _listening;
  StreamSubscription _subscription;
  Subject<PositionListenerEvent> _observable;
  // Getters
  bool get listening => _listening;
  Observable<PositionListenerEvent> get onChange => _observable;
  // Methods
  stop() async {
    _observable?.close();
    _subscription?.cancel();
    _subscription = null;
    _observable = null;
    _listening = false;
    return true;
  }

  start() async {
    stop();
    _index = 0;
    _listening = true;
    _observable = BehaviorSubject();
    await askPermission();
    var locationOptions =
        LocationOptions(accuracy: LocationAccuracy.bestForNavigation);
    //TODO listen background?
    _subscription = geoLocator.getPositionStream(locationOptions).listen((o) {
      _observable.add(PositionListenerEventImpl(o, _index++));
    });
    return true;
  }

  dispose() {
    _subscription?.cancel();
    _observable?.close();
    _subscription = null;
    _observable = null;
  }

  Future<bool> askPermission() async {
    final hasService =
        await permission.checkServiceStatus(PermissionGroup.location);
    if (hasService == ServiceStatus.enabled) {
      final previousStatus =
          await permission.checkPermissionStatus(PermissionGroup.location);
      if (previousStatus == PermissionStatus.granted) {
        return true;
      }
      final res =
          await permission.requestPermissions([PermissionGroup.location]);
      final status = res[PermissionGroup.location];
      return status == PermissionStatus.granted;
    }
    return false;
  }
}

mixin GeolocationListener {
  Future<PositionListener> listenPositionChanges() async {
    return _PositionListenerImpl();
  }
}
