import "dart:math";

import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/recipes/enums/unit.dart";
import "package:menu_management/recipes/models/quantity.dart";

/// A user's owned stock of one ingredient, as entered on the shopping page.
///
/// Two shapes exist:
/// - Single-form ([OwnedStock.new]): one [amount] plus one selected [unit]. Used for ingredients
///   with no products, where the user types a single number in the desired unit. [unit] is null
///   when the user picked "packs" (product-relative), matching [Unit]? null everywhere.
/// - Per-product ([OwnedStock.perProduct]): one owned count per product of the ingredient
///   ([countsByProductIndex] maps a product's index in [Ingredient.products] to how many of that
///   product the user owns). The global owned amount is summed from each product's count times its
///   pack quantity via the ingredient's conversions. Used for ingredients that have products.
///
/// Both shapes resolve to an amount in a target unit through [amountInUnit], so the on-screen list
/// and the multi-trip planner always subtract the same amount.
class OwnedStock {
  const OwnedStock({required this.amount, required this.unit}) : countsByProductIndex = null;

  const OwnedStock.perProduct({required Map<int, double> this.countsByProductIndex}) : amount = 0, unit = null;

  final double amount;

  /// null means "packs".
  final Unit? unit;

  /// Per-product owned counts (product index in [Ingredient.products] -> owned count).
  /// null for single-form stock.
  final Map<int, double>? countsByProductIndex;

  /// Whether the user owns anything at all. Lets callers skip empty stock.
  bool get hasStock {
    final Map<int, double>? counts = countsByProductIndex;
    if (counts == null) return amount > 0;
    return counts.values.any((double count) => count > 0);
  }

  /// The owned amount expressed in [targetUnit] for [ingredient], using the shared converters.
  ///
  /// Single-form stock delegates to [ownedAmountInUnit]. Per-product stock sums each owned
  /// product's contribution via [productOwnedAmountInUnit].
  double amountInUnit({required Ingredient ingredient, required Unit targetUnit}) {
    final Map<int, double>? counts = countsByProductIndex;
    if (counts == null) {
      return ownedAmountInUnit(ingredient: ingredient, ownedAmount: amount, ownedUnit: unit, targetUnit: targetUnit);
    }
    double total = 0;
    for (MapEntry<int, double> entry in counts.entries) {
      int index = entry.key;
      if (index < 0 || index >= ingredient.products.length) continue;
      total += productOwnedAmountInUnit(ingredient: ingredient, product: ingredient.products[index], count: entry.value, targetUnit: targetUnit);
    }
    return total;
  }
}

/// Converts an owned [count] of a single [product] of [ingredient] into [targetUnit].
///
/// The count is a number of packs of that product. It is first turned into an amount in the
/// product's own unit (`count * totalQuantityPerPack`), then converted to [targetUnit] via the
/// ingredient's conversions (grams bridge through `density` for volume, `gramsPerPiece` for
/// pieces). Returns 0 when the count is non-positive or no conversion path exists.
double productOwnedAmountInUnit({required Ingredient ingredient, required Product product, required double count, required Unit targetUnit}) {
  if (count <= 0) return 0;
  double amountInProductUnit = count * product.totalQuantityPerPack;
  if (product.unit == targetUnit) return amountInProductUnit;

  double? grams = ingredient.toGrams(Quantity(amount: amountInProductUnit, unit: product.unit));
  if (grams == null) return 0;
  if (targetUnit == Unit.grams) return grams;
  return ingredient.fromGrams(grams, targetUnit) ?? 0;
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
/// The stock is turned into a single shared grams pool (via [OwnedStock.amountInUnit]) and consumed
/// across every need in the order [consumeRemaining] is called. This makes a single owned stock get
/// subtracted only once, even when the ingredient is needed in more than one unit at the same time.
/// It is the single source of truth for owned-stock subtraction, shared by the on-screen shopping
/// list ([computeRemainingQuantities]) and the multi-trip planner (`multi_trip_planner.dart`), so the
/// two never disagree on how much is still needed.
///
/// The consumer takes an [OwnedStock], so both stock shapes flow through the same single pool:
/// single-form (one amount + unit) and per-product (one count per product, summed into a global
/// grams amount, see issue #24). Whichever shape the user entered, [OwnedStock.amountInUnit] gives
/// its grams total for the pool and its per-unit total for the fallback below.
///
/// Create one consumer per (ingredient, owned stock). A need whose unit cannot be related to grams
/// (no density and no gramsPerPiece), or an owned stock with no grams path at all (for example owned
/// pieces with no gramsPerPiece), falls back to a per-unit subtraction that is likewise consumed only
/// once per unit across calls.
class OwnedStockConsumer {
  OwnedStockConsumer({required Ingredient ingredient, required OwnedStock owned})
    : _ingredient = ingredient,
      _owned = owned,
      _gramsPool = owned.hasStock ? owned.amountInUnit(ingredient: ingredient, targetUnit: Unit.grams) : 0;

  final Ingredient _ingredient;
  final OwnedStock _owned;

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
    if (!_owned.hasStock) return need.amount;

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
    double owned = _fallbackOwnedByUnit.putIfAbsent(need.unit, () => _owned.amountInUnit(ingredient: _ingredient, targetUnit: need.unit));
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
/// each, over-subtracting when an ingredient is needed in more than one unit at once. [owned] may be
/// either stock shape (single-form or per-product); both resolve through the same single pool.
List<Quantity> computeRemainingQuantities({required Ingredient ingredient, required List<Quantity> requiredQuantities, required OwnedStock owned}) {
  OwnedStockConsumer consumer = OwnedStockConsumer(ingredient: ingredient, owned: owned);
  return requiredQuantities.map((Quantity q) => Quantity(amount: roundNeededAmount(consumer.consumeRemaining(q)), unit: q.unit)).toList();
}

/// A need at or below this many units is arithmetic noise, not food to buy.
///
/// The subtraction of the owned stock runs on doubles and crosses unit conversions, so a fully
/// covered need rarely lands on an exact 0. It leaves a residue: 4e-17 for `0.1 + 0.2 - 0.3`, or
/// 0.01 grams for 100 grams minus 3 pieces of 33.33 grams. Without this margin every such residue
/// would become a whole unit to buy. The margin stays far below the smallest real need, which is
/// a fraction of a teaspoon.
const double _negligibleNeed = 0.05;

/// Rounds an amount that the user must still buy to a whole unit.
///
/// A real need never becomes zero. The user cannot buy 0.4 teaspoons, but a pinch of salt is
/// still a need, so the smallest need is one unit. An amount at or below [_negligibleNeed] is
/// not a real need, so it becomes zero. The page and the copied list both round here, so they
/// always show the same number.
double roundNeededAmount(double amount) {
  if (amount <= _negligibleNeed) return 0;
  return max(1, amount.round()).toDouble();
}
