import "package:freezed_annotation/freezed_annotation.dart";
import "package:menu_management/recipes/models/quantity.dart";

part "ingredient_source.freezed.dart";
part "ingredient_source.g.dart";

/// Tracks how much of an ingredient a single recipe contributes to the shopping list.
@freezed
abstract class IngredientSource with _$IngredientSource {
  const factory IngredientSource({
    required String recipeName,
    @Default([]) List<Quantity> perServingQuantities,
    required int servings,
  }) = _IngredientSource;

  factory IngredientSource.fromJson(Map<String, Object?> json) => _$IngredientSourceFromJson(json);
}
