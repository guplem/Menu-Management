import "package:freezed_annotation/freezed_annotation.dart";

part "cooking.freezed.dart";
part "cooking.g.dart";

@freezed
/// A link between a recipe (by ID) and the amount of meals to cook
abstract class Cooking with _$Cooking {
  const factory Cooking({
    required String recipeId,

    /// The amount of meals to cook. [yield] =~ meals. 0 means it should already be cooked. Total servings = people * [yield]
    required int yield,
  }) = _Cooking;

  factory Cooking.fromJson(Map<String, Object?> json) => _$CookingFromJson(json);
}
