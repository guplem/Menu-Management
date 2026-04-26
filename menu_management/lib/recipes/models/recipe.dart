import "package:freezed_annotation/freezed_annotation.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/menu/enums/meal_type.dart";
import "package:menu_management/menu/models/menu_configuration.dart";
import "package:menu_management/recipes/enums/recipe_type.dart";
import "package:menu_management/recipes/models/instruction.dart";

part "recipe.freezed.dart";
part "recipe.g.dart";

/// A recipe is a set of instructions
@freezed
abstract class Recipe with _$Recipe {
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
    @Default(6) int maxStorageDays,
    @Default(true) bool includeInMenuGeneration,
  }) = _Recipe;

  factory Recipe.fromJson(Map<String, Object?> json) => _$RecipeFromJson(_migrateCanBeStored(json));

  /// Backward compatibility: migrate old canBeStored boolean to maxStorageDays
  static Map<String, Object?> _migrateCanBeStored(Map<String, Object?> json) {
    if (json.containsKey("canBeStored") && !json.containsKey("maxStorageDays")) {
      json = {...json, "maxStorageDays": (json["canBeStored"] == true) ? 6 : 0};
      json.remove("canBeStored");
    }
    return json;
  }

  // Empty constant constructor. Must not have any parameter. Needed to be able to add non-static methods and getters
  const Recipe._();

  bool get canBeStored => maxStorageDays > 0;

  int get workingTimeMinutes => instructions.fold(0, (previousValue, element) => previousValue + element.workingTimeMinutes);
  int get cookingTimeMinutes => instructions.fold(0, (previousValue, element) => previousValue + element.cookingTimeMinutes);
  int get totalTimeMinutes => instructions.fold(0, (previousValue, element) => previousValue + element.totalTimeMinutes);

  String toShortString() {
    return "$name (${totalTimeMinutes}min)";
  }

  bool fitsConfiguration(MenuConfiguration configuration, {required bool needToBeStored, required bool strictMealTime}) {
    if (needToBeStored && maxStorageDays <= 0) {
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
