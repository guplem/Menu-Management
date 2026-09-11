import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:menu_management/menu/enums/meal_type.dart";
import "package:menu_management/menu/enums/week_day.dart";
import "package:menu_management/menu/menu_dates.dart";
import "package:menu_management/menu/models/cooking.dart";
import "package:menu_management/menu/models/meal.dart";
import "package:menu_management/menu/models/meal_time.dart";
import "package:menu_management/menu/models/menu.dart";
import "package:menu_management/menu/models/menu_configuration.dart";
import "package:menu_management/menu/models/multi_week_menu.dart";
import "package:menu_management/menu/models/sub_meal.dart";
import "package:menu_management/recipes/enums/unit.dart";
import "package:menu_management/recipes/models/ingredient_usage.dart";
import "package:menu_management/recipes/models/instruction.dart";
import "package:menu_management/recipes/models/quantity.dart";
import "package:menu_management/recipes/models/recipe.dart";
import "package:menu_management/shopping/ingredient_source.dart";

// ── Test helpers ──

Recipe _recipe({String id = "r1", String name = "Test Recipe", List<Instruction> instructions = const [], int maxStorageDays = 6}) {
  return Recipe(id: id, name: name, instructions: instructions, maxStorageDays: maxStorageDays);
}

Meal _meal({WeekDay weekDay = WeekDay.saturday, MealType mealType = MealType.lunch, Recipe? recipe, int yield = 1, int people = 2}) {
  return Meal(
    mealTime: MealTime(weekDay: weekDay, mealType: mealType),
    subMeals: [
      SubMeal(
        cooking: recipe != null ? Cooking(recipeId: recipe.id, yield: yield) : null,
        people: people,
      ),
    ],
  );
}

/// Builds the day labels of one week the same way MultiWeekMenu builds them.
Map<WeekDay, String> _dayLabels({DateTime? startDate, int weekIndex = 0}) {
  return {for (WeekDay weekDay in WeekDay.values) weekDay: menuDayLabel(startDate: startDate, weekIndex: weekIndex, weekDay: weekDay)};
}

/// Builds the servings of every cook event of one week through the public API of MultiWeekMenu.
///
/// The production caller is `MultiWeekMenu.toStringBeautified`, which reads
/// [MultiWeekMenu.servingsForCookEvent]. This helper reads the same method, so it respects
/// `maxStorageDays` and the day order exactly as production does. It never reimplements the count.
///
/// [recipes] must hold every recipe of [menu], because servingsForCookEvent reads maxStorageDays
/// from the recipe. A missing recipe gives a storage window of zero days.
Map<(MealTime, int), int> _cookServings(Menu menu, {required List<Recipe> recipes}) {
  MultiWeekMenu multiWeek = MultiWeekMenu(weeks: [menu]);
  Map<(MealTime, int), int> servings = {};
  for (Meal meal in menu.meals) {
    for (int subMealIndex = 0; subMealIndex < meal.subMeals.length; subMealIndex++) {
      Cooking? cooking = meal.subMeals[subMealIndex].cooking;
      if (cooking == null || cooking.yield <= 0) continue;
      servings[(meal.mealTime, subMealIndex)] = multiWeek.servingsForCookEvent(
        cookWeekIndex: 0,
        cookMealTime: meal.mealTime,
        subMealIndex: subMealIndex,
        recipes: recipes,
      );
    }
  }
  return servings;
}

void main() {
  // ── MealTime ──

  group("MealTime", () {
    group("isSameTime", () {
      test("true for same weekDay and mealType", () {
        const MealTime a = MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch);
        const MealTime b = MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch);
        expect(a.isSameTime(b), true);
      });

      test("false for different weekDay", () {
        const MealTime a = MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch);
        const MealTime b = MealTime(weekDay: WeekDay.tuesday, mealType: MealType.lunch);
        expect(a.isSameTime(b), false);
      });

      test("false for different mealType", () {
        const MealTime a = MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch);
        const MealTime b = MealTime(weekDay: WeekDay.monday, mealType: MealType.dinner);
        expect(a.isSameTime(b), false);
      });
    });

    group("goesBefore", () {
      test("earlier day goes before later day", () {
        const MealTime sat = MealTime(weekDay: WeekDay.saturday, mealType: MealType.dinner);
        const MealTime sun = MealTime(weekDay: WeekDay.sunday, mealType: MealType.breakfast);
        expect(sat.goesBefore(sun), true);
      });

      test("same day: breakfast goes before lunch", () {
        const MealTime breakfast = MealTime(weekDay: WeekDay.monday, mealType: MealType.breakfast);
        const MealTime lunch = MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch);
        expect(breakfast.goesBefore(lunch), true);
      });

      test("same time does not go before itself", () {
        const MealTime a = MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch);
        expect(a.goesBefore(a), false);
      });

      test("later day does not go before earlier day", () {
        const MealTime sun = MealTime(weekDay: WeekDay.sunday, mealType: MealType.breakfast);
        const MealTime sat = MealTime(weekDay: WeekDay.saturday, mealType: MealType.dinner);
        expect(sun.goesBefore(sat), false);
      });
    });

    group("goesAfter", () {
      test("later day goes after earlier day", () {
        const MealTime sun = MealTime(weekDay: WeekDay.sunday, mealType: MealType.breakfast);
        const MealTime sat = MealTime(weekDay: WeekDay.saturday, mealType: MealType.dinner);
        expect(sun.goesAfter(sat), true);
      });

      test("same day: dinner goes after lunch", () {
        const MealTime dinner = MealTime(weekDay: WeekDay.monday, mealType: MealType.dinner);
        const MealTime lunch = MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch);
        expect(dinner.goesAfter(lunch), true);
      });

      test("same time does not go after itself", () {
        const MealTime a = MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch);
        expect(a.goesAfter(a), false);
      });
    });
  });

  // ── Meal ──

  group("Meal", () {
    test("subMeals default to empty list", () {
      const Meal meal = Meal(
        mealTime: MealTime(weekDay: WeekDay.saturday, mealType: MealType.lunch),
      );
      expect(meal.subMeals, isEmpty);
    });

    test("helper creates meal with people 2 by default", () {
      Meal meal = _meal();
      expect(meal.subMeals.first.people, 2);
    });

    test("goesBefore delegates to MealTime", () {
      Meal earlier = _meal(weekDay: WeekDay.saturday, mealType: MealType.breakfast);
      Meal later = _meal(weekDay: WeekDay.saturday, mealType: MealType.dinner);
      expect(earlier.goesBefore(later), true);
      expect(later.goesBefore(earlier), false);
    });

    test("goesAfter delegates to MealTime", () {
      Meal earlier = _meal(weekDay: WeekDay.saturday, mealType: MealType.breakfast);
      Meal later = _meal(weekDay: WeekDay.saturday, mealType: MealType.dinner);
      expect(later.goesAfter(earlier), true);
      expect(earlier.goesAfter(later), false);
    });

    test("copyWithSubMealCooking replaces cooking at index", () {
      Recipe recipe = _recipe();
      Meal meal = _meal();
      Cooking newCooking = Cooking(recipeId: recipe.id, yield: 3);
      Meal updated = meal.copyWithSubMealCooking(0, newCooking);
      expect(updated.subMeals.first.cooking?.yield, 3);
      expect(updated.subMeals.first.cooking?.recipeId, recipe.id);
    });

    test("copyWithSubMealCooking can set cooking to null", () {
      Recipe recipe = _recipe();
      Meal meal = _meal(recipe: recipe);
      Meal updated = meal.copyWithSubMealCooking(0, null);
      expect(updated.subMeals.first.cooking, null);
    });

    test("copyWithSubMealPeople updates people at index", () {
      Meal meal = _meal(people: 2);
      Meal updated = meal.copyWithSubMealPeople(0, 5);
      expect(updated.subMeals.first.people, 5);
    });
  });

  // ── SubMeal ──

  group("SubMeal", () {
    test("defaults to 1 person and no cooking", () {
      const SubMeal subMeal = SubMeal();
      expect(subMeal.people, 1);
      expect(subMeal.cooking, isNull);
    });

    test("holds cooking and people", () {
      const SubMeal subMeal = SubMeal(cooking: Cooking(recipeId: "r1", yield: 2), people: 4);
      expect(subMeal.cooking?.recipeId, "r1");
      expect(subMeal.cooking?.yield, 2);
      expect(subMeal.people, 4);
    });

    test("equality by value", () {
      const SubMeal a = SubMeal(cooking: Cooking(recipeId: "r1", yield: 1), people: 2);
      const SubMeal b = SubMeal(cooking: Cooking(recipeId: "r1", yield: 1), people: 2);
      expect(a, b);
    });

    test("copyWith updates fields", () {
      const SubMeal original = SubMeal(cooking: Cooking(recipeId: "r1", yield: 1), people: 2);
      SubMeal updated = original.copyWith(people: 5);
      expect(updated.people, 5);
      expect(updated.cooking?.recipeId, "r1");
    });
  });

  // ── MenuConfiguration ──

  group("MenuConfiguration", () {
    group("isMeal", () {
      test("true for lunch", () {
        const MenuConfiguration config = MenuConfiguration(
          mealTime: MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch),
        );
        expect(config.isMeal, true);
      });

      test("true for dinner", () {
        const MenuConfiguration config = MenuConfiguration(
          mealTime: MealTime(weekDay: WeekDay.monday, mealType: MealType.dinner),
        );
        expect(config.isMeal, true);
      });

      test("false for breakfast", () {
        const MenuConfiguration config = MenuConfiguration(
          mealTime: MealTime(weekDay: WeekDay.monday, mealType: MealType.breakfast),
        );
        expect(config.isMeal, false);
      });
    });

    group("canBeCookedAtTheSpot", () {
      test("true when meal is required and has cooking time", () {
        const MenuConfiguration config = MenuConfiguration(
          mealTime: MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch),
          requiresMeal: true,
          availableCookingTimeMinutes: 60,
        );
        expect(config.canBeCookedAtTheSpot, true);
      });

      test("false when meal is not required", () {
        const MenuConfiguration config = MenuConfiguration(
          mealTime: MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch),
          requiresMeal: false,
          availableCookingTimeMinutes: 60,
        );
        expect(config.canBeCookedAtTheSpot, false);
      });

      test("false when cooking time is 0", () {
        const MenuConfiguration config = MenuConfiguration(
          mealTime: MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch),
          requiresMeal: true,
          availableCookingTimeMinutes: 0,
        );
        expect(config.canBeCookedAtTheSpot, false);
      });
    });

    group("goesBefore", () {
      test("earlier config goes before later config", () {
        const MenuConfiguration satLunch = MenuConfiguration(
          mealTime: MealTime(weekDay: WeekDay.saturday, mealType: MealType.lunch),
        );
        const MenuConfiguration satDinner = MenuConfiguration(
          mealTime: MealTime(weekDay: WeekDay.saturday, mealType: MealType.dinner),
        );
        expect(satLunch.goesBefore(satDinner), true);
        expect(satDinner.goesBefore(satLunch), false);
      });
    });

    group("defaults", () {
      test("requiresMeal defaults to true", () {
        const MenuConfiguration config = MenuConfiguration(
          mealTime: MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch),
        );
        expect(config.requiresMeal, true);
      });

      test("availableCookingTimeMinutes defaults to 60", () {
        const MenuConfiguration config = MenuConfiguration(
          mealTime: MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch),
        );
        expect(config.availableCookingTimeMinutes, 60);
      });
    });
  });

  // ── Menu ──

  group("Menu", () {
    group("mealsOfDay", () {
      test("returns meals for specified day in order: breakfast, lunch, dinner", () {
        Recipe recipe = _recipe();
        Menu menu = Menu(
          meals: [
            _meal(weekDay: WeekDay.monday, mealType: MealType.dinner, recipe: recipe),
            _meal(weekDay: WeekDay.monday, mealType: MealType.breakfast, recipe: recipe),
            _meal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipe: recipe),
          ],
        );
        List<Meal?> dayMeals = menu.mealsOfDay(WeekDay.monday);
        expect(dayMeals.length, 3);
        expect(dayMeals[0]?.mealTime.mealType, MealType.breakfast);
        expect(dayMeals[1]?.mealTime.mealType, MealType.lunch);
        expect(dayMeals[2]?.mealTime.mealType, MealType.dinner);
      });

      test("returns nulls for missing meal types", () {
        Menu menu = Menu(
          meals: [_meal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipe: _recipe())],
        );
        List<Meal?> dayMeals = menu.mealsOfDay(WeekDay.monday);
        expect(dayMeals[0], null); // no breakfast
        expect(dayMeals[1], isNotNull); // lunch exists
        expect(dayMeals[2], null); // no dinner
      });

      test("returns all nulls for a day with no meals", () {
        Menu menu = const Menu(meals: []);
        List<Meal?> dayMeals = menu.mealsOfDay(WeekDay.friday);
        expect(dayMeals, [null, null, null]);
      });
    });

    group("copyWithUpdatedPeople", () {
      test("updates people count for matching meal", () {
        Recipe recipe = _recipe();
        List<Recipe> recipes = [recipe];
        MealTime time = const MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch);
        Menu menu = Menu(
          meals: [_meal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipe: recipe, people: 2)],
        );
        Menu updated = menu.copyWithUpdatedPeople(mealTime: time, subMealIndex: 0, people: 4, recipes: recipes);
        expect(updated.meals.first.subMeals.first.people, 4);
      });

      test("does not change other meals", () {
        Recipe recipe = _recipe();
        List<Recipe> recipes = [recipe];
        Menu menu = Menu(
          meals: [
            _meal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipe: recipe, people: 2),
            _meal(weekDay: WeekDay.monday, mealType: MealType.dinner, recipe: recipe, people: 3),
          ],
        );
        MealTime lunchTime = const MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch);
        Menu updated = menu.copyWithUpdatedPeople(mealTime: lunchTime, subMealIndex: 0, people: 5, recipes: recipes);
        expect(updated.meals[0].subMeals.first.people, 5);
        expect(updated.meals[1].subMeals.first.people, 3); // unchanged
      });

      test("recalculates yields after changing people", () {
        Recipe storable = _recipe(id: "s1", maxStorageDays: 6);
        List<Recipe> recipes = [storable];
        Menu menu = Menu(
          meals: [
            _meal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipe: storable, yield: 2, people: 2),
            _meal(weekDay: WeekDay.tuesday, mealType: MealType.lunch, recipe: storable, yield: 0, people: 2),
          ],
        );

        // Change people on the leftovers meal (Tuesday)
        MealTime tuesdayLunch = const MealTime(weekDay: WeekDay.tuesday, mealType: MealType.lunch);
        Menu updated = menu.copyWithUpdatedPeople(mealTime: tuesdayLunch, subMealIndex: 0, people: 4, recipes: recipes);

        // People updated
        expect(updated.meals[1].subMeals.first.people, 4);

        // Yields should still be recalculated: first occurrence cooks, second is leftovers
        expect(updated.meals[0].subMeals.first.cooking!.yield, 2); // still first occurrence, yield = count of meals with that recipe
        expect(updated.meals[1].subMeals.first.cooking!.yield, 0); // still leftovers
      });
    });

    group("totalServingsForRecipe", () {
      test("sums people across all meals sharing the same recipe", () {
        Recipe storable = _recipe(id: "s1", maxStorageDays: 6);
        Menu menu = Menu(
          meals: [
            _meal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipe: storable, yield: 2, people: 2),
            _meal(weekDay: WeekDay.tuesday, mealType: MealType.lunch, recipe: storable, yield: 0, people: 4),
          ],
        );

        expect(menu.totalServingsForRecipe("s1"), 6); // 2 + 4
      });

      test("returns people for a single-occurrence recipe", () {
        Recipe recipe = _recipe(id: "r1", maxStorageDays: 0);
        Menu menu = Menu(
          meals: [_meal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipe: recipe, yield: 1, people: 3)],
        );

        expect(menu.totalServingsForRecipe("r1"), 3);
      });

      test("returns 0 for unknown recipe id", () {
        Menu menu = Menu(
          meals: [_meal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipe: _recipe(), people: 2)],
        );
        expect(menu.totalServingsForRecipe("unknown"), 0);
      });
    });

    group("copyWithClearedSubMeal", () {
      test("sets cooking to null for the specified sub-meal", () {
        Recipe recipe = _recipe(id: "r1");
        List<Recipe> recipes = [recipe];
        MealTime time = const MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch);
        Menu menu = Menu(
          meals: [_meal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipe: recipe)],
        );

        Menu updated = menu.copyWithClearedSubMeal(mealTime: time, subMealIndex: 0, recipes: recipes);
        expect(updated.meals.first.subMeals.first.cooking, isNull);
      });

      test("does not affect other meals", () {
        Recipe recipe = _recipe(id: "r1");
        List<Recipe> recipes = [recipe];
        MealTime lunchTime = const MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch);
        Menu menu = Menu(
          meals: [
            _meal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipe: recipe),
            _meal(weekDay: WeekDay.monday, mealType: MealType.dinner, recipe: recipe),
          ],
        );

        Menu updated = menu.copyWithClearedSubMeal(mealTime: lunchTime, subMealIndex: 0, recipes: recipes);
        expect(updated.meals.firstWhere((m) => m.mealTime.mealType == MealType.lunch).subMeals.first.cooking, isNull);
        expect(updated.meals.firstWhere((m) => m.mealTime.mealType == MealType.dinner).subMeals.first.cooking, isNotNull);
      });

      test("recalculates yields after clearing a shared recipe", () {
        Recipe recipe = _recipe(id: "r1", maxStorageDays: 6);
        List<Recipe> recipes = [recipe];
        // Two meals share the same storable recipe
        Menu menu = Menu(
          meals: [
            _meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: recipe, yield: 2),
            _meal(weekDay: WeekDay.sunday, mealType: MealType.lunch, recipe: recipe, yield: 0),
          ],
        );
        MealTime satLunch = const MealTime(weekDay: WeekDay.saturday, mealType: MealType.lunch);

        Menu updated = menu.copyWithClearedSubMeal(mealTime: satLunch, subMealIndex: 0, recipes: recipes);
        // Saturday lunch cleared
        expect(updated.meals.firstWhere((m) => m.mealTime.isSameTime(satLunch)).subMeals.first.cooking, isNull);
        // Sunday lunch is now the sole user of the recipe, yield should be 1
        MealTime sunLunch = const MealTime(weekDay: WeekDay.sunday, mealType: MealType.lunch);
        expect(updated.meals.firstWhere((m) => m.mealTime.isSameTime(sunLunch)).subMeals.first.cooking?.yield, 1);
      });
    });

    group("copyWithAddedSubMeal", () {
      test("adds a sub-meal to the specified time slot", () {
        Recipe recipe = _recipe();
        List<Recipe> recipes = [recipe];
        MealTime time = const MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch);
        Menu menu = Menu(
          meals: [_meal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipe: recipe)],
        );

        Menu updated = menu.copyWithAddedSubMeal(mealTime: time, recipes: recipes);
        expect(updated.meals.first.subMeals.length, 2);
        expect(updated.meals.first.subMeals[0].cooking?.recipeId, "r1");
        expect(updated.meals.first.subMeals[1].cooking, isNull);
        expect(updated.meals.first.subMeals[1].people, 1);
      });

      test("does not affect other meals", () {
        Recipe recipe = _recipe();
        List<Recipe> recipes = [recipe];
        MealTime lunchTime = const MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch);
        Menu menu = Menu(
          meals: [
            _meal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipe: recipe),
            _meal(weekDay: WeekDay.monday, mealType: MealType.dinner, recipe: recipe),
          ],
        );

        Menu updated = menu.copyWithAddedSubMeal(mealTime: lunchTime, recipes: recipes);
        expect(updated.meals.firstWhere((m) => m.mealTime.mealType == MealType.lunch).subMeals.length, 2);
        expect(updated.meals.firstWhere((m) => m.mealTime.mealType == MealType.dinner).subMeals.length, 1);
      });
    });

    group("copyWithRemovedSubMeal", () {
      test("removes a sub-meal at the specified index", () {
        Recipe r1 = _recipe(id: "r1");
        Recipe r2 = _recipe(id: "r2");
        List<Recipe> recipes = [r1, r2];
        MealTime time = const MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch);
        Menu menu = Menu(
          meals: [
            Meal(
              mealTime: time,
              subMeals: [
                SubMeal(cooking: Cooking(recipeId: "r1", yield: 1), people: 1),
                SubMeal(cooking: Cooking(recipeId: "r2", yield: 1), people: 1),
              ],
            ),
          ],
        );

        Menu updated = menu.copyWithRemovedSubMeal(mealTime: time, subMealIndex: 0, recipes: recipes);
        expect(updated.meals.first.subMeals.length, 1);
        expect(updated.meals.first.subMeals.first.cooking?.recipeId, "r2");
      });

      test("returns same menu if subMealIndex is out of range", () {
        Recipe recipe = _recipe();
        List<Recipe> recipes = [recipe];
        MealTime time = const MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch);
        Menu menu = Menu(
          meals: [_meal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipe: recipe)],
        );

        Menu updated = menu.copyWithRemovedSubMeal(mealTime: time, subMealIndex: 5, recipes: recipes);
        expect(updated.meals.first.subMeals.length, 1);
      });
    });

    group("copyWithUpdatedRecipe", () {
      test("replaces recipe at the specified meal time", () {
        Recipe original = _recipe(id: "r1", name: "Pasta");
        Recipe replacement = _recipe(id: "r2", name: "Salad");
        List<Recipe> recipes = [original, replacement];
        MealTime time = const MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch);
        Menu menu = Menu(
          meals: [_meal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipe: original)],
        );

        Menu updated = menu.copyWithUpdatedRecipe(mealTime: time, subMealIndex: 0, recipe: replacement, recipes: recipes);
        expect(updated.meals.first.subMeals.first.cooking?.recipeId, "r2");
      });

      test("returns same menu if recipe is already set", () {
        Recipe recipe = _recipe(id: "r1", name: "Pasta");
        List<Recipe> recipes = [recipe];
        MealTime time = const MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch);
        Menu menu = Menu(
          meals: [_meal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipe: recipe)],
        );

        Menu updated = menu.copyWithUpdatedRecipe(mealTime: time, subMealIndex: 0, recipe: recipe, recipes: recipes);
        expect(identical(updated, menu), true);
      });
    });

    group("copyWithUpdatedYields", () {
      test("first occurrence of storable recipe gets full yield count", () {
        Recipe recipe = _recipe(id: "r1", maxStorageDays: 6);
        List<Recipe> recipes = [recipe];
        Menu menu = Menu(
          meals: [
            _meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: recipe, yield: -1),
            _meal(weekDay: WeekDay.sunday, mealType: MealType.lunch, recipe: recipe, yield: -1),
            _meal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipe: recipe, yield: -1),
          ],
        );

        Menu updated = menu.copyWithUpdatedYields(recipes: recipes);
        // First occurrence: yield = total count of this recipe = 3
        expect(updated.meals[0].subMeals.first.cooking?.yield, 3);
        // Later occurrences: yield = 0 (use leftovers)
        expect(updated.meals[1].subMeals.first.cooking?.yield, 0);
        expect(updated.meals[2].subMeals.first.cooking?.yield, 0);
      });

      test("non-storable recipe always gets yield 1", () {
        Recipe recipe = _recipe(id: "r1", maxStorageDays: 0);
        List<Recipe> recipes = [recipe];
        Menu menu = Menu(
          meals: [
            _meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: recipe, yield: -1),
            _meal(weekDay: WeekDay.sunday, mealType: MealType.lunch, recipe: recipe, yield: -1),
          ],
        );

        Menu updated = menu.copyWithUpdatedYields(recipes: recipes);
        expect(updated.meals[0].subMeals.first.cooking?.yield, 1);
        expect(updated.meals[1].subMeals.first.cooking?.yield, 1);
      });

      test("null cooking meals are preserved", () {
        Menu menu = Menu(
          meals: [_meal(weekDay: WeekDay.saturday, mealType: MealType.lunch)],
        );
        Menu updated = menu.copyWithUpdatedYields(recipes: []);
        expect(updated.meals.first.subMeals.first.cooking, null);
      });

      test("respects maxStorageDays: leftover beyond storage window becomes a new cook", () {
        // maxStorageDays: 1 means same day + tomorrow only
        Recipe recipe = _recipe(id: "r1", maxStorageDays: 1);
        List<Recipe> recipes = [recipe];
        Menu menu = Menu(
          meals: [
            _meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: recipe, yield: -1),
            _meal(weekDay: WeekDay.sunday, mealType: MealType.lunch, recipe: recipe, yield: -1), // 1 day later, within window
            _meal(weekDay: WeekDay.wednesday, mealType: MealType.lunch, recipe: recipe, yield: -1), // 4 days later, outside window
          ],
        );

        Menu updated = menu.copyWithUpdatedYields(recipes: recipes);
        // Saturday: cook for Sat + Sun (2 within window)
        expect(updated.meals[0].subMeals.first.cooking?.yield, 2);
        // Sunday: leftovers from Saturday
        expect(updated.meals[1].subMeals.first.cooking?.yield, 0);
        // Wednesday: outside storage window, new cook event (only itself)
        expect(updated.meals[2].subMeals.first.cooking?.yield, 1);
      });

      test("short maxStorageDays creates multiple cook events in one week", () {
        // maxStorageDays: 2 means days 0,1,2. Saturday=0, Monday=2 (within), Thursday=5 (outside)
        Recipe recipe = _recipe(id: "r1", maxStorageDays: 2);
        List<Recipe> recipes = [recipe];
        Menu menu = Menu(
          meals: [
            _meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: recipe, yield: -1),
            _meal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipe: recipe, yield: -1),
            _meal(weekDay: WeekDay.thursday, mealType: MealType.lunch, recipe: recipe, yield: -1),
          ],
        );

        Menu updated = menu.copyWithUpdatedYields(recipes: recipes);
        // Saturday: cook for Sat + Mon (2 within 2-day window)
        expect(updated.meals[0].subMeals.first.cooking?.yield, 2);
        // Monday: leftovers from Saturday (distance = 2 <= 2)
        expect(updated.meals[1].subMeals.first.cooking?.yield, 0);
        // Thursday: new cook (distance from Saturday = 5 > 2), only itself
        expect(updated.meals[2].subMeals.first.cooking?.yield, 1);
      });

      test("maxStorageDays: 0 always yields 1 (same as non-storable)", () {
        Recipe recipe = _recipe(id: "r1", maxStorageDays: 0);
        List<Recipe> recipes = [recipe];
        Menu menu = Menu(
          meals: [
            _meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: recipe, yield: -1),
            _meal(weekDay: WeekDay.sunday, mealType: MealType.lunch, recipe: recipe, yield: -1),
          ],
        );

        Menu updated = menu.copyWithUpdatedYields(recipes: recipes);
        expect(updated.meals[0].subMeals.first.cooking?.yield, 1);
        expect(updated.meals[1].subMeals.first.cooking?.yield, 1);
      });
    });

    group("allIngredients", () {
      test("aggregates ingredients across meals", () {
        Recipe recipe = _recipe(
          id: "r1",
          instructions: [
            Instruction(
              id: "i1",
              description: "step",
              ingredientsUsed: [
                IngredientUsage(
                  ingredient: "flour",
                  quantity: const Quantity(amount: 100, unit: Unit.grams),
                ),
              ],
            ),
          ],
        );
        List<Recipe> recipes = [recipe];
        // One meal with yield 1, 2 people => 100 * 2 = 200g
        Menu menu = Menu(
          meals: [_meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: recipe, yield: 1, people: 2)],
        );

        Map<String, List<Quantity>> ingredients = menu.allIngredients(recipes: recipes);
        expect(ingredients["flour"]!.first.amount, 200.0);
        expect(ingredients["flour"]!.first.unit, Unit.grams);
      });

      test("yield 0 meals contribute 0 ingredients", () {
        Recipe recipe = _recipe(
          id: "r1",
          instructions: [
            Instruction(
              id: "i1",
              description: "step",
              ingredientsUsed: [
                IngredientUsage(
                  ingredient: "flour",
                  quantity: const Quantity(amount: 100, unit: Unit.grams),
                ),
              ],
            ),
          ],
        );
        List<Recipe> recipes = [recipe];
        Menu menu = Menu(
          meals: [_meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: recipe, yield: 0, people: 2)],
        );

        Map<String, List<Quantity>> ingredients = menu.allIngredients(recipes: recipes);
        // yield=0 meals are skipped entirely; the ingredient is absent from the map (no shopping needed).
        expect(ingredients.containsKey("flour"), false);
      });

      test("aggregates people across shared recipe meals for yield > 0", () {
        Recipe recipe = _recipe(
          id: "r1",
          maxStorageDays: 6,
          instructions: [
            Instruction(
              id: "i1",
              description: "step",
              ingredientsUsed: [
                IngredientUsage(
                  ingredient: "flour",
                  quantity: const Quantity(amount: 100, unit: Unit.grams),
                ),
              ],
            ),
          ],
        );
        List<Recipe> recipes = [recipe];
        // First meal: yield > 0, aggregates people from both meals
        // Second meal: yield 0, contributes nothing
        Menu menu = Menu(
          meals: [
            _meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: recipe, yield: 2, people: 2),
            _meal(weekDay: WeekDay.sunday, mealType: MealType.lunch, recipe: recipe, yield: 0, people: 3),
          ],
        );

        Map<String, List<Quantity>> ingredients = menu.allIngredients(recipes: recipes);
        // peopleFactor = 2 + 3 = 5, amount = 100 * 5 = 500
        expect(ingredients["flour"]!.first.amount, 500.0);
      });

      test("non-storable recipe in multiple meal slots is counted once with total peopleFactor", () {
        Recipe recipe = _recipe(
          id: "r1",
          maxStorageDays: 0,
          instructions: [
            Instruction(
              id: "i1",
              description: "step",
              ingredientsUsed: [
                IngredientUsage(
                  ingredient: "bread",
                  quantity: const Quantity(amount: 3, unit: Unit.pieces),
                ),
              ],
            ),
          ],
        );
        List<Recipe> recipes = [recipe];
        // Non-storable recipe appears in two separate meal slots, each with yield=1.
        // allIngredients must count the ingredient once using peopleFactor = 6+6 = 12,
        // not twice (which would give 3*12 + 3*12 = 72 instead of the correct 3*12 = 36).
        Menu menu = Menu(
          meals: [
            _meal(weekDay: WeekDay.saturday, mealType: MealType.breakfast, recipe: recipe, yield: 1, people: 6),
            _meal(weekDay: WeekDay.sunday, mealType: MealType.breakfast, recipe: recipe, yield: 1, people: 6),
          ],
        );

        Map<String, List<Quantity>> ingredients = menu.allIngredients(recipes: recipes);
        // peopleFactor = 6 + 6 = 12, amount = 3 * 12 = 36
        expect(ingredients["bread"]!.first.amount, 36.0);
      });

      test("returns empty map for no meals", () {
        const Menu menu = Menu(meals: []);
        expect(menu.allIngredients(recipes: []), isEmpty);
      });
    });

    group("ingredientSources", () {
      test("returns per-recipe breakdown for a single recipe", () {
        Recipe recipe = _recipe(
          id: "r1",
          name: "Pasta",
          instructions: [
            Instruction(
              id: "i1",
              description: "step",
              ingredientsUsed: [
                IngredientUsage(
                  ingredient: "flour",
                  quantity: const Quantity(amount: 100, unit: Unit.grams),
                ),
              ],
            ),
          ],
        );
        List<Recipe> recipes = [recipe];
        Menu menu = Menu(
          meals: [_meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: recipe, yield: 1, people: 2)],
        );

        Map<String, List<IngredientSource>> sources = menu.ingredientSources(recipes: recipes);
        expect(sources["flour"], hasLength(1));
        expect(sources["flour"]!.first.recipeName, "Pasta");
        expect(sources["flour"]!.first.perServingQuantities.first.amount, 100.0);
        expect(sources["flour"]!.first.perServingQuantities.first.unit, Unit.grams);
        expect(sources["flour"]!.first.servings, 2);
      });

      test("returns multiple sources when two recipes share an ingredient", () {
        Recipe pasta = _recipe(
          id: "r1",
          name: "Pasta",
          instructions: [
            Instruction(
              id: "i1",
              description: "step",
              ingredientsUsed: [
                IngredientUsage(
                  ingredient: "flour",
                  quantity: const Quantity(amount: 100, unit: Unit.grams),
                ),
              ],
            ),
          ],
        );
        Recipe bread = _recipe(
          id: "r2",
          name: "Bread",
          instructions: [
            Instruction(
              id: "i2",
              description: "step",
              ingredientsUsed: [
                IngredientUsage(
                  ingredient: "flour",
                  quantity: const Quantity(amount: 200, unit: Unit.grams),
                ),
              ],
            ),
          ],
        );
        List<Recipe> recipes = [pasta, bread];
        Menu menu = Menu(
          meals: [
            _meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: pasta, yield: 1, people: 2),
            _meal(weekDay: WeekDay.sunday, mealType: MealType.lunch, recipe: bread, yield: 1, people: 3),
          ],
        );

        Map<String, List<IngredientSource>> sources = menu.ingredientSources(recipes: recipes);
        expect(sources["flour"], hasLength(2));

        IngredientSource pastaSource = sources["flour"]!.firstWhere((s) => s.recipeName == "Pasta");
        expect(pastaSource.perServingQuantities.first.amount, 100.0);
        expect(pastaSource.servings, 2);

        IngredientSource breadSource = sources["flour"]!.firstWhere((s) => s.recipeName == "Bread");
        expect(breadSource.perServingQuantities.first.amount, 200.0);
        expect(breadSource.servings, 3);
      });

      test("yield 0 meals do not produce a source entry", () {
        Recipe recipe = _recipe(
          id: "r1",
          name: "Pasta",
          instructions: [
            Instruction(
              id: "i1",
              description: "step",
              ingredientsUsed: [
                IngredientUsage(
                  ingredient: "flour",
                  quantity: const Quantity(amount: 100, unit: Unit.grams),
                ),
              ],
            ),
          ],
        );
        List<Recipe> recipes = [recipe];
        Menu menu = Menu(
          meals: [_meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: recipe, yield: 0, people: 2)],
        );

        Map<String, List<IngredientSource>> sources = menu.ingredientSources(recipes: recipes);
        expect(sources["flour"], isNull);
      });

      test("aggregates people across shared recipe meals", () {
        Recipe recipe = _recipe(
          id: "r1",
          name: "Pasta",
          instructions: [
            Instruction(
              id: "i1",
              description: "step",
              ingredientsUsed: [
                IngredientUsage(
                  ingredient: "flour",
                  quantity: const Quantity(amount: 100, unit: Unit.grams),
                ),
              ],
            ),
          ],
        );
        List<Recipe> recipes = [recipe];
        Menu menu = Menu(
          meals: [
            _meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: recipe, yield: 2, people: 2),
            _meal(weekDay: WeekDay.sunday, mealType: MealType.lunch, recipe: recipe, yield: 0, people: 3),
          ],
        );

        Map<String, List<IngredientSource>> sources = menu.ingredientSources(recipes: recipes);
        expect(sources["flour"], hasLength(1));
        expect(sources["flour"]!.first.recipeName, "Pasta");
        // peopleFactor = 2 + 3 = 5
        expect(sources["flour"]!.first.servings, 5);
        expect(sources["flour"]!.first.perServingQuantities.first.amount, 100.0);
      });

      test("does not double-count per-serving when same recipe has yield > 0 in multiple meals", () {
        Recipe recipe = _recipe(
          id: "r1",
          name: "Toast",
          instructions: [
            Instruction(
              id: "i1",
              description: "step",
              ingredientsUsed: [
                IngredientUsage(
                  ingredient: "bread",
                  quantity: const Quantity(amount: 3, unit: Unit.pieces),
                ),
              ],
            ),
          ],
        );
        List<Recipe> recipes = [recipe];
        // Same recipe assigned to two breakfast slots, both with yield > 0
        Menu menu = Menu(
          meals: [
            _meal(weekDay: WeekDay.saturday, mealType: MealType.breakfast, recipe: recipe, yield: 1, people: 2),
            _meal(weekDay: WeekDay.sunday, mealType: MealType.breakfast, recipe: recipe, yield: 1, people: 2),
          ],
        );

        Map<String, List<IngredientSource>> sources = menu.ingredientSources(recipes: recipes);
        expect(sources["bread"], hasLength(1));
        // Per-serving should stay 3 (not 6)
        expect(sources["bread"]!.first.perServingQuantities.first.amount, 3.0);
        // peopleFactor = 2 + 2 = 4
        expect(sources["bread"]!.first.servings, 4);
      });

      test("returns empty map for no meals", () {
        const Menu menu = Menu(meals: []);
        expect(menu.ingredientSources(recipes: []), isEmpty);
      });
    });

    // Parity tests pinning the shared selection/dedup/people-summing behavior of allIngredients and
    // ingredientSources on a single mixed menu, so both methods stay in lock-step (Plan 005).
    group("allIngredients / ingredientSources parity", () {
      // Recipe A: storable, used in 3 sub-meals (first yield 3, then two leftovers yield 0).
      // Recipe B: non-storable, used in 2 sub-meals (both yield 1).
      // Plus one sub-meal with cooking == null and one referencing a recipe missing from the list.
      Recipe recipeA = _recipe(
        id: "A",
        name: "RecipeA",
        maxStorageDays: 6,
        instructions: [
          Instruction(
            id: "iA",
            description: "step",
            ingredientsUsed: [
              IngredientUsage(
                ingredient: "flour",
                quantity: const Quantity(amount: 100, unit: Unit.grams),
              ),
            ],
          ),
        ],
      );
      Recipe recipeB = _recipe(
        id: "B",
        name: "RecipeB",
        maxStorageDays: 0,
        instructions: [
          Instruction(
            id: "iB",
            description: "step",
            ingredientsUsed: [
              IngredientUsage(
                ingredient: "bread",
                quantity: const Quantity(amount: 3, unit: Unit.pieces),
              ),
            ],
          ),
        ],
      );
      List<Recipe> recipes = [recipeA, recipeB];
      Menu menu = Menu(
        meals: [
          // Recipe A: cook event + two leftovers. peopleFactor A = 2 + 4 + 1 = 7.
          _meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: recipeA, yield: 3, people: 2),
          _meal(weekDay: WeekDay.sunday, mealType: MealType.lunch, recipe: recipeA, yield: 0, people: 4),
          _meal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipe: recipeA, yield: 0, people: 1),
          // Recipe B: non-storable in two slots. peopleFactor B = 5 + 6 = 11.
          _meal(weekDay: WeekDay.saturday, mealType: MealType.dinner, recipe: recipeB, yield: 1, people: 5),
          _meal(weekDay: WeekDay.sunday, mealType: MealType.dinner, recipe: recipeB, yield: 1, people: 6),
          // Empty sub-meal (no cooking).
          _meal(weekDay: WeekDay.monday, mealType: MealType.dinner, recipe: null, people: 2),
          // Sub-meal referencing a recipe absent from the list.
          Meal(
            mealTime: const MealTime(weekDay: WeekDay.tuesday, mealType: MealType.lunch),
            subMeals: const [SubMeal(cooking: Cooking(recipeId: "MISSING", yield: 1), people: 3)],
          ),
        ],
      );

      test("allIngredients uses the people sum over all of each recipe's sub-meals", () {
        Map<String, List<Quantity>> ingredients = menu.allIngredients(recipes: recipes);
        // Recipe A counted once: 100 * (2 + 4 + 1) = 700.
        expect(ingredients["flour"]!.first.amount, 700.0);
        // Recipe B counted once: 3 * (5 + 6) = 33.
        expect(ingredients["bread"]!.first.amount, 33.0);
        // The missing recipe contributes nothing and does not crash.
        expect(ingredients.keys.toSet(), {"flour", "bread"});
      });

      test("ingredientSources yields one entry per recipe with matching servings", () {
        Map<String, List<IngredientSource>> sources = menu.ingredientSources(recipes: recipes);
        expect(sources["flour"], hasLength(1));
        expect(sources["flour"]!.first.recipeName, "RecipeA");
        expect(sources["flour"]!.first.servings, 7);
        expect(sources["bread"], hasLength(1));
        expect(sources["bread"]!.first.recipeName, "RecipeB");
        expect(sources["bread"]!.first.servings, 11);
      });

      test("both methods expose the same set of ingredient IDs", () {
        Set<String> fromAll = menu.allIngredients(recipes: recipes).keys.toSet();
        Set<String> fromSources = menu.ingredientSources(recipes: recipes).keys.toSet();
        expect(fromAll, fromSources);
      });
    });

    group("toStringBeautified", () {
      test("contains all weekday names", () {
        Recipe recipe = _recipe(name: "Pasta");
        List<Recipe> recipes = [recipe];
        Menu menu = Menu(
          meals: [_meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: recipe)],
        );
        String output = menu.toStringBeautified(
          recipes: recipes,
          dayLabels: _dayLabels(),
          cookServings: _cookServings(menu, recipes: [recipe]),
        );
        expect(output.contains("Saturday"), true);
        expect(output.contains("Sunday"), true);
        expect(output.contains("Friday"), true);
      });

      test("uses the labels that the caller gives", () {
        Recipe recipe = _recipe(name: "Pasta");
        Menu menu = Menu(
          meals: [_meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: recipe)],
        );
        String output = menu.toStringBeautified(
          recipes: [recipe],
          dayLabels: _dayLabels(startDate: DateTime(2025, 8, 6)),
          cookServings: _cookServings(menu, recipes: [recipe]),
        );
        expect(output.contains("Wednesday 6 Aug"), true);
      });

      test("throws when a day has no label", () {
        // A partial map is a mistake of the caller. The method must stop there, not print
        // the text "null" into the clipboard of the user.
        Recipe recipe = _recipe(name: "Pasta");
        Menu menu = Menu(
          meals: [_meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: recipe)],
        );
        Map<WeekDay, String> partialLabels = <WeekDay, String>{WeekDay.saturday: "Saturday"};

        expect(
          () => menu.toStringBeautified(
            recipes: [recipe],
            dayLabels: partialLabels,
            cookServings: _cookServings(menu, recipes: [recipe]),
          ),
          throwsA(isA<TypeError>()),
        );
      });

      test("throws when a cook event has no servings", () {
        // Same rule as the day labels: a partial map is a mistake of the caller.
        Recipe recipe = _recipe(name: "Pasta");
        Menu menu = Menu(
          meals: [_meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: recipe)],
        );

        expect(() => menu.toStringBeautified(recipes: [recipe], dayLabels: _dayLabels(), cookServings: const {}), throwsA(isA<TypeError>()));
      });

      test("shows a dash in all 21 slots of a menu without meals", () {
        const Menu menu = Menu(meals: []);

        String output = menu.toStringBeautified(recipes: [], dayLabels: _dayLabels(), cookServings: const {});

        List<String> mealLines = output.split("\n").where((String line) => line.startsWith("  ")).toList();
        expect(mealLines.length, 21);
        expect(mealLines.toSet(), {"  Breakfast: -", "  Lunch: -", "  Dinner: -"});
      });

      test("names a deleted recipe with a dash and still promises the servings", () {
        // ADR 0016 allows a menu that still points at a deleted recipe. The text must not hide
        // the cook event, because the user has to see which meal lost its dish.
        Menu menu = const Menu(
          meals: [
            Meal(
              mealTime: MealTime(weekDay: WeekDay.saturday, mealType: MealType.lunch),
              subMeals: [SubMeal(cooking: Cooking(recipeId: "deleted", yield: 2), people: 2)],
            ),
          ],
        );

        String output = menu.toStringBeautified(
          recipes: const [],
          dayLabels: _dayLabels(),
          cookServings: {(const MealTime(weekDay: WeekDay.saturday, mealType: MealType.lunch), 0): 4},
        );

        expect(output.contains("Lunch: - [2p] (cook 4 servings)"), true);
      });

      test("keeps the people count of a sub-meal without a recipe in a shared slot", () {
        // A slot where two people have nothing to eat is exactly the gap the text must surface.
        Recipe recipe = _recipe(name: "Pasta");
        Menu menu = const Menu(
          meals: [
            Meal(
              mealTime: MealTime(weekDay: WeekDay.saturday, mealType: MealType.lunch),
              subMeals: [
                SubMeal(cooking: Cooking(recipeId: "r1", yield: 1), people: 3),
                SubMeal(people: 2),
              ],
            ),
          ],
        );

        String output = menu.toStringBeautified(
          recipes: [recipe],
          dayLabels: _dayLabels(),
          cookServings: {(const MealTime(weekDay: WeekDay.saturday, mealType: MealType.lunch), 0): 3},
        );

        expect(output.contains("1. Pasta [3p] (cook 3 servings)"), true);
        expect(output.contains("2. - [2p]"), true);
      });

      test("writes only a dash for a slot that holds one sub-meal without a recipe", () {
        Menu menu = const Menu(
          meals: [
            Meal(
              mealTime: MealTime(weekDay: WeekDay.saturday, mealType: MealType.lunch),
              subMeals: [SubMeal(people: 2)],
            ),
          ],
        );

        String output = menu.toStringBeautified(recipes: const [], dayLabels: _dayLabels(), cookServings: const {});

        expect(output.contains("Lunch: -\n"), true);
        expect(output.contains("Lunch: - ["), false);
      });

      test("says the meal is cooked and how many servings it makes", () {
        // The servings come from the caller, which counts the leftover meals the cook event feeds.
        Recipe recipe = _recipe(name: "Pasta");
        Menu menu = Menu(
          meals: [_meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: recipe, yield: 2, people: 3)],
        );
        String output = menu.toStringBeautified(
          recipes: [recipe],
          dayLabels: _dayLabels(),
          cookServings: {(const MealTime(weekDay: WeekDay.saturday, mealType: MealType.lunch), 0): 6},
        );

        expect(output.contains("Lunch: Pasta [3p] (cook 6 servings)"), true);
      });

      test("writes one serving in the singular", () {
        Recipe recipe = _recipe(name: "Pasta");
        Menu menu = Menu(
          meals: [_meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: recipe, people: 1)],
        );
        String output = menu.toStringBeautified(
          recipes: [recipe],
          dayLabels: _dayLabels(),
          cookServings: {(const MealTime(weekDay: WeekDay.saturday, mealType: MealType.lunch), 0): 1},
        );

        expect(output.contains("(cook 1 serving)"), true);
      });

      test("says the meal eats leftovers instead of printing zero servings", () {
        Recipe recipe = _recipe(name: "Pasta");
        Menu menu = Menu(
          meals: [_meal(weekDay: WeekDay.sunday, mealType: MealType.dinner, recipe: recipe, yield: 0, people: 2)],
        );
        String output = menu.toStringBeautified(recipes: [recipe], dayLabels: _dayLabels(), cookServings: const {});

        expect(output.contains("Dinner: Pasta [2p] (leftovers)"), true);
        expect(output.contains("0 pp"), false);
      });

      test("shows the people count of a slot that holds a single sub-meal", () {
        // The old text showed the people count only for slots with two or more sub-meals.
        Recipe recipe = _recipe(name: "Pasta");
        Menu menu = Menu(
          meals: [_meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: recipe, people: 4)],
        );
        String output = menu.toStringBeautified(
          recipes: [recipe],
          dayLabels: _dayLabels(),
          cookServings: _cookServings(menu, recipes: [recipe]),
        );

        expect(output.contains("[4p]"), true);
      });

      test("shows the people count and the cook wording of every sub-meal of a shared slot", () {
        Recipe pasta = _recipe(id: "r1", name: "Pasta");
        Recipe salad = _recipe(id: "r2", name: "Salad");
        Menu menu = Menu(
          meals: [
            const Meal(
              mealTime: MealTime(weekDay: WeekDay.saturday, mealType: MealType.lunch),
              subMeals: [
                SubMeal(cooking: Cooking(recipeId: "r1", yield: 1), people: 2),
                SubMeal(cooking: Cooking(recipeId: "r2", yield: 0), people: 1),
              ],
            ),
          ],
        );
        String output = menu.toStringBeautified(
          recipes: [pasta, salad],
          dayLabels: _dayLabels(),
          cookServings: {(const MealTime(weekDay: WeekDay.saturday, mealType: MealType.lunch), 0): 2},
        );

        expect(output.contains("1. Pasta [2p] (cook 2 servings)"), true);
        expect(output.contains("2. Salad [1p] (leftovers)"), true);
      });
    });
  });

  // ── Cooking ──

  group("Cooking", () {
    test("holds recipeId and yield", () {
      Cooking cooking = const Cooking(recipeId: "r1", yield: 3);
      expect(cooking.recipeId, "r1");
      expect(cooking.yield, 3);
    });

    test("equality by value", () {
      Cooking a = const Cooking(recipeId: "r1", yield: 1);
      Cooking b = const Cooking(recipeId: "r1", yield: 1);
      expect(a, b);
    });
  });

  // ── JSON serialization round-trips ──

  group("JSON serialization", () {
    test("MealTime round-trips through JSON", () {
      const MealTime original = MealTime(weekDay: WeekDay.wednesday, mealType: MealType.dinner);
      MealTime restored = MealTime.fromJson(original.toJson());
      expect(restored, original);
    });

    test("MenuConfiguration round-trips through JSON encode/decode", () {
      const MenuConfiguration original = MenuConfiguration(
        mealTime: MealTime(weekDay: WeekDay.friday, mealType: MealType.breakfast),
        requiresMeal: false,
        availableCookingTimeMinutes: 30,
      );
      String encoded = jsonEncode(original.toJson());
      MenuConfiguration restored = MenuConfiguration.fromJson(jsonDecode(encoded));
      expect(restored, original);
    });

    test("Meal round-trips through JSON encode/decode", () {
      Recipe recipe = _recipe();
      Meal original = _meal(recipe: recipe, people: 4);
      String encoded = jsonEncode(original.toJson());
      Meal restored = Meal.fromJson(jsonDecode(encoded));
      expect(restored.subMeals.first.people, 4);
      expect(restored.subMeals.first.cooking?.recipeId, "r1");
    });

    test("Menu round-trips through JSON encode/decode", () {
      Recipe recipe = _recipe();
      Menu original = Menu(meals: [_meal(recipe: recipe)]);
      String encoded = jsonEncode(original.toJson());
      Menu restored = Menu.fromJson(jsonDecode(encoded));
      expect(restored.meals.length, 1);
      expect(restored.meals.first.subMeals.first.cooking?.recipeId, "r1");
    });

    test("Meal.fromJson migrates old format (cooking + people) to subMeals", () {
      Map<String, dynamic> oldFormat = {
        "mealTime": {"weekDay": "saturday", "mealType": "lunch"},
        "cooking": {"recipeId": "r1", "yield": 2},
        "people": 3,
      };
      Meal restored = Meal.fromJson(oldFormat);
      expect(restored.subMeals.length, 1);
      expect(restored.subMeals.first.cooking?.recipeId, "r1");
      expect(restored.subMeals.first.cooking?.yield, 2);
      expect(restored.subMeals.first.people, 3);
    });

    test("SubMeal round-trips through JSON encode/decode", () {
      SubMeal original = const SubMeal(cooking: Cooking(recipeId: "r1", yield: 2), people: 3);
      String encoded = jsonEncode(original.toJson());
      SubMeal restored = SubMeal.fromJson(jsonDecode(encoded));
      expect(restored.cooking?.recipeId, "r1");
      expect(restored.cooking?.yield, 2);
      expect(restored.people, 3);
    });
  });
}
