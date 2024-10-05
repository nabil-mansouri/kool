// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RestaurantModel _$RestaurantModelFromJson(Map<String, dynamic> json) {
  return RestaurantModel(
      id: json['id'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
      rating: (json['rating'] as num)?.toDouble(),
      nameSearch: json['nameSearch'] as String,
      available: json['available'] as bool,
      closed: json['closed'] as bool,
      delayFormat: json['delayFormat'] as String,
      tags: (json['tags'] as List)?.map((e) => e as String)?.toList(),
      slots: (json['slots'] as List)
          ?.map((e) => e == null
              ? null
              : OpenSlotModel.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      address: json['address'] as String,
      acceptTicket: json['acceptTicket'] as bool,
      delayMean: json['delayMean'] as int,
      priceMean: (json['priceMean'] as num)?.toDouble(),
      popularity: json['popularity'] as int,
      latitude: (json['latitude'] as num)?.toDouble(),
      longitude: (json['longitude'] as num)?.toDouble(),
      distance: (json['distance'] as num)?.toDouble());
}

Map<String, dynamic> _$RestaurantModelToJson(RestaurantModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'nameSearch': instance.nameSearch,
      'image': instance.image,
      'rating': instance.rating,
      'tags': instance.tags,
      'delayFormat': instance.delayFormat,
      'available': instance.available,
      'closed': instance.closed,
      'acceptTicket': instance.acceptTicket,
      'delayMean': instance.delayMean,
      'popularity': instance.popularity,
      'priceMean': instance.priceMean,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'distance': instance.distance,
      'address': instance.address,
      'slots': instance.slots
    };

OpenSlotModel _$OpenSlotModelFromJson(Map<String, dynamic> json) {
  return OpenSlotModel(
      day: json['day'] as int,
      openMinute: json['openMinute'] as int,
      closeMinute: json['closeMinute'] as int,
      allTheDay: json['allTheDay'] as bool,
      dayFormat: json['dayFormat'] as String,
      openFormat: json['openFormat'] as String,
      closeFormat: json['closeFormat'] as String);
}

Map<String, dynamic> _$OpenSlotModelToJson(OpenSlotModel instance) =>
    <String, dynamic>{
      'day': instance.day,
      'openMinute': instance.openMinute,
      'closeMinute': instance.closeMinute,
      'allTheDay': instance.allTheDay,
      'dayFormat': instance.dayFormat,
      'openFormat': instance.openFormat,
      'closeFormat': instance.closeFormat
    };
