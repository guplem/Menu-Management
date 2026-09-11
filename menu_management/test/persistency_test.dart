import "dart:convert";
import "dart:io";

import "package:flutter_test/flutter_test.dart";
import "package:menu_management/ingredients/ingredients_provider.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/menu/enums/meal_type.dart";
import "package:menu_management/menu/enums/week_day.dart";
import "package:menu_management/menu/models/cooking.dart";
import "package:menu_management/menu/models/meal.dart";
import "package:menu_management/menu/models/meal_time.dart";
import "package:menu_management/menu/models/menu.dart";
import "package:menu_management/menu/models/multi_week_menu.dart";
import "package:menu_management/menu/models/sub_meal.dart";
import "package:menu_management/persistency.dart";
import "package:menu_management/session_action.dart";
import "package:menu_management/recipes/enums/unit.dart";
import "package:menu_management/recipes/models/ingredient_usage.dart";
import "package:menu_management/recipes/models/instruction.dart";
import "package:menu_management/recipes/models/quantity.dart";
import "package:menu_management/recipes/models/recipe.dart";
import "package:menu_management/recipes/recipes_provider.dart";

// ── Test helpers ──

String _validTsrContent() {
  List<Map<String, dynamic>> ingredients = [
    const Ingredient(id: "ing1", name: "Salt").toJson(),
    const Ingredient(id: "ing2", name: "Pepper").toJson(),
  ];
  List<Map<String, dynamic>> recipes = [const Recipe(id: "r1", name: "Test Recipe").toJson()];
  return jsonEncode({"Ingredients": ingredients, "Recipes": recipes});
}

Recipe _recipe({String id = "r1", String name = "Test Recipe"}) {
  return Recipe(id: id, name: name);
}

Meal _meal({WeekDay weekDay = WeekDay.saturday, MealType mealType = MealType.lunch, Recipe? recipe}) {
  return Meal(
    mealTime: MealTime(weekDay: weekDay, mealType: mealType),
    subMeals: [SubMeal(cooking: recipe != null ? Cooking(recipeId: recipe.id, yield: 1) : null, people: 2)],
  );
}

String _validTsmContent() {
  Menu week = Menu(
    meals: [
      _meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: _recipe()),
      _meal(
        weekDay: WeekDay.saturday,
        mealType: MealType.dinner,
        recipe: _recipe(id: "r2", name: "Dinner Recipe"),
      ),
    ],
  );
  MultiWeekMenu multiWeek = MultiWeekMenu(weeks: [week]);
  return jsonEncode(multiWeek.toJson());
}

String _validSingleWeekTsmContent() {
  Menu week = Menu(
    meals: [_meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: _recipe())],
  );
  return jsonEncode(week.toJson());
}

void main() {
  late Directory tempDir;

  setUp(() {
    IngredientsProvider.instance.setData([]);
    RecipesProvider.instance.setData([], ingredients: []);
    tempDir = Directory.systemTemp.createTempSync("persistency_test_");
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  // ── loadDataFromPath ──

  group("loadDataFromPath", () {
    test("loads ingredients and recipes from a valid .tsr file", () async {
      File tsrFile = File("${tempDir.path}/test.tsr");
      tsrFile.writeAsStringSync(_validTsrContent());

      bool result = await Persistency.loadDataFromPath(
        path: tsrFile.path,
        ingredientsProvider: IngredientsProvider.instance,
        recipesProvider: RecipesProvider.instance,
      );

      expect(result, true);
      expect(IngredientsProvider.instance.ingredients.length, 2);
      expect(IngredientsProvider.instance.ingredients.first.name, "Salt");
      expect(RecipesProvider.instance.recipes.length, 1);
      expect(RecipesProvider.instance.recipes.first.name, "Test Recipe");
    });

    test("returns false for non-existent file", () async {
      bool result = await Persistency.loadDataFromPath(
        path: "${tempDir.path}/nonexistent.tsr",
        ingredientsProvider: IngredientsProvider.instance,
        recipesProvider: RecipesProvider.instance,
      );

      expect(result, false);
      expect(IngredientsProvider.instance.ingredients, isEmpty);
      expect(RecipesProvider.instance.recipes, isEmpty);
    });

    test("returns false for corrupted JSON", () async {
      File tsrFile = File("${tempDir.path}/corrupted.tsr");
      tsrFile.writeAsStringSync("this is not valid json {{{");

      bool result = await Persistency.loadDataFromPath(
        path: tsrFile.path,
        ingredientsProvider: IngredientsProvider.instance,
        recipesProvider: RecipesProvider.instance,
      );

      expect(result, false);
      expect(IngredientsProvider.instance.ingredients, isEmpty);
    });

    test("returns false for valid JSON with missing keys", () async {
      File tsrFile = File("${tempDir.path}/incomplete.tsr");
      tsrFile.writeAsStringSync(jsonEncode({"something": "else"}));

      bool result = await Persistency.loadDataFromPath(
        path: tsrFile.path,
        ingredientsProvider: IngredientsProvider.instance,
        recipesProvider: RecipesProvider.instance,
      );

      expect(result, false);
    });

    test("returns false for empty file", () async {
      File tsrFile = File("${tempDir.path}/empty.tsr");
      tsrFile.writeAsStringSync("");

      bool result = await Persistency.loadDataFromPath(
        path: tsrFile.path,
        ingredientsProvider: IngredientsProvider.instance,
        recipesProvider: RecipesProvider.instance,
      );

      expect(result, false);
    });

    test("returns false when the \"Ingredients\" key is missing", () async {
      File tsrFile = File("${tempDir.path}/no_ingredients.tsr");
      tsrFile.writeAsStringSync(jsonEncode({"Recipes": []}));

      bool result = await Persistency.loadDataFromPath(
        path: tsrFile.path,
        ingredientsProvider: IngredientsProvider.instance,
        recipesProvider: RecipesProvider.instance,
      );

      expect(result, false);
    });

    test("returns false when the \"Recipes\" key is missing", () async {
      File tsrFile = File("${tempDir.path}/no_recipes.tsr");
      tsrFile.writeAsStringSync(jsonEncode({"Ingredients": []}));

      bool result = await Persistency.loadDataFromPath(
        path: tsrFile.path,
        ingredientsProvider: IngredientsProvider.instance,
        recipesProvider: RecipesProvider.instance,
      );

      expect(result, false);
    });

    test("returns false when a top-level key has the wrong type", () async {
      File tsrFile = File("${tempDir.path}/wrong_types.tsr");
      tsrFile.writeAsStringSync(jsonEncode({"Ingredients": {}, "Recipes": []}));

      bool result = await Persistency.loadDataFromPath(
        path: tsrFile.path,
        ingredientsProvider: IngredientsProvider.instance,
        recipesProvider: RecipesProvider.instance,
      );

      expect(result, false);
    });

    test("returns false for a top-level JSON array", () async {
      File tsrFile = File("${tempDir.path}/array.tsr");
      tsrFile.writeAsStringSync(jsonEncode([1, 2, 3]));

      bool result = await Persistency.loadDataFromPath(
        path: tsrFile.path,
        ingredientsProvider: IngredientsProvider.instance,
        recipesProvider: RecipesProvider.instance,
      );

      expect(result, false);
    });
  });

  // ── loadMenuFromPath ──

  group("loadMenuFromPath", () {
    test("loads a multi-week menu from a valid .tsm file", () async {
      Recipe r1 = _recipe();
      Recipe r2 = _recipe(id: "r2", name: "Dinner Recipe");
      List<Recipe> recipes = [r1, r2];

      File tsmFile = File("${tempDir.path}/test.tsm");
      tsmFile.writeAsStringSync(_validTsmContent());

      MultiWeekMenu? menu = await Persistency.loadMenuFromPath(tsmFile.path, recipes: recipes);

      expect(menu, isNotNull);
      expect(menu!.weekCount, 1);
      expect(menu.weeks.first.meals.length, 2);
    });

    test("loads a .tsm file without a start date and keeps the menu date-less", () async {
      Recipe r1 = _recipe();
      Recipe r2 = _recipe(id: "r2", name: "Dinner Recipe");
      List<Recipe> recipes = [r1, r2];

      File tsmFile = File("${tempDir.path}/no_start_date.tsm");
      tsmFile.writeAsStringSync(_validTsmContent());

      MultiWeekMenu? menu = await Persistency.loadMenuFromPath(tsmFile.path, recipes: recipes);

      expect(menu!.startDate, isNull);
    });

    test("keeps the start date of a menu whose recipes are all missing", () async {
      File tsmFile = File("${tempDir.path}/start_date_missing_recipes.tsm");
      tsmFile.writeAsStringSync(jsonEncode({"startDate": "2025-08-06T00:00:00.000", "weeks": jsonDecode(_validTsmContent())["weeks"]}));

      MultiWeekMenu? menu = await Persistency.loadMenuFromPath(tsmFile.path, recipes: []);

      expect(menu!.startDate, DateTime(2025, 8, 6));
    });

    test("keeps every meal when the start date in the file is not a date", () async {
      Recipe r1 = _recipe();
      Recipe r2 = _recipe(id: "r2", name: "Dinner Recipe");
      File tsmFile = File("${tempDir.path}/broken_start_date.tsm");
      tsmFile.writeAsStringSync(jsonEncode({"startDate": "6 Aug 2025", "weeks": jsonDecode(_validTsmContent())["weeks"]}));

      MultiWeekMenu? menu = await Persistency.loadMenuFromPath(tsmFile.path, recipes: [r1, r2]);

      expect(menu, isNotNull);
      expect(menu!.startDate, isNull);
      expect(menu.weeks.first.meals.length, 2);
    });

    test("keeps every meal when the start date in the file is not text", () async {
      Recipe r1 = _recipe();
      Recipe r2 = _recipe(id: "r2", name: "Dinner Recipe");
      File tsmFile = File("${tempDir.path}/numeric_start_date.tsm");
      tsmFile.writeAsStringSync(jsonEncode({"startDate": 20250806, "weeks": jsonDecode(_validTsmContent())["weeks"]}));

      MultiWeekMenu? menu = await Persistency.loadMenuFromPath(tsmFile.path, recipes: [r1, r2]);

      expect(menu, isNotNull);
      expect(menu!.startDate, isNull);
      expect(menu.weeks.first.meals.length, 2);
    });

    test("keeps every meal when the start date in the file is empty", () async {
      Recipe r1 = _recipe();
      Recipe r2 = _recipe(id: "r2", name: "Dinner Recipe");
      File tsmFile = File("${tempDir.path}/empty_start_date.tsm");
      tsmFile.writeAsStringSync(jsonEncode({"startDate": "", "weeks": jsonDecode(_validTsmContent())["weeks"]}));

      MultiWeekMenu? menu = await Persistency.loadMenuFromPath(tsmFile.path, recipes: [r1, r2]);

      expect(menu, isNotNull);
      expect(menu!.startDate, isNull);
      expect(menu.weeks.first.meals.length, 2);
    });

    test("loads old single-week format and wraps in MultiWeekMenu", () async {
      Recipe r1 = _recipe();
      List<Recipe> recipes = [r1];

      File tsmFile = File("${tempDir.path}/old_format.tsm");
      tsmFile.writeAsStringSync(_validSingleWeekTsmContent());

      MultiWeekMenu? menu = await Persistency.loadMenuFromPath(tsmFile.path, recipes: recipes);

      expect(menu, isNotNull);
      expect(menu!.weekCount, 1);
      expect(menu.weeks.first.meals.length, 1);
    });

    test("keeps the start date of an old single-week file", () async {
      Recipe r1 = _recipe();
      File tsmFile = File("${tempDir.path}/old_format_start_date.tsm");
      Map<String, dynamic> json = Map<String, dynamic>.from(jsonDecode(_validSingleWeekTsmContent()));
      json["startDate"] = "2025-08-06T00:00:00.000";
      tsmFile.writeAsStringSync(jsonEncode(json));

      MultiWeekMenu? menu = await Persistency.loadMenuFromPath(tsmFile.path, recipes: [r1]);

      expect(menu!.startDate, DateTime(2025, 8, 6));
      expect(menu.weekCount, 1);
    });

    test("reads a start date written in UTC as the same local day", () async {
      // DateTime.parse keeps the UTC flag of a "Z" value. The chip, the date picker and the
      // grid all read the same field, so the loader normalizes it to a local midnight.
      Recipe r1 = _recipe();
      Recipe r2 = _recipe(id: "r2", name: "Dinner Recipe");
      File tsmFile = File("${tempDir.path}/utc_start_date.tsm");
      tsmFile.writeAsStringSync(jsonEncode({"startDate": "2025-08-06T09:00:00Z", "weeks": jsonDecode(_validTsmContent())["weeks"]}));

      MultiWeekMenu? menu = await Persistency.loadMenuFromPath(tsmFile.path, recipes: [r1, r2]);

      // 09:00 UTC is 6 August in Europe but 5 August in UTC-10. Read the expected day from the
      // conversion, so the test passes in every time zone.
      DateTime local = DateTime.parse("2025-08-06T09:00:00Z").toLocal();
      expect(menu!.startDate!.isUtc, isFalse);
      expect(menu.startDate, DateTime(local.year, local.month, local.day));
    });

    test("drops the time of day of a start date", () async {
      Recipe r1 = _recipe();
      Recipe r2 = _recipe(id: "r2", name: "Dinner Recipe");
      File tsmFile = File("${tempDir.path}/timed_start_date.tsm");
      tsmFile.writeAsStringSync(jsonEncode({"startDate": "2025-08-06T17:30:00.000", "weeks": jsonDecode(_validTsmContent())["weeks"]}));

      MultiWeekMenu? menu = await Persistency.loadMenuFromPath(tsmFile.path, recipes: [r1, r2]);

      expect(menu!.startDate, DateTime(2025, 8, 6));
    });

    test("returns null for non-existent file", () async {
      MultiWeekMenu? menu = await Persistency.loadMenuFromPath("${tempDir.path}/nonexistent.tsm", recipes: []);
      expect(menu, isNull);
    });

    test("returns null for corrupted JSON", () async {
      File tsmFile = File("${tempDir.path}/corrupted.tsm");
      tsmFile.writeAsStringSync("not json at all!!!");

      MultiWeekMenu? menu = await Persistency.loadMenuFromPath(tsmFile.path, recipes: []);
      expect(menu, isNull);
    });

    test("returns null for empty file", () async {
      File tsmFile = File("${tempDir.path}/empty.tsm");
      tsmFile.writeAsStringSync("");

      MultiWeekMenu? menu = await Persistency.loadMenuFromPath(tsmFile.path, recipes: []);
      expect(menu, isNull);
    });

    test("nullifies cooking for meals with missing recipeId", () async {
      // Create a .tsm referencing a recipeId that does not exist in the recipes map
      String tsmWithMissingRecipe = jsonEncode({
        "weeks": [
          {
            "meals": [
              {
                "cooking": {"recipeId": "nonexistent-id", "yield": 1},
                "mealTime": {"weekDay": "saturday", "mealType": "lunch"},
                "people": 2,
              },
            ],
          },
        ],
      });

      File tsmFile = File("${tempDir.path}/missing.tsm");
      tsmFile.writeAsStringSync(tsmWithMissingRecipe);

      MultiWeekMenu? menu = await Persistency.loadMenuFromPath(tsmFile.path, recipes: []);

      expect(menu, isNotNull);
      expect(menu!.weeks.first.meals.first.subMeals.first.cooking, isNull);
    });

    test("keeps cooking for meals with valid recipeId", () async {
      Recipe r1 = _recipe(id: "valid-id", name: "Valid Recipe");
      List<Recipe> recipes = [r1];

      String tsmContent = jsonEncode({
        "weeks": [
          {
            "meals": [
              {
                "cooking": {"recipeId": "valid-id", "yield": 2},
                "mealTime": {"weekDay": "saturday", "mealType": "lunch"},
                "people": 2,
              },
            ],
          },
        ],
      });

      File tsmFile = File("${tempDir.path}/valid.tsm");
      tsmFile.writeAsStringSync(tsmContent);

      MultiWeekMenu? menu = await Persistency.loadMenuFromPath(tsmFile.path, recipes: recipes);

      expect(menu, isNotNull);
      expect(menu!.weeks.first.meals.first.subMeals.first.cooking, isNotNull);
      expect(menu.weeks.first.meals.first.subMeals.first.cooking!.recipeId, "valid-id");
    });
  });

  // ── saveDataToPath ──

  group("saveDataToPath", () {
    test("saves and reloads ingredients with nested products", () async {
      List<Ingredient> ingredients = [
        Ingredient(
          id: "ing1",
          name: "Salt",
          products: [Product(link: "https://example.com/salt", quantityPerItem: 1000, unit: Unit.grams, shelfLifeDaysOpened: 365, itemsPerPack: 1)],
          density: 1.2,
        ),
        Ingredient(
          id: "ing2",
          name: "Tomato",
          products: [Product(link: "https://example.com/tomato", quantityPerItem: 720, unit: Unit.grams, itemsPerPack: 1)],
          density: 0.95,
        ),
      ];
      List<Recipe> recipes = [
        Recipe(
          id: "r1",
          name: "Salad",
          instructions: [
            Instruction(
              id: "i1",
              description: "Chop",
              ingredientsUsed: [
                IngredientUsage(
                  ingredient: "ing2",
                  quantity: Quantity(amount: 200, unit: Unit.grams),
                ),
              ],
            ),
          ],
        ),
      ];

      String path = "${tempDir.path}/save_test.tsr";
      await Persistency.saveDataToPath(path: path, ingredients: ingredients, recipes: recipes);

      bool loaded = await Persistency.loadDataFromPath(
        path: path,
        ingredientsProvider: IngredientsProvider.instance,
        recipesProvider: RecipesProvider.instance,
      );

      expect(loaded, true);
      expect(IngredientsProvider.instance.ingredients.length, 2);
      expect(IngredientsProvider.instance.ingredients.first.products.length, 1);
      expect(IngredientsProvider.instance.ingredients.first.products.first.shelfLifeDaysOpened, 365);
      expect(IngredientsProvider.instance.ingredients.first.density, 1.2);
      expect(RecipesProvider.instance.recipes.length, 1);
      expect(RecipesProvider.instance.recipes.first.instructions.first.ingredientsUsed.first.ingredient, "ing2");
    });

    test("saved file is pretty-printed with tab indentation", () async {
      List<Ingredient> ingredients = [Ingredient(id: "ing1", name: "Salt")];
      List<Recipe> recipes = [const Recipe(id: "r1", name: "Test")];

      String path = "${tempDir.path}/format_test.tsr";
      await Persistency.saveDataToPath(path: path, ingredients: ingredients, recipes: recipes);

      String content = File(path).readAsStringSync();
      expect(content, contains("\n"), reason: "Saved file should contain newlines");
    });

    test("saved file contains ref_name for ingredient usages", () async {
      List<Ingredient> ingredients = [Ingredient(id: "ing1", name: "Salt")];
      List<Recipe> recipes = [
        Recipe(
          id: "r1",
          name: "Test",
          instructions: [
            Instruction(
              id: "i1",
              description: "Step",
              ingredientsUsed: [
                IngredientUsage(
                  ingredient: "ing1",
                  quantity: Quantity(amount: 10, unit: Unit.grams),
                ),
              ],
            ),
          ],
        ),
      ];

      String path = "${tempDir.path}/ref_name_test.tsr";
      await Persistency.saveDataToPath(path: path, ingredients: ingredients, recipes: recipes);

      Map<String, dynamic> savedJson = jsonDecode(File(path).readAsStringSync());
      Map<String, dynamic> usage = savedJson["Recipes"][0]["instructions"][0]["ingredientsUsed"][0];
      expect(usage["ref_name"], "Salt");
    });
  });

  // ── defaultMenuFileName ──

  group("defaultMenuFileName", () {
    test("names the file after the first day of the menu", () {
      MultiWeekMenu menu = MultiWeekMenu(
        startDate: DateTime(2025, 8, 6),
        weeks: [
          Menu(meals: [_meal()]),
        ],
      );

      expect(Persistency.defaultMenuFileName(menu), "Menu-2025-08-06.tsm");
    });

    test("falls back to the next Saturday when the menu has no first day", () {
      MultiWeekMenu menu = MultiWeekMenu(
        weeks: [
          Menu(meals: [_meal()]),
        ],
      );

      // 2025-08-06 is a Wednesday, so the next Saturday is 2025-08-09.
      expect(Persistency.defaultMenuFileName(menu, today: DateTime(2025, 8, 6)), "Menu-2025-08-09.tsm");
    });

    test("falls back to today when today is already a Saturday", () {
      MultiWeekMenu menu = MultiWeekMenu(
        weeks: [
          Menu(meals: [_meal()]),
        ],
      );

      expect(Persistency.defaultMenuFileName(menu, today: DateTime(2025, 8, 9)), "Menu-2025-08-09.tsm");
    });

    test("falls back to the Saturday ahead on a Sunday, never to yesterday", () {
      MultiWeekMenu menu = MultiWeekMenu(
        weeks: [
          Menu(meals: [_meal()]),
        ],
      );

      // 2025-08-10 is a Sunday. The next Saturday is six days later, not the day before.
      expect(Persistency.defaultMenuFileName(menu, today: DateTime(2025, 8, 10)), "Menu-2025-08-16.tsm");
    });

    test("names the PDF of the menu after the same day as the menu file", () {
      MultiWeekMenu menu = MultiWeekMenu(
        startDate: DateTime(2025, 8, 6),
        weeks: [
          Menu(meals: [_meal()]),
        ],
      );

      expect(Persistency.defaultMenuFileName(menu, extension: "pdf"), "Menu-2025-08-06.pdf");
    });
  });

  // ── saveBytesToPath ──

  group("saveBytesToPath", () {
    test("writes the bytes that it receives, so the file holds the PDF and nothing else", () async {
      String path = "${tempDir.path}/bytes_test.pdf";

      String written = await Persistency.saveBytesToPath(path: path, bytes: const [37, 80, 68, 70], extension: "pdf");

      expect(written, path);
      expect(await File(path).readAsBytes(), const [37, 80, 68, 70]);
    });

    test("adds the extension when the user names a file without one, so every reader opens it", () async {
      String path = "${tempDir.path}/no_extension";

      String written = await Persistency.saveBytesToPath(path: path, bytes: const [37], extension: "pdf");

      expect(written, "$path.pdf");
      expect(File("$path.pdf").existsSync(), true);
      expect(File(path).existsSync(), false);
    });

    test("keeps the extension that the user wrote, whatever the case of its letters", () async {
      String path = "${tempDir.path}/upper_case.PDF";

      String written = await Persistency.saveBytesToPath(path: path, bytes: const [37], extension: "pdf");

      expect(written, path);
      expect(File("$path.pdf").existsSync(), false);
    });
  });

  // ── saveMenuToPath ──

  group("saveMenuToPath", () {
    test("saves and reloads a multi-week menu", () async {
      Recipe r1 = _recipe(id: "r1", name: "Lunch Recipe");
      List<Recipe> recipes = [r1];
      MultiWeekMenu menu = MultiWeekMenu(
        weeks: [
          Menu(
            meals: [_meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: r1)],
          ),
        ],
      );

      String path = "${tempDir.path}/save_menu_test.tsm";
      await Persistency.saveMenuToPath(path: path, multiWeekMenu: menu, recipes: recipes);

      MultiWeekMenu? loaded = await Persistency.loadMenuFromPath(path, recipes: recipes);

      expect(loaded, isNotNull);
      expect(loaded!.weekCount, 1);
      expect(loaded.weeks.first.meals.first.subMeals.first.cooking!.recipeId, "r1");
    });

    test("saves and reloads the menu start date", () async {
      Recipe r1 = _recipe(id: "r1", name: "Lunch Recipe");
      List<Recipe> recipes = [r1];
      MultiWeekMenu menu = MultiWeekMenu(
        startDate: DateTime(2025, 8, 6),
        weeks: [
          Menu(
            meals: [_meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: r1)],
          ),
        ],
      );

      String path = "${tempDir.path}/start_date_menu_test.tsm";
      await Persistency.saveMenuToPath(path: path, multiWeekMenu: menu, recipes: recipes);

      MultiWeekMenu? loaded = await Persistency.loadMenuFromPath(path, recipes: recipes);

      expect(loaded!.startDate, DateTime(2025, 8, 6));
    });

    test("omits the start date from the file when the menu has none", () async {
      Recipe r1 = _recipe(id: "r1", name: "Lunch Recipe");
      List<Recipe> recipes = [r1];
      MultiWeekMenu menu = MultiWeekMenu(
        weeks: [
          Menu(
            meals: [_meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: r1)],
          ),
        ],
      );

      String path = "${tempDir.path}/no_start_date_menu_test.tsm";
      await Persistency.saveMenuToPath(path: path, multiWeekMenu: menu, recipes: recipes);

      Map<String, dynamic> savedJson = jsonDecode(File(path).readAsStringSync());
      expect(savedJson.containsKey("startDate"), isFalse);
    });

    test("saved menu file is pretty-printed with tab indentation", () async {
      Recipe r1 = _recipe(id: "r1", name: "Test");
      List<Recipe> recipes = [r1];
      MultiWeekMenu menu = MultiWeekMenu(
        weeks: [
          Menu(
            meals: [_meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: r1)],
          ),
        ],
      );

      String path = "${tempDir.path}/format_menu_test.tsm";
      await Persistency.saveMenuToPath(path: path, multiWeekMenu: menu, recipes: recipes);

      String content = File(path).readAsStringSync();
      expect(content, contains("\n"), reason: "Saved file should contain newlines");
    });

    test("saved menu file contains ref_name for cooking entries", () async {
      Recipe r1 = _recipe(id: "r1", name: "Pizza");
      List<Recipe> recipes = [r1];
      MultiWeekMenu menu = MultiWeekMenu(
        weeks: [
          Menu(
            meals: [_meal(weekDay: WeekDay.saturday, mealType: MealType.dinner, recipe: r1)],
          ),
        ],
      );

      String path = "${tempDir.path}/ref_name_menu_test.tsm";
      await Persistency.saveMenuToPath(path: path, multiWeekMenu: menu, recipes: recipes);

      Map<String, dynamic> savedJson = jsonDecode(File(path).readAsStringSync());
      Map<String, dynamic> cooking = savedJson["weeks"][0]["meals"][0]["subMeals"][0]["cooking"];
      expect(cooking["ref_name"], "Pizza");
    });
  });

  // ── toJson produces fully expanded maps (explicitToJson) ──

  group("toJson produces fully expanded maps", () {
    test("Recipe.toJson() converts nested Instructions to maps", () {
      Recipe recipe = Recipe(
        id: "r1",
        name: "Test",
        instructions: [
          Instruction(
            id: "i1",
            description: "Step 1",
            ingredientsUsed: [
              IngredientUsage(
                ingredient: "ing1",
                quantity: Quantity(amount: 100, unit: Unit.grams),
              ),
            ],
          ),
        ],
      );
      Map<String, dynamic> json = recipe.toJson();
      expect(json["instructions"], isA<List>());
      expect(json["instructions"][0], isA<Map<String, dynamic>>(), reason: "Nested Instruction should be a Map, not a Dart object");
    });

    test("Ingredient.toJson() converts nested Products to maps", () {
      Ingredient ingredient = Ingredient(
        id: "ing1",
        name: "Salt",
        products: [Product(link: "https://example.com", quantityPerItem: 500, unit: Unit.grams)],
      );
      Map<String, dynamic> json = ingredient.toJson();
      expect(json["products"], isA<List>());
      expect(json["products"][0], isA<Map<String, dynamic>>(), reason: "Nested Product should be a Map, not a Dart object");
    });

    test("MultiWeekMenu.toJson() converts nested Meals to maps", () {
      MultiWeekMenu menu = MultiWeekMenu(
        weeks: [
          Menu(
            meals: [_meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: _recipe())],
          ),
        ],
      );
      Map<String, dynamic> json = menu.toJson();
      expect(json["weeks"][0], isA<Map<String, dynamic>>(), reason: "Nested Menu should be a Map");
      expect(json["weeks"][0]["meals"][0], isA<Map<String, dynamic>>(), reason: "Nested Meal should be a Map");
    });

    test("TSR round-trip preserves all ingredient fields including products", () {
      Ingredient original = Ingredient(
        id: "ing1",
        name: "Test",
        products: [Product(link: "https://example.com", quantityPerItem: 500, unit: Unit.grams, shelfLifeDaysOpened: 7, itemsPerPack: 2)],
        density: 1.05,
      );
      String encoded = jsonEncode(original.toJson());
      Ingredient decoded = Ingredient.fromJson(jsonDecode(encoded));
      expect(decoded, original);
    });

    test("TSR round-trip preserves all recipe fields including instructions", () {
      Recipe original = Recipe(
        id: "r1",
        name: "Test",
        instructions: [
          Instruction(
            id: "i1",
            description: "Step",
            ingredientsUsed: [
              IngredientUsage(
                ingredient: "ing1",
                quantity: Quantity(amount: 100, unit: Unit.grams),
              ),
            ],
          ),
        ],
      );
      String encoded = jsonEncode(original.toJson());
      Recipe decoded = Recipe.fromJson(jsonDecode(encoded));
      expect(decoded, original);
    });
  });

  // ── Last session tracking ──

  group("last session tracking", () {
    late Directory sessionDir;

    setUp(() {
      sessionDir = Directory.systemTemp.createTempSync("session_test_");
      Persistency.sessionDirOverride = sessionDir.path;
    });

    tearDown(() {
      Persistency.sessionDirOverride = null;
      if (sessionDir.existsSync()) {
        sessionDir.deleteSync(recursive: true);
      }
    });

    test("lastTsrPath and lastTsmPath are null on fresh session", () {
      expect(Persistency.lastTsrPath, isNull);
      expect(Persistency.lastTsmPath, isNull);
      expect(Persistency.lastTsrAction, isNull);
      expect(Persistency.lastTsmAction, isNull);
    });

    test("saveDataToPath records path and saved action for tsr", () async {
      String path = "${tempDir.path}/test.tsr";
      await Persistency.saveDataToPath(path: path, ingredients: [], recipes: []);

      expect(Persistency.lastTsrPath, path);
      expect(Persistency.lastTsrAction, SessionAction.saved);
    });

    test("saveMenuToPath records path and saved action for tsm", () async {
      String path = "${tempDir.path}/test.tsm";
      MultiWeekMenu menu = const MultiWeekMenu(weeks: [Menu(meals: [])]);
      await Persistency.saveMenuToPath(path: path, multiWeekMenu: menu, recipes: []);

      expect(Persistency.lastTsmPath, path);
      expect(Persistency.lastTsmAction, SessionAction.saved);
    });

    test("loadDataFromPath records path and loaded action for tsr", () async {
      File tsrFile = File("${tempDir.path}/test.tsr");
      tsrFile.writeAsStringSync(_validTsrContent());

      await Persistency.loadDataFromPath(
        path: tsrFile.path,
        ingredientsProvider: IngredientsProvider.instance,
        recipesProvider: RecipesProvider.instance,
      );

      expect(Persistency.lastTsrPath, tsrFile.path);
      expect(Persistency.lastTsrAction, SessionAction.loaded);
    });

    test("loadMenuFromPath records path and loaded action for tsm", () async {
      File tsmFile = File("${tempDir.path}/test.tsm");
      tsmFile.writeAsStringSync(_validTsmContent());

      await Persistency.loadMenuFromPath(
        tsmFile.path,
        recipes: [
          _recipe(),
          _recipe(id: "r2", name: "Dinner Recipe"),
        ],
      );

      expect(Persistency.lastTsmPath, tsmFile.path);
      expect(Persistency.lastTsmAction, SessionAction.loaded);
    });

    test("clearLastTsrSession removes tsr path and action but keeps tsm", () async {
      String tsrPath = "${tempDir.path}/test.tsr";
      String tsmPath = "${tempDir.path}/test.tsm";
      await Persistency.saveDataToPath(path: tsrPath, ingredients: [], recipes: []);
      MultiWeekMenu menu = const MultiWeekMenu(weeks: [Menu(meals: [])]);
      await Persistency.saveMenuToPath(path: tsmPath, multiWeekMenu: menu, recipes: []);

      Persistency.clearLastTsrSession();

      expect(Persistency.lastTsrPath, isNull);
      expect(Persistency.lastTsrAction, isNull);
      expect(Persistency.lastTsmPath, tsmPath);
      expect(Persistency.lastTsmAction, SessionAction.saved);
    });

    test("clearLastTsmSession removes tsm path and action but keeps tsr", () async {
      String tsrPath = "${tempDir.path}/test.tsr";
      String tsmPath = "${tempDir.path}/test.tsm";
      await Persistency.saveDataToPath(path: tsrPath, ingredients: [], recipes: []);
      MultiWeekMenu menu = const MultiWeekMenu(weeks: [Menu(meals: [])]);
      await Persistency.saveMenuToPath(path: tsmPath, multiWeekMenu: menu, recipes: []);

      Persistency.clearLastTsmSession();

      expect(Persistency.lastTsrPath, tsrPath);
      expect(Persistency.lastTsrAction, SessionAction.saved);
      expect(Persistency.lastTsmPath, isNull);
      expect(Persistency.lastTsmAction, isNull);
    });

    test("loading after saving updates action from saved to loaded", () async {
      String path = "${tempDir.path}/test.tsr";
      await Persistency.saveDataToPath(
        path: path,
        ingredients: [const Ingredient(id: "ing1", name: "Salt")],
        recipes: [],
      );
      expect(Persistency.lastTsrAction, SessionAction.saved);

      await Persistency.loadDataFromPath(path: path, ingredientsProvider: IngredientsProvider.instance, recipesProvider: RecipesProvider.instance);
      expect(Persistency.lastTsrAction, SessionAction.loaded);
    });
  });
}
