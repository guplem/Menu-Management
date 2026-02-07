import "package:menu_management/recipes/models/recipe.dart";
import "package:freezed_annotation/freezed_annotation.dart";
// ignore: unused_import
import "package:flutter/foundation.dart";

part "cooking.freezed.dart";
part "cooking.g.dart";

@freezed
/// A link between a recipe and the amount of meals to cook
class Cooking with _$Cooking {
  const factory Cooking({
    required Recipe recipe,

    /// The amount of meals to cook. [yield] =~ meals. 0 means it should already be cooked. Total servings = people * [yield]
    required int yield,
  }) = _Cooking;

  factory Cooking.fromJson(Map<String, Object?> json) => _$CookingFromJson(json);
}
