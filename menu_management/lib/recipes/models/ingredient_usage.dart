import "package:freezed_annotation/freezed_annotation.dart";
import "package:menu_management/recipes/models/quantity.dart";

part "ingredient_usage.freezed.dart";
part "ingredient_usage.g.dart";

@freezed
abstract class IngredientUsage with _$IngredientUsage {
  const factory IngredientUsage({required String ingredient, required Quantity quantity}) = _IngredientUsage;

  factory IngredientUsage.fromJson(Map<String, Object?> json) => _$IngredientUsageFromJson(json);
}
