import 'package:json_annotation/json_annotation.dart';
part 'models.g.dart';

enum GeoStatus { denied, disabled, granted, restricted, unknown }

@JsonSerializable()
class GeoPosition {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double altitude;
  final double accuracy;
  final double heading;
  final double speed;
  final double speedAccuracy;
  isEquals(GeoPosition position) {
    final res =
        latitude == position?.latitude && longitude == position?.longitude;
    return res == true;
  }

  GeoPosition({
    this.longitude,
    this.latitude,
    this.timestamp,
    this.accuracy,
    this.altitude,
    this.heading,
    this.speed,
    this.speedAccuracy,
  });
  factory GeoPosition.fromJson(Map<String, dynamic> json) {
    return _$GeoPositionFromJson(json);
  }
  Map<String, dynamic> toJson() {
    return _$GeoPositionToJson(this);
  }
}

@JsonSerializable()
class GeoPlace {
  final String name;
  final String isoCountryCode;
  final String country;
  final String postalCode;
  final String administrativeArea;
  final String subAdministrativeArea;
  final String locality;
  final String subLocality;
  final String thoroughfare;
  final String subThoroughfare;
  final GeoPosition position;

  get isAllNull {
    return this.name == null &&
        this.isoCountryCode == null &&
        this.country == null &&
        this.postalCode == null &&
        this.administrativeArea == null &&
        this.subAdministrativeArea == null &&
        this.locality == null &&
        this.subLocality == null &&
        this.thoroughfare == null &&
        this.subThoroughfare == null;
  }

  isEquals(GeoPlace other) {
    return this.position?.isEquals(other?.position) == true;
  }

  GeoPlace(
      {this.name,
      this.isoCountryCode,
      this.country,
      this.postalCode,
      this.administrativeArea,
      this.subAdministrativeArea,
      this.locality,
      this.subLocality,
      this.thoroughfare,
      this.subThoroughfare,
      this.position});
  factory GeoPlace.fromLatLon({double latitude, double longitude}) {
    return GeoPlace(
        position: GeoPosition(longitude: longitude, latitude: latitude));
  }
  factory GeoPlace.fromJson(Map<String, dynamic> json) {
    return _$GeoPlaceFromJson(json);
  }
  Map<String, dynamic> toJson() {
    return _$GeoPlaceToJson(this);
  }

  bool get hasAddressPart {
    var res = formattedAdresssPart.trim().length > 0;
    return res;
  }

  String get formattedAdresssPart => "$subThoroughfare $thoroughfare";
  String get formattedCityPart => "$postalCode $locality $country";
  String get formattedAddress => "$formattedAdresssPart, $formattedCityPart";
  double get latitude => this.position.latitude;
  double get longitude => this.position.longitude;
}

@JsonSerializable()
class GeoPositionResult {
  final GeoPosition position;
  final GeoStatus status;
  final bool needPerms;
  final bool hasLocationService;
  GeoPositionResult(
      {this.position, this.status, this.needPerms, this.hasLocationService});
  bool get hasPosition {
    return this.position != null;
  }

  factory GeoPositionResult.fromJson(Map<String, dynamic> json) {
    return _$GeoPositionResultFromJson(json);
  }
  Map<String, dynamic> toJson() {
    return _$GeoPositionResultToJson(this);
  }
}

@JsonSerializable()
class GeoAddressResult {
  final GeoPosition position;
  final GeoStatus status;
  final bool needPerms;
  final bool hasLocationService;
  final GeoPlace place;
  GeoAddressResult(
      {this.position,
      this.status,
      this.needPerms,
      this.hasLocationService,
      this.place});
  bool get hasPosition {
    return this.position != null;
  }

  bool get hasPlace {
    return this.place != null;
  }

  factory GeoAddressResult.fromGeoPosition(GeoPositionResult res,
      [GeoPlace placemark]) {
    return GeoAddressResult(
        position: res.position,
        hasLocationService: res.hasLocationService,
        needPerms: res.needPerms,
        status: res.status,
        place: placemark);
  }
  factory GeoAddressResult.fromJson(Map<String, dynamic> json) {
    return _$GeoAddressResultFromJson(json);
  }
  Map<String, dynamic> toJson() {
    return _$GeoAddressResultToJson(this);
  }
}
