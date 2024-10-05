// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) {
  return ProductModel(
      id: json['id'] as String,
      restaurantId: json['restaurantId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      image: json['image'] as String,
      rating: (json['rating'] as num)?.toDouble(),
      priceCents: json['priceCents'] as int,
      available: json['available'] as bool,
      categories:
          (json['categories'] as List)?.map((e) => e as String)?.toList(),
      tags: (json['tags'] as List)?.map((e) => e as String)?.toList());
}

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'image': instance.image,
      'rating': instance.rating,
      'tags': instance.tags,
      'categories': instance.categories,
      'priceCents': instance.priceCents,
      'description': instance.description,
      'available': instance.available,
      'restaurantId': instance.restaurantId
    };


ProductGroupModel _$ProductGroupModelFromJson(Map<String, dynamic> json) {
  return ProductGroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      image: json['image'] as String,
      mandatory: json['mandatory'] as bool,
      minSelection: json['minSelection'] as int,
      maxSelection: json['maxSelection'] as int,
      available: json['available'] as bool)
    ..items = (json['items'] as List)
        ?.map((e) => e == null
            ? null
            : ProductItemModel.fromJson(Map<String, dynamic>.from(e)))
        ?.toList();
}

Map<String, dynamic> _$ProductGroupModelToJson(ProductGroupModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'available': instance.available,
      'mandatory': instance.mandatory,
      'minSelection': instance.minSelection,
      'maxSelection': instance.maxSelection,
      'image': instance.image,
      'description': instance.description,
      'items': instance.items.map((item) => _$ProductItemModelToJson(item)).toList()
    };

ProductItemModel _$ProductItemModelFromJson(Map<String, dynamic> json) {
  return ProductItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      image: json['image'] as String,
      priceCents: json['priceCents'] as int,
      available: json['available'] as bool);
}

Map<String, dynamic> _$ProductItemModelToJson(ProductItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'priceCents': instance.priceCents,
      'available': instance.available,
      'image': instance.image,
      'description': instance.description
    };

ProductCategory _$ProductCategoryFromJson(Map<String, dynamic> json) {
  return ProductCategory(
      id: json['id'] as String,
      position: json['position'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      image: json['image'] as String);
}

Map<String, dynamic> _$ProductCategoryToJson(ProductCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'image': instance.image,
      'description': instance.description,
      'position': instance.position
    };
