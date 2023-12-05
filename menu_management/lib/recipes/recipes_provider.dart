import 'package:flutter/foundation.dart';
import 'package:menu_management/recipes/models/instruction.dart';
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

  void updateInstruction(String recipe, Instruction instruction) {
    final Recipe recipeToUpdate = _recipes.firstWhere((element) => element.id == recipe);
    final int index = recipeToUpdate.instructions.indexWhere((element) => element.id == instruction.id);
    recipeToUpdate.instructions[index] = instruction;
    notifyListeners();
  }
}
