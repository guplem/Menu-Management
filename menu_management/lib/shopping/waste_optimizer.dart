import "dart:math";

import "package:menu_management/flutter_essentials/library.dart";
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
/// Returns recommendations sorted by total waste (lowest first).
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

  recommendations.sort((ProductRecommendation a, ProductRecommendation b) => a.totalWaste.compareTo(b.totalWaste));
  return recommendations;
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

/// One product and how many packs of it to buy, as part of a [CombinationRecommendation].
class PackSelection {
  const PackSelection({required this.product, required this.packs});

  final Product product;
  final int packs;
}

/// A recommended purchase for one ingredient (and one unit): buy the given packs of one or more
/// products so the whole need is covered with the least total waste (over-buy + expiry).
///
/// When [selections] holds a single entry the recommendation is a single product; when it holds
/// more than one the recommendation is a mix (for example "1 small pack + 1 large pack").
class CombinationRecommendation {
  const CombinationRecommendation({required this.selections, required this.overBuyWaste, required this.expiryWaste});

  /// Selected products with pack counts > 0, sorted by ascending pack size then product link.
  /// Empty only when nothing needs buying (need is zero).
  final List<PackSelection> selections;
  final double overBuyWaste;
  final double expiryWaste;

  double get totalWaste => overBuyWaste + expiryWaste;
  bool get isSingleProduct => selections.length == 1;
  int get totalPacks => selections.fold(0, (int sum, PackSelection s) => sum + s.packs);
}

/// Upper bound on the number of pack-count vectors the combination search evaluates.
///
/// The search is the Cartesian product of `0..soloPacks` for each product, where `soloPacks` is
/// the packs that product alone would need (already accounts for expiry). When the product of
/// those ranges would exceed this cap (huge need with tiny packs, or many products), the search
/// is skipped and the best single product is returned instead, keeping the work bounded.
const int _maxCombinationVectors = 20000;

/// Recommends the waste-minimal way to buy one ingredient (in one unit) across [products],
/// allowing a mix of different packs when that beats every single product.
///
/// The search is bounded and deterministic (see [_maxCombinationVectors] and the tie-break in
/// [_isBetterCombination]). It reuses the same event-based simulation as [rankProducts]: food is
/// consumed on cooking days and only expires between events, so the chosen mix reflects the
/// individual cooking events, not only the weekly total.
///
/// [products] must all share the same unit (the caller groups them by unit). Returns null when
/// [products] is empty. Returns a recommendation with empty selections when nothing is needed.
CombinationRecommendation? recommendCombination({
  required double totalNeeded,
  required List<CookingEvent> events,
  required Ingredient ingredient,
  required List<Product> products,
}) {
  if (products.isEmpty) return null;
  if (totalNeeded <= 0) {
    return const CombinationRecommendation(selections: [], overBuyWaste: 0, expiryWaste: 0);
  }

  // Deterministic product order: smallest pack first, then by link, then by unit. The search and
  // tie-break both rely on this order, so the result never depends on the caller's input order.
  List<Product> sorted = [...products]
    ..sort((Product a, Product b) {
      int bySize = a.totalQuantityPerPack.compareTo(b.totalQuantityPerPack);
      if (bySize != 0) return bySize;
      int byLink = a.link.compareTo(b.link);
      if (byLink != 0) return byLink;
      return a.unit.index.compareTo(b.unit.index);
    });

  // Normalize events to the shared unit once; synthesize a single event when there is no timeline
  // (then the search only minimizes pack-granularity over-buy, with no expiry to model).
  List<_NormalizedEvent> normalizedEvents = _normalizeEvents(events: events, product: sorted.first, ingredient: ingredient);
  if (normalizedEvents.isEmpty) {
    normalizedEvents = [_NormalizedEvent(dayIndex: 0, amount: totalNeeded)];
  }

  // Per-product cap = packs that product alone would need (already accounts for expiry).
  List<int> caps = sorted
      .map((Product p) => _simulateProduct(product: p, totalNeeded: totalNeeded, events: events, ingredient: ingredient).packsNeeded)
      .toList();

  // Bound the search: if the Cartesian product of the ranges is too large, fall back to the best
  // single product from the per-product ranking.
  int vectorCount = 1;
  bool tooLarge = false;
  for (int cap in caps) {
    vectorCount *= (cap + 1);
    if (vectorCount > _maxCombinationVectors) {
      tooLarge = true;
      break;
    }
  }
  if (tooLarge) {
    return _bestSingleAsCombination(totalNeeded: totalNeeded, events: events, ingredient: ingredient, products: sorted);
  }

  List<int>? bestCounts;
  double bestOverBuy = 0;
  double bestExpiry = 0;
  List<int> counts = List<int>.filled(sorted.length, 0);

  void evaluate(List<int> candidate) {
    if (candidate.every((int c) => c == 0)) return;
    _CombinationSim sim = _simulateCombination(counts: candidate, products: sorted, events: normalizedEvents);
    if (!sim.feasible) return;

    double bought = 0;
    for (int i = 0; i < sorted.length; i++) {
      bought += candidate[i] * sorted[i].totalQuantityPerPack;
    }
    double overBuy = max(0, bought - sim.consumed - sim.expiryWaste);

    if (bestCounts == null || _isBetterCombination(candidate, overBuy + sim.expiryWaste, bestCounts!, bestOverBuy + bestExpiry)) {
      bestCounts = List<int>.from(candidate);
      bestOverBuy = overBuy;
      bestExpiry = sim.expiryWaste;
    }
  }

  // Enumerate every pack-count vector in a fixed order (odometer over the product ranges).
  void recurse(int index) {
    if (index == sorted.length) {
      evaluate(counts);
      return;
    }
    for (int c = 0; c <= caps[index]; c++) {
      counts[index] = c;
      recurse(index + 1);
    }
    counts[index] = 0;
  }

  recurse(0);

  if (bestCounts == null) return null;

  List<PackSelection> selections = [];
  for (int i = 0; i < sorted.length; i++) {
    if (bestCounts![i] > 0) selections.add(PackSelection(product: sorted[i], packs: bestCounts![i]));
  }

  return CombinationRecommendation(selections: selections, overBuyWaste: bestOverBuy, expiryWaste: bestExpiry);
}

/// Whether candidate combination [aCounts]/[aWaste] should beat the current best [bCounts]/[bWaste].
///
/// Tie-break order: (1) lower total waste, (2) fewer distinct products (prefer a single product
/// over an equal-waste mix), (3) fewer total packs, (4) lexicographically smaller count vector.
bool _isBetterCombination(List<int> aCounts, double aWaste, List<int> bCounts, double bWaste) {
  const double epsilon = 1e-6;
  if ((aWaste - bWaste).abs() > epsilon) return aWaste < bWaste;

  int aDistinct = aCounts.where((int c) => c > 0).length;
  int bDistinct = bCounts.where((int c) => c > 0).length;
  if (aDistinct != bDistinct) return aDistinct < bDistinct;

  int aTotal = aCounts.fold(0, (int s, int c) => s + c);
  int bTotal = bCounts.fold(0, (int s, int c) => s + c);
  if (aTotal != bTotal) return aTotal < bTotal;

  for (int i = 0; i < aCounts.length; i++) {
    if (aCounts[i] != bCounts[i]) return aCounts[i] < bCounts[i];
  }
  return false;
}

/// Wraps the best single product (from [rankProducts]) as a [CombinationRecommendation].
/// Used as the bounded-search fallback when the combination space is too large.
CombinationRecommendation _bestSingleAsCombination({
  required double totalNeeded,
  required List<CookingEvent> events,
  required Ingredient ingredient,
  required List<Product> products,
}) {
  List<ProductRecommendation> ranked = rankProducts(totalNeeded: totalNeeded, events: events, ingredient: ingredient, products: products);
  ProductRecommendation best = ranked.first;
  return CombinationRecommendation(
    selections: [PackSelection(product: best.product, packs: best.packsNeeded)],
    overBuyWaste: best.overBuyWaste,
    expiryWaste: best.expiryWaste,
  );
}

/// Result of simulating one pack-count vector across the cooking events.
class _CombinationSim {
  const _CombinationSim({required this.feasible, required this.expiryWaste, required this.consumed});

  /// False when the purchased packs run out before covering every event.
  final bool feasible;
  final double expiryWaste;
  final double consumed;
}

/// Simulates consuming a heterogeneous pool of containers (from multiple products) across events.
///
/// Each pack contributes `itemsPerPack` containers of `quantityPerItem`. Containers are consumed
/// soonest-expiry-first; when a new container must be opened, the smallest container that fully
/// covers the remaining need is opened (else the largest available), which keeps leftover that
/// must survive to a later event as small as possible. Both rules are deterministic. For a single
/// product this reduces to the same sequential consumption as [_simulateProduct].
_CombinationSim _simulateCombination({required List<int> counts, required List<Product> products, required List<_NormalizedEvent> events}) {
  List<int> poolContainers = [for (int i = 0; i < products.length; i++) counts[i] * products[i].itemsPerPack];
  List<_OpenContainer> open = [];
  double expiryWaste = 0;
  double consumed = 0;

  for (_NormalizedEvent event in events) {
    double amountNeeded = event.amount;

    // Expire open containers whose opened shelf life has been exceeded by this event's day.
    open.removeWhere((_OpenContainer c) {
      int? shelfLife = c.shelfLife;
      if (shelfLife != null && (event.dayIndex - c.openedDay) > shelfLife) {
        expiryWaste += c.remaining;
        return true;
      }
      return false;
    });

    // Consume from already-open containers, soonest-expiry first (null shelf life = never, last).
    open.sort((_OpenContainer a, _OpenContainer b) => a.expiryKey.compareTo(b.expiryKey));
    for (_OpenContainer c in open) {
      if (amountNeeded <= 0) break;
      double take = min(c.remaining, amountNeeded);
      c.remaining -= take;
      amountNeeded -= take;
      consumed += take;
    }
    open.removeWhere((_OpenContainer c) => c.remaining <= 0);

    // Open new containers until the event is covered or the pool is empty.
    while (amountNeeded > 0) {
      int? chosen = _chooseContainerToOpen(poolContainers: poolContainers, products: products, amountNeeded: amountNeeded);
      if (chosen == null) return const _CombinationSim(feasible: false, expiryWaste: 0, consumed: 0);

      poolContainers[chosen]--;
      double size = products[chosen].quantityPerItem;
      double take = min(size, amountNeeded);
      amountNeeded -= take;
      consumed += take;
      double remaining = size - take;
      if (remaining > 0) {
        open.add(_OpenContainer(remaining: remaining, openedDay: event.dayIndex, shelfLife: products[chosen].shelfLifeDaysOpened));
      }
    }
  }

  return _CombinationSim(feasible: true, expiryWaste: expiryWaste, consumed: consumed);
}

/// Picks which product's container to open next: the smallest whose container size fully covers
/// [amountNeeded], else the largest available. Ties break by product index. Returns null when the
/// pool is empty.
int? _chooseContainerToOpen({required List<int> poolContainers, required List<Product> products, required double amountNeeded}) {
  int? smallestFitting;
  int? largest;
  for (int i = 0; i < products.length; i++) {
    if (poolContainers[i] <= 0) continue;
    double size = products[i].quantityPerItem;
    if (size >= amountNeeded && (smallestFitting == null || size < products[smallestFitting].quantityPerItem)) {
      smallestFitting = i;
    }
    if (largest == null || size > products[largest].quantityPerItem) {
      largest = i;
    }
  }
  return smallestFitting ?? largest;
}

class _OpenContainer {
  _OpenContainer({required this.remaining, required this.openedDay, required this.shelfLife});

  double remaining;
  final int openedDay;
  final int? shelfLife;

  /// Day the container expires; a large sentinel when it never expires, so it is used last.
  int get expiryKey => shelfLife == null ? 1 << 30 : openedDay + shelfLife!;
}

/// Human-readable pack lines for a recommended combination, one per selected product.
/// Mirrors the copy-list wording, for example: "6x125grams: 2 packs" or "500 grams/pack: 1 pack".
List<String> combinationPackLines(CombinationRecommendation recommendation) {
  return recommendation.selections.map((PackSelection selection) {
    String label = _packLabel(selection.product);
    String packWord = selection.packs == 1 ? "pack" : "packs";
    return "$label: ${selection.packs} $packWord";
  }).toList();
}

/// Compact one-line description of a combination for inline UI,
/// for example: "1x 250 grams/pack + 1x 600 grams/pack".
String combinationInlineSummary(CombinationRecommendation recommendation) {
  return recommendation.selections.map((PackSelection selection) => "${selection.packs}x ${_packLabel(selection.product)}").join(" + ");
}

String _packLabel(Product product) => product.packLabel() ?? "${product.totalQuantityPerPack.toFormattedAmount()} ${product.unit.name}/pack";

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
