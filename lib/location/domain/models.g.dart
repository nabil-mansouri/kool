// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeoPosition _$GeoPositionFromJson(Map<String, dynamic> json) {
  return GeoPosition(
      longitude: (json['longitude'] as num)?.toDouble(),
      latitude: (json['latitude'] as num)?.toDouble(),
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
      accuracy: (json['accuracy'] as num)?.toDouble(),
      altitude: (json['altitude'] as num)?.toDouble(),
      heading: (json['heading'] as num)?.toDouble(),
      speed: (json['speed'] as num)?.toDouble(),
      speedAccuracy: (json['speedAccuracy'] as num)?.toDouble());
}

Map<String, dynamic> _$GeoPositionToJson(GeoPosition instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'timestamp': instance.timestamp?.toIso8601String(),
      'altitude': instance.altitude,
      'accuracy': instance.accuracy,
      'heading': instance.heading,
      'speed': instance.speed,
      'speedAccuracy': instance.speedAccuracy
    };

GeoPlace _$GeoPlaceFromJson(Map<String, dynamic> json) {
  return GeoPlace(
      name: json['name'] as String,
      isoCountryCode: json['isoCountryCode'] as String,
      country: json['country'] as String,
      postalCode: json['postalCode'] as String,
      administrativeArea: json['administrativeArea'] as String,
      subAdministrativeArea: json['subAdministrativeArea'] as String,
      locality: json['locality'] as String,
      subLocality: json['subLocality'] as String,
      thoroughfare: json['thoroughfare'] as String,
      subThoroughfare: json['subThoroughfare'] as String,
      position: json['position'] == null
          ? null
          : GeoPosition.fromJson(json['position'] as Map<String, dynamic>));
}

Map<String, dynamic> _$GeoPlaceToJson(GeoPlace instance) => <String, dynamic>{
      'name': instance.name,
      'isoCountryCode': instance.isoCountryCode,
      'country': instance.country,
      'postalCode': instance.postalCode,
      'administrativeArea': instance.administrativeArea,
      'subAdministrativeArea': instance.subAdministrativeArea,
      'locality': instance.locality,
      'subLocality': instance.subLocality,
      'thoroughfare': instance.thoroughfare,
      'subThoroughfare': instance.subThoroughfare,
      'position': instance.position.toJson()
    };

GeoPositionResult _$GeoPositionResultFromJson(Map<String, dynamic> json) {
  return GeoPositionResult(
      position: json['position'] == null
          ? null
          : GeoPosition.fromJson(json['position'] as Map<String, dynamic>),
      status: _$enumDecodeNullable(_$GeoStatusEnumMap, json['status']),
      needPerms: json['needPerms'] as bool,
      hasLocationService: json['hasLocationService'] as bool);
}

Map<String, dynamic> _$GeoPositionResultToJson(GeoPositionResult instance) =>
    <String, dynamic>{
      'position': instance.position,
      'status': _$GeoStatusEnumMap[instance.status],
      'needPerms': instance.needPerms,
      'hasLocationService': instance.hasLocationService
    };

T _$enumDecode<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }
  return enumValues.entries
      .singleWhere((e) => e.value == source,
          orElse: () => throw ArgumentError(
              '`$source` is not one of the supported values: '
              '${enumValues.values.join(', ')}'))
      .key;
}

T _$enumDecodeNullable<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source);
}

const _$GeoStatusEnumMap = <GeoStatus, dynamic>{
  GeoStatus.denied: 'denied',
  GeoStatus.disabled: 'disabled',
  GeoStatus.granted: 'granted',
  GeoStatus.restricted: 'restricted',
  GeoStatus.unknown: 'unknown'
};

GeoAddressResult _$GeoAddressResultFromJson(Map<String, dynamic> json) {
  return GeoAddressResult(
      position: json['position'] == null
          ? null
          : GeoPosition.fromJson(json['position'] as Map<String, dynamic>),
      status: _$enumDecodeNullable(_$GeoStatusEnumMap, json['status']),
      needPerms: json['needPerms'] as bool,
      hasLocationService: json['hasLocationService'] as bool,
      place: json['place'] == null
          ? null
          : GeoPlace.fromJson(json['place'] as Map<String, dynamic>));
}

Map<String, dynamic> _$GeoAddressResultToJson(GeoAddressResult instance) =>
    <String, dynamic>{
      'position': instance.position,
      'status': _$GeoStatusEnumMap[instance.status],
      'needPerms': instance.needPerms,
      'hasLocationService': instance.hasLocationService,
      'place': instance.place
    };
