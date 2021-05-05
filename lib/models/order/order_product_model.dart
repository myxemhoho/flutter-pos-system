import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/menu/product_ingredient_model.dart';
import 'package:possystem/models/menu/product_model.dart';
import 'package:possystem/models/order/order_ingredient_model.dart';

class OrderProductModel {
  OrderProductModel(
    this.product, {
    this.count = 1,
    num singlePrice,
    this.ingredients = const [],
  }) : singlePrice = singlePrice ?? product.price;

  ProductModel product;
  bool isSelected = false;
  num singlePrice;
  int count;
  final List<OrderIngredientModel> ingredients;

  num get price => count * singlePrice;
  Iterable<String> get ingredientNames => ingredients.map((e) => e.toString());

  void increment([int value = 1]) => setCount(value);
  void decrement([int value = 1]) => setCount(-value);
  void setCount(int value) {
    count += value;
    notifyListener(OrderProductListenerTypes.count);
  }

  OrderProductObject toMap() {
    final allIngredients = <String, OrderIngredientObject>{
      for (var ingredientEntry in product.ingredients.entries)
        ingredientEntry.key: OrderIngredientObject(
          ingredientId: ingredientEntry.key,
          name: ingredientEntry.value.ingredient.name,
          cost: ingredientEntry.value.cost,
          amount: ingredientEntry.value.amount,
        )
    };
    ingredients.forEach((ingredient) {
      allIngredients[ingredient.id].update(
        cost: ingredient.cost,
        amount: ingredient.amount,
        price: ingredient.price,
        quantityId: ingredient.quantity.id,
      );
    });

    return OrderProductObject(
      singlePrice: singlePrice,
      count: count,
      productId: product.id,
      productName: product.name,
      isDiscount: singlePrice != product.price,
      ingredients: allIngredients,
    );
  }

  bool toggleSelected([bool checked]) {
    checked ??= !isSelected;
    final changed = isSelected != checked;

    if (changed) {
      isSelected = checked;
      notifyListener(OrderProductListenerTypes.selection);
    }

    return changed;
  }

  OrderIngredientModel getIngredientOf(String id) {
    try {
      return ingredients.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  void addIngredient(OrderIngredientModel newOne) {
    var i = 0;
    for (var oldOne in ingredients) {
      if (oldOne == newOne) {
        singlePrice -= oldOne.price;
        ingredients.removeAt(i);
        break;
      }
      i++;
    }

    singlePrice += newOne.price;
    ingredients.add(newOne);
  }

  void removeIngredient(ProductIngredientModel ingredient) {
    ingredients.removeWhere((e) {
      if (e.ingredient.id == ingredient.id) {
        singlePrice -= e.price;
        return true;
      }
      return false;
    });
  }

  // Custom Listeners for performace

  static final listeners = <OrderProductListenerTypes, List<void Function()>>{
    OrderProductListenerTypes.count: [],
    OrderProductListenerTypes.selection: [],
  };
  static void addListener(
    void Function() listener, [
    OrderProductListenerTypes type,
  ]) {
    if (type != null) return listeners[type].add(listener);

    listeners[OrderProductListenerTypes.count].add(listener);
    listeners[OrderProductListenerTypes.selection].add(listener);
  }

  static void removeListener(void Function() listener) {
    listeners[OrderProductListenerTypes.count].remove(listener);
    listeners[OrderProductListenerTypes.selection].remove(listener);
  }

  static void notifyListener([OrderProductListenerTypes type]) {
    if (type != null) return listeners[type].forEach((lisnter) => lisnter());

    listeners[OrderProductListenerTypes.count].forEach((e) => e());
    listeners[OrderProductListenerTypes.selection].forEach((e) => e());
  }
}

enum OrderProductListenerTypes {
  count,
  selection,
}