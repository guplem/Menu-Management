import 'package:freezed_annotation/freezed_annotation.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';
import 'package:menu_management/flutter_essentials/library.dart';
import 'package:menu_management/menu/enums/week_day.dart';
import 'package:menu_management/menu/models/cooking.dart';
import 'package:menu_management/menu/models/meal.dart';
import 'package:menu_management/menu/models/meal_time.dart';
import 'package:menu_management/recipes/models/recipe.dart';

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

  Menu copyWithUpdatedRecipe({required MealTime mealTime, required Recipe recipe}) {
    // Prepare relevant data
    Meal mealToUpdate = meals.firstWhere((meal) => meal.mealTime.isSameTime(mealTime));

    // No need to update the meal if it already has the recipe we want to update it to
    if (mealToUpdate.cooking?.recipe.id == recipe.id) return this;

    mealToUpdate = mealToUpdate.copyWithUpdatedCooking(Cooking(recipe: recipe, yield: 1));

    // Generate the updated meals list
    List<Meal> newMeals = [...meals];
    newMeals[newMeals.indexWhere((meal) => meal.mealTime.isSameTime(mealToUpdate.mealTime))] = mealToUpdate;

    return copyWith(meals: newMeals).copyWithUpdatedYields();
  }

  List<Meal> mealsOfDay(WeekDay weekDay) {
    List<Meal> dayMeals = meals.where((meal) => meal.mealTime.weekDay == weekDay).toList();
    dayMeals.sort((a, b) => a.mealTime.goesBefore(b.mealTime) ? -1 : 1);
    return dayMeals;
  }

  Menu copyWithUpdatedYields() {
    List<Meal> oldMeals = [...this.meals];


    bool isFirstTimeOfRecipe(MealTime time, Recipe recipe) {
      List<Meal> sortedMealTimes = oldMeals.sorted((a, b) => a.goesBefore(b) ? -1 : 1).toList();
      for (int i = 0; i < sortedMealTimes.length; i++) {
        MealTime t = sortedMealTimes[i].mealTime;
        Recipe? r = sortedMealTimes[i].cooking?.recipe;
        if (r == recipe && t.goesBefore(time)) {
          return false;
        } else if (r == recipe && (t == time || time.goesBefore(t))) {
          return true;
        }
      }
      Debug.logError("This should not happen");
      return false;
    }


    List<Meal> meals = oldMeals.map((meal) {
      Recipe? recipe = meal.cooking?.recipe;

      int yield = 1;
      if (recipe != null && recipe.canBeStored) {
        if (isFirstTimeOfRecipe(meal.mealTime, recipe)) {
          yield = oldMeals.fold(0, (previousValue, Meal element) => previousValue + (element.cooking?.recipe == recipe ? 1 : 0));
        } else {
          yield = 0;
        }
      }

      return Meal(
        mealTime: meal.mealTime,
        cooking: recipe == null
            ? null
            : Cooking(
          recipe: recipe,
          yield: yield,
        ),
      );
    }).toList();


    return copyWith(meals: meals);
  }
}
