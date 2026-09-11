import "package:flutter_test/flutter_test.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/models/product.dart";
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
import "package:menu_management/shopping/multi_trip_planner.dart";
import "package:menu_management/shopping/owned_amount.dart";
import "package:menu_management/shopping/shopping_pdf_document.dart";

const Ingredient _noodles = Ingredient(id: "n1", name: "Noodles");

/// One recipe that eats 100 grams of noodles per serving.
Recipe _pasta() => const Recipe(
  id: "r1",
  name: "Pasta",
  instructions: [
    Instruction(
      id: "i1",
      description: "Boil the pasta.",
      ingredientsUsed: [
        IngredientUsage(
          ingredient: "n1",
          quantity: Quantity(amount: 100, unit: Unit.grams),
        ),
      ],
    ),
  ],
);

Meal _meal({required WeekDay weekDay, required MealType mealType, int yield = 1, int people = 2}) => Meal(
  mealTime: MealTime(weekDay: weekDay, mealType: mealType),
  subMeals: [
    SubMeal(
      cooking: Cooking(recipeId: "r1", yield: yield),
      people: people,
    ),
  ],
);

MultiWeekMenu _menu() => MultiWeekMenu(
  startDate: DateTime(2025, 8, 6),
  weeks: [
    Menu(
      meals: [
        _meal(weekDay: WeekDay.saturday, mealType: MealType.lunch),
        _meal(weekDay: WeekDay.sunday, mealType: MealType.dinner, yield: 0, people: 3),
      ],
    ),
  ],
);

/// Builds a document with the defaults that most tests share: one menu, one ingredient and no trip.
ShoppingPdfDocument _document({
  List<Ingredient> ingredients = const [_noodles],
  Map<String, List<Quantity>> remaining = const {
    "n1": [Quantity(amount: 500, unit: Unit.grams)],
  },
  List<ShoppingTrip> trips = const [],
  MultiWeekMenu? multiWeekMenu,
}) {
  return buildShoppingPdfDocument(
    ingredients: ingredients,
    remainingByIngredientId: remaining,
    trips: trips,
    tripLabel: (ShoppingTrip trip) => "Trip of week ${trip.weekIndex + 1}",
    multiWeekMenu: multiWeekMenu ?? _menu(),
    recipes: [_pasta()],
    cookingTimeline: const {},
  );
}

void main() {
  group("buildShoppingPdfDocument sections", () {
    test("writes one untitled section when the planner finds no trip, so the reader gets one plain list", () {
      ShoppingPdfDocument document = _document();

      expect(document.trips.length, 1);
      expect(document.trips.single.title, "");
      expect(document.trips.single.ingredients.map((ShoppingPdfIngredientEntry entry) => entry.ingredientName).toList(), ["Noodles"]);
    });

    test("writes one section per planned trip, and keeps the freeze-on-arrival note of that trip", () {
      List<ShoppingTrip> trips = const [
        ShoppingTrip(
          weekIndex: 0,
          items: [TripItem(ingredientId: "n1", amount: 100, unit: Unit.grams, freezeOnArrival: true)],
        ),
        ShoppingTrip(
          weekIndex: 1,
          items: [TripItem(ingredientId: "n1", amount: 100, unit: Unit.grams)],
        ),
      ];

      ShoppingPdfDocument document = _document(trips: trips);

      expect(document.trips.map((ShoppingPdfTripSection section) => section.title).toList(), ["Trip of week 1", "Trip of week 2"]);
      expect(document.trips.map((ShoppingPdfTripSection section) => section.ingredients.single.amounts).toList(), ["250 grams", "250 grams"]);
      expect(document.trips.map((ShoppingPdfTripSection section) => section.ingredients.single.freezeOnArrival).toList(), [true, false]);
    });

    test("writes no entry for an ingredient that the user already owns in full", () {
      ShoppingPdfDocument document = _document(
        remaining: const {
          "n1": [Quantity(amount: 0, unit: Unit.grams)],
        },
      );

      expect(document.trips.single.ingredients, isEmpty);
    });

    test("keeps an ingredient whose need rounds below one unit, because a pinch of salt is still a need", () {
      ShoppingPdfDocument document = _document(
        remaining: {
          "n1": [Quantity(amount: roundNeededAmount(0.4), unit: Unit.grams)],
        },
      );

      expect(document.trips.single.ingredients.single.ingredientName, "Noodles");
      expect(document.trips.single.ingredients.single.amounts, "1 grams");
    });

    test("names the document after the days that the menu covers", () {
      expect(_document().title, "Shopping list 6 Aug - 12 Aug");
      expect(_document(multiWeekMenu: const MultiWeekMenu(weeks: [Menu()])).title, "Shopping list");
    });
  });

  group("buildShoppingPdfDocument products", () {
    test("lists every product that matches the unit with the packs of buying only that product, and marks the best one", () {
      Ingredient noodles = const Ingredient(
        id: "n1",
        name: "Noodles",
        products: [
          Product(link: "https://tienda.mercadona.es/product/1/espaguetis", quantityPerItem: 500, unit: Unit.grams),
          Product(link: "", quantityPerItem: 250, unit: Unit.grams),
          Product(link: "", quantityPerItem: 1, unit: Unit.pieces),
        ],
      );

      ShoppingPdfDocument document = _document(ingredients: [noodles]);

      expect(document.trips.single.ingredients.single.products, const [
        ShoppingPdfProductOption(
          label: "Espaguetis (500 grams/pack)",
          link: "https://tienda.mercadona.es/product/1/espaguetis",
          packs: 1,
          isRecommended: true,
        ),
        ShoppingPdfProductOption(label: "250 grams/pack", link: "", packs: 2, isRecommended: false),
      ]);
    });

    test("writes no product option for an ingredient that has none, so its line still shows the amount", () {
      ShoppingPdfIngredientEntry entry = _document().trips.single.ingredients.single;

      expect(entry.products, isEmpty);
      expect(entry.amounts, "500 grams");
    });
  });

  group("buildShoppingPdfDocument justification", () {
    test("names the week, the day, the meal slot, the recipe and the amount of every meal that needs the ingredient", () {
      ShoppingPdfIngredientEntry entry = _document().trips.single.ingredients.single;

      expect(entry.meals, const [
        ShoppingPdfMealNeed(
          weekLabel: "Week 1",
          dayLabel: "Wednesday 6 Aug",
          mealName: "Lunch",
          recipeName: "Pasta",
          people: 2,
          isCookEvent: true,
          amounts: "200 grams",
        ),
        ShoppingPdfMealNeed(
          weekLabel: "Week 1",
          dayLabel: "Thursday 7 Aug",
          mealName: "Dinner",
          recipeName: "Pasta",
          people: 3,
          isCookEvent: false,
          amounts: "300 grams",
        ),
      ]);
    });

    test("falls back to the weekday name when the menu carries no start date", () {
      ShoppingPdfDocument document = _document(
        multiWeekMenu: MultiWeekMenu(
          weeks: [
            Menu(
              meals: [_meal(weekDay: WeekDay.saturday, mealType: MealType.lunch)],
            ),
          ],
        ),
      );

      expect(document.trips.single.ingredients.single.meals.single.dayLabel, "Saturday");
    });

    test("writes no meal for an ingredient that no meal of the menu needs", () {
      ShoppingPdfDocument document = _document(
        ingredients: const [Ingredient(id: "n2", name: "Salt")],
        remaining: const {
          "n2": [Quantity(amount: 5, unit: Unit.grams)],
        },
      );

      expect(document.trips.single.ingredients.single.meals, isEmpty);
    });
  });
}
