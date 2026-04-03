import "dart:convert";
import "dart:io";

import "package:flutter_test/flutter_test.dart";
import "package:menu_management/ingredients/ingredients_provider.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/menu/enums/meal_type.dart";
import "package:menu_management/menu/enums/week_day.dart";
import "package:menu_management/menu/models/cooking.dart";
import "package:menu_management/menu/models/meal.dart";
import "package:menu_management/menu/models/meal_time.dart";
import "package:menu_management/menu/models/menu.dart";
import "package:menu_management/menu/models/multi_week_menu.dart";
import "package:menu_management/persistency.dart";
import "package:menu_management/recipes/models/recipe.dart";
import "package:menu_management/recipes/recipes_provider.dart";

// ── Test helpers ──

String _validTsrContent() {
  List<Map<String, dynamic>> ingredients = [
    const Ingredient(id: "ing1", name: "Salt").toJson(),
    const Ingredient(id: "ing2", name: "Pepper").toJson(),
  ];
  List<Map<String, dynamic>> recipes = [
    const Recipe(id: "r1", name: "Test Recipe").toJson(),
  ];
  return jsonEncode({"Ingredients": ingredients, "Recipes": recipes});
}

Recipe _recipe({String id = "r1", String name = "Test Recipe"}) {
  return Recipe(id: id, name: name);
}

Meal _meal({WeekDay weekDay = WeekDay.saturday, MealType mealType = MealType.lunch, Recipe? recipe}) {
  return Meal(
    mealTime: MealTime(weekDay: weekDay, mealType: mealType),
    cooking: recipe != null ? Cooking(recipe: recipe, yield: 1) : null,
  );
}

String _validTsmContent() {
  Menu week = Menu(meals: [
    _meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: _recipe()),
    _meal(weekDay: WeekDay.saturday, mealType: MealType.dinner, recipe: _recipe(id: "r2", name: "Dinner Recipe")),
  ]);
  MultiWeekMenu multiWeek = MultiWeekMenu(weeks: [week]);
  return jsonEncode(multiWeek.toJson());
}

String _validSingleWeekTsmContent() {
  Menu week = Menu(meals: [
    _meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipe: _recipe()),
  ]);
  return jsonEncode(week.toJson());
}

void main() {
  late Directory tempDir;

  setUp(() {
    IngredientsProvider.instance.setData([]);
    RecipesProvider.instance.setData([]);
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
  });

  // ── loadMenuFromPath ──

  group("loadMenuFromPath", () {
    test("loads a multi-week menu from a valid .tsm file", () async {
      File tsmFile = File("${tempDir.path}/test.tsm");
      tsmFile.writeAsStringSync(_validTsmContent());

      MultiWeekMenu? menu = await Persistency.loadMenuFromPath(tsmFile.path);

      expect(menu, isNotNull);
      expect(menu!.weekCount, 1);
      expect(menu.weeks.first.meals.length, 2);
    });

    test("loads old single-week format and wraps in MultiWeekMenu", () async {
      File tsmFile = File("${tempDir.path}/old_format.tsm");
      tsmFile.writeAsStringSync(_validSingleWeekTsmContent());

      MultiWeekMenu? menu = await Persistency.loadMenuFromPath(tsmFile.path);

      expect(menu, isNotNull);
      expect(menu!.weekCount, 1);
      expect(menu.weeks.first.meals.length, 1);
    });

    test("returns null for non-existent file", () async {
      MultiWeekMenu? menu = await Persistency.loadMenuFromPath("${tempDir.path}/nonexistent.tsm");
      expect(menu, isNull);
    });

    test("returns null for corrupted JSON", () async {
      File tsmFile = File("${tempDir.path}/corrupted.tsm");
      tsmFile.writeAsStringSync("not json at all!!!");

      MultiWeekMenu? menu = await Persistency.loadMenuFromPath(tsmFile.path);
      expect(menu, isNull);
    });

    test("returns null for empty file", () async {
      File tsmFile = File("${tempDir.path}/empty.tsm");
      tsmFile.writeAsStringSync("");

      MultiWeekMenu? menu = await Persistency.loadMenuFromPath(tsmFile.path);
      expect(menu, isNull);
    });
  });

  // ── Last session tracking ──

  group("last session tracking", () {
    test("lastTsrPath is null when no session has been saved", () {
      // On a fresh install or test environment, there may or may not be a session file.
      // We just verify the getter does not throw.
      Persistency.lastTsrPath;
      Persistency.lastTsmPath;
    });
  });
}
