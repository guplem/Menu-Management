import "package:flutter_test/flutter_test.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/menu/enums/week_day.dart";
import "package:menu_management/menu/expiry_warnings.dart";
import "package:menu_management/menu/enums/meal_type.dart";
import "package:menu_management/menu/models/cooking.dart";
import "package:menu_management/menu/models/meal.dart";
import "package:menu_management/menu/models/meal_time.dart";
import "package:menu_management/menu/models/sub_meal.dart";
import "package:menu_management/recipes/enums/unit.dart";
import "package:menu_management/recipes/models/instruction.dart";
import "package:menu_management/recipes/models/ingredient_usage.dart";
import "package:menu_management/recipes/models/quantity.dart";
import "package:menu_management/recipes/models/recipe.dart";

Product _product({String link = "https://example.com/p", int? shelfLifeDaysClosed, bool canBeFrozen = false}) {
  return Product(
    link: link,
    quantityPerItem: 250,
    unit: Unit.grams,
    shelfLifeDaysClosed: shelfLifeDaysClosed,
    canBeFrozen: canBeFrozen,
  );
}

Ingredient _ingredient({required String id, String? name, List<Product> products = const []}) {
  return Ingredient(id: id, name: name ?? id, products: products);
}

Recipe _recipe({required String id, required List<String> ingredientIds}) {
  return Recipe(
    id: id,
    name: id,
    instructions: [
      Instruction(
        id: "$id-step",
        description: "step",
        ingredientsUsed: ingredientIds
            .map((iid) => IngredientUsage(ingredient: iid, quantity: const Quantity(amount: 100, unit: Unit.grams)))
            .toList(),
      ),
    ],
  );
}

Meal _meal({String? recipeId}) {
  return Meal(
    mealTime: const MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch),
    subMeals: [
      SubMeal(cooking: recipeId == null ? null : Cooking(recipeId: recipeId, yield: 1)),
    ],
  );
}

void main() {
  group("expiryWarningsForMeal", () {
    test("returns empty when meal has no sub-meals with cooking", () {
      List<MealExpiryWarning> warnings = expiryWarningsForMeal(
        meal: _meal(),
        absoluteDayIndex: 5,
        recipes: const [],
        ingredients: const [],
      );
      expect(warnings, isEmpty);
    });

    test("returns empty when recipe ID is unknown", () {
      List<MealExpiryWarning> warnings = expiryWarningsForMeal(
        meal: _meal(recipeId: "unknown-recipe"),
        absoluteDayIndex: 5,
        recipes: const [],
        ingredients: const [],
      );
      expect(warnings, isEmpty);
    });

    test("returns empty when ingredient has no products", () {
      Recipe recipe = _recipe(id: "r1", ingredientIds: ["i1"]);
      Ingredient ingredient = _ingredient(id: "i1");
      List<MealExpiryWarning> warnings = expiryWarningsForMeal(
        meal: _meal(recipeId: "r1"),
        absoluteDayIndex: 5,
        recipes: [recipe],
        ingredients: [ingredient],
      );
      expect(warnings, isEmpty);
    });

    test("returns empty when single product has null shelfLifeDaysClosed", () {
      Recipe recipe = _recipe(id: "r1", ingredientIds: ["i1"]);
      Ingredient ingredient = _ingredient(id: "i1", products: [_product()]);
      List<MealExpiryWarning> warnings = expiryWarningsForMeal(
        meal: _meal(recipeId: "r1"),
        absoluteDayIndex: 100,
        recipes: [recipe],
        ingredients: [ingredient],
      );
      expect(warnings, isEmpty);
    });

    test("returns empty when product survives by day", () {
      Recipe recipe = _recipe(id: "r1", ingredientIds: ["i1"]);
      Ingredient ingredient = _ingredient(id: "i1", products: [_product(shelfLifeDaysClosed: 5)]);
      List<MealExpiryWarning> warnings = expiryWarningsForMeal(
        meal: _meal(recipeId: "r1"),
        absoluteDayIndex: 2, // 2 + 1 = 3 < 5, survives
        recipes: [recipe],
        ingredients: [ingredient],
      );
      expect(warnings, isEmpty);
    });

    test("warns when single product is expired by day", () {
      Recipe recipe = _recipe(id: "r1", ingredientIds: ["i1"]);
      Product expired = _product(shelfLifeDaysClosed: 2);
      Ingredient ingredient = _ingredient(id: "i1", name: "Chicken", products: [expired]);
      List<MealExpiryWarning> warnings = expiryWarningsForMeal(
        meal: _meal(recipeId: "r1"),
        absoluteDayIndex: 5, // 5 + 1 = 6 >= 2
        recipes: [recipe],
        ingredients: [ingredient],
      );
      expect(warnings, hasLength(1));
      expect(warnings.first.ingredient, ingredient);
      expect(warnings.first.products, [expired]);
    });

    test("warns when all variants expire by day", () {
      Recipe recipe = _recipe(id: "r1", ingredientIds: ["i1"]);
      Product small = _product(link: "https://example.com/small", shelfLifeDaysClosed: 2);
      Product big = _product(link: "https://example.com/big", shelfLifeDaysClosed: 3);
      Ingredient ingredient = _ingredient(id: "i1", products: [small, big]);
      List<MealExpiryWarning> warnings = expiryWarningsForMeal(
        meal: _meal(recipeId: "r1"),
        absoluteDayIndex: 5,
        recipes: [recipe],
        ingredients: [ingredient],
      );
      expect(warnings, hasLength(1));
      expect(warnings.first.products, [small, big]);
    });

    test("does not warn when at least one variant has null shelfLifeDaysClosed", () {
      Recipe recipe = _recipe(id: "r1", ingredientIds: ["i1"]);
      Product perishable = _product(link: "https://example.com/p1", shelfLifeDaysClosed: 1);
      Product canned = _product(link: "https://example.com/p2"); // null = indefinite when sealed
      Ingredient ingredient = _ingredient(id: "i1", products: [perishable, canned]);
      List<MealExpiryWarning> warnings = expiryWarningsForMeal(
        meal: _meal(recipeId: "r1"),
        absoluteDayIndex: 100,
        recipes: [recipe],
        ingredients: [ingredient],
      );
      expect(warnings, isEmpty);
    });

    test("does not warn when at least one variant survives", () {
      Recipe recipe = _recipe(id: "r1", ingredientIds: ["i1"]);
      Product short = _product(link: "https://example.com/short", shelfLifeDaysClosed: 2);
      Product long = _product(link: "https://example.com/long", shelfLifeDaysClosed: 30);
      Ingredient ingredient = _ingredient(id: "i1", products: [short, long]);
      List<MealExpiryWarning> warnings = expiryWarningsForMeal(
        meal: _meal(recipeId: "r1"),
        absoluteDayIndex: 5,
        recipes: [recipe],
        ingredients: [ingredient],
      );
      expect(warnings, isEmpty);
    });

    test("aggregates warnings from multiple ingredients", () {
      Recipe recipe = _recipe(id: "r1", ingredientIds: ["i1", "i2"]);
      Ingredient i1 = _ingredient(id: "i1", products: [_product(shelfLifeDaysClosed: 1)]);
      Ingredient i2 = _ingredient(id: "i2", products: [_product(shelfLifeDaysClosed: 2)]);
      List<MealExpiryWarning> warnings = expiryWarningsForMeal(
        meal: _meal(recipeId: "r1"),
        absoluteDayIndex: 10,
        recipes: [recipe],
        ingredients: [i1, i2],
      );
      expect(warnings.map((w) => w.ingredient.id).toSet(), {"i1", "i2"});
    });

    test("deduplicates warnings across instructions using the same ingredient", () {
      Recipe recipe = Recipe(
        id: "r1",
        name: "r1",
        instructions: [
          Instruction(
            id: "s1",
            description: "first",
            ingredientsUsed: [IngredientUsage(ingredient: "i1", quantity: const Quantity(amount: 100, unit: Unit.grams))],
          ),
          Instruction(
            id: "s2",
            description: "second",
            ingredientsUsed: [IngredientUsage(ingredient: "i1", quantity: const Quantity(amount: 50, unit: Unit.grams))],
          ),
        ],
      );
      Ingredient i1 = _ingredient(id: "i1", products: [_product(shelfLifeDaysClosed: 1)]);
      List<MealExpiryWarning> warnings = expiryWarningsForMeal(
        meal: _meal(recipeId: "r1"),
        absoluteDayIndex: 5,
        recipes: [recipe],
        ingredients: [i1],
      );
      expect(warnings, hasLength(1));
    });

    test("aggregates warnings across multiple sub-meals with different recipes", () {
      Recipe r1 = _recipe(id: "r1", ingredientIds: ["i1"]);
      Recipe r2 = _recipe(id: "r2", ingredientIds: ["i2"]);
      Ingredient i1 = _ingredient(id: "i1", products: [_product(shelfLifeDaysClosed: 1)]);
      Ingredient i2 = _ingredient(id: "i2", products: [_product(shelfLifeDaysClosed: 2)]);
      Meal meal = Meal(
        mealTime: const MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch),
        subMeals: [
          SubMeal(cooking: const Cooking(recipeId: "r1", yield: 1)),
          SubMeal(cooking: const Cooking(recipeId: "r2", yield: 1)),
        ],
      );
      List<MealExpiryWarning> warnings = expiryWarningsForMeal(
        meal: meal,
        absoluteDayIndex: 10,
        recipes: [r1, r2],
        ingredients: [i1, i2],
      );
      expect(warnings.map((w) => w.ingredient.id).toSet(), {"i1", "i2"});
    });

    test("returns empty when the only sub-meal is a leftover (yield == 0)", () {
      Recipe recipe = _recipe(id: "r1", ingredientIds: ["i1"]);
      Ingredient ingredient = _ingredient(id: "i1", products: [_product(shelfLifeDaysClosed: 1)]);
      Meal leftoverOnly = Meal(
        mealTime: const MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch),
        subMeals: [
          SubMeal(cooking: const Cooking(recipeId: "r1", yield: 0)),
        ],
      );
      List<MealExpiryWarning> warnings = expiryWarningsForMeal(
        meal: leftoverOnly,
        absoluteDayIndex: 5,
        recipes: [recipe],
        ingredients: [ingredient],
      );
      expect(warnings, isEmpty);
    });

    test("ignores leftover sub-meals when aggregating with cooking sub-meals", () {
      Recipe r1 = _recipe(id: "r1", ingredientIds: ["i1"]);
      Recipe r2 = _recipe(id: "r2", ingredientIds: ["i2"]);
      Ingredient i1 = _ingredient(id: "i1", products: [_product(shelfLifeDaysClosed: 1)]);
      Ingredient i2 = _ingredient(id: "i2", products: [_product(shelfLifeDaysClosed: 2)]);
      Meal meal = Meal(
        mealTime: const MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch),
        subMeals: [
          SubMeal(cooking: const Cooking(recipeId: "r1", yield: 0)), // leftover, must be ignored
          SubMeal(cooking: const Cooking(recipeId: "r2", yield: 1)),
        ],
      );
      List<MealExpiryWarning> warnings = expiryWarningsForMeal(
        meal: meal,
        absoluteDayIndex: 10,
        recipes: [r1, r2],
        ingredients: [i1, i2],
      );
      expect(warnings.map((w) => w.ingredient.id).toSet(), {"i2"});
    });
  });

  group("MealExpiryWarning severity", () {
    test("severity is impossible when single non-freezable product is past sealed life", () {
      Recipe recipe = _recipe(id: "r1", ingredientIds: ["i1"]);
      Product expired = _product(shelfLifeDaysClosed: 2);
      Ingredient ingredient = _ingredient(id: "i1", products: [expired]);
      List<MealExpiryWarning> warnings = expiryWarningsForMeal(
        meal: _meal(recipeId: "r1"),
        absoluteDayIndex: 5,
        recipes: [recipe],
        ingredients: [ingredient],
      );
      expect(warnings, hasLength(1));
      expect(warnings.first.severity, MealExpirySeverity.impossible);
    });

    test("severity is freezeRequired when single freezable product is past sealed life", () {
      Recipe recipe = _recipe(id: "r1", ingredientIds: ["i1"]);
      Product chicken = _product(shelfLifeDaysClosed: 3, canBeFrozen: true);
      Ingredient ingredient = _ingredient(id: "i1", name: "Chicken", products: [chicken]);
      List<MealExpiryWarning> warnings = expiryWarningsForMeal(
        meal: _meal(recipeId: "r1"),
        absoluteDayIndex: 14,
        recipes: [recipe],
        ingredients: [ingredient],
      );
      expect(warnings, hasLength(1));
      expect(warnings.first.severity, MealExpirySeverity.freezeRequired);
    });

    test("severity is freezeRequired when at least one expired variant is freezable", () {
      Recipe recipe = _recipe(id: "r1", ingredientIds: ["i1"]);
      Product nonFreezable = _product(link: "https://example.com/p1", shelfLifeDaysClosed: 2);
      Product freezable = _product(link: "https://example.com/p2", shelfLifeDaysClosed: 3, canBeFrozen: true);
      Ingredient ingredient = _ingredient(id: "i1", products: [nonFreezable, freezable]);
      List<MealExpiryWarning> warnings = expiryWarningsForMeal(
        meal: _meal(recipeId: "r1"),
        absoluteDayIndex: 10,
        recipes: [recipe],
        ingredients: [ingredient],
      );
      expect(warnings, hasLength(1));
      expect(warnings.first.severity, MealExpirySeverity.freezeRequired);
    });

    test("severity is impossible when no expired variant is freezable", () {
      Recipe recipe = _recipe(id: "r1", ingredientIds: ["i1"]);
      Product small = _product(link: "https://example.com/p1", shelfLifeDaysClosed: 2);
      Product big = _product(link: "https://example.com/p2", shelfLifeDaysClosed: 3);
      Ingredient ingredient = _ingredient(id: "i1", products: [small, big]);
      List<MealExpiryWarning> warnings = expiryWarningsForMeal(
        meal: _meal(recipeId: "r1"),
        absoluteDayIndex: 10,
        recipes: [recipe],
        ingredients: [ingredient],
      );
      expect(warnings, hasLength(1));
      expect(warnings.first.severity, MealExpirySeverity.impossible);
    });

    test("freezable variant that survives sealed produces no warning at all", () {
      Recipe recipe = _recipe(id: "r1", ingredientIds: ["i1"]);
      Product longLifeFreezable = _product(shelfLifeDaysClosed: 30, canBeFrozen: true);
      Ingredient ingredient = _ingredient(id: "i1", products: [longLifeFreezable]);
      List<MealExpiryWarning> warnings = expiryWarningsForMeal(
        meal: _meal(recipeId: "r1"),
        absoluteDayIndex: 5,
        recipes: [recipe],
        ingredients: [ingredient],
      );
      expect(warnings, isEmpty);
    });

    test("a meal with one impossible and one freezeRequired ingredient produces both severities", () {
      Recipe r1 = _recipe(id: "r1", ingredientIds: ["i1"]);
      Recipe r2 = _recipe(id: "r2", ingredientIds: ["i2"]);
      Ingredient i1 = _ingredient(id: "i1", products: [_product(shelfLifeDaysClosed: 2)]); // impossible
      Ingredient i2 = _ingredient(id: "i2", products: [_product(shelfLifeDaysClosed: 3, canBeFrozen: true)]); // freezeRequired
      Meal meal = Meal(
        mealTime: const MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch),
        subMeals: [
          SubMeal(cooking: const Cooking(recipeId: "r1", yield: 1)),
          SubMeal(cooking: const Cooking(recipeId: "r2", yield: 1)),
        ],
      );
      List<MealExpiryWarning> warnings = expiryWarningsForMeal(
        meal: meal,
        absoluteDayIndex: 10,
        recipes: [r1, r2],
        ingredients: [i1, i2],
      );
      Map<String, MealExpirySeverity> bySeverity = {for (MealExpiryWarning w in warnings) w.ingredient.id: w.severity};
      expect(bySeverity["i1"], MealExpirySeverity.impossible);
      expect(bySeverity["i2"], MealExpirySeverity.freezeRequired);
    });
  });
}
