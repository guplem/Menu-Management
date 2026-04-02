import "dart:convert";

import "package:flutter/services.dart";
import "package:menu_management/ingredients/ingredients_provider.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/menu/models/menu.dart";
import "package:menu_management/menu/models/multi_week_menu.dart";
import "package:menu_management/recipes/models/recipe.dart";
import "package:menu_management/recipes/recipes_provider.dart";

class DefaultData {
  /// Loads the bundled RecipeBook.tsr from assets into the providers.
  static Future<void> loadDefaultRecipes({
    required IngredientsProvider ingredientsProvider,
    required RecipesProvider recipesProvider,
  }) async {
    String data = await rootBundle.loadString("assets/RecipeBook.tsr");
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
  }

  /// Loads the bundled DefaultMenu.tsm from assets.
  static Future<MultiWeekMenu> loadDefaultMenu() async {
    String data = await rootBundle.loadString("assets/DefaultMenu.tsm");
    Map<String, dynamic> json = Map<String, dynamic>.from(jsonDecode(data));

    if (json.containsKey("weeks")) {
      return MultiWeekMenu.fromJson(json);
    } else {
      Menu singleWeek = Menu.fromJson(json);
      return MultiWeekMenu.validated(weeks: [singleWeek]);
    }
  }
}
