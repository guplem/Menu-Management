import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:menu_management/menu/enums/meal_type.dart";
import "package:menu_management/menu/enums/week_day.dart";
import "package:menu_management/menu/models/meal_time.dart";
import "package:menu_management/menu/models/menu_configuration.dart";
import "package:menu_management/recipes/enums/recipe_type.dart";
import "package:menu_management/recipes/enums/unit.dart";
import "package:menu_management/recipes/models/ingredient_usage.dart";
import "package:menu_management/recipes/models/instruction.dart";
import "package:menu_management/recipes/models/quantity.dart";
import "package:menu_management/recipes/models/recipe.dart";
import "package:menu_management/recipes/models/result.dart";

void main() {
  // ── Instruction ──

  group("Instruction", () {
    test("totalTimeMinutes is sum of working and cooking time", () {
      Instruction instruction = const Instruction(id: "i1", description: "step", workingTimeMinutes: 15, cookingTimeMinutes: 30);
      expect(instruction.totalTimeMinutes, 45);
    });

    test("defaults to 10 + 10 = 20 total minutes", () {
      Instruction instruction = const Instruction(id: "i1", description: "step");
      expect(instruction.totalTimeMinutes, 20);
    });

    test("defaults to empty ingredientsUsed, outputs, and inputs", () {
      Instruction instruction = const Instruction(id: "i1", description: "step");
      expect(instruction.ingredientsUsed, isEmpty);
      expect(instruction.outputs, isEmpty);
      expect(instruction.inputs, isEmpty);
    });

    test("JSON round-trip preserves all fields", () {
      Instruction original = Instruction(
        id: "i1",
        description: "Boil water",
        workingTimeMinutes: 5,
        cookingTimeMinutes: 10,
        ingredientsUsed: [
          const IngredientUsage(
            ingredient: "water",
            quantity: Quantity(amount: 500, unit: Unit.centiliters),
          ),
        ],
        outputs: [const Result(id: "o1", description: "boiled water")],
        inputs: ["input1"],
      );
      String encoded = jsonEncode(original.toJson());
      Instruction restored = Instruction.fromJson(jsonDecode(encoded));
      expect(restored.id, "i1");
      expect(restored.description, "Boil water");
      expect(restored.ingredientsUsed.length, 1);
      expect(restored.outputs.length, 1);
      expect(restored.inputs.length, 1);
    });
  });

  // ── IngredientUsage ──

  group("IngredientUsage", () {
    test("holds ingredient id and quantity", () {
      const IngredientUsage usage = IngredientUsage(
        ingredient: "flour",
        quantity: Quantity(amount: 200, unit: Unit.grams),
      );
      expect(usage.ingredient, "flour");
      expect(usage.quantity.amount, 200);
      expect(usage.quantity.unit, Unit.grams);
    });

    test("equality by value", () {
      const IngredientUsage a = IngredientUsage(
        ingredient: "flour",
        quantity: Quantity(amount: 200, unit: Unit.grams),
      );
      const IngredientUsage b = IngredientUsage(
        ingredient: "flour",
        quantity: Quantity(amount: 200, unit: Unit.grams),
      );
      expect(a, b);
    });
  });

  // ── Quantity ──

  group("Quantity", () {
    test("holds amount and unit", () {
      const Quantity q = Quantity(amount: 100, unit: Unit.grams);
      expect(q.amount, 100);
      expect(q.unit, Unit.grams);
    });

    test("copyWith changes amount", () {
      const Quantity q = Quantity(amount: 100, unit: Unit.grams);
      Quantity updated = q.copyWith(amount: 200);
      expect(updated.amount, 200);
      expect(updated.unit, Unit.grams);
    });
  });

  // ── Result ──

  group("Result", () {
    test("holds id and description", () {
      const Result r = Result(id: "r1", description: "cooked pasta");
      expect(r.id, "r1");
      expect(r.description, "cooked pasta");
    });

    test("equality by value", () {
      const Result a = Result(id: "r1", description: "cooked pasta");
      const Result b = Result(id: "r1", description: "cooked pasta");
      expect(a, b);
    });
  });

  // ── Recipe ──

  group("Recipe", () {
    group("time calculations", () {
      test("workingTimeMinutes sums across instructions", () {
        Recipe recipe = const Recipe(
          id: "r1",
          name: "Test",
          instructions: [
            Instruction(id: "i1", description: "s1", workingTimeMinutes: 10, cookingTimeMinutes: 0),
            Instruction(id: "i2", description: "s2", workingTimeMinutes: 15, cookingTimeMinutes: 0),
          ],
        );
        expect(recipe.workingTimeMinutes, 25);
      });

      test("cookingTimeMinutes sums across instructions", () {
        Recipe recipe = const Recipe(
          id: "r1",
          name: "Test",
          instructions: [
            Instruction(id: "i1", description: "s1", workingTimeMinutes: 0, cookingTimeMinutes: 20),
            Instruction(id: "i2", description: "s2", workingTimeMinutes: 0, cookingTimeMinutes: 30),
          ],
        );
        expect(recipe.cookingTimeMinutes, 50);
      });

      test("totalTimeMinutes sums all times", () {
        Recipe recipe = const Recipe(
          id: "r1",
          name: "Test",
          instructions: [
            Instruction(id: "i1", description: "s1", workingTimeMinutes: 5, cookingTimeMinutes: 10),
            Instruction(id: "i2", description: "s2", workingTimeMinutes: 10, cookingTimeMinutes: 20),
          ],
        );
        expect(recipe.totalTimeMinutes, 45);
      });

      test("zero for no instructions", () {
        Recipe recipe = const Recipe(id: "r1", name: "Test");
        expect(recipe.totalTimeMinutes, 0);
        expect(recipe.workingTimeMinutes, 0);
        expect(recipe.cookingTimeMinutes, 0);
      });
    });

    group("toShortString", () {
      test("formats as name (totalTime)", () {
        Recipe recipe = const Recipe(
          id: "r1",
          name: "Pasta",
          instructions: [Instruction(id: "i1", description: "s1", workingTimeMinutes: 5, cookingTimeMinutes: 10)],
        );
        expect(recipe.toShortString(), "Pasta (15min)");
      });

      test("shows 0min for no instructions", () {
        Recipe recipe = const Recipe(id: "r1", name: "Quick Snack");
        expect(recipe.toShortString(), "Quick Snack (0min)");
      });
    });

    group("defaults", () {
      test("has expected default values", () {
        Recipe recipe = const Recipe(id: "r1", name: "Test");
        expect(recipe.carbs, true);
        expect(recipe.proteins, true);
        expect(recipe.vegetables, true);
        expect(recipe.type, RecipeType.meal);
        expect(recipe.lunch, true);
        expect(recipe.dinner, true);
        expect(recipe.canBeStored, true);
        expect(recipe.includeInMenuGeneration, true);
        expect(recipe.instructions, isEmpty);
      });
    });

    group("fitsConfiguration", () {
      MenuConfiguration configWithTime(MealType mealType, int minutes) {
        return MenuConfiguration(
          mealTime: MealTime(weekDay: WeekDay.monday, mealType: mealType),
          requiresMeal: true,
          availableCookingTimeMinutes: minutes,
        );
      }

      test("rejects non-storable recipe when needToBeStored is true", () {
        Recipe recipe = const Recipe(id: "r1", name: "Test", canBeStored: false);
        expect(recipe.fitsConfiguration(configWithTime(MealType.lunch, 60), needToBeStored: true, strictMealTime: false), false);
      });

      test("accepts non-storable recipe when needToBeStored is false", () {
        Recipe recipe = const Recipe(id: "r1", name: "Test", canBeStored: false);
        expect(recipe.fitsConfiguration(configWithTime(MealType.lunch, 60), needToBeStored: false, strictMealTime: false), true);
      });

      test("rejects recipe with cooking time when config cannot cook at the spot", () {
        Recipe recipe = const Recipe(
          id: "r1",
          name: "Test",
          instructions: [Instruction(id: "i1", description: "s1", workingTimeMinutes: 10, cookingTimeMinutes: 10)],
        );
        // availableCookingTimeMinutes = 0 => canBeCookedAtTheSpot = false
        expect(recipe.fitsConfiguration(configWithTime(MealType.lunch, 0), needToBeStored: false, strictMealTime: false), false);
      });

      test("accepts zero-time recipe when config cannot cook at the spot", () {
        Recipe recipe = const Recipe(id: "r1", name: "Test", instructions: []);
        expect(recipe.fitsConfiguration(configWithTime(MealType.lunch, 0), needToBeStored: false, strictMealTime: false), true);
      });

      test("strict lunch rejects dinner-only recipe", () {
        Recipe recipe = const Recipe(id: "r1", name: "Test", lunch: false, dinner: true);
        expect(recipe.fitsConfiguration(configWithTime(MealType.lunch, 60), needToBeStored: false, strictMealTime: true), false);
      });

      test("strict dinner rejects lunch-only recipe", () {
        Recipe recipe = const Recipe(id: "r1", name: "Test", lunch: true, dinner: false);
        expect(recipe.fitsConfiguration(configWithTime(MealType.dinner, 60), needToBeStored: false, strictMealTime: true), false);
      });

      test("non-strict mode ignores meal time restrictions", () {
        Recipe recipe = const Recipe(id: "r1", name: "Test", lunch: false, dinner: true);
        expect(recipe.fitsConfiguration(configWithTime(MealType.lunch, 60), needToBeStored: false, strictMealTime: false), true);
      });

      test("rejects recipe with no lunch/dinner flags for a meal config", () {
        Recipe recipe = const Recipe(id: "r1", name: "Test", lunch: false, dinner: false);
        expect(recipe.fitsConfiguration(configWithTime(MealType.lunch, 60), needToBeStored: false, strictMealTime: false), false);
      });
    });

    group("JSON serialization", () {
      test("round-trips through JSON", () {
        Recipe original = const Recipe(
          id: "r1",
          name: "Pasta Bolognese",
          carbs: true,
          proteins: true,
          vegetables: false,
          type: RecipeType.meal,
          lunch: true,
          dinner: true,
          canBeStored: true,
          includeInMenuGeneration: false,
        );
        Recipe restored = Recipe.fromJson(original.toJson());
        expect(restored, original);
      });
    });
  });
}
