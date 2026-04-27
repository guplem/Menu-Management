import "dart:convert";

import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:menu_management/ingredients/ingredients_provider.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/menu/models/cooking.dart";
import "package:menu_management/menu/models/multi_week_menu.dart";
import "package:menu_management/persistency.dart";
import "package:menu_management/recipes/models/recipe.dart";
import "package:menu_management/recipes/recipes_provider.dart";

/// Workaround: `yield` is a reserved keyword in async methods, so we access it via a sync helper.
int cookingYield(Cooking cooking) => cooking.yield;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    IngredientsProvider.instance.setData([]);
    RecipesProvider.instance.setData([], ingredients: []);
  });

  // ── Helper: parse expected data straight from the asset files ──

  Future<Map<String, dynamic>> loadRawTsr() async {
    String data = await rootBundle.loadString("assets/RecipeBook.tsr");
    return Map<String, dynamic>.from(jsonDecode(data));
  }

  Future<Map<String, dynamic>> loadRawTsm() async {
    String data = await rootBundle.loadString("assets/DefaultMenu.tsm");
    return Map<String, dynamic>.from(jsonDecode(data));
  }

  /// Loads recipes into providers so they are available for menu loading.
  Future<List<Recipe>> loadRecipesAndGetList() async {
    await Persistency.loadDefaultRecipes(ingredientsProvider: IngredientsProvider.instance, recipesProvider: RecipesProvider.instance);
    return RecipesProvider.instance.recipes;
  }

  group("loadDefaultRecipes", () {
    test("loads all ingredients from the asset", () async {
      Map<String, dynamic> rawTsr = await loadRawTsr();
      List<dynamic> expectedIngredients = rawTsr["Ingredients"];

      await Persistency.loadDefaultRecipes(ingredientsProvider: IngredientsProvider.instance, recipesProvider: RecipesProvider.instance);

      List<Ingredient> loaded = IngredientsProvider.instance.ingredients;
      expect(loaded.length, expectedIngredients.length);

      for (Map<String, dynamic> expected in expectedIngredients) {
        expect(
          loaded.any((i) => i.id == expected["id"] && i.name == expected["name"]),
          true,
          reason: "Ingredient '${expected["name"]}' (${expected["id"]}) should be loaded",
        );
      }
    });

    test("loads all recipes from the asset", () async {
      Map<String, dynamic> rawTsr = await loadRawTsr();
      List<dynamic> expectedRecipes = rawTsr["Recipes"];

      await Persistency.loadDefaultRecipes(ingredientsProvider: IngredientsProvider.instance, recipesProvider: RecipesProvider.instance);

      List<Recipe> loaded = RecipesProvider.instance.recipes;
      expect(loaded.length, expectedRecipes.length);

      for (Map<String, dynamic> expected in expectedRecipes) {
        Recipe? match = loaded.where((r) => r.id == expected["id"]).firstOrNull;
        expect(match, isNotNull, reason: "Recipe '${expected["name"]}' (${expected["id"]}) should be loaded");
        expect(match!.name, expected["name"]);
      }
    });

    test("recipe nutritional flags match the asset", () async {
      Map<String, dynamic> rawTsr = await loadRawTsr();
      List<dynamic> expectedRecipes = rawTsr["Recipes"];

      await Persistency.loadDefaultRecipes(ingredientsProvider: IngredientsProvider.instance, recipesProvider: RecipesProvider.instance);

      for (Map<String, dynamic> expected in expectedRecipes) {
        Recipe loaded = RecipesProvider.instance.recipes.firstWhere((r) => r.id == expected["id"]);
        expect(loaded.carbs, expected["carbs"] ?? true, reason: "${loaded.name} carbs");
        expect(loaded.proteins, expected["proteins"] ?? true, reason: "${loaded.name} proteins");
        expect(loaded.vegetables, expected["vegetables"] ?? true, reason: "${loaded.name} vegetables");
      }
    });
  });

  group("loadDefaultMenu", () {
    test("loads the correct number of weeks from the asset", () async {
      Map<String, dynamic> rawTsm = await loadRawTsm();
      int expectedWeeks = (rawTsm["weeks"] as List).length;
      List<Recipe> recipes = await loadRecipesAndGetList();

      MultiWeekMenu menu = await Persistency.loadDefaultMenu(recipes: recipes);

      expect(menu.weekCount, expectedWeeks);
    });

    test("each week has the correct number of meals", () async {
      Map<String, dynamic> rawTsm = await loadRawTsm();
      List<dynamic> rawWeeks = rawTsm["weeks"];
      List<Recipe> recipes = await loadRecipesAndGetList();

      MultiWeekMenu menu = await Persistency.loadDefaultMenu(recipes: recipes);

      for (int i = 0; i < menu.weekCount; i++) {
        int expectedMeals = (rawWeeks[i]["meals"] as List).length;
        expect(menu.weeks[i].meals.length, expectedMeals, reason: "Week ${i + 1} meal count");
      }
    });

    test("all meals have a recipe assigned", () async {
      List<Recipe> recipes = await loadRecipesAndGetList();
      MultiWeekMenu menu = await Persistency.loadDefaultMenu(recipes: recipes);

      for (int w = 0; w < menu.weekCount; w++) {
        for (var meal in menu.weeks[w].meals) {
          expect(meal.subMeals.first.cooking, isNotNull, reason: "Week ${w + 1} ${meal.mealTime.weekDay} ${meal.mealTime.mealType} should have a recipe");
        }
      }
    });

    test("meal recipeIds and yields match the asset exactly", () async {
      Map<String, dynamic> rawTsm = await loadRawTsm();
      List<dynamic> rawWeeks = rawTsm["weeks"];
      List<Recipe> recipes = await loadRecipesAndGetList();

      MultiWeekMenu menu = await Persistency.loadDefaultMenu(recipes: recipes);

      for (int w = 0; w < menu.weekCount; w++) {
        List<dynamic> rawMeals = rawWeeks[w]["meals"];
        for (int m = 0; m < menu.weeks[w].meals.length; m++) {
          var loaded = menu.weeks[w].meals[m];
          Map<String, dynamic> raw = rawMeals[m];

          // Old-format TSM files have cooking/people at meal level; migration moves them to subMeals
          Map<String, dynamic>? rawCooking = raw["cooking"] ?? raw["subMeals"]?[0]?["cooking"];
          String rawRecipeId = rawCooking!["recipeId"];
          int rawYield = rawCooking["yield"];

          expect(loaded.subMeals.first.cooking!.recipeId, rawRecipeId, reason: "Week ${w + 1} meal $m recipeId");
          expect(cookingYield(loaded.subMeals.first.cooking!), rawYield, reason: "Week ${w + 1} meal $m yield");
        }
      }
    });
  });

  group("referential integrity", () {
    test("every ingredient referenced by a recipe exists", () async {
      await Persistency.loadDefaultRecipes(ingredientsProvider: IngredientsProvider.instance, recipesProvider: RecipesProvider.instance);

      Set<String> ingredientIds = IngredientsProvider.instance.ingredients.map((i) => i.id).toSet();
      List<Recipe> recipes = RecipesProvider.instance.recipes;

      for (Recipe recipe in recipes) {
        for (var instruction in recipe.instructions) {
          for (var usage in instruction.ingredientsUsed) {
            expect(
              ingredientIds.contains(usage.ingredient),
              true,
              reason: "Recipe '${recipe.name}' instruction '${instruction.description}' references missing ingredient ID '${usage.ingredient}'",
            );
          }
        }
      }
    });

    test("every instruction input references an output within the same recipe", () async {
      await Persistency.loadDefaultRecipes(ingredientsProvider: IngredientsProvider.instance, recipesProvider: RecipesProvider.instance);

      for (Recipe recipe in RecipesProvider.instance.recipes) {
        Set<String> outputIds = recipe.instructions.expand((i) => i.outputs).map((o) => o.id).toSet();

        for (var instruction in recipe.instructions) {
          for (String inputId in instruction.inputs) {
            expect(
              outputIds.contains(inputId),
              true,
              reason: "Recipe '${recipe.name}' instruction '${instruction.description}' references missing output ID '$inputId'",
            );
          }
        }
      }
    });

    test("every recipe in the default menu exists in the recipe book", () async {
      List<Recipe> recipes = await loadRecipesAndGetList();
      MultiWeekMenu menu = await Persistency.loadDefaultMenu(recipes: recipes);

      Set<String> recipeIds = recipes.map((r) => r.id).toSet();

      for (int w = 0; w < menu.weekCount; w++) {
        for (var meal in menu.weeks[w].meals) {
          if (meal.subMeals.first.cooking != null) {
            expect(
              recipeIds.contains(meal.subMeals.first.cooking!.recipeId),
              true,
              reason: "Week ${w + 1} ${meal.mealTime.weekDay} ${meal.mealTime.mealType} references missing recipe ID '${meal.subMeals.first.cooking!.recipeId}'",
            );
          }
        }
      }
    });

    test("no duplicate ingredient IDs", () async {
      await Persistency.loadDefaultRecipes(ingredientsProvider: IngredientsProvider.instance, recipesProvider: RecipesProvider.instance);

      List<String> ids = IngredientsProvider.instance.ingredients.map((i) => i.id).toList();
      expect(ids.toSet().length, ids.length, reason: "Duplicate ingredient IDs found");
    });

    test("no duplicate recipe IDs", () async {
      await Persistency.loadDefaultRecipes(ingredientsProvider: IngredientsProvider.instance, recipesProvider: RecipesProvider.instance);

      List<String> ids = RecipesProvider.instance.recipes.map((r) => r.id).toList();
      expect(ids.toSet().length, ids.length, reason: "Duplicate recipe IDs found");
    });

    test("no duplicate instruction IDs within a recipe", () async {
      await Persistency.loadDefaultRecipes(ingredientsProvider: IngredientsProvider.instance, recipesProvider: RecipesProvider.instance);

      for (Recipe recipe in RecipesProvider.instance.recipes) {
        List<String> ids = recipe.instructions.map((i) => i.id).toList();
        expect(ids.toSet().length, ids.length, reason: "Recipe '${recipe.name}' has duplicate instruction IDs");
      }
    });

    test("no duplicate output IDs within a recipe", () async {
      await Persistency.loadDefaultRecipes(ingredientsProvider: IngredientsProvider.instance, recipesProvider: RecipesProvider.instance);

      for (Recipe recipe in RecipesProvider.instance.recipes) {
        List<String> outputIds = recipe.instructions.expand((i) => i.outputs).map((o) => o.id).toList();
        expect(outputIds.toSet().length, outputIds.length, reason: "Recipe '${recipe.name}' has duplicate output IDs");
      }
    });
  });
}
