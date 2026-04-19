import "dart:convert";
import "dart:io";

import "package:file_picker/file_picker.dart";
import "package:flutter/services.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/ingredients/ingredients_provider.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/menu/models/meal.dart";
import "package:menu_management/menu/models/menu.dart";
import "package:menu_management/menu/models/multi_week_menu.dart";
import "package:menu_management/recipes/models/recipe.dart";
import "package:menu_management/recipes/recipes_provider.dart";

class Persistency {
  static final Persistency _singleton = Persistency._internal();

  factory Persistency() {
    return _singleton;
  }

  Persistency._internal();

  // ============================================================
  // Last session tracking
  // ============================================================

  static File get _lastSessionFile {
    String appData = Platform.environment["APPDATA"] ?? Platform.environment["HOME"] ?? ".";
    Directory dir = Directory("$appData/MenuManagement");
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return File("${dir.path}/last_session.json");
  }

  static Map<String, String?> _readLastSession() {
    try {
      File file = _lastSessionFile;
      if (file.existsSync()) {
        return Map<String, String?>.from(jsonDecode(file.readAsStringSync()));
      }
    } catch (_) {
      // Ignore errors reading last session
    }
    return {};
  }

  static void _saveLastSession({String? tsrPath, String? tsmPath}) {
    try {
      Map<String, String?> session = _readLastSession();
      if (tsrPath != null) session["tsrPath"] = tsrPath;
      if (tsmPath != null) session["tsmPath"] = tsmPath;
      _lastSessionFile.writeAsStringSync(jsonEncode(session));
    } catch (_) {
      // Ignore errors saving last session
    }
  }

  /// Returns the last saved/loaded .tsr path, or null if none.
  static String? get lastTsrPath => _readLastSession()["tsrPath"];

  /// Returns the last saved/loaded .tsm path, or null if none.
  static String? get lastTsmPath => _readLastSession()["tsmPath"];

  // ============================================================
  // Load from a specific file path (no picker)
  // ============================================================

  /// Loads ingredients and recipes from a specific .tsr file path.
  /// Returns true if successful, false if the file doesn't exist or can't be read.
  static Future<bool> loadDataFromPath({
    required String path,
    required IngredientsProvider ingredientsProvider,
    required RecipesProvider recipesProvider,
  }) async {
    try {
      File file = File(path);
      if (!file.existsSync()) return false;

      String data = await file.readAsString();
      _parseTsrIntoProviders(data, ingredientsProvider, recipesProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Loads a MultiWeekMenu from a specific .tsm file path.
  /// Returns null if the file doesn't exist or can't be read.
  static Future<MultiWeekMenu?> loadMenuFromPath(String path, {required List<Recipe> recipes}) async {
    try {
      File file = File(path);
      if (!file.existsSync()) return null;

      String data = await file.readAsString();
      return _parseMenuFromJson(data, recipes: recipes);
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // Load bundled defaults from assets
  // ============================================================

  /// Loads the bundled RecipeBook.tsr asset into the providers.
  static Future<void> loadDefaultRecipes({required IngredientsProvider ingredientsProvider, required RecipesProvider recipesProvider}) async {
    String data = await rootBundle.loadString("assets/RecipeBook.tsr");
    _parseTsrIntoProviders(data, ingredientsProvider, recipesProvider);
  }

  /// Loads the bundled DefaultMenu.tsm asset into a MultiWeekMenu.
  static Future<MultiWeekMenu> loadDefaultMenu({required List<Recipe> recipes}) async {
    String data = await rootBundle.loadString("assets/DefaultMenu.tsm");
    return _parseMenuFromJson(data, recipes: recipes);
  }

  // ============================================================
  // Shared parsing helpers
  // ============================================================

  /// Parses .tsr JSON content and updates the providers.
  static void _parseTsrIntoProviders(String data, IngredientsProvider ingredientsProvider, RecipesProvider recipesProvider) {
    Map<String, dynamic> json = Map<String, dynamic>.from(jsonDecode(data));

    List<Ingredient> ingredients = [];
    for (Map<String, dynamic> ingredient in json["Ingredients"]) {
      ingredients.add(Ingredient.fromJson(ingredient));
    }

    List<Recipe> recipes = [];
    for (Map<String, dynamic> recipe in json["Recipes"]) {
      recipes.add(Recipe.fromJson(recipe));
    }

    ingredientsProvider.setData(ingredients);
    recipesProvider.setData(recipes, ingredients: ingredients);
  }

  /// Parses .tsm JSON content into a MultiWeekMenu. Supports both multi-week and single-week formats.
  /// Validates that all referenced recipeIds exist in [recipes]. Missing recipes are nullified with a warning.
  static MultiWeekMenu _parseMenuFromJson(String data, {required List<Recipe> recipes}) {
    Map<String, dynamic> json = Map<String, dynamic>.from(jsonDecode(data));

    MultiWeekMenu rawMenu;
    if (json.containsKey("weeks")) {
      rawMenu = MultiWeekMenu.fromJson(json);
    } else {
      Menu singleWeek = Menu.fromJson(json);
      rawMenu = MultiWeekMenu.validated(weeks: [singleWeek]);
    }

    // Validate: warn and strip meals with missing recipe IDs
    List<String> warnings = [];
    List<Menu> validatedWeeks = rawMenu.weeks.map((Menu week) {
      List<Meal> validMeals = week.meals.map((Meal meal) {
        if (meal.cooking == null) return meal;
        if (!recipes.any((r) => r.id == meal.cooking!.recipeId)) {
          warnings.add("Missing recipe '${meal.cooking!.recipeId}' at ${meal.mealTime.weekDay.name} ${meal.mealTime.mealType.name}");
          return meal.copyWith(cooking: null);
        }
        return meal;
      }).toList();
      return week.copyWith(meals: validMeals);
    }).toList();

    if (warnings.isNotEmpty) {
      Debug.logWarning(true, "Menu loaded with missing recipes:\n${warnings.join('\n')}", asAssertion: false);
    }

    return MultiWeekMenu(weeks: validatedWeeks);
  }

  // ============================================================
  // ref_name injection for human-readable files
  // ============================================================

  /// Injects ref_name fields into .tsm JSON for human readability.
  /// ref_name is ignored by fromJson on load.
  static void _injectMenuRefNames(Map<String, dynamic> menuJson, {required List<Recipe> recipes}) {
    List<dynamic> weeks;
    if (menuJson.containsKey("weeks")) {
      weeks = menuJson["weeks"];
    } else if (menuJson.containsKey("meals")) {
      weeks = [menuJson];
    } else {
      return;
    }

    for (Map<String, dynamic> week in weeks) {
      for (Map<String, dynamic> meal in week["meals"]) {
        if (meal["cooking"] != null) {
          Map<String, dynamic> cooking = meal["cooking"];
          String? recipeId = cooking["recipeId"];
          if (recipeId != null) {
            cooking["ref_name"] = recipes.firstWhereOrNull((r) => r.id == recipeId)?.name ?? "UNKNOWN";
          }
        }
      }
    }
  }

  /// Injects ref_name fields into .tsr recipe JSON for IngredientUsage entries.
  static void _injectRecipeRefNames(Map<String, dynamic> tsrJson, {required List<Ingredient> ingredients}) {
    if (tsrJson["Recipes"] == null) return;
    for (Map<String, dynamic> recipe in tsrJson["Recipes"]) {
      if (recipe["instructions"] == null) continue;
      for (Map<String, dynamic> instruction in recipe["instructions"]) {
        if (instruction["ingredientsUsed"] == null) continue;
        for (Map<String, dynamic> usage in instruction["ingredientsUsed"]) {
          String? ingredientId = usage["ingredient"];
          if (ingredientId != null) {
            usage["ref_name"] = ingredients.firstWhereOrNull((i) => i.id == ingredientId)?.name ?? "UNKNOWN";
          }
        }
      }
    }
  }

  // ============================================================
  // Save to a specific file path (no picker)
  // ============================================================

  /// Saves ingredients and recipes to a specific .tsr file path.
  static Future<void> saveDataToPath({required String path, required List<Ingredient> ingredients, required List<Recipe> recipes}) async {
    Map<String, dynamic> tsrJson = {"Ingredients": ingredients.map((i) => i.toJson()).toList(), "Recipes": recipes.map((r) => r.toJson()).toList()};
    _injectRecipeRefNames(tsrJson, ingredients: ingredients);

    File file = File(path);
    String data = jsonEncode(tsrJson);
    await file.writeAsString(data);
    _saveLastSession(tsrPath: path);
  }

  /// Saves a MultiWeekMenu to a specific .tsm file path.
  static Future<void> saveMenuToPath({required String path, required MultiWeekMenu multiWeekMenu, required List<Recipe> recipes}) async {
    Map<String, dynamic> json = multiWeekMenu.toJson();
    _injectMenuRefNames(json, recipes: recipes);
    String data = jsonEncode(json);

    File file = File(path);
    await file.writeAsString(data);
    _saveLastSession(tsmPath: path);
  }

  // ============================================================
  // Save / Load with file picker
  // ============================================================

  static Future<void> saveData({required List<Ingredient> ingredients, required List<Recipe> recipes}) async {
    // Pick the destination
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: "Select where to save the data",
      fileName: "RecipeBook.tsr",
      allowedExtensions: ["tsr", "json"],
      type: FileType.custom,
    );

    if (outputFile == null) {
      // User canceled the picker
    } else {
      await saveDataToPath(path: outputFile, ingredients: ingredients, recipes: recipes);
    }
  }

  static Future<void> loadData({required IngredientsProvider ingredientsProvider, required RecipesProvider recipesProvider}) async {
    // TODO: check if there is data in the providers and ask for confirmation before loading the file

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: "Select the file to load",
      allowMultiple: false,
      allowedExtensions: ["tsr", "json"],
      withData: true,
      type: FileType.custom,
    );

    if (result == null) {
      // User canceled the picker
    } else {
      // Prepare the file
      File file = File(result.files.single.path!);

      String data = await file.readAsString();
      _parseTsrIntoProviders(data, ingredientsProvider, recipesProvider);
      _saveLastSession(tsrPath: result.files.single.path!);
    }
  }

  static Future<void> saveMenu(MultiWeekMenu multiWeekMenu, {required List<Recipe> recipes}) async {
    DateTime nextSaturday = DateTime.now().add(Duration(days: 6 - DateTime.now().weekday));
    String date = "${nextSaturday.year}-${nextSaturday.month}-${nextSaturday.day}";

    // Pick the destination
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: "Select where to save the menu",
      fileName: "Menu-$date.tsm",
      allowedExtensions: ["tsm", "json"],
      type: FileType.custom,
    );

    if (outputFile == null) {
      // User canceled the picker
    } else {
      await saveMenuToPath(path: outputFile, multiWeekMenu: multiWeekMenu, recipes: recipes);
    }
  }

  static Future<MultiWeekMenu?> loadMultiWeekMenu({required List<Recipe> recipes}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: "Select the menu to load",
      allowMultiple: false,
      allowedExtensions: ["tsm", "json"],
      withData: true,
      type: FileType.custom,
    );

    if (result == null) {
      // User canceled the picker
    } else {
      // Prepare the file
      File file = File(result.files.single.path!);

      String data = await file.readAsString();
      _saveLastSession(tsmPath: result.files.single.path!);
      return _parseMenuFromJson(data, recipes: recipes);
    }
    return null;
  }
}
