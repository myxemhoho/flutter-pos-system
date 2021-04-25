import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:possystem/helper/util.dart';
import 'package:possystem/services/database.dart';
import 'package:sprintf/sprintf.dart';

import 'product_model.dart';

class CatalogModel extends ChangeNotifier {
  CatalogModel({
    @required this.name,
    this.index = 0,
    String id,
    Map<String, ProductModel> products,
    DateTime createdAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        products = products ?? {},
        id = id ?? Util.uuidV4();

  final String id;
  // catalog's name
  String name;
  // index in menu
  int index;
  // when it has been added to menu
  final DateTime createdAt;
  // product list
  final Map<String, ProductModel> products;

  // I/O

  factory CatalogModel.fromMap(Map<String, dynamic> data) {
    final oriProducts = data['products'];
    final products = <String, ProductModel>{};

    final catalog = CatalogModel(
      id: data['id'],
      name: data['name'],
      index: data['index'],
      createdAt: data['createdAt'],
      products: products,
    );

    if (oriProducts is Map) {
      oriProducts.forEach((final key, final product) {
        if (key is String && product is Map) {
          products[key] = ProductModel.fromMap(
            catalog: catalog,
            data: {'id': key, ...product},
          );
        }
      });
    }

    return catalog;
  }

  factory CatalogModel.empty() {
    return CatalogModel(name: null, id: null);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'index': index,
      'createdAt': createdAt,
      'products': {
        for (var entry in products.entries) entry.key: entry.value.toMap()
      },
    };
  }

  // STATE CHANGE

  void update({
    String name,
    int index,
  }) {
    final updateData = _getUpdateData(
      name: name,
      index: index,
    );

    if (updateData.isEmpty) return;

    Database.instance.update(Collections.menu, updateData);

    notifyListeners();
  }

  Future<void> reorderProducts(List<ProductModel> products) async {
    for (var i = 0, n = products.length; i < n; i++) {
      products[i].update(index: i + 1);
    }

    notifyListeners();
  }

  void updateProduct(ProductModel product) {
    if (!products.containsKey(product.id)) {
      products[product.id] = product;
      final updateData = {'$id.products.${product.id}': product.toMap()};

      Database.instance.update(Collections.menu, updateData);
    }
    notifyListeners();
  }

  void removeProduct(String productId) {
    products.remove(productId);

    Database.instance.update(Collections.menu, {
      '$id.products.$productId': null,
    });

    notifyListeners();
  }

  void productChanged() {
    notifyListeners();
  }

  // HELPER

  Map<String, dynamic> _getUpdateData({
    String name,
    int index,
  }) {
    final updateData = <String, dynamic>{};
    if (index != null && index != this.index) {
      this.index = index;
      updateData['$id.index'] = index;
    }
    if (name != null && name != this.name) {
      this.name = name;
      updateData['$id.name'] = name;
    }
    return updateData;
  }

  ProductModel operator [](String name) => products[name];

  // GETTER

  ProductModel getProduct(String productId) {
    try {
      return products.values.firstWhere((e) => e.id == productId);
    } catch (e) {
      return null;
    }
  }

  List<ProductModel> get productList {
    final productList = products.values.toList();
    productList.sort((a, b) => a.index.compareTo(b.index));
    return productList;
  }

  int get newIndex {
    var maxIndex = 0;
    products.forEach((key, product) {
      if (product.index > maxIndex) {
        maxIndex = product.index;
      }
    });
    return maxIndex + 1;
  }

  String get createdDate {
    return sprintf('%04d-%02d-%02d', [
      createdAt.year,
      createdAt.month,
      createdAt.day,
    ]);
  }

  bool get isEmpty => length == 0;
  bool get isNotEmpty => length != 0;
  bool get isReady => name != null;
  int get length => products.length;
}
