import "package:flutter_test/flutter_test.dart";
import "package:menu_management/ingredients/ingredients_provider.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/recipes/enums/recipe_type.dart";
import "package:menu_management/recipes/models/instruction.dart";
import "package:menu_management/recipes/models/recipe.dart";
import "package:menu_management/recipes/models/result.dart";
import "package:menu_management/recipes/recipes_provider.dart";

void main() {
  // ── IngredientsProvider ──

  group("IngredientsProvider", () {
    setUp(() {
      // Reset state before each test
      IngredientsProvider.instance.setData([]);
      IngredientsProvider.instance.searchHistory.clear();
    });

    group("addOrUpdate", () {
      test("adds new ingredient", () {
        Ingredient ingredient = const Ingredient(id: "ing1", name: "Flour");
        IngredientsProvider.addOrUpdate(newIngredient: ingredient);
        expect(IngredientsProvider.instance.ingredients.length, 1);
        expect(IngredientsProvider.instance.ingredients.first.name, "Flour");
      });

      test("updates existing ingredient by id", () {
        Ingredient original = const Ingredient(id: "ing1", name: "Flour");
        Ingredient updated = const Ingredient(id: "ing1", name: "Whole Wheat Flour");
        IngredientsProvider.addOrUpdate(newIngredient: original);
        IngredientsProvider.addOrUpdate(newIngredient: updated);
        expect(IngredientsProvider.instance.ingredients.length, 1);
        expect(IngredientsProvider.instance.ingredients.first.name, "Whole Wheat Flour");
      });
    });

    group("remove", () {
      test("removes ingredient by id", () {
        IngredientsProvider.addOrUpdate(newIngredient: const Ingredient(id: "ing1", name: "Flour"));
        IngredientsProvider.addOrUpdate(newIngredient: const Ingredient(id: "ing2", name: "Sugar"));
        IngredientsProvider.remove(ingredientId: "ing1");
        expect(IngredientsProvider.instance.ingredients.length, 1);
        expect(IngredientsProvider.instance.ingredients.first.id, "ing2");
      });

      test("does nothing for non-existent id", () {
        IngredientsProvider.addOrUpdate(newIngredient: const Ingredient(id: "ing1", name: "Flour"));
        IngredientsProvider.remove(ingredientId: "nonexistent");
        expect(IngredientsProvider.instance.ingredients.length, 1);
      });
    });

    group("get", () {
      test("returns ingredient by id", () {
        IngredientsProvider.addOrUpdate(newIngredient: const Ingredient(id: "ing1", name: "Flour"));
        Ingredient result = IngredientsProvider.instance.get("ing1");
        expect(result.name, "Flour");
      });
    });

    group("setData", () {
      test("replaces all ingredients", () {
        IngredientsProvider.addOrUpdate(newIngredient: const Ingredient(id: "old", name: "Old"));
        IngredientsProvider.instance.setData([const Ingredient(id: "new1", name: "New1"), const Ingredient(id: "new2", name: "New2")]);
        expect(IngredientsProvider.instance.ingredients.length, 2);
        expect(IngredientsProvider.instance.ingredients.first.id, "new1");
      });
    });

    group("isValidNewIngredient", () {
      test("returns true for unique name", () {
        IngredientsProvider.addOrUpdate(newIngredient: const Ingredient(id: "ing1", name: "Flour"));
        expect(IngredientsProvider.instance.isValidNewIngredient("Sugar"), true);
      });

      test("returns false for duplicate name (case insensitive)", () {
        IngredientsProvider.addOrUpdate(newIngredient: const Ingredient(id: "ing1", name: "Flour"));
        expect(IngredientsProvider.instance.isValidNewIngredient("flour"), false);
        expect(IngredientsProvider.instance.isValidNewIngredient("FLOUR"), false);
      });

      test("trims whitespace before comparing", () {
        IngredientsProvider.addOrUpdate(newIngredient: const Ingredient(id: "ing1", name: "Flour"));
        expect(IngredientsProvider.instance.isValidNewIngredient("  Flour  "), false);
      });
    });

    group("addIngredientToHistory", () {
      test("adds ingredient to the front of history", () {
        Ingredient ing = const Ingredient(id: "ing1", name: "Flour");
        IngredientsProvider.addOrUpdate(newIngredient: ing);
        IngredientsProvider.addIngredientToHistory(ing);
        expect(IngredientsProvider.instance.searchHistory.first, ing);
      });

      test("does not add duplicate", () {
        Ingredient ing = const Ingredient(id: "ing1", name: "Flour");
        IngredientsProvider.addOrUpdate(newIngredient: ing);
        IngredientsProvider.addIngredientToHistory(ing);
        IngredientsProvider.addIngredientToHistory(ing);
        expect(IngredientsProvider.instance.searchHistory.length, 1);
      });

      test("caps history at 10 items", () {
        for (int i = 0; i < 12; i++) {
          Ingredient ing = Ingredient(id: "ing$i", name: "Ingredient $i");
          IngredientsProvider.addOrUpdate(newIngredient: ing);
          IngredientsProvider.addIngredientToHistory(ing);
        }
        expect(IngredientsProvider.instance.searchHistory.length, 10);
        // Most recent should be first
        expect(IngredientsProvider.instance.searchHistory.first.id, "ing11");
      });
    });
  });

  // ── RecipesProvider ──

  group("RecipesProvider", () {
    setUp(() {
      // Reset state before each test. Also reset ingredients to avoid _checkIngredientsValidity issues
      RecipesProvider.instance.setData([]);
      IngredientsProvider.instance.setData([]);
    });

    group("addOrUpdate", () {
      test("adds new recipe", () {
        RecipesProvider.addOrUpdate(newRecipe: const Recipe(id: "r1", name: "Pasta"));
        expect(RecipesProvider.instance.recipes.length, 1);
        expect(RecipesProvider.instance.recipes.first.name, "Pasta");
      });

      test("updates existing recipe by id", () {
        RecipesProvider.addOrUpdate(newRecipe: const Recipe(id: "r1", name: "Pasta"));
        RecipesProvider.addOrUpdate(newRecipe: const Recipe(id: "r1", name: "Spaghetti"));
        expect(RecipesProvider.instance.recipes.length, 1);
        expect(RecipesProvider.instance.recipes.first.name, "Spaghetti");
      });
    });

    group("remove", () {
      test("removes recipe by id", () {
        RecipesProvider.addOrUpdate(newRecipe: const Recipe(id: "r1", name: "Pasta"));
        RecipesProvider.addOrUpdate(newRecipe: const Recipe(id: "r2", name: "Salad"));
        RecipesProvider.remove(recipeId: "r1");
        expect(RecipesProvider.instance.recipes.length, 1);
        expect(RecipesProvider.instance.recipes.first.id, "r2");
      });
    });

    group("get", () {
      test("returns recipe by id", () {
        RecipesProvider.addOrUpdate(newRecipe: const Recipe(id: "r1", name: "Pasta"));
        expect(RecipesProvider.instance.get("r1").name, "Pasta");
      });

      test("throws for unknown id", () {
        expect(() => RecipesProvider.instance.get("nonexistent"), throwsStateError);
      });
    });

    group("getOfType", () {
      test("filters by type", () {
        RecipesProvider.addOrUpdate(newRecipe: const Recipe(id: "r1", name: "Pancakes", type: RecipeType.breakfast));
        RecipesProvider.addOrUpdate(newRecipe: const Recipe(id: "r2", name: "Pasta", type: RecipeType.meal));
        RecipesProvider.addOrUpdate(newRecipe: const Recipe(id: "r3", name: "Cake", type: RecipeType.dessert));

        List<Recipe> meals = RecipesProvider.instance.getOfType(type: RecipeType.meal);
        expect(meals.length, 1);
        expect(meals.first.name, "Pasta");
      });

      test("excludes recipes not included in menu generation", () {
        RecipesProvider.addOrUpdate(newRecipe: const Recipe(id: "r1", name: "Pasta", type: RecipeType.meal, includeInMenuGeneration: false));
        List<Recipe> meals = RecipesProvider.instance.getOfType(type: RecipeType.meal);
        expect(meals, isEmpty);
      });

      test("filters by nutritional flags", () {
        RecipesProvider.addOrUpdate(newRecipe: const Recipe(id: "r1", name: "Pasta", carbs: true, proteins: false, vegetables: false));
        RecipesProvider.addOrUpdate(newRecipe: const Recipe(id: "r2", name: "Steak", carbs: false, proteins: true, vegetables: false));

        List<Recipe> carbsOnly = RecipesProvider.instance.getOfType(type: RecipeType.meal, carbs: true, proteins: false);
        expect(carbsOnly.length, 1);
        expect(carbsOnly.first.name, "Pasta");
      });
    });

    group("instruction management", () {
      test("addOrUpdateInstruction adds new instruction", () {
        RecipesProvider.addOrUpdate(newRecipe: const Recipe(id: "r1", name: "Pasta"));
        RecipesProvider.addOrUpdateInstruction(
          recipeId: "r1",
          newInstruction: const Instruction(id: "i1", description: "Boil water"),
        );
        Recipe recipe = RecipesProvider.instance.get("r1");
        expect(recipe.instructions.length, 1);
        expect(recipe.instructions.first.description, "Boil water");
      });

      test("addOrUpdateInstruction updates existing instruction", () {
        RecipesProvider.addOrUpdate(
          newRecipe: const Recipe(id: "r1", name: "Pasta", instructions: [Instruction(id: "i1", description: "Boil water")]),
        );
        RecipesProvider.addOrUpdateInstruction(
          recipeId: "r1",
          newInstruction: const Instruction(id: "i1", description: "Boil salted water"),
        );
        Recipe recipe = RecipesProvider.instance.get("r1");
        expect(recipe.instructions.length, 1);
        expect(recipe.instructions.first.description, "Boil salted water");
      });

      test("removeInstruction removes by id", () {
        RecipesProvider.addOrUpdate(
          newRecipe: const Recipe(
            id: "r1",
            name: "Pasta",
            instructions: [Instruction(id: "i1", description: "Step 1"), Instruction(id: "i2", description: "Step 2")],
          ),
        );
        RecipesProvider.removeInstruction(recipeId: "r1", instructionId: "i1");
        Recipe recipe = RecipesProvider.instance.get("r1");
        expect(recipe.instructions.length, 1);
        expect(recipe.instructions.first.id, "i2");
      });

      test("reorderInstructions moves instruction", () {
        RecipesProvider.addOrUpdate(
          newRecipe: const Recipe(
            id: "r1",
            name: "Pasta",
            instructions: [
              Instruction(id: "i1", description: "Step A"),
              Instruction(id: "i2", description: "Step B"),
              Instruction(id: "i3", description: "Step C"),
            ],
          ),
        );
        // Move Step A (index 0) to index 2
        RecipesProvider.reorderInstructions(recipeId: "r1", oldIndex: 0, newIndex: 2);
        Recipe recipe = RecipesProvider.instance.get("r1");
        expect(recipe.instructions[0].id, "i2");
        expect(recipe.instructions[1].id, "i3");
        expect(recipe.instructions[2].id, "i1");
      });
    });

    group("results and inputs", () {
      test("getResults finds results matching input ids across recipes", () {
        RecipesProvider.addOrUpdate(
          newRecipe: const Recipe(
            id: "r1",
            name: "Pasta",
            instructions: [
              Instruction(id: "i1", description: "Step", outputs: [Result(id: "o1", description: "cooked pasta")]),
              Instruction(id: "i2", description: "Step", outputs: [Result(id: "o2", description: "sauce")]),
            ],
          ),
        );
        List<Result> results = RecipesProvider.instance.getResults(["o1", "o2"]);
        expect(results.length, 2);
        expect(results.any((r) => r.id == "o1"), true);
        expect(results.any((r) => r.id == "o2"), true);
      });

      test("getResults returns empty for no matches", () {
        RecipesProvider.addOrUpdate(newRecipe: const Recipe(id: "r1", name: "Pasta"));
        expect(RecipesProvider.instance.getResults(["nonexistent"]), isEmpty);
      });

      test("getRecipeInputsAvailability marks already-taken inputs as unavailable", () {
        RecipesProvider.addOrUpdate(
          newRecipe: const Recipe(
            id: "r1",
            name: "Multi-step",
            instructions: [
              Instruction(id: "i1", description: "First", outputs: [Result(id: "o1", description: "intermediate")]),
              Instruction(id: "i2", description: "Second", inputs: ["o1"], outputs: [Result(id: "o2", description: "final")]),
              Instruction(id: "i3", description: "Third", inputs: []),
            ],
          ),
        );

        // For instruction i3: o1 is taken by i2, o2 is available
        Map<Result, bool> availability = RecipesProvider.instance.getRecipeInputsAvailability(recipeId: "r1", forInstruction: "i3");
        Result o1 = const Result(id: "o1", description: "intermediate");
        Result o2 = const Result(id: "o2", description: "final");

        expect(availability[o1], false); // taken by i2
        expect(availability[o2], true); // available
      });

      test("getRecipeInputsAvailability excludes outputs from subsequent instructions", () {
        RecipesProvider.addOrUpdate(
          newRecipe: const Recipe(
            id: "r1",
            name: "Multi-step",
            instructions: [
              Instruction(id: "i1", description: "First", outputs: [Result(id: "o1", description: "first output")]),
              Instruction(id: "i2", description: "Second", outputs: [Result(id: "o2", description: "second output")]),
              Instruction(id: "i3", description: "Third", outputs: [Result(id: "o3", description: "third output")]),
            ],
          ),
        );

        // For instruction i1: o2 and o3 come from later instructions, so they should be unavailable
        Map<Result, bool> availability = RecipesProvider.instance.getRecipeInputsAvailability(recipeId: "r1", forInstruction: "i1");
        Result o2 = const Result(id: "o2", description: "second output");
        Result o3 = const Result(id: "o3", description: "third output");

        expect(availability[o2], false); // from subsequent instruction i2
        expect(availability[o3], false); // from subsequent instruction i3
      });

      test("getRecipeInputsAvailability excludes results whose ID matches the instruction ID", () {
        // The check `forInstruction != element.id` blocks results whose ID equals the instruction ID.
        // This is a name-collision guard, not a general self-output check.
        RecipesProvider.addOrUpdate(
          newRecipe: const Recipe(
            id: "r1",
            name: "Multi-step",
            instructions: [
              Instruction(id: "i1", description: "First", outputs: [Result(id: "i2", description: "result with same id as instruction i2")]),
              Instruction(id: "i2", description: "Second", outputs: [Result(id: "o2", description: "second output")]),
            ],
          ),
        );

        // For instruction i2: result "i2" has the same ID as the instruction, so it's excluded
        Map<Result, bool> availability = RecipesProvider.instance.getRecipeInputsAvailability(recipeId: "r1", forInstruction: "i2");
        Result resultWithInstructionId = const Result(id: "i2", description: "result with same id as instruction i2");

        expect(availability[resultWithInstructionId], false);
      });
    });

    group("setData", () {
      test("replaces all recipes", () {
        RecipesProvider.addOrUpdate(newRecipe: const Recipe(id: "old", name: "Old"));
        RecipesProvider.instance.setData([const Recipe(id: "new1", name: "New1"), const Recipe(id: "new2", name: "New2")]);
        expect(RecipesProvider.instance.recipes.length, 2);
        expect(RecipesProvider.instance.recipes.first.id, "new1");
      });
    });
  });
}
