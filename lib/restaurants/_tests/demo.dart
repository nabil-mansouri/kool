import 'package:flutter_test/flutter_test.dart' hide group;
import 'package:food/commerce/commerce.dart';
import '../restaurants.dart';
import '../domain/factory.dart';
import 'utils.dart';

demo() async {
  final center = RestaurantTestUtils().center;
  print("demo preparing...");
  final RestaurantServiceFirebase rService = RestaurantServiceFirebase(
      catName: "categories",
      productName: "products",
      restoColName: "restaurants");
  final ProductService pService = ProductServiceFirebase(
      productName: "products", productDetailName: "product_detail");
  //CLEAN RESTO
  final oldRestaus = await rService.restoDao.fetch(RestaurantQuery());
  List<Future> promises = [];
  for (final r in oldRestaus) {
    promises.add(rService.deleteById(r.id, withCategories: true));
  }
  await Future.wait(promises);
  //CREATE RESTO
  var newRestaus =
      RestaurantFactory.restaurants(25, GeoPointGeneratorImpl(center));
  newRestaus = await rService.restoDao.createAll(newRestaus, forceId: true);
  //CREATE CATEGORIES
  final List<ProductCategory> categories = await RestaurantFactory.category();
  newRestaus.forEach((resto) async {
    await rService.restoDao
        .getCategoryDao(resto.id)
        .createAll(categories, forceId: true);
  });
  //GENERATE PRODUCTS
  final List<ProductDetailModel> details = [];
  newRestaus.sublist(0, 5).forEach((resto) async {
    details.addAll(await RestaurantFactory.productDetails(10, resto.id));
  });
  //CLEAN PRODUCT
  final products = await pService.fetchProducts(ProductQuery());
  promises = [];
  for (final p in products) {
    promises.add(pService.deleteProductById(p.id, withDetail: true));
  }
  await Future.wait(promises);
  //CREATE PRODUCT
  for (ProductDetailModel detail in details) {
    await pService.createProductDetail(detail, saveProduct: true);
  }
  print("demo prepared");
}
