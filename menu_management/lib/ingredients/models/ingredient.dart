import "package:freezed_annotation/freezed_annotation.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/recipes/enums/unit.dart";
import "package:menu_management/recipes/models/quantity.dart";

part "ingredient.freezed.dart";
part "ingredient.g.dart";

@freezed
abstract class Ingredient with _$Ingredient {
  const factory Ingredient({required String id, required String name, @Default([]) List<Product> products, @JsonKey(includeIfNull: false) double? density}) = _Ingredient;

  factory Ingredient.fromJson(Map<String, Object?> json) => _$IngredientFromJson(json);

  const Ingredient._();

  /// Converts a quantity to grams using this ingredient's density.
  /// Returns null when conversion is not possible (no density, or unit is pieces).
  double? toGrams(Quantity quantity) {
    if (density == null) return null;
    return switch (quantity.unit) {
      Unit.grams => quantity.amount,
      Unit.centiliters => quantity.amount * 10 * density!,
      Unit.tablespoons => quantity.amount * 15 * density!,
      Unit.teaspoons => quantity.amount * 5 * density!,
      Unit.pieces => null,
    };
  }

  /// Converts a gram amount back to the given unit using this ingredient's density.
  /// Returns null when conversion is not possible (no density, or target is pieces).
  double? fromGrams(double grams, Unit targetUnit) {
    if (density == null) return null;
    return switch (targetUnit) {
      Unit.grams => grams,
      Unit.centiliters => grams / (10 * density!),
      Unit.tablespoons => grams / (15 * density!),
      Unit.teaspoons => grams / (5 * density!),
      Unit.pieces => null,
    };
  }
}
