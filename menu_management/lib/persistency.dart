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

  SaveData() {
    List<Ingredient> ingredients = [...IngredientsProvider.instance.ingredients];
    List<Recipe> recipes = [...RecipesProvider.instance.recipes];

  }

  LoadData() {}
}
