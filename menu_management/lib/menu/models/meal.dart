import "package:freezed_annotation/freezed_annotation.dart";
import "package:menu_management/menu/models/cooking.dart";
import "package:menu_management/menu/models/meal_time.dart";
import "package:menu_management/menu/models/sub_meal.dart";

part "meal.freezed.dart";
part "meal.g.dart";

/// A meal is a time slot in a menu that can hold multiple sub-meals (one per person or group).
@freezed
abstract class Meal with _$Meal {
  const factory Meal({required MealTime mealTime, @Default([]) List<SubMeal> subMeals}) = _Meal;

  factory Meal.fromJson(Map<String, Object?> json) => _$MealFromJson(_migrateToSubMeals(Map<String, dynamic>.from(json)));

  // Empty constant constructor. Must not have any parameter. Needed to be able to add non-static methods and getters
  const Meal._();

  /// Migrates old single-cooking format to new sub-meals format.
  /// Old: {"mealTime": ..., "cooking": {...}, "people": 2}
  /// New: {"mealTime": ..., "subMeals": [{"cooking": {...}, "people": 2}]}
  static Map<String, dynamic> _migrateToSubMeals(Map<String, dynamic> json) {
    if (!json.containsKey("subMeals")) {
      Map<String, dynamic> subMeal = {"people": json.remove("people") ?? 2};
      if (json.containsKey("cooking")) {
        subMeal["cooking"] = json.remove("cooking");
      }
      json["subMeals"] = [subMeal];
    }
    return json;
  }

  /// Updates the cooking of a specific sub-meal at [subMealIndex].
  Meal copyWithSubMealCooking(int subMealIndex, Cooking? cooking) {
    List<SubMeal> newSubMeals = [...subMeals];
    newSubMeals[subMealIndex] = newSubMeals[subMealIndex].copyWith(cooking: cooking);
    return copyWith(subMeals: newSubMeals);
  }

  /// Updates the people count of a specific sub-meal at [subMealIndex].
  Meal copyWithSubMealPeople(int subMealIndex, int people) {
    List<SubMeal> newSubMeals = [...subMeals];
    newSubMeals[subMealIndex] = newSubMeals[subMealIndex].copyWith(people: people);
    return copyWith(subMeals: newSubMeals);
  }

  bool goesBefore(Meal meal) {
    return mealTime.goesBefore(meal.mealTime);
  }

  bool goesAfter(Meal meal) {
    return mealTime.goesAfter(meal.mealTime);
  }
}
