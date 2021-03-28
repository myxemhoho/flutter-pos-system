import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:possystem/models/menu_model.dart';
import 'package:provider/provider.dart';

import 'catalog_orderable_list.dart';

class MenuActions extends StatelessWidget {
  const MenuActions({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      actions: [
        CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pushReplacement(
            CupertinoPageRoute(
              builder: (BuildContext context) {
                final items = context.watch<MenuModel>().catalogList;
                return CatalogOrderableList(items: items);
              },
            ),
          ),
          child: Text('排序產品種類'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.pop(context, 'cancel'),
        child: Text('取消'),
      ),
    );
  }
}