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

  group("productOwnedAmountInUnit", () {
    test("count of a product times its pack quantity, when the product unit is the target unit", () {
      // Product: 6 items x 125 g = 750 g per pack. Owning 2 packs -> 1500 g.
      Product product = _product(unit: Unit.grams, quantityPerItem: 125, itemsPerPack: 6);
      Ingredient ingredient = Ingredient(id: "i1", name: "Item", products: [product]);
      expect(productOwnedAmountInUnit(ingredient: ingredient, product: product, count: 2, targetUnit: Unit.grams), 1500);
    });

    test("converts a piece product's owned count into grams via gramsPerPiece", () {
      // 3 pieces owned, gramsPerPiece 120 -> 360 g.
      Product product = _product(unit: Unit.pieces, quantityPerItem: 1);
      Ingredient banana = Ingredient(id: "banana", name: "Banana", gramsPerPiece: 120, products: [product]);
      expect(productOwnedAmountInUnit(ingredient: banana, product: product, count: 3, targetUnit: Unit.grams), 360);
    });

    test("returns the count in pieces directly when target is pieces (no gramsPerPiece needed)", () {
      Product product = _product(unit: Unit.pieces, quantityPerItem: 1);
      Ingredient eggs = Ingredient(id: "eggs", name: "Eggs", products: [product]);
      expect(productOwnedAmountInUnit(ingredient: eggs, product: product, count: 4, targetUnit: Unit.pieces), 4);
    });

    test("returns 0 when a cross-unit conversion has no bridge", () {
      // Pieces product, target grams, no gramsPerPiece -> cannot convert.
      Product product = _product(unit: Unit.pieces, quantityPerItem: 1);
      Ingredient eggs = Ingredient(id: "eggs", name: "Eggs", products: [product]);
      expect(productOwnedAmountInUnit(ingredient: eggs, product: product, count: 4, targetUnit: Unit.grams), 0);
    });

    test("returns 0 for a non-positive count", () {
      Product product = _product(unit: Unit.grams, quantityPerItem: 100);
      Ingredient ingredient = Ingredient(id: "i1", name: "Item", products: [product]);
      expect(productOwnedAmountInUnit(ingredient: ingredient, product: product, count: 0, targetUnit: Unit.grams), 0);
    });
  });

  group("OwnedStock.amountInUnit", () {
    test("single-form stock delegates to ownedAmountInUnit", () {
      Ingredient flour = const Ingredient(id: "flour", name: "Flour");
      const OwnedStock stock = OwnedStock(amount: 250, unit: Unit.grams);
      expect(stock.amountInUnit(ingredient: flour, targetUnit: Unit.grams), 250);
    });

    test("per-product stock sums two products of different pack sizes into grams", () {
      // Product A: 500 g per pack. Product B: 250 g per pack.
      // Owning 3 of A + 5 of B -> 1500 + 1250 = 2750 g.
      Product a = _product(unit: Unit.grams, quantityPerItem: 500);
      Product b = _product(unit: Unit.grams, quantityPerItem: 250);
      Ingredient ingredient = Ingredient(id: "i1", name: "Item", products: [a, b]);
      OwnedStock stock = OwnedStock.perProduct(countsByProductIndex: {0: 3, 1: 5});
      expect(stock.amountInUnit(ingredient: ingredient, targetUnit: Unit.grams), 2750);
    });

    test("per-product stock mixes a weight product and a piece product via gramsPerPiece", () {
      // Product 0: 200 g per pack (weight). Product 1: pieces, gramsPerPiece 50.
      // Owning 1 weight pack (200 g) + 2 pieces (100 g) -> 300 g.
      Product weight = _product(unit: Unit.grams, quantityPerItem: 200);
      Product pieces = _product(unit: Unit.pieces, quantityPerItem: 1);
      Ingredient ingredient = Ingredient(id: "i1", name: "Item", gramsPerPiece: 50, products: [weight, pieces]);
      OwnedStock stock = OwnedStock.perProduct(countsByProductIndex: {0: 1, 1: 2});
      expect(stock.amountInUnit(ingredient: ingredient, targetUnit: Unit.grams), 300);
    });

    test("per-product stock reports the global owned amount in a target unit via fromGrams", () {
      // 4 pieces owned, gramsPerPiece 120 -> 480 g -> back to 4 pieces.
      Product pieces = _product(unit: Unit.pieces, quantityPerItem: 1);
      Ingredient banana = Ingredient(id: "banana", name: "Banana", gramsPerPiece: 120, products: [pieces]);
      OwnedStock stock = OwnedStock.perProduct(countsByProductIndex: {0: 4});
      expect(stock.amountInUnit(ingredient: banana, targetUnit: Unit.grams), 480);
      expect(stock.amountInUnit(ingredient: banana, targetUnit: Unit.pieces), 4);
    });

    test("hasStock is false when nothing is owned and true when some product is owned", () {
      Product a = _product(unit: Unit.grams, quantityPerItem: 500);
      expect(OwnedStock.perProduct(countsByProductIndex: const {0: 0}).hasStock, isFalse);
      expect(OwnedStock.perProduct(countsByProductIndex: const {0: 2}).hasStock, isTrue);
      expect(const OwnedStock(amount: 0, unit: Unit.grams).hasStock, isFalse);
      expect(const OwnedStock(amount: 5, unit: Unit.grams).hasStock, isTrue);
      // Reference the product so the analyzer does not flag it as unused.
      expect(a.totalQuantityPerPack, 500);
    });
  });

  group("computeRemainingQuantities", () {
    test("subtracts owned once for a single-unit need (matches the old per-unit result)", () {
      Ingredient flour = const Ingredient(id: "flour", name: "Flour");
      List<Quantity> remaining = computeRemainingQuantities(
        ingredient: flour,
        requiredQuantities: const [Quantity(amount: 600, unit: Unit.grams)],
        owned: const OwnedStock(amount: 250, unit: Unit.grams),
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
        owned: const OwnedStock(amount: 0, unit: Unit.grams),
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
        owned: const OwnedStock(amount: 100, unit: Unit.grams),
      );

      double pieces = remaining.firstWhere((q) => q.unit == Unit.pieces).amount;
      double grams = remaining.firstWhere((q) => q.unit == Unit.grams).amount;
      expect(pieces, 0);
      expect(grams, 50);
    });
  });

  group("computeRemainingQuantities with per-product owned", () {
    test("subtracts per-product owned counts once across two units via the single pool", () {
      // Garlic needed as 4 pieces AND 50 g (gramsPerPiece 25 keeps both lines). The user owns
      // 4 pieces via the pieces product (index 1) -> 100 g global. That covers the pieces line
      // and is used up, leaving the 50 g line untouched. This proves per-product owned (issue #24)
      // flows through the same single grams pool as the single-form stock above.
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
        owned: OwnedStock.perProduct(countsByProductIndex: const {1: 4}),
      );

      double pieces = remaining.firstWhere((q) => q.unit == Unit.pieces).amount;
      double grams = remaining.firstWhere((q) => q.unit == Unit.grams).amount;
      expect(pieces, 0);
      expect(grams, 50);
    });
  });
}
