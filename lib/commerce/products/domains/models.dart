import 'package:json_annotation/json_annotation.dart';
import 'package:intl/intl.dart';
import 'package:diacritic/diacritic.dart';
part 'models.g.dart';

final formatCurrency = new NumberFormat.simpleCurrency(locale: "FR-fr");
_nameSearch(String name) {
  if (name != null) {
    String res = name.toLowerCase();
    res = removeDiacritics(res);
    return res.replaceAll(new RegExp('([^a-z0-9])'), "");
  }
  return name;
}

@JsonSerializable()
class ProductModel {
  String id;
  String name;
  String image;
  double rating;
  List<String> tags;
  List<String> categories;
  int priceCents;
  String description;
  bool available;
  //TODO replace restaurantId by shopId
  String restaurantId;
  ProductModel(
      {this.id,
      this.restaurantId,
      this.name,
      this.description,
      this.image,
      this.rating,
      this.priceCents,
      this.available,
      List<String> categories,
      List<String> tags})
      : this.categories = categories ?? [],
        this.tags = tags ?? [];
  get hasDescription =>
      this.description != null && this.description.trim().length > 0;
  get hasImage => this.image != null && this.image.trim().length > 0;

  String get nameSearch => _nameSearch(this.name);

  Map<String, dynamic> toJSON() {
    return _$ProductModelToJson(this);
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    ProductModel model = _$ProductModelFromJson(json);
    return model;
  }
  String get price => formatCurrency.format(this.priceCents / 100);
}

@JsonSerializable()
class ProductDetailModel {
  ProductModel product;
  List<ProductGroupModel> groups = [];
  ProductDetailModel({this.product, this.groups});
}

@JsonSerializable()
class ProductGroupModel {
  String id;
  String name;
  bool available;
  bool mandatory;
  int minSelection; //min number of choice selected
  int maxSelection; //max number of choice selected
  //unused now
  String image;
  String description;
  List<ProductItemModel> items = [];
  ProductGroupModel(
      {this.id,
      this.name,
      this.description,
      this.image,
      this.mandatory,
      this.minSelection,
      this.maxSelection,
      this.available});
  Map<String, dynamic> toJSON() {
    return _$ProductGroupModelToJson(this);
  }

  factory ProductGroupModel.fromJson(Map<String, dynamic> json) {
    ProductGroupModel model = _$ProductGroupModelFromJson(json);
    return model;
  }

  String get nameSearch => _nameSearch(this.name);
}

@JsonSerializable()
class ProductItemModel {
  String id;
  String name;
  int priceCents;
  bool available;
  //unused now
  String image;
  String description;
  ProductItemModel(
      {this.id,
      this.name,
      this.description,
      this.image,
      this.priceCents,
      this.available});
  Map<String, dynamic> toJSON() {
    return _$ProductItemModelToJson(this);
  }

  factory ProductItemModel.fromJson(Map<String, dynamic> json) {
    ProductItemModel model = _$ProductItemModelFromJson(json);
    return model;
  }
  String get price => formatCurrency.format(this.priceCents / 100);

  String get nameSearch => _nameSearch(this.name);
}

@JsonSerializable()
class ProductCategory {
  String id;
  String name;
  String image;
  String description;
  int position;
  ProductCategory(
      {this.id, this.position, this.name, this.description, this.image});
  Map<String, dynamic> toJSON() {
    return _$ProductCategoryToJson(this);
  }

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    ProductCategory model = _$ProductCategoryFromJson(json);
    return model;
  }
  String get nameSearch => _nameSearch(this.name);
}
