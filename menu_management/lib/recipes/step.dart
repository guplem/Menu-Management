import 'package:menu_management/ingredients/ingredient.dart';
import 'package:menu_management/recipes/quantity.dart';

class Step {
  Map<Ingredient, Quantity> ingredients;
  String description;

  Step({required this.ingredients, required this.description});
}
