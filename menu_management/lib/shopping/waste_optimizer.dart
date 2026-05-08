import "dart:math";

import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/recipes/models/quantity.dart";
import "package:menu_management/shopping/cooking_timeline.dart";

class ProductRecommendation {
  const ProductRecommendation({
    required this.product,
    required this.packsNeeded,
    required this.overBuyWaste,
    required this.expiryWaste,
    required this.isViable,
  });

  final Product product;
  final int packsNeeded;
  final double overBuyWaste;
  final double expiryWaste;
  final bool isViable;

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
    return ProductRecommendation(
      product: product,
      packsNeeded: packs,
      overBuyWaste: bought - totalNeeded,
      expiryWaste: 0,
      isViable: true,
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

  return ProductRecommendation(
    product: product,
    packsNeeded: packsNeeded,
    overBuyWaste: overBuyWaste,
    expiryWaste: expiryWaste,
    isViable: expiryWaste <= 0,
  );
}

class _NormalizedEvent {
  const _NormalizedEvent({required this.dayIndex, required this.amount});
  final int dayIndex;
  final double amount;
}

/// Converts cooking events to the product's unit, merging same-day events.
List<_NormalizedEvent> _normalizeEvents({
  required List<CookingEvent> events,
  required Product product,
  required Ingredient ingredient,
}) {
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
