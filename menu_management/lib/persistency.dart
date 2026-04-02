import "dart:convert";
import "dart:io";

import "package:file_picker/file_picker.dart";
import "package:menu_management/ingredients/ingredients_provider.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
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
      recipesProvider.setData(recipes);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Loads a MultiWeekMenu from a specific .tsm file path.
  /// Returns null if the file doesn't exist or can't be read.
  static Future<MultiWeekMenu?> loadMenuFromPath(String path) async {
    try {
      File file = File(path);
      if (!file.existsSync()) return null;

      String data = await file.readAsString();
      Map<String, dynamic> json = Map<String, dynamic>.from(jsonDecode(data));

      if (json.containsKey("weeks")) {
        return MultiWeekMenu.fromJson(json);
      } else {
        Menu singleWeek = Menu.fromJson(json);
        return MultiWeekMenu.validated(weeks: [singleWeek]);
      }
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // Save / Load with file picker
  // ============================================================

  static Future<void> saveData() async {
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
      // Get the data
      List<Ingredient> ingredients = [...IngredientsProvider.instance.ingredients];
      List<Recipe> recipes = [...RecipesProvider.instance.recipes];

      // Prepare the file
      File file = File(outputFile);
      String data = "{\n";

      // Add INGREDIENTS to the file's data
      data += '"Ingredients":[\n';
      for (Ingredient ingredient in ingredients) {
        data += "${jsonEncode(ingredient.toJson())}\n";
        // Add a comma if not the last
        if (ingredient != ingredients.last) {
          data += ",";
        }
      }
      data += "]";
      data += ",";
      data += "\n";

      // Add RECIPES to the file's data
      data += '"Recipes":[\n';
      for (Recipe recipe in recipes) {
        data += "${jsonEncode(recipe.toJson())}\n";
        // Add a comma if not the last
        if (recipe != recipes.last) {
          data += ",";
        }
      }
      data += "]";
      // data += ','; // A coma is not needed after the last element
      data += "\n";

      // Close JSON and save to file
      data += "}";
      await file.writeAsString(data);
      _saveLastSession(tsrPath: outputFile);
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

      // Read the file
      String data = await file.readAsString();

      // Parse the data
      Map<String, dynamic> json = Map<String, dynamic>.from(jsonDecode(data));

      // Convert to INGREDIENT objects
      List<Ingredient> ingredients = [];
      for (Map<String, dynamic> ingredient in json["Ingredients"]) {
        ingredients.add(Ingredient.fromJson(ingredient));
      }

      // Convert to RECIPE objects
      List<Recipe> recipes = [];
      for (Map<String, dynamic> recipe in json["Recipes"]) {
        recipes.add(Recipe.fromJson(recipe));
      }

      // Update the providers
      ingredientsProvider.setData(ingredients);
      recipesProvider.setData(recipes);
      _saveLastSession(tsrPath: result.files.single.path!);
    }
  }

  static Future<void> saveMenu(MultiWeekMenu multiWeekMenu) async {
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
      // Prepare the file
      File file = File(outputFile);
      String data = jsonEncode(multiWeekMenu.toJson());

      // Save to file
      await file.writeAsString(data);
      _saveLastSession(tsmPath: outputFile);
    }
  }

  static Future<MultiWeekMenu?> loadMultiWeekMenu() async {
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

      // Read the file
      String data = await file.readAsString();

      // Parse the data
      Map<String, dynamic> json = Map<String, dynamic>.from(jsonDecode(data));

      // Support loading old single-week .tsm files by checking for "weeks" key
      if (json.containsKey("weeks")) {
        _saveLastSession(tsmPath: result.files.single.path!);
        return MultiWeekMenu.fromJson(json);
      } else {
        _saveLastSession(tsmPath: result.files.single.path!);
        Menu singleWeek = Menu.fromJson(json);
        return MultiWeekMenu.validated(weeks: [singleWeek]);
      }
    }
    return null;
  }
}
