import "package:flutter_test/flutter_test.dart";
import "package:menu_management/ingredients/ingredients_provider.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/menu/enums/meal_type.dart";
import "package:menu_management/menu/enums/week_day.dart";
import "package:menu_management/menu/menu_provider.dart";
import "package:menu_management/menu/models/cooking.dart";
import "package:menu_management/menu/models/meal.dart";
import "package:menu_management/menu/models/meal_time.dart";
import "package:menu_management/menu/models/menu.dart";
import "package:menu_management/menu/models/multi_week_menu.dart";
import "package:menu_management/menu/models/sub_meal.dart";
import "package:menu_management/recipes/enums/unit.dart";
import "package:menu_management/recipes/models/ingredient_usage.dart";
import "package:menu_management/recipes/models/instruction.dart";
import "package:menu_management/recipes/models/quantity.dart";
import "package:menu_management/recipes/models/recipe.dart";
import "package:menu_management/recipes/models/result.dart";
import "package:menu_management/recipes/recipes_provider.dart";

// ── Test helpers ──

IngredientUsage _usage(String ingredientId) => IngredientUsage(
  ingredient: ingredientId,
  quantity: const Quantity(amount: 100, unit: Unit.grams),
);

Meal _meal({WeekDay weekDay = WeekDay.saturday, MealType mealType = MealType.lunch, String? recipeId, int yield = 1, int people = 2}) {
  return Meal(
    mealTime: MealTime(weekDay: weekDay, mealType: mealType),
    subMeals: [
      SubMeal(
        cooking: recipeId != null ? Cooking(recipeId: recipeId, yield: yield) : null,
        people: people,
      ),
    ],
  );
}

void main() {
  // ── Ingredient.findReferencingRecipes ──

  group("Ingredient.findReferencingRecipes", () {
    const Ingredient tomato = Ingredient(id: "ing-tomato", name: "Tomato");

    test("returns recipes that use the ingredient in any instruction", () {
      Recipe salad = Recipe(
        id: "r-salad",
        name: "Salad",
        instructions: [
          Instruction(id: "i1", description: "Chop", ingredientsUsed: [_usage("ing-tomato")]),
        ],
      );
      Recipe soup = Recipe(
        id: "r-soup",
        name: "Soup",
        instructions: [
          const Instruction(id: "i1", description: "Prep"),
          Instruction(id: "i2", description: "Boil", ingredientsUsed: [_usage("ing-tomato")]),
        ],
      );
      Recipe cake = Recipe(
        id: "r-cake",
        name: "Cake",
        instructions: [
          Instruction(id: "i1", description: "Mix", ingredientsUsed: [_usage("ing-flour")]),
        ],
      );

      List<Recipe> referencing = tomato.findReferencingRecipes(recipes: [salad, soup, cake]);

      expect(referencing.map((Recipe recipe) => recipe.id).toList(), ["r-salad", "r-soup"]);
    });

    test("returns each recipe once even when the ingredient appears in multiple instructions", () {
      Recipe stew = Recipe(
        id: "r-stew",
        name: "Stew",
        instructions: [
          Instruction(id: "i1", description: "Chop", ingredientsUsed: [_usage("ing-tomato")]),
          Instruction(id: "i2", description: "Simmer", ingredientsUsed: [_usage("ing-tomato")]),
        ],
      );

      expect(tomato.findReferencingRecipes(recipes: [stew]).length, 1);
    });

    test("returns empty when no recipe uses the ingredient", () {
      Recipe cake = Recipe(
        id: "r-cake",
        name: "Cake",
        instructions: [
          Instruction(id: "i1", description: "Mix", ingredientsUsed: [_usage("ing-flour")]),
        ],
      );

      expect(tomato.findReferencingRecipes(recipes: [cake]), isEmpty);
    });
  });

  // ── Recipe.copyWithRemovedIngredientUsages ──

  group("Recipe.copyWithRemovedIngredientUsages", () {
    test("removes usages of the ingredient from every instruction", () {
      Recipe recipe = Recipe(
        id: "r1",
        name: "Stew",
        instructions: [
          Instruction(id: "i1", description: "Chop", ingredientsUsed: [_usage("ing-tomato"), _usage("ing-onion")]),
          Instruction(id: "i2", description: "Simmer", ingredientsUsed: [_usage("ing-tomato")]),
        ],
      );

      Recipe updated = recipe.copyWithRemovedIngredientUsages(ingredientId: "ing-tomato");

      expect(updated.instructions[0].ingredientsUsed.map((IngredientUsage usage) => usage.ingredient).toList(), ["ing-onion"]);
      expect(updated.instructions[1].ingredientsUsed, isEmpty);
    });

    test("keeps instruction count and order", () {
      Recipe recipe = Recipe(
        id: "r1",
        name: "Stew",
        instructions: [
          Instruction(id: "i1", description: "Chop", ingredientsUsed: [_usage("ing-tomato")]),
          const Instruction(id: "i2", description: "Rest"),
        ],
      );

      Recipe updated = recipe.copyWithRemovedIngredientUsages(ingredientId: "ing-tomato");

      expect(updated.instructions.map((Instruction instruction) => instruction.id).toList(), ["i1", "i2"]);
    });

    test("returns an equal recipe when the ingredient is not used", () {
      Recipe recipe = Recipe(
        id: "r1",
        name: "Cake",
        instructions: [
          Instruction(id: "i1", description: "Mix", ingredientsUsed: [_usage("ing-flour")]),
        ],
      );

      expect(recipe.copyWithRemovedIngredientUsages(ingredientId: "ing-tomato"), recipe);
    });
  });

  // ── Recipe.findDependentInstructions ──

  group("Recipe.findDependentInstructions", () {
    test("returns instructions consuming an output of the given instruction", () {
      Recipe recipe = const Recipe(
        id: "r1",
        name: "Multi-step",
        instructions: [
          Instruction(
            id: "i1",
            description: "Prep",
            outputs: [Result(id: "o1", description: "prepped")],
          ),
          Instruction(
            id: "i2",
            description: "Cook",
            inputs: ["o1"],
            outputs: [Result(id: "o2", description: "cooked")],
          ),
          Instruction(id: "i3", description: "Serve", inputs: ["o2"]),
        ],
      );

      List<Instruction> dependents = recipe.findDependentInstructions("i1");

      expect(dependents.map((Instruction instruction) => instruction.id).toList(), ["i2"]);
    });

    test("returns every instruction consuming any of the outputs", () {
      Recipe recipe = const Recipe(
        id: "r1",
        name: "Multi-step",
        instructions: [
          Instruction(
            id: "i1",
            description: "Prep",
            outputs: [
              Result(id: "o1", description: "a"),
              Result(id: "o2", description: "b"),
            ],
          ),
          Instruction(id: "i2", description: "Cook", inputs: ["o1"]),
          Instruction(id: "i3", description: "Serve", inputs: ["o2"]),
        ],
      );

      expect(recipe.findDependentInstructions("i1").map((Instruction instruction) => instruction.id).toList(), ["i2", "i3"]);
    });

    test("returns empty when the instruction has no outputs", () {
      Recipe recipe = const Recipe(
        id: "r1",
        name: "Multi-step",
        instructions: [
          Instruction(id: "i1", description: "Prep"),
          Instruction(id: "i2", description: "Cook"),
        ],
      );

      expect(recipe.findDependentInstructions("i1"), isEmpty);
    });

    test("returns empty when no instruction consumes the outputs", () {
      Recipe recipe = const Recipe(
        id: "r1",
        name: "Multi-step",
        instructions: [
          Instruction(
            id: "i1",
            description: "Prep",
            outputs: [Result(id: "o1", description: "prepped")],
          ),
          Instruction(id: "i2", description: "Cook"),
        ],
      );

      expect(recipe.findDependentInstructions("i1"), isEmpty);
    });

    test("returns empty for an unknown instruction id", () {
      Recipe recipe = const Recipe(id: "r1", name: "Empty");

      expect(recipe.findDependentInstructions("missing"), isEmpty);
    });
  });

  // ── Recipe.copyWithRemovedInstruction ──

  group("Recipe.copyWithRemovedInstruction", () {
    test("removes the instruction", () {
      Recipe recipe = const Recipe(
        id: "r1",
        name: "Multi-step",
        instructions: [
          Instruction(id: "i1", description: "Prep"),
          Instruction(id: "i2", description: "Cook"),
        ],
      );

      Recipe updated = recipe.copyWithRemovedInstruction(instructionId: "i1");

      expect(updated.instructions.map((Instruction instruction) => instruction.id).toList(), ["i2"]);
    });

    test("strips the removed instruction's output ids from other instructions' inputs", () {
      Recipe recipe = const Recipe(
        id: "r1",
        name: "Multi-step",
        instructions: [
          Instruction(
            id: "i1",
            description: "Prep",
            outputs: [Result(id: "o1", description: "prepped")],
          ),
          Instruction(
            id: "i2",
            description: "Cook",
            inputs: ["o1"],
            outputs: [Result(id: "o2", description: "cooked")],
          ),
          Instruction(id: "i3", description: "Serve", inputs: ["o2"]),
        ],
      );

      Recipe updated = recipe.copyWithRemovedInstruction(instructionId: "i1");

      expect(updated.instructions.map((Instruction instruction) => instruction.id).toList(), ["i2", "i3"]);
      expect(updated.instructions[0].inputs, isEmpty);
      expect(updated.instructions[1].inputs, ["o2"]);
    });

    test("returns an equal recipe for an unknown instruction id", () {
      Recipe recipe = const Recipe(
        id: "r1",
        name: "Multi-step",
        instructions: [Instruction(id: "i1", description: "Prep")],
      );

      expect(recipe.copyWithRemovedInstruction(instructionId: "missing"), recipe);
    });
  });

  // ── MultiWeekMenu.findReferencingMeals ──

  group("MultiWeekMenu.findReferencingMeals", () {
    test("returns week index and meal time for every slot using the recipe", () {
      Menu week0 = Menu(
        meals: [
          _meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipeId: "r-paella"),
          _meal(weekDay: WeekDay.sunday, mealType: MealType.dinner, recipeId: "r-salad"),
        ],
      );
      Menu week1 = Menu(
        meals: [_meal(weekDay: WeekDay.monday, mealType: MealType.dinner, recipeId: "r-paella")],
      );
      MultiWeekMenu menu = MultiWeekMenu(weeks: [week0, week1]);

      List<({int weekIndex, MealTime mealTime})> references = menu.findReferencingMeals("r-paella");

      expect(references, [
        (weekIndex: 0, mealTime: const MealTime(weekDay: WeekDay.saturday, mealType: MealType.lunch)),
        (weekIndex: 1, mealTime: const MealTime(weekDay: WeekDay.monday, mealType: MealType.dinner)),
      ]);
    });

    test("returns one entry per meal slot even when several sub-meals use the recipe", () {
      Meal meal = Meal(
        mealTime: const MealTime(weekDay: WeekDay.saturday, mealType: MealType.lunch),
        subMeals: const [
          SubMeal(cooking: Cooking(recipeId: "r-paella", yield: 1), people: 2),
          SubMeal(cooking: Cooking(recipeId: "r-paella", yield: 0), people: 1),
        ],
      );
      MultiWeekMenu menu = MultiWeekMenu(
        weeks: [
          Menu(meals: [meal]),
        ],
      );

      expect(menu.findReferencingMeals("r-paella").length, 1);
    });

    test("orders entries chronologically within a week", () {
      Menu week = Menu(
        meals: [
          _meal(weekDay: WeekDay.monday, mealType: MealType.dinner, recipeId: "r-paella"),
          _meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipeId: "r-paella"),
        ],
      );

      List<({int weekIndex, MealTime mealTime})> references = MultiWeekMenu(weeks: [week]).findReferencingMeals("r-paella");

      expect(references.first.mealTime.weekDay, WeekDay.saturday);
      expect(references.last.mealTime.weekDay, WeekDay.monday);
    });

    test("returns empty when the recipe is not used", () {
      MultiWeekMenu menu = MultiWeekMenu(
        weeks: [
          Menu(
            meals: [
              _meal(recipeId: "r-salad"),
              _meal(weekDay: WeekDay.sunday),
            ],
          ),
        ],
      );

      expect(menu.findReferencingMeals("r-paella"), isEmpty);
    });
  });

  // ── MultiWeekMenu.copyWithClearedRecipe ──

  group("MultiWeekMenu.copyWithClearedRecipe", () {
    test("clears the cooking of every sub-meal using the recipe across weeks", () {
      const Recipe paella = Recipe(id: "r-paella", name: "Paella");
      const Recipe salad = Recipe(id: "r-salad", name: "Salad");
      Menu week0 = Menu(
        meals: [
          _meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipeId: "r-paella", yield: 2),
          _meal(weekDay: WeekDay.sunday, mealType: MealType.lunch, recipeId: "r-paella", yield: 0),
          _meal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipeId: "r-salad"),
        ],
      );
      Menu week1 = Menu(
        meals: [_meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipeId: "r-paella")],
      );
      MultiWeekMenu menu = MultiWeekMenu(weeks: [week0, week1]);

      MultiWeekMenu cleared = menu.copyWithClearedRecipe(recipeId: "r-paella", recipes: [paella, salad]);

      for (Menu week in cleared.weeks) {
        for (Meal meal in week.meals) {
          for (SubMeal subMeal in meal.subMeals) {
            expect(subMeal.cooking?.recipeId, isNot("r-paella"));
          }
        }
      }
      // The sub-meal itself stays; only its cooking is cleared.
      expect(cleared.weeks[0].meals[0].subMeals.single.cooking, isNull);
      expect(cleared.weeks[0].meals[0].subMeals.single.people, 2);
    });

    test("keeps other recipes' cookings and recalculates their yields", () {
      const Recipe paella = Recipe(id: "r-paella", name: "Paella");
      const Recipe salad = Recipe(id: "r-salad", name: "Salad", maxStorageDays: 6);
      Menu week = Menu(
        meals: [
          _meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipeId: "r-paella"),
          // Yields intentionally wrong so the recalculation is observable.
          _meal(weekDay: WeekDay.sunday, mealType: MealType.lunch, recipeId: "r-salad", yield: 0),
          _meal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipeId: "r-salad", yield: 0),
        ],
      );

      MultiWeekMenu cleared = MultiWeekMenu(weeks: [week]).copyWithClearedRecipe(recipeId: "r-paella", recipes: [paella, salad]);

      Meal sundayMeal = cleared.weeks[0].meals[1];
      Meal mondayMeal = cleared.weeks[0].meals[2];
      expect(sundayMeal.subMeals.single.cooking!.recipeId, "r-salad");
      expect(sundayMeal.subMeals.single.cooking!.yield, 2); // Cooks on Sunday for both salad days
      expect(mondayMeal.subMeals.single.cooking!.yield, 0); // Leftovers
    });
  });

  // ── RecipesProvider.removeInstruction ──

  group("RecipesProvider.removeInstruction", () {
    setUp(() {
      // Reset state before each test. Also reset ingredients to avoid _checkIngredientsValidity issues
      RecipesProvider.instance.setData([], ingredients: []);
      IngredientsProvider.instance.setData([]);
    });

    test("removes orphaned input references from the remaining instructions", () {
      RecipesProvider.addOrUpdate(
        newRecipe: const Recipe(
          id: "r1",
          name: "Multi-step",
          instructions: [
            Instruction(
              id: "i1",
              description: "Prep",
              outputs: [Result(id: "o1", description: "prepped")],
            ),
            Instruction(
              id: "i2",
              description: "Cook",
              inputs: ["o1"],
              outputs: [Result(id: "o2", description: "cooked")],
            ),
            Instruction(id: "i3", description: "Serve", inputs: ["o2"]),
          ],
        ),
      );

      RecipesProvider.removeInstruction(recipeId: "r1", instructionId: "i1");

      Recipe recipe = RecipesProvider.instance.get("r1");
      expect(recipe.instructions.map((Instruction instruction) => instruction.id).toList(), ["i2", "i3"]);
      expect(recipe.instructions.first.inputs, isEmpty); // "o1" no longer exists
      expect(recipe.instructions.last.inputs, ["o2"]); // Still produced by i2
    });
  });

  // ── MenuProvider active menu ──

  group("MenuProvider.setMultiWeekMenu", () {
    setUp(() {
      MenuProvider.setMultiWeekMenu(null);
    });

    test("stores the active menu so delete flows can check references against it", () {
      MultiWeekMenu menu = MultiWeekMenu(
        weeks: [
          Menu(meals: [_meal(recipeId: "r-paella")]),
        ],
      );

      MenuProvider.setMultiWeekMenu(menu);

      expect(MenuProvider.instance.multiWeekMenu, menu);
    });

    test("clears the active menu when set to null", () {
      MenuProvider.setMultiWeekMenu(
        MultiWeekMenu(
          weeks: [
            Menu(meals: [_meal()]),
          ],
        ),
      );

      MenuProvider.setMultiWeekMenu(null);

      expect(MenuProvider.instance.multiWeekMenu, isNull);
    });
  });
}
