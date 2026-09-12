import "package:flutter_test/flutter_test.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/recipes/enums/unit.dart";
import "package:menu_management/recipes/models/quantity.dart";
import "package:menu_management/shopping/multi_trip_planner.dart";
import "package:menu_management/shopping/owned_amount.dart";
import "package:menu_management/shopping/shopping_copy_text.dart";

// 500 grams per pack (2 items x 250 grams). Different links -> variety variants of the same size.
Product _equivProduct(String link) => Product(link: link, quantityPerItem: 250, itemsPerPack: 2, unit: Unit.grams);

void main() {
  group("buildIngredientCopyLines equivalent-product distribution", () {
    test("spreads packs one-of-each across equivalent products instead of full count each", () {
      Ingredient ingredient = Ingredient(id: "pizza", name: "Pizza", products: [_equivProduct("a"), _equivProduct("b"), _equivProduct("c")]);

      // Need 1500 g -> 3 packs total -> 1 pack per variant.
      String text = buildIngredientCopyLines(
        ingredient: ingredient,
        remaining: const [Quantity(amount: 1500, unit: Unit.grams)],
      );

      expect(text.split("\n"), const [
        "Pizza",
        "  2x250grams: 1 pack",
        "    a",
        "  2x250grams: 1 pack",
        "    b",
        "  2x250grams: 1 pack",
        "    c",
        "",
      ]);
    });

    test("drops the trailing zero-share variant when packs are fewer than the group", () {
      Ingredient ingredient = Ingredient(id: "pizza", name: "Pizza", products: [_equivProduct("a"), _equivProduct("b"), _equivProduct("c")]);

      // Need 1000 g -> 2 packs total -> [1, 1, 0]: only two lines, the zero is skipped.
      String text = buildIngredientCopyLines(
        ingredient: ingredient,
        remaining: const [Quantity(amount: 1000, unit: Unit.grams)],
      );

      // Variant "c" gets zero packs, so it writes neither a pack line nor an orphan link line.
      expect(text.split("\n"), const ["Pizza", "  2x250grams: 1 pack", "    a", "  2x250grams: 1 pack", "    b", ""]);
    });

    test("waste-minimal mix lists each distinct pack size with its own count", () {
      Product small = const Product(link: "small", quantityPerItem: 250, itemsPerPack: 2, unit: Unit.grams); // 500 g
      Product big = const Product(link: "big", quantityPerItem: 250, itemsPerPack: 3, unit: Unit.grams); // 750 g
      Ingredient ingredient = Ingredient(id: "flour", name: "Flour", products: [small, big]);

      // The copy now shows the waste-minimal pack mix (issue #26), not every product's solo count.
      // Need 1250 g: the only zero-waste mix is 1 small (500) + 1 big (750). Different pack sizes are
      // separate equivalence groups, so neither is spread one-of-each; each lists its own count.
      String text = buildIngredientCopyLines(
        ingredient: ingredient,
        remaining: const [Quantity(amount: 1250, unit: Unit.grams)],
      );

      expect(text.split("\n"), const ["Flour", "  2x250grams: 1 pack", "    small", "  3x250grams: 1 pack", "    big", ""]);
    });

    test("lists the one unit that the page already rounded a sub-unit need up to", () {
      // A pinch of salt is still on the shopping list. computeRemainingQuantities rounds 0.4
      // teaspoons up to 1 before the copy runs, so this function only writes the whole number.
      Ingredient salt = const Ingredient(id: "salt", name: "Salt");

      String text = buildIngredientCopyLines(
        ingredient: salt,
        remaining: [Quantity(amount: roundNeededAmount(0.4), unit: Unit.teaspoons)],
      );

      expect(text, "Salt: 1 teaspoons\n");
    });

    test("writes nothing for an ingredient that the user already owns", () {
      Ingredient salt = const Ingredient(id: "salt", name: "Salt");

      String text = buildIngredientCopyLines(
        ingredient: salt,
        remaining: const [Quantity(amount: 0, unit: Unit.teaspoons)],
      );

      expect(text, "");
    });
  });

  group("copy text ingredient order", () {
    // Four ingredients with no products, given in an order that is not alphabetical. The mixed
    // upper and lower case proves the sort ignores case.
    List<Ingredient> unsortedIngredients() => const [
      Ingredient(id: "zucchini", name: "zucchini"),
      Ingredient(id: "apple", name: "Apple"),
      Ingredient(id: "banana", name: "banana"),
      Ingredient(id: "carrot", name: "Carrot"),
    ];

    Map<String, List<Quantity>> remainingPerIngredient() => const {
      "zucchini": [Quantity(amount: 200, unit: Unit.grams)],
      "apple": [Quantity(amount: 100, unit: Unit.grams)],
      "banana": [Quantity(amount: 300, unit: Unit.grams)],
      "carrot": [Quantity(amount: 400, unit: Unit.grams)],
    };

    List<String> expectedLines() => const ["Apple: 100 grams", "banana: 300 grams", "Carrot: 400 grams", "zucchini: 200 grams"];

    List<ShoppingTrip> singleTrip() => const [
      ShoppingTrip(
        weekIndex: 0,
        items: [
          TripItem(ingredientId: "zucchini", amount: 200, unit: Unit.grams),
          TripItem(ingredientId: "apple", amount: 100, unit: Unit.grams),
          TripItem(ingredientId: "banana", amount: 300, unit: Unit.grams),
          TripItem(ingredientId: "carrot", amount: 400, unit: Unit.grams),
        ],
      ),
    ];

    test("the single list writes every ingredient once, sorted by name", () {
      String text = buildSingleListCopyText(ingredients: unsortedIngredients(), remainingByIngredientId: remainingPerIngredient());

      expect(text.split("\n"), expectedLines());
    });

    test("the per-trip list writes every ingredient once under its trip header, sorted by name", () {
      String text = buildMultiTripCopyText(
        ingredients: unsortedIngredients(),
        remainingByIngredientId: remainingPerIngredient(),
        trips: singleTrip(),
        tripLabel: (ShoppingTrip trip) => "Week ${trip.weekIndex}",
      );

      expect(text.split("\n"), ["Week 0", "------", ...expectedLines()]);
    });

    test("both paths order the same menu the same way", () {
      // One menu must never produce two different ingredient orders.
      String single = buildSingleListCopyText(ingredients: unsortedIngredients(), remainingByIngredientId: remainingPerIngredient());
      String perTrip = buildMultiTripCopyText(
        ingredients: unsortedIngredients(),
        remainingByIngredientId: remainingPerIngredient(),
        trips: singleTrip(),
        tripLabel: (ShoppingTrip trip) => "Week ${trip.weekIndex}",
      );

      // Only a top-level line names an ingredient. A pack line starts with two spaces.
      List<String> namesOf(String text) => text
          .split("\n")
          .where((String line) => !line.startsWith(" ") && line.contains(":"))
          .map((String line) => line.split(":").first.trim())
          .toList();

      expect(namesOf(single), const ["Apple", "banana", "Carrot", "zucchini"]);
      expect(namesOf(perTrip), namesOf(single));
    });

    test("writes the same per-trip packs the page shows, with the product name and link", () {
      // Pairs with "splits the page total the same way the copied list splits it" in
      // shopping_ingredient_test. Both read distributeRemainingAcrossTrips, so the numbers match.
      // The link is a real store link, so this also pins the name line and the link line inside a
      // trip section, which is the path that the shopping page calls.
      Ingredient beans = const Ingredient(
        id: "beans",
        name: "Beans",
        products: [Product(link: "https://tienda.mercadona.es/product/1234/alubias-cocidas", quantityPerItem: 50, itemsPerPack: 2, unit: Unit.grams)],
      );

      String text = buildMultiTripCopyText(
        ingredients: [beans],
        remainingByIngredientId: const {
          "beans": [Quantity(amount: 600, unit: Unit.grams)],
        },
        trips: const [
          ShoppingTrip(
            weekIndex: 0,
            items: [TripItem(ingredientId: "beans", amount: 500, unit: Unit.grams)],
          ),
          ShoppingTrip(
            weekIndex: 1,
            items: [TripItem(ingredientId: "beans", amount: 100, unit: Unit.grams)],
          ),
        ],
        tripLabel: (ShoppingTrip trip) => "Week ${trip.weekIndex}",
      );

      expect(text.split("\n"), const [
        "Week 0",
        "------",
        "Beans",
        "  Alubias cocidas (2x50grams): 5 packs",
        "    https://tienda.mercadona.es/product/1234/alubias-cocidas",
        "",
        "Week 1",
        "------",
        "Beans",
        "  Alubias cocidas (2x50grams): 1 pack",
        "    https://tienda.mercadona.es/product/1234/alubias-cocidas",
      ]);
    });

    test("the name filter of the order test does not count a pack line as a name", () {
      // Guards the namesOf helper above: a product line is indented and must not read as a name.
      Ingredient pizza = Ingredient(id: "pizza", name: "Pizza", products: [_equivProduct("a")]);

      String text = buildSingleListCopyText(
        ingredients: [pizza],
        remainingByIngredientId: const {
          "pizza": [Quantity(amount: 500, unit: Unit.grams)],
        },
      );

      expect(text.split("\n"), const ["Pizza", "  2x250grams: 1 pack", "    a"]);
    });
  });

  group("remainingForCopy", () {
    test("returns the amounts that the map holds for the ingredient", () {
      const Ingredient salt = Ingredient(id: "salt", name: "Salt");

      List<Quantity> remaining = remainingForCopy(
        ingredient: salt,
        remainingByIngredientId: const {
          "salt": [Quantity(amount: 2, unit: Unit.teaspoons)],
        },
      );

      expect(remaining, const [Quantity(amount: 2, unit: Unit.teaspoons)]);
    });

    test("reads an ingredient with no key as covered, and does not throw", () {
      // The copy button must never crash on a map gap. The warning goes to the log; the caller
      // gets an empty list, so the ingredient copies as covered.
      const Ingredient salt = Ingredient(id: "salt", name: "Salt");

      expect(remainingForCopy(ingredient: salt, remainingByIngredientId: const {}), isEmpty);
    });
  });

  group("buildSimplifiedShoppingCopyText", () {
    test("writes one line per ingredient with the amount and nothing else", () {
      Ingredient pizza = Ingredient(id: "pizza", name: "Pizza", products: [_equivProduct("a")]);
      Ingredient apple = const Ingredient(id: "apple", name: "Apple");

      String text = buildSimplifiedShoppingCopyText(
        ingredients: [pizza, apple],
        remainingByIngredientId: const {
          "pizza": [Quantity(amount: 500, unit: Unit.grams)],
          "apple": [Quantity(amount: 3, unit: Unit.pieces)],
        },
      );

      // The list is sorted by name and holds no pack line: the amount is all it shows.
      expect(text.split("\n"), const ["Apple: 3 pieces", "Pizza: 500 grams"]);
    });

    test("joins the two units of one ingredient in one line", () {
      const Ingredient milk = Ingredient(id: "milk", name: "Milk");

      String text = buildSimplifiedShoppingCopyText(
        ingredients: const [milk],
        remainingByIngredientId: const {
          "milk": [Quantity(amount: 500, unit: Unit.centiliters), Quantity(amount: 2, unit: Unit.pieces)],
        },
      );

      expect(text.split("\n"), const ["Milk: 500 centiliters + 2 pieces"]);
    });

    test("leaves out an ingredient that the user already owns", () {
      const Ingredient milk = Ingredient(id: "milk", name: "Milk");
      const Ingredient rice = Ingredient(id: "rice", name: "Rice");

      String text = buildSimplifiedShoppingCopyText(
        ingredients: const [milk, rice],
        remainingByIngredientId: const {
          "milk": [Quantity(amount: 0, unit: Unit.centiliters)],
          "rice": [Quantity(amount: 200, unit: Unit.grams)],
        },
      );

      expect(text.split("\n"), const ["Rice: 200 grams"]);
    });

    test("keeps the freeze-on-arrival warning of the ingredients that the plan freezes", () {
      // In one-trip mode the plan only works if the user freezes these items on the trip day.
      // A simplified list without the warning cannot be followed safely.
      const Ingredient peas = Ingredient(id: "peas", name: "Peas");
      const Ingredient rice = Ingredient(id: "rice", name: "Rice");

      String text = buildSimplifiedShoppingCopyText(
        ingredients: const [peas, rice],
        remainingByIngredientId: const {
          "peas": [Quantity(amount: 500, unit: Unit.grams)],
          "rice": [Quantity(amount: 200, unit: Unit.grams)],
        },
        freezeOnArrivalIngredientIds: const {"peas"},
      );

      expect(text.split("\n"), const ["Peas: 500 grams (freeze on arrival)", "Rice: 200 grams"]);
    });

    test("throws on a fractional amount, the same way the detailed list does", () {
      // Both builders take the same input shape. Without this guard a caller that skips
      // roundNeededAmount fails loudly on Detailed and prints "0.4 grams" on Simplified.
      const Ingredient rice = Ingredient(id: "rice", name: "Rice");

      expect(
        () => buildSimplifiedShoppingCopyText(
          ingredients: const [rice],
          remainingByIngredientId: const {
            "rice": [Quantity(amount: 0.4, unit: Unit.grams)],
          },
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group("computeFreezeOnArrivalIngredientIds", () {
    test("names every ingredient that the plan freezes, and no other one", () {
      // The peas ride trip 0 and must be frozen; the rice is bought on the trip of its own week.
      const Ingredient peas = Ingredient(
        id: "peas",
        name: "Peas",
        products: [Product(link: "", quantityPerItem: 500, unit: Unit.grams, shelfLifeDaysClosed: 3, canBeFrozen: true)],
      );
      const Ingredient rice = Ingredient(id: "rice", name: "Rice");

      List<ShoppingTrip> trips = const [
        ShoppingTrip(
          weekIndex: 0,
          items: [
            TripItem(ingredientId: "peas", amount: 500, unit: Unit.grams, freezeOnArrival: true),
            TripItem(ingredientId: "rice", amount: 200, unit: Unit.grams),
          ],
        ),
      ];

      Set<String> frozen = computeFreezeOnArrivalIngredientIds(
        ingredients: const [peas, rice],
        remainingByIngredientId: const {
          "peas": [Quantity(amount: 500, unit: Unit.grams)],
          "rice": [Quantity(amount: 200, unit: Unit.grams)],
        },
        trips: trips,
      );

      expect(frozen, const {"peas"});
    });

    test("names an ingredient that one trip freezes and another trip does not", () {
      // The peas ride two trips: the batch of trip 0 must wait in the freezer, the batch of the
      // later trip does not. The simplified list holds no trip, so its reader buys both batches on
      // day one. The later batch then also has to wait, and only the freezer keeps it. So one
      // frozen batch marks the whole line.
      const Ingredient peas = Ingredient(
        id: "peas",
        name: "Peas",
        products: [Product(link: "", quantityPerItem: 500, unit: Unit.grams, shelfLifeDaysClosed: 3, canBeFrozen: true)],
      );

      List<ShoppingTrip> trips = const [
        ShoppingTrip(
          weekIndex: 0,
          items: [TripItem(ingredientId: "peas", amount: 500, unit: Unit.grams, freezeOnArrival: true)],
        ),
        ShoppingTrip(
          weekIndex: 1,
          items: [TripItem(ingredientId: "peas", amount: 300, unit: Unit.grams)],
        ),
      ];

      Set<String> frozen = computeFreezeOnArrivalIngredientIds(
        ingredients: const [peas],
        remainingByIngredientId: const {
          "peas": [Quantity(amount: 800, unit: Unit.grams)],
        },
        trips: trips,
      );

      expect(frozen, const {"peas"});
    });

    test("names nothing when the planner planned no trip", () {
      const Ingredient rice = Ingredient(id: "rice", name: "Rice");

      expect(
        computeFreezeOnArrivalIngredientIds(
          ingredients: const [rice],
          remainingByIngredientId: const {
            "rice": [Quantity(amount: 200, unit: Unit.grams)],
          },
          trips: const [],
        ),
        isEmpty,
      );
    });
  });

  group("buildIngredientCopyLines with a real product of the recipe book", () {
    test("writes the name, the pack size, the pack count and the link of a real store product", () {
      // The ingredient, the link and the pack come word for word from assets/RecipeBook.tsr, so
      // this test shows the shape that the user really reads.
      const Ingredient milk = Ingredient(
        id: "34d2c7b0-8478-1e99-9cbf-85317f03e969",
        name: "Leche desnatada sin lactosa",
        density: 1.03,
        products: [
          Product(
            link: "https://tienda.mercadona.es/product/10730/leche-desnatada-sin-lactosa-hacendado-pack-6",
            itemsPerPack: 6,
            quantityPerItem: 100,
            unit: Unit.centiliters,
            shelfLifeDaysOpened: 3,
            shelfLifeDaysClosed: 365,
          ),
        ],
      );

      String text = buildIngredientCopyLines(
        ingredient: milk,
        remaining: const [Quantity(amount: 800, unit: Unit.centiliters)],
      );

      expect(text.split("\n"), const [
        "Leche desnatada sin lactosa",
        "  Leche desnatada sin lactosa hacendado pack 6 (6x100centiliters): 2 packs",
        "    https://tienda.mercadona.es/product/10730/leche-desnatada-sin-lactosa-hacendado-pack-6",
        "",
      ]);
    });
  });

  group("buildIngredientCopyLines product name", () {
    test("names the product before its pack size", () {
      // A single-item weight product has no pack label, so without the name the line would read
      // "  1,000 grams/pack: 1 pack". A person in the shop cannot use that.
      const Ingredient bread = Ingredient(
        id: "bread",
        name: "Bread",
        products: [Product(link: "https://tienda.mercadona.es/product/20559/pan-de-molde-integral", quantityPerItem: 1000, unit: Unit.grams)],
      );

      String text = buildIngredientCopyLines(
        ingredient: bread,
        remaining: const [Quantity(amount: 1000, unit: Unit.grams)],
      );

      expect(text.split("\n"), const [
        "Bread",
        "  Pan de molde integral (1,000 grams/pack): 1 pack",
        "    https://tienda.mercadona.es/product/20559/pan-de-molde-integral",
        "",
      ]);
    });

    test("writes only the pack size when the link names no product", () {
      const Ingredient bread = Ingredient(
        id: "bread",
        name: "Bread",
        products: [Product(link: "https://shop.example/bread", quantityPerItem: 1000, unit: Unit.grams)],
      );

      String text = buildIngredientCopyLines(
        ingredient: bread,
        remaining: const [Quantity(amount: 1000, unit: Unit.grams)],
      );

      expect(text.split("\n"), const ["Bread", "  1,000 grams/pack: 1 pack", "    https://shop.example/bread", ""]);
    });
  });

  group("buildIngredientCopyLines product link", () {
    test("writes the store link under the pack line of the product", () {
      Ingredient pizza = Ingredient(id: "pizza", name: "Pizza", products: [_equivProduct("https://shop.example/pizza")]);

      String text = buildIngredientCopyLines(
        ingredient: pizza,
        remaining: const [Quantity(amount: 500, unit: Unit.grams)],
      );

      expect(text.split("\n"), const ["Pizza", "  2x250grams: 1 pack", "    https://shop.example/pizza", ""]);
    });

    test("writes no link line for a product without a link", () {
      Ingredient pizza = Ingredient(id: "pizza", name: "Pizza", products: [_equivProduct("")]);

      String text = buildIngredientCopyLines(
        ingredient: pizza,
        remaining: const [Quantity(amount: 500, unit: Unit.grams)],
      );

      expect(text.split("\n"), const ["Pizza", "  2x250grams: 1 pack", ""]);
    });
  });
}
