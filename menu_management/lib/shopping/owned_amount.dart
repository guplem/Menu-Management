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
