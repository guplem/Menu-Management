import "package:freezed_annotation/freezed_annotation.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/recipes/enums/unit.dart";
import "package:menu_management/recipes/models/quantity.dart";

part "ingredient.freezed.dart";
part "ingredient.g.dart";

@freezed
abstract class Ingredient with _$Ingredient {
  const factory Ingredient({
    required String id,
    required String name,
    @Default([]) List<Product> products,
    @JsonKey(includeIfNull: false) double? density,
    @JsonKey(includeIfNull: false) double? gramsPerPiece,
  }) = _Ingredient;

  factory Ingredient.fromJson(Map<String, Object?> json) => _$IngredientFromJson(json);

  const Ingredient._();

  /// Converts a quantity to grams using density (for volume) or gramsPerPiece (for pieces).
  /// Returns null when conversion is not possible.
  double? toGrams(Quantity quantity) {
    return switch (quantity.unit) {
      Unit.grams => quantity.amount,
      Unit.centiliters => density != null ? quantity.amount * 10 * density! : null,
      Unit.tablespoons => density != null ? quantity.amount * 15 * density! : null,
      Unit.teaspoons => density != null ? quantity.amount * 5 * density! : null,
      Unit.pieces => gramsPerPiece != null && gramsPerPiece! > 0 ? quantity.amount * gramsPerPiece! : null,
    };
  }

  /// Converts a gram amount back to the given unit using density (for volume) or gramsPerPiece (for pieces).
  /// Returns null when conversion is not possible.
  double? fromGrams(double grams, Unit targetUnit) {
    return switch (targetUnit) {
      Unit.grams => grams,
      Unit.centiliters => density != null ? grams / (10 * density!) : null,
      Unit.tablespoons => density != null ? grams / (15 * density!) : null,
      Unit.teaspoons => density != null ? grams / (5 * density!) : null,
      Unit.pieces => gramsPerPiece != null && gramsPerPiece! > 0 ? grams / gramsPerPiece! : null,
    };
  }
}
