import 'package:menu_management/recipe.dart';

class Meal {
  /// The recipes and their amount to cook. 0 means it should already be cooked.
  Map<Recipe, int> recipes;

  Meal({required this.recipes});
}
