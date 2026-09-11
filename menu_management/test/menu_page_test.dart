import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:menu_management/menu/enums/meal_type.dart";
import "package:menu_management/menu/enums/week_day.dart";
import "package:menu_management/menu/models/meal.dart";
import "package:menu_management/menu/models/meal_time.dart";
import "package:menu_management/menu/models/menu.dart";
import "package:menu_management/menu/models/multi_week_menu.dart";
import "package:menu_management/menu/models/sub_meal.dart";
import "package:menu_management/menu/widgets/menu_page.dart";
import "package:menu_management/recipes/enums/recipe_type.dart";
import "package:menu_management/recipes/models/instruction.dart";
import "package:menu_management/recipes/models/recipe.dart";
import "package:menu_management/recipes/recipes_provider.dart";

Recipe _breakfastRecipe(String id) {
  return Recipe(
    id: id,
    name: "Breakfast $id",
    type: RecipeType.breakfast,
    lunch: false,
    dinner: false,
    instructions: [Instruction(id: "${id}_i", description: "make it", workingTimeMinutes: 10, cookingTimeMinutes: 0)],
  );
}

Recipe _mealRecipe(String id) {
  return Recipe(
    id: id,
    name: "Meal $id",
    type: RecipeType.meal,
    lunch: true,
    dinner: true,
    carbs: true,
    instructions: [Instruction(id: "${id}_i", description: "cook it", workingTimeMinutes: 20, cookingTimeMinutes: 0)],
  );
}

/// The generator needs enough recipes to fill every slot, so it does not warn.
void _seedRecipes() {
  RecipesProvider.instance.setData([
    for (int i = 0; i < 10; i++) _breakfastRecipe("b$i"),
    for (int i = 0; i < 20; i++) _mealRecipe("m$i"),
  ], ingredients: []);
}

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

/// Renders the page on a desktop-sized surface, because the menu grid needs seven wide columns.
Future<void> _pumpMenuPage(WidgetTester tester, MultiWeekMenu menu) async {
  tester.view.physicalSize = const Size(1800, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: MenuPage(multiWeekMenu: menu)));
  await tester.pump();
}

void main() {
  setUp(_seedRecipes);

  group("MenuPage day columns", () {
    testWidgets("starts at Saturday and shows no dates when the menu has no start date", (WidgetTester tester) async {
      await _pumpMenuPage(tester, MultiWeekMenu(weeks: [_week()]));

      expect(find.text("Saturday"), findsOneWidget);
      expect(find.text("Friday"), findsOneWidget);
      expect(find.text("Set first day"), findsOneWidget);
      expect(find.textContaining("Aug"), findsNothing);
    });

    testWidgets("starts at the weekday of the start date and wraps around", (WidgetTester tester) async {
      // 2025-08-06 is a Wednesday, so the columns read Wednesday to Tuesday.
      await _pumpMenuPage(tester, MultiWeekMenu(startDate: DateTime(2025, 8, 6), weeks: [_week()]));

      expect(find.text("Wednesday"), findsOneWidget);
      expect(find.text("Tuesday"), findsOneWidget);
      expect(find.text("6 Aug"), findsOneWidget);
      expect(find.text("12 Aug"), findsOneWidget);
    });

    testWidgets("shows the date of every column of the second week", (WidgetTester tester) async {
      await _pumpMenuPage(tester, MultiWeekMenu(startDate: DateTime(2025, 8, 6), weeks: [_week(), _week()]));

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();

      expect(find.text("13 Aug"), findsOneWidget);
      expect(find.text("19 Aug"), findsOneWidget);
    });
  });

  group("MenuPage week navigator", () {
    testWidgets("shows the date range of the week on screen", (WidgetTester tester) async {
      await _pumpMenuPage(tester, MultiWeekMenu(startDate: DateTime(2025, 8, 6), weeks: [_week(), _week()]));

      expect(find.text("Week 1 / 2"), findsOneWidget);
      expect(find.text("6 Aug - 12 Aug"), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();

      expect(find.text("13 Aug - 19 Aug"), findsOneWidget);
    });

    testWidgets("shows no date range when the menu has no start date", (WidgetTester tester) async {
      await _pumpMenuPage(tester, MultiWeekMenu(weeks: [_week(), _week()]));

      expect(find.text("Week 1 / 2"), findsOneWidget);
      expect(find.textContaining(" - "), findsNothing);
    });
  });

  group("MenuPage regeneration", () {
    testWidgets("keeps the start date when the user regenerates the menu", (WidgetTester tester) async {
      await _pumpMenuPage(tester, MultiWeekMenu(startDate: DateTime(2025, 8, 6), weeks: [_week()]));

      await tester.tap(find.byIcon(Icons.refresh_rounded));
      await tester.pump();

      expect(find.text("Wednesday 6 Aug"), findsOneWidget);
      expect(find.text("6 Aug"), findsOneWidget);
      expect(find.text("Set first day"), findsNothing);
    });
  });

  group("MenuPage start date picker", () {
    testWidgets("opens on a start date that is years in the past", (WidgetTester tester) async {
      // The picker asserts that its initial date sits inside its bounds. A menu loaded from a
      // file can carry any date, so the bounds must follow the date on screen.
      final DateTime longAgo = DateTime(DateTime.now().year - 3, 5, 14);
      await _pumpMenuPage(tester, MultiWeekMenu(startDate: longAgo, weeks: [_week()]));

      await tester.tap(find.byIcon(Icons.event_rounded));
      await tester.pumpAndSettle();

      expect(find.text("Select the first day of the menu"), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets("opens on a start date that is years in the future", (WidgetTester tester) async {
      final DateTime farAhead = DateTime(DateTime.now().year + 9, 5, 14);
      await _pumpMenuPage(tester, MultiWeekMenu(startDate: farAhead, weeks: [_week()]));

      await tester.tap(find.byIcon(Icons.event_rounded));
      await tester.pumpAndSettle();

      expect(find.text("Select the first day of the menu"), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group("MenuPage start date control", () {
    testWidgets("names the first day and clears it again", (WidgetTester tester) async {
      await _pumpMenuPage(tester, MultiWeekMenu(startDate: DateTime(2025, 8, 6), weeks: [_week()]));

      expect(find.text("Wednesday 6 Aug"), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();

      expect(find.text("Set first day"), findsOneWidget);
      expect(find.text("Saturday"), findsOneWidget);
    });
  });

  group("MenuPage export button", () {
    testWidgets("opens the export dialog with both menu formats", (WidgetTester tester) async {
      await _pumpMenuPage(tester, MultiWeekMenu(weeks: [_week()]));

      await tester.tap(find.byTooltip("Export menu"));
      await tester.pumpAndSettle();

      expect(find.text("Export menu"), findsWidgets);
      expect(find.text("Simplified"), findsOneWidget);
      expect(find.text("Detailed"), findsOneWidget);
    });

    testWidgets("holds no direct copy button any more", (WidgetTester tester) async {
      await _pumpMenuPage(tester, MultiWeekMenu(weeks: [_week()]));

      expect(find.byTooltip("Copy to clipboard"), findsNothing);
    });
  });
}
