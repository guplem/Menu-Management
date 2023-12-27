import 'package:freezed_annotation/freezed_annotation.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';
import 'package:menu_management/menu/models/cooking.dart';
import 'package:menu_management/menu/models/meal.dart';
import 'package:menu_management/menu/models/meal_time.dart';

part 'menu.freezed.dart';
part 'menu.g.dart';

@freezed
class Menu with _$Menu {
  const factory Menu({
    @Default([]) List<Meal> meals,
  }) = _Menu;

  factory Menu.fromJson(Map<String, Object?> json) => _$MenuFromJson(json);

  // Empty constant constructor. Must not have any parameter. Needed to be able to add non-static methods and getters
  const Menu._();

  Menu copyWithUpdatedMeal({required MealTime mealTime, required List<Cooking> recipes}) {
    final newMeals = meals.map((meal) {
      if (meal.mealTime.isSameTime(mealTime)) {
        return meal.copyWithUpdatedRecipes(recipes);
      }
      return meal;
    }).toList();
    return copyWith(meals: newMeals);
  }

}
