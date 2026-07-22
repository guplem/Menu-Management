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
