import "package:flutter_test/flutter_test.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/recipes/enums/unit.dart";
import "package:menu_management/recipes/models/quantity.dart";
import "package:menu_management/shopping/multi_trip_planner.dart";
import "package:menu_management/shopping/shopping_page.dart";

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

    test("lists an ingredient whose need is below one unit", () {
      // A pinch of salt is still on the shopping list. The old rounding dropped the line.
      Ingredient salt = const Ingredient(id: "salt", name: "Salt");

      String text = buildIngredientCopyLines(
        ingredient: salt,
        remaining: const [Quantity(amount: 0.4, unit: Unit.teaspoons)],
      );

      expect(text.contains("Salt: 1 teaspoons"), isTrue);
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
    // Two ingredients with no products, given in an order that is not alphabetical.
    List<Ingredient> unsortedIngredients() => const [Ingredient(id: "zucchini", name: "Zucchini"), Ingredient(id: "apple", name: "Apple")];

    Map<String, List<Quantity>> remainingPerIngredient() => const {
      "zucchini": [Quantity(amount: 200, unit: Unit.grams)],
      "apple": [Quantity(amount: 100, unit: Unit.grams)],
    };

    test("the single list sorts the ingredients by name", () {
      String text = buildSingleListCopyText(ingredients: unsortedIngredients(), remainingByIngredientId: remainingPerIngredient());

      expect(text.indexOf("Apple") < text.indexOf("Zucchini"), isTrue);
    });

    test("the per-trip list sorts the ingredients by name", () {
      List<ShoppingTrip> trips = const [
        ShoppingTrip(
          weekIndex: 0,
          items: [
            TripItem(ingredientId: "zucchini", amount: 200, unit: Unit.grams),
            TripItem(ingredientId: "apple", amount: 100, unit: Unit.grams),
          ],
        ),
      ];

      String text = buildMultiTripCopyText(
        ingredients: unsortedIngredients(),
        remainingByIngredientId: remainingPerIngredient(),
        trips: trips,
        tripLabel: (ShoppingTrip trip) => "Week ${trip.weekIndex}",
      );

      expect(text.indexOf("Apple") < text.indexOf("Zucchini"), isTrue);
    });

    test("both paths order the same menu the same way", () {
      // One menu must never produce two different ingredient orders.
      List<ShoppingTrip> trips = const [
        ShoppingTrip(
          weekIndex: 0,
          items: [
            TripItem(ingredientId: "zucchini", amount: 200, unit: Unit.grams),
            TripItem(ingredientId: "apple", amount: 100, unit: Unit.grams),
          ],
        ),
      ];

      String single = buildSingleListCopyText(ingredients: unsortedIngredients(), remainingByIngredientId: remainingPerIngredient());
      String perTrip = buildMultiTripCopyText(
        ingredients: unsortedIngredients(),
        remainingByIngredientId: remainingPerIngredient(),
        trips: trips,
        tripLabel: (ShoppingTrip trip) => "Week ${trip.weekIndex}",
      );

      List<String> namesOf(String text) =>
          text.split("\n").where((String line) => line.contains(":")).map((String line) => line.split(":").first.trim()).toList();

      expect(namesOf(perTrip), namesOf(single));
    });
  });
}
