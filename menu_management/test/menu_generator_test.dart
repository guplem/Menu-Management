import "package:flutter_test/flutter_test.dart";
import "package:menu_management/ingredients/ingredients_provider.dart";
import "package:menu_management/menu/enums/meal_type.dart";
import "package:menu_management/menu/enums/week_day.dart";
import "package:menu_management/menu/menu_generator.dart";
import "package:menu_management/menu/models/meal.dart";
import "package:menu_management/menu/models/meal_time.dart";
import "package:menu_management/menu/models/menu.dart";
import "package:menu_management/menu/models/menu_configuration.dart";
import "package:menu_management/recipes/enums/recipe_type.dart";
import "package:menu_management/recipes/models/instruction.dart";
import "package:menu_management/recipes/models/recipe.dart";
import "package:menu_management/recipes/recipes_provider.dart";

// ── Test recipe builders ──

Recipe _breakfast({required String id, required String name, int totalMinutes = 10, bool canBeStored = false}) {
  return Recipe(
    id: id,
    name: name,
    type: RecipeType.breakfast,
    lunch: false,
    dinner: false,
    canBeStored: canBeStored,
    instructions: totalMinutes > 0
        ? [Instruction(id: "${id}_i", description: "make $name", workingTimeMinutes: totalMinutes, cookingTimeMinutes: 0)]
        : [],
  );
}

Recipe _meal({
  required String id,
  required String name,
  int totalMinutes = 20,
  bool canBeStored = true,
  bool lunch = true,
  bool dinner = true,
  bool carbs = true,
  bool proteins = false,
  bool vegetables = false,
}) {
  return Recipe(
    id: id,
    name: name,
    type: RecipeType.meal,
    lunch: lunch,
    dinner: dinner,
    canBeStored: canBeStored,
    carbs: carbs,
    proteins: proteins,
    vegetables: vegetables,
    instructions: totalMinutes > 0
        ? [Instruction(id: "${id}_i", description: "cook $name", workingTimeMinutes: totalMinutes, cookingTimeMinutes: 0)]
        : [],
  );
}

// ── Helpers ──

List<MenuConfiguration> _fullWeekConfigurations({int cookingTimeMinutes = 60}) {
  List<MenuConfiguration> configs = [];
  for (WeekDay day in WeekDay.values) {
    for (MealType meal in MealType.values) {
      configs.add(
        MenuConfiguration(
          mealTime: MealTime(weekDay: day, mealType: meal),
          requiresMeal: true,
          availableCookingTimeMinutes: cookingTimeMinutes,
        ),
      );
    }
  }
  return configs;
}

List<MenuConfiguration> _lunchDinnerOnlyConfigurations({int cookingTimeMinutes = 60}) {
  List<MenuConfiguration> configs = [];
  for (WeekDay day in WeekDay.values) {
    for (MealType meal in [MealType.lunch, MealType.dinner]) {
      configs.add(
        MenuConfiguration(
          mealTime: MealTime(weekDay: day, mealType: meal),
          requiresMeal: true,
          availableCookingTimeMinutes: cookingTimeMinutes,
        ),
      );
    }
    // Breakfast not required
    configs.add(
      MenuConfiguration(
        mealTime: MealTime(weekDay: day, mealType: MealType.breakfast),
        requiresMeal: false,
      ),
    );
  }
  return configs;
}

void main() {
  setUp(() {
    IngredientsProvider.instance.setData([]);
    RecipesProvider.instance.setData([], ingredients: []);
    // Always provide at least one breakfast recipe to avoid Debug.logWarning assertion
    RecipesProvider.addOrUpdate(
      newRecipe: _breakfast(id: "b_default", name: "Default Breakfast"),
    );
  });

  group("MenuGenerator structural properties", () {
    test("generates a meal for every configuration slot", () {
      // Provide enough recipes to fill all slots
      for (int i = 0; i < 10; i++) {
        RecipesProvider.addOrUpdate(
          newRecipe: _breakfast(id: "b$i", name: "Breakfast $i"),
        );
      }
      for (int i = 0; i < 20; i++) {
        RecipesProvider.addOrUpdate(
          newRecipe: _meal(id: "m$i", name: "Meal $i"),
        );
      }

      List<MenuConfiguration> configs = _fullWeekConfigurations();
      MenuGenerator generator = MenuGenerator(baseSeed: 42);
      generator.generate(configurations: configs, recipes: RecipesProvider.instance.recipes);
      Menu menu = generator.menu!;

      // All 21 slots (one per config) should produce a Meal object
      expect(menu.meals.length, configs.length);
    });

    test("disabled slots produce meals with null cooking", () {
      RecipesProvider.addOrUpdate(
        newRecipe: _meal(id: "m1", name: "Pasta"),
      );

      List<MenuConfiguration> configs = _lunchDinnerOnlyConfigurations();
      MenuGenerator generator = MenuGenerator(baseSeed: 42);
      generator.generate(configurations: configs, recipes: RecipesProvider.instance.recipes);
      Menu menu = generator.menu!;

      // All 21 slots (7 days x 3 meal types) should be present
      expect(menu.meals.length, configs.length);

      // Disabled breakfast slots should exist but have null cooking
      List<Meal> breakfastMeals = menu.meals.where((m) => m.mealTime.mealType == MealType.breakfast).toList();
      expect(breakfastMeals.length, 7);
      expect(breakfastMeals.every((m) => m.cooking == null), true);
    });

    test("only assigns breakfast recipes to breakfast slots", () {
      for (int i = 0; i < 10; i++) {
        RecipesProvider.addOrUpdate(
          newRecipe: _breakfast(id: "b$i", name: "Breakfast $i"),
        );
      }
      for (int i = 0; i < 15; i++) {
        RecipesProvider.addOrUpdate(
          newRecipe: _meal(id: "m$i", name: "Meal $i"),
        );
      }

      List<MenuConfiguration> configs = _fullWeekConfigurations();
      MenuGenerator generator = MenuGenerator(baseSeed: 42);
      generator.generate(configurations: configs, recipes: RecipesProvider.instance.recipes);
      Menu menu = generator.menu!;

      for (Meal meal in menu.meals) {
        if (meal.mealTime.mealType == MealType.breakfast && meal.cooking != null) {
          expect(
            RecipesProvider.instance.get(meal.cooking!.recipeId).type,
            RecipeType.breakfast,
            reason: "Breakfast slot at ${meal.mealTime.weekDay} should have a breakfast recipe",
          );
        }
        if ((meal.mealTime.mealType == MealType.lunch || meal.mealTime.mealType == MealType.dinner) && meal.cooking != null) {
          expect(
            RecipesProvider.instance.get(meal.cooking!.recipeId).type,
            RecipeType.meal,
            reason: "Lunch/dinner slot at ${meal.mealTime.weekDay} ${meal.mealTime.mealType} should have a meal recipe",
          );
        }
      }
    });

    test("same seed produces same menu", () {
      for (int i = 0; i < 10; i++) {
        RecipesProvider.addOrUpdate(
          newRecipe: _breakfast(id: "b$i", name: "Breakfast $i"),
        );
        RecipesProvider.addOrUpdate(
          newRecipe: _meal(id: "m$i", name: "Meal $i"),
        );
      }

      List<MenuConfiguration> configs = _fullWeekConfigurations();

      MenuGenerator gen1 = MenuGenerator(baseSeed: 99);
      gen1.generate(configurations: configs, recipes: RecipesProvider.instance.recipes);

      MenuGenerator gen2 = MenuGenerator(baseSeed: 99);
      gen2.generate(configurations: configs, recipes: RecipesProvider.instance.recipes);

      for (int i = 0; i < gen1.menu!.meals.length; i++) {
        expect(
          gen1.menu!.meals[i].cooking?.recipeId,
          gen2.menu!.meals[i].cooking?.recipeId,
          reason: "Slot $i should have the same recipe for the same seed",
        );
      }
    });

    test("different seeds produce different menus (with enough recipe variety)", () {
      for (int i = 0; i < 15; i++) {
        RecipesProvider.addOrUpdate(
          newRecipe: _breakfast(id: "b$i", name: "Breakfast $i"),
        );
        RecipesProvider.addOrUpdate(
          newRecipe: _meal(id: "m$i", name: "Meal $i"),
        );
      }

      List<MenuConfiguration> configs = _fullWeekConfigurations();

      MenuGenerator gen1 = MenuGenerator(baseSeed: 1);
      gen1.generate(configurations: configs, recipes: RecipesProvider.instance.recipes);

      MenuGenerator gen2 = MenuGenerator(baseSeed: 9999);
      gen2.generate(configurations: configs, recipes: RecipesProvider.instance.recipes);

      // At least one slot should differ
      bool anyDifference = false;
      for (int i = 0; i < gen1.menu!.meals.length; i++) {
        if (gen1.menu!.meals[i].cooking?.recipeId != gen2.menu!.meals[i].cooking?.recipeId) {
          anyDifference = true;
          break;
        }
      }
      expect(anyDifference, true);
    });
  });

  group("MenuGenerator yield logic", () {
    test("storable recipe reused across slots gets yield on first occurrence only", () {
      Recipe storableRecipe = _meal(id: "m1", name: "Storable Pasta", canBeStored: true);
      RecipesProvider.addOrUpdate(newRecipe: storableRecipe);

      // Only 2 lunch slots with time, so the one storable recipe fills both
      List<MenuConfiguration> configs = [
        const MenuConfiguration(
          mealTime: MealTime(weekDay: WeekDay.saturday, mealType: MealType.lunch),
          requiresMeal: true,
          availableCookingTimeMinutes: 60,
        ),
        const MenuConfiguration(
          mealTime: MealTime(weekDay: WeekDay.sunday, mealType: MealType.lunch),
          requiresMeal: true,
          availableCookingTimeMinutes: 60,
        ),
      ];

      MenuGenerator generator = MenuGenerator(baseSeed: 42);
      generator.generate(configurations: configs, recipes: RecipesProvider.instance.recipes);
      Menu menu = generator.menu!;

      // Both slots should have the same recipe
      expect(menu.meals[0].cooking?.recipeId, "m1");
      expect(menu.meals[1].cooking?.recipeId, "m1");

      // First occurrence has yield = total count, rest have yield = 0
      List<Meal> sorted = [...menu.meals]..sort((a, b) => a.goesBefore(b) ? -1 : 1);
      Meal first = sorted.firstWhere((m) => m.cooking?.yield != null && m.cooking!.yield > 0);
      expect(first.cooking!.yield, 2);

      int zeroYieldCount = menu.meals.where((m) => m.cooking?.yield == 0).length;
      expect(zeroYieldCount, 1);
    });
  });

  group("MenuGenerator zero-time slot backfilling", () {
    test("zero cooking time slot gets filled by a storable recipe from an earlier slot", () {
      Recipe storableRecipe = _meal(id: "m1", name: "Storable Stew", canBeStored: true, totalMinutes: 30);
      RecipesProvider.addOrUpdate(newRecipe: storableRecipe);

      List<MenuConfiguration> configs = [
        const MenuConfiguration(
          mealTime: MealTime(weekDay: WeekDay.saturday, mealType: MealType.lunch),
          requiresMeal: true,
          availableCookingTimeMinutes: 60, // Can cook here
        ),
        const MenuConfiguration(
          mealTime: MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch),
          requiresMeal: true,
          availableCookingTimeMinutes: 0, // Cannot cook here, needs leftovers
        ),
      ];

      MenuGenerator generator = MenuGenerator(baseSeed: 42);
      generator.generate(configurations: configs, recipes: RecipesProvider.instance.recipes);
      Menu menu = generator.menu!;

      // Both slots should be filled (the zero-time slot from leftovers)
      expect(menu.meals.length, 2);
      bool allFilled = menu.meals.every((m) => m.cooking != null);
      expect(allFilled, true, reason: "Zero-time slot should be filled via storable recipe from earlier slot");
    });
  });

  group("MenuGenerator getPreviousMomentConfigurations", () {
    test("returns configurations that come before the target", () {
      MenuGenerator generator = MenuGenerator(baseSeed: 1);

      MenuConfiguration satLunch = const MenuConfiguration(
        mealTime: MealTime(weekDay: WeekDay.saturday, mealType: MealType.lunch),
      );
      MenuConfiguration satDinner = const MenuConfiguration(
        mealTime: MealTime(weekDay: WeekDay.saturday, mealType: MealType.dinner),
      );
      MenuConfiguration sunLunch = const MenuConfiguration(
        mealTime: MealTime(weekDay: WeekDay.sunday, mealType: MealType.lunch),
      );

      List<MenuConfiguration> previous = generator.getPreviousMomentConfigurations(
        previousThan: sunLunch,
        possibleConfigurations: [satLunch, satDinner],
      );

      expect(previous.length, 2);
      expect(previous.any((c) => c.mealTime.weekDay == WeekDay.saturday && c.mealTime.mealType == MealType.lunch), true);
      expect(previous.any((c) => c.mealTime.weekDay == WeekDay.saturday && c.mealTime.mealType == MealType.dinner), true);
    });

    test("returns empty when target is the earliest", () {
      MenuGenerator generator = MenuGenerator(baseSeed: 1);

      MenuConfiguration satBreakfast = const MenuConfiguration(
        mealTime: MealTime(weekDay: WeekDay.saturday, mealType: MealType.breakfast),
      );
      MenuConfiguration sunLunch = const MenuConfiguration(
        mealTime: MealTime(weekDay: WeekDay.sunday, mealType: MealType.lunch),
      );

      List<MenuConfiguration> previous = generator.getPreviousMomentConfigurations(previousThan: satBreakfast, possibleConfigurations: [sunLunch]);

      expect(previous, isEmpty);
    });
  });

  group("MenuGenerator empty recipe pool", () {
    test("generates menu with null cooking when no meal recipe fits the configuration", () {
      // Add a meal recipe that requires more time than the config allows
      RecipesProvider.addOrUpdate(
        newRecipe: _meal(id: "m_slow", name: "Slow Braise", totalMinutes: 120, canBeStored: false),
      );

      List<MenuConfiguration> configs = [
        const MenuConfiguration(
          mealTime: MealTime(weekDay: WeekDay.saturday, mealType: MealType.lunch),
          requiresMeal: true,
          availableCookingTimeMinutes: 0, // Cannot cook at the spot
        ),
      ];

      MenuGenerator generator = MenuGenerator(baseSeed: 42);
      generator.generate(configurations: configs, recipes: RecipesProvider.instance.recipes);
      Menu menu = generator.menu!;

      expect(menu.meals.length, 1);
      expect(menu.meals.first.cooking, null, reason: "No fitting recipe, cooking should be null");
    });

    test("disabled-only configurations produce meals with null cooking", () {
      RecipesProvider.addOrUpdate(
        newRecipe: _meal(id: "m1", name: "Pasta"),
      );

      List<MenuConfiguration> configs = [
        const MenuConfiguration(
          mealTime: MealTime(weekDay: WeekDay.saturday, mealType: MealType.lunch),
          requiresMeal: false,
        ),
      ];

      MenuGenerator generator = MenuGenerator(baseSeed: 42);
      generator.generate(configurations: configs, recipes: RecipesProvider.instance.recipes);
      Menu menu = generator.menu!;

      expect(menu.meals.length, 1);
      expect(menu.meals.first.cooking, isNull);
    });
  });
}
