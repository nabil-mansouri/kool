import 'package:food/commerce/commerce.dart';
import 'contract.dart';
import '../models.dart';
import '../factory.dart';
import 'last_query.dart';

class RestaurantServiceMock
    with ProductServiceMock, LastQueryMixin
    implements RestaurantService {
  static RestaurantServiceMock _instance;

  static RestaurantServiceMock getInstance() {
    if (_instance == null) {
      _instance = RestaurantServiceMock();
    }
    return _instance;
  }

  Future<ProductModel> createProduct(ProductModel model, {String forceId}) {
    return Future.value();
  }

  Future<ProductModel> fetchProductById(String id) {
    return Future.value();
  }

  Future<RestaurantDetailModel> fetchDetail(RestaurantModel restaurant) async {
    return Future.delayed(
        Duration(milliseconds: 1000),
        () => new RestaurantDetailModel(
                categories: [
                  ProductCategory(id: "burger", name: "Burger", position: 0),
                  ProductCategory(
                      id: "sandwich", name: "Sandwich", position: 1),
                  ProductCategory(id: "yaourt", name: "Yaourt", position: 2)
                ],
                products: RestaurantFactory.products(10, restaurant.id),
                slots: RestaurantFactory.slots(10)));
  }

  Future<List<RestaurantModel>> fetch(
      RestaurantQuery query, double radius) async {
    query = query ?? RestaurantQuery();
    query.limit = query.limit ?? 10;
    return Future.delayed(Duration(milliseconds: 1000),
        () => RestaurantFactory.restaurants(query.limit));
  }

  RestaurantListCursor fetchCursor(RestaurantQuery query,
      {double maxRadius, double addRadius, int minNumberOfData}) {
    return null;
  }

  Future<void> deleteById(String id, {bool withCategories}) {
    return Future.value(null);
  }

  Future<RestaurantModel> fetchById(String id) {
    return Future.value(RestaurantFactory.restaurants(1)[0]);
  }

  Future<RestaurantModel> create(RestaurantModel model, {String forceId}) {
    return Future.value(model);
  }

  Future<List<ProductModel>> fetchProducts(ProductQuery query) async {
    return RestaurantFactory.products(10, query.restaurantId);
  }

  Future<void> deleteProductById(String id, {bool withDetail}) {
    return Future.value();
  }
}
