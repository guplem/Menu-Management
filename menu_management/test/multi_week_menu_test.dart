import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:menu_management/menu/enums/meal_type.dart";
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
}
