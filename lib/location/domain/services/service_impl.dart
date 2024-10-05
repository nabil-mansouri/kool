import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models.dart';
import 'contract.dart';
import 'recent_places.dart';

class LocationServiceImpl with RecentPlacesMixin implements LocationService {
  final geoLocator = Geolocator();
  final permission = PermissionHandler();

  Future<double> distanceBetweenInMeters({GeoPosition from, GeoPosition to}) {
    return geoLocator.distanceBetween(
        from.latitude, from.longitude, to.latitude, to.longitude);
  }

  Future<GeoPositionResult> currentPosition(
      {bool elseReturnLastKnown = false}) async {
    final res = await _currentPosition();
    if (res.hasPosition) {
      return res;
    } else if (elseReturnLastKnown) {
      final last = await geoLocator.getLastKnownPosition();
      return GeoPositionResult(
          position: toModelPosition(last),
          status: res.status,
          needPerms: res.needPerms,
          hasLocationService: res.hasLocationService);
    } else {
      return res;
    }
  }

  Future<GeoPositionResult> _currentPosition() async {
    GeolocationStatus status =
        await geoLocator.checkGeolocationPermissionStatus();
    if (status == GeolocationStatus.granted) {
      final position = await geoLocator.getCurrentPosition();
      return GeoPositionResult(
          position: toModelPosition(position),
          status: toModelGeoStatus(status),
          needPerms: false,
          hasLocationService: true);
    } else {
      return GeoPositionResult(
          position: null,
          status: toModelGeoStatus(status),
          needPerms: false,
          hasLocationService: status != GeolocationStatus.disabled);
    }
  }

  Future<GeoAddressResult> currentAddress(
      {bool askPermission = false, bool elseReturnLastKnow = false}) async {
    if (askPermission) {
      await this.askPermission();
    }
    final position =
        await currentPosition(elseReturnLastKnown: elseReturnLastKnow);
    if (position.hasPosition) {
      List<Placemark> placemark = await geoLocator.placemarkFromCoordinates(
          position.position.latitude, position.position.longitude);
      if (placemark.length > 0) {
        return GeoAddressResult.fromGeoPosition(
            position, toModelPlace(placemark.first));
      }
    }
    return GeoAddressResult.fromGeoPosition(position);
  }

  Future<List<GeoPlace>> getPositionFromAddress(String address,
      {bool keepOnlyFullAddress = false}) async {
    final result = await geoLocator.placemarkFromAddress(address);
    return result
        .map((f) => toModelPlace(f))
        .where((test) => keepOnlyFullAddress != true || test.hasAddressPart)
        .toList();
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

  GeoPosition toModelPosition(Position position) {
    if (position == null) {
      return null;
    }
    return GeoPosition(
      longitude: position.longitude,
      latitude: position.latitude,
      timestamp: position.timestamp,
      accuracy: position.accuracy,
      altitude: position.altitude,
      heading: position.heading,
      speed: position.speed,
      speedAccuracy: position.speedAccuracy,
    );
  }

  GeoPlace toModelPlace(Placemark place) {
    if (place == null) {
      return null;
    }
    return GeoPlace(
        name: place.name,
        isoCountryCode: place.isoCountryCode,
        country: place.country,
        postalCode: place.postalCode,
        administrativeArea: place.administrativeArea,
        subAdministrativeArea: place.subAdministrativeArea,
        locality: place.locality,
        subLocality: place.subLocality,
        thoroughfare: place.thoroughfare,
        subThoroughfare: place.subThoroughfare,
        position: toModelPosition(place.position));
  }

  GeoStatus toModelStatus(PermissionStatus status) {
    if (status == null) {
      return null;
    }
    switch (status) {
      case PermissionStatus.denied:
        return GeoStatus.denied;
      case PermissionStatus.disabled:
        return GeoStatus.disabled;
      case PermissionStatus.granted:
        return GeoStatus.granted;
      case PermissionStatus.restricted:
        return GeoStatus.restricted;
      case PermissionStatus.unknown:
      default:
        return GeoStatus.unknown;
    }
  }

  GeoStatus toModelGeoStatus(GeolocationStatus status) {
    if (status == null) {
      return null;
    }
    switch (status) {
      case GeolocationStatus.denied:
        return GeoStatus.denied;
      case GeolocationStatus.disabled:
        return GeoStatus.disabled;
      case GeolocationStatus.granted:
        return GeoStatus.granted;
      case GeolocationStatus.restricted:
        return GeoStatus.restricted;
      case GeolocationStatus.unknown:
      default:
        return GeoStatus.unknown;
    }
  }
}
