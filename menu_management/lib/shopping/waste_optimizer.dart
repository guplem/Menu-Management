import "dart:math";

import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/recipes/models/quantity.dart";
import "package:menu_management/shopping/cooking_timeline.dart";

/// Maximum share of a single recipe's need that may go unmet when buying one pack less.
///
/// When dropping the last (mostly-empty) pack would leave every affected cooking event short
/// by no more than this fraction of its own need, the optimizer recommends buying one pack
/// less and flags the recommendation as [ProductRecommendation.underBuy]. Evaluated PER RECIPE
/// (per cooking event), not on the ingredient total, so a small total shortfall that lands
/// entirely on one small recipe does not trigger the reduction. Starting point: 20%.
const double underBuyMaxRecipeShortfallFraction = 0.20;

class ProductRecommendation {
  const ProductRecommendation({
    required this.product,
    required this.packsNeeded,
    required this.overBuyWaste,
    required this.expiryWaste,
    required this.isViable,
    this.underBuy = false,
    this.shortfall = 0,
  });

  final Product product;
  final int packsNeeded;
  final double overBuyWaste;
  final double expiryWaste;
  final bool isViable;

  /// True when [packsNeeded] was reduced by one pack below what fully covers the recipes,
  /// trading a small per-recipe shortfall for removing the over-buy surplus. The UI shows a
  /// "buying less than recipes calculate" warning in this case.
  ///
  /// When true, [overBuyWaste]/[expiryWaste]/[totalWaste] keep the FULL-pack-buy values (the waste
  /// you would get buying the non-reduced count). This keeps ranking and the best-option marker
  /// comparing every product on its full-buy waste; only [packsNeeded] and [shortfall] reflect the
  /// reduction. See [rankProducts].
  final bool underBuy;

  /// Amount (in the product's unit) by which the recipes fall short when [underBuy] is true;
  /// zero otherwise.
  final double shortfall;

  double get totalWaste => overBuyWaste + expiryWaste;

  /// Returns a copy with a different [packsNeeded]; used to spread packs across
  /// equivalent products (all other fields, including waste, stay the same).
  ProductRecommendation copyWithPacksNeeded(int newPacksNeeded) {
    return ProductRecommendation(
      product: product,
      packsNeeded: newPacksNeeded,
      overBuyWaste: overBuyWaste,
      expiryWaste: expiryWaste,
      isViable: isViable,
    );
  }
}

/// Ranks products by total waste (over-buy + expiry) for a given required amount.
///
/// Uses an event-based simulation: ingredients are consumed on cooking days,
/// and only expire between cooking events (once cooked, food is preserved).
///
/// [totalNeeded] is the total amount needed in the product's unit.
/// [events] is the cooking timeline for this ingredient.
/// [ingredient] provides unit conversion functions.
/// [products] is the list of available products to compare.
///
/// Returns recommendations sorted by total waste (lowest first). Ties keep the
/// input order so the ordering (and the cycle below) is deterministic.
///
/// Equivalent products are cycled: when two or more products share every
/// buying/consumption characteristic (see [productEquivalenceKey]) and one or more
/// packs are needed, the packs are spread one-of-each across them instead of loading
/// all packs onto the single top-ranked product. This gives variety (e.g. one of
/// each pizza flavor) without changing total cost, since equivalent products have
/// identical pack size and therefore identical waste. When only one pack is needed
/// the first product gets it and the rest get 0, so the group's total stays exact.
List<ProductRecommendation> rankProducts({
  required double totalNeeded,
  required List<CookingEvent> events,
  required Ingredient ingredient,
  required List<Product> products,
}) {
  if (products.isEmpty) return const [];

  List<ProductRecommendation> recommendations = products.map((Product product) {
    return _simulateProduct(product: product, totalNeeded: totalNeeded, events: events, ingredient: ingredient);
  }).toList();

  // Stable sort: lowest waste first, ties broken by original input order so the
  // cycle distribution below is deterministic.
  List<int> order = List<int>.generate(recommendations.length, (int i) => i);
  order.sort((int a, int b) {
    int byWaste = recommendations[a].totalWaste.compareTo(recommendations[b].totalWaste);
    if (byWaste != 0) return byWaste;
    return a.compareTo(b);
  });
  recommendations = order.map((int i) => recommendations[i]).toList();

  return _cycleEquivalentProducts(recommendations);
}

/// Spreads packs one-of-each across groups of equivalent products.
///
/// Products are grouped by [productEquivalenceKey]. Within a group of 2+ products
/// that each need the same number of packs `p >= 1`, the `p` packs are distributed
/// via [distributeEquivalentPacks] in the group's (already sorted) order: earlier
/// products absorb the remainder (so `p = 1` gives the first product 1 and the rest
/// 0, keeping the group total exact). Waste fields are left untouched: equivalent
/// products have identical waste, and it is a per-product "if this were the sole
/// supplier" figure that the UI compares to flag the best option, so all group
/// members stay tied for best.
List<ProductRecommendation> _cycleEquivalentProducts(List<ProductRecommendation> recommendations) {
  Map<String, List<int>> groups = {};
  for (int i = 0; i < recommendations.length; i++) {
    groups.putIfAbsent(productEquivalenceKey(recommendations[i].product), () => []).add(i);
  }

  List<ProductRecommendation> result = List<ProductRecommendation>.of(recommendations);
  for (List<int> memberIndexes in groups.values) {
    if (memberIndexes.length < 2) continue;
    int totalPacks = recommendations[memberIndexes.first].packsNeeded;
    if (totalPacks <= 0) continue; // Nothing to distribute when no packs are needed.

    List<int> shares = distributeEquivalentPacks(totalPacks: totalPacks, groupSize: memberIndexes.length);
    for (int position = 0; position < memberIndexes.length; position++) {
      int index = memberIndexes[position];
      result[index] = recommendations[index].copyWithPacksNeeded(shares[position]);
    }
  }
  return result;
}

/// Distributes [totalPacks] one-of-each across [groupSize] equivalent products.
///
/// Returns per-product pack counts in group order: `base = totalPacks ~/ groupSize`
/// each, with the remainder given to the earliest products. Examples: (3, 3) -> [1,1,1];
/// (4, 3) -> [2,1,1]; (2, 3) -> [1,1,0]; (5, 1) -> [5]. Single source of truth for the
/// one-of-each split used by [rankProducts], the shopping card, and the copied list.
List<int> distributeEquivalentPacks({required int totalPacks, required int groupSize}) {
  if (groupSize <= 0) return const [];
  int base = totalPacks ~/ groupSize;
  int remainder = totalPacks % groupSize;
  return List<int>.generate(groupSize, (int position) => base + (position < remainder ? 1 : 0));
}

/// The set of characteristics that make two products interchangeable for buying.
///
/// Includes every field that changes how a product is bought and consumed:
/// pack shape ([Product.itemsPerPack], [Product.quantityPerItem], [Product.unit]),
/// both shelf lives, and whether it can be frozen. Excludes [Product.link], which
/// only identifies the store item or variant (e.g. two pizza flavors of the same
/// size are equivalent and should be cycled). Price is not modeled on [Product];
/// if it is added later it belongs in this key.
///
/// Public so the shopping card and the copied list define equivalence in exactly
/// one place (same grouping the cycle above uses).
String productEquivalenceKey(Product product) {
  return [
    product.itemsPerPack,
    product.quantityPerItem,
    product.unit.name,
    product.shelfLifeDaysOpened,
    product.shelfLifeDaysClosed,
    product.canBeFrozen,
  ].join("|");
}

/// Simulates sequential container consumption across cooking events for a single product.
ProductRecommendation _simulateProduct({
  required Product product,
  required double totalNeeded,
  required List<CookingEvent> events,
  required Ingredient ingredient,
}) {
  int? shelfLife = product.shelfLifeDaysOpened;

  // Convert events to product's unit and sort by day
  List<_NormalizedEvent> normalizedEvents = _normalizeEvents(events: events, product: product, ingredient: ingredient);

  // If no events or no shelf life concern, fall back to simple pack calculation
  if (normalizedEvents.isEmpty || shelfLife == null) {
    int packs = product.packsNeeded(totalNeeded);
    double bought = packs * product.totalQuantityPerPack;
    return _considerBuyingOnePackLess(
      product: product,
      packsNeeded: packs,
      overBuyWaste: bought - totalNeeded,
      expiryWaste: 0,
      events: normalizedEvents,
      totalNeeded: totalNeeded,
    );
  }

  // Simulate sequential consumption
  double containerSize = product.itemsPerPack > 1 ? product.quantityPerItem : product.totalQuantityPerPack;
  double openRemaining = 0;
  int openedOnDay = -9999;
  double expiryWaste = 0;
  int containersOpened = 0;

  for (_NormalizedEvent event in normalizedEvents) {
    double amountNeeded = event.amount;

    // Check if open container has expired
    if (openRemaining > 0 && (event.dayIndex - openedOnDay) > shelfLife) {
      expiryWaste += openRemaining;
      openRemaining = 0;
    }

    // Consume from open container first
    if (openRemaining > 0) {
      double consumed = min(openRemaining, amountNeeded);
      openRemaining -= consumed;
      amountNeeded -= consumed;
    }

    // Open new containers as needed
    while (amountNeeded > 0) {
      containersOpened++;
      openRemaining = containerSize;
      openedOnDay = event.dayIndex;
      double consumed = min(openRemaining, amountNeeded);
      openRemaining -= consumed;
      amountNeeded -= consumed;
    }
  }

  // Calculate packs needed and over-buy waste
  int packsNeeded;
  double overBuyWaste;

  if (product.itemsPerPack > 1) {
    packsNeeded = (containersOpened / product.itemsPerPack).ceil();
    int unusedItems = packsNeeded * product.itemsPerPack - containersOpened;
    overBuyWaste = openRemaining + unusedItems * containerSize;
  } else {
    packsNeeded = containersOpened;
    overBuyWaste = openRemaining;
  }

  return _considerBuyingOnePackLess(
    product: product,
    packsNeeded: packsNeeded,
    overBuyWaste: overBuyWaste,
    expiryWaste: expiryWaste,
    events: normalizedEvents,
    totalNeeded: totalNeeded,
  );
}

/// Builds the recommendation, optionally reducing it by one pack when buying one pack less
/// removes the over-buy surplus while keeping every affected recipe's shortfall under
/// [underBuyMaxRecipeShortfallFraction].
///
/// The shortfall from dropping one pack is `totalQuantityPerPack - overBuyWaste`. It is
/// allocated to cooking events from the latest day backward (later recipes run short first,
/// matching the sequential consumption simulation). The reduction applies only when every
/// affected event stays within the per-recipe threshold. When there are no events (fallback
/// path), the whole need is treated as a single recipe.
ProductRecommendation _considerBuyingOnePackLess({
  required Product product,
  required int packsNeeded,
  required double overBuyWaste,
  required double expiryWaste,
  required List<_NormalizedEvent> events,
  required double totalNeeded,
}) {
  ProductRecommendation fullBuy = ProductRecommendation(
    product: product,
    packsNeeded: packsNeeded,
    overBuyWaste: overBuyWaste,
    expiryWaste: expiryWaste,
    isViable: expiryWaste <= 0,
  );

  double packQuantity = product.totalQuantityPerPack;

  // Only reduce viable, over-buying recommendations that keep at least one pack after the drop.
  if (expiryWaste > 0 || overBuyWaste <= 0 || packsNeeded < 2 || packQuantity <= 0) return fullBuy;

  // Amount the recipes fall short if we buy one pack less.
  double shortfall = packQuantity - overBuyWaste;
  if (shortfall <= 0) return fullBuy;

  // Per-recipe check: the shortfall lands on the latest cooking events first.
  List<_NormalizedEvent> recipeEvents = events.isNotEmpty ? events : [_NormalizedEvent(dayIndex: 0, amount: totalNeeded)];
  double remaining = shortfall;
  for (int i = recipeEvents.length - 1; i >= 0 && remaining > 1e-9; i--) {
    double eventNeed = recipeEvents[i].amount;
    if (eventNeed <= 0) continue;
    double eventShortfall = min(remaining, eventNeed);
    // Reject when this recipe would be short by more than the allowed fraction of its own need.
    if (eventShortfall > underBuyMaxRecipeShortfallFraction * eventNeed + 1e-9) return fullBuy;
    remaining -= eventShortfall;
  }
  // Reject when the shortfall exceeds everything the recipes need (nothing left to absorb it).
  if (remaining > 1e-9) return fullBuy;

  // Keep the full-pack-buy waste so ranking and the best-option marker do not favor this reduced
  // recommendation over a product that fully covers the need with small waste (see [underBuy]).
  return ProductRecommendation(
    product: product,
    packsNeeded: packsNeeded - 1,
    overBuyWaste: overBuyWaste,
    expiryWaste: expiryWaste,
    isViable: expiryWaste <= 0,
    underBuy: true,
    shortfall: shortfall,
  );
}

class _NormalizedEvent {
  const _NormalizedEvent({required this.dayIndex, required this.amount});
  final int dayIndex;
  final double amount;
}

/// Converts cooking events to the product's unit, merging same-day events.
List<_NormalizedEvent> _normalizeEvents({required List<CookingEvent> events, required Product product, required Ingredient ingredient}) {
  Map<int, double> byDay = {};

  for (CookingEvent event in events) {
    double amount = event.amountInUnit(
      product.unit,
      toGrams: (Quantity q) => ingredient.toGrams(q),
      fromGrams: (double g, _) => ingredient.fromGrams(g, product.unit),
    );
    if (amount > 0) {
      byDay[event.dayIndex] = (byDay[event.dayIndex] ?? 0) + amount;
    }
  }

  List<_NormalizedEvent> result = byDay.entries.map((MapEntry<int, double> e) => _NormalizedEvent(dayIndex: e.key, amount: e.value)).toList();
  result.sort((_NormalizedEvent a, _NormalizedEvent b) => a.dayIndex.compareTo(b.dayIndex));
  return result;
}
