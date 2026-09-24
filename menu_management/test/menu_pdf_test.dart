import "dart:convert";
import "dart:typed_data";

import "package:flutter_test/flutter_test.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/menu/enums/meal_type.dart";
import "package:menu_management/menu/enums/week_day.dart";
import "package:menu_management/menu/menu_pdf.dart";
import "package:menu_management/menu/menu_pdf_document.dart";
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

import "helpers/pdf_bytes_reader.dart";

Recipe _pasta() => const Recipe(
  id: "r1",
  name: "Pasta",
  instructions: [
    Instruction(
      id: "i1",
      description: "Boil the pasta.",
      workingTimeMinutes: 5,
      cookingTimeMinutes: 12,
      ingredientsUsed: [
        IngredientUsage(
          ingredient: "n1",
          quantity: Quantity(amount: 100, unit: Unit.grams),
        ),
      ],
    ),
  ],
);

Meal _meal({required WeekDay weekDay, required MealType mealType, String? recipeId, int yield = 1, int people = 2}) => Meal(
  mealTime: MealTime(weekDay: weekDay, mealType: mealType),
  subMeals: [
    SubMeal(
      cooking: recipeId == null ? null : Cooking(recipeId: recipeId, yield: yield),
      people: people,
    ),
  ],
);

MultiWeekMenu _twoWeekMenu() => MultiWeekMenu(
  startDate: DateTime(2025, 8, 6),
  weeks: [
    Menu(
      meals: [
        _meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipeId: "r1"),
        _meal(weekDay: WeekDay.sunday, mealType: MealType.lunch, recipeId: "r1", yield: 0, people: 3),
        _meal(weekDay: WeekDay.monday, mealType: MealType.dinner),
      ],
    ),
    Menu(
      meals: [_meal(weekDay: WeekDay.friday, mealType: MealType.dinner, recipeId: "r1")],
    ),
  ],
);

void main() {
  group("buildMenuPdfBytes", () {
    test("writes a file that every reader accepts: a PDF header and an end-of-file marker", () async {
      Uint8List bytes = await buildMenuPdfBytes(
        multiWeekMenu: _twoWeekMenu(),
        recipes: [_pasta()],
        ingredients: [const Ingredient(id: "n1", name: "Noodles")],
      );

      expect(latin1.decode(bytes.sublist(0, 5)), "%PDF-");
      expect(latin1.decode(bytes.sublist(bytes.length - 6)).trim(), "%%EOF");
    });

    test("writes a file for a menu that holds no meal at all, so the export never fails on an empty menu", () async {
      Uint8List bytes = await buildMenuPdfBytes(
        multiWeekMenu: const MultiWeekMenu(weeks: [Menu()]),
        recipes: [],
        ingredients: [],
      );

      expect(latin1.decode(bytes.sublist(0, 5)), "%PDF-");
      expect(latin1.decode(bytes.sublist(bytes.length - 6)).trim(), "%%EOF");
    });
  });

  group("the text that the renderer writes", () {
    test("writes the note of a dish under its name", () {
      MenuPdfDish dish({required int people, required MenuPdfDishSource source, int servingsToCook = 0}) =>
          MenuPdfDish(recipeName: "Pasta", people: people, source: source, servingsToCook: servingsToCook);

      expect(dishNoteText(dish(people: 2, source: MenuPdfDishSource.cooked, servingsToCook: 5)), "2p · cook 5 servings");
      expect(dishNoteText(dish(people: 1, source: MenuPdfDishSource.cooked, servingsToCook: 1)), "1p · cook 1 serving");
      expect(dishNoteText(dish(people: 3, source: MenuPdfDishSource.leftovers)), "3p · leftovers");
      // A dish with no recipe keeps its people count: an empty meal for two is a gap to see.
      expect(dishNoteText(dish(people: 2, source: MenuPdfDishSource.empty)), "2p");
    });

    test("writes a dash in a slot that holds no meal, the same dash as a dish with no recipe", () {
      expect(emptySlotText, "-");
      expect(emptySlotText, emptyDishName);
    });

    test("names the columns of the week table", () {
      expect(dayColumnHeaderText, "Day");
      expect(MealType.values.map(mealTypeHeaderText).toList(), ["Breakfast", "Lunch", "Dinner"]);
    });

    test("takes the columns of the week table from the slots, so the header and the cells match", () {
      MenuPdfWeekSection week = const MenuPdfWeekSection(
        title: "Week 1",
        days: [
          MenuPdfDayRow(
            dayLabel: "Saturday",
            slots: [
              MenuPdfSlot(mealType: MealType.lunch),
              MenuPdfSlot(mealType: MealType.dinner),
            ],
          ),
        ],
      );

      expect(weekTableMealTypes(week), [MealType.lunch, MealType.dinner]);
      // A week with no day writes the three meals of the clock.
      expect(weekTableMealTypes(const MenuPdfWeekSection(title: "Week 1")), MealType.values);
    });

    test("counts the weeks and the recipes under the title", () {
      MenuPdfRecipeSection recipe = const MenuPdfRecipeSection(recipeName: "Pasta", servings: 2, workingTimeMinutes: 1, cookingTimeMinutes: 1);
      MenuPdfWeekSection week = const MenuPdfWeekSection(title: "Week 1");

      expect(menuSubtitleText(MenuPdfDocument(title: "Menu", weeks: [week, week, week], recipes: [recipe, recipe])), "3 weeks · 2 recipes");
      expect(menuSubtitleText(MenuPdfDocument(title: "Menu", weeks: [week], recipes: [recipe])), "1 week · 1 recipe");
      expect(menuSubtitleText(const MenuPdfDocument(title: "Menu")), "0 weeks · 0 recipes");
    });

    test("writes the servings and the times of a recipe as one fact each", () {
      MenuPdfRecipeSection section = const MenuPdfRecipeSection(recipeName: "Pasta", servings: 5, workingTimeMinutes: 7, cookingTimeMinutes: 12);

      expect(recipeFactTexts(section), ["5 servings", "19 min in total", "7 min of work", "12 min of cooking"]);
      expect(recipeFactTexts(section.copyWith(servings: 1)), ["1 serving", "19 min in total", "7 min of work", "12 min of cooking"]);
    });

    test("writes the times of a step, and the ingredients that it uses on a line of their own", () {
      MenuPdfStep step = const MenuPdfStep(
        number: 1,
        description: "Boil the pasta.",
        workingTimeMinutes: 5,
        cookingTimeMinutes: 12,
        ingredients: [
          MenuPdfIngredientLine(ingredientName: "Noodles", amounts: "500 grams"),
          MenuPdfIngredientLine(ingredientName: "Egg", amounts: "5 pieces"),
        ],
      );

      expect(stepTimesText(step), "5 min of work · 12 min of cooking");
      expect(stepIngredientsText(step), "Uses: Noodles (500 grams), Egg (5 pieces)");
      // A step that uses no ingredient writes no ingredient line.
      expect(stepIngredientsText(step.copyWith(ingredients: [])), "");
    });

    test("explains the two notes of a dish in the legend", () {
      expect(cookLegendText, "cook N servings: cook at this meal. N counts the leftovers for later meals too.");
      expect(leftoversLegendText, "leftovers: eat the food of an earlier cook.");
    });
  });

  group("renderMenuPdf", () {
    test("caps every dish name at two lines, so a day of twenty long dishes still fits one row on a page", () async {
      // A table row cannot split over two pages: the renderer throws when one row is taller than
      // a page. Twenty dishes of six lines each pass that height, and the two-line cap holds them
      // under it. Remove the `maxLines` of the dish name and this test throws.
      MenuPdfSlot fullSlot(MealType mealType) => MenuPdfSlot(
        mealType: mealType,
        dishes: List<MenuPdfDish>.generate(
          20,
          (int index) => MenuPdfDish(
            recipeName: "Slow roasted aubergine with tahini and pomegranate and toasted pine nuts and flat leaf parsley number $index",
            people: 2,
            source: MenuPdfDishSource.cooked,
            servingsToCook: 4,
          ),
        ),
      );
      MenuPdfDocument document = MenuPdfDocument(
        title: "Menu 6 Aug - 12 Aug",
        weeks: [
          MenuPdfWeekSection(
            title: "Week 1",
            days: List<MenuPdfDayRow>.generate(
              7,
              (int index) => MenuPdfDayRow(dayLabel: "Day $index", slots: MealType.values.map(fullSlot).toList()),
            ),
          ),
        ],
      );

      Uint8List bytes = await renderMenuPdf(document);

      expect(latin1.decode(bytes.sublist(0, 5)), "%PDF-");
    });

    test("writes a file for a menu that holds no week at all", () async {
      Uint8List bytes = await renderMenuPdf(const MenuPdfDocument(title: "Menu"));

      expect(latin1.decode(bytes.sublist(0, 5)), "%PDF-");
    });

    test("starts every week and the recipes on a new page, so no week table breaks in the middle", () async {
      MenuPdfWeekSection week(int number) => MenuPdfWeekSection(
        title: "Week $number",
        days: const [
          MenuPdfDayRow(
            dayLabel: "Saturday",
            slots: [MenuPdfSlot(mealType: MealType.lunch)],
          ),
        ],
      );
      MenuPdfDocument document = MenuPdfDocument(
        title: "Menu",
        weeks: [week(1), week(2)],
        recipes: const [MenuPdfRecipeSection(recipeName: "Pasta", servings: 2, workingTimeMinutes: 1, cookingTimeMinutes: 1)],
      );

      Uint8List bytes = await renderMenuPdf(document);

      // Two small weeks and one small recipe fit one page together. Three pages prove the breaks.
      expect(pdfPageCount(bytes), 3);
      expect(drawnPdfText(bytes).contains("Menu · Page 3 of 3"), isTrue);
    });

    test("draws every part of a recipe: the facts, the ingredients, the steps and their times", () async {
      MenuPdfDocument document = const MenuPdfDocument(
        title: "Menu",
        recipes: [
          MenuPdfRecipeSection(
            recipeName: "Pasta",
            servings: 5,
            workingTimeMinutes: 7,
            cookingTimeMinutes: 12,
            ingredients: [MenuPdfIngredientLine(ingredientName: "Noodles", amounts: "500 grams")],
            steps: [
              MenuPdfStep(
                number: 1,
                description: "Boil the pasta.",
                workingTimeMinutes: 5,
                cookingTimeMinutes: 12,
                ingredients: [MenuPdfIngredientLine(ingredientName: "Noodles", amounts: "500 grams")],
              ),
            ],
          ),
        ],
      );

      String drawn = drawnPdfText(await renderMenuPdf(document));

      expect(drawn.contains("5 servings 19 min in total 7 min of work 12 min of cooking"), isTrue);
      expect(drawn.contains("Noodles 500 grams"), isTrue);
      expect(drawn.contains("1 Boil the pasta. 5 min of work · 12 min of cooking Uses: Noodles (500 grams)"), isTrue);
    });
  });
}
