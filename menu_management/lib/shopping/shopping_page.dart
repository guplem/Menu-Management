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
import "package:menu_management/shopping/trip_amount_distributor.dart";
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

    for (MapEntry<String, List<Quantity>> entry in ingredientsRequired.entries) {
      String ingredientId = entry.key;
      Ingredient? ingredient = allIngredients.firstWhereOrNull((i) => i.id == ingredientId);

      ownedAmounts[ingredientId] = 0;
      ownedUnits[ingredientId] = defaultOwnedUnit(ingredient: ingredient, desiredQuantities: entry.value);
    }
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
            sources: ingredientSources[ingredientId] ?? [],
            plannedTrips: plannedTrips,
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

  /// The on-screen "remaining to buy" for one ingredient: the normalized required amounts with the
  /// user's owned stock subtracted once and each line rounded to a whole unit. Delegates to the
  /// shared [computeRemainingQuantities] so the header, the single list, and the per-trip copy all
  /// start from the same numbers.
  List<Quantity> _remainingAmounts({required String ingredientId, required Ingredient ingredient}) {
    OwnedUnit selectedUnit = ownedUnits[ingredientId] ?? const OwnedUnit(unit: Unit.grams);
    return computeRemainingQuantities(
      ingredient: ingredient,
      requiredQuantities: ingredientsRequired[ingredientId]!,
      ownedAmount: ownedAmounts[ingredientId] ?? 0,
      ownedUnit: selectedUnit.unit,
    );
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

    // Spread each ingredient's on-screen remaining across the trip weeks in the on-screen unit, so
    // the copied per-trip amounts sum to exactly what the page shows (same unit, no rounding drift).
    // Bucket the resulting lines by week, then print the sections in the planner's trip order.
    Map<int, List<({Ingredient ingredient, TripAllocation allocation})>> linesByWeek = {for (ShoppingTrip trip in trips) trip.weekIndex: []};

    for (String ingredientId in ingredientsRequired.keys) {
      Ingredient ingredient = IngredientsProvider.instance.get(ingredientId);
      List<Quantity> remaining = _remainingAmounts(ingredientId: ingredientId, ingredient: ingredient);
      List<TripAllocation> allocations = distributeRemainingAcrossTrips(ingredient: ingredient, pageRemaining: remaining, trips: trips);
      for (TripAllocation allocation in allocations) {
        linesByWeek[allocation.weekIndex]!.add((ingredient: ingredient, allocation: allocation));
      }
    }

    StringBuffer buffer = StringBuffer();
    bool wroteSection = false;
    for (ShoppingTrip trip in trips) {
      List<({Ingredient ingredient, TripAllocation allocation})> lines = linesByWeek[trip.weekIndex]!;
      if (lines.isEmpty) continue;
      lines.sort((a, b) => a.ingredient.name.toLowerCase().compareTo(b.ingredient.name.toLowerCase()));

      if (wroteSection) buffer.writeln();
      wroteSection = true;
      buffer.writeln("Week ${trip.weekIndex + 1}");
      buffer.writeln("--------");
      for (({Ingredient ingredient, TripAllocation allocation}) line in lines) {
        _appendIngredientLines(
          buffer: buffer,
          ingredient: line.ingredient,
          remaining: line.allocation.quantities,
          freezeOnArrival: line.allocation.freezeOnArrival,
        );
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
    buffer.write(buildIngredientCopyLines(ingredient: ingredient, remaining: remaining, freezeOnArrival: freezeOnArrival));
  }

  List<ShoppingTrip> _planTrips() {
    List<Ingredient> allIngredients = IngredientsProvider.instance.ingredients;

    // Pass the user's owned stock as-is (one amount + one selected unit, or "packs").
    // The planner converts it into each event's unit via the shared ownedAmountInUnit,
    // so it subtracts exactly what the on-screen list subtracts.
    Map<String, OwnedStock> ownedStockPerIngredient = {};
    for (MapEntry<String, double> entry in ownedAmounts.entries) {
      String ingredientId = entry.key;
      double amount = entry.value;
      if (amount <= 0) continue;

      OwnedUnit selectedUnit = ownedUnits[ingredientId] ?? const OwnedUnit(unit: Unit.grams);
      ownedStockPerIngredient[ingredientId] = OwnedStock(amount: amount, unit: selectedUnit.unit);
    }

    return planShoppingTrips(
      cookingTimeline: cookingTimeline,
      ingredients: allIngredients,
      ownedAmounts: ownedStockPerIngredient,
      assumeFreezerForFreezable: _useFreezerStrategy,
    );
  }
}

/// Builds the copied shopping-list text for one ingredient (one trip's worth of [remaining]).
///
/// Pure: takes the ingredient and its still-needed quantities, returns the lines as text
/// (empty when nothing is needed). Amounts are rounded to whole units so sub-1-unit residuals
/// drop out instead of rendering as "0 teaspoons".
///
/// Equivalent products (same [productEquivalenceKey], e.g. two pizza flavors of the same size)
/// share the packs one-of-each via [distributeEquivalentPacks], so each shows its cycled share
/// instead of every variant showing the full solo count. A variant that ends up with 0 packs is
/// skipped. Non-equivalent products each keep their full solo count.
String buildIngredientCopyLines({required Ingredient ingredient, required List<Quantity> remaining, bool freezeOnArrival = false}) {
  StringBuffer buffer = StringBuffer();

  List<Quantity> rounded = remaining.map((Quantity q) => Quantity(amount: q.amount.roundToDouble(), unit: q.unit)).toList();
  if (!rounded.any((q) => q.amount > 0)) return "";

  String freezeSuffix = freezeOnArrival ? " (freeze on arrival)" : "";

  if (ingredient.products.isEmpty) {
    String amounts = rounded.where((q) => q.amount > 0).map((q) => "${q.amount.toFormattedAmount()} ${q.unit.name}").join(" + ");
    buffer.writeln("${ingredient.name}: $amounts$freezeSuffix");
    return buffer.toString();
  }

  Quantity? primaryRemaining = rounded.firstWhereOrNull((q) => q.amount > 0 && ingredient.products.any((p) => p.unit == q.unit));
  if (primaryRemaining == null) {
    // No matching product unit -> fall back to raw amount line.
    String amounts = rounded.where((q) => q.amount > 0).map((q) => "${q.amount.toFormattedAmount()} ${q.unit.name}").join(" + ");
    buffer.writeln("${ingredient.name}: $amounts$freezeSuffix");
    return buffer.toString();
  }

  buffer.writeln("${ingredient.name}$freezeSuffix");

  // Products matching the primary unit, in configured order.
  List<Product> matching = ingredient.products.where((Product p) => p.unit == primaryRemaining.unit).toList();

  // Per-equivalence-group cycled shares: the group's solo cover split one-of-each.
  Map<String, List<int>> sharesByKey = {};
  Map<String, int> cursorByKey = {};
  Map<String, List<Product>> groups = {};
  for (Product product in matching) {
    groups.putIfAbsent(productEquivalenceKey(product), () => <Product>[]).add(product);
  }
  for (MapEntry<String, List<Product>> group in groups.entries) {
    int total = group.value.first.packsNeeded(primaryRemaining.amount);
    sharesByKey[group.key] = distributeEquivalentPacks(totalPacks: total, groupSize: group.value.length);
  }

  for (Product product in matching) {
    String key = productEquivalenceKey(product);
    int cursor = cursorByKey[key] ?? 0;
    cursorByKey[key] = cursor + 1;
    int packs = sharesByKey[key]![cursor];
    if (packs <= 0) continue;
    String label = product.packLabel() ?? "${product.totalQuantityPerPack.toFormattedAmount()} ${product.unit.name}/pack";
    String packWord = packs == 1 ? "pack" : "packs";
    buffer.writeln("  $label: $packs $packWord");
  }

  return buffer.toString();
}
