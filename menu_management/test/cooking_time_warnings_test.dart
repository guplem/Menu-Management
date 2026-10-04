import "package:flutter_test/flutter_test.dart";
import "package:menu_management/menu/cooking_time_warnings.dart";
import "package:menu_management/menu/enums/meal_type.dart";
import "package:menu_management/menu/enums/week_day.dart";
import "package:menu_management/menu/models/cooking.dart";
import "package:menu_management/menu/models/meal_time.dart";
import "package:menu_management/menu/models/menu_configuration.dart";
import "package:menu_management/menu/models/sub_meal.dart";
import "package:menu_management/recipes/models/instruction.dart";
import "package:menu_management/recipes/models/recipe.dart";

/// A recipe with one step of [workingTimeMinutes] of work and [cookingTimeMinutes] of cooking.
Recipe _recipe({required String id, int workingTimeMinutes = 20, int cookingTimeMinutes = 10}) {
  return Recipe(
    id: id,
    name: "Recipe $id",
    instructions: [Instruction(id: "$id-step", description: "step", workingTimeMinutes: workingTimeMinutes, cookingTimeMinutes: cookingTimeMinutes)],
  );
}

MenuConfiguration _configuration({required int availableCookingTimeMinutes}) {
  return MenuConfiguration(
    mealTime: const MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch),
    availableCookingTimeMinutes: availableCookingTimeMinutes,
  );
}

SubMeal _subMeal({String recipeId = "r1", int yield_ = 1}) {
  return SubMeal(
    cooking: Cooking(recipeId: recipeId, yield: yield_),
    people: 2,
  );
}

void main() {
  group("cookingTimeWarningForSubMeal", () {
    test("warns when the recipe needs more time than the meal has", () {
      Recipe recipe = _recipe(id: "r1", workingTimeMinutes: 20, cookingTimeMinutes: 10);
      CookingTimeWarning? warning = cookingTimeWarningForSubMeal(
        subMeal: _subMeal(),
        configuration: _configuration(availableCookingTimeMinutes: 25),
        recipes: [recipe],
      );
      expect(warning, isNotNull);
      expect(warning!.recipe, recipe);
      expect(warning.requiredMinutes, 30);
      expect(warning.availableMinutes, 25);
    });

    test("does not warn when the recipe needs exactly the time that the meal has", () {
      CookingTimeWarning? warning = cookingTimeWarningForSubMeal(
        subMeal: _subMeal(),
        configuration: _configuration(availableCookingTimeMinutes: 30),
        recipes: [_recipe(id: "r1", workingTimeMinutes: 20, cookingTimeMinutes: 10)],
      );
      expect(warning, isNull);
    });

    test("does not warn for leftovers, because nobody cooks at that meal", () {
      CookingTimeWarning? warning = cookingTimeWarningForSubMeal(
        subMeal: _subMeal(yield_: 0),
        configuration: _configuration(availableCookingTimeMinutes: 0),
        recipes: [_recipe(id: "r1")],
      );
      expect(warning, isNull);
    });

    test("does not warn for an empty sub-meal", () {
      CookingTimeWarning? warning = cookingTimeWarningForSubMeal(
        subMeal: const SubMeal(people: 2),
        configuration: _configuration(availableCookingTimeMinutes: 0),
        recipes: [_recipe(id: "r1")],
      );
      expect(warning, isNull);
    });

    test("does not warn when the recipe is unknown", () {
      CookingTimeWarning? warning = cookingTimeWarningForSubMeal(
        subMeal: _subMeal(recipeId: "missing"),
        configuration: _configuration(availableCookingTimeMinutes: 0),
        recipes: [_recipe(id: "r1")],
      );
      expect(warning, isNull);
    });

    test("does not warn for a recipe with no time when the meal has no time", () {
      CookingTimeWarning? warning = cookingTimeWarningForSubMeal(
        subMeal: _subMeal(),
        configuration: _configuration(availableCookingTimeMinutes: 0),
        recipes: [_recipe(id: "r1", workingTimeMinutes: 0, cookingTimeMinutes: 0)],
      );
      expect(warning, isNull);
    });
  });

  group("cookingTimeWarningMessage", () {
    test("names the time that the recipe needs and the time that the meal has", () {
      CookingTimeWarning warning = CookingTimeWarning(
        recipe: _recipe(id: "r1", workingTimeMinutes: 20, cookingTimeMinutes: 25),
        availableMinutes: 30,
      );
      expect(cookingTimeWarningMessage(warning), "Not enough time to cook this dish.\nIt needs 45 min, but this meal has only 30 min.");
    });

    test("says that the meal has no time to cook", () {
      CookingTimeWarning warning = CookingTimeWarning(recipe: _recipe(id: "r1", workingTimeMinutes: 20, cookingTimeMinutes: 25), availableMinutes: 0);
      expect(cookingTimeWarningMessage(warning), "Not enough time to cook this dish.\nIt needs 45 min, but this meal has no time to cook.");
    });
  });
}
