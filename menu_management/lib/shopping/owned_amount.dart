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

/// Subtracts the user's owned stock from an ingredient's required amounts and rounds each to a
/// whole unit, producing the "remaining to buy" the on-screen shopping list shows.
///
/// [requiredQuantities] must already be normalized (the output of `normalizeQuantities`).
///
/// The owned stock is consumed a single time. It is turned into one grams pool (via the shared
/// [ownedAmountInUnit]) and drawn down across the required units in order. This prevents the
/// old bug where a single stock was fully converted into every unit and subtracted from each,
/// over-subtracting when an ingredient is needed in more than one unit at once. Units that cannot
/// be related to grams (no density and no gramsPerPiece) fall back to a same-unit subtraction.
List<Quantity> computeRemainingQuantities({
  required Ingredient ingredient,
  required List<Quantity> requiredQuantities,
  required double ownedAmount,
  required Unit? ownedUnit,
}) {
  Quantity toRemaining(Quantity required, double owned) => Quantity(amount: max(0, required.amount - owned).roundToDouble(), unit: required.unit);

  if (ownedAmount <= 0) {
    return requiredQuantities.map((Quantity q) => toRemaining(q, 0)).toList();
  }

  double ownedGramsPool = ownedAmountInUnit(ingredient: ingredient, ownedAmount: ownedAmount, ownedUnit: ownedUnit, targetUnit: Unit.grams);

  // No grams conversion path (e.g. pieces with no gramsPerPiece): subtract per unit directly.
  if (ownedGramsPool <= 0) {
    return requiredQuantities.map((Quantity q) {
      double owned = ownedAmountInUnit(ingredient: ingredient, ownedAmount: ownedAmount, ownedUnit: ownedUnit, targetUnit: q.unit);
      return toRemaining(q, owned);
    }).toList();
  }

  List<Quantity> result = [];
  for (Quantity q in requiredQuantities) {
    double? needGrams = ingredient.toGrams(q);
    if (needGrams == null) {
      // This unit cannot be expressed in grams; only a same-unit owned stock can reduce it.
      double owned = ownedAmountInUnit(ingredient: ingredient, ownedAmount: ownedAmount, ownedUnit: ownedUnit, targetUnit: q.unit);
      result.add(toRemaining(q, owned));
      continue;
    }
    double consumed = min(ownedGramsPool, needGrams);
    ownedGramsPool -= consumed;
    double remainingGrams = needGrams - consumed;
    double? remainingInUnit = ingredient.fromGrams(remainingGrams, q.unit);
    result.add(Quantity(amount: max(0, remainingInUnit ?? q.amount).roundToDouble(), unit: q.unit));
  }
  return result;
}
