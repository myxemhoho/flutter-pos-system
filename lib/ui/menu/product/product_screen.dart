import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/icon_text.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/scaffold/fade_in_title_scaffold.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:provider/provider.dart';

import 'widgets/ingredient_expansion.dart';

class ProductScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = context.watch<Product>();

    final textTheme = Theme.of(context).textTheme;

    final navigateNewIngredient = () => Navigator.of(context).pushNamed(
          Routes.menuIngredient,
          arguments: product,
        );

    final metadata = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Tooltip(
          message: tt('menu.product.label.price'),
          child: IconText(
            text: product.price.toString(),
            icon: Icons.loyalty_sharp,
          ),
        ),
        MetaBlock(),
        Tooltip(
          message: tt('menu.product.label.cost'),
          child: IconText(
            text: product.cost.toString(),
            icon: Icons.attach_money_sharp,
          ),
        ),
      ],
    );

    final body = product.isEmpty
        ? EmptyBody(title: '可以設定產品的成份囉！', onPressed: navigateNewIngredient)
        : IngredientExpansion(ingredients: product.itemList);

    return FadeInTitleScaffold(
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(KIcons.back),
      ),
      title: product.name,
      trailing: IconButton(
        onPressed: () => showCircularBottomSheet(
          context,
          actions: _actions(product),
        ),
        icon: Icon(KIcons.more),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateNewIngredient,
        tooltip: tt('menu.integredient.add'),
        child: Icon(KIcons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(kSpacing3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(product.name, style: textTheme.headline4),
                metadata,
              ],
            ),
          ),
          body,
        ],
      ),
    );
  }

  List<BottomSheetAction> _actions(Product product) {
    return [
      BottomSheetAction(
        title: Text(tt('menu.product.edit')),
        leading: Icon(Icons.text_fields_sharp),
        onTap: (context) {
          Navigator.of(context).pushReplacementNamed(
            Routes.menuProductModal,
            arguments: product,
          );
        },
      ),
    ];
  }
}
