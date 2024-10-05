import 'package:flutter_test/flutter_test.dart' hide group;
import '../restaurants.dart';
import '../domain/factory.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food/commerce/commerce.dart';
import 'package:firestore_helpers/firestore_helpers.dart';

class GeoPointGeneratorImpl extends GeoPointGenerator {
  GeoPoint point;
  double radius = 0;
  GeoPointGeneratorImpl(this.point);
  next(int index) {
    Area a = Area(point, index.toDouble());
    var res = boundingBoxCoordinates(a);
    point = GeoPoint(res.swCorner.latitude, res.swCorner.longitude);
  }

  get latitude => this.point.latitude;
  get longitude => this.point.longitude;
}

class RestaurantTestUtils {
  final GeoPoint center = GeoPoint(46.8065195, 4.4081646);
  final RestaurantServiceFirebase firebase = RestaurantServiceFirebase(
      catName: "test_categories",
      productName: "test_products",
      restoColName: "test_restaurants");
  List<ProductCategory> categories = [];
  List<RestaurantModel> restaus = [];
  List<ProductModel> products = [];
  RestaurantTestUtils() {
    setRestaurantService(firebase);
    categories = RestaurantFactory.categoryForTest(5);
    restaus = RestaurantFactory.restaurantsForTests(
        5, GeoPointGeneratorImpl(center),
        tag: "notsame");
    restaus.addAll(RestaurantFactory.restaurantsForTests(
        5, GeoPointGeneratorImpl(center),
        samePoint: true, offsetId: 5, tag: "same"));

    restaus.sublist(0, 5).forEach((resto) {
      products
          .addAll(RestaurantFactory.productsForTest(5, restaurantId: resto.id));
    });
  }

  deleteAllRestaurants() async {
    dynamic before = await firebase.restoDao.fetch(RestaurantQuery());
    before.forEach((f) => firebase.deleteById(f.id));
    dynamic docs = await firebase.restoDao.fetch(RestaurantQuery());
    expect(docs.length, equals(0));
  }

  deleteAllProducts() async {
    var before = await firebase.fetchProducts(ProductQuery());
    before.forEach((f) => firebase.deleteProductById(f.id));
    var docs = await firebase.fetchProducts(ProductQuery());
    expect(docs.length, equals(0));
  }

  deleteAllCategories() async {
    restaus.forEach((resto) async {
      var dao = firebase.restoDao.getCategoryDao(resto.id);
      var categories = await dao.fetch(Object());
      await dao.deleteAll(categories);
      var docs = await dao.fetch(Object());
      expect(docs.length, equals(0));
    });
  }
}
