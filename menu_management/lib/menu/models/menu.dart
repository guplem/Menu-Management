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

  Menu copyWithUpdatedYields({required List<Recipe> recipes}) {
    List<Meal> oldMeals = [...this.meals];

    bool isFirstTimeOfRecipe(MealTime time, String recipeId) {
      List<Meal> sortedMealTimes = oldMeals.sorted((a, b) => a.goesBefore(b) ? -1 : 1).toList();
      for (int i = 0; i < sortedMealTimes.length; i++) {
        MealTime t = sortedMealTimes[i].mealTime;
        String? r = sortedMealTimes[i].cooking?.recipeId;
        if (r == recipeId && t.goesBefore(time)) {
          return false;
        } else if (r == recipeId && (t == time || time.goesBefore(t))) {
          return true;
        }
      }
      Debug.logError("This should not happen");
      return false;
    }

    List<Meal> meals = oldMeals.map((meal) {
      String? recipeId = meal.cooking?.recipeId;
      Recipe? recipe = recipeId != null ? recipes.firstWhereOrNull((r) => r.id == recipeId) : null;

      int yield = 1;
      if (recipe != null && recipe.canBeStored) {
        if (isFirstTimeOfRecipe(meal.mealTime, recipeId!)) {
          yield = oldMeals.count((Meal element) => element.cooking?.recipeId == recipeId);
        } else {
          yield = 0;
        }
      }

      return Meal(
        mealTime: meal.mealTime,
        cooking: recipeId == null ? null : Cooking(recipeId: recipeId, yield: yield),
        people: meal.people,
      );
    }).toList();

    return copyWith(meals: meals);
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
