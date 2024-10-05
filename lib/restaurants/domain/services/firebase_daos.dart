import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong/latlong.dart';
import 'package:food/commons/firebase_dao.dart';
import '../models.dart';
import 'contract.dart';
import 'package:meta/meta.dart';
import 'package:food/commerce/commerce.dart';

class RestaurantFirebaseDao
    extends AbstractFirebaseDao<RestaurantQuery, RestaurantModel> {
  final String categoryColName;
  RestaurantFirebaseDao(String col, {@required this.categoryColName})
      : super(col);
  RestaurantModel fromFirebase(Map<String, dynamic> json,
      {String id, RestaurantQuery query}) {
    final Map<dynamic, dynamic> slots =
        json.containsKey("slots") ? json["slots"] : null;
    final GeoPoint position =
        json.containsKey("position") ? json["position"] : null;
    json.remove("position");
    json.remove("slots");
    final RestaurantModel model = RestaurantModel.fromJson(json);
    if (position != null) {
      model.latitude = position.latitude;
      model.longitude = position.longitude;
    }
    if (slots != null) {
      slots.keys.forEach((f) => model.slots.add(OpenSlotModel.fromJson(
          Map.castFrom<dynamic, dynamic, String, dynamic>(slots["$f"]))));
    }
    if (query != null && query.location != null) {
      final center = query.location;
      final Distance distance = new Distance();
      final double km1 = distance.as(
          LengthUnit.Meter,
          new LatLng(center.latitude, center.longitude),
          new LatLng(model.latitude, model.longitude));
      model.distance = km1;
    }
    if (id != null) {
      model.id = id;
    }
    return model;
  }

  Map<String, dynamic> toFirebase(RestaurantModel model) {
    var slots = model.slots;
    var json = model.toJSON();
//
    json.remove("slots");
    var slotsMap = {};
    if (slots != null && slots.length > 0) {
      var index = 0;
      slots
          .forEach((s) => slotsMap.putIfAbsent("${index++}", () => s.toJSON()));
    }
    json.putIfAbsent("slots", () => slotsMap);
//
    json.remove("latitude");
    json.remove("longitude");
    json.putIfAbsent(
        "position", () => GeoPoint(model.latitude, model.longitude));
    return json;
  }

  Query toQuery(Query fQuery, RestaurantQuery query) {
    if (query.acceptTicket != null && query.acceptTicket) {
      fQuery = fQuery.where("acceptTicket", isEqualTo: true);
    }
    if (query.importantTag != null) {
      //TODO use a map for importantTags?
      fQuery = fQuery.where("tags", arrayContains: query.importantTag);
    }
    if (query.tag != null) {
      fQuery = fQuery.where("tags", arrayContains: query.tag);
    }
    return fQuery;
  }

  ProductCategoryFirebaseDao getCategoryDao(String restaurantId) {
    return ProductCategoryFirebaseDao(
        this.ref.document(restaurantId), this.categoryColName);
  }
}
