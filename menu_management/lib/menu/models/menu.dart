import "package:freezed_annotation/freezed_annotation.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/menu/enums/meal_type.dart";
import "package:menu_management/menu/enums/week_day.dart";
import "package:menu_management/menu/models/cooking.dart";
import "package:menu_management/menu/models/meal.dart";
import "package:menu_management/menu/models/meal_time.dart";
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

  Menu copyWithUpdatedRecipe({required MealTime mealTime, required Recipe recipe, required List<Recipe> recipes}) {
    // Prepare relevant data
    Meal mealToUpdate = meals.firstWhere((meal) => meal.mealTime.isSameTime(mealTime));

    // No need to update the meal if it already has the recipe we want to update it to
    if (mealToUpdate.cooking?.recipeId == recipe.id) return this;

    mealToUpdate = mealToUpdate.copyWithUpdatedCooking(Cooking(recipeId: recipe.id, yield: 1));

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

    // First pass: determine which meals are "cook" vs "leftovers"
    Map<MealTime, int> yieldMap = {};
    for (Meal meal in sorted) {
      String? recipeId = meal.cooking?.recipeId;
      if (recipeId == null) continue;
      Recipe? recipe = recipes.firstWhereOrNull((r) => r.id == recipeId);
      if (recipe == null || recipe.maxStorageDays <= 0) {
        yieldMap[meal.mealTime] = 1;
        continue;
      }

      int absoluteDay = weekIndex * 7 + meal.mealTime.weekDay.value;
      if (cookDay.containsKey(recipeId) && (absoluteDay - cookDay[recipeId]!) <= recipe.maxStorageDays) {
        // Within storage window of a previous cook
        yieldMap[meal.mealTime] = 0;
      } else {
        // New cook event
        cookDay[recipeId] = absoluteDay;
        // Count how many subsequent occurrences are within storage window
        int count = sorted.where((Meal m) {
          if (m.cooking?.recipeId != recipeId) return false;
          int mDay = weekIndex * 7 + m.mealTime.weekDay.value;
          return mDay >= absoluteDay && (mDay - absoluteDay) <= recipe.maxStorageDays;
        }).length;
        yieldMap[meal.mealTime] = count;
      }
    }

    List<Meal> result = meals.map((Meal meal) {
      String? recipeId = meal.cooking?.recipeId;
      if (recipeId == null) return meal;
      int yield = yieldMap[meal.mealTime] ?? 1;
      return Meal(
        mealTime: meal.mealTime,
        cooking: Cooking(recipeId: recipeId, yield: yield),
        people: meal.people,
      );
    }).toList();

    return Menu(meals: result);
  }

  Map<String, List<Quantity>> allIngredients({required List<Recipe> recipes}) {
    Map<String, List<Quantity>> ingredients = {};
    Set<String> processedRecipeIds = {};

    for (Meal meal in meals) {
      if (meal.cooking == null) continue;
      int yields = meal.cooking!.yield;

      // Skip leftover meals (storable recipes reused from a previous cook).
      if (yields <= 0) continue;

      // Process each unique recipe only once.
      // Non-storable recipes have yield=1 for every occurrence, so without this guard
      // each occurrence would be counted separately despite peopleFactor already summing all people.
      String recipeId = meal.cooking!.recipeId;
      if (processedRecipeIds.contains(recipeId)) continue;
      processedRecipeIds.add(recipeId);

      // Calculate the total people across all meals sharing this recipe.
      int peopleFactor = meals.where((Meal m) => m.cooking?.recipeId == recipeId).fold(0, (int sum, Meal m) => sum + m.people);

      Recipe? recipe = recipes.firstWhereOrNull((r) => r.id == meal.cooking!.recipeId);
      if (recipe == null) continue;

      for (Instruction instruction in recipe.instructions) {
        for (IngredientUsage ingredientUsage in instruction.ingredientsUsed) {
          if (ingredients[ingredientUsage.ingredient] == null) {
            ingredients[ingredientUsage.ingredient] = [];
          }
          if (!ingredients[ingredientUsage.ingredient]!.any((registeredQuantity) => registeredQuantity.unit == ingredientUsage.quantity.unit)) {
            ingredients[ingredientUsage.ingredient]!.add(Quantity(amount: 0 /*placeholder*/, unit: ingredientUsage.quantity.unit));
          }
          double amountToAdd = ingredientUsage.quantity.amount * peopleFactor;
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
    Set<String> processedRecipeIds = {};

    for (Meal meal in meals) {
      if (meal.cooking == null) continue;
      if (meal.cooking!.yield <= 0) continue;
      if (processedRecipeIds.contains(meal.cooking!.recipeId)) continue;
      processedRecipeIds.add(meal.cooking!.recipeId);

      int peopleFactor = meals.where((Meal m) => m.cooking?.recipeId == meal.cooking?.recipeId).fold(0, (int sum, Meal m) => sum + m.people);

      Recipe? recipe = recipes.firstWhereOrNull((r) => r.id == meal.cooking!.recipeId);
      if (recipe == null) continue;

      for (Instruction instruction in recipe.instructions) {
        for (IngredientUsage ingredientUsage in instruction.ingredientsUsed) {
          sources[ingredientUsage.ingredient] ??= [];

          // Find or create the source entry for this recipe
          int existingIndex = sources[ingredientUsage.ingredient]!.indexWhere((s) => s.recipeName == recipe.name);
          if (existingIndex >= 0) {
            IngredientSource existing = sources[ingredientUsage.ingredient]![existingIndex];
            List<Quantity> updatedQuantities = [...existing.perServingQuantities];
            Quantity? existingQty = updatedQuantities.firstWhereOrNull((q) => q.unit == ingredientUsage.quantity.unit);
            if (existingQty != null) {
              updatedQuantities.remove(existingQty);
              updatedQuantities.add(existingQty.copyWith(amount: existingQty.amount + ingredientUsage.quantity.amount));
            } else {
              updatedQuantities.add(ingredientUsage.quantity);
            }
            sources[ingredientUsage.ingredient]![existingIndex] = existing.copyWith(perServingQuantities: updatedQuantities);
          } else {
            sources[ingredientUsage.ingredient]!.add(IngredientSource(
              recipeName: recipe.name,
              perServingQuantities: [ingredientUsage.quantity],
              servings: peopleFactor,
            ));
          }
        }
      }
    }

    return sources;
  }

  Menu copyWithClearedMeal({required MealTime mealTime, required List<Recipe> recipes}) {
    List<Meal> newMeals = [...meals];
    int index = newMeals.indexWhere((Meal meal) => meal.mealTime.isSameTime(mealTime));
    if (index == -1) return this;
    newMeals[index] = newMeals[index].copyWithUpdatedCooking(null);
    return copyWith(meals: newMeals).copyWithUpdatedYields(recipes: recipes);
  }

  Menu copyWithUpdatedPeople({required MealTime mealTime, required int people, required List<Recipe> recipes}) {
    List<Meal> newMeals = [...meals];
    int index = newMeals.indexWhere((Meal meal) => meal.mealTime.isSameTime(mealTime));
    if (index != -1) {
      newMeals[index] = newMeals[index].copyWith(people: people);
    }
    return copyWith(meals: newMeals).copyWithUpdatedYields(recipes: recipes);
  }

  /// Total number of servings to cook for a recipe, summing people across all meals that share it.
  int totalServingsForRecipe(String recipeId) {
    return meals.where((Meal m) => m.cooking?.recipeId == recipeId).fold(0, (int sum, Meal m) => sum + m.people);
  }

  String toStringBeautified({required List<Recipe> recipes}) {
    // Format:
    // Weekday
    //   Breakfast: recipe (yield pp)
    //   Lunch: recipe (yield pp)
    //   Dinner: recipe (yield pp)
    // NOTE: If a meal has no recipe, it will be displayed as "-", with no yield

    String result = "";
    for (WeekDay weekDay in WeekDay.values) {
      result += "${weekDay.name.capitalizeFirstLetter()}\n";
      List<Meal?> dayMeals = mealsOfDay(weekDay);
      for (int i = 0; i < dayMeals.length; i++) {
        Meal? meal = dayMeals[i];
        String? mealType = MealType.values[i].name.capitalizeFirstLetter();
        String recipeName = (meal?.cooking != null ? recipes.firstWhereOrNull((r) => r.id == meal!.cooking!.recipeId)?.name : null) ?? "-";
        recipeName += meal?.cooking == null ? "" : " (${meal?.cooking?.yield.toString()} pp)";
        result += "  $mealType: $recipeName\n";
      }
      result += "\n";
    }
    return result.trim();
  }
}
