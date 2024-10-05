import 'dart:async';
import 'package:meta/meta.dart';
import 'package:food/commerce/commerce.dart';
import 'package:optional/optional.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:food/location/location.dart';
import '../models.dart';
part 'contract.g.dart';

enum RestaurantOrderQuery { Position, Popularity, Notes, Delay, Price }

@JsonSerializable()
class RestaurantQuery {
  String tag;
  int limit;
  DateTime forDate;
  bool forNow ;
  GeoPlace location;
  String importantTag;
  bool acceptTicket;
  String nameSearch;
  String lastIdFetched;
  RestaurantOrderQuery order = RestaurantOrderQuery.Position;
  RestaurantQuery(
      {this.lastIdFetched,
      this.tag,
      this.importantTag,
      this.acceptTicket = false,
      this.location,
      this.order,
      this.limit = 10,
      this.forDate,
      this.forNow= true,
      this.nameSearch});
  factory RestaurantQuery.fromJson(Map<String, dynamic> json) {
    return _$RestaurantQueryFromJson(json);
  }
  Map<String, dynamic> toJson() {
    return _$RestaurantQueryToJson(this);
  }

  get canSubmit {
    return this.location != null;
  }
}

abstract class RestaurantListCursor {
  bool get cancelled;
  bool get finished;
  Future<List<RestaurantModel>> next();
  stop();
  Map<String, dynamic> backup();
  void restaure(Map<String, dynamic> state);
}

abstract class RestaurantService {
  //
  Future removeLastQuery();
  Future<Optional<RestaurantQuery>> getLastQuery();
  Future<RestaurantQuery> setLastQuery(RestaurantQuery query);
  Future<void> deleteById(String id, {bool withCategories});
  Future<RestaurantModel> fetchById(String id);
  RestaurantListCursor fetchCursor(RestaurantQuery query,
      {@required double maxRadius,
      @required double addRadius,
      @required int minNumberOfData});
  Future<List<RestaurantModel>> fetch(RestaurantQuery query, double radius);
  Future<RestaurantDetailModel> fetchDetail(RestaurantModel model);
  Future<RestaurantModel> create(RestaurantModel model, {String forceId});
  //
  Future<ProductModel> createProduct(ProductModel model, {String forceId});
  Future<List<ProductModel>> fetchProducts(ProductQuery query);
  Future<void> deleteProductById(String id);
  Future<ProductModel> fetchProductById(String id);
  //
}
