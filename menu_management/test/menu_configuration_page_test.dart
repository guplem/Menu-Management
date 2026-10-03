import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:menu_management/menu/enums/meal_type.dart";
import "package:menu_management/menu/enums/week_day.dart";
import "package:menu_management/menu/menu_provider.dart";
import "package:menu_management/menu/models/meal.dart";
import "package:menu_management/menu/models/meal_time.dart";
import "package:menu_management/menu/models/menu_configuration.dart";
import "package:menu_management/menu/models/menu.dart";
import "package:menu_management/menu/models/multi_week_menu.dart";
import "package:menu_management/menu/models/sub_meal.dart";
import "package:menu_management/menu/widgets/menu_configuration_page.dart";
import "package:menu_management/recipes/enums/recipe_type.dart";
import "package:menu_management/recipes/enums/unit.dart";
import "package:menu_management/recipes/models/instruction.dart";
import "package:menu_management/recipes/models/recipe.dart";
import "package:menu_management/recipes/recipes_provider.dart";
import "package:menu_management/shopping/shopping_progress.dart";
import "package:provider/provider.dart";

Menu _week() {
  return Menu(
    meals: [
      const Meal(
        mealTime: MealTime(weekDay: WeekDay.saturday, mealType: MealType.lunch),
        subMeals: [SubMeal(people: 2)],
      ),
    ],
  );
}

/// Seeds enough recipes for the generator to fill every slot, so it does not warn.
void _seedRecipes() {
  RecipesProvider.instance.setData([
    for (int i = 0; i < 10; i++)
      Recipe(
        id: "b$i",
        name: "Breakfast $i",
        type: RecipeType.breakfast,
        lunch: false,
        dinner: false,
        instructions: [Instruction(id: "b${i}_i", description: "make it", workingTimeMinutes: 10, cookingTimeMinutes: 0)],
      ),
    for (int i = 0; i < 20; i++)
      Recipe(
        id: "m$i",
        name: "Meal $i",
        type: RecipeType.meal,
        lunch: true,
        dinner: true,
        carbs: true,
        instructions: [Instruction(id: "m${i}_i", description: "cook it", workingTimeMinutes: 20, cookingTimeMinutes: 0)],
      ),
  ], ingredients: []);
}

/// Renders the page on a desktop-sized surface, because the configuration grid needs seven columns.
Future<void> _pumpConfigurationPage(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1800, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<MenuProvider>.value(value: MenuProvider.instance),
        ChangeNotifierProvider<RecipesProvider>.value(value: RecipesProvider.instance),
      ],
      child: MaterialApp(
        // The flutter_test placeholder font is wider than the real font, so the menu page that the
        // generate button opens overflows its meal cards. Shrink the text scale to make room.
        builder: (BuildContext context, Widget? child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(0.7)),
          child: child!,
        ),
        home: const MenuConfigurationPage(),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  setUp(() => MenuProvider.setMultiWeekMenu(null));
  tearDown(() => MenuProvider.setMultiWeekMenu(null));

  group("MenuConfigurationPage cooking time", () {
    testWidgets("keeps an arithmetic expression while the user types it", (WidgetTester tester) async {
      // "120/1" is already valid and stores 120. A field that rebuilt from the stored value would
      // then show "120", and the next "0" would make "1200" instead of "120/10".
      MenuConfiguration original = MenuProvider.instance.configurations.first;
      addTearDown(() => MenuProvider.update(newConfiguration: original));
      MenuProvider.update(newConfiguration: original.copyWith(requiresMeal: true));
      await _pumpConfigurationPage(tester);

      Finder cookingTimeField = find.widgetWithText(TextField, "Cooking time").first;
      await tester.enterText(cookingTimeField, "120/1");
      await tester.pump();
      await tester.enterText(cookingTimeField, "120/10");
      await tester.pump();

      expect(tester.widget<TextField>(cookingTimeField).controller!.text, "120/10");
      expect(MenuProvider.instance.configurations.first.availableCookingTimeMinutes, 12);
    });
  });

  group("MenuConfigurationPage generate button", () {
    testWidgets("keeps the shopping progress of the active menu", (WidgetTester tester) async {
      _seedRecipes();
      const ShoppingProgress progress = ShoppingProgress(ownedAmounts: {"salt": (amount: 20, unit: Unit.grams)}, useFreezerStrategy: true);
      MenuProvider.setMultiWeekMenu(MultiWeekMenu(shoppingProgress: progress, weeks: [_week()]));
      await _pumpConfigurationPage(tester);

      await tester.tap(find.byTooltip("Generate Menu"));
      await tester.pumpAndSettle();

      expect(MenuProvider.instance.multiWeekMenu!.shoppingProgress, progress);
    });
  });

  group("MenuConfigurationPage day labels", () {
    testWidgets("starts at Saturday when no menu is active", (WidgetTester tester) async {
      await _pumpConfigurationPage(tester);

      expect(find.text("Saturday"), findsOneWidget);
      expect(find.text("Friday"), findsOneWidget);
    });

    testWidgets("borrows the weekday order of the active menu", (WidgetTester tester) async {
      // 2025-08-06 is a Wednesday, so the columns read Wednesday to Tuesday.
      MenuProvider.setMultiWeekMenu(MultiWeekMenu(startDate: DateTime(2025, 8, 6), weeks: [_week()]));

      await _pumpConfigurationPage(tester);

      expect(find.text("Wednesday"), findsOneWidget);
      expect(find.text("Tuesday"), findsOneWidget);
      expect(find.text("Saturday"), findsOneWidget);
    });

    testWidgets("follows the active menu when it changes while the page is open", (WidgetTester tester) async {
      await _pumpConfigurationPage(tester);
      expect(find.text("Saturday"), findsOneWidget);

      MenuProvider.setMultiWeekMenu(MultiWeekMenu(startDate: DateTime(2025, 8, 6), weeks: [_week()]));
      await tester.pump();

      expect(find.text("Wednesday"), findsOneWidget);
    });
  });
}
