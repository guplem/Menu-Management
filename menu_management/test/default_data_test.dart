import "dart:convert";

import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:menu_management/ingredients/ingredients_provider.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/menu/models/cooking.dart";
import "package:menu_management/menu/enums/meal_type.dart";
import "package:menu_management/menu/enums/week_day.dart";
import "package:menu_management/menu/models/meal.dart";
import "package:menu_management/menu/models/multi_week_menu.dart";
import "package:menu_management/menu/models/sub_meal.dart";
import "package:menu_management/persistency.dart";
import "package:menu_management/recipes/enums/recipe_type.dart";
import "package:menu_management/recipes/models/ingredient_usage.dart";
import "package:menu_management/recipes/models/instruction.dart";
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
          expect(
            meal.subMeals.first.cooking,
            isNotNull,
            reason: "Week ${w + 1} ${meal.mealTime.weekDay} ${meal.mealTime.mealType} should have a recipe",
          );
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
              reason:
                  "Week ${w + 1} ${meal.mealTime.weekDay} ${meal.mealTime.mealType} references missing recipe ID '${meal.subMeals.first.cooking!.recipeId}'",
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

    test("no lunch or dinner recipe repeats on two days in a row, including across week boundaries", () async {
      List<Recipe> recipes = await loadRecipesAndGetList();
      MultiWeekMenu menu = await Persistency.loadDefaultMenu(recipes: recipes);

      // Day 0 is week 1 Saturday and day 20 is week 3 Friday, so the last day of a week and the
      // first day of the next week are next to each other. Breakfasts are left out because the
      // default menu repeats the same breakfast every weekday on purpose.
      Map<int, Set<String>> recipeIdsPerDay = {};
      for (int w = 0; w < menu.weekCount; w++) {
        for (Meal meal in menu.weeks[w].meals) {
          if (meal.mealTime.mealType == MealType.breakfast) {
            continue;
          }
          int dayIndex = w * WeekDay.values.length + meal.mealTime.weekDay.value;
          for (SubMeal subMeal in meal.subMeals) {
            if (subMeal.cooking != null) {
              recipeIdsPerDay.putIfAbsent(dayIndex, () => <String>{}).add(subMeal.cooking!.recipeId);
            }
          }
        }
      }

      Map<String, String> recipeNameById = {for (Recipe recipe in recipes) recipe.id: recipe.name};
      int lastDayIndex = menu.weekCount * WeekDay.values.length - 1;
      for (int day = 0; day < lastDayIndex; day++) {
        Set<String> repeated = (recipeIdsPerDay[day] ?? <String>{}).intersection(recipeIdsPerDay[day + 1] ?? <String>{});
        expect(
          repeated,
          isEmpty,
          reason: "Day $day and day ${day + 1} both serve ${repeated.map((String id) => recipeNameById[id] ?? id).join(", ")}",
        );
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

  group("Ensalada César", () {
    const String ensaladaCesarId = "3f2c81a0-5d4e-4c1b-9a77-2b6f0d91c4ee";

    test("the recipe book holds it as a dinner meal with carbs, proteins and vegetables", () async {
      await Persistency.loadDefaultRecipes(ingredientsProvider: IngredientsProvider.instance, recipesProvider: RecipesProvider.instance);

      Recipe recipe = RecipesProvider.instance.recipes.firstWhere((Recipe r) => r.id == ensaladaCesarId);

      expect(recipe.name, "Ensalada César");
      expect(recipe.type, RecipeType.meal);
      expect(recipe.lunch, false);
      expect(recipe.dinner, true);
      expect(recipe.carbs, true);
      expect(recipe.proteins, true);
      expect(recipe.vegetables, true);
      expect(recipe.maxStorageDays, 0);
      expect(recipe.includeInMenuGeneration, true);
    });

    test("it uses the Caesar salad ingredients with the expected amounts", () async {
      await Persistency.loadDefaultRecipes(ingredientsProvider: IngredientsProvider.instance, recipesProvider: RecipesProvider.instance);

      Recipe recipe = RecipesProvider.instance.recipes.firstWhere((Recipe r) => r.id == ensaladaCesarId);
      Map<String, Ingredient> ingredientById = {for (Ingredient i in IngredientsProvider.instance.ingredients) i.id: i};

      Map<String, String> amountByIngredientName = {
        for (Instruction instruction in recipe.instructions)
          for (IngredientUsage usage in instruction.ingredientsUsed)
            ingredientById[usage.ingredient]!.name: "${usage.quantity.amount} ${usage.quantity.unit.name}",
      };

      expect(amountByIngredientName, {
        "Lechuga Romana": "200.0 grams",
        "Tiras de pechuga de pollo": "140.0 grams",
        "Queso curado y cheddar en dados": "100.0 grams",
        "Picatostes": "30.0 grams",
        "Parmesano (o Grana Padano) rallado": "20.0 grams",
        "Salsa César": "6.0 centiliters",
      });
    });

    test("each new ingredient carries its Mercadona product", () async {
      await Persistency.loadDefaultRecipes(ingredientsProvider: IngredientsProvider.instance, recipesProvider: RecipesProvider.instance);

      Map<String, Ingredient> ingredientByName = {for (Ingredient i in IngredientsProvider.instance.ingredients) i.name: i};

      Map<String, String> expectedPacks = {
        "Lechuga Romana": "1x200.0 grams",
        "Tiras de pechuga de pollo": "1x140.0 grams",
        "Queso curado y cheddar en dados": "1x125.0 grams",
        "Picatostes": "1x100.0 grams",
        "Salsa César": "1x31.0 centiliters",
      };

      for (MapEntry<String, String> expected in expectedPacks.entries) {
        Ingredient ingredient = ingredientByName[expected.key]!;
        expect(ingredient.products.length, 1, reason: "${expected.key} product count");
        Product product = ingredient.products.first;
        expect("${product.itemsPerPack}x${product.quantityPerItem} ${product.unit.name}", expected.value, reason: "${expected.key} pack size");
        expect(product.link.startsWith("https://tienda.mercadona.es/product/"), true, reason: "${expected.key} store link");
      }
    });

    test("it replaces the salmon salad on week 3 Wednesday dinner", () async {
      List<Recipe> recipes = await loadRecipesAndGetList();
      MultiWeekMenu menu = await Persistency.loadDefaultMenu(recipes: recipes);

      Meal wednesdayDinner = menu.weeks[2].meals.firstWhere(
        (Meal meal) => meal.mealTime.weekDay == WeekDay.wednesday && meal.mealTime.mealType == MealType.dinner,
      );

      expect(wednesdayDinner.subMeals.length, 1);
      expect(wednesdayDinner.subMeals.first.cooking!.recipeId, ensaladaCesarId);
      expect(wednesdayDinner.subMeals.first.people, 2);
    });

    test("the salmon salad stays on week 1 Thursday dinner", () async {
      List<Recipe> recipes = await loadRecipesAndGetList();
      MultiWeekMenu menu = await Persistency.loadDefaultMenu(recipes: recipes);

      Meal thursdayDinner = menu.weeks[0].meals.firstWhere(
        (Meal meal) => meal.mealTime.weekDay == WeekDay.thursday && meal.mealTime.mealType == MealType.dinner,
      );

      expect(thursdayDinner.subMeals.first.cooking!.recipeId, "6c877540-8a82-1e23-b9ad-f37d25fb840b");
    });
  });
}
