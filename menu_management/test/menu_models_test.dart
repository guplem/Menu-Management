import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:menu_management/menu/enums/meal_type.dart";
import "package:menu_management/menu/enums/week_day.dart";
import "package:menu_management/menu/models/cooking.dart";
import "package:menu_management/menu/models/meal.dart";
import "package:menu_management/menu/models/meal_time.dart";
import "package:menu_management/menu/models/menu.dart";
import "package:menu_management/menu/models/menu_configuration.dart";
import "package:menu_management/recipes/enums/unit.dart";
import "package:menu_management/recipes/models/ingredient_usage.dart";
import "package:menu_management/recipes/models/instruction.dart";
import "package:menu_management/recipes/models/quantity.dart";
import "package:menu_management/recipes/models/recipe.dart";
import "package:menu_management/shopping/ingredient_source.dart";

// ── Test helpers ──

Recipe _recipe({String id = "r1", String name = "Test Recipe", List<Instruction> instructions = const [], bool canBeStored = true}) {
  return Recipe(id: id, name: name, instructions: instructions, canBeStored: canBeStored);
}

Meal _meal({WeekDay weekDay = WeekDay.saturday, MealType mealType = MealType.lunch, Recipe? recipe, int yield = 1, int people = 2}) {
  return Meal(
    mealTime: MealTime(weekDay: weekDay, mealType: mealType),
    cooking: recipe != null ? Cooking(recipeId: recipe.id, yield: yield) : null,
    people: people,
  );
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
    test("defaults to 2 people", () {
      Meal meal = _meal();
      expect(meal.people, 2);
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

    test("copyWithUpdatedCooking replaces cooking", () {
      Recipe recipe = _recipe();
      Meal meal = _meal();
      Cooking newCooking = Cooking(recipeId: recipe.id, yield: 3);
      Meal updated = meal.copyWithUpdatedCooking(newCooking);
      expect(updated.cooking?.yield, 3);
      expect(updated.cooking?.recipeId, recipe.id);
    });

    test("copyWithUpdatedCooking can set cooking to null", () {
      Recipe recipe = _recipe();
      Meal meal = _meal(recipe: recipe);
      Meal updated = meal.copyWithUpdatedCooking(null);
      expect(updated.cooking, null);
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
        MealTime time = const MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch);
        Menu menu = Menu(
          meals: [_meal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipe: _recipe(), people: 2)],
        );
        Menu updated = menu.copyWithUpdatedPeople(mealTime: time, people: 4);
        expect(updated.meals.first.people, 4);
      });

      test("does not change other meals", () {
        Recipe recipe = _recipe();
        Menu menu = Menu(
          meals: [
            _meal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipe: recipe, people: 2),
            _meal(weekDay: WeekDay.monday, mealType: MealType.dinner, recipe: recipe, people: 3),
          ],
        );
        MealTime lunchTime = const MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch);
        Menu updated = menu.copyWithUpdatedPeople(mealTime: lunchTime, people: 5);
        expect(updated.meals[0].people, 5);
        expect(updated.meals[1].people, 3); // unchanged
      });
    });

    group("copyWithClearedMeal", () {
      test("sets cooking to null for the specified meal time", () {
        Recipe recipe = _recipe(id: "r1");
        List<Recipe> recipes = [recipe];
        MealTime time = const MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch);
        Menu menu = Menu(
          meals: [_meal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipe: recipe)],
        );

        Menu updated = menu.copyWithClearedMeal(mealTime: time, recipes: recipes);
        expect(updated.meals.first.cooking, isNull);
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

        Menu updated = menu.copyWithClearedMeal(mealTime: lunchTime, recipes: recipes);
        expect(updated.meals.firstWhere((m) => m.mealTime.mealType == MealType.lunch).cooking, isNull);
        expect(updated.meals.firstWhere((m) => m.mealTime.mealType == MealType.dinner).cooking, isNotNull);
      });

      test("recalculates yields after clearing a shared recipe", () {
        Recipe recipe = _recipe(id: "r1", canBeStored: true);
        List<Recipe> recipes = [recipe];
        // Two meals share the same storable recipe
        Menu menu = Menu(
          meals: [
            _meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: recipe, yield: 2),
            _meal(weekDay: WeekDay.sunday, mealType: MealType.lunch, recipe: recipe, yield: 0),
          ],
        );
        MealTime satLunch = const MealTime(weekDay: WeekDay.saturday, mealType: MealType.lunch);

        Menu updated = menu.copyWithClearedMeal(mealTime: satLunch, recipes: recipes);
        // Saturday lunch cleared
        expect(updated.meals.firstWhere((m) => m.mealTime.isSameTime(satLunch)).cooking, isNull);
        // Sunday lunch is now the sole user of the recipe, yield should be 1
        MealTime sunLunch = const MealTime(weekDay: WeekDay.sunday, mealType: MealType.lunch);
        expect(updated.meals.firstWhere((m) => m.mealTime.isSameTime(sunLunch)).cooking?.yield, 1);
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

        Menu updated = menu.copyWithUpdatedRecipe(mealTime: time, recipe: replacement, recipes: recipes);
        expect(updated.meals.first.cooking?.recipeId, "r2");
      });

      test("returns same menu if recipe is already set", () {
        Recipe recipe = _recipe(id: "r1", name: "Pasta");
        List<Recipe> recipes = [recipe];
        MealTime time = const MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch);
        Menu menu = Menu(
          meals: [_meal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipe: recipe)],
        );

        Menu updated = menu.copyWithUpdatedRecipe(mealTime: time, recipe: recipe, recipes: recipes);
        expect(identical(updated, menu), true);
      });
    });

    group("copyWithUpdatedYields", () {
      test("first occurrence of storable recipe gets full yield count", () {
        Recipe recipe = _recipe(id: "r1", canBeStored: true);
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
        expect(updated.meals[0].cooking?.yield, 3);
        // Later occurrences: yield = 0 (use leftovers)
        expect(updated.meals[1].cooking?.yield, 0);
        expect(updated.meals[2].cooking?.yield, 0);
      });

      test("non-storable recipe always gets yield 1", () {
        Recipe recipe = _recipe(id: "r1", canBeStored: false);
        List<Recipe> recipes = [recipe];
        Menu menu = Menu(
          meals: [
            _meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: recipe, yield: -1),
            _meal(weekDay: WeekDay.sunday, mealType: MealType.lunch, recipe: recipe, yield: -1),
          ],
        );

        Menu updated = menu.copyWithUpdatedYields(recipes: recipes);
        expect(updated.meals[0].cooking?.yield, 1);
        expect(updated.meals[1].cooking?.yield, 1);
      });

      test("null cooking meals are preserved", () {
        Menu menu = Menu(
          meals: [_meal(weekDay: WeekDay.saturday, mealType: MealType.lunch)],
        );
        Menu updated = menu.copyWithUpdatedYields(recipes: []);
        expect(updated.meals.first.cooking, null);
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
          canBeStored: true,
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
          canBeStored: false,
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
                IngredientUsage(ingredient: "flour", quantity: const Quantity(amount: 100, unit: Unit.grams)),
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
                IngredientUsage(ingredient: "flour", quantity: const Quantity(amount: 100, unit: Unit.grams)),
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
                IngredientUsage(ingredient: "flour", quantity: const Quantity(amount: 200, unit: Unit.grams)),
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
                IngredientUsage(ingredient: "flour", quantity: const Quantity(amount: 100, unit: Unit.grams)),
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
                IngredientUsage(ingredient: "flour", quantity: const Quantity(amount: 100, unit: Unit.grams)),
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
                IngredientUsage(ingredient: "bread", quantity: const Quantity(amount: 3, unit: Unit.pieces)),
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

    group("toStringBeautified", () {
      test("contains all weekday names", () {
        Recipe recipe = _recipe(name: "Pasta");
        List<Recipe> recipes = [recipe];
        Menu menu = Menu(
          meals: [_meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: recipe)],
        );
        String output = menu.toStringBeautified(recipes: recipes);
        expect(output.contains("Saturday"), true);
        expect(output.contains("Sunday"), true);
        expect(output.contains("Friday"), true);
      });

      test("shows dash for missing meals", () {
        const Menu menu = Menu(meals: []);
        String output = menu.toStringBeautified(recipes: []);
        expect(output.contains("-"), true);
      });

      test("shows recipe name and yield for assigned meals", () {
        Recipe recipe = _recipe(name: "Pasta");
        List<Recipe> recipes = [recipe];
        Menu menu = Menu(
          meals: [_meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: recipe, yield: 2)],
        );
        String output = menu.toStringBeautified(recipes: recipes);
        expect(output.contains("Pasta"), true);
        expect(output.contains("2 pp"), true);
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
      expect(restored.people, 4);
      expect(restored.cooking?.recipeId, "r1");
    });

    test("Menu round-trips through JSON encode/decode", () {
      Recipe recipe = _recipe();
      Menu original = Menu(meals: [_meal(recipe: recipe)]);
      String encoded = jsonEncode(original.toJson());
      Menu restored = Menu.fromJson(jsonDecode(encoded));
      expect(restored.meals.length, 1);
      expect(restored.meals.first.cooking?.recipeId, "r1");
    });
  });
}
