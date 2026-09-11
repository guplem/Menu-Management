import "package:freezed_annotation/freezed_annotation.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/menu/enums/meal_type.dart";
import "package:menu_management/menu/enums/week_day.dart";
import "package:menu_management/menu/models/cooking.dart";
import "package:menu_management/menu/models/meal.dart";
import "package:menu_management/menu/models/meal_time.dart";
import "package:menu_management/menu/models/sub_meal.dart";
import "package:menu_management/recipes/models/ingredient_usage.dart";
import "package:menu_management/recipes/models/instruction.dart";
import "package:menu_management/recipes/models/quantity.dart";
import "package:menu_management/recipes/models/recipe.dart";
import "package:menu_management/shopping/ingredient_source.dart";

part "menu.freezed.dart";
part "menu.g.dart";

@freezed
abstract class Menu with _$Menu {
  const factory Menu({@Default([]) List<Meal> meals}) = _Menu;

  factory Menu.fromJson(Map<String, Object?> json) => _$MenuFromJson(json);

  // Empty constant constructor. Must not have any parameter. Needed to be able to add non-static methods and getters
  const Menu._();

  Menu copyWithUpdatedRecipe({required MealTime mealTime, required int subMealIndex, required Recipe recipe, required List<Recipe> recipes}) {
    // Prepare relevant data
    Meal mealToUpdate = meals.firstWhere((meal) => meal.mealTime.isSameTime(mealTime));

    // No need to update the meal if it already has the recipe we want to update it to
    if (mealToUpdate.subMeals[subMealIndex].cooking?.recipeId == recipe.id) return this;

    mealToUpdate = mealToUpdate.copyWithSubMealCooking(subMealIndex, Cooking(recipeId: recipe.id, yield: 1));

    // Generate the updated meals list
    List<Meal> newMeals = [...meals];
    newMeals[newMeals.indexWhere((meal) => meal.mealTime.isSameTime(mealToUpdate.mealTime))] = mealToUpdate;

    return copyWith(meals: newMeals).copyWithUpdatedYields(recipes: recipes);
  }

  List<Meal?> mealsOfDay(WeekDay weekDay) {
    List<Meal> dayMeals = meals.where((meal) => meal.mealTime.weekDay == weekDay).toList();
    List<Meal?> dayMealsWithNulls = List.filled(3, null, growable: false);
    dayMealsWithNulls[0] = dayMeals.firstWhereOrNull((meal) => meal.mealTime.mealType == MealType.breakfast);
    dayMealsWithNulls[1] = dayMeals.firstWhereOrNull((meal) => meal.mealTime.mealType == MealType.lunch);
    dayMealsWithNulls[2] = dayMeals.firstWhereOrNull((meal) => meal.mealTime.mealType == MealType.dinner);
    return dayMealsWithNulls;
  }

  /// Recalculates yields for a single week (weekIndex defaults to 0).
  /// Use [MultiWeekMenu.copyWithUpdatedYields] for cross-week awareness.
  Menu copyWithUpdatedYields({required List<Recipe> recipes, int weekIndex = 0}) {
    return recalculateYields(meals: [...meals], recipes: recipes, weekIndex: weekIndex);
  }

  /// Shared yield recalculation logic. Operates on a flat list of meals belonging
  /// to this week. [weekIndex] is used to compute absolute day indices.
  /// [externalCookEvents] maps recipeId to the absolute day it was cooked in a
  /// previous week (for cross-week leftover awareness).
  static Menu recalculateYields({
    required List<Meal> meals,
    required List<Recipe> recipes,
    required int weekIndex,
    Map<String, int> externalCookEvents = const {},
  }) {
    List<Meal> sorted = [...meals].sorted((a, b) => a.goesBefore(b) ? -1 : 1).toList();

    // Track the cook day for each recipe (absolute day index).
    // Start with any carry-over from previous weeks.
    Map<String, int> cookDay = {...externalCookEvents};

    // Yield map: (MealTime, subMealIndex) -> yield value
    Map<(MealTime, int), int> yieldMap = {};

    // First pass: determine which sub-meals are "cook" vs "leftovers"
    for (Meal meal in sorted) {
      for (int si = 0; si < meal.subMeals.length; si++) {
        SubMeal subMeal = meal.subMeals[si];
        String? recipeId = subMeal.cooking?.recipeId;
        if (recipeId == null) continue;
        Recipe? recipe = recipes.firstWhereOrNull((r) => r.id == recipeId);
        if (recipe == null || recipe.maxStorageDays <= 0) {
          yieldMap[(meal.mealTime, si)] = 1;
          continue;
        }

        int absoluteDay = weekIndex * 7 + meal.mealTime.weekDay.value;
        if (cookDay.containsKey(recipeId) && (absoluteDay - cookDay[recipeId]!) <= recipe.maxStorageDays) {
          // Within storage window of a previous cook
          yieldMap[(meal.mealTime, si)] = 0;
        } else {
          // New cook event
          cookDay[recipeId] = absoluteDay;
          // Count how many subsequent sub-meal occurrences are within storage window
          int count = 0;
          for (Meal m in sorted) {
            for (SubMeal sm in m.subMeals) {
              if (sm.cooking?.recipeId != recipeId) continue;
              int mDay = weekIndex * 7 + m.mealTime.weekDay.value;
              if (mDay >= absoluteDay && (mDay - absoluteDay) <= recipe.maxStorageDays) {
                count++;
              }
            }
          }
          yieldMap[(meal.mealTime, si)] = count;
        }
      }
    }

    List<Meal> result = meals.map((Meal meal) {
      List<SubMeal> updatedSubMeals = [];
      for (int si = 0; si < meal.subMeals.length; si++) {
        SubMeal subMeal = meal.subMeals[si];
        if (subMeal.cooking == null) {
          updatedSubMeals.add(subMeal);
          continue;
        }
        int yieldValue = yieldMap[(meal.mealTime, si)] ?? 1;
        updatedSubMeals.add(
          SubMeal(
            cooking: Cooking(recipeId: subMeal.cooking!.recipeId, yield: yieldValue),
            people: subMeal.people,
          ),
        );
      }
      return Meal(mealTime: meal.mealTime, subMeals: updatedSubMeals);
    }).toList();

    return Menu(meals: result);
  }

  /// Shared pass for [allIngredients] and [ingredientSources]: the recipes that are actively cooked in this
  /// menu, each paired with the total people across ALL sub-meals sharing it and the resolved [Recipe].
  ///
  /// Selection rules (identical for both consumers):
  /// - Skip leftover sub-meals (storable recipes reused from a previous cook): yield <= 0.
  /// - Process each unique recipe only once. Non-storable recipes have yield=1 for every occurrence, so
  ///   without this guard each occurrence would be counted separately despite peopleFactor already summing
  ///   all people.
  /// - Recipes missing from [recipes] are still registered in the dedup set (so a later occurrence is not
  ///   reconsidered) but are excluded from the result.
  List<({Recipe recipe, int peopleFactor})> _activeCookedRecipes({required List<Recipe> recipes}) {
    List<({Recipe recipe, int peopleFactor})> result = [];
    Set<String> processedRecipeIds = {};

    for (Meal meal in meals) {
      for (SubMeal subMeal in meal.subMeals) {
        if (subMeal.cooking == null) continue;
        if (subMeal.cooking!.yield <= 0) continue;

        String recipeId = subMeal.cooking!.recipeId;
        if (processedRecipeIds.contains(recipeId)) continue;
        processedRecipeIds.add(recipeId);

        // Calculate the total people across all sub-meals sharing this recipe.
        int peopleFactor = 0;
        for (Meal m in meals) {
          for (SubMeal sm in m.subMeals) {
            if (sm.cooking?.recipeId == recipeId) {
              peopleFactor += sm.people;
            }
          }
        }

        Recipe? recipe = recipes.firstWhereOrNull((r) => r.id == recipeId);
        if (recipe == null) continue;

        result.add((recipe: recipe, peopleFactor: peopleFactor));
      }
    }

    return result;
  }

  Map<String, List<Quantity>> allIngredients({required List<Recipe> recipes}) {
    Map<String, List<Quantity>> ingredients = {};

    for (({Recipe recipe, int peopleFactor}) entry in _activeCookedRecipes(recipes: recipes)) {
      for (Instruction instruction in entry.recipe.instructions) {
        for (IngredientUsage ingredientUsage in instruction.ingredientsUsed) {
          if (ingredients[ingredientUsage.ingredient] == null) {
            ingredients[ingredientUsage.ingredient] = [];
          }
          if (!ingredients[ingredientUsage.ingredient]!.any((registeredQuantity) => registeredQuantity.unit == ingredientUsage.quantity.unit)) {
            ingredients[ingredientUsage.ingredient]!.add(Quantity(amount: 0 /*placeholder*/, unit: ingredientUsage.quantity.unit));
          }
          double amountToAdd = ingredientUsage.quantity.amount * entry.peopleFactor;
          Quantity oldQuantity = ingredients[ingredientUsage.ingredient]!.firstWhere(
            (registeredQuantity) => registeredQuantity.unit == ingredientUsage.quantity.unit,
          );
          Quantity newQuantity = oldQuantity.copyWith(amount: amountToAdd + oldQuantity.amount);
          ingredients[ingredientUsage.ingredient]!.remove(oldQuantity);
          ingredients[ingredientUsage.ingredient]!.add(newQuantity);
        }
      }
    }

    return ingredients;
  }

  /// Returns per-recipe breakdown of ingredient usage: which recipes use each ingredient,
  /// with per-serving quantities and total servings (peopleFactor).
  Map<String, List<IngredientSource>> ingredientSources({required List<Recipe> recipes}) {
    Map<String, List<IngredientSource>> sources = {};

    for (({Recipe recipe, int peopleFactor}) entry in _activeCookedRecipes(recipes: recipes)) {
      Map<String, List<Quantity>> perServing = entry.recipe.perServingQuantities();
      for (MapEntry<String, List<Quantity>> ingredient in perServing.entries) {
        List<IngredientSource> ingredientSources = sources.putIfAbsent(ingredient.key, () => <IngredientSource>[]);
        int existingIndex = ingredientSources.indexWhere((IngredientSource s) => s.recipeName == entry.recipe.name);
        if (existingIndex >= 0) {
          // Two recipes of the menu share a name. Keep one row and add the amounts together.
          IngredientSource existing = ingredientSources[existingIndex];
          List<Quantity> merged = [...existing.perServingQuantities];
          for (Quantity quantity in ingredient.value) {
            int mergedIndex = merged.indexWhere((Quantity q) => q.unit == quantity.unit);
            if (mergedIndex < 0) {
              merged.add(quantity);
            } else {
              merged[mergedIndex] = merged[mergedIndex].copyWith(amount: merged[mergedIndex].amount + quantity.amount);
            }
          }
          ingredientSources[existingIndex] = existing.copyWith(perServingQuantities: merged);
        } else {
          ingredientSources.add(
            IngredientSource(recipeName: entry.recipe.name, perServingQuantities: ingredient.value, servings: entry.peopleFactor),
          );
        }
      }
    }

    return sources;
  }

  Menu copyWithClearedSubMeal({required MealTime mealTime, required int subMealIndex, required List<Recipe> recipes}) {
    List<Meal> newMeals = [...meals];
    int index = newMeals.indexWhere((Meal meal) => meal.mealTime.isSameTime(mealTime));
    if (index == -1) return this;
    newMeals[index] = newMeals[index].copyWithSubMealCooking(subMealIndex, null);
    return copyWith(meals: newMeals).copyWithUpdatedYields(recipes: recipes);
  }

  Menu copyWithAddedSubMeal({required MealTime mealTime, required List<Recipe> recipes}) {
    List<Meal> newMeals = [...meals];
    int index = newMeals.indexWhere((Meal meal) => meal.mealTime.isSameTime(mealTime));
    if (index == -1) return this;
    Meal meal = newMeals[index];
    newMeals[index] = meal.copyWith(subMeals: [...meal.subMeals, const SubMeal()]);
    return copyWith(meals: newMeals).copyWithUpdatedYields(recipes: recipes);
  }

  Menu copyWithRemovedSubMeal({required MealTime mealTime, required int subMealIndex, required List<Recipe> recipes}) {
    List<Meal> newMeals = [...meals];
    int index = newMeals.indexWhere((Meal meal) => meal.mealTime.isSameTime(mealTime));
    if (index == -1) return this;
    Meal meal = newMeals[index];
    if (subMealIndex >= meal.subMeals.length) return this;
    List<SubMeal> newSubMeals = [...meal.subMeals]..removeAt(subMealIndex);
    newMeals[index] = meal.copyWith(subMeals: newSubMeals);
    return copyWith(meals: newMeals).copyWithUpdatedYields(recipes: recipes);
  }

  Menu copyWithUpdatedPeople({required MealTime mealTime, required int subMealIndex, required int people, required List<Recipe> recipes}) {
    List<Meal> newMeals = [...meals];
    int index = newMeals.indexWhere((Meal meal) => meal.mealTime.isSameTime(mealTime));
    if (index != -1) {
      newMeals[index] = newMeals[index].copyWithSubMealPeople(subMealIndex, people);
    }
    return copyWith(meals: newMeals).copyWithUpdatedYields(recipes: recipes);
  }

  /// Total number of servings to cook for a recipe, summing people across all sub-meals that share it.
  int totalServingsForRecipe(String recipeId) {
    int total = 0;
    for (Meal meal in meals) {
      for (SubMeal subMeal in meal.subMeals) {
        if (subMeal.cooking?.recipeId == recipeId) {
          total += subMeal.people;
        }
      }
    }
    return total;
  }

  /// [dayLabels] names each day of this week. The caller builds it with `menuDayLabel`,
  /// because the start date lives on MultiWeekMenu. That function owns the date-less wording
  /// too, so this method never needs a name of its own. The map must hold all seven days.
  /// A missing day throws, so a partial map fails at the caller, not in the clipboard text.
  ///
  /// [cookServings] says how many servings each cook event makes, keyed by the meal slot and the
  /// index of the sub-meal. The caller builds it with `MultiWeekMenu.servingsForCookEvent`,
  /// because a cook event can also feed a meal of the next week. The map must hold every
  /// sub-meal whose `Cooking.yield` is above zero. A missing cook event throws, for the same
  /// reason as a missing day label.
  String toStringBeautified({
    required List<Recipe> recipes,
    required Map<WeekDay, String> dayLabels,
    required Map<(MealTime, int), int> cookServings,
  }) {
    // Format:
    // Weekday
    //   Breakfast: recipe [x p] (cook n servings)
    //   Lunch: recipe [x p] (leftovers)
    //   Dinner: -
    // NOTE: If a meal has no sub-meals or no recipe, it will be displayed as "-"

    String result = "";
    for (WeekDay weekDay in WeekDay.values) {
      result += "${dayLabels[weekDay]!}\n";
      List<Meal?> dayMeals = mealsOfDay(weekDay);
      for (int i = 0; i < dayMeals.length; i++) {
        Meal? meal = dayMeals[i];
        String? mealType = MealType.values[i].name.capitalizeFirstLetter();
        if (meal == null || meal.subMeals.isEmpty) {
          result += "  $mealType: -\n";
        } else if (meal.subMeals.length == 1) {
          result += "  $mealType: ${_subMealText(meal: meal, subMealIndex: 0, recipes: recipes, cookServings: cookServings)}\n";
        } else {
          result += "  $mealType:\n";
          for (int si = 0; si < meal.subMeals.length; si++) {
            result += "    ${si + 1}. ${_subMealText(meal: meal, subMealIndex: si, recipes: recipes, cookServings: cookServings)}\n";
          }
        }
      }
      result += "\n";
    }
    return result.trim();
  }

  /// Writes one sub-meal of [toStringBeautified], for example "Pasta [2p] (cook 4 servings)".
  ///
  /// A sub-meal with no recipe reads only "-", because there is nothing to eat and nobody to
  /// count. Every other sub-meal shows its people count, and then says if the cook makes the food
  /// at that meal or if the meal eats leftovers of an earlier cook.
  String _subMealText({
    required Meal meal,
    required int subMealIndex,
    required List<Recipe> recipes,
    required Map<(MealTime, int), int> cookServings,
  }) {
    SubMeal subMeal = meal.subMeals[subMealIndex];
    Cooking? cooking = subMeal.cooking;
    if (cooking == null) return "-";

    String recipeName = recipes.firstWhereOrNull((Recipe r) => r.id == cooking.recipeId)?.name ?? "-";
    if (cooking.yield <= 0) return "$recipeName [${subMeal.people}p] (leftovers)";

    int servings = cookServings[(meal.mealTime, subMealIndex)]!;
    return "$recipeName [${subMeal.people}p] (cook $servings ${servings == 1 ? "serving" : "servings"})";
  }
}
