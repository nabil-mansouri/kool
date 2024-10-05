import 'package:flutter_test/flutter_test.dart' hide group;
import 'package:test/test.dart' show group;
import '../restaurants.dart';
import '../domain/factory.dart';
import 'package:food/commerce/commerce.dart';
import 'utils.dart';

startServiceTest(RestaurantTestUtils testUtils) {
  group("[Service]", () {
    final restaus = testUtils.restaus;
    final firebase = testUtils.firebase;
    final center = testUtils.center;
    final products = testUtils.products;
    final categories = testUtils.categories;

    setUpAll(() async {
      print("[Restaurant][Service] settup all");
      await testUtils.deleteAllRestaurants();
      await testUtils.deleteAllProducts();
      await testUtils.deleteAllCategories();
    });

    test('should create restaurants', () async {
      var current = testUtils.restaus[0];
      await testUtils.firebase.create(current, forceId: current.id);
      var founded = await testUtils.firebase.fetchById(current.id);
      expect(founded, isNotNull);
      expect(founded.toJSON(), equals(current.toJSON()));
    });

    test('should create restaurants with slots', () async {
      var current = restaus[1];
      current.slots = RestaurantFactory.slots(5);
      await firebase.create(current, forceId: current.id);
      var founded = await firebase.fetchById(current.id);
      expect(founded, isNotNull);
      expect(founded.slots.length, equals(5));
      expect(founded.toJSON(), equals(current.toJSON()));
    });

    test('should create other restaus', () async {
      var current = restaus.sublist(1);
      List<Future> futures =
          current.map((f) => firebase.create(f, forceId: f.id)).toList();
      await Future.wait(futures);
    });

    test('should fetch all restaurants', () async {
      var res = await firebase.fetch(
          RestaurantQuery(
              order: RestaurantOrderQuery.Position,
              location: GeoPlace.fromLatLon(
                latitude: center.latitude,
                longitude: center.longitude,
              )),
          30);
      expect(res.length, equals(10));
    });

    test('should fetch restaurants order by location', () async {
      var res = await firebase.fetch(
          RestaurantQuery(
              acceptTicket: true,
              importantTag: "notsame",
              tag: "indien",
              order: RestaurantOrderQuery.Position,
              location: GeoPlace.fromLatLon(
                latitude: center.latitude,
                longitude: center.longitude,
              )),
          3);
      expect(res.length, equals(2));
      expect(res[0].id, equals("restaurant0"));
      expect(res[1].id, equals("restaurant2"));
    });

    test('should fetch restaurants order by delay', () async {
      var res = await firebase.fetch(
          RestaurantQuery(
              acceptTicket: false,
              importantTag: "same",
              tag: "indien",
              order: RestaurantOrderQuery.Delay,
              location: GeoPlace.fromLatLon(
                  latitude: center.latitude, longitude: center.longitude)),
          6);
      expect(res.length, equals(5));
      expect(res[0].id, equals("restaurant5"));
      expect(res[1].id, equals("restaurant6"));
      expect(res[2].id, equals("restaurant7"));
    });

    test('should fetch restaurants order by rating', () async {
      var res = await firebase.fetch(
          RestaurantQuery(
              acceptTicket: false,
              importantTag: "same",
              tag: "indien",
              order: RestaurantOrderQuery.Notes,
              location: GeoPlace.fromLatLon(
                  latitude: center.latitude, longitude: center.longitude)),
          6);
      expect(res.length, equals(5));
      expect(res[0].id, equals("restaurant9"));
      expect(res[1].id, equals("restaurant8"));
      expect(res[2].id, equals("restaurant7"));
    });

    test('should fetch restaurants order by popularity', () async {
      var res = await firebase.fetch(
          RestaurantQuery(
              acceptTicket: false,
              importantTag: "same",
              tag: "indien",
              order: RestaurantOrderQuery.Popularity,
              location: GeoPlace.fromLatLon(
                  latitude: center.latitude, longitude: center.longitude)),
          6);
      expect(res.length, equals(5));
      expect(res[0].id, equals("restaurant9"));
      expect(res[1].id, equals("restaurant8"));
      expect(res[2].id, equals("restaurant7"));
    });

    test('should fetch restaurants order by price', () async {
      var res = await firebase.fetch(
          RestaurantQuery(
              acceptTicket: false,
              importantTag: "same",
              tag: "indien",
              order: RestaurantOrderQuery.Price,
              location: GeoPlace.fromLatLon(
                  latitude: center.latitude, longitude: center.longitude)),
          6);
      expect(res.length, equals(5));
      expect(res[0].id, equals("restaurant5"));
      expect(res[1].id, equals("restaurant6"));
      expect(res[2].id, equals("restaurant7"));
    });

    test('should filter by accept ticket', () async {
      var res = await firebase.fetch(
          RestaurantQuery(
              acceptTicket: true,
              order: RestaurantOrderQuery.Position,
              location: GeoPlace.fromLatLon(
                  latitude: center.latitude, longitude: center.longitude)),
          6);
      expect(res.length, equals(5));
      res.forEach((f) => expect(f.acceptTicket, isTrue));
    });

    test('should filter by important tag', () async {
      var res = await firebase.fetch(
          RestaurantQuery(
              importantTag: "same",
              order: RestaurantOrderQuery.Position,
              location: GeoPlace.fromLatLon(
                  latitude: center.latitude, longitude: center.longitude)),
          8);
      expect(res.length, equals(5));
      res.forEach((f) => expect(f.tags.contains("same"), isTrue));
    });

    test('should filter by tag', () async {
      var res = await firebase.fetch(
          RestaurantQuery(
              tag: "true",
              order: RestaurantOrderQuery.Position,
              location: GeoPlace.fromLatLon(
                  latitude: center.latitude, longitude: center.longitude)),
          8);
      expect(res.length, equals(5));
      res.forEach((f) => expect(f.tags.contains("true"), isTrue));
    });

    test('should fetch with cursor', () async {
      var cursor = firebase.fetchCursor(
          RestaurantQuery(
              limit: 150,
              tag: "notsame",
              order: RestaurantOrderQuery.Position,
              location: GeoPlace.fromLatLon(
                  latitude: center.latitude, longitude: center.longitude)),
          addRadius: 2,
          maxRadius: 10,
          minNumberOfData: 2);
      int count = 0;
      while (!cursor.finished) {
        var result = await cursor.next();
        expect(result.length, equals(count < 2 ? 2 : 1));
        count++;
      }
      expect(count, equals(3));
    });

    test('should create products', () async {
      var current = products[0];
      await firebase.createProduct(current, forceId: current.id);
      var founded = await firebase.fetchProductById(current.id);
      expect(founded, isNotNull);
      expect(founded.toJSON(), equals(current.toJSON()));
    });

    test('should create other products', () async {
      var current = products.sublist(1);
      List<Future> futures =
          current.map((f) => firebase.createProduct(f, forceId: f.id)).toList();
      await Future.wait(futures);
    });

    test('should fetch all products', () async {
      var res = await firebase.fetchProducts(ProductQuery());
      expect(res.length, equals(25));
    });

    test('should fetch product for restaurant', () async {
      var res = await firebase
          .fetchProducts(ProductQuery(restaurantId: "restaurant0"));
      expect(res.length, equals(5));
    });

    test('should fetch restaurant detail', () async {
      var resto = await firebase.fetchById("restaurant1");
      var res = await firebase.fetchDetail(resto);
      expect(res.slots.length, equals(5));
      expect(res.products.length, equals(5));
    });

    test('should create category', () async {
      var current = categories[0];
      final firstResto = restaus[0];
      await firebase.createCategory(firstResto.id, current,
          forceId: current.id);
      var founded = await firebase.fetchCategoryById(firstResto.id, current.id);
      expect(founded, isNotNull);
      expect(founded.toJSON(), equals(current.toJSON()));
    });

    test('should create other categories', () async {
      var current = categories.sublist(1);
      final firstResto = restaus[0];
      List<Future> futures = current
          .map((f) => firebase.createCategory(firstResto.id, f, forceId: f.id))
          .toList();
      await Future.wait(futures);
    });

    test('should fetch all categories', () async {
      final firstResto = restaus[0];
      var res = await firebase.fetchCategories(firstResto.id, Object());
      expect(res.length, equals(5));
    });
  });
}
