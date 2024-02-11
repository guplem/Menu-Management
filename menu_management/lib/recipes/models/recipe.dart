import 'package:menu_management/flutter_essentials/library.dart';
import 'package:menu_management/menu/enums/meal_type.dart';
import 'package:menu_management/menu/models/menu_configuration.dart';
import 'package:menu_management/recipes/enums/recipe_type.dart';
import 'package:menu_management/recipes/models/instruction.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';
import 'package:menu_management/recipes/recipes_provider.dart';

part 'recipe.freezed.dart';
part 'recipe.g.dart';

/// A recipe is a set of instructions
@freezed
class Recipe with _$Recipe {
  const factory Recipe({
    required String id,
    required String name,
    @Default([]) List<Instruction> instructions,
    @Default(true) bool carbs,
    @Default(true) bool proteins,
    @Default(true) bool vegetables,
    @Default(RecipeType.meal) RecipeType type,
    @Default(true) bool lunch,
    @Default(true) bool dinner,

    /// The number of days the recipe can be stored in the fridge (coocked)
    @Default(true) bool canBeStored,
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

  String toShortString() {
    return "$name (${totalTimeMinutes}min)";
  }

  bool fitsConfiguration(MenuConfiguration configuration, {required bool needToBeStored, required bool strictMealTime}) {
    if (needToBeStored && !canBeStored) {
      return false;
    }
    if (!configuration.canBeCookedAtTheSpot && totalTimeMinutes > 0) {
      return false;
    }
    if (configuration.isMeal && !lunch && !dinner) {
      return false;
    }
    if (strictMealTime) {
      if (configuration.mealTime.mealType == MealType.breakfast && (lunch || dinner)) {
        Debug.logError("This should never happen, since breakfast is not a meal and this is checked before");
        return false;
      }
      if (configuration.mealTime.mealType == MealType.lunch && (dinner)) {
        return false;
      }
      if (configuration.mealTime.mealType == MealType.dinner && (lunch)) {
        return false;
      }
    }
    return true;
  }
}
