import "dart:convert";
import "dart:io";

import "package:file_picker/file_picker.dart";
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
import "package:menu_management/persistency.dart";
import "package:menu_management/recipes/recipes_provider.dart";
import "package:menu_management/shopping/shopping_ingredient.dart";
import "package:menu_management/shopping/shopping_page.dart";
import "package:menu_management/shopping/shopping_progress.dart";
import "package:provider/provider.dart";

const Ingredient _rice = Ingredient(
  id: "rice",
  name: "Rice",
  products: [Product(link: _riceLink, quantityPerItem: 500, itemsPerPack: 1, unit: Unit.grams)],
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

// The same milk, but a product that the user may freeze. The freezer mode then buys the milk of
// both weeks on the first trip and asks the user to freeze it.
const Ingredient _freezableMilk = Ingredient(
  id: "milk",
  name: "Milk",
  products: [
    Product(link: "https://example.com/milk", quantityPerItem: 1000, itemsPerPack: 1, unit: Unit.grams, shelfLifeDaysClosed: 3, canBeFrozen: true),
  ],
);

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

/// A two-week menu. The Friday cook of week 1 also feeds a leftover meal on the Saturday of week 2.
MultiWeekMenu _crossWeekLeftoverMenu() {
  return const MultiWeekMenu(
    weeks: [
      Menu(
        meals: [
          Meal(
            mealTime: MealTime(weekDay: WeekDay.friday, mealType: MealType.dinner),
            subMeals: [SubMeal(cooking: Cooking(recipeId: "r1", yield: 2), people: 2)],
          ),
        ],
      ),
      Menu(
        meals: [
          Meal(
            mealTime: MealTime(weekDay: WeekDay.saturday, mealType: MealType.lunch),
            subMeals: [SubMeal(cooking: Cooking(recipeId: "r1", yield: 0), people: 2)],
          ),
        ],
      ),
    ],
  );
}

// The product is sold in grams, but the recipe counts pieces. No product row matches the recipe
// unit, so the page shows the header "Owned" input with a unit dropdown: pieces, grams, packs.
const Ingredient _egg = Ingredient(
  id: "egg",
  name: "Egg",
  products: [Product(link: "https://example.com/eggs", quantityPerItem: 60, itemsPerPack: 6, unit: Unit.grams)],
);

/// A one-meal menu that cooks two eggs, with the [progress] that the user saved before.
MultiWeekMenu _eggMenu({required ShoppingProgress progress}) {
  return MultiWeekMenu(
    shoppingProgress: progress,
    weeks: const [
      Menu(
        meals: [
          Meal(
            mealTime: MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch),
            subMeals: [SubMeal(cooking: Cooking(recipeId: "r3", yield: 1), people: 1)],
          ),
        ],
      ),
    ],
  );
}

void _seedEggs() {
  const Recipe eggRecipe = Recipe(
    id: "r3",
    name: "Boiled eggs",
    instructions: [
      Instruction(
        id: "i3",
        description: "boil the eggs",
        workingTimeMinutes: 5,
        cookingTimeMinutes: 10,
        ingredientsUsed: [
          IngredientUsage(
            ingredient: "egg",
            quantity: Quantity(amount: 2, unit: Unit.pieces),
          ),
        ],
      ),
    ],
  );
  IngredientsProvider.instance.setData([_egg]);
  RecipesProvider.instance.setData([eggRecipe], ingredients: [_egg]);
}

/// The unit that the header "Owned" dropdown of the page shows.
OwnedUnit? _headerOwnedUnit(WidgetTester tester) {
  return tester.widget<DropdownButtonFormField<OwnedUnit>>(find.byType(DropdownButtonFormField<OwnedUnit>)).initialValue;
}

const String _breadLink = "https://example.com/bread";

// The store sells one loaf, so the weight product and the pieces product share one link.
const Ingredient _bread = Ingredient(
  id: "bread",
  name: "Bread",
  products: [
    Product(link: _breadLink, quantityPerItem: 400, itemsPerPack: 1, unit: Unit.grams),
    Product(link: _breadLink, quantityPerItem: 1, itemsPerPack: 1, unit: Unit.pieces),
  ],
);

// No product, so the header "Owned" input offers grams only, and no packs.
const Ingredient _salt = Ingredient(id: "salt", name: "Salt");

/// Seeds one recipe that needs [usages] and returns a one-meal menu that cooks it, with [progress].
MultiWeekMenu _seedSingleRecipeMenu({
  required List<Ingredient> ingredients,
  required List<IngredientUsage> usages,
  required ShoppingProgress progress,
}) {
  Recipe recipe = Recipe(
    id: "r4",
    name: "Test dish",
    instructions: [Instruction(id: "i4", description: "cook it", workingTimeMinutes: 5, cookingTimeMinutes: 0, ingredientsUsed: usages)],
  );
  IngredientsProvider.instance.setData(ingredients);
  RecipesProvider.instance.setData([recipe], ingredients: ingredients);
  return MultiWeekMenu(
    shoppingProgress: progress,
    weeks: const [
      Menu(
        meals: [
          Meal(
            mealTime: MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch),
            subMeals: [SubMeal(cooking: Cooking(recipeId: "r4", yield: 1), people: 1)],
          ),
        ],
      ),
    ],
  );
}

/// Finds the "Owned" field that shows [text] inside the product row of [productIndex].
Finder _ownedFieldOfProductRow({required int productIndex, required String text}) {
  return find.descendant(of: find.byKey(ValueKey<int>(productIndex)), matching: find.widgetWithText(TextField, text));
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

Future<void> _pumpShoppingPage(WidgetTester tester, MultiWeekMenu menu, {ValueChanged<ShoppingProgress>? onShoppingProgressChanged}) async {
  tester.view.physicalSize = const Size(1800, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<IngredientsProvider>.value(value: IngredientsProvider.instance),
        ChangeNotifierProvider<RecipesProvider>.value(value: RecipesProvider.instance),
      ],
      child: MaterialApp(
        // The flutter_test placeholder font is wider than the real font, so it overflows the
        // fixed-width unit dropdown of the header owned input. Shrink the text scale to make room.
        builder: (BuildContext context, Widget? child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(0.7)),
          child: child!,
        ),
        home: ShoppingPage(multiWeekMenu: menu, onShoppingProgressChanged: onShoppingProgressChanged),
      ),
    ),
  );
  await tester.pump();
}

/// A save dialog that returns [pickedPath], so a test says where the page saves the menu.
class _FakeFilePicker extends FilePicker {
  _FakeFilePicker(this.pickedPath);

  final String pickedPath;

  @override
  Future<String?> saveFile({
    String? dialogTitle,
    String? fileName,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Uint8List? bytes,
    bool lockParentWindow = false,
  }) async => pickedPath;
}

/// The link of the only rice product, which keys the saved owned count of that product.
const String _riceLink = "https://example.com/rice";

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
    testWidgets("opens the export dialog with the three text formats and the PDF", (WidgetTester tester) async {
      await _pumpShoppingPage(tester, _menu());

      await tester.tap(find.byTooltip("Export shopping list"));
      await tester.pumpAndSettle();

      expect(find.text("Export shopping list"), findsOneWidget);
      expect(find.text("Simplified"), findsOneWidget);
      expect(find.text("Detailed"), findsOneWidget);
      expect(find.text("Checklist"), findsOneWidget);
      expect(find.text("PDF"), findsOneWidget);
    });

    testWidgets("offers the export button as the only way to copy the list", (WidgetTester tester) async {
      // The two fixed-format copy buttons are gone. The export button replaces both of them.
      await _pumpShoppingPage(tester, _menu());

      expect(find.byTooltip("Export shopping list"), findsOneWidget);
      expect(find.byIcon(Icons.ios_share_rounded), findsOneWidget);
      expect(find.byTooltip("Copy to clipboard"), findsNothing);
    });
  });

  group("ShoppingPage export formats", () {
    testWidgets("copies the detailed list, with the trip section and the packs", (WidgetTester tester) async {
      await _pumpAndCopy(tester, format: "Detailed");

      expect(_copiedTexts.single.split("\n"), const ["now", "---", "Rice", "  500 grams/pack: 1 pack", "    https://example.com/rice"]);
    });

    testWidgets("copies the checklist, with the trip section and one line per pack", (WidgetTester tester) async {
      await _pumpAndCopy(tester, format: "Checklist");

      expect(_copiedTexts.single.split("\n"), const ["now", "---", "Rice - 500 grams/pack: 1 pack"]);
    });

    testWidgets("copies the simplified list, with no trip section and no pack", (WidgetTester tester) async {
      await _pumpAndCopy(tester, format: "Simplified");

      expect(_copiedTexts.single.split("\n"), const ["Rice: 400 grams"]);
    });

    testWidgets("keeps the freeze note of the trip plan in the simplified list", (WidgetTester tester) async {
      // The page must hand the freeze note of the trip plan to the simplified text. Without it the
      // one-trip plan cannot be followed: the milk of the second week waits a week in the fridge.
      IngredientsProvider.instance.setData([_freezableMilk]);
      RecipesProvider.instance.setData([_milkRecipe()], ingredients: [_freezableMilk]);
      await _pumpShoppingPage(tester, _twoWeekMilkMenu(startDate: DateTime(2025, 8, 6)));

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip("Export shopping list"));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Simplified"));
      await tester.pumpAndSettle();

      expect(_copiedTexts.single.split("\n"), const ["Milk: 1,200 grams (freeze on arrival)"]);
    });

    testWidgets("buys the food of a leftover meal of the next week with its cook event", (WidgetTester tester) async {
      // Issue #49: the Friday cook of week 1 also feeds the Saturday of week 2, so the list buys
      // 4 servings of 200 grams, all on the one trip before the cook event.
      await _pumpShoppingPage(tester, _crossWeekLeftoverMenu());

      await tester.tap(find.byTooltip("Export shopping list"));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Simplified"));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip("Export shopping list"));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Detailed"));
      await tester.pumpAndSettle();

      expect(_copiedTexts.map((String text) => text.split("\n")).toList(), const [
        ["Rice: 800 grams"],
        ["now", "---", "Rice", "  500 grams/pack: 2 packs", "    https://example.com/rice"],
      ]);
    });

    testWidgets("names the copied format in the snackbar", (WidgetTester tester) async {
      await _pumpAndCopy(tester, format: "Detailed");

      expect(find.text("Copied the detailed shopping list to the clipboard."), findsOneWidget);
    });
  });

  group("ShoppingPage progress", () {
    testWidgets("restores the owned count and the trip switch of the menu", (WidgetTester tester) async {
      MultiWeekMenu menu = _menu().copyWith(
        shoppingProgress: const ShoppingProgress(
          ownedProductCounts: {
            "rice": {(link: _riceLink, unit: Unit.grams): 2},
          },
          useFreezerStrategy: true,
        ),
      );

      await _pumpShoppingPage(tester, menu);

      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
      expect(_ownedFieldOfProductRow(productIndex: 0, text: "2"), findsOneWidget);
    });

    testWidgets("puts a restored count on the product of its link and unit when two products share a link", (WidgetTester tester) async {
      MultiWeekMenu menu = _seedSingleRecipeMenu(
        ingredients: const [_bread],
        usages: const [
          IngredientUsage(
            ingredient: "bread",
            quantity: Quantity(amount: 200, unit: Unit.grams),
          ),
          IngredientUsage(
            ingredient: "bread",
            quantity: Quantity(amount: 2, unit: Unit.pieces),
          ),
        ],
        progress: const ShoppingProgress(
          ownedProductCounts: {
            "bread": {(link: _breadLink, unit: Unit.pieces): 3},
          },
        ),
      );

      await _pumpShoppingPage(tester, menu);

      expect(_ownedFieldOfProductRow(productIndex: 1, text: "3"), findsOneWidget);
      expect(_ownedFieldOfProductRow(productIndex: 0, text: "3"), findsNothing);
    });

    testWidgets("restores a header owned amount in packs", (WidgetTester tester) async {
      _seedEggs();

      await _pumpShoppingPage(tester, _eggMenu(progress: const ShoppingProgress(ownedAmounts: {"egg": (amount: 2, unit: null)})));

      expect(find.widgetWithText(TextField, "2"), findsOneWidget);
      expect(_headerOwnedUnit(tester), const OwnedUnit());
    });

    testWidgets("drops a header owned amount in packs when the ingredient has no product", (WidgetTester tester) async {
      MultiWeekMenu menu = _seedSingleRecipeMenu(
        ingredients: const [_salt],
        usages: const [
          IngredientUsage(
            ingredient: "salt",
            quantity: Quantity(amount: 10, unit: Unit.grams),
          ),
        ],
        progress: const ShoppingProgress(ownedAmounts: {"salt": (amount: 3, unit: null)}),
      );

      await _pumpShoppingPage(tester, menu);

      expect(tester.takeException(), isNull);
      expect(find.widgetWithText(TextField, "3"), findsNothing);
    });

    testWidgets("drops a header owned amount when product rows replace the header input", (WidgetTester tester) async {
      List<ShoppingProgress> reported = [];
      MultiWeekMenu menu = _menu().copyWith(shoppingProgress: const ShoppingProgress(ownedAmounts: {"rice": (amount: 300, unit: Unit.grams)}));
      await _pumpShoppingPage(tester, menu, onShoppingProgressChanged: reported.add);

      await tester.tap(find.byType(Switch));
      await tester.pump();

      expect(reported.last, const ShoppingProgress(useFreezerStrategy: true));
    });

    testWidgets("restores the header owned amount and its unit", (WidgetTester tester) async {
      _seedEggs();

      await _pumpShoppingPage(tester, _eggMenu(progress: const ShoppingProgress(ownedAmounts: {"egg": (amount: 120, unit: Unit.grams)})));

      expect(find.widgetWithText(TextField, "120"), findsOneWidget);
      expect(_headerOwnedUnit(tester), const OwnedUnit(unit: Unit.grams));
    });

    testWidgets("drops a saved owned amount in a unit that the dropdown does not offer", (WidgetTester tester) async {
      _seedEggs();

      await _pumpShoppingPage(tester, _eggMenu(progress: const ShoppingProgress(ownedAmounts: {"egg": (amount: 3, unit: Unit.teaspoons)})));

      expect(tester.takeException(), isNull);
      expect(find.widgetWithText(TextField, "3"), findsNothing);
      expect(_headerOwnedUnit(tester), const OwnedUnit(unit: Unit.pieces));
    });

    testWidgets("reports the owned count keyed by the product link", (WidgetTester tester) async {
      List<ShoppingProgress> reported = [];
      await _pumpShoppingPage(tester, _menu(), onShoppingProgressChanged: reported.add);

      await tester.enterText(find.widgetWithText(TextField, "Owned"), "2");
      await tester.pump();

      expect(
        reported.last,
        const ShoppingProgress(
          ownedProductCounts: {
            "rice": {(link: _riceLink, unit: Unit.grams): 2},
          },
        ),
      );
    });

    testWidgets("reports the trip switch", (WidgetTester tester) async {
      List<ShoppingProgress> reported = [];
      await _pumpShoppingPage(tester, _menu(), onShoppingProgressChanged: reported.add);

      await tester.tap(find.byType(Switch));
      await tester.pump();

      expect(reported.last, const ShoppingProgress(useFreezerStrategy: true));
    });

    testWidgets("saves the menu with the progress on screen", (WidgetTester tester) async {
      Directory tempDir = Directory.systemTemp.createTempSync("shopping_page_save_test_");
      addTearDown(() => tempDir.deleteSync(recursive: true));
      Persistency.sessionDirOverride = tempDir.path;
      addTearDown(() => Persistency.sessionDirOverride = null);
      File savedFile = File("${tempDir.path}/menu.tsm");
      FilePicker.platform = _FakeFilePicker(savedFile.path);
      await _pumpShoppingPage(tester, _menu());

      await tester.enterText(find.widgetWithText(TextField, "Owned"), "2");
      await tester.pump();
      // The save writes a real file, so the test taps and waits on real time and not on the fake clock.
      Map<String, dynamic>? savedJson;
      await tester.runAsync(() async {
        await tester.tap(find.byTooltip("Save Menu"));
        for (int attempt = 0; attempt < 100 && savedJson == null; attempt++) {
          await Future<void>.delayed(const Duration(milliseconds: 20));
          if (savedFile.existsSync()) {
            try {
              savedJson = jsonDecode(savedFile.readAsStringSync());
            } on FormatException {
              savedJson = null;
            }
          }
        }
      });

      expect(savedJson!["shoppingProgress"], {
        "ownedProductCounts": {
          "rice": [
            {"link": _riceLink, "unit": "grams", "count": 2.0},
          ],
        },
      });
    });
  });
}
