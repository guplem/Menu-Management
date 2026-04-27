import "package:freezed_annotation/freezed_annotation.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/menu/models/meal.dart";
import "package:menu_management/menu/models/meal_time.dart";
import "package:menu_management/menu/models/menu.dart";
import "package:menu_management/menu/models/sub_meal.dart";
import "package:menu_management/recipes/models/quantity.dart";
import "package:menu_management/recipes/models/recipe.dart";
import "package:menu_management/shopping/ingredient_source.dart";

part "multi_week_menu.freezed.dart";
part "multi_week_menu.g.dart";

@freezed
abstract class MultiWeekMenu with _$MultiWeekMenu {
  const factory MultiWeekMenu({@Default([]) List<Menu> weeks}) = _MultiWeekMenu;

  factory MultiWeekMenu.fromJson(Map<String, Object?> json) => _$MultiWeekMenuFromJson(json);

  const MultiWeekMenu._();

  /// Validates that the menu has at least one week.
  /// Use this factory instead of the default constructor when creating from user actions.
  factory MultiWeekMenu.validated({required List<Menu> weeks}) {
    if (weeks.isEmpty) throw ArgumentError("MultiWeekMenu must have at least one week");
    return MultiWeekMenu(weeks: weeks);
  }

  int get weekCount => weeks.length;

  MultiWeekMenu addWeek(Menu week) {
    return copyWith(weeks: [...weeks, week]);
  }

  MultiWeekMenu removeLastWeek() {
    if (weeks.length <= 1) return this;
    return copyWith(weeks: weeks.sublist(0, weeks.length - 1));
  }

  MultiWeekMenu updateWeekAt(int index, Menu updatedWeek) {
    final List<Menu> newWeeks = [...weeks];
    newWeeks[index] = updatedWeek;
    return copyWith(weeks: newWeeks);
  }

  /// Recalculates yields across all weeks, allowing cross-week leftovers
  /// when a recipe cooked late in week N is within maxStorageDays of meals
  /// in week N+1.
  MultiWeekMenu copyWithUpdatedYields({required List<Recipe> recipes}) {
    List<Menu> updatedWeeks = [];
    Map<String, int> carryOverCookDays = {};

    for (int weekIndex = 0; weekIndex < weeks.length; weekIndex++) {
      Menu week = Menu.recalculateYields(
        meals: [...weeks[weekIndex].meals],
        recipes: recipes,
        weekIndex: weekIndex,
        externalCookEvents: carryOverCookDays,
      );
      updatedWeeks.add(week);

      // Build carry-over: for each recipe cooked this week, record the latest cook day
      for (Meal meal in week.meals) {
        for (SubMeal subMeal in meal.subMeals) {
          if (subMeal.cooking == null || subMeal.cooking!.yield <= 0) continue;
          String recipeId = subMeal.cooking!.recipeId;
          int absoluteDay = weekIndex * 7 + meal.mealTime.weekDay.value;
          // Keep the latest cook day per recipe for carry-over
          if (!carryOverCookDays.containsKey(recipeId) || absoluteDay > carryOverCookDays[recipeId]!) {
            carryOverCookDays[recipeId] = absoluteDay;
          }
        }
      }
    }

    return copyWith(weeks: updatedWeeks);
  }

  /// Total servings to cook for a recipe across all weeks (global sum).
  int totalServingsForRecipe(String recipeId) {
    return weeks.fold(0, (int sum, Menu week) => sum + week.totalServingsForRecipe(recipeId));
  }

  /// Returns the total people served by a specific cook event (yield > 0 sub-meal).
  /// The cook event at [cookWeekIndex]/[cookMealTime]/[subMealIndex] feeds itself plus all
  /// subsequent leftover occurrences (yield == 0) of the same recipe within
  /// the recipe's maxStorageDays window.
  int servingsForCookEvent({
    required int cookWeekIndex,
    required MealTime cookMealTime,
    required int subMealIndex,
    required List<Recipe> recipes,
  }) {
    // Find the cook meal
    Meal? cookMeal = weeks[cookWeekIndex].meals.firstWhereOrNull((Meal m) => m.mealTime.isSameTime(cookMealTime));
    if (cookMeal == null || subMealIndex >= cookMeal.subMeals.length) return 0;

    SubMeal cookSubMeal = cookMeal.subMeals[subMealIndex];
    if (cookSubMeal.cooking == null || cookSubMeal.cooking!.yield <= 0) return 0;

    String recipeId = cookSubMeal.cooking!.recipeId;
    Recipe? recipe = recipes.firstWhereOrNull((Recipe r) => r.id == recipeId);
    int maxDays = recipe?.maxStorageDays ?? 0;
    int cookAbsoluteDay = cookWeekIndex * 7 + cookMealTime.weekDay.value;

    int total = 0;
    for (int wi = cookWeekIndex; wi < weeks.length; wi++) {
      for (Meal meal in weeks[wi].meals) {
        for (SubMeal subMeal in meal.subMeals) {
          if (subMeal.cooking?.recipeId != recipeId) continue;
          int mealAbsoluteDay = wi * 7 + meal.mealTime.weekDay.value;
          if (mealAbsoluteDay < cookAbsoluteDay) continue;
          if (mealAbsoluteDay - cookAbsoluteDay > maxDays) continue;
          total += subMeal.people;
        }
      }
    }
    return total;
  }

  Map<String, List<Quantity>> allIngredients({required List<Recipe> recipes}) {
    Map<String, List<Quantity>> combined = {};

    for (Menu week in weeks) {
      Map<String, List<Quantity>> weekIngredients = week.allIngredients(recipes: recipes);
      for (MapEntry<String, List<Quantity>> entry in weekIngredients.entries) {
        if (combined[entry.key] == null) {
          combined[entry.key] = [];
        }
        for (Quantity quantity in entry.value) {
          Quantity? existing = combined[entry.key]!.firstWhereOrNull((q) => q.unit == quantity.unit);
          if (existing != null) {
            combined[entry.key]!.remove(existing);
            combined[entry.key]!.add(existing.copyWith(amount: existing.amount + quantity.amount));
          } else {
            combined[entry.key]!.add(quantity);
          }
        }
      }
    }

    return combined;
  }

  /// Returns per-recipe breakdown of ingredient usage across all weeks.
  /// Entries with the same recipe name are merged by summing servings.
  Map<String, List<IngredientSource>> ingredientSources({required List<Recipe> recipes}) {
    Map<String, List<IngredientSource>> combined = {};

    for (Menu week in weeks) {
      Map<String, List<IngredientSource>> weekSources = week.ingredientSources(recipes: recipes);
      for (MapEntry<String, List<IngredientSource>> entry in weekSources.entries) {
        combined[entry.key] ??= [];
        for (IngredientSource source in entry.value) {
          int existingIndex = combined[entry.key]!.indexWhere((s) => s.recipeName == source.recipeName);
          if (existingIndex >= 0) {
            IngredientSource existing = combined[entry.key]![existingIndex];
            combined[entry.key]![existingIndex] = existing.copyWith(servings: existing.servings + source.servings);
          } else {
            combined[entry.key]!.add(source);
          }
        }
      }
    }

    return combined;
  }

  String toStringBeautified({required List<Recipe> recipes}) {
    String result = "";
    for (int i = 0; i < weeks.length; i++) {
      result += "Week ${i + 1}\n";
      result += "${weeks[i].toStringBeautified(recipes: recipes)}\n\n";
    }
    return result.trim();
  }
}
