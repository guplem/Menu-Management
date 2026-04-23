import "package:flutter_test/flutter_test.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/recipes/enums/unit.dart";
import "package:menu_management/recipes/models/quantity.dart";
import "package:menu_management/shopping/shopping_ingredient.dart";

Ingredient _ingredientWithProducts(List<Product> products) {
  return Ingredient(id: "1", name: "Test", products: products);
}

Ingredient _ingredientNoProducts() {
  return Ingredient(id: "1", name: "Test");
}

Product _product(Unit unit) {
  return Product(link: "", quantityPerItem: 100, itemsPerPack: 1, unit: unit);
}

void main() {
  group("defaultOwnedUnit", () {
    group("ingredient with products", () {
      test("defaults to packs when ingredient has a grams product", () {
        Ingredient ingredient = _ingredientWithProducts([_product(Unit.grams)]);
        OwnedUnit result = defaultOwnedUnit(ingredient: ingredient, desiredQuantities: [const Quantity(amount: 100, unit: Unit.grams)]);
        expect(result, const OwnedUnit());
      });

      test("defaults to packs when ingredient has a pieces product", () {
        Ingredient ingredient = _ingredientWithProducts([_product(Unit.pieces)]);
        OwnedUnit result = defaultOwnedUnit(ingredient: ingredient, desiredQuantities: [const Quantity(amount: 3, unit: Unit.pieces)]);
        expect(result, const OwnedUnit());
      });

      test("defaults to packs when ingredient has multiple products", () {
        Ingredient ingredient = _ingredientWithProducts([_product(Unit.grams), _product(Unit.pieces)]);
        OwnedUnit result = defaultOwnedUnit(ingredient: ingredient, desiredQuantities: [const Quantity(amount: 100, unit: Unit.grams)]);
        expect(result, const OwnedUnit());
      });
    });

    group("ingredient without products", () {
      test("defaults to pieces when desired quantity is in pieces", () {
        Ingredient ingredient = _ingredientNoProducts();
        OwnedUnit result = defaultOwnedUnit(ingredient: ingredient, desiredQuantities: [const Quantity(amount: 3, unit: Unit.pieces)]);
        expect(result, const OwnedUnit(unit: Unit.pieces));
      });

      test("defaults to first desired unit when no pieces", () {
        Ingredient ingredient = _ingredientNoProducts();
        OwnedUnit result = defaultOwnedUnit(ingredient: ingredient, desiredQuantities: [const Quantity(amount: 200, unit: Unit.grams)]);
        expect(result, const OwnedUnit(unit: Unit.grams));
      });

      test("defaults to grams when no desired quantities", () {
        Ingredient ingredient = _ingredientNoProducts();
        OwnedUnit result = defaultOwnedUnit(ingredient: ingredient, desiredQuantities: []);
        expect(result, const OwnedUnit(unit: Unit.grams));
      });
    });

    group("null ingredient", () {
      test("defaults to pieces when desired quantity is in pieces", () {
        OwnedUnit result = defaultOwnedUnit(ingredient: null, desiredQuantities: [const Quantity(amount: 3, unit: Unit.pieces)]);
        expect(result, const OwnedUnit(unit: Unit.pieces));
      });

      test("defaults to first desired unit when no pieces", () {
        OwnedUnit result = defaultOwnedUnit(ingredient: null, desiredQuantities: [const Quantity(amount: 100, unit: Unit.grams)]);
        expect(result, const OwnedUnit(unit: Unit.grams));
      });

      test("defaults to grams when no desired quantities", () {
        OwnedUnit result = defaultOwnedUnit(ingredient: null, desiredQuantities: []);
        expect(result, const OwnedUnit(unit: Unit.grams));
      });
    });
  });
}
