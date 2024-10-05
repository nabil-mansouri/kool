// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contract.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RestaurantQuery _$RestaurantQueryFromJson(Map<String, dynamic> json) {
  return RestaurantQuery(
      lastIdFetched: json['lastIdFetched'] as String,
      tag: json['tag'] as String,
      forDate: json['forDate'] == null
          ? null
          : DateTime.parse(json['forDate'] as String),
      forNow: json['forNow'] as bool,
      importantTag: json['importantTag'] as String,
      acceptTicket: json['acceptTicket'] as bool,
      location: json['location'] == null
          ? null
          : GeoPlace.fromJson(json['location'] as Map<String, dynamic>),
      order: _$enumDecodeNullable(_$RestaurantOrderQueryEnumMap, json['order']),
      limit: json['limit'] as int,
      nameSearch: json['nameSearch'] as String);
}

Map<String, dynamic> _$RestaurantQueryToJson(RestaurantQuery instance) =>
    <String, dynamic>{
      'lastIdFetched': instance.lastIdFetched,
      'tag': instance.tag,
      'forDate': instance.forDate?.toIso8601String(),
      'forNow': instance.forNow,
      'importantTag': instance.importantTag,
      'acceptTicket': instance.acceptTicket,
      'nameSearch': instance.nameSearch,
      'limit': instance.limit,
      'location': instance.location.toJson(),
      'order': _$RestaurantOrderQueryEnumMap[instance.order]
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

const _$RestaurantOrderQueryEnumMap = <RestaurantOrderQuery, dynamic>{
  RestaurantOrderQuery.Position: 'Position',
  RestaurantOrderQuery.Popularity: 'Popularity',
  RestaurantOrderQuery.Notes: 'Notes',
  RestaurantOrderQuery.Delay: 'Delay',
  RestaurantOrderQuery.Price: 'Price'
};
