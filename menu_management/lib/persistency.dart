import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:menu_management/flutter_essentials/library.dart';
import 'package:menu_management/ingredients/ingredients_provider.dart';
import 'package:menu_management/ingredients/models/ingredient.dart';
import 'package:menu_management/recipes/models/recipe.dart';
import 'package:menu_management/recipes/recipes_provider.dart';

class Persistency {
  static final Persistency _singleton = Persistency._internal();

  factory Persistency() {
    return _singleton;
  }

  Persistency._internal();

  static saveData() async {
    // Pick the destination
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Select where to save the data',
      fileName: 'RecipeBook.tsr',
      allowedExtensions: ['tsr','json'],
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
      String data = '{\n';

      // Add INGREDIENTS to the file's data
      data +='"Ingredients":[\n';
      for (Ingredient ingredient in ingredients) {
        data += '${jsonEncode(ingredient.toJson())}\n';
        // Add a comma if not the last
        if (ingredient != ingredients.last) {
          data += ',';
        }
      }
      data += ']';
      data += ',';
      data += '\n';

      // Add RECIPES to the file's data
      data +='"Recipes":[\n';
      for (Recipe recipe in recipes) {
        data += '${jsonEncode(recipe.toJson())}\n';
        // Add a comma if not the last
        if (recipe != recipes.last) {
          data += ',';
        }
      }
      data += ']';
      // data += ','; // A coma is not needed after the last element
      data += '\n';

      // Close JSON and save to file
      data += '}';
      file.writeAsString(data);
    }
  }

  static loadData({required IngredientsProvider ingredientsProvider, required RecipesProvider recipesProvider}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Select the file to load',
      allowMultiple: false,
      allowedExtensions: ['tsr','json'],
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
      for (Map<String, dynamic> ingredient in json['Ingredients']) {
        ingredients.add(Ingredient.fromJson(ingredient));
      }

      // Convert to RECIPE objects
      List<Recipe> recipes = [];
      for (Map<String, dynamic> recipe in json['Recipes']) {
        recipes.add(Recipe.fromJson(recipe));
      }

      // Update the providers
      ingredientsProvider.setData(ingredients);
      recipesProvider.setData(recipes);
    }
  }
}
