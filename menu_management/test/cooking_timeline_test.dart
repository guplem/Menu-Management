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
import "package:menu_management/shopping/cooking_timeline.dart";

Recipe _recipe({
  required String id,
  required String name,
  required List<Instruction> instructions,
  int maxStorageDays = 6,
}) {
  return Recipe(id: id, name: name, instructions: instructions, maxStorageDays: maxStorageDays);
}

Instruction _instruction({required String ingredientId, double amount = 100, Unit unit = Unit.grams}) {
  return Instruction(
    id: "instr-$ingredientId",
    description: "Use $ingredientId",
    ingredientsUsed: [IngredientUsage(ingredient: ingredientId, quantity: Quantity(amount: amount, unit: unit))],
  );
}

Meal _meal({required WeekDay weekDay, required MealType mealType, String? recipeId, int yield_ = 1, int people = 2}) {
  return Meal(
    mealTime: MealTime(weekDay: weekDay, mealType: mealType),
    subMeals: [SubMeal(cooking: recipeId != null ? Cooking(recipeId: recipeId, yield: yield_) : null, people: people)],
  );
}

void main() {
  group("buildCookingTimeline", () {
    test("single recipe in single week produces one event", () {
      Recipe recipe = _recipe(id: "r1", name: "Pasta", instructions: [_instruction(ingredientId: "tomato", amount: 150)]);
      MultiWeekMenu menu = MultiWeekMenu(weeks: [
        Menu(meals: [_meal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipeId: "r1")]),
      ]);

      Map<String, List<CookingEvent>> timeline = buildCookingTimeline(multiWeekMenu: menu, recipes: [recipe]);

      expect(timeline.keys, contains("tomato"));
      expect(timeline["tomato"]!.length, 1);
      expect(timeline["tomato"]!.first.dayIndex, 2); // monday = value 2
      // 150g * 2 people = 300g
      expect(timeline["tomato"]!.first.quantities.first.amount, 300);
      expect(timeline["tomato"]!.first.quantities.first.unit, Unit.grams);
    });

    test("storable recipe served at multiple meals produces one event with summed people", () {
      Recipe recipe = _recipe(id: "r1", name: "Stew", instructions: [_instruction(ingredientId: "potato", amount: 200)]);
      // Storable: first occurrence gets yield=3, rest get yield=0
      MultiWeekMenu menu = MultiWeekMenu(weeks: [
        Menu(meals: [
          _meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipeId: "r1", yield_: 3),
          _meal(weekDay: WeekDay.saturday, mealType: MealType.dinner, recipeId: "r1", yield_: 0),
          _meal(weekDay: WeekDay.sunday, mealType: MealType.lunch, recipeId: "r1", yield_: 0),
        ]),
      ]);

      Map<String, List<CookingEvent>> timeline = buildCookingTimeline(multiWeekMenu: menu, recipes: [recipe]);

      expect(timeline["potato"]!.length, 1);
      // 200g * (2+2+2) people = 1200g
      expect(timeline["potato"]!.first.quantities.first.amount, 1200);
      expect(timeline["potato"]!.first.dayIndex, 0); // saturday = 0
    });

    test("non-storable recipe appearing twice in same week produces two events", () {
      Recipe recipe = _recipe(id: "r1", name: "Salad", instructions: [_instruction(ingredientId: "lettuce", amount: 50)], maxStorageDays: 0);
      MultiWeekMenu menu = MultiWeekMenu(weeks: [
        Menu(meals: [
          _meal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipeId: "r1"),
          _meal(weekDay: WeekDay.thursday, mealType: MealType.dinner, recipeId: "r1"),
        ]),
      ]);

      Map<String, List<CookingEvent>> timeline = buildCookingTimeline(multiWeekMenu: menu, recipes: [recipe]);

      expect(timeline["lettuce"]!.length, 2);
      expect(timeline["lettuce"]![0].dayIndex, 2); // monday
      expect(timeline["lettuce"]![1].dayIndex, 5); // thursday
      // Each event: 50g * 2 people = 100g
      expect(timeline["lettuce"]![0].quantities.first.amount, 100);
      expect(timeline["lettuce"]![1].quantities.first.amount, 100);
    });

    test("two recipes using same ingredient on same day are merged", () {
      Recipe r1 = _recipe(id: "r1", name: "Pasta", instructions: [_instruction(ingredientId: "tomato", amount: 150)]);
      Recipe r2 = _recipe(id: "r2", name: "Soup", instructions: [_instruction(ingredientId: "tomato", amount: 80)]);
      MultiWeekMenu menu = MultiWeekMenu(weeks: [
        Menu(meals: [
          _meal(weekDay: WeekDay.tuesday, mealType: MealType.lunch, recipeId: "r1"),
          _meal(weekDay: WeekDay.tuesday, mealType: MealType.dinner, recipeId: "r2"),
        ]),
      ]);

      Map<String, List<CookingEvent>> timeline = buildCookingTimeline(multiWeekMenu: menu, recipes: [r1, r2]);

      expect(timeline["tomato"]!.length, 1); // merged into one event
      // (150*2) + (80*2) = 300 + 160 = 460g
      expect(timeline["tomato"]!.first.quantities.first.amount, 460);
    });

    test("multi-week menu produces events across weeks with correct dayIndex", () {
      Recipe recipe = _recipe(id: "r1", name: "Pasta", instructions: [_instruction(ingredientId: "tomato", amount: 100)]);
      MultiWeekMenu menu = MultiWeekMenu(weeks: [
        Menu(meals: [_meal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipeId: "r1")]),
        Menu(meals: [_meal(weekDay: WeekDay.wednesday, mealType: MealType.lunch, recipeId: "r1")]),
        Menu(meals: [_meal(weekDay: WeekDay.friday, mealType: MealType.lunch, recipeId: "r1")]),
      ]);

      Map<String, List<CookingEvent>> timeline = buildCookingTimeline(multiWeekMenu: menu, recipes: [recipe]);

      expect(timeline["tomato"]!.length, 3);
      expect(timeline["tomato"]![0].dayIndex, 2); // week 0, monday
      expect(timeline["tomato"]![1].dayIndex, 11); // week 1, wednesday (7+4)
      expect(timeline["tomato"]![2].dayIndex, 20); // week 2, friday (14+6)
    });

    test("meals with no cooking or yield=0 are skipped", () {
      Recipe recipe = _recipe(id: "r1", name: "Pasta", instructions: [_instruction(ingredientId: "tomato", amount: 100)]);
      MultiWeekMenu menu = MultiWeekMenu(weeks: [
        Menu(meals: [
          _meal(weekDay: WeekDay.monday, mealType: MealType.lunch, recipeId: null), // no cooking
          _meal(weekDay: WeekDay.tuesday, mealType: MealType.lunch, recipeId: "r1", yield_: 0), // leftover
          _meal(weekDay: WeekDay.wednesday, mealType: MealType.lunch, recipeId: "r1", yield_: 1), // cooking
        ]),
      ]);

      Map<String, List<CookingEvent>> timeline = buildCookingTimeline(multiWeekMenu: menu, recipes: [recipe]);

      expect(timeline["tomato"]!.length, 1);
      expect(timeline["tomato"]!.first.dayIndex, 4); // wednesday
    });

    test("empty menu returns empty timeline", () {
      Map<String, List<CookingEvent>> timeline = buildCookingTimeline(
        multiWeekMenu: const MultiWeekMenu(weeks: []),
        recipes: [],
      );
      expect(timeline, isEmpty);
    });

    test("recipe with multiple instructions sums ingredient quantities", () {
      Recipe recipe = _recipe(
        id: "r1",
        name: "Complex Dish",
        instructions: [
          _instruction(ingredientId: "flour", amount: 100),
          Instruction(
            id: "instr-2",
            description: "Add more flour",
            ingredientsUsed: [IngredientUsage(ingredient: "flour", quantity: const Quantity(amount: 50, unit: Unit.grams))],
          ),
        ],
      );
      MultiWeekMenu menu = MultiWeekMenu(weeks: [
        Menu(meals: [_meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipeId: "r1")]),
      ]);

      Map<String, List<CookingEvent>> timeline = buildCookingTimeline(multiWeekMenu: menu, recipes: [recipe]);

      expect(timeline["flour"]!.length, 1);
      // (100 + 50) * 2 people = 300g
      expect(timeline["flour"]!.first.quantities.first.amount, 300);
    });

    test("storable recipe with two cook events in one week produces two separate events", () {
      // maxStorageDays: 1 means Saturday cook covers Sat+Sun only, Thursday is a new cook
      Recipe recipe = _recipe(
        id: "r1",
        name: "Stew",
        instructions: [_instruction(ingredientId: "potato", amount: 100)],
        maxStorageDays: 1,
      );
      MultiWeekMenu menu = MultiWeekMenu(weeks: [
        Menu(meals: [
          // Saturday cook (yield=2: covers Sat + Sun)
          _meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipeId: "r1", yield_: 2, people: 2),
          // Sunday leftover (yield=0)
          _meal(weekDay: WeekDay.sunday, mealType: MealType.lunch, recipeId: "r1", yield_: 0, people: 3),
          // Thursday cook (yield=1: new cook event, outside Saturday's window)
          _meal(weekDay: WeekDay.thursday, mealType: MealType.lunch, recipeId: "r1", yield_: 1, people: 4),
        ]),
      ]);

      Map<String, List<CookingEvent>> timeline = buildCookingTimeline(multiWeekMenu: menu, recipes: [recipe]);

      // Should produce TWO events: Saturday (2+3 people) and Thursday (4 people)
      expect(timeline["potato"]!.length, 2);
      expect(timeline["potato"]![0].dayIndex, 0); // saturday
      expect(timeline["potato"]![0].quantities.first.amount, 500); // 100 * (2+3)
      expect(timeline["potato"]![1].dayIndex, 5); // thursday
      expect(timeline["potato"]![1].quantities.first.amount, 400); // 100 * 4
    });

    test("ingredient used in different units preserves both quantities", () {
      Recipe recipe = _recipe(
        id: "r1",
        name: "Dish",
        instructions: [
          _instruction(ingredientId: "tomato", amount: 100, unit: Unit.grams),
          Instruction(
            id: "instr-cl",
            description: "Add tomato sauce",
            ingredientsUsed: [IngredientUsage(ingredient: "tomato", quantity: const Quantity(amount: 2, unit: Unit.centiliters))],
          ),
        ],
      );
      MultiWeekMenu menu = MultiWeekMenu(weeks: [
        Menu(meals: [_meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, recipeId: "r1")]),
      ]);

      Map<String, List<CookingEvent>> timeline = buildCookingTimeline(multiWeekMenu: menu, recipes: [recipe]);

      expect(timeline["tomato"]!.length, 1);
      List<Quantity> quantities = timeline["tomato"]!.first.quantities;
      expect(quantities.length, 2);
      Quantity gramsQ = quantities.firstWhere((q) => q.unit == Unit.grams);
      Quantity clQ = quantities.firstWhere((q) => q.unit == Unit.centiliters);
      expect(gramsQ.amount, 200); // 100 * 2 people
      expect(clQ.amount, 4); // 2 * 2 people
    });
  });
}
