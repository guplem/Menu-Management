import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:menu_management/menu/enums/meal_type.dart";
import "package:menu_management/menu/enums/menu_copy_format.dart";
import "package:menu_management/menu/enums/week_day.dart";
import "package:menu_management/menu/models/cooking.dart";
import "package:menu_management/menu/models/meal.dart";
import "package:menu_management/menu/models/meal_time.dart";
import "package:menu_management/menu/models/menu.dart";
import "package:menu_management/menu/models/multi_week_menu.dart";
import "package:menu_management/menu/models/sub_meal.dart";
import "package:menu_management/recipes/models/ingredient_usage.dart";
import "package:menu_management/recipes/models/instruction.dart";
import "package:menu_management/recipes/models/quantity.dart";
import "package:menu_management/recipes/enums/unit.dart";
import "package:menu_management/recipes/models/recipe.dart";
import "package:menu_management/shopping/ingredient_meal_requirement.dart";
import "package:menu_management/shopping/ingredient_source.dart";

/// Helper to create a minimal recipe for testing
Recipe _testRecipe({required String id, required String name, List<Instruction> instructions = const []}) {
  return Recipe(id: id, name: name, instructions: instructions);
}

/// Helper to create a meal at a specific time with an optional recipe
Meal _testMeal({required WeekDay weekDay, required MealType mealType, Recipe? recipe, int yield = 1, int people = 2}) {
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
      expect(updated.weeks[0].meals.first.subMeals.first.cooking?.recipeId, "r1");
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

  group("MultiWeekMenu ingredientSources", () {
    test("combines sources from multiple weeks", () {
      Instruction flourInstruction = Instruction(
        id: "i1",
        description: "step",
        ingredientsUsed: [
          IngredientUsage(
            ingredient: "flour",
            quantity: const Quantity(amount: 200, unit: Unit.grams),
          ),
        ],
      );
      Recipe pastaRecipe = _testRecipe(id: "r1", name: "Pasta", instructions: [flourInstruction]);
      Recipe breadRecipe = _testRecipe(id: "r2", name: "Bread", instructions: [flourInstruction]);
      List<Recipe> recipes = [pastaRecipe, breadRecipe];

      Menu week1 = Menu(
        meals: [_testMeal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: pastaRecipe)],
      );
      Menu week2 = Menu(
        meals: [_testMeal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: breadRecipe)],
      );

      MultiWeekMenu multiWeek = MultiWeekMenu(weeks: [week1, week2]);
      Map<String, List<IngredientSource>> sources = multiWeek.ingredientSources(recipes: recipes);

      expect(sources["flour"], hasLength(2));
      expect(sources["flour"]!.any((s) => s.recipeName == "Pasta"), true);
      expect(sources["flour"]!.any((s) => s.recipeName == "Bread"), true);
    });

    test("same recipe across weeks is merged into one entry with summed servings", () {
      Instruction flourInstruction = Instruction(
        id: "i1",
        description: "step",
        ingredientsUsed: [
          IngredientUsage(
            ingredient: "flour",
            quantity: const Quantity(amount: 100, unit: Unit.grams),
          ),
        ],
      );
      Recipe recipe = _testRecipe(id: "r1", name: "Pasta", instructions: [flourInstruction]);
      List<Recipe> recipes = [recipe];

      // Default people = 2 per meal
      Menu week1 = Menu(
        meals: [_testMeal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: recipe)],
      );
      Menu week2 = Menu(
        meals: [_testMeal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: recipe)],
      );

      MultiWeekMenu multiWeek = MultiWeekMenu(weeks: [week1, week2]);
      Map<String, List<IngredientSource>> sources = multiWeek.ingredientSources(recipes: recipes);

      // Same recipe in two weeks = one merged entry with combined servings
      expect(sources["flour"], hasLength(1));
      expect(sources["flour"]!.first.recipeName, "Pasta");
      expect(sources["flour"]!.first.servings, 4); // 2 per week * 2 weeks
      expect(sources["flour"]!.first.perServingQuantities.first.amount, 100.0);
    });

    test("returns empty map when no weeks have ingredients", () {
      MultiWeekMenu multiWeek = MultiWeekMenu(weeks: [const Menu(), const Menu()]);
      expect(multiWeek.ingredientSources(recipes: []), isEmpty);
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

    test("names the days by the WeekDay enum when the menu has no start date", () {
      final Recipe recipe = _testRecipe(id: "r1", name: "Pasta");
      final MultiWeekMenu multiWeek = MultiWeekMenu(weeks: [_singleMealMenu(recipe: recipe)]);

      final String output = multiWeek.toStringBeautified(recipes: [recipe]);

      expect(output.contains("Saturday"), true);
      expect(output.contains("Aug"), false);
    });

    test("gives every day its real date when the menu has a start date", () {
      // 2025-08-06 is a Wednesday, so menu day 0 is Wednesday 6 Aug.
      final Recipe recipe = _testRecipe(id: "r1", name: "Pasta");
      final MultiWeekMenu multiWeek = MultiWeekMenu(
        startDate: DateTime(2025, 8, 6),
        weeks: [
          _singleMealMenu(recipe: recipe),
          _singleMealMenu(recipe: recipe),
        ],
      );

      final String output = multiWeek.toStringBeautified(recipes: [recipe]);

      expect(output.contains("Wednesday 6 Aug"), true);
      expect(output.contains("Tuesday 12 Aug"), true);
      expect(output.contains("Wednesday 13 Aug"), true);
      // The date-less name must not survive next to the dated one.
      expect(output.contains("\nSaturday\n"), false);
    });

    test("adds the date range of each week to its header", () {
      final Recipe recipe = _testRecipe(id: "r1", name: "Pasta");
      final MultiWeekMenu multiWeek = MultiWeekMenu(
        startDate: DateTime(2025, 8, 6),
        weeks: [
          _singleMealMenu(recipe: recipe),
          _singleMealMenu(recipe: recipe),
        ],
      );

      final String output = multiWeek.toStringBeautified(recipes: [recipe]);

      expect(output.contains("Week 1 (6 Aug - 12 Aug)"), true);
      expect(output.contains("Week 2 (13 Aug - 19 Aug)"), true);
    });

    test("counts the leftover meals in the servings of the cook event", () {
      // The raw Cooking.yield only counts the meals, not the people. The grid shows the real
      // servings through servingsForCookEvent, and the text must show the same number.
      final Recipe recipe = _testRecipe(id: "r1", name: "Pasta");
      final MultiWeekMenu multiWeek = MultiWeekMenu(
        weeks: [
          Menu(
            meals: [
              _testMeal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: recipe, yield: 2, people: 3),
              _testMeal(weekDay: WeekDay.sunday, mealType: MealType.lunch, recipe: recipe, yield: 0, people: 2),
            ],
          ),
        ],
      );

      final String output = multiWeek.toStringBeautified(recipes: [recipe]);

      expect(output.contains("Lunch: Pasta [3p] (cook 5 servings)"), true);
      expect(output.contains("Lunch: Pasta [2p] (leftovers)"), true);
    });

    test("counts a leftover meal of the next week in the servings of the cook event", () {
      final Recipe recipe = _testRecipe(id: "r1", name: "Pasta");
      final MultiWeekMenu multiWeek = MultiWeekMenu(
        weeks: [
          Menu(
            meals: [_testMeal(weekDay: WeekDay.friday, mealType: MealType.dinner, recipe: recipe, yield: 2, people: 2)],
          ),
          Menu(
            meals: [_testMeal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: recipe, yield: 0, people: 2)],
          ),
        ],
      );

      final String output = multiWeek.toStringBeautified(recipes: [recipe]);

      expect(output.contains("Dinner: Pasta [2p] (cook 4 servings)"), true);
      expect(output.contains("Lunch: Pasta [2p] (leftovers)"), true);
    });
  });

  group("MultiWeekMenu ingredientMealRequirements", () {
    /// A recipe that uses 100 grams of rice for one serving.
    Recipe riceRecipe({String id = "r1", String name = "Rice bowl"}) {
      return _testRecipe(
        id: id,
        name: name,
        instructions: const [
          Instruction(
            id: "i1",
            description: "cook the rice",
            ingredientsUsed: [
              IngredientUsage(
                ingredient: "rice",
                quantity: Quantity(amount: 100, unit: Unit.grams),
              ),
            ],
          ),
        ],
      );
    }

    test("records the week, the day, the meal slot and the recipe of every meal that needs the ingredient", () {
      Recipe recipe = riceRecipe();
      MultiWeekMenu multiWeek = MultiWeekMenu(
        weeks: [
          const Menu(),
          const Menu(),
          Menu(
            meals: [_testMeal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipe: recipe, people: 3)],
          ),
        ],
      );

      Map<String, List<IngredientMealRequirement>> requirements = multiWeek.ingredientMealRequirements(recipes: [recipe]);

      expect(requirements.keys, ["rice"]);
      IngredientMealRequirement requirement = requirements["rice"]!.single;
      expect(requirement.weekIndex, 2);
      expect(requirement.mealTime, const MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch));
      expect(requirement.subMealIndex, 0);
      expect(requirement.recipeId, "r1");
      expect(requirement.recipeName, "Rice bowl");
      expect(requirement.people, 3);
      expect(requirement.isCookEvent, isTrue);
      expect(requirement.quantities, const [Quantity(amount: 300, unit: Unit.grams)]);
    });

    test("keeps one entry per meal instead of one entry per recipe", () {
      // IngredientSource dedups by recipe, so it cannot say which day needs the ingredient.
      Recipe recipe = riceRecipe();
      MultiWeekMenu multiWeek = MultiWeekMenu(
        weeks: [
          Menu(
            meals: [
              _testMeal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipe: recipe, yield: 2),
              _testMeal(weekDay: WeekDay.tuesday, mealType: MealType.dinner, recipe: recipe, yield: 0),
            ],
          ),
        ],
      );

      List<IngredientMealRequirement> requirements = multiWeek.ingredientMealRequirements(recipes: [recipe])["rice"]!;

      expect(requirements.length, 2);
      expect(requirements.map((IngredientMealRequirement r) => r.mealTime.weekDay), [WeekDay.monday, WeekDay.tuesday]);
      expect(requirements.map((IngredientMealRequirement r) => r.mealTime.mealType), [MealType.lunch, MealType.dinner]);
      expect(requirements.map((IngredientMealRequirement r) => r.isCookEvent), [true, false]);
    });

    test("lists the meals in chronological order", () {
      Recipe recipe = riceRecipe();
      MultiWeekMenu multiWeek = MultiWeekMenu(
        weeks: [
          Menu(
            meals: [
              _testMeal(weekDay: WeekDay.tuesday, mealType: MealType.dinner, recipe: recipe, yield: 0),
              _testMeal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipe: recipe, yield: 2),
            ],
          ),
        ],
      );

      List<IngredientMealRequirement> requirements = multiWeek.ingredientMealRequirements(recipes: [recipe])["rice"]!;

      expect(requirements.map((IngredientMealRequirement r) => r.mealTime.weekDay), [WeekDay.monday, WeekDay.tuesday]);
    });

    test("sums to the same total as allIngredients when every meal of a cook event is in one week", () {
      // The per-meal breakdown justifies the shopping total, so it must never disagree with it.
      Recipe recipe = riceRecipe();
      MultiWeekMenu multiWeek = MultiWeekMenu(
        weeks: [
          Menu(
            meals: [
              _testMeal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipe: recipe, yield: 2, people: 2),
              _testMeal(weekDay: WeekDay.tuesday, mealType: MealType.dinner, recipe: recipe, yield: 0, people: 3),
            ],
          ),
        ],
      );

      double total = multiWeek
          .ingredientMealRequirements(recipes: [recipe])["rice"]!
          .expand((IngredientMealRequirement r) => r.quantities)
          .fold(0.0, (double sum, Quantity q) => sum + q.amount);

      expect(total, multiWeek.allIngredients(recipes: [recipe])["rice"]!.single.amount);
    });

    test("ignores a meal whose recipe is unknown", () {
      MultiWeekMenu multiWeek = MultiWeekMenu(
        weeks: [
          Menu(
            meals: [
              _testMeal(
                weekDay: WeekDay.monday,
                mealType: MealType.lunch,
                recipe: _testRecipe(id: "missing", name: "Gone"),
              ),
            ],
          ),
        ],
      );

      expect(multiWeek.ingredientMealRequirements(recipes: []), isEmpty);
    });

    test("tags each entry with the week that needs the ingredient", () {
      Recipe recipe = riceRecipe();
      Menu week = Menu(
        meals: [_testMeal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipe: recipe)],
      );
      MultiWeekMenu multiWeek = MultiWeekMenu(weeks: [week, week]);

      List<IngredientMealRequirement> requirements = multiWeek.ingredientMealRequirements(recipes: [recipe])["rice"]!;

      expect(requirements.map((IngredientMealRequirement r) => r.weekIndex), [0, 1]);
    });

    test("returns nothing for a menu without meals", () {
      MultiWeekMenu multiWeek = MultiWeekMenu(weeks: [const Menu(), const Menu()]);

      expect(multiWeek.ingredientMealRequirements(recipes: []), isEmpty);
    });

    test("writes an entry for a leftover meal of the next week", () {
      // The cook event is the last meal of week 0. The leftover meal is the first meal of week 1.
      // A walk that runs one week at a time misses it, because week 1 cooks nothing.
      Recipe recipe = riceRecipe();
      MultiWeekMenu multiWeek = MultiWeekMenu(
        weeks: [
          Menu(
            meals: [_testMeal(weekDay: WeekDay.friday, mealType: MealType.dinner, recipe: recipe, yield: 2, people: 2)],
          ),
          Menu(
            meals: [_testMeal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: recipe, yield: 0, people: 2)],
          ),
        ],
      );

      List<IngredientMealRequirement> requirements = multiWeek.ingredientMealRequirements(recipes: [recipe])["rice"]!;

      expect(requirements.length, 2);
      expect(requirements.map((IngredientMealRequirement r) => r.weekIndex), [0, 1]);
      expect(requirements.map((IngredientMealRequirement r) => r.isCookEvent), [true, false]);
      expect(requirements.last.mealTime, const MealTime(weekDay: WeekDay.saturday, mealType: MealType.lunch));
      expect(requirements.last.quantities, const [Quantity(amount: 200, unit: Unit.grams)]);
    });

    test("adds up the same unit that two instructions of one recipe use", () {
      Recipe recipe = _testRecipe(
        id: "r1",
        name: "Rice bowl",
        instructions: const [
          Instruction(
            id: "i1",
            description: "boil the rice",
            ingredientsUsed: [
              IngredientUsage(
                ingredient: "rice",
                quantity: Quantity(amount: 100, unit: Unit.grams),
              ),
            ],
          ),
          Instruction(
            id: "i2",
            description: "fry the rice",
            ingredientsUsed: [
              IngredientUsage(
                ingredient: "rice",
                quantity: Quantity(amount: 20, unit: Unit.grams),
              ),
            ],
          ),
        ],
      );
      MultiWeekMenu multiWeek = MultiWeekMenu(
        weeks: [
          Menu(
            meals: [_testMeal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipe: recipe, people: 2)],
          ),
        ],
      );

      List<IngredientMealRequirement> requirements = multiWeek.ingredientMealRequirements(recipes: [recipe])["rice"]!;

      expect(requirements.single.quantities, const [Quantity(amount: 240, unit: Unit.grams)]);
    });

    test("keeps one quantity per unit when one recipe needs two units of one ingredient", () {
      Recipe recipe = _testRecipe(
        id: "r1",
        name: "Garlic bread",
        instructions: const [
          Instruction(
            id: "i1",
            description: "rub the bread",
            ingredientsUsed: [
              IngredientUsage(
                ingredient: "garlic",
                quantity: Quantity(amount: 2, unit: Unit.pieces),
              ),
              IngredientUsage(
                ingredient: "garlic",
                quantity: Quantity(amount: 5, unit: Unit.grams),
              ),
            ],
          ),
        ],
      );
      MultiWeekMenu multiWeek = MultiWeekMenu(
        weeks: [
          Menu(
            meals: [_testMeal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipe: recipe, people: 2)],
          ),
        ],
      );

      List<IngredientMealRequirement> requirements = multiWeek.ingredientMealRequirements(recipes: [recipe])["garlic"]!;

      expect(requirements.single.quantities, const [Quantity(amount: 4, unit: Unit.pieces), Quantity(amount: 10, unit: Unit.grams)]);
    });

    test("writes one entry per sub-meal when two recipes of one slot need the same ingredient", () {
      Recipe rice = riceRecipe(id: "r1", name: "Rice bowl");
      Recipe pudding = riceRecipe(id: "r2", name: "Rice pudding");
      MultiWeekMenu multiWeek = MultiWeekMenu(
        weeks: [
          const Menu(
            meals: [
              Meal(
                mealTime: MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch),
                subMeals: [
                  SubMeal(cooking: Cooking(recipeId: "r2", yield: 1), people: 1),
                  SubMeal(cooking: Cooking(recipeId: "r1", yield: 1), people: 2),
                ],
              ),
            ],
          ),
        ],
      );

      List<IngredientMealRequirement> requirements = multiWeek.ingredientMealRequirements(recipes: [rice, pudding])["rice"]!;

      // Both entries share the meal slot, so the sub-meal index alone decides the order.
      expect(requirements.map((IngredientMealRequirement r) => r.subMealIndex), [0, 1]);
      expect(requirements.map((IngredientMealRequirement r) => r.recipeName), ["Rice pudding", "Rice bowl"]);
      expect(requirements.map((IngredientMealRequirement r) => r.quantities.single.amount), [100, 200]);
    });
  });

  group("MultiWeekMenu cross-week shopping totals", () {
    /// A recipe that uses 100 grams of rice for one serving.
    Recipe riceRecipe({String id = "r1", String name = "Rice bowl", int maxStorageDays = 6}) {
      return Recipe(
        id: id,
        name: name,
        maxStorageDays: maxStorageDays,
        instructions: const [
          Instruction(
            id: "i1",
            description: "cook the rice",
            ingredientsUsed: [
              IngredientUsage(
                ingredient: "rice",
                quantity: Quantity(amount: 100, unit: Unit.grams),
              ),
            ],
          ),
        ],
      );
    }

    /// Adds up the per-meal amounts of [ingredientMealRequirements], per ingredient and per unit.
    Map<String, List<Quantity>> sumOfMealRequirements(MultiWeekMenu multiWeek, List<Recipe> recipes) {
      Map<String, List<Quantity>> totals = {};
      for (MapEntry<String, List<IngredientMealRequirement>> entry in multiWeek.ingredientMealRequirements(recipes: recipes).entries) {
        Map<Unit, double> byUnit = {};
        for (Quantity quantity in entry.value.expand((IngredientMealRequirement r) => r.quantities)) {
          byUnit[quantity.unit] = (byUnit[quantity.unit] ?? 0) + quantity.amount;
        }
        totals[entry.key] = byUnit.entries.map((MapEntry<Unit, double> e) => Quantity(amount: e.value, unit: e.key)).toList();
      }
      return totals;
    }

    test("buys the food of a leftover meal of the next week with the cook event that feeds it", () {
      // Issue #49: week 1 cooks nothing, and week 0 cannot see the meal of week 1.
      Recipe recipe = riceRecipe(maxStorageDays: 3);
      MultiWeekMenu multiWeek = MultiWeekMenu(
        weeks: [
          Menu(
            meals: [_testMeal(weekDay: WeekDay.friday, mealType: MealType.dinner, recipe: recipe, yield: 2, people: 2)],
          ),
          Menu(
            meals: [_testMeal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: recipe, yield: 0, people: 2)],
          ),
        ],
      );

      expect(multiWeek.allIngredients(recipes: [recipe]), const {
        "rice": [Quantity(amount: 400, unit: Unit.grams)],
      });
    });

    test("leaves out a leftover meal of the next week that is outside the storage window", () {
      // Friday of week 0 is day 6. Monday of week 1 is day 9, three days later, and the recipe keeps one day.
      Recipe recipe = riceRecipe(maxStorageDays: 1);
      MultiWeekMenu multiWeek = MultiWeekMenu(
        weeks: [
          Menu(
            meals: [_testMeal(weekDay: WeekDay.friday, mealType: MealType.dinner, recipe: recipe, yield: 2, people: 2)],
          ),
          Menu(
            meals: [_testMeal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipe: recipe, yield: 0, people: 3)],
          ),
        ],
      );

      expect(multiWeek.allIngredients(recipes: [recipe]), const {
        "rice": [Quantity(amount: 200, unit: Unit.grams)],
      });
      expect(multiWeek.ingredientMealRequirements(recipes: [recipe])["rice"]!.map((IngredientMealRequirement r) => r.weekIndex), [0]);
    });

    test("leaves out a leftover meal of the same week that is outside the storage window", () {
      // Saturday is day 0 and Thursday is day 5. The recipe keeps one day, so no cook event feeds Thursday.
      Recipe recipe = riceRecipe(maxStorageDays: 1);
      MultiWeekMenu multiWeek = MultiWeekMenu(
        weeks: [
          Menu(
            meals: [
              _testMeal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: recipe, yield: 2, people: 2),
              _testMeal(weekDay: WeekDay.thursday, mealType: MealType.lunch, recipe: recipe, yield: 0, people: 3),
            ],
          ),
        ],
      );

      expect(multiWeek.allIngredients(recipes: [recipe]), const {
        "rice": [Quantity(amount: 200, unit: Unit.grams)],
      });
      expect(multiWeek.ingredientMealRequirements(recipes: [recipe])["rice"]!.map((IngredientMealRequirement r) => r.mealTime.weekDay), [
        WeekDay.saturday,
      ]);
    });

    test("tags each meal with the week of the cook event that feeds it", () {
      // The Friday cook of week 0 feeds the Saturday of week 1. The Monday cook of week 1 is the
      // nearest earlier cook event of the Tuesday, so it feeds the Tuesday.
      Recipe recipe = riceRecipe(maxStorageDays: 6);
      MultiWeekMenu multiWeek = MultiWeekMenu(
        weeks: [
          Menu(
            meals: [_testMeal(weekDay: WeekDay.friday, mealType: MealType.dinner, recipe: recipe, yield: 2, people: 2)],
          ),
          Menu(
            meals: [
              _testMeal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: recipe, yield: 0, people: 2),
              _testMeal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipe: recipe, yield: 2, people: 2),
              _testMeal(weekDay: WeekDay.tuesday, mealType: MealType.lunch, recipe: recipe, yield: 0, people: 2),
            ],
          ),
        ],
      );

      List<IngredientMealRequirement> requirements = multiWeek.ingredientMealRequirements(recipes: [recipe])["rice"]!;

      expect(requirements.map((IngredientMealRequirement r) => (r.weekIndex, r.mealTime.weekDay, r.cookWeekIndex)), [
        (0, WeekDay.friday, 0),
        (1, WeekDay.saturday, 0),
        (1, WeekDay.monday, 1),
        (1, WeekDay.tuesday, 1),
      ]);
      // The day of the cook event, counted from the first day of the menu: Friday of week 0 is
      // day 6, and Monday of week 1 is day 9. A shopping trip buys the food of that day.
      expect(requirements.map((IngredientMealRequirement r) => r.cookDayIndex), [6, 6, 9, 9]);
    });

    test("counts a leftover meal of the next week in the servings of the recipe source", () {
      Recipe recipe = riceRecipe(maxStorageDays: 3);
      MultiWeekMenu multiWeek = MultiWeekMenu(
        weeks: [
          Menu(
            meals: [_testMeal(weekDay: WeekDay.friday, mealType: MealType.dinner, recipe: recipe, yield: 2, people: 2)],
          ),
          Menu(
            meals: [_testMeal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: recipe, yield: 0, people: 3)],
          ),
        ],
      );

      expect(multiWeek.ingredientSources(recipes: [recipe]), const {
        "rice": [
          IngredientSource(
            recipeName: "Rice bowl",
            perServingQuantities: [Quantity(amount: 100, unit: Unit.grams)],
            servings: 5,
          ),
        ],
      });
    });

    test("agrees per ingredient with the sum of ingredientMealRequirements", () {
      // One menu that mixes every case: a leftover meal of the next week, a leftover meal outside
      // every window, a recipe that cannot be stored, two sub-meals in one slot and an unknown recipe.
      Recipe rice = riceRecipe(id: "r1", name: "Rice bowl", maxStorageDays: 2);
      Recipe fresh = riceRecipe(id: "r2", name: "Fresh rice", maxStorageDays: 0);
      List<Recipe> recipes = [rice, fresh];
      MultiWeekMenu multiWeek = MultiWeekMenu(
        weeks: [
          Menu(
            meals: [
              const Meal(
                mealTime: MealTime(weekDay: WeekDay.thursday, mealType: MealType.lunch),
                subMeals: [
                  SubMeal(cooking: Cooking(recipeId: "r2", yield: 1), people: 1),
                  SubMeal(cooking: Cooking(recipeId: "r1", yield: 3), people: 2),
                ],
              ),
              _testMeal(weekDay: WeekDay.friday, mealType: MealType.lunch, recipe: fresh, yield: 1, people: 4),
              _testMeal(weekDay: WeekDay.friday, mealType: MealType.dinner, recipe: rice, yield: 0, people: 3),
              _testMeal(
                weekDay: WeekDay.monday,
                mealType: MealType.dinner,
                recipe: _testRecipe(id: "missing", name: "Gone"),
              ),
            ],
          ),
          Menu(
            meals: [
              _testMeal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: rice, yield: 0, people: 5),
              _testMeal(weekDay: WeekDay.sunday, mealType: MealType.lunch, recipe: rice, yield: 0, people: 7),
            ],
          ),
        ],
      );

      // Rice bowl: Thursday (day 5) feeds Friday (day 6) and Saturday of week 1 (day 7), but not
      // Sunday of week 1 (day 8). So 2 + 3 + 5 people. Fresh rice: 1 + 4 people.
      Map<String, List<Quantity>> expected = const {
        "rice": [Quantity(amount: 1500, unit: Unit.grams)],
      };
      expect(multiWeek.allIngredients(recipes: recipes), expected);
      expect(sumOfMealRequirements(multiWeek, recipes), expected);
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
      expect(restored.weeks.first.meals.first.subMeals.first.cooking?.recipeId, "r1");
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
      expect(loaded.weeks.first.meals.first.subMeals.first.cooking?.recipeId, "r1");
    });
  });

  group("MultiWeekMenu cross-week yield calculation", () {
    test("recipe cooked Thursday week 1 carries over as leftovers to Monday week 2", () {
      // maxStorageDays: 6 means it can be stored up to 6 days
      Recipe storable = _testRecipe(id: "s1", name: "Stew");
      // Thursday = weekDay.thursday (value 5)
      Meal thursdayMeal = Meal(
        mealTime: const MealTime(weekDay: WeekDay.thursday, mealType: MealType.lunch),
        subMeals: [SubMeal(cooking: Cooking(recipeId: "s1", yield: -1), people: 2)],
      );
      // Monday next week = weekDay.monday (value 2)
      Meal mondayMeal = Meal(
        mealTime: const MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch),
        subMeals: [SubMeal(cooking: Cooking(recipeId: "s1", yield: -1), people: 2)],
      );

      Menu week1 = Menu(meals: [thursdayMeal]);
      Menu week2 = Menu(meals: [mondayMeal]);
      MultiWeekMenu multi = MultiWeekMenu(weeks: [week1, week2]);

      MultiWeekMenu updated = multi.copyWithUpdatedYields(recipes: [storable]);

      // Week 1 Thursday: cook (yield = 1 within this week, but cross-week makes it 2)
      // Actually: cross-week recalc - week 1 sees only itself (yield=1 for thursday),
      // week 2 monday: absolute day = 7*1+2 = 9, thursday absolute = 7*0+5 = 5, distance = 4 <= 6
      // So Monday week 2 is leftovers (yield=0)
      expect(updated.weeks[0].meals[0].subMeals.first.cooking?.yield, 1);
      expect(updated.weeks[1].meals[0].subMeals.first.cooking?.yield, 0);
    });

    test("recipe exceeding maxStorageDays across weeks gets a new cook event", () {
      // maxStorageDays: 2
      Recipe shortLife = Recipe(id: "s1", name: "Salad", maxStorageDays: 2);
      // Saturday week 1 = absolute day 0
      Meal satMeal = Meal(
        mealTime: const MealTime(weekDay: WeekDay.saturday, mealType: MealType.lunch),
        subMeals: [SubMeal(cooking: Cooking(recipeId: "s1", yield: -1), people: 2)],
      );
      // Wednesday week 1 = absolute day 4 (distance = 4 > 2, new cook)
      Meal wedMeal = Meal(
        mealTime: const MealTime(weekDay: WeekDay.wednesday, mealType: MealType.lunch),
        subMeals: [SubMeal(cooking: Cooking(recipeId: "s1", yield: -1), people: 2)],
      );

      Menu week1 = Menu(meals: [satMeal, wedMeal]);
      MultiWeekMenu multi = MultiWeekMenu(weeks: [week1]);

      MultiWeekMenu updated = multi.copyWithUpdatedYields(recipes: [shortLife]);

      // Saturday: cook (yield=1, only itself within 2-day window)
      expect(updated.weeks[0].meals[0].subMeals.first.cooking?.yield, 1);
      // Wednesday: new cook (yield=1), too far from Saturday
      expect(updated.weeks[0].meals[1].subMeals.first.cooking?.yield, 1);
    });

    test("totalServingsForRecipe sums across all weeks", () {
      Menu week1 = Menu(
        meals: [
          Meal(
            mealTime: const MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch),
            subMeals: [SubMeal(cooking: Cooking(recipeId: "r1", yield: 1), people: 2)],
          ),
        ],
      );
      Menu week2 = Menu(
        meals: [
          Meal(
            mealTime: const MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch),
            subMeals: [SubMeal(cooking: Cooking(recipeId: "r1", yield: 0), people: 3)],
          ),
        ],
      );
      MultiWeekMenu multi = MultiWeekMenu(weeks: [week1, week2]);

      expect(multi.totalServingsForRecipe("r1"), 5); // 2 + 3
    });

    test("servingsForCookEvent only counts meals in its storage window", () {
      Recipe storable = Recipe(id: "s1", name: "Stew", maxStorageDays: 6);
      List<Recipe> recipes = [storable];

      // Week 0: Saturday cook (day 0), Wednesday leftovers (day 4)
      // Week 1: Monday (day 9) - outside storage window, new cook event
      Menu week0 = Menu(
        meals: [
          Meal(
            mealTime: const MealTime(weekDay: WeekDay.saturday, mealType: MealType.lunch),
            subMeals: [SubMeal(cooking: Cooking(recipeId: "s1", yield: 2), people: 2)],
          ),
          Meal(
            mealTime: const MealTime(weekDay: WeekDay.wednesday, mealType: MealType.lunch),
            subMeals: [SubMeal(cooking: Cooking(recipeId: "s1", yield: 0), people: 3)],
          ),
        ],
      );
      Menu week1 = Menu(
        meals: [
          Meal(
            mealTime: const MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch),
            subMeals: [SubMeal(cooking: Cooking(recipeId: "s1", yield: 1), people: 4)],
          ),
        ],
      );
      MultiWeekMenu multi = MultiWeekMenu(weeks: [week0, week1]);

      // Saturday cook feeds Saturday (2) + Wednesday (3) = 5, NOT Monday
      expect(
        multi.servingsForCookEvent(
          cookWeekIndex: 0,
          cookMealTime: const MealTime(weekDay: WeekDay.saturday, mealType: MealType.lunch),
          subMealIndex: 0,
          recipes: recipes,
        ),
        5,
      );

      // Monday cook feeds only Monday (4)
      expect(
        multi.servingsForCookEvent(
          cookWeekIndex: 1,
          cookMealTime: const MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch),
          subMealIndex: 0,
          recipes: recipes,
        ),
        4,
      );
    });

    group("servingsForCookEvent attributes each meal to one cook event", () {
      const MealTime satBreakfast = MealTime(weekDay: WeekDay.saturday, mealType: MealType.breakfast);
      const MealTime satLunch = MealTime(weekDay: WeekDay.saturday, mealType: MealType.lunch);
      const MealTime satDinner = MealTime(weekDay: WeekDay.saturday, mealType: MealType.dinner);
      const MealTime sunLunch = MealTime(weekDay: WeekDay.sunday, mealType: MealType.lunch);
      const MealTime monLunch = MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch);
      const MealTime tueLunch = MealTime(weekDay: WeekDay.tuesday, mealType: MealType.lunch);
      const MealTime wedLunch = MealTime(weekDay: WeekDay.wednesday, mealType: MealType.lunch);
      const MealTime thuLunch = MealTime(weekDay: WeekDay.thursday, mealType: MealType.lunch);

      /// Builds one meal that holds one sub-meal per entry of [people], all with [recipeId].
      Meal mealOf(MealTime mealTime, String recipeId, List<int> people) {
        return Meal(
          mealTime: mealTime,
          subMeals: [
            for (int p in people)
              SubMeal(
                cooking: Cooking(recipeId: recipeId, yield: 1),
                people: p,
              ),
          ],
        );
      }

      /// Returns the servings of every cook event of [recipeId], keyed by week, slot and sub-meal index.
      Map<(int, MealTime, int), int> cookServings(MultiWeekMenu multi, String recipeId, List<Recipe> recipes) {
        Map<(int, MealTime, int), int> result = {};
        for (int wi = 0; wi < multi.weeks.length; wi++) {
          for (Meal meal in multi.weeks[wi].meals) {
            for (int si = 0; si < meal.subMeals.length; si++) {
              Cooking? cooking = meal.subMeals[si].cooking;
              if (cooking == null || cooking.recipeId != recipeId || cooking.yield <= 0) continue;
              result[(wi, meal.mealTime, si)] = multi.servingsForCookEvent(
                cookWeekIndex: wi,
                cookMealTime: meal.mealTime,
                subMealIndex: si,
                recipes: recipes,
              );
            }
          }
        }
        return result;
      }

      test("a fresh-only recipe at lunch and dinner of one day cooks the people of each meal", () {
        List<Recipe> recipes = [Recipe(id: "f1", name: "Salad", maxStorageDays: 0)];
        MultiWeekMenu multi = MultiWeekMenu(
          weeks: [
            Menu(
              meals: [
                mealOf(satLunch, "f1", [2]),
                mealOf(satDinner, "f1", [2]),
              ],
            ),
          ],
        ).copyWithUpdatedYields(recipes: recipes);

        expect(cookServings(multi, "f1", recipes), {(0, satLunch, 0): 2, (0, satDinner, 0): 2});
      });

      test("a fresh-only recipe at breakfast and dinner does not count the earlier meal", () {
        List<Recipe> recipes = [Recipe(id: "f1", name: "Salad", maxStorageDays: 0)];
        MultiWeekMenu multi = MultiWeekMenu(
          weeks: [
            Menu(
              meals: [
                mealOf(satDinner, "f1", [3]),
                mealOf(satBreakfast, "f1", [1]),
              ],
            ),
          ],
        ).copyWithUpdatedYields(recipes: recipes);

        expect(cookServings(multi, "f1", recipes), {(0, satBreakfast, 0): 1, (0, satDinner, 0): 3});
      });

      test("two sub-meals of a fresh-only recipe in one slot cook the people of each sub-meal", () {
        List<Recipe> recipes = [Recipe(id: "f1", name: "Salad", maxStorageDays: 0)];
        MultiWeekMenu multi = MultiWeekMenu(
          weeks: [
            Menu(
              meals: [
                mealOf(satLunch, "f1", [2, 3]),
              ],
            ),
          ],
        ).copyWithUpdatedYields(recipes: recipes);

        expect(cookServings(multi, "f1", recipes), {(0, satLunch, 0): 2, (0, satLunch, 1): 3});
      });

      test("two sub-meals of a storable recipe in one slot cook once for both", () {
        List<Recipe> recipes = [Recipe(id: "s1", name: "Stew", maxStorageDays: 2)];
        MultiWeekMenu multi = MultiWeekMenu(
          weeks: [
            Menu(
              meals: [
                mealOf(satLunch, "s1", [2, 3]),
                mealOf(sunLunch, "s1", [4]),
              ],
            ),
          ],
        ).copyWithUpdatedYields(recipes: recipes);

        expect(cookServings(multi, "s1", recipes), {(0, satLunch, 0): 9});
      });

      test("a storable recipe cooked again keeps its later leftovers for the second cook event", () {
        List<Recipe> recipes = [Recipe(id: "s1", name: "Stew", maxStorageDays: 1)];
        MultiWeekMenu multi = MultiWeekMenu(
          weeks: [
            Menu(
              meals: [
                mealOf(monLunch, "s1", [2]),
                mealOf(tueLunch, "s1", [3]),
                mealOf(wedLunch, "s1", [4]),
                mealOf(thuLunch, "s1", [5]),
              ],
            ),
          ],
        ).copyWithUpdatedYields(recipes: recipes);

        expect(cookServings(multi, "s1", recipes), {(0, monLunch, 0): 5, (0, wedLunch, 0): 9});
      });

      test("a second cook event inside the storage window takes the leftovers after it", () {
        // These yields are set by hand: Wednesday cooks again although Monday's window still covers it.
        List<Recipe> recipes = [Recipe(id: "s1", name: "Stew", maxStorageDays: 3)];
        MultiWeekMenu multi = MultiWeekMenu(
          weeks: [
            Menu(
              meals: [
                Meal(
                  mealTime: monLunch,
                  subMeals: [SubMeal(cooking: Cooking(recipeId: "s1", yield: 2), people: 2)],
                ),
                Meal(
                  mealTime: tueLunch,
                  subMeals: [SubMeal(cooking: Cooking(recipeId: "s1", yield: 0), people: 3)],
                ),
                Meal(
                  mealTime: wedLunch,
                  subMeals: [SubMeal(cooking: Cooking(recipeId: "s1", yield: 2), people: 4)],
                ),
                Meal(
                  mealTime: thuLunch,
                  subMeals: [SubMeal(cooking: Cooking(recipeId: "s1", yield: 0), people: 5)],
                ),
              ],
            ),
          ],
        );

        expect(cookServings(multi, "s1", recipes), {(0, monLunch, 0): 5, (0, wedLunch, 0): 9});
      });

      test("a leftover sub-meal outside the storage window is not counted", () {
        // These yields are set by hand: Thursday is a leftover sub-meal that Monday's window does not cover.
        List<Recipe> recipes = [Recipe(id: "s1", name: "Stew", maxStorageDays: 1)];
        MultiWeekMenu multi = MultiWeekMenu(
          weeks: [
            Menu(
              meals: [
                Meal(
                  mealTime: monLunch,
                  subMeals: [SubMeal(cooking: Cooking(recipeId: "s1", yield: 2), people: 2)],
                ),
                Meal(
                  mealTime: tueLunch,
                  subMeals: [SubMeal(cooking: Cooking(recipeId: "s1", yield: 0), people: 3)],
                ),
                Meal(
                  mealTime: thuLunch,
                  subMeals: [SubMeal(cooking: Cooking(recipeId: "s1", yield: 0), people: 5)],
                ),
              ],
            ),
          ],
        );

        expect(cookServings(multi, "s1", recipes), {(0, monLunch, 0): 5});
      });

      test("the servings of all cook events of a recipe add up to its total servings", () {
        List<Recipe> recipes = [Recipe(id: "f1", name: "Salad", maxStorageDays: 0), Recipe(id: "s1", name: "Stew", maxStorageDays: 1)];
        MultiWeekMenu multi = MultiWeekMenu(
          weeks: [
            Menu(
              meals: [
                mealOf(satBreakfast, "f1", [1, 2]),
                mealOf(satLunch, "f1", [2]),
                mealOf(satDinner, "s1", [2, 1]),
                mealOf(sunLunch, "s1", [3]),
                mealOf(monLunch, "s1", [4]),
                mealOf(thuLunch, "s1", [2]),
              ],
            ),
            Menu(
              meals: [
                mealOf(satLunch, "s1", [5]),
                mealOf(sunLunch, "f1", [3]),
              ],
            ),
          ],
        ).copyWithUpdatedYields(recipes: recipes);

        for (String recipeId in ["f1", "s1"]) {
          int sum = cookServings(multi, recipeId, recipes).values.fold(0, (int a, int b) => a + b);
          expect(sum, multi.totalServingsForRecipe(recipeId), reason: recipeId);
        }
        expect(multi.totalServingsForRecipe("f1"), 8);
        expect(multi.totalServingsForRecipe("s1"), 17);
      });
    });
  });

  group("MultiWeekMenu start date", () {
    test("defaults to no start date", () {
      Recipe recipe = _testRecipe(id: "r1", name: "Soup");
      MultiWeekMenu multi = MultiWeekMenu(weeks: [_singleMealMenu(recipe: recipe)]);

      expect(multi.startDate, isNull);
    });

    test("survives a JSON round trip", () {
      Recipe recipe = _testRecipe(id: "r1", name: "Soup");
      MultiWeekMenu multi = MultiWeekMenu(
        startDate: DateTime(2025, 8, 6),
        weeks: [_singleMealMenu(recipe: recipe)],
      );

      MultiWeekMenu restored = MultiWeekMenu.fromJson(jsonDecode(jsonEncode(multi.toJson())));

      expect(restored.startDate, DateTime(2025, 8, 6));
    });

    test("is absent from the JSON when the menu has no start date", () {
      Recipe recipe = _testRecipe(id: "r1", name: "Soup");
      MultiWeekMenu multi = MultiWeekMenu(weeks: [_singleMealMenu(recipe: recipe)]);

      expect(multi.toJson().containsKey("startDate"), isFalse);
    });

    test("a missing start date in the JSON loads as no start date", () {
      Recipe recipe = _testRecipe(id: "r1", name: "Soup");
      Map<String, dynamic> json = MultiWeekMenu(weeks: [_singleMealMenu(recipe: recipe)]).toJson();

      expect(MultiWeekMenu.fromJson(json).startDate, isNull);
    });

    test("changing the start date leaves every meal in its own slot", () {
      Recipe recipe = _testRecipe(id: "r1", name: "Soup");
      MultiWeekMenu multi = MultiWeekMenu(
        weeks: [
          Menu(
            meals: [
              _testMeal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: recipe),
              _testMeal(weekDay: WeekDay.wednesday, mealType: MealType.dinner, recipe: recipe),
            ],
          ),
        ],
      );

      MultiWeekMenu dated = multi.copyWith(startDate: DateTime(2025, 8, 6));

      // The weekday of each meal is the planning key. A real date must never move it.
      expect(dated.weeks.first.meals.map((Meal meal) => meal.mealTime).toList(), [
        const MealTime(weekDay: WeekDay.saturday, mealType: MealType.lunch),
        const MealTime(weekDay: WeekDay.wednesday, mealType: MealType.dinner),
      ]);
      expect(dated.weeks, multi.weeks);
    });

    test("the start date does not change the cross-week leftover calculation", () {
      // Thursday of week 1 (day 5) cooks. Monday of week 2 (day 9) is 4 days later, so it
      // eats the leftovers. This is the case where a wrong date translation would show up.
      Recipe storable = Recipe(id: "s1", name: "Stew", maxStorageDays: 6);
      Menu week1 = Menu(
        meals: [_testMeal(weekDay: WeekDay.thursday, mealType: MealType.lunch, recipe: storable, yield: -1)],
      );
      Menu week2 = Menu(
        meals: [_testMeal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipe: storable, yield: -1)],
      );
      MultiWeekMenu undated = MultiWeekMenu(weeks: [week1, week2]);
      MultiWeekMenu dated = undated.copyWith(startDate: DateTime(2025, 8, 6));

      MultiWeekMenu updatedUndated = undated.copyWithUpdatedYields(recipes: [storable]);
      MultiWeekMenu updatedDated = dated.copyWithUpdatedYields(recipes: [storable]);

      expect(updatedUndated.weeks[0].meals[0].subMeals.first.cooking?.yield, 1);
      expect(updatedUndated.weeks[1].meals[0].subMeals.first.cooking?.yield, 0);
      expect(updatedDated.weeks, updatedUndated.weeks);
      expect(updatedDated.startDate, DateTime(2025, 8, 6));
    });

    test("adding and removing a week keeps the start date", () {
      Recipe recipe = _testRecipe(id: "r1", name: "Soup");
      MultiWeekMenu multi = MultiWeekMenu(
        startDate: DateTime(2025, 8, 6),
        weeks: [_singleMealMenu(recipe: recipe)],
      );

      MultiWeekMenu grown = multi.addWeek(_singleMealMenu(recipe: recipe));

      expect(grown.startDate, DateTime(2025, 8, 6));
      expect(grown.removeLastWeek().startDate, DateTime(2025, 8, 6));
    });
  });

  group("MultiWeekMenu toStringBeautified detailed format", () {
    /// The days that hold no meal. The detailed format keeps the shape of the simplified one, so
    /// the expected text of a small menu still lists every day of the week.
    List<String> emptyDays(List<String> dayNames) {
      return [
        for (String dayName in dayNames) ...[dayName, "  Breakfast: -", "  Lunch: -", "  Dinner: -", ""],
      ];
    }

    test("adds the total time of the recipe to every cook event", () {
      Recipe pasta = _testRecipe(
        id: "r1",
        name: "Pasta",
        instructions: const [Instruction(id: "i1", description: "Boil", workingTimeMinutes: 15, cookingTimeMinutes: 30)],
      );
      Menu week = Menu(
        meals: [
          _testMeal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: pasta),
          _testMeal(weekDay: WeekDay.sunday, mealType: MealType.lunch, recipe: pasta, yield: 0),
        ],
      );
      MultiWeekMenu multiWeek = MultiWeekMenu(weeks: [week]);

      String output = multiWeek.toStringBeautified(recipes: [pasta], format: MenuCopyFormat.detailed);

      expect(output.split("\n"), [
        "Week 1",
        "Saturday",
        "  Breakfast: -",
        "  Lunch: Pasta [2p] (cook 4 servings, 45 min)",
        "  Dinner: -",
        "",
        "Sunday",
        "  Breakfast: -",
        "  Lunch: Pasta [2p] (leftovers)",
        "  Dinner: -",
        "",
        ...emptyDays(["Monday", "Tuesday", "Wednesday", "Thursday"]),
        "Friday",
        "  Breakfast: -",
        "  Lunch: -",
        "  Dinner: -",
      ]);
    });

    test("writes no time for a cook event whose recipe is gone", () {
      Recipe pasta = _testRecipe(id: "r1", name: "Pasta");
      MultiWeekMenu multiWeek = MultiWeekMenu(weeks: [_singleMealMenu(recipe: pasta)]);

      String output = multiWeek.toStringBeautified(recipes: const [], format: MenuCopyFormat.detailed);

      expect(output.split("\n"), [
        "Week 1",
        "Saturday",
        "  Breakfast: -",
        "  Lunch: - [2p] (cook 2 servings)",
        "  Dinner: -",
        "",
        ...emptyDays(["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday"]),
        "Friday",
        "  Breakfast: -",
        "  Lunch: -",
        "  Dinner: -",
      ]);
    });

    test("writes no time for a recipe that holds no time", () {
      // The recipe is in the list, so this is not the "recipe is gone" branch. It holds no
      // instruction, so its total is 0 minutes. ", 0 min" would read as an instant dish.
      Recipe pasta = _testRecipe(id: "r1", name: "Pasta");
      MultiWeekMenu multiWeek = MultiWeekMenu(weeks: [_singleMealMenu(recipe: pasta)]);

      String output = multiWeek.toStringBeautified(recipes: [pasta], format: MenuCopyFormat.detailed);

      expect(output.split("\n"), [
        "Week 1",
        "Saturday",
        "  Breakfast: -",
        "  Lunch: Pasta [2p] (cook 2 servings)",
        "  Dinner: -",
        "",
        ...emptyDays(["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday"]),
        "Friday",
        "  Breakfast: -",
        "  Lunch: -",
        "  Dinner: -",
      ]);
    });

    test("keeps the simplified format free of the time", () {
      Recipe pasta = _testRecipe(
        id: "r1",
        name: "Pasta",
        instructions: const [Instruction(id: "i1", description: "Boil", workingTimeMinutes: 15, cookingTimeMinutes: 30)],
      );
      MultiWeekMenu multiWeek = MultiWeekMenu(weeks: [_singleMealMenu(recipe: pasta)]);

      String output = multiWeek.toStringBeautified(recipes: [pasta], format: MenuCopyFormat.simplified);

      expect(output.split("\n"), [
        "Week 1",
        "Saturday",
        "  Breakfast: -",
        "  Lunch: Pasta [2p] (cook 2 servings)",
        "  Dinner: -",
        "",
        ...emptyDays(["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday"]),
        "Friday",
        "  Breakfast: -",
        "  Lunch: -",
        "  Dinner: -",
      ]);
    });
  });
}
