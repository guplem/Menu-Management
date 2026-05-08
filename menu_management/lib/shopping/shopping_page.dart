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
import "package:menu_management/shopping/cooking_timeline.dart";
import "package:menu_management/shopping/multi_trip_planner.dart";
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

  /// Cooking event timeline per ingredient (for event-based waste calculation).
  late final Map<String, List<CookingEvent>> cookingTimeline;

  /// Per-recipe breakdown of ingredient usage (which recipes need each ingredient).
  late final Map<String, List<IngredientSource>> ingredientSources;

  /// When true, the copy output is split into one shopping trip per week as needed
  /// so nothing the user buys is past its sealed shelf life when used. When false,
  /// the copy output is one flat list assuming a single purchase before menu day 0.
  bool _ensureFreshness = false;

  @override
  void initState() {
    super.initState();
    List<Ingredient> allIngredients = IngredientsProvider.instance.ingredients;
    Map<String, List<Quantity>> rawIngredients = widget.multiWeekMenu.allIngredients(recipes: RecipesProvider.instance.recipes);

    ingredientsRequired = normalizeAllIngredients(rawQuantities: rawIngredients, ingredients: allIngredients);
    ingredientSources = widget.multiWeekMenu.ingredientSources(recipes: RecipesProvider.instance.recipes);
    cookingTimeline = buildCookingTimeline(multiWeekMenu: widget.multiWeekMenu, recipes: RecipesProvider.instance.recipes);

    ownedAmounts = {};
    ownedUnits = {};

    for (MapEntry<String, List<Quantity>> entry in ingredientsRequired.entries) {
      String ingredientId = entry.key;
      Ingredient? ingredient = allIngredients.firstWhereOrNull((i) => i.id == ingredientId);

      ownedAmounts[ingredientId] = 0;
      ownedUnits[ingredientId] = defaultOwnedUnit(ingredient: ingredient, desiredQuantities: entry.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<ShoppingTrip> plannedTrips = _ensureFreshness ? _planTrips() : const [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Shopping List"),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Tooltip(
                  message: "On: the copy button splits the list into multiple shopping trips so nothing expires "
                      "before it is cooked. Off: one purchase the day before the menu starts.",
                  child: const Text("Ensure freshness"),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: _ensureFreshness,
                  onChanged: (bool value) {
                    setState(() => _ensureFreshness = value);
                  },
                ),
              ],
            ),
          ),
        ],
        bottom: _ensureFreshness
            ? PreferredSize(
                preferredSize: const Size.fromHeight(28),
                child: Container(
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                    "Multi-trip mode: copy will split into ${plannedTrips.length} ${plannedTrips.length == 1 ? "trip" : "trips"} (${plannedTrips.map((t) => "Week ${t.weekIndex + 1}").join(", ")}).",
                    style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer),
                  ),
                ),
              )
            : null,
      ),
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
          List<CookingEvent> events = cookingTimeline[ingredientId] ?? [];

          // Compute product recommendations per required unit
          List<ProductRecommendation> recommendations = [];
          if (ingredient.products.isNotEmpty && desired.isNotEmpty) {
            for (Quantity quantity in desired) {
              List<Product> matchingProducts = ingredient.products.where((p) => p.unit == quantity.unit).toList();
              if (matchingProducts.isNotEmpty) {
                recommendations.addAll(rankProducts(totalNeeded: quantity.amount, events: events, ingredient: ingredient, products: matchingProducts));
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
    String text = _ensureFreshness ? _buildMultiTripCopyText() : _buildSingleListCopyText();
    Clipboard.setData(ClipboardData(text: text));
  }

  String _buildSingleListCopyText() {
    StringBuffer buffer = StringBuffer();

    for (MapEntry<String, List<Quantity>> entry in ingredientsRequired.entries) {
      String ingredientId = entry.key;
      Ingredient ingredient = IngredientsProvider.instance.get(ingredientId);
      List<Quantity> remaining = _remainingAmounts(ingredientId: ingredientId, ingredient: ingredient);

      _appendIngredientLines(buffer: buffer, ingredient: ingredient, remaining: remaining);
    }

    return buffer.toString().trimRight();
  }

  String _buildMultiTripCopyText() {
    List<ShoppingTrip> trips = _planTrips();
    if (trips.isEmpty) return _buildSingleListCopyText();

    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < trips.length; i++) {
      ShoppingTrip trip = trips[i];
      if (i > 0) buffer.writeln();
      buffer.writeln("Week ${trip.weekIndex + 1}");
      buffer.writeln("--------");

      // Group items by ingredient (one ingredient may have multiple units).
      Map<String, List<TripItem>> byIngredient = {};
      for (TripItem item in trip.items) {
        byIngredient.putIfAbsent(item.ingredientId, () => []).add(item);
      }

      for (MapEntry<String, List<TripItem>> entry in byIngredient.entries) {
        Ingredient ingredient = IngredientsProvider.instance.get(entry.key);
        List<Quantity> tripQuantities = entry.value.map((TripItem i) => Quantity(amount: i.amount, unit: i.unit)).toList();
        _appendIngredientLines(buffer: buffer, ingredient: ingredient, remaining: tripQuantities);
      }
    }

    return buffer.toString().trimRight();
  }

  void _appendIngredientLines({required StringBuffer buffer, required Ingredient ingredient, required List<Quantity> remaining}) {
    // Round to whole units to match the on-screen / single-list display semantics.
    // Sub-1-unit residuals (e.g., 0.3 teaspoons of a spice) drop out instead of rendering as "0 teaspoons".
    List<Quantity> rounded = remaining.map((Quantity q) => Quantity(amount: q.amount.roundToDouble(), unit: q.unit)).toList();
    if (!rounded.any((q) => q.amount > 0)) return;

    if (ingredient.products.isNotEmpty) {
      Quantity? primaryRemaining = rounded.firstWhereOrNull((q) => q.amount > 0 && ingredient.products.any((p) => p.unit == q.unit));
      if (primaryRemaining == null) {
        // No matching product unit -> fall back to raw amount line.
        String amounts = rounded.where((q) => q.amount > 0).map((q) => "${q.amount.toFormattedAmount()} ${q.unit.name}").join(" + ");
        buffer.writeln("${ingredient.name}: $amounts");
        return;
      }
      buffer.writeln(ingredient.name);
      for (Product product in ingredient.products) {
        if (product.unit != primaryRemaining.unit) continue;
        int packs = product.packsNeeded(primaryRemaining.amount);
        if (packs <= 0) continue;
        String label = product.packLabel() ?? "${product.totalQuantityPerPack.toFormattedAmount()} ${product.unit.name}/pack";
        String packWord = packs == 1 ? "pack" : "packs";
        buffer.writeln("  $label: $packs $packWord");
      }
    } else {
      String amounts = rounded.where((q) => q.amount > 0).map((q) => "${q.amount.toFormattedAmount()} ${q.unit.name}").join(" + ");
      buffer.writeln("${ingredient.name}: $amounts");
    }
  }

  List<ShoppingTrip> _planTrips() {
    List<Ingredient> allIngredients = IngredientsProvider.instance.ingredients;

    // Build remaining-after-owned cooking timeline. We keep events whose summed
    // amount across all owned-eligible units is still positive; the planner
    // handles owned subtraction internally via ownedAmounts.
    Map<String, List<Quantity>> ownedQuantitiesPerIngredient = {};
    for (MapEntry<String, double> entry in ownedAmounts.entries) {
      String ingredientId = entry.key;
      double amount = entry.value;
      if (amount <= 0) continue;
      Ingredient? ingredient = allIngredients.firstWhereOrNull((i) => i.id == ingredientId);
      if (ingredient == null) continue;

      OwnedUnit selectedUnit = ownedUnits[ingredientId] ?? const OwnedUnit(unit: Unit.grams);
      if (selectedUnit.unit != null) {
        ownedQuantitiesPerIngredient[ingredientId] = [Quantity(amount: amount, unit: selectedUnit.unit!)];
      } else {
        // "packs" mode: convert to product's unit using its first product.
        Product? product = ingredient.products.firstOrNull;
        if (product != null) {
          ownedQuantitiesPerIngredient[ingredientId] = [Quantity(amount: amount * product.totalQuantityPerPack, unit: product.unit)];
        }
      }
    }

    return planShoppingTrips(
      cookingTimeline: cookingTimeline,
      ingredients: allIngredients,
      ownedAmounts: ownedQuantitiesPerIngredient,
    );
  }
}
