import 'package:menu_management/recipes/enums/recipe_type.dart';
import 'package:menu_management/recipes/models/instruction.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';
import 'package:menu_management/recipes/recipes_provider.dart';

part 'recipe.freezed.dart';
part 'recipe.g.dart';

@freezed
class Recipe with _$Recipe {
  const factory Recipe({
    required String id,
    required String name,
    @Default([]) List<Instruction> instructions,
    @Default(false) bool carbs,
    @Default(false) bool proteins,
    @Default(false) bool vegetables,
    RecipeType? type,
  }) = _Recipe;

  factory Recipe.fromJson(Map<String, Object?> json) => _$RecipeFromJson(json);

  // Empty constant constructor. Must not have any parameter. Needed to be able to add non-static methods and getters
  const Recipe._();

  void saveToProvider() {
    RecipesProvider.addOrUpdate(newRecipe: this);
  }

  int get workingTimeMinutes => instructions.fold(0, (previousValue, element) => previousValue + element.workingTimeMinutes);
  int get cookingTimeMinutes => instructions.fold(0, (previousValue, element) => previousValue + element.cookingTimeMinutes);
  int get totalTimeMinutes => instructions.fold(0, (previousValue, element) => previousValue + element.totalTimeMinutes);

}
