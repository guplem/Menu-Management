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

  @override
  void initState() {

    super.initState();
    ingredients = widget.menu.allIngredients;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
      ),
      body: ListView.builder(
        itemCount: ingredients.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(ingredients.keys.elementAt(index).name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: ingredients.values.elementAt(index).map((quantity) {
                String amountRounded = quantity.amount.toStringAsFixed(0);
                String unit = quantity.unit.toString().split(".").last;
                return Text("$amountRounded $unit");
              }).toList(),
            )
          );
        },
      ),
    );
  }
}
