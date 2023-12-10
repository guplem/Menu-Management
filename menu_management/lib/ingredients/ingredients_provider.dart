import 'package:flutter/foundation.dart';
import 'package:menu_management/flutter_essentials/library.dart';
import 'package:menu_management/ingredients/models/ingredient.dart';

// Alter data should be done through the static methods.
// Fetching data should be done through the listenableOf method or through the provider in the tree.
class IngredientsProvider extends ChangeNotifier {
  static late IngredientsProvider instance;

  IngredientsProvider() {
    instance = this;
  }

  final List<Ingredient> _ingredients = [];
  List<Ingredient> get ingredients => _ingredients;

  List<Ingredient> searchHistory = <Ingredient>[];

  static Ingredient listenableOf(context, ingredientId) => getProvider<IngredientsProvider>(context, listen: true).get(ingredientId);

  void setData(List<Ingredient> ingredients) {
    _ingredients.clear();
    _ingredients.addAll(ingredients);
    notifyListeners();
  }

  Ingredient get(String ingredientId) {
    return ingredients.firstWhere((element) => element.id == ingredientId);
  }

  static void addOrUpdate({required Ingredient newIngredient}) {
    final int index = instance.ingredients.indexWhere((element) => element.id == newIngredient.id);
    if (index >= 0) {
      instance.ingredients[index] = newIngredient;
    } else {
      instance.ingredients.add(newIngredient);
    }
    instance.notifyListeners();
  }

  static void remove({required String ingredientId}) {
    instance.ingredients.removeWhere((element) => element.id == ingredientId);
    instance.notifyListeners();
  }

  static void addIngredientToHistory(Ingredient selectedIngredient) {
    if (instance.searchHistory.contains(selectedIngredient)) {
      return;
    }

    if (instance.searchHistory.length >= 10) {
      instance.searchHistory.removeLast();
    }
    instance.searchHistory.insert(0, selectedIngredient);

    instance.notifyListeners();
  }
}
