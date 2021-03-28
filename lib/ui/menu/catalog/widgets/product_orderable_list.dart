import 'package:flutter/material.dart';
import 'package:possystem/components/page/orderable_list.dart';
import 'package:possystem/models/catalog_model.dart';
import 'package:possystem/models/product_model.dart';
import 'package:provider/provider.dart';

class ProductOrderableList extends OrderableList<ProductModel> {
  ProductOrderableList({Key key, @required List<ProductModel> items})
      : super(key: key, items: items, title: '排序產品');

  @override
  _ProductOrderListState createState() => _ProductOrderListState();
}

class _ProductOrderListState extends OrderableListState<ProductModel, int> {
  @override
  Future<void> onSubmit() async {
    final catalog = context.read<CatalogModel>();

    for (var i = 0, n = widget.items.length; i < n; i++) {
      widget.items[i].update(index: i + 1);
    }

    catalog.productChanged();
  }

  @override
  Widget itemBuilder(BuildContext context, int index) {
    final item = widget.items[index];
    return OrderableListItem(
      key: ValueKey(item.index),
      index: index,
      title: item.name,
    );
  }

  @override
  int get itemCount => widget.items.length;
}