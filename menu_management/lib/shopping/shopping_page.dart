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
import "package:menu_management/shopping/owned_amount.dart";
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

  /// Owned amount per ingredient (raw number entered by user). Used only for ingredients with
  /// no products, where the user types a single number in the selected unit.
  late final Map<String, double> ownedAmounts;

  /// Selected unit for owned input per ingredient (no-products ingredients only).
  late final Map<String, OwnedUnit> ownedUnits;

  /// Owned count per product for ingredients that have products, keyed by ingredient id then by
  /// the product's index in [Ingredient.products]. The global owned amount is derived from these
  /// counts via [OwnedStock.perProduct].
  late final Map<String, Map<int, double>> ownedProductCounts;

  /// Cooking event timeline per ingredient (for event-based waste calculation).
  late final Map<String, List<CookingEvent>> cookingTimeline;

  /// Per-recipe breakdown of ingredient usage (which recipes need each ingredient).
  late final Map<String, List<IngredientSource>> ingredientSources;

  /// When true, the planner assumes freezable products are frozen on arrival, so a single
  /// trip 0 covers the whole menu unless non-freezable items force later trips. When false,
  /// the planner ignores the freezer and splits trips strictly by sealed shelf life.
  /// In both modes the copy output is sectioned per trip.
  bool _useFreezerStrategy = false;

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
    ownedProductCounts = {};

    for (MapEntry<String, List<Quantity>> entry in ingredientsRequired.entries) {
      String ingredientId = entry.key;
      Ingredient? ingredient = allIngredients.firstWhereOrNull((i) => i.id == ingredientId);

      ownedAmounts[ingredientId] = 0;
      ownedUnits[ingredientId] = defaultOwnedUnit(ingredient: ingredient, desiredQuantities: entry.value);
      ownedProductCounts[ingredientId] = {};
    }
  }

  /// Builds the owned stock for an ingredient: per-product counts when it has products,
  /// otherwise the single amount + selected unit. Both resolve to the same units via
  /// [OwnedStock.amountInUnit], so the on-screen list and the planner subtract the same amount.
  OwnedStock _ownedStockFor({required String ingredientId, required Ingredient ingredient}) {
    if (ingredient.products.isNotEmpty) {
      return OwnedStock.perProduct(countsByProductIndex: ownedProductCounts[ingredientId] ?? const {});
    }
    return OwnedStock(amount: ownedAmounts[ingredientId] ?? 0, unit: ownedUnits[ingredientId]?.unit);
  }

  @override
  Widget build(BuildContext context) {
    List<ShoppingTrip> plannedTrips = _planTrips();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Shopping List"),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Tooltip(
                  message:
                      "Off: shop multiple times so nothing expires before cooking.\n"
                      "On: shop once and freeze items that would otherwise expire.",
                  child: const Text("Try to make one trip"),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: _useFreezerStrategy,
                  onChanged: (bool value) {
                    setState(() => _useFreezerStrategy = value);
                  },
                ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.secondaryContainer,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(_buildBannerText(plannedTrips), style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer)),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(tooltip: "Copy to clipboard", onPressed: _copyToClipboard, child: const Icon(Icons.copy_rounded)),
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
                recommendations.addAll(
                  rankProducts(totalNeeded: quantity.amount, events: events, ingredient: ingredient, products: matchingProducts),
                );
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
            ownedProductCounts: ownedProductCounts[ingredientId] ?? const {},
            sources: ingredientSources[ingredientId] ?? [],
            plannedTrips: plannedTrips,
            onOwnedChanged: (double amount, OwnedUnit unit) {
              setState(() {
                ownedAmounts[ingredientId] = amount;
                ownedUnits[ingredientId] = unit;
              });
            },
            onProductOwnedChanged: (int productIndex, double count) {
              setState(() {
                (ownedProductCounts[ingredientId] ??= {})[productIndex] = count;
              });
            },
          );
        },
      ),
    );
  }

  /// Converts the owned stock of an ingredient into [targetUnit]. Delegates to the shared
  /// [OwnedStock.amountInUnit] so the on-screen list and the trip planner subtract the same amount.
  double _ownedInUnit({required String ingredientId, required Ingredient ingredient, required Unit targetUnit}) {
    return _ownedStockFor(ingredientId: ingredientId, ingredient: ingredient).amountInUnit(ingredient: ingredient, targetUnit: targetUnit);
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
    String text = _buildMultiTripCopyText();
    Clipboard.setData(ClipboardData(text: text));
  }

  String _buildBannerText(List<ShoppingTrip> trips) {
    String prefix = _useFreezerStrategy ? "One-trip mode" : "Multi-trip mode";
    if (trips.isEmpty) return "$prefix: nothing to plan.";
    String tripCountText = "${trips.length} ${trips.length == 1 ? "trip" : "trips"}";
    String weeksText = trips.map((ShoppingTrip t) => "Week ${t.weekIndex + 1}").join(", ");
    return "$prefix: copy will split into $tripCountText ($weeksText).";
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
        bool freezeOnArrival = entry.value.any((TripItem i) => i.freezeOnArrival);
        _appendIngredientLines(buffer: buffer, ingredient: ingredient, remaining: tripQuantities, freezeOnArrival: freezeOnArrival);
      }
    }

    return buffer.toString().trimRight();
  }

  void _appendIngredientLines({
    required StringBuffer buffer,
    required Ingredient ingredient,
    required List<Quantity> remaining,
    bool freezeOnArrival = false,
  }) {
    // Round to whole units to match the on-screen / single-list display semantics.
    // Sub-1-unit residuals (e.g., 0.3 teaspoons of a spice) drop out instead of rendering as "0 teaspoons".
    List<Quantity> rounded = remaining.map((Quantity q) => Quantity(amount: q.amount.roundToDouble(), unit: q.unit)).toList();
    if (!rounded.any((q) => q.amount > 0)) return;

    String freezeSuffix = freezeOnArrival ? " (freeze on arrival)" : "";

    if (ingredient.products.isNotEmpty) {
      Quantity? primaryRemaining = rounded.firstWhereOrNull((q) => q.amount > 0 && ingredient.products.any((p) => p.unit == q.unit));
      if (primaryRemaining == null) {
        // No matching product unit -> fall back to raw amount line.
        String amounts = rounded.where((q) => q.amount > 0).map((q) => "${q.amount.toFormattedAmount()} ${q.unit.name}").join(" + ");
        buffer.writeln("${ingredient.name}: $amounts$freezeSuffix");
        return;
      }
      buffer.writeln("${ingredient.name}$freezeSuffix");
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
      buffer.writeln("${ingredient.name}: $amounts$freezeSuffix");
    }
  }

  List<ShoppingTrip> _planTrips() {
    List<Ingredient> allIngredients = IngredientsProvider.instance.ingredients;
    Map<String, Ingredient> ingredientsById = {for (Ingredient ingredient in allIngredients) ingredient.id: ingredient};

    // Build each ingredient's owned stock (per-product counts, or a single amount + unit for
    // no-products ingredients). The planner resolves it into each event's unit via the shared
    // OwnedStock.amountInUnit, so it subtracts exactly what the on-screen list subtracts.
    Map<String, OwnedStock> ownedStockPerIngredient = {};
    for (String ingredientId in ingredientsRequired.keys) {
      Ingredient? ingredient = ingredientsById[ingredientId];
      if (ingredient == null) continue;

      OwnedStock stock = _ownedStockFor(ingredientId: ingredientId, ingredient: ingredient);
      if (!stock.hasStock) continue;
      ownedStockPerIngredient[ingredientId] = stock;
    }

    return planShoppingTrips(
      cookingTimeline: cookingTimeline,
      ingredients: allIngredients,
      ownedAmounts: ownedStockPerIngredient,
      assumeFreezerForFreezable: _useFreezerStrategy,
    );
  }
}
