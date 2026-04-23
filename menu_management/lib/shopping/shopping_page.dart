import "dart:math";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/ingredients/ingredients_provider.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/menu/models/multi_week_menu.dart";
import "package:menu_management/recipes/enums/unit.dart";
import "package:menu_management/recipes/recipes_provider.dart";
import "package:menu_management/recipes/models/quantity.dart";
import "package:menu_management/shopping/quantity_normalizer.dart";
import "package:menu_management/shopping/ingredient_source.dart";
import "package:menu_management/shopping/shopping_ingredient.dart";
import "package:menu_management/shopping/waste_optimizer.dart";

class ShoppingPage extends StatefulWidget {
  const ShoppingPage({super.key, required this.multiWeekMenu});

  final MultiWeekMenu multiWeekMenu;

  @override
  State<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  late final Map<String, List<Quantity>> ingredientsRequired;

  /// Owned amount per ingredient (raw number entered by user).
  late final Map<String, double> ownedAmounts;

  /// Selected unit for owned input per ingredient.
  late final Map<String, OwnedUnit> ownedUnits;

  /// Daily usage per ingredient (total / consumption days, simplified to total / 7 for now).
  late final Map<String, double> dailyUsagePerIngredient;

  /// Per-recipe breakdown of ingredient usage (which recipes need each ingredient).
  late final Map<String, List<IngredientSource>> ingredientSources;

  @override
  void initState() {
    super.initState();
    List<Ingredient> allIngredients = IngredientsProvider.instance.ingredients;
    Map<String, List<Quantity>> rawIngredients = widget.multiWeekMenu.allIngredients(recipes: RecipesProvider.instance.recipes);

    ingredientsRequired = normalizeAllIngredients(rawQuantities: rawIngredients, ingredients: allIngredients);
    ingredientSources = widget.multiWeekMenu.ingredientSources(recipes: RecipesProvider.instance.recipes);

    ownedAmounts = {};
    ownedUnits = {};
    dailyUsagePerIngredient = {};

    int totalDays = widget.multiWeekMenu.weeks.length * 7;

    for (MapEntry<String, List<Quantity>> entry in ingredientsRequired.entries) {
      String ingredientId = entry.key;
      Ingredient? ingredient = allIngredients.firstWhereOrNull((i) => i.id == ingredientId);

      ownedAmounts[ingredientId] = 0;
      ownedUnits[ingredientId] = defaultOwnedUnit(ingredient: ingredient, desiredQuantities: entry.value);

      // Compute daily usage: sum of all quantities in the first matching unit
      double totalAmount = entry.value.fold(0.0, (sum, q) => sum + q.amount);
      dailyUsagePerIngredient[ingredientId] = totalDays > 0 ? totalAmount / totalDays : totalAmount;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Shopping List")),
      floatingActionButton: FloatingActionButton(
        tooltip: "Copy to clipboard",
        onPressed: _copyToClipboard,
        child: const Icon(Icons.copy_rounded),
      ),
      body: ListView.builder(
        itemCount: ingredientsRequired.length,
        itemBuilder: (context, index) {
          String ingredientId = ingredientsRequired.keyAt(index);
          Ingredient ingredient = getProvider<IngredientsProvider>(context, listen: true).get(ingredientId);
          List<Quantity> desired = ingredientsRequired.valueAt(index);
          List<Quantity> remaining = _remainingAmounts(ingredientId: ingredientId, ingredient: ingredient);
          double dailyUsage = dailyUsagePerIngredient[ingredientId] ?? 0;

          // Compute product recommendations per required unit
          List<ProductRecommendation> recommendations = [];
          if (ingredient.products.isNotEmpty && desired.isNotEmpty) {
            for (Quantity quantity in desired) {
              List<Product> matchingProducts = ingredient.products.where((p) => p.unit == quantity.unit).toList();
              if (matchingProducts.isNotEmpty) {
                recommendations.addAll(rankProducts(totalNeeded: quantity.amount, dailyUsage: dailyUsage, products: matchingProducts));
              }
            }
          }

          return ShoppingIngredient(
            ingredient: ingredient,
            quantitiesDesired: desired,
            calculatedRemainingQuantities: remaining,
            productRecommendations: recommendations,
            ownedAmount: ownedAmounts[ingredientId] ?? 0,
            ownedUnit: ownedUnits[ingredientId] ?? const OwnedUnit(unit: Unit.grams),
            dailyUsage: dailyUsage,
            sources: ingredientSources[ingredientId] ?? [],
            onOwnedChanged: (double amount, OwnedUnit unit) {
              setState(() {
                ownedAmounts[ingredientId] = amount;
                ownedUnits[ingredientId] = unit;
              });
            },
          );
        },
      ),
    );
  }

  /// Converts owned amount to the actual quantity in [targetUnit] based on the selected owned unit.
  double _ownedInUnit({required String ingredientId, required Ingredient ingredient, required Unit targetUnit}) {
    double amount = ownedAmounts[ingredientId] ?? 0;
    if (amount <= 0) return 0;

    OwnedUnit selectedUnit = ownedUnits[ingredientId] ?? OwnedUnit(unit: targetUnit);

    if (selectedUnit.unit == null) {
      // "packs" mode: find the first product with matching target unit and convert
      Product? product = ingredient.products.firstWhereOrNull((p) => p.unit == targetUnit);
      if (product == null) return 0;
      return amount * product.totalQuantityPerPack;
    }

    if (selectedUnit.unit == targetUnit) {
      return amount;
    }

    // Different units: try conversion via ingredient density
    double? ownedGrams = ingredient.toGrams(Quantity(amount: amount, unit: selectedUnit.unit!));
    if (ownedGrams != null) {
      if (targetUnit == Unit.grams) return ownedGrams;
      double? converted = ingredient.fromGrams(ownedGrams, targetUnit);
      if (converted != null) return converted;
    }

    return 0;
  }

  List<Quantity> _remainingAmounts({required String ingredientId, required Ingredient ingredient}) {
    List<Quantity> required = ingredientsRequired[ingredientId]!;

    return required.map((Quantity quantityRequired) {
      double owned = _ownedInUnit(ingredientId: ingredientId, ingredient: ingredient, targetUnit: quantityRequired.unit);
      double amount = quantityRequired.amount - owned;
      return Quantity(amount: max(0, amount).roundToDouble(), unit: quantityRequired.unit);
    }).toList();
  }

  void _copyToClipboard() {
    StringBuffer buffer = StringBuffer();

    for (MapEntry<String, List<Quantity>> entry in ingredientsRequired.entries) {
      String ingredientId = entry.key;
      Ingredient ingredient = IngredientsProvider.instance.get(ingredientId);
      List<Quantity> remaining = _remainingAmounts(ingredientId: ingredientId, ingredient: ingredient);

      if (!remaining.any((q) => q.amount > 0)) continue;

      if (ingredient.products.isNotEmpty) {
        buffer.writeln(ingredient.name);
        Quantity primaryRemaining = remaining.firstWhere((q) => q.amount > 0);
        for (Product product in ingredient.products) {
          if (product.unit != primaryRemaining.unit) continue;
          int packs = product.packsNeeded(primaryRemaining.amount);
          if (packs <= 0) continue;
          String label = product.packLabel() ?? "${product.totalQuantityPerPack.toFormattedAmount()} ${product.unit.name}/pack";
          String packWord = packs == 1 ? "pack" : "packs";
          buffer.writeln("  $label: $packs $packWord");
        }
      } else {
        String amounts = remaining.where((q) => q.amount > 0).map((q) => "${q.amount.toFormattedAmount()} ${q.unit.name}").join(" + ");
        buffer.writeln("${ingredient.name}: $amounts");
      }
    }

    Clipboard.setData(ClipboardData(text: buffer.toString().trimRight()));
  }
}
