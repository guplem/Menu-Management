import 'package:flutter/foundation.dart';
import 'package:menu_management/ingredients/ingredient.dart';

class IngredientsProvider extends ChangeNotifier {
  static late IngredientsProvider instance;

  IngredientsProvider() {
    instance = this;
  }

  final List<Ingredient> _ingredients = [];
  List<Ingredient> get ingredients => _ingredients;

  void addIngredient(Ingredient ingredient) {
    _ingredients.add(ingredient);
    notifyListeners();
  }

  void removeIngredient(Ingredient ingredient) {
    _ingredients.remove(ingredient);
    notifyListeners();
  }
}
