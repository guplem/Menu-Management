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

      expect(dishNoteText(dish(people: 2, source: MenuPdfDishSource.cooked, servingsToCook: 5)), "2p - cook 5 servings");
      expect(dishNoteText(dish(people: 1, source: MenuPdfDishSource.cooked, servingsToCook: 1)), "1p - cook 1 serving");
      expect(dishNoteText(dish(people: 3, source: MenuPdfDishSource.leftovers)), "3p - leftovers");
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
            slots: [MenuPdfSlot(mealType: MealType.lunch), MenuPdfSlot(mealType: MealType.dinner)],
          ),
        ],
      );

      expect(weekTableMealTypes(week), [MealType.lunch, MealType.dinner]);
      // A week with no day writes the three meals of the clock.
      expect(weekTableMealTypes(const MenuPdfWeekSection(title: "Week 1")), MealType.values);
    });

    test("writes the servings and the times under the name of a recipe", () {
      MenuPdfRecipeSection section = const MenuPdfRecipeSection(recipeName: "Pasta", servings: 5, workingTimeMinutes: 7, cookingTimeMinutes: 12);

      expect(recipeSummaryText(section), "5 servings - 19 min (7 min of work, 12 min of cooking)");
      expect(recipeSummaryText(section.copyWith(servings: 1)), "1 serving - 19 min (7 min of work, 12 min of cooking)");
    });

    test("writes one ingredient line, and numbers every step with its times and its ingredients", () {
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

      expect(ingredientLineText(const MenuPdfIngredientLine(ingredientName: "Noodles", amounts: "500 grams")), "Noodles: 500 grams");
      expect(stepTitleText(step), "1. Boil the pasta.");
      expect(stepDetailsText(step), "   5 min of work, 12 min of cooking - Noodles: 500 grams, Egg: 5 pieces");
      expect(stepDetailsText(step.copyWith(ingredients: [])), "   5 min of work, 12 min of cooking");
    });
  });

  group("renderMenuPdf", () {
    test("writes a day that holds four sub-meals with long names, because a table row cannot split over two pages", () async {
      MenuPdfSlot fullSlot(MealType mealType) => MenuPdfSlot(
        mealType: mealType,
        dishes: List<MenuPdfDish>.generate(
          4,
          (int index) => MenuPdfDish(
            recipeName: "Slow-roasted-aubergine-with-tahini-and-pomegranate number $index",
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
  });
}
