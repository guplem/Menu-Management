import "package:flutter_test/flutter_test.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/menu/enums/meal_type.dart";
import "package:menu_management/menu/enums/week_day.dart";
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

Ingredient _ingredient({required String id, required String name}) => Ingredient(id: id, name: name);

IngredientUsage _usage({required String ingredientId, required double amount, Unit unit = Unit.grams}) => IngredientUsage(
  ingredient: ingredientId,
  quantity: Quantity(amount: amount, unit: unit),
);

Instruction _instruction({
  required String id,
  required String description,
  List<IngredientUsage> ingredientsUsed = const [],
  int workingTimeMinutes = 10,
  int cookingTimeMinutes = 10,
}) => Instruction(
  id: id,
  description: description,
  ingredientsUsed: ingredientsUsed,
  workingTimeMinutes: workingTimeMinutes,
  cookingTimeMinutes: cookingTimeMinutes,
);

Recipe _recipe({required String id, required String name, List<Instruction> instructions = const [], int maxStorageDays = 6}) =>
    Recipe(id: id, name: name, instructions: instructions, maxStorageDays: maxStorageDays);

Meal _meal({required WeekDay weekDay, required MealType mealType, String? recipeId, int yield = 1, int people = 2, List<SubMeal>? subMeals}) => Meal(
  mealTime: MealTime(weekDay: weekDay, mealType: mealType),
  subMeals:
      subMeals ??
      [
        SubMeal(
          cooking: recipeId == null ? null : Cooking(recipeId: recipeId, yield: yield),
          people: people,
        ),
      ],
);

/// The empty slot of every day and meal that the test does not fill.
const MenuPdfSlot _emptyBreakfast = MenuPdfSlot(mealType: MealType.breakfast);
const MenuPdfSlot _emptyLunch = MenuPdfSlot(mealType: MealType.lunch);
const MenuPdfSlot _emptyDinner = MenuPdfSlot(mealType: MealType.dinner);

void main() {
  group("buildMenuPdfDocument weeks", () {
    test("titles the document and every week with the dates of the menu", () {
      Recipe pasta = _recipe(id: "r1", name: "Pasta");
      MultiWeekMenu menu = MultiWeekMenu(
        startDate: DateTime(2025, 8, 6),
        weeks: [
          Menu(
            meals: [_meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipeId: "r1")],
          ),
          Menu(
            meals: [_meal(weekDay: WeekDay.sunday, mealType: MealType.dinner, recipeId: "r1")],
          ),
        ],
      );

      MenuPdfDocument document = buildMenuPdfDocument(multiWeekMenu: menu, recipes: [pasta], ingredients: []);

      expect(document.title, "Menu 6 Aug - 19 Aug");
      expect(document.weeks.map((MenuPdfWeekSection week) => week.title).toList(), ["Week 1 (6 Aug - 12 Aug)", "Week 2 (13 Aug - 19 Aug)"]);
    });

    test("titles the document and every week without dates when the menu has no first day", () {
      Recipe pasta = _recipe(id: "r1", name: "Pasta");
      MultiWeekMenu menu = MultiWeekMenu(
        weeks: [
          Menu(
            meals: [_meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipeId: "r1")],
          ),
        ],
      );

      MenuPdfDocument document = buildMenuPdfDocument(multiWeekMenu: menu, recipes: [pasta], ingredients: []);

      expect(document.title, "Menu");
      expect(document.weeks.map((MenuPdfWeekSection week) => week.title).toList(), ["Week 1"]);
    });

    test("titles a menu that holds no week 'Menu', because such a menu covers no day", () {
      MultiWeekMenu menu = MultiWeekMenu(startDate: DateTime(2025, 8, 6), weeks: const []);

      MenuPdfDocument document = buildMenuPdfDocument(multiWeekMenu: menu, recipes: [], ingredients: []);

      expect(document.title, "Menu");
      expect(document.weeks, isEmpty);
    });

    test("writes one row per day, in the order of the week, with the real date of each day", () {
      Recipe pasta = _recipe(id: "r1", name: "Pasta");
      MultiWeekMenu menu = MultiWeekMenu(
        startDate: DateTime(2025, 8, 6),
        weeks: [
          Menu(
            meals: [_meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipeId: "r1")],
          ),
        ],
      );

      MenuPdfDocument document = buildMenuPdfDocument(multiWeekMenu: menu, recipes: [pasta], ingredients: []);

      expect(document.weeks.single.days.map((MenuPdfDayRow day) => day.dayLabel).toList(), [
        "Wednesday 6 Aug",
        "Thursday 7 Aug",
        "Friday 8 Aug",
        "Saturday 9 Aug",
        "Sunday 10 Aug",
        "Monday 11 Aug",
        "Tuesday 12 Aug",
      ]);
    });

    test("writes the three meal slots of a day, and leaves the slots with no meal empty", () {
      Recipe pasta = _recipe(id: "r1", name: "Pasta");
      MultiWeekMenu menu = MultiWeekMenu(
        weeks: [
          Menu(
            meals: [_meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipeId: "r1", people: 2)],
          ),
        ],
      );

      MenuPdfDocument document = buildMenuPdfDocument(multiWeekMenu: menu, recipes: [pasta], ingredients: []);

      expect(
        document.weeks.single.days.first,
        const MenuPdfDayRow(
          dayLabel: "Saturday",
          slots: [
            _emptyBreakfast,
            MenuPdfSlot(
              mealType: MealType.lunch,
              dishes: [MenuPdfDish(recipeName: "Pasta", people: 2, source: MenuPdfDishSource.cooked, servingsToCook: 2)],
            ),
            _emptyDinner,
          ],
        ),
      );
    });

    test("counts the servings of a cook event that also feeds a meal of the next week", () {
      Recipe pasta = _recipe(id: "r1", name: "Pasta");
      MultiWeekMenu menu = MultiWeekMenu(
        weeks: [
          Menu(
            meals: [_meal(weekDay: WeekDay.friday, mealType: MealType.lunch, recipeId: "r1", people: 2)],
          ),
          Menu(
            meals: [_meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipeId: "r1", yield: 0, people: 3)],
          ),
        ],
      );

      MenuPdfDocument document = buildMenuPdfDocument(multiWeekMenu: menu, recipes: [pasta], ingredients: []);

      // The cook event of week 1 feeds the leftover meal of week 2, so it cooks 2 + 3 servings.
      expect(document.weeks.first.days.last.slots[1].dishes, const [
        MenuPdfDish(recipeName: "Pasta", people: 2, source: MenuPdfDishSource.cooked, servingsToCook: 5),
      ]);
      expect(document.weeks.last.days.first.slots[1].dishes, const [
        MenuPdfDish(recipeName: "Pasta", people: 3, source: MenuPdfDishSource.leftovers, servingsToCook: 0),
      ]);
    });

    test("writes one dish per sub-meal of a slot, and an empty dish for a sub-meal with no recipe", () {
      Recipe pasta = _recipe(id: "r1", name: "Pasta");
      MultiWeekMenu menu = MultiWeekMenu(
        weeks: [
          Menu(
            meals: [
              _meal(
                weekDay: WeekDay.saturday,
                mealType: MealType.dinner,
                subMeals: [
                  SubMeal(cooking: const Cooking(recipeId: "r1", yield: 1), people: 2),
                  const SubMeal(people: 1),
                ],
              ),
            ],
          ),
        ],
      );

      MenuPdfDocument document = buildMenuPdfDocument(multiWeekMenu: menu, recipes: [pasta], ingredients: []);

      expect(
        document.weeks.single.days.first.slots.last,
        const MenuPdfSlot(
          mealType: MealType.dinner,
          dishes: [
            MenuPdfDish(recipeName: "Pasta", people: 2, source: MenuPdfDishSource.cooked, servingsToCook: 2),
            MenuPdfDish(recipeName: "-", people: 1, source: MenuPdfDishSource.empty, servingsToCook: 0),
          ],
        ),
      );
    });

    test("writes a dash as the dish of a meal whose recipe is deleted", () {
      MultiWeekMenu menu = MultiWeekMenu(
        weeks: [
          Menu(
            meals: [_meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipeId: "gone", people: 2)],
          ),
        ],
      );

      MenuPdfDocument document = buildMenuPdfDocument(multiWeekMenu: menu, recipes: [], ingredients: []);

      expect(document.weeks.single.days.first.slots[1].dishes, const [
        MenuPdfDish(recipeName: "-", people: 2, source: MenuPdfDishSource.empty, servingsToCook: 0),
      ]);
      // The cell must ask for no work: the reader has no recipe to cook from.
      expect(document.weeks.single.days.first.slots[1].dishes.single.note, "");
      expect(document.recipes, isEmpty);
    });

    test("names the cook note of every dish", () {
      expect(const MenuPdfDish(recipeName: "Pasta", people: 2, source: MenuPdfDishSource.cooked, servingsToCook: 5).note, "cook 5 servings");
      expect(const MenuPdfDish(recipeName: "Pasta", people: 1, source: MenuPdfDishSource.cooked, servingsToCook: 1).note, "cook 1 serving");
      expect(const MenuPdfDish(recipeName: "Pasta", people: 2, source: MenuPdfDishSource.leftovers, servingsToCook: 0).note, "leftovers");
      expect(const MenuPdfDish(recipeName: "-", people: 2, source: MenuPdfDishSource.empty, servingsToCook: 0).note, "");
    });
  });

  group("buildMenuPdfDocument recipes", () {
    test("prints every recipe of the menu once, in the order of its first meal", () {
      Recipe pasta = _recipe(id: "r1", name: "Pasta");
      Recipe soup = _recipe(id: "r2", name: "Soup");
      MultiWeekMenu menu = MultiWeekMenu(
        weeks: [
          Menu(
            meals: [
              _meal(weekDay: WeekDay.sunday, mealType: MealType.lunch, recipeId: "r2"),
              _meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipeId: "r1"),
              _meal(weekDay: WeekDay.monday, mealType: MealType.dinner, recipeId: "r1"),
            ],
          ),
        ],
      );

      MenuPdfDocument document = buildMenuPdfDocument(multiWeekMenu: menu, recipes: [pasta, soup], ingredients: []);

      expect(document.recipes.map((MenuPdfRecipeSection recipe) => recipe.recipeName).toList(), ["Pasta", "Soup"]);
    });

    test("scales the ingredients of a recipe to the servings that the whole menu cooks", () {
      Recipe pasta = _recipe(
        id: "r1",
        name: "Pasta",
        instructions: [
          _instruction(
            id: "i1",
            description: "Boil the pasta.",
            ingredientsUsed: [
              _usage(ingredientId: "n1", amount: 80),
              _usage(ingredientId: "n2", amount: 1, unit: Unit.pieces),
            ],
          ),
          _instruction(
            id: "i2",
            description: "Add the sauce.",
            ingredientsUsed: [_usage(ingredientId: "n1", amount: 20)],
          ),
        ],
      );
      MultiWeekMenu menu = MultiWeekMenu(
        weeks: [
          Menu(
            meals: [
              _meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipeId: "r1", people: 2),
              _meal(weekDay: WeekDay.sunday, mealType: MealType.lunch, recipeId: "r1", yield: 0, people: 3),
            ],
          ),
        ],
      );

      MenuPdfDocument document = buildMenuPdfDocument(
        multiWeekMenu: menu,
        recipes: [pasta],
        ingredients: [
          _ingredient(id: "n1", name: "Noodles"),
          _ingredient(id: "n2", name: "Egg"),
        ],
      );

      // One cook event of 5 servings: 100 grams of noodles and 1 egg per serving.
      expect(document.recipes.single.servings, 5);
      expect(document.recipes.single.ingredients, const [
        MenuPdfIngredientLine(ingredientName: "Noodles", amounts: "500 grams"),
        MenuPdfIngredientLine(ingredientName: "Egg", amounts: "5 pieces"),
      ]);
    });

    test("counts every eater once when the menu cooks the same fresh recipe twice on one day", () {
      // A recipe that keeps no leftovers (maxStorageDays: 0) gets one cook event per meal. The
      // ingredient list must buy for the four people that eat, not for eight.
      Recipe pasta = _recipe(
        id: "r1",
        name: "Pasta",
        maxStorageDays: 0,
        instructions: [
          _instruction(
            id: "i1",
            description: "Boil the pasta.",
            ingredientsUsed: [_usage(ingredientId: "n1", amount: 100)],
          ),
        ],
      );
      MultiWeekMenu menu = MultiWeekMenu(
        weeks: [
          Menu(
            meals: [
              _meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipeId: "r1", people: 2),
              _meal(weekDay: WeekDay.saturday, mealType: MealType.dinner, recipeId: "r1", people: 2),
            ],
          ),
        ],
      );

      MenuPdfDocument document = buildMenuPdfDocument(
        multiWeekMenu: menu,
        recipes: [pasta],
        ingredients: [_ingredient(id: "n1", name: "Noodles")],
      );

      expect(document.recipes.single.servings, 4);
      expect(document.recipes.single.ingredients, const [MenuPdfIngredientLine(ingredientName: "Noodles", amounts: "400 grams")]);
    });

    test("numbers the instructions and keeps the times and the ingredients of each one", () {
      Recipe pasta = _recipe(
        id: "r1",
        name: "Pasta",
        instructions: [
          _instruction(
            id: "i1",
            description: "Boil the pasta.",
            ingredientsUsed: [_usage(ingredientId: "n1", amount: 100)],
            workingTimeMinutes: 5,
            cookingTimeMinutes: 12,
          ),
          _instruction(id: "i2", description: "Serve.", workingTimeMinutes: 2, cookingTimeMinutes: 0),
        ],
      );
      MultiWeekMenu menu = MultiWeekMenu(
        weeks: [
          Menu(
            meals: [_meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipeId: "r1", people: 2)],
          ),
        ],
      );

      MenuPdfDocument document = buildMenuPdfDocument(
        multiWeekMenu: menu,
        recipes: [pasta],
        ingredients: [_ingredient(id: "n1", name: "Noodles")],
      );

      MenuPdfRecipeSection section = document.recipes.single;
      expect(section.workingTimeMinutes, 7);
      expect(section.cookingTimeMinutes, 12);
      expect(section.totalTimeMinutes, 19);
      expect(section.steps, const [
        MenuPdfStep(
          number: 1,
          description: "Boil the pasta.",
          workingTimeMinutes: 5,
          cookingTimeMinutes: 12,
          ingredients: [MenuPdfIngredientLine(ingredientName: "Noodles", amounts: "200 grams")],
        ),
        MenuPdfStep(number: 2, description: "Serve.", workingTimeMinutes: 2, cookingTimeMinutes: 0),
      ]);
    });

    test("names an ingredient that is not in the list, so the line never goes missing", () {
      Recipe pasta = _recipe(
        id: "r1",
        name: "Pasta",
        instructions: [
          _instruction(
            id: "i1",
            description: "Boil.",
            ingredientsUsed: [_usage(ingredientId: "gone", amount: 100)],
          ),
        ],
      );
      MultiWeekMenu menu = MultiWeekMenu(
        weeks: [
          Menu(
            meals: [_meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipeId: "r1", people: 1)],
          ),
        ],
      );

      MenuPdfDocument document = buildMenuPdfDocument(multiWeekMenu: menu, recipes: [pasta], ingredients: []);

      expect(document.recipes.single.ingredients, const [MenuPdfIngredientLine(ingredientName: "Unknown ingredient", amounts: "100 grams")]);
    });

    test("writes no recipe section for a menu that cooks nothing", () {
      MultiWeekMenu menu = MultiWeekMenu(
        weeks: [
          Menu(
            meals: [_meal(weekDay: WeekDay.saturday, mealType: MealType.breakfast, people: 2)],
          ),
        ],
      );

      MenuPdfDocument document = buildMenuPdfDocument(multiWeekMenu: menu, recipes: [], ingredients: []);

      expect(document.recipes, isEmpty);
      expect(document.weeks.single.days.first.slots, const [
        MenuPdfSlot(
          mealType: MealType.breakfast,
          dishes: [MenuPdfDish(recipeName: "-", people: 2, source: MenuPdfDishSource.empty, servingsToCook: 0)],
        ),
        _emptyLunch,
        _emptyDinner,
      ]);
    });
  });
}
