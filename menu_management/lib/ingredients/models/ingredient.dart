import "package:freezed_annotation/freezed_annotation.dart";
import "package:menu_management/ingredients/models/product.dart";

part "ingredient.freezed.dart";
part "ingredient.g.dart";

@freezed
abstract class Ingredient with _$Ingredient {
  const factory Ingredient({required String id, required String name, @Default([]) List<Product> products}) = _Ingredient;

  factory Ingredient.fromJson(Map<String, Object?> json) => _$IngredientFromJson(json);
}
