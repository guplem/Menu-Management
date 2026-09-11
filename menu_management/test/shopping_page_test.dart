import "package:flutter/material.dart";
import "package:flutter/services.dart";
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

// A short sealed shelf life forces the planner to schedule one trip per week.
const Ingredient _milk = Ingredient(
  id: "milk",
  name: "Milk",
  products: [Product(link: "https://example.com/milk", quantityPerItem: 1000, itemsPerPack: 1, unit: Unit.grams, shelfLifeDaysClosed: 3)],
);

Recipe _milkRecipe() {
  return const Recipe(
    id: "r2",
    name: "Milk bowl",
    instructions: [
      Instruction(
        id: "i2",
        description: "pour the milk",
        workingTimeMinutes: 5,
        cookingTimeMinutes: 0,
        ingredientsUsed: [
          IngredientUsage(
            ingredient: "milk",
            quantity: Quantity(amount: 300, unit: Unit.grams),
          ),
        ],
      ),
    ],
  );
}

/// A two-week menu that cooks the milk recipe on the Monday of each week.
MultiWeekMenu _twoWeekMilkMenu({required DateTime startDate}) {
  const Menu week = Menu(
    meals: [
      Meal(
        mealTime: MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch),
        subMeals: [SubMeal(cooking: Cooking(recipeId: "r2", yield: 1), people: 2)],
      ),
    ],
  );
  return MultiWeekMenu(startDate: startDate, weeks: const [week, week]);
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

/// The texts that the page copied to the clipboard, in the order of the copies.
late List<String> _copiedTexts;

/// Opens the export dialog of the shopping page and picks one format.
Future<void> _pumpAndCopy(WidgetTester tester, {required String format}) async {
  await _pumpShoppingPage(tester, _menu());
  await tester.tap(find.byTooltip("Export shopping list"));
  await tester.pumpAndSettle();
  await tester.tap(find.text(format));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    IngredientsProvider.instance.setData([_rice]);
    RecipesProvider.instance.setData([_riceRecipe()], ingredients: [_rice]);
    _copiedTexts = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (MethodCall call) async {
      if (call.method == "Clipboard.setData") _copiedTexts.add((call.arguments as Map<Object?, Object?>)["text"]! as String);
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null);
  });

  group("ShoppingPage trip banner", () {
    testWidgets("says now for the only trip when the menu has no first day", (WidgetTester tester) async {
      await _pumpShoppingPage(tester, _menu());

      expect(find.textContaining("Multi-trip mode: the detailed export splits into 1 trip (now)."), findsOneWidget);
    });

    testWidgets("says now for the only trip when the menu has a first day", (WidgetTester tester) async {
      // The trip of the first week happens the day before menu day 0, a day already past.
      // The banner must match the product row, which calls that same trip "now".
      await _pumpShoppingPage(tester, _menu(startDate: DateTime(2025, 8, 6)));

      expect(find.textContaining("Multi-trip mode: the detailed export splits into 1 trip (now)."), findsOneWidget);
    });

    testWidgets("keeps the real date of a later trip", (WidgetTester tester) async {
      IngredientsProvider.instance.setData([_milk]);
      RecipesProvider.instance.setData([_milkRecipe()], ingredients: [_milk]);
      // The menu starts on Wednesday 6 Aug 2025. The second trip happens on day 6, 12 Aug.
      await _pumpShoppingPage(tester, _twoWeekMilkMenu(startDate: DateTime(2025, 8, 6)));

      expect(find.textContaining("Multi-trip mode: the detailed export splits into 2 trips (now, Tuesday 12 Aug)."), findsOneWidget);
    });
  });

  group("ShoppingPage export button", () {
    testWidgets("opens the export dialog with both shopping formats", (WidgetTester tester) async {
      await _pumpShoppingPage(tester, _menu());

      await tester.tap(find.byTooltip("Export shopping list"));
      await tester.pumpAndSettle();

      expect(find.text("Export shopping list"), findsOneWidget);
      expect(find.text("Simplified"), findsOneWidget);
      expect(find.text("Detailed"), findsOneWidget);
    });

    testWidgets("offers the export button as the only way to copy the list", (WidgetTester tester) async {
      // The two fixed-format copy buttons are gone. The export button replaces both of them.
      await _pumpShoppingPage(tester, _menu());

      expect(find.byTooltip("Export shopping list"), findsOneWidget);
      expect(find.byIcon(Icons.ios_share_rounded), findsOneWidget);
    });
  });

  group("ShoppingPage export formats", () {
    testWidgets("copies the detailed list, with the trip section and the packs", (WidgetTester tester) async {
      await _pumpAndCopy(tester, format: "Detailed");

      expect(_copiedTexts.single.split("\n"), const ["now", "---", "Rice", "  500 grams/pack: 1 pack", "    https://example.com/rice"]);
    });

    testWidgets("copies the simplified list, with no trip section and no pack", (WidgetTester tester) async {
      await _pumpAndCopy(tester, format: "Simplified");

      expect(_copiedTexts.single.split("\n"), const ["Rice: 400 grams"]);
    });

    testWidgets("names the copied format in the snackbar", (WidgetTester tester) async {
      await _pumpAndCopy(tester, format: "Detailed");

      expect(find.text("Copied the detailed shopping list to the clipboard."), findsOneWidget);
    });
  });
}
