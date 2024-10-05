import 'dart:async';
import '../models.dart';

abstract class LocationService {
  Future<GeoPositionResult> currentPosition({bool elseReturnLastKnown});

  Future<GeoAddressResult> currentAddress(
      {bool askPermission = false, bool elseReturnLastKnow});

  Future<List<GeoPlace>> getPositionFromAddress(String address,
      {bool keepOnlyFullAddress = false});

  Future<bool> askPermission();

  Future<List<GeoPlace>> getRecentPlaces();

  Future<GeoPlace> addToRecentPlace(GeoPlace place);

  Future<void> removeRecentPlaces();

  Future<double> distanceBetweenInMeters({GeoPosition from, GeoPosition to});
}
