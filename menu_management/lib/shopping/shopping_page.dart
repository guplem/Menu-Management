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
import "package:menu_management/shopping/shopping_copy_text.dart";
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
