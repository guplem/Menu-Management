import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:menu_management/menu/enums/meal_type.dart";
import "package:menu_management/menu/enums/week_day.dart";
import "package:menu_management/menu/models/cooking.dart";
import "package:menu_management/menu/models/meal.dart";
import "package:menu_management/menu/models/meal_time.dart";
import "package:menu_management/menu/models/menu.dart";
import "package:menu_management/menu/models/multi_week_menu.dart";
import "package:menu_management/recipes/models/ingredient_usage.dart";
import "package:menu_management/recipes/models/instruction.dart";
import "package:menu_management/recipes/models/quantity.dart";
import "package:menu_management/recipes/models/recipe.dart";
import "package:menu_management/recipes/enums/unit.dart";

/// Helper to create a minimal recipe for testing
Recipe _testRecipe({required String id, required String name, List<Instruction> instructions = const []}) {
  return Recipe(id: id, name: name, instructions: instructions);
}

/// Helper to create a meal at a specific time with an optional recipe
Meal _testMeal({required WeekDay weekDay, required MealType mealType, Recipe? recipe, int yield = 1}) {
  return Meal(
    mealTime: MealTime(weekDay: weekDay, mealType: mealType),
    cooking: recipe != null ? Cooking(recipeId: recipe.id, yield: yield) : null,
  );
}

/// Helper to create a simple one-meal Menu for testing
Menu _singleMealMenu({required Recipe recipe, WeekDay weekDay = WeekDay.saturday, MealType mealType = MealType.lunch}) {
  return Menu(
    meals: [_testMeal(weekDay: weekDay, mealType: mealType, recipe: recipe)],
  );
}

void main() {
  group("MultiWeekMenu construction", () {
    test("can be created with a single week", () {
      final Menu week1 = Menu(meals: []);
      final MultiWeekMenu multiWeek = MultiWeekMenu(weeks: [week1]);

      expect(multiWeek.weeks.length, 1);
      expect(multiWeek.weeks.first, week1);
    });

    test("weekCount returns the number of weeks", () {
      final Menu week1 = Menu(meals: []);
      final Menu week2 = Menu(meals: []);
      final MultiWeekMenu multiWeek = MultiWeekMenu(weeks: [week1, week2]);

      expect(multiWeek.weekCount, 2);
    });

    test("validated factory throws on zero weeks", () {
      expect(() => MultiWeekMenu.validated(weeks: []), throwsArgumentError);
    });
  });

  group("MultiWeekMenu addWeek", () {
    test("adds a week and returns a new MultiWeekMenu", () {
      final Menu week1 = Menu(meals: []);
      final Menu week2 = Menu(meals: []);
      final MultiWeekMenu original = MultiWeekMenu(weeks: [week1]);

      final MultiWeekMenu updated = original.addWeek(week2);

      expect(updated.weekCount, 2);
      expect(updated.weeks[0], week1);
      expect(updated.weeks[1], week2);
      // Original is unchanged (immutability)
      expect(original.weekCount, 1);
    });
  });

  group("MultiWeekMenu removeLastWeek", () {
    test("removes the last week and returns a new MultiWeekMenu", () {
      final Menu week1 = Menu(meals: []);
      final Menu week2 = Menu(meals: []);
      final MultiWeekMenu original = MultiWeekMenu(weeks: [week1, week2]);

      final MultiWeekMenu updated = original.removeLastWeek();

      expect(updated.weekCount, 1);
      expect(updated.weeks.first, week1);
      // Original is unchanged
      expect(original.weekCount, 2);
    });

    test("does not remove below one week", () {
      final Menu week1 = Menu(meals: []);
      final MultiWeekMenu singleWeek = MultiWeekMenu(weeks: [week1]);

      final MultiWeekMenu result = singleWeek.removeLastWeek();

      expect(result.weekCount, 1);
      expect(result.weeks.first, week1);
    });
  });

  group("MultiWeekMenu updateWeekAt", () {
    test("replaces a week at the given index", () {
      final Menu week1 = Menu(meals: []);
      final Recipe recipe = _testRecipe(id: "r1", name: "Pasta");
      final Menu updatedWeek1 = _singleMealMenu(recipe: recipe);
      final MultiWeekMenu original = MultiWeekMenu(weeks: [week1]);

      final MultiWeekMenu updated = original.updateWeekAt(0, updatedWeek1);

      expect(updated.weeks[0].meals.length, 1);
      expect(updated.weeks[0].meals.first.cooking?.recipeId, "r1");
      // Original unchanged
      expect(original.weeks[0].meals.length, 0);
    });
  });

  group("MultiWeekMenu allIngredients aggregation", () {
    test("aggregates ingredients across multiple weeks", () {
      final Recipe pastaRecipe = _testRecipe(
        id: "r1",
        name: "Pasta",
        instructions: [
          Instruction(
            id: "i1",
            description: "Cook pasta",
            ingredientsUsed: [
              IngredientUsage(
                ingredient: "flour",
                quantity: const Quantity(amount: 200, unit: Unit.grams),
              ),
            ],
          ),
        ],
      );
      List<Recipe> recipes = [pastaRecipe];

      final Menu week1 = Menu(
        meals: [_testMeal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: pastaRecipe)],
      );
      final Menu week2 = Menu(
        meals: [_testMeal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: pastaRecipe)],
      );

      final MultiWeekMenu multiWeek = MultiWeekMenu(weeks: [week1, week2]);
      final Map<String, List<Quantity>> allIngredients = multiWeek.allIngredients(recipes: recipes);

      // flour: 200g * 2 people * week1 + 200g * 2 people * week2 = 800g
      expect(allIngredients.containsKey("flour"), true);
      final double totalFlour = allIngredients["flour"]!.where((q) => q.unit == Unit.grams).fold(0.0, (sum, q) => sum + q.amount);
      expect(totalFlour, 800.0);
    });

    test("returns empty map when no weeks have ingredients", () {
      final MultiWeekMenu multiWeek = MultiWeekMenu(weeks: [const Menu(), const Menu()]);
      expect(multiWeek.allIngredients(recipes: []), isEmpty);
    });
  });

  group("MultiWeekMenu toStringBeautified", () {
    test("labels each week in the output", () {
      final Recipe recipe = _testRecipe(id: "r1", name: "Pasta");
      List<Recipe> recipes = [recipe];
      final Menu week1 = _singleMealMenu(recipe: recipe);
      final Menu week2 = _singleMealMenu(recipe: recipe);
      final MultiWeekMenu multiWeek = MultiWeekMenu(weeks: [week1, week2]);

      final String output = multiWeek.toStringBeautified(recipes: recipes);

      expect(output.contains("Week 1"), true);
      expect(output.contains("Week 2"), true);
    });
  });

  group("MultiWeekMenu backward-compatible JSON loading", () {
    test("loads new multi-week format with weeks key", () {
      final Recipe recipe = _testRecipe(id: "r1", name: "Pasta");
      final Menu week1 = _singleMealMenu(recipe: recipe);
      final MultiWeekMenu original = MultiWeekMenu(weeks: [week1]);

      String encoded = jsonEncode(original.toJson());
      Map<String, dynamic> json = jsonDecode(encoded);

      expect(json.containsKey("weeks"), true);
      final MultiWeekMenu restored = MultiWeekMenu.fromJson(json);
      expect(restored.weekCount, 1);
      expect(restored.weeks.first.meals.first.cooking?.recipeId, "r1");
    });

    test("old single-week Menu JSON lacks weeks key", () {
      final Recipe recipe = _testRecipe(id: "r1", name: "Pasta");
      final Menu singleWeek = _singleMealMenu(recipe: recipe);

      String encoded = jsonEncode(singleWeek.toJson());
      Map<String, dynamic> json = jsonDecode(encoded);

      // Old format has "meals" at top level, no "weeks"
      expect(json.containsKey("weeks"), false);
      expect(json.containsKey("meals"), true);

      // Simulate backward-compatible load logic from Persistency.loadMultiWeekMenu
      MultiWeekMenu loaded;
      if (json.containsKey("weeks")) {
        loaded = MultiWeekMenu.fromJson(json);
      } else {
        Menu menu = Menu.fromJson(json);
        loaded = MultiWeekMenu.validated(weeks: [menu]);
      }

      expect(loaded.weekCount, 1);
      expect(loaded.weeks.first.meals.first.cooking?.recipeId, "r1");
    });
  });
}
