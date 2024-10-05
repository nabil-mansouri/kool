import '../models.dart';

class ProductQuery {
  String restaurantId;
  ProductQuery({this.restaurantId});
}

abstract class ProductService {
  Future<ProductModel> createProduct(ProductModel model, {String forceId});
  Future<List<ProductModel>> fetchProducts(ProductQuery query);
  Future<void> deleteProductById(String id, {bool withDetail});
  Future<ProductModel> fetchProductById(String id);
  Future<ProductDetailModel> fetchProductDetailById(String productId);
  Future<ProductDetailModel> fetchProductDetail(ProductModel product);
  Future<ProductDetailModel> createProductDetail(ProductDetailModel detail,
      {bool saveProduct});
}
