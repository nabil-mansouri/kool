import 'package:json_annotation/json_annotation.dart';
import 'package:food/commerce/commerce.dart';
import 'package:food/location/location.dart';
part 'models.g.dart';

/*
 * Models
 */

@JsonSerializable()
class RestaurantModel {
  String id;
  String name;
  String nameSearch;
  String image;
  double rating;
  List<String> tags;
  String delayFormat;
  bool available;
  bool closed;
  bool acceptTicket;
  int delayMean;
  int popularity;
  double priceMean;
  double latitude;
  double longitude;
  double distance;
  String address;
  List<OpenSlotModel> slots = [];
  RestaurantModel(
      {this.id,
      this.name,
      this.image,
      this.rating = 0,
      this.nameSearch,
      this.available = true,
      this.closed = false,
      this.delayFormat,
      this.tags,
      this.slots,
      this.address,
      this.acceptTicket = false,
      this.delayMean = 1000,
      this.priceMean = 1000,
      this.popularity = 0,
      this.latitude = 0,
      this.longitude = 0,
      this.distance = 0}) {
    this.slots = this.slots ?? [];
    this.tags = this.tags ?? [];
    //TODO transform name
    this.nameSearch = this.nameSearch ?? this.name;
  }
  Map<String, dynamic> toJSON() {
    var json = _$RestaurantModelToJson(this);
    json['slots'] =
        this.slots.map((slot) => _$OpenSlotModelToJson(slot)).toList();
    return json;
  }

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    RestaurantModel model = _$RestaurantModelFromJson(json);
    return model;
  }
}

@JsonSerializable()
class OpenSlotModel {
  int day; //1 to 7
  int openMinute;
  int closeMinute;
  bool allTheDay;
  String dayFormat;
  String openFormat;
  String closeFormat;
  OpenSlotModel(
      {this.day,
      this.openMinute,
      this.closeMinute,
      this.allTheDay,
      this.dayFormat,
      this.openFormat,
      this.closeFormat});

  Map<String, dynamic> toJSON() {
    return _$OpenSlotModelToJson(this);
  }

  factory OpenSlotModel.fromJson(Map<String, dynamic> json) {
    OpenSlotModel model = _$OpenSlotModelFromJson(json);
    return model;
  }
}

class RestaurantDetailModel {
  GeoPosition position;
  List<OpenSlotModel> slots = [];
  List<ProductModel> products = [];
  List<ProductCategory> categories = [];
  RestaurantDetailModel({this.products, this.slots, this.categories});
}
