import "dart:math";

import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/recipes/enums/unit.dart";
import "package:menu_management/recipes/models/quantity.dart";

/// A user's owned stock of one ingredient, as entered on the shopping page.
///
/// [unit] is the unit the user picked in the "owned" dropdown. It is null when
/// the user picked "packs" (product-relative), matching [Unit]? null everywhere.
class OwnedStock {
  const OwnedStock({required this.amount, required this.unit});

  final double amount;

  /// null means "packs".
  final Unit? unit;
}

/// Converts a user's owned amount into [targetUnit] for an ingredient.
///
/// This is the single owned-to-target-unit conversion used by both the on-screen
/// shopping list and the multi-trip planner, so both always subtract the same amount.
///
/// [ownedUnit] is the unit the user picked; null means "packs" (product-relative).
/// Returns 0 when the amount is non-positive or no conversion path exists.
double ownedAmountInUnit({required Ingredient ingredient, required double ownedAmount, required Unit? ownedUnit, required Unit targetUnit}) {
  if (ownedAmount <= 0) return 0;

  if (ownedUnit == null) {
    // "packs" mode: use the product whose unit matches the target unit (not the first product).
    for (Product product in ingredient.products) {
      if (product.unit == targetUnit) return ownedAmount * product.totalQuantityPerPack;
    }
    return 0;
  }

  if (ownedUnit == targetUnit) return ownedAmount;

  // Different units: convert via the ingredient's density (volume) or gramsPerPiece (pieces).
  double? ownedGrams = ingredient.toGrams(Quantity(amount: ownedAmount, unit: ownedUnit));
  if (ownedGrams != null) {
    if (targetUnit == Unit.grams) return ownedGrams;
    double? converted = ingredient.fromGrams(ownedGrams, targetUnit);
    if (converted != null) return converted;
  }

  return 0;
}

/// Draws down a user's owned stock across an ingredient's needs, one need at a time.
///
/// The stock is turned into a single shared grams pool (via [ownedAmountInUnit]) and consumed across
/// every need in the order [consumeRemaining] is called. This makes a single owned stock get
/// subtracted only once, even when the ingredient is needed in more than one unit at the same time.
/// It is the single source of truth for owned-stock subtraction, shared by the on-screen shopping
/// list ([computeRemainingQuantities]) and the multi-trip planner (`multi_trip_planner.dart`), so the
/// two never disagree on how much is still needed.
///
/// Create one consumer per (ingredient, owned stock). A need whose unit cannot be related to grams
/// (no density and no gramsPerPiece), or an owned stock with no grams path at all (for example owned
/// pieces with no gramsPerPiece), falls back to a per-unit subtraction that is likewise consumed only
/// once per unit across calls.
class OwnedStockConsumer {
  OwnedStockConsumer({required Ingredient ingredient, required double ownedAmount, required Unit? ownedUnit})
    : _ingredient = ingredient,
      _ownedAmount = ownedAmount,
      _ownedUnit = ownedUnit,
      _gramsPool = ownedAmount <= 0
          ? 0
          : ownedAmountInUnit(ingredient: ingredient, ownedAmount: ownedAmount, ownedUnit: ownedUnit, targetUnit: Unit.grams);

  final Ingredient _ingredient;
  final double _ownedAmount;
  final Unit? _ownedUnit;

  /// Remaining shared grams pool. Drawn down by each need; reaching 0 just means the stock is used up,
  /// not that there is no grams path (that is fixed at construction, see [_ownedHasGramsPath]).
  double _gramsPool;

  /// Whether the owned stock can be expressed in grams at all. Fixed at construction from the initial
  /// pool. The branch must key off this, not the live pool level: once the pool drains to 0, later
  /// needs must still stay on the grams path (subtracting nothing more), not fall back to a per-unit
  /// conversion that would re-subtract the full owned stock.
  late final bool _ownedHasGramsPath = _gramsPool > 0;

  /// Per-unit remaining owned for needs with no grams path, converted on first use of each unit.
  final Map<Unit, double> _fallbackOwnedByUnit = {};

  /// Returns how much of [need] still has to be bought after applying the owned stock.
  /// The result is raw (not rounded); callers that display whole units round it themselves.
  double consumeRemaining(Quantity need) {
    if (_ownedAmount <= 0) return need.amount;

    // No grams conversion path from the owned stock: subtract per unit directly.
    if (!_ownedHasGramsPath) return _consumeFallback(need);

    double? needGrams = _ingredient.toGrams(need);
    // This need's unit cannot be expressed in grams; only a same-unit owned stock can reduce it.
    if (needGrams == null) return _consumeFallback(need);

    double consumed = min(_gramsPool, needGrams);
    _gramsPool -= consumed;
    double remainingGrams = needGrams - consumed;
    double? remainingInUnit = _ingredient.fromGrams(remainingGrams, need.unit);
    return remainingInUnit ?? need.amount;
  }

  double _consumeFallback(Quantity need) {
    double owned = _fallbackOwnedByUnit.putIfAbsent(
      need.unit,
      () => ownedAmountInUnit(ingredient: _ingredient, ownedAmount: _ownedAmount, ownedUnit: _ownedUnit, targetUnit: need.unit),
    );
    double consumed = min(owned, need.amount);
    _fallbackOwnedByUnit[need.unit] = owned - consumed;
    return need.amount - consumed;
  }
}

/// Subtracts the user's owned stock from an ingredient's required amounts and rounds each to a
/// whole unit, producing the "remaining to buy" the on-screen shopping list shows.
///
/// [requiredQuantities] must already be normalized (the output of `normalizeQuantities`).
///
/// Delegates to [OwnedStockConsumer] so the stock is consumed a single time across all units. This
/// prevents the old bug where a single stock was fully converted into every unit and subtracted from
/// each, over-subtracting when an ingredient is needed in more than one unit at once.
List<Quantity> computeRemainingQuantities({
  required Ingredient ingredient,
  required List<Quantity> requiredQuantities,
  required double ownedAmount,
  required Unit? ownedUnit,
}) {
  OwnedStockConsumer consumer = OwnedStockConsumer(ingredient: ingredient, ownedAmount: ownedAmount, ownedUnit: ownedUnit);
  return requiredQuantities.map((Quantity q) => Quantity(amount: max(0, consumer.consumeRemaining(q)).roundToDouble(), unit: q.unit)).toList();
}
