import 'models.dart';
import 'dart:math';
import 'package:food/commerce/commerce.dart';

abstract class GeoPointGenerator {
  double get latitude;
  double get longitude;
  GeoPointGenerator();
  void next(int index);
}

class RestaurantFactory {
  static final rng = new Random();
  static List<ProductModel> products(int nb, String restaurantId) {
    return ProductFactory.products(nb, restaurantId);
  }

  static Future<List<ProductDetailModel>> productDetails(
      int nb, String restaurantId) {
    return ProductFactory.productDetails(nb, restaurantId);
  }

  static List<OpenSlotModel> slots(int nb) {
    return List.generate(
        nb,
        (index) => OpenSlotModel(
            day: (index % 7) + 1,
            dayFormat: [
              "Lundi",
              "Mardi",
              "Mercredi",
              "Jeudi",
              "Vendredi",
              "Samedi",
              "Dimanche"
            ][index % 7],
            openMinute: index >= 7 ? 960 : 480,
            openFormat: index >= 7 ? "13H" : "8H",
            closeMinute: index >= 7 ? 1320 : 780,
            closeFormat: index >= 7 ? "20H" : "15H"));
  }

  static List<RestaurantModel> restaurants(int nb,
      [GeoPointGenerator geoGenerator]) {
    return List.generate(nb, (index) {
      if (geoGenerator != null) geoGenerator.next(index);
      return RestaurantModel(
          id: "restaurant-$index",
          name: "Upper Café",
          latitude: geoGenerator != null ? geoGenerator.latitude : 0,
          longitude: geoGenerator != null ? geoGenerator.longitude : 0,
          closed: index % 5 != 0,
          address: "119 Rue Ordener 75017 Paris",
          image:
              "https://image.afcdn.com/recipe/20170105/24149_w1024h768c1cx2592cy1728.jpg",
          rating: rng.nextDouble() * 5,
          delayFormat: "20 min",
          tags: ["Burger", "Americain", "Fish & Chips"]);
    });
  }

  static List<RestaurantModel> restaurantsForTests(
      int nb, GeoPointGenerator geoGenerator,
      {int offsetId = 0, bool samePoint = false, String tag = "yop"}) {
    return List.generate(nb, (fakeIndex) {
      var index = fakeIndex + offsetId;
      if (!samePoint) geoGenerator.next(index);
      return RestaurantModel(
          id: "restaurant$index",
          name: "Restaurant$index",
          nameSearch: "restaurant$index",
          acceptTicket: index % 2 == 0,
          available: index % 2 == 0,
          closed: index % 2 == 0,
          slots: [],
          delayMean: 10 * index,
          popularity: 1000 * index,
          priceMean: 2.0 * index,
          latitude: geoGenerator.latitude,
          longitude: geoGenerator.longitude,
          image:
              "https://image.afcdn.com/recipe/20170105/24149_w1024h768c1cx2592cy1728.jpg",
          rating: (index % 5) * 1.0,
          delayFormat: "20 min",
          tags: ["indien", "halal", tag, "${index % 2 == 0}"]);
    });
  }

  static List<ProductModel> productsForTest(int nb, {String restaurantId}) {
    return ProductFactory.productsForTest(nb, restaurantId: restaurantId);
  }

  static List<ProductCategory> categoryForTest(int nb) {
    return ProductFactory.categoryForTest(nb);
  }

  static Future<List<ProductCategory>> category() {
    return ProductFactory.category();
  }
}
