import 'package:flutter/foundation.dart';
import 'package:menu_management/recipes/models/recipe.dart';

class RecipesProvider extends ChangeNotifier {
  static late RecipesProvider instance;

  RecipesProvider() {
    instance = this;
  }

  final List<Recipe> _recipes = [];
  List<Recipe> get recipes => _recipes;

  void addRecipe(Recipe recipe) {
    _recipes.add(recipe);
    notifyListeners();
  }

  void removeRecipe(Recipe recipe) {
    _recipes.remove(recipe);
    notifyListeners();
  }
}
