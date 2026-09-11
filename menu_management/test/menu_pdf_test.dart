import "dart:convert";
import "dart:typed_data";

import "package:flutter_test/flutter_test.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/menu/enums/meal_type.dart";
import "package:menu_management/menu/enums/week_day.dart";
import "package:menu_management/menu/menu_pdf.dart";
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
}
