import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/slidable_item_list.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/replenishment.dart';
import 'package:possystem/routes.dart';
import 'package:provider/provider.dart';

import 'package:possystem/translator.dart';

class ReplenishmentScreen extends StatelessWidget {
  const ReplenishmentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final replenisher = context.watch<Replenisher>();

    void navToAdd() =>
        Navigator.of(context).pushNamed(Routes.stockReplenishmentModal);

    final body = replenisher.isEmpty
        ? <Widget>[Expanded(child: EmptyBody(onPressed: navToAdd))]
        : <Widget>[
            Center(child: HintText(S.totalCount(replenisher.length))),
            Expanded(
              child: SingleChildScrollView(
                child: SlidableItemList<Replenishment, int>(
                  handleDelete: (item) => item.remove(),
                  deleteValue: 1,
                  warningContextBuilder: (_, item) =>
                      Text(S.dialogDeletionContent(item.name, '')),
                  items: replenisher.itemList,
                  tileBuilder: (_, index, item) => _ReplenishmentTile(item),
                ),
              ),
            ),
          ];

    return Scaffold(
      appBar: AppBar(
        title: Text(S.stockReplenishmentTitle),
        leading: const PopButton(),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('replenisher.add'),
        onPressed: navToAdd,
        tooltip: S.stockReplenishmentCreate,
        child: const Icon(KIcons.add),
      ),
      // this page need to draw lots of data, wait a will to make sure page shown
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: body,
      ),
    );
  }
}

class _ReplenishmentTile extends StatelessWidget {
  final Replenishment item;

  const _ReplenishmentTile(this.item);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        key: Key('replenisher.${item.id}'),
        title: Text(item.name),
        subtitle: Text(S.stockReplenishmentSubtitle(item.data.length)),
        onTap: () => Navigator.of(context).pushNamed(
              Routes.stockReplenishmentModal,
              arguments: item,
            ),
        trailing: IconButton(
          key: Key('replenisher.${item.id}.apply'),
          onPressed: () => handleApply(context),
          icon: const Icon(Icons.shopping_cart_sharp),
        ));
  }

  Future<void> handleApply(BuildContext context) async {
    final data = <String, num>{};
    item.data.forEach((key, value) {
      final ingredient = Stock.instance.getItem(key);
      if (ingredient != null) {
        data[ingredient.name] = value;
      }
    });

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: S.stockReplenishmentApplyConfirmTitle(item.name),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.stockReplenishmentApplyConfirmContent),
            const SizedBox(height: kSpacing1),
            DataTable(columns: const [
              DataColumn(label: Text('名稱')),
              DataColumn(numeric: true, label: Text('數量'))
            ], rows: <DataRow>[
              for (final entry in data.entries)
                DataRow(cells: [
                  DataCell(Text(entry.key)),
                  DataCell(Text(entry.value.toString())),
                ])
            ]),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    await item.apply();
    Navigator.of(context).pop(true);
  }
}