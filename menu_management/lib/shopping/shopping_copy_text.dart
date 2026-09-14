// The shopping side gives each copy format its own builder, while the menu side switches formats
// with the MenuCopyFormat enum. That difference is deliberate. The two menu formats write the same
// lines with one extra piece of text, so one function with a flag keeps them in step. The shopping
// formats write different lines: the simplified one needs neither the trip plan nor the packs, and
// the detailed and the checklist ones write a different shape from the same input. One function
// with a flag would take parameters that some of its callers must leave empty.
//
// The detailed and the checklist formats read the same input, so they share the parts that must
// never drift apart: the trip sections ([_buildTripSections]) and the pack mix
// ([shoppingPackSelection]). Only the per-line shape differs.
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/recipes/models/quantity.dart";
import "package:menu_management/shopping/multi_trip_planner.dart";
import "package:menu_management/shopping/owned_amount.dart";
import "package:menu_management/shopping/trip_amount_distributor.dart";
import "package:menu_management/shopping/waste_optimizer.dart";

/// Writes the copied text of one ingredient, for one trip's worth of [remaining].
///
/// [buildIngredientCopyLines] and [buildIngredientChecklistLines] both match this shape, so the
/// shared builders below take either of them and write the same sections around it.
typedef IngredientLinesBuilder = String Function({required Ingredient ingredient, required List<Quantity> remaining, bool freezeOnArrival});

/// Sorts the ingredients of the copied list by name, ignoring upper and lower case.
///
/// Every copy builder calls this, so one menu can never produce two different ingredient orders.
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
///
/// [freezeOnArrivalIngredientIds] names the ingredients that the user must freeze on the day of
/// the trip (ADR 0015). Each of them keeps the same "(freeze on arrival)" suffix that the detailed
/// text writes. Without the suffix the one-trip plan cannot be followed safely, because the plan
/// assumes the freezer. Build the set with [computeFreezeOnArrivalIngredientIds].
///
/// Precondition: every amount is already a whole number of its unit, as in [buildIngredientCopyLines].
String buildSimplifiedShoppingCopyText({
  required List<Ingredient> ingredients,
  required Map<String, List<Quantity>> remainingByIngredientId,
  Set<String> freezeOnArrivalIngredientIds = const {},
}) {
  StringBuffer buffer = StringBuffer();
  for (Ingredient ingredient in sortIngredientsForCopy(ingredients)) {
    List<Quantity> remaining = remainingForCopy(ingredient: ingredient, remainingByIngredientId: remainingByIngredientId);
    assertWholeShoppingAmounts(ingredient: ingredient, remaining: remaining);
    if (!remaining.any((Quantity quantity) => quantity.amount > 0)) continue;
    String freezeSuffix = freezeOnArrivalIngredientIds.contains(ingredient.id) ? freezeOnArrivalSuffix : "";
    buffer.writeln("${ingredient.name}: ${shoppingAmountsText(remaining)}$freezeSuffix");
  }
  return buffer.toString().trimRight();
}

/// The note that tells the reader to freeze an item on the day of the trip (ADR 0015).
/// Every copy format and the PDF write it, so one plan reads the same way in each of them.
const String freezeOnArrivalSuffix = " (freeze on arrival)";

/// Fails when an amount is not a whole number of its unit.
///
/// Every copy builder and the shopping PDF call this, so a caller that skips [roundNeededAmount]
/// fails in development in every format instead of printing "0.4 grams" in one of them.
void assertWholeShoppingAmounts({required Ingredient ingredient, required List<Quantity> remaining}) {
  assert(
    remaining.every((Quantity q) => q.amount == q.amount.roundToDouble()),
    "The shopping export got a fractional amount for ${ingredient.name}. Round it with roundNeededAmount first.",
  );
}

/// Returns the ids of the ingredients that the user must freeze on the day of the trip.
///
/// Pure: takes the same input as the copy builders plus the planned trips. It reads the same
/// per-ingredient split as [buildMultiTripCopyText].
///
/// The detailed text marks each trip line on its own, so one ingredient can carry the note on one
/// trip and not on another. This set holds one flag per ingredient, and one marked trip marks the
/// whole ingredient. The two formats therefore read differently for such an ingredient, and that
/// is on purpose: the simplified text holds no trip, so its reader buys every batch on day one.
/// The batch of a later trip then also has to wait, and only the freezer keeps it.
Set<String> computeFreezeOnArrivalIngredientIds({
  required List<Ingredient> ingredients,
  required Map<String, List<Quantity>> remainingByIngredientId,
  required List<ShoppingTrip> trips,
}) {
  Set<String> frozen = {};
  if (trips.isEmpty) return frozen;
  for (Ingredient ingredient in ingredients) {
    List<Quantity> remaining = remainingForCopy(ingredient: ingredient, remainingByIngredientId: remainingByIngredientId);
    List<TripAllocation> allocations = distributeRemainingAcrossTrips(ingredient: ingredient, pageRemaining: remaining, trips: trips);
    if (allocations.any((TripAllocation allocation) => allocation.freezeOnArrival)) frozen.add(ingredient.id);
  }
  return frozen;
}

/// Writes the amounts of one ingredient, for example "500 grams + 2 pieces".
///
/// Every copy format and the shopping PDF call this, so one ingredient reads the same way in each
/// of them. It drops every amount that is zero or less, because the user buys none of those.
String shoppingAmountsText(List<Quantity> remaining) {
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
  return _buildFlatList(ingredients: ingredients, remainingByIngredientId: remainingByIngredientId, buildLines: buildIngredientCopyLines);
}

/// Writes one ingredient after another, sorted by name, with no trip header.
String _buildFlatList({
  required List<Ingredient> ingredients,
  required Map<String, List<Quantity>> remainingByIngredientId,
  required IngredientLinesBuilder buildLines,
}) {
  StringBuffer buffer = StringBuffer();
  for (Ingredient ingredient in sortIngredientsForCopy(ingredients)) {
    buffer.write(
      buildLines(
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
/// Each ingredient writes a name line, an indented pack line per pack of the mix, and the store
/// link under each pack line. Use [buildChecklistCopyText] for the flat one-line-per-pack shape.
String buildMultiTripCopyText({
  required List<Ingredient> ingredients,
  required Map<String, List<Quantity>> remainingByIngredientId,
  required List<ShoppingTrip> trips,
  required String Function(ShoppingTrip trip) tripLabel,
}) {
  return _buildTripSections(
    ingredients: ingredients,
    remainingByIngredientId: remainingByIngredientId,
    trips: trips,
    tripLabel: tripLabel,
    buildLines: buildIngredientCopyLines,
  );
}

/// Builds the copied shopping list as a checklist: one line per pack, under one header per trip.
///
/// Pure: takes the same input as [buildMultiTripCopyText] and writes the same trip sections, so
/// both formats split one menu the same way.
///
/// The reader pastes this text into a checklist app, which turns each line into one item. Every
/// line therefore stands on its own: it names the ingredient, the pack and the pack count, and it
/// carries no indent and no store link. A link on its own line would become an item that the
/// reader cannot tick off in a shop. Use [buildMultiTripCopyText] when the reader wants the links.
String buildChecklistCopyText({
  required List<Ingredient> ingredients,
  required Map<String, List<Quantity>> remainingByIngredientId,
  required List<ShoppingTrip> trips,
  required String Function(ShoppingTrip trip) tripLabel,
}) {
  return _buildTripSections(
    ingredients: ingredients,
    remainingByIngredientId: remainingByIngredientId,
    trips: trips,
    tripLabel: tripLabel,
    buildLines: buildIngredientChecklistLines,
  );
}

/// Writes one section per planned trip, and lets [buildLines] shape the lines inside it.
///
/// It spreads the on-screen remaining of each ingredient across the trip weeks in the on-screen
/// unit, so the copied per-trip amounts sum to exactly what the page shows (same unit, no
/// rounding drift). It buckets the resulting lines by week, then writes the sections in the
/// trip order of the planner. A section header gets a row of dashes of its own length.
String _buildTripSections({
  required List<Ingredient> ingredients,
  required Map<String, List<Quantity>> remainingByIngredientId,
  required List<ShoppingTrip> trips,
  required String Function(ShoppingTrip trip) tripLabel,
  required IngredientLinesBuilder buildLines,
}) {
  if (trips.isEmpty) return _buildFlatList(ingredients: ingredients, remainingByIngredientId: remainingByIngredientId, buildLines: buildLines);

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
      buffer.write(buildLines(ingredient: line.ingredient, remaining: line.allocation.quantities, freezeOnArrival: line.allocation.freezeOnArrival));
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
/// The lines show the waste-minimal pack mix from [shoppingPackSelection] (issue #26), not every
/// product's solo count: a product the mix does not pick is not listed.
String buildIngredientCopyLines({required Ingredient ingredient, required List<Quantity> remaining, bool freezeOnArrival = false}) {
  assertWholeShoppingAmounts(ingredient: ingredient, remaining: remaining);

  StringBuffer buffer = StringBuffer();

  if (!remaining.any((Quantity q) => q.amount > 0)) return "";

  String freezeSuffix = freezeOnArrival ? freezeOnArrivalSuffix : "";

  List<({Product product, int packs})>? selection = shoppingPackSelection(ingredient: ingredient, remaining: remaining);
  if (selection == null) {
    buffer.writeln("${ingredient.name}: ${shoppingAmountsText(remaining)}$freezeSuffix");
    return buffer.toString();
  }

  buffer.writeln("${ingredient.name}$freezeSuffix");
  for (({Product product, int packs}) line in selection) {
    buffer.writeln("  ${productShoppingLabel(line.product)}: ${line.packs} ${_packWord(line.packs)}");
    // The link tells the reader which product to take from the shelf. A product with no link
    // writes no line, because an empty line helps nobody.
    if (line.product.link.isNotEmpty) buffer.writeln("    ${line.product.link}");
  }

  return buffer.toString();
}

/// Builds the checklist text for one ingredient (one trip's worth of [remaining]).
///
/// Pure, and it takes the same input and holds the same precondition as [buildIngredientCopyLines].
/// It writes the same pack mix, on one line per pack: "Banana - 1 piece/pack: 5 packs". Each line
/// is one checklist item, so the ingredient name repeats on every line of the same ingredient and
/// the store link is left out.
///
/// The freeze note rides on each pack line, not on a header line, for the same reason.
///
/// An ingredient with no pack to write falls back to the raw amount, for example "Salt: 2
/// teaspoons". That happens when the ingredient has no product, when no product matches the unit
/// that is left to buy, and when the pack solver finds no mix. The detailed text writes the bare
/// ingredient name in that last case; the checklist writes the amount instead, because a checklist
/// item with no amount tells the reader nothing.
String buildIngredientChecklistLines({required Ingredient ingredient, required List<Quantity> remaining, bool freezeOnArrival = false}) {
  assertWholeShoppingAmounts(ingredient: ingredient, remaining: remaining);

  if (!remaining.any((Quantity q) => q.amount > 0)) return "";

  String freezeSuffix = freezeOnArrival ? freezeOnArrivalSuffix : "";

  List<({Product product, int packs})>? selection = shoppingPackSelection(ingredient: ingredient, remaining: remaining);
  if (selection == null || selection.isEmpty) return "${ingredient.name}: ${shoppingAmountsText(remaining)}$freezeSuffix\n";

  StringBuffer buffer = StringBuffer();
  for (({Product product, int packs}) line in selection) {
    buffer.writeln("${ingredient.name} - ${productShoppingLabel(line.product)}: ${line.packs} ${_packWord(line.packs)}$freezeSuffix");
  }
  return buffer.toString();
}

/// Names the unit of [packs]: "pack" for one, "packs" for any other count.
String _packWord(int packs) => packs == 1 ? "pack" : "packs";

/// Picks the packs to buy of one ingredient for one trip's worth of [remaining].
///
/// Returns null when no pack line is possible: the ingredient has no product, or no product uses
/// the unit that the user must still buy. The caller then writes the raw amount instead.
///
/// Returns the packs of the waste-minimal mix from [recommendCombination] (issue #26), not every
/// product's solo count: a product that the mix does not pick is not in the result. Where that mix
/// holds two or more equivalent products (same [productEquivalenceKey], for example two pizza
/// flavors of the same size), the group's packs are spread one-of-each via
/// [distributeEquivalentPacks] (issue #27), so identical variants read as "one of each" instead of
/// all packs on one variant. A variant that ends up with 0 packs is left out.
///
/// The detailed text and the checklist text both call this, so they can never recommend two
/// different pack mixes for the same ingredient.
List<({Product product, int packs})>? shoppingPackSelection({required Ingredient ingredient, required List<Quantity> remaining}) {
  if (ingredient.products.isEmpty) return null;

  Quantity? primaryRemaining = remaining.firstWhereOrNull((q) => q.amount > 0 && ingredient.products.any((p) => p.unit == q.unit));
  if (primaryRemaining == null) return null;

  // Products matching the primary unit, in configured order.
  List<Product> matching = ingredient.products.where((Product p) => p.unit == primaryRemaining.unit).toList();

  // Pick the waste-minimal mix of packs for this amount. Events are empty: each trip is already a
  // shelf-life-safe bucket, so the mix only needs to minimize pack-granularity over-buy for the
  // amount bought on this trip.
  CombinationRecommendation? combination = recommendCombination(
    totalNeeded: primaryRemaining.amount,
    events: const [],
    ingredient: ingredient,
    products: matching,
  );
  if (combination == null) return const [];

  // Total packs the mix buys per equivalence group. Equivalent variants share one key, so the
  // solver may load them all onto one representative; summing per key recovers the group's total.
  Map<String, int> packsByKey = {};
  for (PackSelection selection in combination.selections) {
    String key = productEquivalenceKey(selection.product);
    packsByKey[key] = (packsByKey[key] ?? 0) + selection.packs;
  }

  Map<String, List<Product>> groups = {};
  for (Product product in matching) {
    groups.putIfAbsent(productEquivalenceKey(product), () => <Product>[]).add(product);
  }
  Map<String, List<int>> sharesByKey = {};
  for (MapEntry<String, List<Product>> group in groups.entries) {
    int total = packsByKey[group.key] ?? 0;
    sharesByKey[group.key] = distributeEquivalentPacks(totalPacks: total, groupSize: group.value.length);
  }

  List<({Product product, int packs})> lines = [];
  Map<String, int> cursorByKey = {};
  for (Product product in matching) {
    String key = productEquivalenceKey(product);
    int cursor = cursorByKey[key] ?? 0;
    cursorByKey[key] = cursor + 1;
    int packs = sharesByKey[key]![cursor];
    if (packs <= 0) continue;
    lines.add((product: product, packs: packs));
  }
  return lines;
}

/// Names one product of the shopping list, for example "Espaguetis (6x125grams)".
///
/// The name tells the reader which product to take from the shelf, and the pack size tells how
/// much one pack holds. A product has no name field, so the name comes from the store link. A
/// link that names nothing leaves the pack size alone.
///
/// Every copy format and the PDF call this, so one product reads the same way in each of them.
String productShoppingLabel(Product product) {
  String packSize = product.packLabel() ?? "${product.totalQuantityPerPack.toFormattedAmount()} ${product.unit.name}/pack";
  String? name = product.nameFromLink();
  return name == null ? packSize : "$name ($packSize)";
}
