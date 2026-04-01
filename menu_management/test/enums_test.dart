import "package:flutter_test/flutter_test.dart";
import "package:menu_management/menu/enums/meal_type.dart";
import "package:menu_management/menu/enums/week_day.dart";
import "package:menu_management/recipes/enums/recipe_type.dart";
import "package:menu_management/recipes/enums/unit.dart";

void main() {
  group("WeekDay", () {
    test("has 7 values starting from saturday", () {
      expect(WeekDay.values.length, 7);
      expect(WeekDay.saturday.value, 0);
      expect(WeekDay.friday.value, 6);
    });

    test("fromValue returns correct day", () {
      expect(WeekDay.fromValue(0), WeekDay.saturday);
      expect(WeekDay.fromValue(1), WeekDay.sunday);
      expect(WeekDay.fromValue(2), WeekDay.monday);
      expect(WeekDay.fromValue(3), WeekDay.tuesday);
      expect(WeekDay.fromValue(4), WeekDay.wednesday);
      expect(WeekDay.fromValue(5), WeekDay.thursday);
      expect(WeekDay.fromValue(6), WeekDay.friday);
    });

    test("fromValue throws on invalid value", () {
      expect(() => WeekDay.fromValue(7), throwsStateError);
      expect(() => WeekDay.fromValue(-1), throwsStateError);
    });

    test("goesBefore compares by value", () {
      expect(WeekDay.saturday.goesBefore(WeekDay.sunday), true);
      expect(WeekDay.friday.goesBefore(WeekDay.saturday), false);
      expect(WeekDay.monday.goesBefore(WeekDay.monday), false);
    });

    test("goesAfter compares by value", () {
      expect(WeekDay.sunday.goesAfter(WeekDay.saturday), true);
      expect(WeekDay.saturday.goesAfter(WeekDay.sunday), false);
      expect(WeekDay.monday.goesAfter(WeekDay.monday), false);
    });
  });

  group("MealType", () {
    test("has 3 values", () {
      expect(MealType.values.length, 3);
      expect(MealType.breakfast.value, 0);
      expect(MealType.lunch.value, 1);
      expect(MealType.dinner.value, 2);
    });

    test("fromValue returns correct type", () {
      expect(MealType.fromValue(0), MealType.breakfast);
      expect(MealType.fromValue(1), MealType.lunch);
      expect(MealType.fromValue(2), MealType.dinner);
    });

    test("fromValue throws on invalid value", () {
      expect(() => MealType.fromValue(3), throwsStateError);
    });

    test("goesBefore compares by value", () {
      expect(MealType.breakfast.goesBefore(MealType.lunch), true);
      expect(MealType.lunch.goesBefore(MealType.dinner), true);
      expect(MealType.dinner.goesBefore(MealType.breakfast), false);
      expect(MealType.lunch.goesBefore(MealType.lunch), false);
    });

    test("goesAfter compares by value", () {
      expect(MealType.dinner.goesAfter(MealType.lunch), true);
      expect(MealType.lunch.goesAfter(MealType.breakfast), true);
      expect(MealType.breakfast.goesAfter(MealType.lunch), false);
      expect(MealType.dinner.goesAfter(MealType.dinner), false);
    });
  });

  group("RecipeType", () {
    test("has 4 values with expected integer codes", () {
      expect(RecipeType.breakfast.value, 0);
      expect(RecipeType.meal.value, 1);
      expect(RecipeType.snack.value, 3);
      expect(RecipeType.dessert.value, 4);
    });

    test("fromValue returns correct type", () {
      expect(RecipeType.fromValue(0), RecipeType.breakfast);
      expect(RecipeType.fromValue(1), RecipeType.meal);
      expect(RecipeType.fromValue(3), RecipeType.snack);
      expect(RecipeType.fromValue(4), RecipeType.dessert);
    });

    test("fromValue throws on invalid/skipped value", () {
      expect(() => RecipeType.fromValue(2), throwsStateError);
      expect(() => RecipeType.fromValue(5), throwsStateError);
    });
  });

  group("Unit", () {
    test("has 5 values", () {
      expect(Unit.grams.value, 0);
      expect(Unit.centiliters.value, 1);
      expect(Unit.pieces.value, 2);
      expect(Unit.tablespoons.value, 3);
      expect(Unit.teaspoons.value, 4);
    });

    test("fromValue returns correct unit", () {
      expect(Unit.fromValue(0), Unit.grams);
      expect(Unit.fromValue(1), Unit.centiliters);
      expect(Unit.fromValue(2), Unit.pieces);
      expect(Unit.fromValue(3), Unit.tablespoons);
      expect(Unit.fromValue(4), Unit.teaspoons);
    });

    test("fromValue throws on invalid value", () {
      expect(() => Unit.fromValue(5), throwsStateError);
    });
  });
}
