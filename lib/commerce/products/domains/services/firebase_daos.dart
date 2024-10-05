import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food/commons/firebase_dao.dart';
import '../models.dart';
import 'contract.dart';
import 'package:meta/meta.dart';

class ProductFirebaseDao
    extends AbstractFirebaseDao<ProductQuery, ProductModel> {
  final String detailName;
  ProductFirebaseDao(String col, {@required this.detailName}) : super(col);
  ProductModel fromFirebase(Map<String, dynamic> json,
      {String id, ProductQuery query}) {
    var model = ProductModel.fromJson(json);
    model.id = id;
    return model;
  }

  Map<String, dynamic> toFirebase(ProductModel model) {
    return model.toJSON();
  }

  Query toQuery(Query fQuery, ProductQuery query) {
    if (query.restaurantId != null) {
      fQuery = fQuery.where("restaurantId", isEqualTo: query.restaurantId);
    }
    return fQuery;
  }

  ProductGroupFirebaseDao getGroups(String productId) {
    return ProductGroupFirebaseDao(
        this.ref.document(productId), this.detailName);
  }
}

class ProductGroupFirebaseDao
    extends AbstractFirebaseDao<Object, ProductGroupModel> {
  ProductGroupFirebaseDao(DocumentReference parent, String colName)
      : super.fromParent(parent, colName);
  ProductGroupModel fromFirebase(Map<String, dynamic> json,
      {String id, Object query}) {
    var model = ProductGroupModel.fromJson(json);
    return model;
  }

  Map<String, dynamic> toFirebase(ProductGroupModel model) {
    return model.toJSON();
  }

  Query toQuery(Query fQuery, Object query) {
    return fQuery;
  }
}

class ProductCategoryFirebaseDao
    extends AbstractFirebaseDao<Object, ProductCategory> {
  ProductCategoryFirebaseDao(DocumentReference parent, String colName)
      : super.fromParent(parent, colName);
  ProductCategory fromFirebase(Map<String, dynamic> json,
      {String id, Object query}) {
    var model = ProductCategory.fromJson(json);
    model.id = id;
    return model;
  }

  Map<String, dynamic> toFirebase(ProductCategory model) {
    return model.toJSON();
  }

  Query toQuery(Query fQuery, Object query) {
    return fQuery;
  }
}
