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
import "package:menu_management/shopping/cooking_timeline.dart";
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

/// One menu of two weeks. Each week cooks the same recipe once, so each week needs the same amount.
MultiWeekMenu _twoWeekMenu() => MultiWeekMenu(
  startDate: DateTime(2025, 8, 6),
  weeks: [
    Menu(
      meals: [_meal(weekDay: WeekDay.saturday, mealType: MealType.lunch)],
    ),
    Menu(
      meals: [_meal(weekDay: WeekDay.saturday, mealType: MealType.lunch)],
    ),
  ],
);

/// One trip per week, each trip carrying the same amount of the noodles. Each trip buys the
/// Saturday of its own week: day 0 and day 7 of [_twoWeekMenu].
const List<ShoppingTrip> _tripPerWeek = [
  ShoppingTrip(
    weekIndex: 0,
    items: [
      TripItem(ingredientId: "n1", amount: 250, unit: Unit.grams, cookDays: {0}),
    ],
  ),
  ShoppingTrip(
    weekIndex: 1,
    items: [
      TripItem(ingredientId: "n1", amount: 250, unit: Unit.grams, cookDays: {7}),
    ],
  ),
];

/// Builds a document with the defaults that most tests share: one menu, one ingredient and no trip.
ShoppingPdfDocument _document({
  List<Ingredient> ingredients = const [_noodles],
  Map<String, List<Quantity>> remaining = const {
    "n1": [Quantity(amount: 500, unit: Unit.grams)],
  },
  List<ShoppingTrip> trips = const [],
  MultiWeekMenu? multiWeekMenu,
  List<Recipe>? recipes,
  Map<String, List<CookingEvent>> cookingTimeline = const {},
}) {
  return buildShoppingPdfDocument(
    ingredients: ingredients,
    remainingByIngredientId: remaining,
    trips: trips,
    tripLabel: (ShoppingTrip trip) => "Trip of week ${trip.weekIndex + 1}",
    multiWeekMenu: multiWeekMenu ?? _menu(),
    recipes: recipes ?? [_pasta()],
    cookingTimeline: cookingTimeline,
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

    test("writes one untitled empty section when the trips are planned but the user owns everything", () {
      ShoppingPdfDocument document = _document(
        trips: _tripPerWeek,
        remaining: const {
          "n1": [Quantity(amount: 0, unit: Unit.grams)],
        },
      );

      expect(document.trips.length, 1);
      expect(document.trips.single.title, "");
      expect(document.trips.single.ingredients, isEmpty);
    });

    test("names the document after the days that the menu covers", () {
      expect(_document().title, "Shopping list 6 Aug - 12 Aug");
      expect(_document(multiWeekMenu: const MultiWeekMenu(weeks: [Menu()])).title, "Shopping list");
    });
  });

  group("buildShoppingPdfDocument products", () {
    test("lists every product that matches the unit with the packs of buying only that product", () {
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
        // One pack of 500 grams and two packs of 250 grams both cover 500 grams and waste nothing,
        // so both carry the mark.
        ShoppingPdfProductOption(label: "250 grams/pack", link: "", packs: 2, isRecommended: true),
      ]);
    });

    test("writes no product option for an ingredient that has none, so its line still shows the amount", () {
      ShoppingPdfIngredientEntry entry = _document().trips.single.ingredients.single;

      expect(entry.products, isEmpty);
      expect(entry.amounts, "500 grams");
    });

    test("marks every product that ties for the least waste, the same rule that the shopping page follows", () {
      Ingredient noodles = const Ingredient(
        id: "n1",
        name: "Noodles",
        products: [
          Product(link: "https://tienda.mercadona.es/product/1/espaguetis", quantityPerItem: 500, unit: Unit.grams),
          Product(link: "https://tienda.mercadona.es/product/1/espaguetis", quantityPerItem: 500, unit: Unit.grams),
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
        ShoppingPdfProductOption(
          label: "Espaguetis (500 grams/pack)",
          link: "https://tienda.mercadona.es/product/1/espaguetis",
          packs: 1,
          isRecommended: true,
        ),
      ]);
    });

    test("writes no option for a product whose pack holds nothing, because 0 packs buys nothing", () {
      Ingredient noodles = const Ingredient(
        id: "n1",
        name: "Noodles",
        products: [
          Product(link: "", quantityPerItem: 0, unit: Unit.grams),
          Product(link: "", quantityPerItem: 500, unit: Unit.grams),
        ],
      );

      ShoppingPdfDocument document = _document(ingredients: [noodles]);

      expect(document.trips.single.ingredients.single.products, const [
        ShoppingPdfProductOption(label: "500 grams/pack", link: "", packs: 1, isRecommended: true),
      ]);
    });

    test("ranks the products of one trip on the cooking events of that trip alone, not on the whole menu", () {
      Ingredient noodles = const Ingredient(
        id: "n1",
        name: "Noodles",
        products: [
          // Opened on the cooking day of week 1, this pack is past its shelf life by week 2. Over
          // the whole menu it therefore wastes more than the bigger pack; over one trip it wastes
          // less. The mark says which pack the reader of that one section buys.
          Product(link: "", quantityPerItem: 300, unit: Unit.grams, shelfLifeDaysOpened: 1),
          Product(link: "", quantityPerItem: 320, unit: Unit.grams),
        ],
      );

      ShoppingPdfDocument document = _document(
        ingredients: [noodles],
        remaining: const {
          "n1": [Quantity(amount: 500, unit: Unit.grams)],
        },
        trips: _tripPerWeek,
        multiWeekMenu: _twoWeekMenu(),
        cookingTimeline: const {
          "n1": [
            CookingEvent(dayIndex: 0, quantities: [Quantity(amount: 250, unit: Unit.grams)]),
            CookingEvent(dayIndex: 7, quantities: [Quantity(amount: 250, unit: Unit.grams)]),
          ],
        },
      );

      expect(document.trips.first.ingredients.single.products, const [
        ShoppingPdfProductOption(label: "300 grams/pack", link: "", packs: 1, isRecommended: true),
        ShoppingPdfProductOption(label: "320 grams/pack", link: "", packs: 1, isRecommended: false),
      ]);
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

    test("writes the amount of a meal in the unit of the amount to buy, so the reader can compare the two", () {
      const Recipe dressing = Recipe(
        id: "r1",
        name: "Dressing",
        instructions: [
          Instruction(
            id: "i1",
            description: "Pour the oil.",
            ingredientsUsed: [
              IngredientUsage(
                ingredient: "o1",
                quantity: Quantity(amount: 3, unit: Unit.tablespoons),
              ),
            ],
          ),
        ],
      );
      // The screen turns 6 tablespoons into 90 millilitres, then into 81 grams through the
      // density. The amount to buy reads grams, so the meal line must read grams too.
      const Ingredient oil = Ingredient(
        id: "o1",
        name: "Olive oil",
        density: 0.9,
        products: [Product(link: "", quantityPerItem: 1000, unit: Unit.grams)],
      );

      ShoppingPdfDocument document = _document(
        ingredients: const [oil],
        remaining: const {
          "o1": [Quantity(amount: 81, unit: Unit.grams)],
        },
        multiWeekMenu: MultiWeekMenu(
          startDate: DateTime(2025, 8, 6),
          weeks: [
            Menu(
              meals: [_meal(weekDay: WeekDay.saturday, mealType: MealType.lunch)],
            ),
          ],
        ),
        recipes: const [dressing],
      );

      expect(document.trips.single.ingredients.single.amounts, "81 grams");
      expect(document.trips.single.ingredients.single.meals, const [
        ShoppingPdfMealNeed(
          weekLabel: "Week 1",
          dayLabel: "Wednesday 6 Aug",
          mealName: "Lunch",
          recipeName: "Dressing",
          people: 2,
          isCookEvent: true,
          amounts: "81 grams",
        ),
      ]);
    });

    test("keeps in each trip section only the meals of the weeks that the trip buys for", () {
      ShoppingPdfDocument document = _document(
        remaining: const {
          "n1": [Quantity(amount: 400, unit: Unit.grams)],
        },
        trips: _tripPerWeek,
        multiWeekMenu: _twoWeekMenu(),
      );

      expect(document.trips.map((ShoppingPdfTripSection section) => section.ingredients.single.amounts).toList(), ["200 grams", "200 grams"]);
      expect(document.trips.first.ingredients.single.meals, const [
        ShoppingPdfMealNeed(
          weekLabel: "Week 1",
          dayLabel: "Wednesday 6 Aug",
          mealName: "Lunch",
          recipeName: "Pasta",
          people: 2,
          isCookEvent: true,
          amounts: "200 grams",
        ),
      ]);
      expect(document.trips.last.ingredients.single.meals, const [
        ShoppingPdfMealNeed(
          weekLabel: "Week 2",
          dayLabel: "Wednesday 13 Aug",
          mealName: "Lunch",
          recipeName: "Pasta",
          people: 2,
          isCookEvent: true,
          amounts: "200 grams",
        ),
      ]);
    });

    test("lists a leftover meal of the next week under the trip that buys its cook event", () {
      // The cook event on the Friday of week 1 cooks the food of the Saturday of week 2 too.
      // The trip of week 1 buys that food, so the trip of week 1 must justify it.
      MultiWeekMenu multiWeek = MultiWeekMenu(
        startDate: DateTime(2025, 8, 6),
        weeks: [
          Menu(
            meals: [_meal(weekDay: WeekDay.friday, mealType: MealType.dinner, yield: 2)],
          ),
          Menu(
            meals: [
              _meal(weekDay: WeekDay.saturday, mealType: MealType.lunch, yield: 0),
              _meal(weekDay: WeekDay.wednesday, mealType: MealType.lunch),
            ],
          ),
        ],
      );
      // The Friday cook of week 1 is day 6, and the Wednesday cook of week 2 is day 11.
      const List<ShoppingTrip> trips = [
        ShoppingTrip(
          weekIndex: 0,
          items: [
            TripItem(ingredientId: "n1", amount: 400, unit: Unit.grams, cookDays: {6}),
          ],
        ),
        ShoppingTrip(
          weekIndex: 1,
          items: [
            TripItem(ingredientId: "n1", amount: 200, unit: Unit.grams, cookDays: {11}),
          ],
        ),
      ];

      ShoppingPdfDocument document = _document(
        remaining: const {
          "n1": [Quantity(amount: 600, unit: Unit.grams)],
        },
        trips: trips,
        multiWeekMenu: multiWeek,
      );

      expect(document.trips.map((ShoppingPdfTripSection section) => section.ingredients.single.amounts).toList(), ["400 grams", "200 grams"]);
      expect(document.trips.first.ingredients.single.meals, const [
        ShoppingPdfMealNeed(
          weekLabel: "Week 1",
          dayLabel: "Tuesday 12 Aug",
          mealName: "Dinner",
          recipeName: "Pasta",
          people: 2,
          isCookEvent: true,
          amounts: "200 grams",
        ),
        ShoppingPdfMealNeed(
          weekLabel: "Week 2",
          dayLabel: "Wednesday 13 Aug",
          mealName: "Lunch",
          recipeName: "Pasta",
          people: 2,
          isCookEvent: false,
          amounts: "200 grams",
        ),
      ]);
      expect(document.trips.last.ingredients.single.meals, const [
        ShoppingPdfMealNeed(
          weekLabel: "Week 2",
          dayLabel: "Sunday 17 Aug",
          mealName: "Lunch",
          recipeName: "Pasta",
          people: 2,
          isCookEvent: true,
          amounts: "200 grams",
        ),
      ]);
    });

    test("lists every meal that a trip buys for, also a meal of a later week that the trip buys because the item keeps", () {
      // Noodles keep forever, so the planner buys the noodles of both weeks on the first trip.
      // Lettuce keeps 3 days, so the planner adds a second trip for the lettuce of week 2.
      const Ingredient noodles = Ingredient(
        id: "n1",
        name: "Noodles",
        products: [Product(link: "", quantityPerItem: 500, unit: Unit.grams)],
      );
      const Ingredient lettuce = Ingredient(
        id: "n2",
        name: "Lettuce",
        products: [Product(link: "", quantityPerItem: 1, unit: Unit.pieces, shelfLifeDaysClosed: 3)],
      );
      const Recipe salad = Recipe(
        id: "r1",
        name: "Pasta salad",
        instructions: [
          Instruction(
            id: "i1",
            description: "Mix.",
            ingredientsUsed: [
              IngredientUsage(
                ingredient: "n1",
                quantity: Quantity(amount: 100, unit: Unit.grams),
              ),
              IngredientUsage(
                ingredient: "n2",
                quantity: Quantity(amount: 1, unit: Unit.pieces),
              ),
            ],
          ),
        ],
      );
      MultiWeekMenu multiWeek = _twoWeekMenu();
      Map<String, List<CookingEvent>> timeline = buildCookingTimeline(multiWeekMenu: multiWeek, recipes: const [salad]);
      List<ShoppingTrip> trips = planShoppingTrips(cookingTimeline: timeline, ingredients: const [noodles, lettuce]);

      ShoppingPdfDocument document = _document(
        ingredients: const [noodles, lettuce],
        remaining: const {
          "n1": [Quantity(amount: 400, unit: Unit.grams)],
          "n2": [Quantity(amount: 4, unit: Unit.pieces)],
        },
        trips: trips,
        multiWeekMenu: multiWeek,
        recipes: const [salad],
        cookingTimeline: timeline,
      );

      ShoppingPdfIngredientEntry firstTripNoodles = document.trips.first.ingredients.firstWhere(
        (ShoppingPdfIngredientEntry entry) => entry.ingredientName == "Noodles",
      );
      expect(firstTripNoodles.amounts, "400 grams");
      expect(firstTripNoodles.meals, const [
        ShoppingPdfMealNeed(
          weekLabel: "Week 1",
          dayLabel: "Wednesday 6 Aug",
          mealName: "Lunch",
          recipeName: "Pasta salad",
          people: 2,
          isCookEvent: true,
          amounts: "200 grams",
        ),
        ShoppingPdfMealNeed(
          weekLabel: "Week 2",
          dayLabel: "Wednesday 13 Aug",
          mealName: "Lunch",
          recipeName: "Pasta salad",
          people: 2,
          isCookEvent: true,
          amounts: "200 grams",
        ),
      ]);
    });

    test("lists a meal that the owned stock covers under the first trip that buys the ingredient", () {
      // The user owns the noodles of week 1, so the planner buys only the noodles of day 7. The
      // meal of week 1 still needs the food, and the list shows the whole need.
      const List<ShoppingTrip> trips = [
        ShoppingTrip(
          weekIndex: 1,
          items: [
            TripItem(ingredientId: "n1", amount: 200, unit: Unit.grams, cookDays: {7}),
          ],
        ),
      ];

      ShoppingPdfDocument document = _document(
        remaining: const {
          "n1": [Quantity(amount: 200, unit: Unit.grams)],
        },
        trips: trips,
        multiWeekMenu: _twoWeekMenu(),
      );

      expect(document.trips.single.ingredients.single.meals, const [
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
          weekLabel: "Week 2",
          dayLabel: "Wednesday 13 Aug",
          mealName: "Lunch",
          recipeName: "Pasta",
          people: 2,
          isCookEvent: true,
          amounts: "200 grams",
        ),
      ]);
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
