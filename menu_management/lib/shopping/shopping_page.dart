import "dart:math";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/ingredients/ingredients_provider.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/menu/models/multi_week_menu.dart";
import "package:menu_management/recipes/recipes_provider.dart";
import "package:menu_management/recipes/models/quantity.dart";
import "package:menu_management/shopping/quantity_normalizer.dart";
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

  /// Per-product owned packs: ingredient ID -> product index -> owned packs (double).
  late final Map<String, Map<int, double>> ownedPacksPerProduct;

  /// Raw owned amounts for ingredients without products: ingredient ID to List of Quantity.
  late final Map<String, List<Quantity>> ownedRawForNoProducts;

  /// Daily usage per ingredient (total / consumption days, simplified to total / 7 for now).
  late final Map<String, double> dailyUsagePerIngredient;

  @override
  void initState() {
    super.initState();
    List<Ingredient> allIngredients = IngredientsProvider.instance.ingredients;
    Map<String, List<Quantity>> rawIngredients = widget.multiWeekMenu.allIngredients(recipes: RecipesProvider.instance.recipes);

    ingredientsRequired = normalizeAllIngredients(rawQuantities: rawIngredients, ingredients: allIngredients);

    ownedPacksPerProduct = {};
    ownedRawForNoProducts = {};
    dailyUsagePerIngredient = {};

    int totalDays = widget.multiWeekMenu.weeks.length * 7;

    for (MapEntry<String, List<Quantity>> entry in ingredientsRequired.entries) {
      String ingredientId = entry.key;
      Ingredient? ingredient = allIngredients.firstWhereOrNull((i) => i.id == ingredientId);

      if (ingredient != null && ingredient.products.isNotEmpty) {
        ownedPacksPerProduct[ingredientId] = {};
      } else {
        ownedRawForNoProducts[ingredientId] = entry.value.map((q) => Quantity(amount: 0, unit: q.unit)).toList();
      }

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

          // Compute product recommendations
          List<ProductRecommendation> recommendations = [];
          if (ingredient.products.isNotEmpty && desired.isNotEmpty) {
            // Use the first quantity's amount and unit for recommendations (after normalization, usually just 1)
            Quantity primaryQuantity = desired.first;
            List<Product> matchingProducts = ingredient.products.where((p) => p.unit == primaryQuantity.unit).toList();
            recommendations = rankProducts(totalNeeded: primaryQuantity.amount, dailyUsage: dailyUsage, products: matchingProducts);
          }

          return ShoppingIngredient(
            ingredient: ingredient,
            quantitiesDesired: desired,
            calculatedRemainingQuantities: remaining,
            productRecommendations: recommendations,
            ownedPacksPerProduct: ownedPacksPerProduct[ingredientId] ?? {},
            ownedRaw: ownedRawForNoProducts[ingredientId] ?? desired.map((q) => Quantity(amount: 0, unit: q.unit)).toList(),
            dailyUsage: dailyUsage,
            onPacksChanged: (int productIndex, double packs) {
              setState(() {
                ownedPacksPerProduct[ingredientId] ??= {};
                ownedPacksPerProduct[ingredientId]![productIndex] = packs;
              });
            },
            onRawOwnedChanged: (List<Quantity> rawOwned) {
              setState(() => ownedRawForNoProducts[ingredientId] = rawOwned);
            },
          );
        },
      ),
    );
  }

  List<Quantity> _remainingAmounts({required String ingredientId, required Ingredient ingredient}) {
    List<Quantity> required = ingredientsRequired[ingredientId]!;

    if (ingredient.products.isNotEmpty) {
      // Compute total owned amount from pack data
      Map<int, double> ownedPacks = ownedPacksPerProduct[ingredientId] ?? {};

      return required.map((Quantity quantityRequired) {
        // Sum owned across all products with matching unit
        double totalOwned = 0;
        for (MapEntry<int, double> entry in ownedPacks.entries) {
          if (entry.key < ingredient.products.length) {
            Product product = ingredient.products[entry.key];
            if (product.unit == quantityRequired.unit) {
              totalOwned += entry.value * product.totalQuantityPerPack;
            }
          }
        }
        double amount = quantityRequired.amount - totalOwned;
        return Quantity(amount: max(0, amount).roundToDouble(), unit: quantityRequired.unit);
      }).toList();
    }

    // No products: use raw owned amounts
    List<Quantity> owned = ownedRawForNoProducts[ingredientId] ?? [];
    return required.map((Quantity quantityRequired) {
      Quantity ownedQuantity = owned.firstWhere((o) => o.unit == quantityRequired.unit, orElse: () => Quantity(amount: 0, unit: quantityRequired.unit));
      double amount = quantityRequired.amount - ownedQuantity.amount;
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
          String packLabel = "${product.itemsPerPack}x${product.quantityPerItem.toStringAsFixed(0)}${product.unit.name}";
          String packWord = packs == 1 ? "pack" : "packs";
          buffer.writeln("  $packLabel: $packs $packWord");
        }
      } else {
        String amounts = remaining.where((q) => q.amount > 0).map((q) => "${q.amount.toStringAsFixed(0)} ${q.unit.name}").join(" + ");
        buffer.writeln("${ingredient.name}: $amounts");
      }
    }

    Clipboard.setData(ClipboardData(text: buffer.toString().trimRight()));
  }
}
