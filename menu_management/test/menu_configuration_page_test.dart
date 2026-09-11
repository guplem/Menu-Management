import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:menu_management/menu/enums/meal_type.dart";
import "package:menu_management/menu/enums/week_day.dart";
import "package:menu_management/menu/menu_provider.dart";
import "package:menu_management/menu/models/meal.dart";
import "package:menu_management/menu/models/meal_time.dart";
import "package:menu_management/menu/models/menu.dart";
import "package:menu_management/menu/models/multi_week_menu.dart";
import "package:menu_management/menu/models/sub_meal.dart";
import "package:menu_management/menu/widgets/menu_configuration_page.dart";
import "package:menu_management/recipes/recipes_provider.dart";
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
      child: const MaterialApp(home: MenuConfigurationPage()),
    ),
  );
  await tester.pump();
}

void main() {
  setUp(() => MenuProvider.setMultiWeekMenu(null));
  tearDown(() => MenuProvider.setMultiWeekMenu(null));

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
