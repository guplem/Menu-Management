import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/ingredients/ingredients_provider.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/menu/menu_dates.dart";
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

  /// Builds the owned stock for an ingredient: per-product counts when per-product rows render
  /// (see [usesPerProductOwnedInputs]), otherwise the single header amount + selected unit. This
  /// mirrors which input the UI shows, so the header fallback (products present but no product unit
  /// matches a recipe unit) is read from the single amount, not the empty per-product counts. Both
  /// resolve to the same units via [OwnedStock.amountInUnit], so the on-screen list and the planner
  /// subtract the same amount.
  OwnedStock _ownedStockFor({required String ingredientId, required Ingredient ingredient}) {
    List<Quantity> desired = ingredientsRequired[ingredientId] ?? const [];
    if (usesPerProductOwnedInputs(ingredient: ingredient, desiredQuantities: desired)) {
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
          // Waste-minimal mix of packs per required unit (may combine several products).
          // Uses the same total need and events as the per-product ranking, so the recommended
          // mix reflects the individual cooking events, not only the weekly total.
          List<CombinationRecommendation> combinations = [];
          if (ingredient.products.isNotEmpty && desired.isNotEmpty) {
            for (Quantity quantity in desired) {
              List<Product> matchingProducts = ingredient.products.where((p) => p.unit == quantity.unit).toList();
              if (matchingProducts.isNotEmpty) {
                recommendations.addAll(
                  rankProducts(totalNeeded: quantity.amount, events: events, ingredient: ingredient, products: matchingProducts),
                );
                CombinationRecommendation? combination = recommendCombination(
                  totalNeeded: quantity.amount,
                  events: events,
                  ingredient: ingredient,
                  products: matchingProducts,
                );
                if (combination != null && combination.selections.length > 1) combinations.add(combination);
              }
            }
          }

          return ShoppingIngredient(
            ingredient: ingredient,
            quantitiesDesired: desired,
            calculatedRemainingQuantities: remaining,
            productRecommendations: recommendations,
            combinationRecommendations: combinations,
            ownedAmount: ownedAmounts[ingredientId] ?? 0,
            ownedUnit: ownedUnits[ingredientId] ?? const OwnedUnit(unit: Unit.grams),
            ownedProductCounts: ownedProductCounts[ingredientId] ?? const {},
            sources: ingredientSources[ingredientId] ?? [],
            plannedTrips: plannedTrips,
            startDate: widget.multiWeekMenu.startDate,
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

  /// The on-screen "remaining to buy" for one ingredient: the normalized required amounts with the
  /// user's owned stock subtracted once and each line rounded to a whole unit. Delegates to the
  /// shared [computeRemainingQuantities] so the header, the single list, and the per-trip copy all
  /// start from the same numbers. The owned stock comes from [_ownedStockFor], so per-product owned
  /// counts (issue #24) feed the same single pool as the single-form amount.
  List<Quantity> _remainingAmounts({required String ingredientId, required Ingredient ingredient}) {
    return computeRemainingQuantities(
      ingredient: ingredient,
      requiredQuantities: ingredientsRequired[ingredientId]!,
      owned: _ownedStockFor(ingredientId: ingredientId, ingredient: ingredient),
    );
  }

  void _copyToClipboard() {
    List<ShoppingTrip> trips = _planTrips();
    ({List<Ingredient> ingredients, Map<String, List<Quantity>> remainingByIngredientId}) input = _copyInput();
    String text = buildMultiTripCopyText(
      ingredients: input.ingredients,
      remainingByIngredientId: input.remainingByIngredientId,
      trips: trips,
      tripLabel: (ShoppingTrip trip) => _tripLabel(trip: trip, trips: trips),
    );
    Clipboard.setData(ClipboardData(text: text));
  }

  /// Names one trip of [trips]. [shoppingTripLabel] owns the rule that decides when the
  /// earliest trip of the plan reads "now". The banner and the copied section headers both
  /// call this, so they agree with the per-product rows, which call the same function.
  String _tripLabel({required ShoppingTrip trip, required List<ShoppingTrip> trips}) {
    return shoppingTripLabel(
      startDate: widget.multiWeekMenu.startDate,
      weekIndex: trip.weekIndex,
      tripDay: trip.tripDay,
      isFirstTrip: trip.weekIndex == trips.first.weekIndex,
    );
  }

  String _buildBannerText(List<ShoppingTrip> trips) {
    String prefix = _useFreezerStrategy ? "One-trip mode" : "Multi-trip mode";
    if (trips.isEmpty) return "$prefix: nothing to plan.";
    String tripCountText = "${trips.length} ${trips.length == 1 ? "trip" : "trips"}";
    String weeksText = trips.map((ShoppingTrip t) => _tripLabel(trip: t, trips: trips)).join(", ");
    return "$prefix: copy will split into $tripCountText ($weeksText).";
  }

  /// Collects the ingredients of the list and what the user must still buy of each one.
  /// Both copy builders read the same two values, so they can never start from different data.
  ({List<Ingredient> ingredients, Map<String, List<Quantity>> remainingByIngredientId}) _copyInput() {
    List<Ingredient> ingredients = [];
    Map<String, List<Quantity>> remainingByIngredientId = {};
    for (String ingredientId in ingredientsRequired.keys) {
      Ingredient ingredient = IngredientsProvider.instance.get(ingredientId);
      ingredients.add(ingredient);
      remainingByIngredientId[ingredientId] = _remainingAmounts(ingredientId: ingredientId, ingredient: ingredient);
    }
    return (ingredients: ingredients, remainingByIngredientId: remainingByIngredientId);
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

/// Sorts the ingredients of the copied list by name, ignoring upper and lower case.
///
/// Both copy builders call this, so one menu can never produce two different ingredient orders.
List<Ingredient> sortIngredientsForCopy(List<Ingredient> ingredients) {
  List<Ingredient> sorted = [...ingredients];
  sorted.sort((Ingredient a, Ingredient b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return sorted;
}

/// Builds the copied shopping list as one single list, with no trip sections.
///
/// Pure: takes the ingredients and what the user must still buy of each one, keyed by ingredient
/// id, and returns the text. Used when the planner finds no trip to plan.
String buildSingleListCopyText({required List<Ingredient> ingredients, required Map<String, List<Quantity>> remainingByIngredientId}) {
  StringBuffer buffer = StringBuffer();
  for (Ingredient ingredient in sortIngredientsForCopy(ingredients)) {
    buffer.write(buildIngredientCopyLines(ingredient: ingredient, remaining: remainingByIngredientId[ingredient.id] ?? const []));
  }
  return buffer.toString().trimRight();
}

/// Builds the copied shopping list split into one section per shop trip (ADR 0014).
///
/// Pure: takes the ingredients, what the user must still buy of each one, the planned trips, and
/// a function that names one trip. Falls back to the single list when there is no trip to plan.
///
/// It spreads the on-screen remaining of each ingredient across the trip weeks in the on-screen
/// unit, so the copied per-trip amounts sum to exactly what the page shows (same unit, no
/// rounding drift). It buckets the resulting lines by week, then writes the sections in the
/// trip order of the planner.
String buildMultiTripCopyText({
  required List<Ingredient> ingredients,
  required Map<String, List<Quantity>> remainingByIngredientId,
  required List<ShoppingTrip> trips,
  required String Function(ShoppingTrip trip) tripLabel,
}) {
  if (trips.isEmpty) return buildSingleListCopyText(ingredients: ingredients, remainingByIngredientId: remainingByIngredientId);

  Map<int, List<({Ingredient ingredient, TripAllocation allocation})>> linesByWeek = {for (ShoppingTrip trip in trips) trip.weekIndex: []};

  for (Ingredient ingredient in sortIngredientsForCopy(ingredients)) {
    List<Quantity> remaining = remainingByIngredientId[ingredient.id] ?? const [];
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

    if (wroteSection) buffer.writeln();
    wroteSection = true;
    String header = tripLabel(trip);
    buffer.writeln(header);
    buffer.writeln("-" * header.length);
    for (({Ingredient ingredient, TripAllocation allocation}) line in lines) {
      buffer.write(
        buildIngredientCopyLines(
          ingredient: line.ingredient,
          remaining: line.allocation.quantities,
          freezeOnArrival: line.allocation.freezeOnArrival,
        ),
      );
    }
  }

  return buffer.toString().trimRight();
}

/// Builds the copied shopping-list text for one ingredient (one trip's worth of [remaining]).
///
/// Pure: takes the ingredient and its still-needed quantities, returns the lines as text
/// (empty when nothing is needed). [roundNeededAmount] rounds each amount to a whole unit and
/// never rounds a real need down to zero, so a sub-1-unit need lists as one unit instead of
/// dropping out of the list.
///
/// The lines show the waste-minimal pack mix from [recommendCombination] (issue #26), not every
/// product's solo count: a product the mix does not pick is not listed. Where that mix contains
/// two or more equivalent products (same [productEquivalenceKey], e.g. two pizza flavors of the
/// same size), the group's packs are spread one-of-each via [distributeEquivalentPacks] (issue
/// #27), so identical variants list as "one of each" instead of all packs on one variant. A
/// variant that ends up with 0 packs is skipped.
String buildIngredientCopyLines({required Ingredient ingredient, required List<Quantity> remaining, bool freezeOnArrival = false}) {
  StringBuffer buffer = StringBuffer();

  List<Quantity> rounded = remaining.map((Quantity q) => Quantity(amount: roundNeededAmount(q.amount), unit: q.unit)).toList();
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

  // Pick the waste-minimal mix of packs for this amount (issue #26): the copy shows that mix, not
  // every product's solo count. Events are empty: each trip is already a shelf-life-safe bucket, so
  // the mix only needs to minimize pack-granularity over-buy for the amount bought on this trip.
  CombinationRecommendation? combination = recommendCombination(
    totalNeeded: primaryRemaining.amount,
    events: const [],
    ingredient: ingredient,
    products: matching,
  );
  if (combination == null) return buffer.toString();

  // Total packs the mix buys per equivalence group. Equivalent variants share one key, so the
  // solver may load them all onto one representative; summing per key recovers the group's total.
  Map<String, int> packsByKey = {};
  for (PackSelection selection in combination.selections) {
    String key = productEquivalenceKey(selection.product);
    packsByKey[key] = (packsByKey[key] ?? 0) + selection.packs;
  }

  // Spread each group's packs one-of-each across its equivalent variants (issue #27), so identical
  // variants in the recommendation list as "one of each" instead of all packs on one variant.
  Map<String, List<int>> sharesByKey = {};
  Map<String, int> cursorByKey = {};
  Map<String, List<Product>> groups = {};
  for (Product product in matching) {
    groups.putIfAbsent(productEquivalenceKey(product), () => <Product>[]).add(product);
  }
  for (MapEntry<String, List<Product>> group in groups.entries) {
    int total = packsByKey[group.key] ?? 0;
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
