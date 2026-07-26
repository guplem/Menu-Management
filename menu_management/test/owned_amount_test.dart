import "package:flutter_test/flutter_test.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/recipes/enums/unit.dart";
import "package:menu_management/recipes/models/quantity.dart";
import "package:menu_management/shopping/owned_amount.dart";

Product _product({required Unit unit, double quantityPerItem = 100, int itemsPerPack = 1}) {
  return Product(link: "https://example.com/p", unit: unit, quantityPerItem: quantityPerItem, itemsPerPack: itemsPerPack);
}

void main() {
  group("ownedAmountInUnit", () {
    test("returns 0 for a non-positive owned amount", () {
      Ingredient flour = const Ingredient(id: "flour", name: "Flour");
      expect(ownedAmountInUnit(ingredient: flour, ownedAmount: 0, ownedUnit: Unit.grams, targetUnit: Unit.grams), 0);
      expect(ownedAmountInUnit(ingredient: flour, ownedAmount: -5, ownedUnit: Unit.grams, targetUnit: Unit.grams), 0);
    });

    test("returns the amount unchanged when owned unit equals target unit", () {
      Ingredient flour = const Ingredient(id: "flour", name: "Flour");
      expect(ownedAmountInUnit(ingredient: flour, ownedAmount: 250, ownedUnit: Unit.grams, targetUnit: Unit.grams), 250);
    });

    test("packs mode uses the product whose unit matches the target unit, not the first product", () {
      // Products: pieces (1 per pack) listed FIRST, grams (500 per pack) listed second.
      // A "packs" owned of 1 against a grams need must use the 500g product, not the pieces one.
      Ingredient ingredient = Ingredient(
        id: "i1",
        name: "Item",
        products: [
          _product(unit: Unit.pieces, quantityPerItem: 1),
          _product(unit: Unit.grams, quantityPerItem: 500),
        ],
      );
      expect(ownedAmountInUnit(ingredient: ingredient, ownedAmount: 1, ownedUnit: null, targetUnit: Unit.grams), 500);
      expect(ownedAmountInUnit(ingredient: ingredient, ownedAmount: 1, ownedUnit: null, targetUnit: Unit.pieces), 1);
    });

    test("packs mode returns 0 when no product matches the target unit", () {
      Ingredient ingredient = Ingredient(
        id: "i1",
        name: "Item",
        products: [_product(unit: Unit.pieces, quantityPerItem: 1)],
      );
      expect(ownedAmountInUnit(ingredient: ingredient, ownedAmount: 2, ownedUnit: null, targetUnit: Unit.grams), 0);
    });

    test("converts owned pieces into grams using gramsPerPiece", () {
      Ingredient banana = const Ingredient(id: "banana", name: "Banana", gramsPerPiece: 120);
      expect(ownedAmountInUnit(ingredient: banana, ownedAmount: 1, ownedUnit: Unit.pieces, targetUnit: Unit.grams), 120);
    });

    test("converts owned grams into centiliters using density", () {
      Ingredient oil = const Ingredient(id: "oil", name: "Oil", density: 0.8);
      // 400 g / (10 * 0.8) = 50 cl
      expect(ownedAmountInUnit(ingredient: oil, ownedAmount: 400, ownedUnit: Unit.grams, targetUnit: Unit.centiliters), 50);
    });

    test("returns 0 when cross-unit conversion is impossible (no density or gramsPerPiece)", () {
      Ingredient banana = const Ingredient(id: "banana", name: "Banana");
      expect(ownedAmountInUnit(ingredient: banana, ownedAmount: 3, ownedUnit: Unit.pieces, targetUnit: Unit.grams), 0);
    });
  });

  group("computeRemainingQuantities", () {
    test("subtracts owned once for a single-unit need (matches the old per-unit result)", () {
      Ingredient flour = const Ingredient(id: "flour", name: "Flour");
      List<Quantity> remaining = computeRemainingQuantities(
        ingredient: flour,
        requiredQuantities: const [Quantity(amount: 600, unit: Unit.grams)],
        ownedAmount: 250,
        ownedUnit: Unit.grams,
      );

      expect(remaining.length, 1);
      expect(remaining.first.unit, Unit.grams);
      expect(remaining.first.amount, 350);
    });

    test("rounds the remaining amount to whole units", () {
      Ingredient flour = const Ingredient(id: "flour", name: "Flour");
      List<Quantity> remaining = computeRemainingQuantities(
        ingredient: flour,
        requiredQuantities: const [Quantity(amount: 100.6, unit: Unit.grams)],
        ownedAmount: 0,
        ownedUnit: Unit.grams,
      );

      expect(remaining.first.amount, 101);
    });

    test("does not subtract a single owned stock more than once when the need spans two units", () {
      // Garlic is needed as 4 pieces AND 50 g. It has gramsPerPiece = 25 and a pieces product,
      // so the normalizer keeps pieces and grams as two separate lines. The user owns 100 g.
      // 100 g equals the 4 pieces (4 * 25). The owned stock must cover the pieces line and be
      // used up, leaving the 50 g line untouched -- NOT subtracted from both lines.
      Ingredient garlic = Ingredient(
        id: "garlic",
        name: "Ajo",
        gramsPerPiece: 25,
        products: [
          _product(unit: Unit.grams, quantityPerItem: 150),
          _product(unit: Unit.pieces, quantityPerItem: 1),
        ],
      );
      List<Quantity> remaining = computeRemainingQuantities(
        ingredient: garlic,
        requiredQuantities: const [
          Quantity(amount: 4, unit: Unit.pieces),
          Quantity(amount: 50, unit: Unit.grams),
        ],
        ownedAmount: 100,
        ownedUnit: Unit.grams,
      );

      double pieces = remaining.firstWhere((q) => q.unit == Unit.pieces).amount;
      double grams = remaining.firstWhere((q) => q.unit == Unit.grams).amount;
      expect(pieces, 0);
      expect(grams, 50);
    });
  });
}
