import 'dart:async';
import 'package:localstorage/localstorage.dart';
import 'package:optional/optional.dart';
import 'contract.dart';

mixin LastQueryMixin {
  final LocalStorage storage = new LocalStorage('restaurants');

  Future<RestaurantQuery> setLastQuery(RestaurantQuery query) async {
    await storage.ready;
    storage.setItem("query", query.toJson());
    return query;
  }

  Future<Optional<RestaurantQuery>> getLastQuery() async {
    await storage.ready;
    Map<String, dynamic> json = storage.getItem('query');
    if (json != null) {
      return Optional.ofNullable(RestaurantQuery.fromJson(json));
    }
    return Optional.empty();
  }

  Future removeLastQuery() async {
    await storage.ready;
    storage.deleteItem("query");
  }
}
