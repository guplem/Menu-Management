import 'dart:math';

import 'package:flutter/material.dart';
import 'package:menu_management/flutter_essentials/library.dart';
import 'package:menu_management/ingredients/models/ingredient.dart';
import 'package:menu_management/menu/models/menu.dart';
import 'package:menu_management/recipes/models/quantity.dart';
import 'package:menu_management/shopping/shopping_ingredient.dart';

class ShoppingPage extends StatefulWidget {
  const ShoppingPage({super.key, required this.menu});

  final Menu menu;

  @override
  State<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  late final Map<Ingredient, List<Quantity>> ingredientsRequired;
  late final Map<Ingredient, List<Quantity>> ingredientsOwned;
  int people = 1;

  @override
  void initState() {
    super.initState();
    ingredientsRequired = widget.menu.allIngredients;
    ingredientsOwned = ingredientsRequired.map((key, value) => MapEntry(key, value.map((quantity) => Quantity(amount: 0, unit: quantity.unit)).toList()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
        actions: [
          Row(
            children: [
              IconButton(icon: const Icon(Icons.remove), onPressed: people <= 1 ? null : () => setState(() => people -= 1)),
              Text("$people"),
              const SizedBox(width: 10),
              Icon(people <= 1 ? Icons.person_rounded : Icons.people_alt_rounded),
              IconButton(icon: const Icon(Icons.add), onPressed: () => setState(() => people += 1)),
            ],
          )
        ],
      ),
      body: ListView.builder(
        itemCount: ingredientsRequired.length,
        itemBuilder: (context, index) {
          return ShoppingIngredient(
            ingredient: ingredientsRequired.keyAt(index),
            quantitiesDesiredPerPerson: ingredientsRequired.valueAt(index),
            ownedQuantities: ingredientsOwned[ingredientsRequired.keyAt(index)]!,
            calculatedRemainingQuantities: remainingAmounts(ingredient: ingredientsRequired.keyAt(index)),
            people: people,
            onOwnedAmountChanged: (List<Quantity> ownedQuantities) {
              setState(() => ingredientsOwned[ingredientsRequired.keyAt(index)] = ownedQuantities);
            },
          );
        },
      ),
    );
  }

  List<Quantity> remainingAmounts({required Ingredient ingredient}) {
    int ingredientIndex = ingredientsRequired.keys.toList().indexOf(ingredient);
    List<Quantity> required = ingredientsRequired.valueAt(ingredientIndex);
    List<Quantity> owned = ingredientsOwned[ingredientsRequired.keyAt(ingredientIndex)]!;

    return required.map((quantityRequired) {
      Quantity ownedQuantity = owned.firstWhere((ownedQty) => ownedQty.unit == quantityRequired.unit);
      double amount = quantityRequired.amount * people - ownedQuantity.amount;
      return Quantity(amount: max(0, amount).roundToDouble(), unit: quantityRequired.unit);
    }).toList();
  }
}
