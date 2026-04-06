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
          expect(meal.cooking, isNotNull, reason: "Week ${w + 1} ${meal.mealTime.weekDay} ${meal.mealTime.mealType} should have a recipe");
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

          String rawRecipeId = raw["cooking"]["recipeId"];
          int rawYield = raw["cooking"]["yield"];

          expect(loaded.cooking!.recipeId, rawRecipeId, reason: "Week ${w + 1} meal $m recipeId");
          expect(cookingYield(loaded.cooking!), rawYield, reason: "Week ${w + 1} meal $m yield");
        }
      }
    });
  });
}
