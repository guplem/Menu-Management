import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:menu_management/ingredients/ingredients_provider.dart";
import "package:menu_management/menu/enums/meal_type.dart";
import "package:menu_management/menu/enums/week_day.dart";
import "package:menu_management/menu/menu_provider.dart";
import "package:menu_management/menu/models/cooking.dart";
import "package:menu_management/menu/models/meal.dart";
import "package:menu_management/menu/models/meal_time.dart";
import "package:menu_management/menu/models/menu.dart";
import "package:menu_management/menu/models/multi_week_menu.dart";
import "package:menu_management/menu/models/sub_meal.dart";
import "package:menu_management/recipes/models/instruction.dart";
import "package:menu_management/recipes/models/recipe.dart";
import "package:menu_management/recipes/recipes_provider.dart";
import "package:menu_management/recipes/widgets/recipes_page.dart";
import "package:provider/provider.dart";

const Recipe _paella = Recipe(
  id: "r-paella",
  name: "Paella",
  instructions: [Instruction(id: "i1", description: "cook it", workingTimeMinutes: 20, cookingTimeMinutes: 20)],
);

MultiWeekMenu _menuWithPaella({DateTime? startDate}) {
  return MultiWeekMenu(
    startDate: startDate,
    weeks: [
      Menu(
        meals: [
          const Meal(
            mealTime: MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch),
            subMeals: [SubMeal(cooking: Cooking(recipeId: "r-paella", yield: 1), people: 2)],
          ),
        ],
      ),
    ],
  );
}

Future<void> _pumpRecipesPage(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1800, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<IngredientsProvider>.value(value: IngredientsProvider.instance),
        ChangeNotifierProvider<RecipesProvider>.value(value: RecipesProvider.instance),
        ChangeNotifierProvider<MenuProvider>.value(value: MenuProvider.instance),
      ],
      child: const MaterialApp(home: RecipesPage()),
    ),
  );
  await tester.pump();
}

/// Selects the recipe in the list and asks to delete it, so the confirmation dialog appears.
Future<void> _openDeleteDialog(WidgetTester tester) async {
  await tester.tap(find.text("Paella"));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(TextButton, "Delete"));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    IngredientsProvider.instance.setData([]);
    RecipesProvider.instance.setData([_paella], ingredients: []);
    MenuProvider.setMultiWeekMenu(null);
  });
  tearDown(() => MenuProvider.setMultiWeekMenu(null));

  group("RecipesPage delete confirmation", () {
    testWidgets("names the meal slot by weekday when the menu has no first day", (WidgetTester tester) async {
      MenuProvider.setMultiWeekMenu(_menuWithPaella());
      await _pumpRecipesPage(tester);

      await _openDeleteDialog(tester);

      expect(find.text("- Week 1 - Monday lunch"), findsOneWidget);
    });

    testWidgets("adds the real date of the meal slot when the menu has a first day", (WidgetTester tester) async {
      // The menu starts on Wednesday 6 Aug 2025. The Monday slot is day 2, so 8 Aug.
      MenuProvider.setMultiWeekMenu(_menuWithPaella(startDate: DateTime(2025, 8, 6)));
      await _pumpRecipesPage(tester);

      await _openDeleteDialog(tester);

      expect(find.text("- Week 1 - Friday 8 Aug lunch"), findsOneWidget);
    });
  });
}
