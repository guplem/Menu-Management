import "package:flutter_test/flutter_test.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/recipes/enums/unit.dart";
import "package:menu_management/recipes/models/quantity.dart";
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
  });
}
