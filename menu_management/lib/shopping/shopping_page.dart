import 'package:flutter/material.dart';
import 'package:menu_management/ingredients/models/ingredient.dart';
import 'package:menu_management/menu/models/menu.dart';
import 'package:menu_management/recipes/models/quantity.dart';

class ShoppingPage extends StatefulWidget {
  const ShoppingPage({super.key, required this.menu});

  final Menu menu;

  @override
  State<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  late final Map<Ingredient, List<Quantity>> ingredients;
  late final Map<Ingredient, List<Quantity>> ingredientsOwned;
  int people = 1;

  @override
  void initState() {
    super.initState();
    ingredients = widget.menu.allIngredients;
    ingredientsOwned = ingredients.map((key, value) => MapEntry(key, value.map((quantity) => Quantity(amount: 0, unit: quantity.unit)).toList()));
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
        itemCount: ingredients.length,
        itemBuilder: (context, index) {
          return ListTile(
              title: Text(ingredients.keys.elementAt(index).name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: ingredients.values.elementAt(index).map((quantity) {
                  String amountRounded = (quantity.amount * people).toStringAsFixed(0);
                  String unit = quantity.unit.toString().split(".").last;
                  return Text("$amountRounded $unit");
                }).toList(),
              ));
        },
      ),
    );
  }
}
