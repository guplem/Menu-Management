import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/recipes/models/quantity.dart";
import "package:menu_management/shopping/multi_trip_planner.dart";
import "package:menu_management/shopping/owned_amount.dart";
import "package:menu_management/shopping/trip_amount_distributor.dart";
import "package:menu_management/shopping/waste_optimizer.dart";

/// Sorts the ingredients of the copied list by name, ignoring upper and lower case.
///
/// Both copy builders call this, so one menu can never produce two different ingredient orders.
List<Ingredient> sortIngredientsForCopy(List<Ingredient> ingredients) {
  List<Ingredient> sorted = [...ingredients];
  sorted.sort((Ingredient a, Ingredient b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return sorted;
}

/// Builds the simplified shopping list: one line per ingredient, with the amount and nothing else.
///
/// Pure: takes the ingredients and what the user must still buy of each one, keyed by ingredient
/// id, and returns the text. The reader of this text shops without the app, so the text holds no
/// trip section, no pack line, and no store link. Use [buildMultiTripCopyText] for those.
///
/// An ingredient that the user already owns writes no line.
String buildSimplifiedShoppingCopyText({required List<Ingredient> ingredients, required Map<String, List<Quantity>> remainingByIngredientId}) {
  StringBuffer buffer = StringBuffer();
  for (Ingredient ingredient in sortIngredientsForCopy(ingredients)) {
    List<Quantity> remaining = remainingForCopy(ingredient: ingredient, remainingByIngredientId: remainingByIngredientId);
    if (!remaining.any((Quantity quantity) => quantity.amount > 0)) continue;
    buffer.writeln("${ingredient.name}: ${_amountsText(remaining)}");
  }
  return buffer.toString().trimRight();
}

/// Writes the amounts of one ingredient, for example "500 grams + 2 pieces".
/// Both copy formats call this, so one ingredient reads the same way in each of them.
String _amountsText(List<Quantity> remaining) {
  return remaining
      .where((Quantity quantity) => quantity.amount > 0)
      .map((Quantity quantity) {
        return "${quantity.amount.toFormattedAmount()} ${quantity.unit.name}";
      })
      .join(" + ");
}

/// Builds the copied shopping list as one single list, with no trip sections.
///
/// Pure: takes the ingredients and what the user must still buy of each one, keyed by ingredient
/// id, and returns the text. Used when the planner finds no trip to plan.
String buildSingleListCopyText({required List<Ingredient> ingredients, required Map<String, List<Quantity>> remainingByIngredientId}) {
  StringBuffer buffer = StringBuffer();
  for (Ingredient ingredient in sortIngredientsForCopy(ingredients)) {
    buffer.write(
      buildIngredientCopyLines(
        ingredient: ingredient,
        remaining: remainingForCopy(ingredient: ingredient, remainingByIngredientId: remainingByIngredientId),
      ),
    );
  }
  return buffer.toString().trimRight();
}

/// Reads the still-needed amounts of one ingredient out of [remainingByIngredientId].
///
/// An ingredient with no key is a mistake of the caller: the page builds both maps from the same
/// menu. The copy button must not crash on it, so this warns and reads the ingredient as covered.
/// The warning names the ingredient, so the gap is visible in the log instead of silent.
List<Quantity> remainingForCopy({required Ingredient ingredient, required Map<String, List<Quantity>> remainingByIngredientId}) {
  List<Quantity>? remaining = remainingByIngredientId[ingredient.id];
  // asAssertion is false on purpose: the default form runs an assert and throws in a debug build,
  // which would crash the copy button on the exact gap that this function must survive.
  Debug.logWarning(
    remaining == null,
    "No remaining amount for the ingredient ${ingredient.name} (${ingredient.id}). Copied as covered.",
    asAssertion: false,
  );
  return remaining ?? const [];
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
    List<Quantity> remaining = remainingForCopy(ingredient: ingredient, remainingByIngredientId: remainingByIngredientId);
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
/// (empty when nothing is needed).
///
/// Precondition: every amount in [remaining] is already a whole number of its unit. The page
/// rounds it once with [roundNeededAmount] (`computeRemainingQuantities`), and the per-trip split
/// ([distributeRemainingAcrossTrips]) keeps whole numbers. This function never rounds again, so
/// the copied text can never disagree with the page. An `assert` guards the precondition: a
/// caller that passes a fractional amount fails in development instead of printing "0.40 units".
///
/// The lines show the waste-minimal pack mix from [recommendCombination] (issue #26), not every
/// product's solo count: a product the mix does not pick is not listed. Where that mix contains
/// two or more equivalent products (same [productEquivalenceKey], e.g. two pizza flavors of the
/// same size), the group's packs are spread one-of-each via [distributeEquivalentPacks] (issue
/// #27), so identical variants list as "one of each" instead of all packs on one variant. A
/// variant that ends up with 0 packs is skipped.
String buildIngredientCopyLines({required Ingredient ingredient, required List<Quantity> remaining, bool freezeOnArrival = false}) {
  assert(
    remaining.every((Quantity q) => q.amount == q.amount.roundToDouble()),
    "buildIngredientCopyLines got a fractional amount for ${ingredient.name}. Round it with roundNeededAmount first.",
  );

  StringBuffer buffer = StringBuffer();

  if (!remaining.any((Quantity q) => q.amount > 0)) return "";

  String freezeSuffix = freezeOnArrival ? " (freeze on arrival)" : "";

  if (ingredient.products.isEmpty) {
    buffer.writeln("${ingredient.name}: ${_amountsText(remaining)}$freezeSuffix");
    return buffer.toString();
  }

  Quantity? primaryRemaining = remaining.firstWhereOrNull((q) => q.amount > 0 && ingredient.products.any((p) => p.unit == q.unit));
  if (primaryRemaining == null) {
    // No matching product unit -> fall back to raw amount line.
    buffer.writeln("${ingredient.name}: ${_amountsText(remaining)}$freezeSuffix");
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
    // The link tells the reader which product to take from the shelf. A product with no link
    // writes no line, because an empty line helps nobody.
    if (product.link.isNotEmpty) buffer.writeln("    ${product.link}");
  }

  return buffer.toString();
}
