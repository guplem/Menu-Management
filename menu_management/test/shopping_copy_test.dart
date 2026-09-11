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

int _count(String haystack, String needle) => needle.isEmpty ? 0 : haystack.split(needle).length - 1;

void main() {
  group("buildIngredientCopyLines equivalent-product distribution", () {
    test("spreads packs one-of-each across equivalent products instead of full count each", () {
      Ingredient ingredient = Ingredient(id: "pizza", name: "Pizza", products: [_equivProduct("a"), _equivProduct("b"), _equivProduct("c")]);

      // Need 1500 g -> 3 packs total -> 1 pack per variant.
      String text = buildIngredientCopyLines(
        ingredient: ingredient,
        remaining: const [Quantity(amount: 1500, unit: Unit.grams)],
      );

      expect(_count(text, "2x250grams: 1 pack"), 3);
      expect(text.contains("3 pack"), isFalse);
    });

    test("drops the trailing zero-share variant when packs are fewer than the group", () {
      Ingredient ingredient = Ingredient(id: "pizza", name: "Pizza", products: [_equivProduct("a"), _equivProduct("b"), _equivProduct("c")]);

      // Need 1000 g -> 2 packs total -> [1, 1, 0]: only two lines, the zero is skipped.
      String text = buildIngredientCopyLines(
        ingredient: ingredient,
        remaining: const [Quantity(amount: 1000, unit: Unit.grams)],
      );

      expect(_count(text, "2x250grams: 1 pack"), 2);
      expect(text.contains(": 0 pack"), isFalse);
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

      expect(text.contains("2x250grams: 1 pack"), isTrue);
      expect(text.contains("3x250grams: 1 pack"), isTrue);
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

    test("writes the same per-trip packs the page shows", () {
      // Pairs with "splits the page total the same way the copied list splits it" in
      // shopping_ingredient_test. Both read distributeRemainingAcrossTrips, so the numbers match.
      Ingredient beans = const Ingredient(
        id: "beans",
        name: "Beans",
        products: [Product(link: "", quantityPerItem: 50, itemsPerPack: 2, unit: Unit.grams)],
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

      expect(text.split("\n"), const ["Week 0", "------", "Beans", "  2x50grams: 5 packs", "", "Week 1", "------", "Beans", "  2x50grams: 1 pack"]);
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
