import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:menu_management/ingredients/ingredients_provider.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/menu/enums/meal_type.dart";
import "package:menu_management/menu/enums/week_day.dart";
import "package:menu_management/menu/models/cooking.dart";
import "package:menu_management/menu/models/meal.dart";
import "package:menu_management/menu/models/meal_time.dart";
import "package:menu_management/menu/models/menu.dart";
import "package:menu_management/menu/models/multi_week_menu.dart";
import "package:menu_management/menu/models/sub_meal.dart";
import "package:menu_management/recipes/enums/unit.dart";
import "package:menu_management/recipes/models/ingredient_usage.dart";
import "package:menu_management/recipes/models/instruction.dart";
import "package:menu_management/recipes/models/quantity.dart";
import "package:menu_management/recipes/models/recipe.dart";
import "package:menu_management/recipes/recipes_provider.dart";
import "package:menu_management/shopping/shopping_page.dart";
import "package:provider/provider.dart";

const Ingredient _rice = Ingredient(
  id: "rice",
  name: "Rice",
  products: [Product(link: "https://example.com/rice", quantityPerItem: 500, itemsPerPack: 1, unit: Unit.grams)],
);

Recipe _riceRecipe() {
  return const Recipe(
    id: "r1",
    name: "Rice bowl",
    instructions: [
      Instruction(
        id: "i1",
        description: "cook the rice",
        workingTimeMinutes: 10,
        cookingTimeMinutes: 10,
        ingredientsUsed: [
          IngredientUsage(
            ingredient: "rice",
            quantity: Quantity(amount: 200, unit: Unit.grams),
          ),
        ],
      ),
    ],
  );
}

MultiWeekMenu _menu({DateTime? startDate}) {
  return MultiWeekMenu(
    startDate: startDate,
    weeks: [
      Menu(
        meals: [
          const Meal(
            mealTime: MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch),
            subMeals: [SubMeal(cooking: Cooking(recipeId: "r1", yield: 1), people: 2)],
          ),
        ],
      ),
    ],
  );
}

Future<void> _pumpShoppingPage(WidgetTester tester, MultiWeekMenu menu) async {
  tester.view.physicalSize = const Size(1800, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<IngredientsProvider>.value(value: IngredientsProvider.instance),
        ChangeNotifierProvider<RecipesProvider>.value(value: RecipesProvider.instance),
      ],
      child: MaterialApp(home: ShoppingPage(multiWeekMenu: menu)),
    ),
  );
  await tester.pump();
}

void main() {
  setUp(() {
    IngredientsProvider.instance.setData([_rice]);
    RecipesProvider.instance.setData([_riceRecipe()], ingredients: [_rice]);
  });

  group("ShoppingPage trip banner", () {
    testWidgets("names the trip by week number when the menu has no first day", (WidgetTester tester) async {
      await _pumpShoppingPage(tester, _menu());

      expect(find.textContaining("Multi-trip mode: copy will split into 1 trip (Week 1)."), findsOneWidget);
    });

    testWidgets("names the real shopping date when the menu has a first day", (WidgetTester tester) async {
      // The menu starts on Wednesday 6 Aug 2025, so its trip happens the day before.
      await _pumpShoppingPage(tester, _menu(startDate: DateTime(2025, 8, 6)));

      expect(find.textContaining("Multi-trip mode: copy will split into 1 trip (Tuesday 5 Aug)."), findsOneWidget);
    });
  });
}
