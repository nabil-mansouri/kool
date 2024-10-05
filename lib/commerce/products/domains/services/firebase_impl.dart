import 'contract.dart';
import '../models.dart';
import 'firebase_daos.dart';

class ProductServiceFirebase extends ProductService {
  final ProductFirebaseDao productDao;
  ProductServiceFirebase(
      {String productName = "products",
      String productDetailName = "product_detail"})
      : productDao =
            ProductFirebaseDao(productName, detailName: productDetailName);

  Future<ProductModel> fetchProductById(String id) async {
    return this.productDao.fetchById(id);
  }

  Future<ProductModel> createProduct(ProductModel model,
      {String forceId}) async {
    return this.productDao.create(model, forceId: forceId);
  }

  Future<List<ProductModel>> fetchProducts(ProductQuery query) async {
    return this.productDao.fetch(query);
  }

  Future<void> deleteProductById(String id, {bool withDetail = false}) async {
    await this.productDao.deleteById(id);
    if (withDetail) {
      final daoGroup = this.productDao.getGroups(id);
      final details = await daoGroup.fetch({});
      await daoGroup.deleteAll(details);
    }
    return null;
  }

  Future<ProductDetailModel> createProductDetail(ProductDetailModel detail,
      {bool saveProduct = false}) async {
    if (saveProduct) {
      detail.product =
          await productDao.create(detail.product, forceId: detail.product.id);
    }
    final dao = this.productDao.getGroups(detail.product.id);
    detail.groups = await dao.createAll(detail.groups, forceId: true);
    return detail;
  }

  Future<ProductDetailModel> fetchProductDetailById(String productId) async {
    ProductModel product = await fetchProductById(productId);
    return fetchProductDetail(product);
  }

  Future<ProductDetailModel> fetchProductDetail(ProductModel product) async {
    final groups = await this.productDao.getGroups(product.id).fetch({});
    ProductDetailModel detail =
        ProductDetailModel(groups: groups, product: product);
    return detail;
  }
}
