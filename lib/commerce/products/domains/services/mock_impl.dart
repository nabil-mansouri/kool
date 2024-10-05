import 'contract.dart';
import '../models.dart';
import '../factory.dart';

class ProductServiceMock implements ProductService {
  static ProductServiceMock _instance;

  static ProductServiceMock getInstance() {
    if (_instance == null) {
      _instance = ProductServiceMock();
    }
    return _instance;
  }

  fetchProductDetail(product) {
    return Future.value();
  }

  Future<ProductModel> createProduct(ProductModel model, {String forceId}) {
    return Future.value();
  }

  Future<ProductModel> fetchProductById(String id) {
    return Future.value();
  }

  Future<ProductDetailModel> createProductDetail(ProductDetailModel detail,
      {bool saveProduct}) {
    return Future.value();
  }

  Future<ProductDetailModel> fetchProductDetailById(String productId) async {
    ProductModel product = await fetchProductById(productId);
    return fetchProductDetail(product);
  }

  Future<List<ProductModel>> fetchProducts(ProductQuery query) async {
    return ProductFactory.products(10, query.restaurantId);
  }

  Future<void> deleteProductById(String id, {bool withDetail}) {
    return Future.value();
  }
}
