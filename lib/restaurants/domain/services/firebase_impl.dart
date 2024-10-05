import 'dart:async';
import 'package:food/commerce/commerce.dart';
import 'contract.dart';
import '../models.dart';
import 'firebase_cursor.dart';
import 'firebase_daos.dart';
import 'last_query.dart';

class RestaurantServiceFirebase
    with LastQueryMixin
    implements RestaurantService {
  final RestaurantFirebaseDao restoDao;
  final ProductServiceFirebase productService;
  RestaurantServiceFirebase(
      {String restoColName = "restaurants",
      String productName = "products",
      String catName = "categories"})
      : restoDao =
            RestaurantFirebaseDao(restoColName, categoryColName: catName),
        productService = ProductServiceFirebase(productName: productName);
  RestaurantListCursor fetchCursor(RestaurantQuery query,
      {double maxRadius, double addRadius, int minNumberOfData}) {
    return RestaurantListCursorImpl(query, this.restoDao,
        maxRadius: maxRadius,
        addRadius: addRadius,
        minNumberOfData: minNumberOfData);
  }

  Future<void> deleteById(String id, {bool withCategories = false}) async {
    await this.restoDao.deleteById(id);
    if (withCategories) {
      final dao = this.restoDao.getCategoryDao(id);
      final categories = await dao.fetch({});
      await dao.deleteAll(categories);
    }
    return null;
  }

  Future<RestaurantModel> fetchById(String id) async {
    return restoDao.fetchById(id);
  }

  Future<List<RestaurantModel>> fetch(RestaurantQuery query, double radius) {
    query = query ?? RestaurantQuery();
    return RestaurantListCursorImpl(query, this.restoDao,
            maxRadius: radius, addRadius: radius, minNumberOfData: query.limit)
        .next();
  }

  Future<RestaurantDetailModel> fetchDetail(RestaurantModel model) async {
    Future<List<ProductModel>> fProduct =
        this.productService.fetchProducts(ProductQuery(restaurantId: model.id));
    Future<List<ProductCategory>> fCategories =
        this.restoDao.getCategoryDao(model.id).fetch(Object());
    await Future.wait([fProduct, fCategories]);
    List<ProductModel> products = await fProduct;
    List<OpenSlotModel> slots = model.slots;
    List<ProductCategory> categories = await fCategories;
    return RestaurantDetailModel(
        categories: categories, slots: slots, products: products);
  }

  Future<RestaurantModel> create(RestaurantModel model,
      {String forceId}) async {
    return this.restoDao.create(model, forceId: forceId);
  }

  Future<ProductModel> fetchProductById(String id) async {
    return productService.fetchProductById(id);
  }

  Future<ProductModel> createProduct(ProductModel model,
      {String forceId}) async {
    return productService.createProduct(model);
  }

  Future<List<ProductModel>> fetchProducts(ProductQuery query) async {
    return productService.fetchProducts(query);
  }

  Future<void> deleteProductById(String id) {
    return productService.deleteProductById(id);
  }

  Future<List<ProductCategory>> fetchCategories(
      String restaurantId, Object query) async {
    return this.restoDao.getCategoryDao(restaurantId).fetch(query);
  }

  Future<ProductCategory> fetchCategoryById(
      String restaurantId, String id) async {
    return this.restoDao.getCategoryDao(restaurantId).fetchById(id);
  }

  Future<ProductCategory> createCategory(
      String restaurantId, ProductCategory model,
      {String forceId}) async {
    return this
        .restoDao
        .getCategoryDao(restaurantId)
        .create(model, forceId: forceId);
  }

  Future<void> deleteCategory(String restaurantId, String id) {
    return this.restoDao.getCategoryDao(restaurantId).deleteById(id);
  }
}
