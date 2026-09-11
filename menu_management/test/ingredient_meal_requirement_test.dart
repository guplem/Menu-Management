import "package:flutter_test/flutter_test.dart";
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
import "package:menu_management/shopping/ingredient_meal_requirement.dart";

/// A recipe that uses 100 grams of rice for one serving.
Recipe _riceRecipe({String id = "r1", String name = "Rice bowl", int maxStorageDays = 6}) {
  return Recipe(
    id: id,
    name: name,
    maxStorageDays: maxStorageDays,
    instructions: const [
      Instruction(
        id: "i1",
        description: "cook the rice",
        ingredientsUsed: [
          IngredientUsage(
            ingredient: "rice",
            quantity: Quantity(amount: 100, unit: Unit.grams),
          ),
        ],
      ),
    ],
  );
}

Meal _meal({required WeekDay weekDay, required MealType mealType, required String recipeId, required int yield, int people = 2}) {
  return Meal(
    mealTime: MealTime(weekDay: weekDay, mealType: mealType),
    subMeals: [
      SubMeal(
        cooking: Cooking(recipeId: recipeId, yield: yield),
        people: people,
      ),
    ],
  );
}

void main() {
  group("Menu.ingredientMealRequirements", () {
    test("records the week, the day, the meal slot and the recipe of every meal that needs the ingredient", () {
      Recipe recipe = _riceRecipe();
      Menu menu = Menu(
        meals: [_meal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipeId: recipe.id, yield: 1, people: 3)],
      );

      Map<String, List<IngredientMealRequirement>> requirements = menu.ingredientMealRequirements(recipes: [recipe], weekIndex: 2);

      expect(requirements.keys, ["rice"]);
      IngredientMealRequirement requirement = requirements["rice"]!.single;
      expect(requirement.weekIndex, 2);
      expect(requirement.mealTime, const MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch));
      expect(requirement.subMealIndex, 0);
      expect(requirement.recipeId, "r1");
      expect(requirement.recipeName, "Rice bowl");
      expect(requirement.people, 3);
      expect(requirement.isCookEvent, isTrue);
      expect(requirement.quantities, const [Quantity(amount: 300, unit: Unit.grams)]);
    });

    test("keeps one entry per meal instead of one entry per recipe", () {
      // IngredientSource dedups by recipe, so it cannot say which day needs the ingredient.
      Recipe recipe = _riceRecipe();
      Menu menu = Menu(
        meals: [
          _meal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipeId: recipe.id, yield: 2, people: 2),
          _meal(weekDay: WeekDay.tuesday, mealType: MealType.dinner, recipeId: recipe.id, yield: 0, people: 2),
        ],
      );

      List<IngredientMealRequirement> requirements = menu.ingredientMealRequirements(recipes: [recipe])["rice"]!;

      expect(requirements.length, 2);
      expect(requirements.map((IngredientMealRequirement r) => r.mealTime.weekDay), [WeekDay.monday, WeekDay.tuesday]);
      expect(requirements.map((IngredientMealRequirement r) => r.mealTime.mealType), [MealType.lunch, MealType.dinner]);
    });

    test("marks the meal that eats leftovers as not a cook event", () {
      Recipe recipe = _riceRecipe();
      Menu menu = Menu(
        meals: [
          _meal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipeId: recipe.id, yield: 2, people: 2),
          _meal(weekDay: WeekDay.tuesday, mealType: MealType.dinner, recipeId: recipe.id, yield: 0, people: 2),
        ],
      );

      List<IngredientMealRequirement> requirements = menu.ingredientMealRequirements(recipes: [recipe])["rice"]!;

      expect(requirements.first.isCookEvent, isTrue);
      expect(requirements.last.isCookEvent, isFalse);
    });

    test("lists the meals in chronological order", () {
      Recipe recipe = _riceRecipe();
      Menu menu = Menu(
        meals: [
          _meal(weekDay: WeekDay.tuesday, mealType: MealType.dinner, recipeId: recipe.id, yield: 0, people: 2),
          _meal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipeId: recipe.id, yield: 2, people: 2),
        ],
      );

      List<IngredientMealRequirement> requirements = menu.ingredientMealRequirements(recipes: [recipe])["rice"]!;

      expect(requirements.first.mealTime.weekDay, WeekDay.monday);
      expect(requirements.last.mealTime.weekDay, WeekDay.tuesday);
    });

    test("sums to the same total as allIngredients", () {
      // The per-meal breakdown justifies the shopping total, so it must never disagree with it.
      Recipe recipe = _riceRecipe();
      Menu menu = Menu(
        meals: [
          _meal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipeId: recipe.id, yield: 2, people: 2),
          _meal(weekDay: WeekDay.tuesday, mealType: MealType.dinner, recipeId: recipe.id, yield: 0, people: 3),
        ],
      );

      double total = menu
          .ingredientMealRequirements(recipes: [recipe])["rice"]!
          .expand((IngredientMealRequirement r) => r.quantities)
          .fold(0.0, (double sum, Quantity q) => sum + q.amount);

      expect(total, menu.allIngredients(recipes: [recipe])["rice"]!.single.amount);
    });

    test("ignores a meal whose recipe is unknown", () {
      Menu menu = Menu(
        meals: [_meal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipeId: "missing", yield: 1)],
      );

      expect(menu.ingredientMealRequirements(recipes: []), isEmpty);
    });
  });

  group("MultiWeekMenu.ingredientMealRequirements", () {
    test("tags each entry with the week that needs the ingredient", () {
      Recipe recipe = _riceRecipe();
      Menu week = Menu(
        meals: [_meal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipeId: recipe.id, yield: 1, people: 2)],
      );
      MultiWeekMenu multiWeek = MultiWeekMenu(weeks: [week, week]);

      List<IngredientMealRequirement> requirements = multiWeek.ingredientMealRequirements(recipes: [recipe])["rice"]!;

      expect(requirements.length, 2);
      expect(requirements.map((IngredientMealRequirement r) => r.weekIndex), [0, 1]);
    });

    test("returns nothing for a menu without meals", () {
      MultiWeekMenu multiWeek = MultiWeekMenu(weeks: [const Menu(), const Menu()]);

      expect(multiWeek.ingredientMealRequirements(recipes: []), isEmpty);
    });
  });
}
