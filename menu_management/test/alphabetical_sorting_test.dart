import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:menu_management/ingredients/ingredients_provider.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/widgets/ingredients_page.dart";
import "package:menu_management/recipes/models/recipe.dart";
import "package:menu_management/recipes/recipes_provider.dart";
import "package:menu_management/recipes/widgets/recipes_page.dart";
import "package:provider/provider.dart";

void main() {
  group("IngredientsPage alphabetical sorting", () {
    setUp(() {
      IngredientsProvider.instance.setData([]);
    });

    List<String> findIngredientNames(WidgetTester tester) {
      return tester
          .widgetList<ListTile>(find.byType(ListTile))
          .where((ListTile tile) => tile.title is Text)
          .map((ListTile tile) => (tile.title as Text).data!)
          .toList();
    }

    testWidgets("displays ingredients in alphabetical order", (WidgetTester tester) async {
      IngredientsProvider.instance.setData([
        const Ingredient(id: "1", name: "Zucchini"),
        const Ingredient(id: "2", name: "Apple"),
        const Ingredient(id: "3", name: "Banana"),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<IngredientsProvider>.value(
            value: IngredientsProvider.instance,
            child: const IngredientsPage(),
          ),
        ),
      );

      expect(findIngredientNames(tester), ["Apple", "Banana", "Zucchini"]);
    });

    testWidgets("undo re-adds ingredient in alphabetical position", (WidgetTester tester) async {
      IngredientsProvider.instance.setData([
        const Ingredient(id: "1", name: "Apple"),
        const Ingredient(id: "2", name: "Banana"),
        const Ingredient(id: "3", name: "Zucchini"),
      ]);

      // Simulate delete + undo: remove Banana then add it back
      IngredientsProvider.remove(ingredientId: "2");
      IngredientsProvider.addOrUpdate(newIngredient: const Ingredient(id: "2", name: "Banana"));

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<IngredientsProvider>.value(
            value: IngredientsProvider.instance,
            child: const IngredientsPage(),
          ),
        ),
      );

      expect(findIngredientNames(tester), ["Apple", "Banana", "Zucchini"]);
    });

    testWidgets("sorting is case-insensitive", (WidgetTester tester) async {
      IngredientsProvider.instance.setData([
        const Ingredient(id: "1", name: "banana"),
        const Ingredient(id: "2", name: "Apple"),
        const Ingredient(id: "3", name: "cherry"),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<IngredientsProvider>.value(
            value: IngredientsProvider.instance,
            child: const IngredientsPage(),
          ),
        ),
      );

      expect(findIngredientNames(tester), ["Apple", "banana", "cherry"]);
    });
  });

  group("RecipesPage alphabetical sorting", () {
    setUp(() {
      RecipesProvider.instance.setData([], ingredients: []);
      IngredientsProvider.instance.setData([]);
    });

    List<String> findRecipeNames(WidgetTester tester) {
      return tester
          .widgetList<ListTile>(find.byType(ListTile))
          .where((ListTile tile) => tile.title is Text)
          .map((ListTile tile) => (tile.title as Text).data!)
          .toList();
    }

    testWidgets("displays recipes in alphabetical order", (WidgetTester tester) async {
      RecipesProvider.instance.setData([
        const Recipe(id: "1", name: "Zucchini Soup"),
        const Recipe(id: "2", name: "Apple Pie"),
        const Recipe(id: "3", name: "Banana Bread"),
      ], ingredients: []);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<RecipesProvider>.value(
            value: RecipesProvider.instance,
            child: const RecipesPage(),
          ),
        ),
      );

      expect(findRecipeNames(tester), ["Apple Pie", "Banana Bread", "Zucchini Soup"]);
    });

    testWidgets("undo re-adds recipe in alphabetical position", (WidgetTester tester) async {
      RecipesProvider.instance.setData([
        const Recipe(id: "1", name: "Apple Pie"),
        const Recipe(id: "2", name: "Banana Bread"),
        const Recipe(id: "3", name: "Zucchini Soup"),
      ], ingredients: []);

      // Simulate delete + undo
      RecipesProvider.remove(recipeId: "2");
      RecipesProvider.addOrUpdate(newRecipe: const Recipe(id: "2", name: "Banana Bread"));

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<RecipesProvider>.value(
            value: RecipesProvider.instance,
            child: const RecipesPage(),
          ),
        ),
      );

      expect(findRecipeNames(tester), ["Apple Pie", "Banana Bread", "Zucchini Soup"]);
    });
  });
}
