import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/recipes/enums/unit.dart";
import "package:menu_management/recipes/models/quantity.dart";

/// Milliliters per unit for volume conversions (universal, no density needed).
const Map<Unit, double> _mlPerUnit = {
  Unit.centiliters: 10,
  Unit.tablespoons: 15,
  Unit.teaspoons: 5,
};

bool _isVolumeUnit(Unit unit) => _mlPerUnit.containsKey(unit);

/// Normalizes a list of quantities for a single ingredient by merging
/// compatible units. Volume units (tbsp, tsp, cl) are merged universally.
/// If density is known, volume and weight are merged into grams.
///
/// Pieces are merged with grams when gramsPerPiece is known and no pieces-based product exists.
List<Quantity> normalizeQuantities({required Ingredient ingredient, required List<Quantity> rawQuantities}) {
  if (rawQuantities.isEmpty) return const [];
  if (rawQuantities.length == 1 && rawQuantities.first.unit == Unit.grams) {
    return rawQuantities;
  }
  bool canConvertPieces = ingredient.gramsPerPiece != null && ingredient.gramsPerPiece! > 0;
  bool hasProductInPieces = ingredient.products.any((Product p) => p.unit == Unit.pieces);
  bool shouldConvertPieces = canConvertPieces && !hasProductInPieces;
  if (rawQuantities.length == 1 && rawQuantities.first.unit == Unit.pieces && !shouldConvertPieces) {
    return rawQuantities;
  }

  // Accumulate totals across all units
  double totalGrams = 0;
  double totalMl = 0;
  double totalPieces = 0;

  for (Quantity q in rawQuantities) {
    switch (q.unit) {
      case Unit.grams:
        totalGrams += q.amount;
      case Unit.centiliters:
      case Unit.tablespoons:
      case Unit.teaspoons:
        totalMl += q.amount * _mlPerUnit[q.unit]!;
      case Unit.pieces:
        totalPieces += q.amount;
    }
  }

  // Convert pieces to grams when gramsPerPiece is known and no pieces-based product exists
  if (shouldConvertPieces && totalPieces > 0) {
    totalGrams += totalPieces * ingredient.gramsPerPiece!;
    totalPieces = 0;
  }

  bool hasGrams = totalGrams > 0;
  bool hasVolume = totalMl > 0;

  // If only unconverted pieces remain, return them
  if (!hasGrams && !hasVolume && totalPieces > 0) {
    return [Quantity(amount: totalPieces, unit: Unit.pieces)];
  }

  // Determine the target unit
  Unit targetUnit = _determineTargetUnit(ingredient: ingredient, hasGrams: hasGrams, hasVolume: hasVolume);

  List<Quantity> result = [];
  if (totalPieces > 0) result.add(Quantity(amount: totalPieces, unit: Unit.pieces));

  if (targetUnit == Unit.grams) {
    if (hasVolume && ingredient.density != null) {
      totalGrams += totalMl * ingredient.density!;
      totalMl = 0;
    }
    if (totalGrams > 0) result.add(Quantity(amount: totalGrams, unit: Unit.grams));
    if (totalMl > 0) result.add(Quantity(amount: totalMl / 10, unit: Unit.centiliters)); // fallback: couldn't convert
    return result;
  }

  if (targetUnit == Unit.centiliters) {
    if (hasGrams && ingredient.density != null && ingredient.density! > 0) {
      totalMl += totalGrams / ingredient.density!;
      totalGrams = 0;
    }
    if (totalMl > 0) result.add(Quantity(amount: totalMl / 10, unit: Unit.centiliters));
    if (totalGrams > 0) result.add(Quantity(amount: totalGrams, unit: Unit.grams)); // fallback: couldn't convert
    return result;
  }

  return rawQuantities;
}

/// Determines what unit to normalize to, considering product units and density availability.
Unit _determineTargetUnit({required Ingredient ingredient, required bool hasGrams, required bool hasVolume}) {
  // If a product exists, prefer matching the product's unit
  if (ingredient.products.isNotEmpty) {
    Unit productUnit = ingredient.products.first.unit;
    if (productUnit == Unit.grams) {
      bool canConvertVolume = !hasVolume || ingredient.density != null;
      if (canConvertVolume) return Unit.grams;
    }
    if (_isVolumeUnit(productUnit)) return Unit.centiliters;
    // Product is in pieces or unknown; fall through to default logic
  }

  // Both weight and volume present
  if (hasGrams && hasVolume) {
    // If density is known, merge into grams (weight is the more useful shopping unit)
    if (ingredient.density != null) return Unit.grams;
    // No density: keep both families, volume merges to cl, grams stays
    return Unit.grams; // grams won't merge volume without density; the function handles this
  }

  // Only grams
  if (hasGrams) return Unit.grams;

  // Only volume (tbsp, tsp, cl) - if density known and no products, convert to grams
  if (hasVolume) {
    if (ingredient.density != null && ingredient.products.isEmpty) return Unit.grams;
    return Unit.centiliters;
  }

  return Unit.grams; // default
}

/// Normalizes an entire ingredients map by merging compatible units per ingredient.
Map<String, List<Quantity>> normalizeAllIngredients({
  required Map<String, List<Quantity>> rawQuantities,
  required List<Ingredient> ingredients,
}) {
  return rawQuantities.map((String ingredientId, List<Quantity> quantities) {
    Ingredient? ingredient = ingredients.firstWhereOrNull((i) => i.id == ingredientId);
    if (ingredient == null) return MapEntry(ingredientId, quantities);
    return MapEntry(ingredientId, normalizeQuantities(ingredient: ingredient, rawQuantities: quantities));
  });
}
