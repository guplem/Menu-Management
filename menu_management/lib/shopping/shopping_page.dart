import "dart:math";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/ingredients/ingredients_provider.dart";
import "package:menu_management/menu/models/menu.dart";
import "package:menu_management/recipes/models/quantity.dart";
import "package:menu_management/shopping/shopping_ingredient.dart";

class ShoppingPage extends StatefulWidget {
  const ShoppingPage({super.key, required this.menu});

  final Menu menu;

  @override
  State<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  late final Map<String, List<Quantity>> ingredientsRequired;
  late final Map<String, List<Quantity>> ingredientsOwned;

  @override
  void initState() {
    super.initState();
    ingredientsRequired = widget.menu.allIngredients;
    ingredientsOwned = ingredientsRequired.map(
      (key, value) => MapEntry(key, value.map((quantity) => Quantity(amount: 0, unit: quantity.unit)).toList()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Shopping List")),
      floatingActionButton: FloatingActionButton(
        tooltip: "Copy to clipboard",
        onPressed: () {
          // Create string (ignoring those with required <= 0). Format: "Ingredient: amount unit + amount unit + ..."
          String shoppingList = ingredientsRequired.entries
              .map((entry) {
                List<Quantity> remaining = remainingAmounts(ingredient: entry.key);
                return remaining.any((quantity) => quantity.amount > 0)
                    ? "${IngredientsProvider.instance.get(entry.key).name}: ${remaining.where((quantity) => quantity.amount > 0).map((quantity) => "${quantity.amount} ${quantity.unit.toString().split(".").last}").join(' + ')}"
                    : null;
              })
              .whereNotNull()
              .join("\n");
          // Copy to clipboard
          Clipboard.setData(ClipboardData(text: shoppingList));
        },
        child: const Icon(Icons.copy_rounded),
      ),
      body: ListView.builder(
        itemCount: ingredientsRequired.length,
        itemBuilder: (context, index) {
          return ShoppingIngredient(
            ingredient: getProvider<IngredientsProvider>(context, listen: true).get(ingredientsRequired.keyAt(index)),
            quantitiesDesired: ingredientsRequired.valueAt(index),
            ownedQuantities: ingredientsOwned[ingredientsRequired.keyAt(index)]!,
            calculatedRemainingQuantities: remainingAmounts(ingredient: ingredientsRequired.keyAt(index)),
            onOwnedAmountChanged: (List<Quantity> ownedQuantities) {
              setState(() => ingredientsOwned[ingredientsRequired.keyAt(index)] = ownedQuantities);
            },
          );
        },
      ),
    );
  }

  List<Quantity> remainingAmounts({required String ingredient}) {
    int ingredientIndex = ingredientsRequired.keys.toList().indexOf(ingredient);
    List<Quantity> required = ingredientsRequired.valueAt(ingredientIndex);
    List<Quantity> owned = ingredientsOwned[ingredientsRequired.keyAt(ingredientIndex)]!;

    return required.map((quantityRequired) {
      Quantity ownedQuantity = owned.firstWhere((ownedQty) => ownedQty.unit == quantityRequired.unit);
      double amount = quantityRequired.amount - ownedQuantity.amount;
      return Quantity(amount: max(0, amount).roundToDouble(), unit: quantityRequired.unit);
    }).toList();
  }
}
