import 'models.dart';
import 'dart:math';
import 'package:yaml/yaml.dart';
import 'package:flutter/services.dart' show rootBundle;

dynamic cache;
_fileFactory() async {
  if (cache != null) {
    return cache;
  }
  final text =
      await rootBundle.loadString('assets/factory/products.yaml', cache: false);
  cache = loadYaml(text);
  return cache;
}

class ProductFactory {
  static final rng = new Random();

  static _buildProduct(String restaurantId, dynamic currentProduct) {
    return ProductModel(
        restaurantId: restaurantId,
        id: restaurantId + "-" + currentProduct['id'],
        name: currentProduct['name'],
        description: currentProduct['description'],
        priceCents: currentProduct['priceCents'],
        rating: currentProduct['rating'],
        available: currentProduct['available'],
        categories: (currentProduct['categories'] as YamlList)
            .map((f) => f.toString())
            .toList(),
        tags: (currentProduct['tags'] as YamlList)
            .map((f) => f.toString())
            .toList(),
        image: currentProduct['image']);
  }

  static List<ProductModel> products(int nb, String restaurantId) {
    final yamlProducts = ["products"];
    final int nbProducts = yamlProducts.length;
    return List.generate(nb, (index) {
      int realIndex = index % nbProducts;
      final currentProduct = yamlProducts[realIndex];
      return _buildProduct(restaurantId, currentProduct);
    });
  }

  static Future<List<ProductCategory>> category() async {
    final yamlCategories = (await _fileFactory())["categories"];
    final int nbCategories = yamlCategories.length;
    return List.generate(nbCategories, (index) {
      final yamlCategory = yamlCategories[index];
      return ProductCategory(
          id: yamlCategory["id"],
          name: yamlCategory["name"],
          position: yamlCategory["position"],
          description: yamlCategory["description"],
          image: yamlCategory["image"]);
    });
  }

  static Future<List<ProductDetailModel>> productDetails(
      int nb, String restaurantId) async {
    final yamlProducts = (await _fileFactory())["products"];
    final int nbProducts = yamlProducts.length;
    return List.generate(nb, (index) {
      int realIndex = index % nbProducts;
      final currentProduct = yamlProducts[realIndex];
      ProductDetailModel detail = ProductDetailModel(groups: []);
      detail.product = _buildProduct(restaurantId, currentProduct);
      final productGroup = currentProduct["groups"];
      if (productGroup != null) {
        for (final group in productGroup) {
          final groupModel = ProductGroupModel(
              available: group["available"],
              description: group["description"],
              id: group["id"],
              image: group["image"],
              maxSelection: group["maxSelection"],
              minSelection: group["minSelection"],
              mandatory: group["mandatory"],
              name: group["name"]);
          final itemGroups = group["items"];
          if (itemGroups != null) {
            for (final item in itemGroups) {
              groupModel.items.add(ProductItemModel(
                  available: item["available"],
                  description: item["description"],
                  id: item["id"],
                  image: item["image"],
                  name: item["name"],
                  priceCents: item["priceCents"]));
            }
          }
          detail.groups.add(groupModel);
        }
      }
      return detail;
    });
  }

  static List<ProductModel> productsForTest(int nb, {String restaurantId}) {
    return List.generate(
        nb,
        (index) => ProductModel(
            id: "$restaurantId-product$index",
            name: "Product$index",
            restaurantId: restaurantId,
            description:
                "Steack 100g, boursin, bacon, oignons frits, tomates confits. Salade tomate et oignons avec sauce à l'ail et fines herbes.",
            priceCents: index + 1,
            rating: rng.nextDouble() * 5,
            available: index % 5 != 0,
            categories: index < 3 ? ["category0", "category1"] : ["category2"],
            tags: ["burger", "salade"],
            image:
                "https://image.afcdn.com/recipe/20170105/24149_w1024h768c1cx2592cy1728.jpg"));
  }

  static List<ProductCategory> categoryForTest(int nb) {
    return List.generate(
        nb,
        (index) => ProductCategory(
            id: "category$index",
            name: "Categorie$index",
            position: index,
            description:
                "Steack 100g, boursin, bacon, oignons frits, tomates confits. Salade tomate et oignons avec sauce à l'ail et fines herbes.",
            image:
                "https://image.afcdn.com/recipe/20170105/24149_w1024h768c1cx2592cy1728.jpg"));
  }
}
