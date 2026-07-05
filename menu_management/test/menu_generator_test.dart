import "package:flutter_test/flutter_test.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/ingredients/ingredients_provider.dart";
import "package:menu_management/menu/enums/meal_type.dart";
import "package:menu_management/menu/enums/week_day.dart";
import "package:menu_management/menu/menu_generator.dart";
import "package:menu_management/menu/models/meal.dart";
import "package:menu_management/menu/models/meal_time.dart";
import "package:menu_management/menu/models/menu.dart";
import "package:menu_management/menu/models/menu_configuration.dart";
import "package:menu_management/menu/models/sub_meal.dart";
import "package:menu_management/recipes/enums/recipe_type.dart";
import "package:menu_management/recipes/models/instruction.dart";
import "package:menu_management/recipes/models/recipe.dart";
import "package:menu_management/recipes/recipes_provider.dart";

// ── Test recipe builders ──

Recipe _breakfast({required String id, required String name, int totalMinutes = 10, int maxStorageDays = 0}) {
  return Recipe(
    id: id,
    name: name,
    type: RecipeType.breakfast,
    lunch: false,
    dinner: false,
    maxStorageDays: maxStorageDays,
    instructions: totalMinutes > 0
        ? [Instruction(id: "${id}_i", description: "make $name", workingTimeMinutes: totalMinutes, cookingTimeMinutes: 0)]
        : [],
  );
}

Recipe _meal({
  required String id,
  required String name,
  int totalMinutes = 20,
  int maxStorageDays = 6,
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
    maxStorageDays: maxStorageDays,
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

      // Disabled breakfast slots should exist but have empty subMeals
      List<Meal> breakfastMeals = menu.meals.where((m) => m.mealTime.mealType == MealType.breakfast).toList();
      expect(breakfastMeals.length, 7);
      expect(breakfastMeals.every((m) => m.subMeals.isEmpty), true);
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
        if (meal.mealTime.mealType == MealType.breakfast && meal.subMeals.any((sm) => sm.cooking != null)) {
          expect(
            RecipesProvider.instance.get(meal.subMeals.first.cooking!.recipeId).type,
            RecipeType.breakfast,
            reason: "Breakfast slot at ${meal.mealTime.weekDay} should have a breakfast recipe",
          );
        }
        if ((meal.mealTime.mealType == MealType.lunch || meal.mealTime.mealType == MealType.dinner) && meal.subMeals.any((sm) => sm.cooking != null)) {
          expect(
            RecipesProvider.instance.get(meal.subMeals.first.cooking!.recipeId).type,
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
          gen1.menu!.meals[i].subMeals.firstOrNull?.cooking?.recipeId,
          gen2.menu!.meals[i].subMeals.firstOrNull?.cooking?.recipeId,
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
        if (gen1.menu!.meals[i].subMeals.firstOrNull?.cooking?.recipeId != gen2.menu!.meals[i].subMeals.firstOrNull?.cooking?.recipeId) {
          anyDifference = true;
          break;
        }
      }
      expect(anyDifference, true);
    });
  });

  group("MenuGenerator yield logic", () {
    test("storable recipe reused across slots gets yield on first occurrence only", () {
      Recipe storableRecipe = _meal(id: "m1", name: "Storable Pasta", maxStorageDays: 6);
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
      expect(menu.meals[0].subMeals.firstOrNull?.cooking?.recipeId, "m1");
      expect(menu.meals[1].subMeals.firstOrNull?.cooking?.recipeId, "m1");

      // First occurrence has yield = total count, rest have yield = 0
      List<Meal> sorted = [...menu.meals]..sort((a, b) => a.goesBefore(b) ? -1 : 1);
      Meal first = sorted.firstWhere((m) => m.subMeals.firstOrNull?.cooking?.yield != null && m.subMeals.first.cooking!.yield > 0);
      expect(first.subMeals.first.cooking!.yield, 2);

      int zeroYieldCount = menu.meals.where((m) => m.subMeals.firstOrNull?.cooking?.yield == 0).length;
      expect(zeroYieldCount, 1);
    });
  });

  group("MenuGenerator zero-time slot backfilling", () {
    test("zero cooking time slot gets filled by a storable recipe from an earlier slot", () {
      Recipe storableRecipe = _meal(id: "m1", name: "Storable Stew", maxStorageDays: 6, totalMinutes: 30);
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
      bool allFilled = menu.meals.every((m) => m.subMeals.any((sm) => sm.cooking != null));
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
        newRecipe: _meal(id: "m_slow", name: "Slow Braise", totalMinutes: 120, maxStorageDays: 0),
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
      expect(menu.meals.first.subMeals.isNotEmpty, true, reason: "Required meal slot should have sub-meals");
      expect(menu.meals.first.subMeals.first.cooking, isNull, reason: "No fitting recipe, cooking should be null");
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
      expect(menu.meals.first.subMeals.isEmpty, true);
    });
  });

  group("Recipe.fitsConfiguration", () {
    // A lunch slot that can be cooked at the spot (requiresMeal + time available).
    const MenuConfiguration lunchSlot = MenuConfiguration(
      mealTime: MealTime(weekDay: WeekDay.saturday, mealType: MealType.lunch),
      requiresMeal: true,
      availableCookingTimeMinutes: 60,
    );
    // A dinner slot that can be cooked at the spot.
    const MenuConfiguration dinnerSlot = MenuConfiguration(
      mealTime: MealTime(weekDay: WeekDay.saturday, mealType: MealType.dinner),
      requiresMeal: true,
      availableCookingTimeMinutes: 60,
    );

    test("rejects a non-storable recipe when it must be stored", () {
      Recipe recipe = _meal(id: "r", name: "R", maxStorageDays: 0);
      expect(recipe.fitsConfiguration(lunchSlot, needToBeStored: true, strictMealTime: false), false);
    });

    test("accepts a storable recipe when it must be stored (other gates passing)", () {
      Recipe recipe = _meal(id: "r", name: "R", maxStorageDays: 3, lunch: true, dinner: false);
      expect(recipe.fitsConfiguration(lunchSlot, needToBeStored: true, strictMealTime: false), true);
    });

    test("rejects a recipe with cooking time when the slot cannot be cooked at the spot", () {
      const MenuConfiguration noTimeSlot = MenuConfiguration(
        mealTime: MealTime(weekDay: WeekDay.saturday, mealType: MealType.lunch),
        requiresMeal: true,
        availableCookingTimeMinutes: 0,
      );
      Recipe recipe = _meal(id: "r", name: "R", totalMinutes: 30, lunch: true, dinner: false);
      expect(recipe.fitsConfiguration(noTimeSlot, needToBeStored: false, strictMealTime: false), false);
    });

    test("accepts a zero-time recipe when the slot cannot be cooked at the spot", () {
      const MenuConfiguration noTimeSlot = MenuConfiguration(
        mealTime: MealTime(weekDay: WeekDay.saturday, mealType: MealType.lunch),
        requiresMeal: true,
        availableCookingTimeMinutes: 0,
      );
      Recipe recipe = _meal(id: "r", name: "R", totalMinutes: 0, lunch: true, dinner: false);
      expect(recipe.fitsConfiguration(noTimeSlot, needToBeStored: false, strictMealTime: false), true);
    });

    test("a 120-minute recipe fits a 15-minute slot (duration is never compared)", () {
      // NOTE: characterization -- possibly unintended, see plans/002.
      // fitsConfiguration never compares totalTimeMinutes to availableCookingTimeMinutes.
      // The only time gate is the binary canBeCookedAtTheSpot (time > 0), so any positive
      // available time accepts a recipe of any duration.
      const MenuConfiguration shortSlot = MenuConfiguration(
        mealTime: MealTime(weekDay: WeekDay.saturday, mealType: MealType.lunch),
        requiresMeal: true,
        availableCookingTimeMinutes: 15,
      );
      Recipe recipe = _meal(id: "r", name: "R", totalMinutes: 120, lunch: true, dinner: false);
      expect(recipe.fitsConfiguration(shortSlot, needToBeStored: false, strictMealTime: false), true);
    });

    test("rejects a recipe flagged for neither lunch nor dinner in a meal slot", () {
      Recipe recipe = _meal(id: "r", name: "R", lunch: false, dinner: false);
      expect(recipe.fitsConfiguration(lunchSlot, needToBeStored: false, strictMealTime: false), false);
    });

    test("strict mode rejects a lunch+dinner recipe from both lunch and dinner slots", () {
      // NOTE: characterization -- possibly unintended, see plans/002.
      // In strict mode a recipe flagged for BOTH lunch and dinner is rejected from lunch
      // slots (because dinner is true) and from dinner slots (because lunch is true).
      // Dual-flagged recipes can only enter a menu through the generator's fallback paths.
      Recipe dualRecipe = _meal(id: "r", name: "R", lunch: true, dinner: true);
      expect(dualRecipe.fitsConfiguration(lunchSlot, needToBeStored: false, strictMealTime: true), false);
      expect(dualRecipe.fitsConfiguration(dinnerSlot, needToBeStored: false, strictMealTime: true), false);

      Recipe lunchOnly = _meal(id: "r2", name: "R2", lunch: true, dinner: false);
      expect(lunchOnly.fitsConfiguration(lunchSlot, needToBeStored: false, strictMealTime: true), true);
    });
  });

  group("MenuGenerator getValidRecipeForConfiguration", () {
    // A lunch slot recipes are tested against.
    const MenuConfiguration lunchSlot = MenuConfiguration(
      mealTime: MealTime(weekDay: WeekDay.saturday, mealType: MealType.lunch),
      requiresMeal: true,
      availableCookingTimeMinutes: 60,
    );

    test("returns null for empty candidates", () {
      MenuGenerator generator = MenuGenerator(baseSeed: 42);
      Recipe? result = generator.getValidRecipeForConfiguration(
        maxNumberOfTimesTheSameRecipeShouldBeUsed: 999,
        configuration: lunchSlot,
        candidates: <Recipe>{},
        needToBeStored: false,
        alreadySelected: [],
        strictMealTime: true,
      );
      expect(result, isNull);
    });

    test("returns null when storage is required but no candidate is storable", () {
      MenuGenerator generator = MenuGenerator(baseSeed: 42);
      Recipe nonStorable = _meal(id: "ns", name: "Non Storable", maxStorageDays: 0, lunch: true, dinner: false);
      Recipe? result = generator.getValidRecipeForConfiguration(
        maxNumberOfTimesTheSameRecipeShouldBeUsed: 999,
        configuration: lunchSlot,
        candidates: {nonStorable},
        needToBeStored: true,
        alreadySelected: [],
        strictMealTime: true,
      );
      expect(result, isNull);
    });

    test("prioritizes the least-selected nutritional type", () {
      MenuGenerator generator = MenuGenerator(baseSeed: 42);
      // Two carb recipes already selected -> carbs is the most-selected type.
      Recipe carbA = _meal(id: "cA", name: "Carb A", carbs: true, proteins: false, vegetables: false, lunch: true, dinner: false);
      Recipe carbB = _meal(id: "cB", name: "Carb B", carbs: true, proteins: false, vegetables: false, lunch: true, dinner: false);
      Recipe carbCandidate = _meal(id: "cC", name: "Carb C", carbs: true, proteins: false, vegetables: false, lunch: true, dinner: false);
      Recipe proteinCandidate = _meal(id: "pD", name: "Protein D", carbs: false, proteins: true, vegetables: false, lunch: true, dinner: false);

      Recipe? result = generator.getValidRecipeForConfiguration(
        maxNumberOfTimesTheSameRecipeShouldBeUsed: 999,
        configuration: lunchSlot,
        candidates: {carbCandidate, proteinCandidate},
        needToBeStored: false,
        alreadySelected: [carbA, carbB],
        strictMealTime: true,
      );
      // Protein is the least-selected type, so the protein candidate wins.
      expect(result?.id, "pD");
    });

    test("deprioritizes a recipe already selected up to the repetition cap", () {
      MenuGenerator generator = MenuGenerator(baseSeed: 42);
      Recipe recipeA = _meal(id: "A", name: "A", carbs: true, proteins: false, vegetables: false, lunch: true, dinner: false);
      Recipe recipeB = _meal(id: "B", name: "B", carbs: true, proteins: false, vegetables: false, lunch: true, dinner: false);

      Recipe? result = generator.getValidRecipeForConfiguration(
        maxNumberOfTimesTheSameRecipeShouldBeUsed: 1,
        configuration: lunchSlot,
        candidates: {recipeA, recipeB},
        needToBeStored: false,
        alreadySelected: [recipeA],
        strictMealTime: true,
      );
      // A hit the cap and is moved to the back, so B is returned.
      expect(result?.id, "B");
    });

    test("a capped recipe is still returned when it is the only candidate", () {
      MenuGenerator generator = MenuGenerator(baseSeed: 42);
      Recipe recipeA = _meal(id: "A", name: "A", carbs: true, proteins: false, vegetables: false, lunch: true, dinner: false);

      Recipe? result = generator.getValidRecipeForConfiguration(
        maxNumberOfTimesTheSameRecipeShouldBeUsed: 1,
        configuration: lunchSlot,
        candidates: {recipeA},
        needToBeStored: false,
        alreadySelected: [recipeA],
        strictMealTime: true,
      );
      // The cap deprioritizes but does not exclude: A is still the only option.
      expect(result?.id, "A");
    });
  });

  group("MenuGenerator yield logic", () {
    test("storable recipe reused beyond its storage window cooks again", () {
      // Saturday (day 0) and Wednesday (day 4) are 4 days apart, beyond maxStorageDays: 1.
      Recipe storableRecipe = _meal(id: "m1", name: "Short-life Stew", maxStorageDays: 1, lunch: true, dinner: false);
      RecipesProvider.addOrUpdate(newRecipe: storableRecipe);

      List<MenuConfiguration> configs = [
        const MenuConfiguration(
          mealTime: MealTime(weekDay: WeekDay.saturday, mealType: MealType.lunch),
          requiresMeal: true,
          availableCookingTimeMinutes: 60,
        ),
        const MenuConfiguration(
          mealTime: MealTime(weekDay: WeekDay.wednesday, mealType: MealType.lunch),
          requiresMeal: true,
          availableCookingTimeMinutes: 60,
        ),
      ];

      MenuGenerator generator = MenuGenerator(baseSeed: 42);
      generator.generate(configurations: configs, recipes: RecipesProvider.instance.recipes);
      Menu menu = generator.menu!;

      // Both slots get the same recipe, but each is its own cook event (yield 1) because
      // the second occurrence falls outside the 1-day storage window.
      List<int> yields = menu.meals
          .map((m) => m.subMeals.firstOrNull?.cooking?.yield)
          .whereType<int>()
          .toList();
      expect(yields.length, 2);
      expect(yields.every((y) => y == 1), true);
    });

    test("storable recipe reused across three slots within the window yields on first only", () {
      // Saturday (0), Sunday (1), Monday (2) are all within maxStorageDays: 6.
      Recipe storableRecipe = _meal(id: "m1", name: "Big Batch", maxStorageDays: 6, lunch: true, dinner: false);
      RecipesProvider.addOrUpdate(newRecipe: storableRecipe);

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
        const MenuConfiguration(
          mealTime: MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch),
          requiresMeal: true,
          availableCookingTimeMinutes: 60,
        ),
      ];

      MenuGenerator generator = MenuGenerator(baseSeed: 42);
      generator.generate(configurations: configs, recipes: RecipesProvider.instance.recipes);
      Menu menu = generator.menu!;

      List<int> yields = menu.meals
          .map((m) => m.subMeals.firstOrNull?.cooking?.yield)
          .whereType<int>()
          .toList();
      expect(yields.length, 3);
      expect(yields.where((y) => y == 3).length, 1);
      expect(yields.where((y) => y == 0).length, 2);
    });

    test("non-storable recipe in two slots is a fresh cook each time", () {
      Recipe nonStorable = _meal(id: "m1", name: "Fresh Salad", maxStorageDays: 0, lunch: true, dinner: false);
      RecipesProvider.addOrUpdate(newRecipe: nonStorable);

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

      List<int> yields = menu.meals
          .map((m) => m.subMeals.firstOrNull?.cooking?.yield)
          .whereType<int>()
          .toList();
      expect(yields.length, 2);
      expect(yields.every((y) => y == 1), true);
    });
  });

  group("MenuGenerator multiple sub-meals", () {
    test("a mealCount of 2 produces two sub-meals with distinct recipes", () {
      for (int i = 0; i < 6; i++) {
        RecipesProvider.addOrUpdate(newRecipe: _meal(id: "m$i", name: "Meal $i", lunch: true, dinner: false));
      }

      List<MenuConfiguration> configs = [
        const MenuConfiguration(
          mealTime: MealTime(weekDay: WeekDay.saturday, mealType: MealType.lunch),
          requiresMeal: true,
          availableCookingTimeMinutes: 60,
          mealCount: 2,
        ),
      ];

      MenuGenerator generator = MenuGenerator(baseSeed: 42);
      generator.generate(configurations: configs, recipes: RecipesProvider.instance.recipes);
      Menu menu = generator.menu!;

      Meal meal = menu.meals.first;
      expect(meal.subMeals.length, 2);
      String? first = meal.subMeals[0].cooking?.recipeId;
      String? second = meal.subMeals[1].cooking?.recipeId;
      expect(first, isNotNull);
      expect(second, isNotNull);
      // The extra sub-meal draws from the remaining pool, so it gets a different recipe.
      expect(first == second, false);
    });

    test("peoplePerSubMeal is 1 for mealCount 2 and 2 for mealCount 1", () {
      RecipesProvider.addOrUpdate(newRecipe: _meal(id: "m0", name: "Meal 0", lunch: true, dinner: false));
      RecipesProvider.addOrUpdate(newRecipe: _meal(id: "m1", name: "Meal 1", lunch: true, dinner: false));

      List<MenuConfiguration> configs = [
        const MenuConfiguration(
          mealTime: MealTime(weekDay: WeekDay.saturday, mealType: MealType.lunch),
          requiresMeal: true,
          availableCookingTimeMinutes: 60,
          mealCount: 2,
        ),
        const MenuConfiguration(
          mealTime: MealTime(weekDay: WeekDay.sunday, mealType: MealType.lunch),
          requiresMeal: true,
          availableCookingTimeMinutes: 60,
          mealCount: 1,
        ),
      ];

      MenuGenerator generator = MenuGenerator(baseSeed: 42);
      generator.generate(configurations: configs, recipes: RecipesProvider.instance.recipes);
      Menu menu = generator.menu!;

      Meal twoCount = menu.meals.firstWhere((m) => m.mealTime.weekDay == WeekDay.saturday);
      Meal oneCount = menu.meals.firstWhere((m) => m.mealTime.weekDay == WeekDay.sunday);
      expect(twoCount.subMeals.every((sm) => sm.people == 1), true);
      expect(oneCount.subMeals.every((sm) => sm.people == 2), true);
    });

    test("a mealCount of 2 with a single recipe reuses it in the second sub-meal", () {
      RecipesProvider.addOrUpdate(newRecipe: _meal(id: "only", name: "Only Meal", lunch: true, dinner: false));

      List<MenuConfiguration> configs = [
        const MenuConfiguration(
          mealTime: MealTime(weekDay: WeekDay.saturday, mealType: MealType.lunch),
          requiresMeal: true,
          availableCookingTimeMinutes: 60,
          mealCount: 2,
        ),
      ];

      MenuGenerator generator = MenuGenerator(baseSeed: 42);
      generator.generate(configurations: configs, recipes: RecipesProvider.instance.recipes);
      Menu menu = generator.menu!;

      Meal meal = menu.meals.first;
      expect(meal.subMeals.length, 2);
      // With no other recipe available, the extra sub-meal falls back to the same recipe.
      expect(meal.subMeals[0].cooking?.recipeId, "only");
      expect(meal.subMeals[1].cooking?.recipeId, "only");
    });
  });

  group("MenuGenerator structural properties under stress", () {
    test("generation with zero meal recipes throws an assertion in debug mode", () {
      // NOTE: characterization -- possibly unintended, see plans/002.
      // With no meal recipes, generate() calls Debug.logWarning(mealsRecipes.isEmpty, "No meals found")
      // which fires an assert (asAssertion defaults to true). So the generator cannot run with an empty
      // meal pool while assertions are enabled (debug/test). In release mode the assert is skipped and
      // lunch/dinner slots would simply stay empty.
      // Only the default breakfast recipe from setUp exists.
      List<MenuConfiguration> configs = _fullWeekConfigurations();
      MenuGenerator generator = MenuGenerator(baseSeed: 42);
      expect(
        () => generator.generate(configurations: configs, recipes: RecipesProvider.instance.recipes),
        throwsA(isA<AssertionError>()),
      );
    });

    test("no crash when every recipe needs time but no slot can cook at the spot", () {
      for (int i = 0; i < 5; i++) {
        RecipesProvider.addOrUpdate(newRecipe: _meal(id: "m$i", name: "Meal $i", totalMinutes: 30, maxStorageDays: 0, lunch: true, dinner: false));
      }

      List<MenuConfiguration> configs = _fullWeekConfigurations(cookingTimeMinutes: 0);
      MenuGenerator generator = MenuGenerator(baseSeed: 42);
      generator.generate(configurations: configs, recipes: RecipesProvider.instance.recipes);
      Menu menu = generator.menu!;

      // No slot can cook at the spot and non-storable recipes cannot be leftovers,
      // so every meal slot stays empty.
      List<Meal> mealSlots = menu.meals
          .where((m) => m.mealTime.mealType == MealType.lunch || m.mealTime.mealType == MealType.dinner)
          .toList();
      expect(mealSlots.every((m) => m.subMeals.every((sm) => sm.cooking == null)), true);
    });

    test("lunch slots only get lunch recipes and dinner slots only get dinner recipes", () {
      for (int i = 0; i < 6; i++) {
        RecipesProvider.addOrUpdate(newRecipe: _meal(id: "lunch$i", name: "Lunch $i", lunch: true, dinner: false));
        RecipesProvider.addOrUpdate(newRecipe: _meal(id: "dinner$i", name: "Dinner $i", lunch: false, dinner: true));
      }

      List<MenuConfiguration> configs = _fullWeekConfigurations();
      MenuGenerator generator = MenuGenerator(baseSeed: 42);
      generator.generate(configurations: configs, recipes: RecipesProvider.instance.recipes);
      Menu menu = generator.menu!;

      for (Meal meal in menu.meals) {
        for (SubMeal subMeal in meal.subMeals) {
          if (subMeal.cooking == null) continue;
          Recipe recipe = RecipesProvider.instance.get(subMeal.cooking!.recipeId);
          if (meal.mealTime.mealType == MealType.lunch) {
            expect(recipe.lunch, true, reason: "Lunch slot at ${meal.mealTime.weekDay} got a non-lunch recipe");
          }
          if (meal.mealTime.mealType == MealType.dinner) {
            expect(recipe.dinner, true, reason: "Dinner slot at ${meal.mealTime.weekDay} got a non-dinner recipe");
          }
        }
      }
    });
  });
}
