import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/recipes/enums/unit.dart";
import "package:menu_management/shopping/shopping_progress.dart";

const String _riceSmallLink = "https://example.com/rice-500";
const String _riceLargeLink = "https://example.com/rice-1000";

const Ingredient _rice = Ingredient(
  id: "rice",
  name: "Rice",
  products: [
    Product(link: _riceSmallLink, quantityPerItem: 500, itemsPerPack: 1, unit: Unit.grams),
    Product(link: _riceLargeLink, quantityPerItem: 1000, itemsPerPack: 1, unit: Unit.grams),
  ],
);

const Ingredient _salt = Ingredient(id: "salt", name: "Salt");

void main() {
  group("ShoppingProgress JSON", () {
    test("writes every part of the progress", () {
      const ShoppingProgress progress = ShoppingProgress(
        ownedAmounts: {"salt": (amount: 20, unit: Unit.grams), "oil": (amount: 1.5, unit: null)},
        ownedProductCounts: {
          "rice": {_riceLargeLink: 2},
        },
        useFreezerStrategy: true,
      );

      expect(progress.toJson(), {
        "useFreezerStrategy": true,
        "ownedAmounts": {
          "salt": {"amount": 20.0, "unit": "grams"},
          "oil": {"amount": 1.5, "unit": "packs"},
        },
        "ownedProductCounts": {
          "rice": {_riceLargeLink: 2.0},
        },
      });
    });

    test("leaves out each empty part", () {
      expect(const ShoppingProgress(useFreezerStrategy: true).toJson(), {"useFreezerStrategy": true});
      expect(const ShoppingProgress(ownedAmounts: {"salt": (amount: 20, unit: Unit.grams)}).toJson(), {
        "ownedAmounts": {
          "salt": {"amount": 20.0, "unit": "grams"},
        },
      });
    });

    test("writes nothing for an empty progress", () {
      expect(ShoppingProgress.toJsonOrNull(const ShoppingProgress()), isNull);
      expect(ShoppingProgress.toJsonOrNull(null), isNull);
    });

    test("survives a JSON round trip", () {
      const ShoppingProgress progress = ShoppingProgress(
        ownedAmounts: {"salt": (amount: 20, unit: Unit.grams), "oil": (amount: 1.5, unit: null)},
        ownedProductCounts: {
          "rice": {_riceLargeLink: 2},
        },
        useFreezerStrategy: true,
      );

      expect(ShoppingProgress.fromJsonLenient(jsonDecode(jsonEncode(progress.toJson()))), progress);
    });

    test("reads no progress from a value that is not an object", () {
      expect(ShoppingProgress.fromJsonLenient(null), isNull);
      expect(ShoppingProgress.fromJsonLenient("full"), isNull);
      expect(ShoppingProgress.fromJsonLenient([1, 2]), isNull);
    });

    test("reads no progress from an object that holds nothing", () {
      expect(ShoppingProgress.fromJsonLenient(<String, Object?>{}), isNull);
    });

    test("drops only the bad owned amounts", () {
      Map<String, Object?> json = {
        "ownedAmounts": {
          "salt": {"amount": 20, "unit": "grams"},
          "text": {"amount": "lots", "unit": "grams"},
          "negative": {"amount": -3, "unit": "grams"},
          "unknownUnit": {"amount": 2, "unit": "buckets"},
          "noUnit": {"amount": 2},
          "notAnObject": 4,
        },
      };

      expect(ShoppingProgress.fromJsonLenient(json), const ShoppingProgress(ownedAmounts: {"salt": (amount: 20, unit: Unit.grams)}));
    });

    test("drops only the bad product counts", () {
      Map<String, Object?> json = {
        "ownedProductCounts": {
          "rice": {_riceSmallLink: 1, _riceLargeLink: "two"},
          "milk": {"https://example.com/milk": 0},
          "pasta": "three",
        },
      };

      expect(
        ShoppingProgress.fromJsonLenient(json),
        const ShoppingProgress(
          ownedProductCounts: {
            "rice": {_riceSmallLink: 1},
          },
        ),
      );
    });

    test("drops a trip switch that is not true or false", () {
      Map<String, Object?> json = {
        "useFreezerStrategy": "yes",
        "ownedAmounts": {
          "salt": {"amount": 20, "unit": "grams"},
        },
      };

      expect(ShoppingProgress.fromJsonLenient(json), const ShoppingProgress(ownedAmounts: {"salt": (amount: 20, unit: Unit.grams)}));
    });

    test("drops a whole part that is not an object", () {
      Map<String, Object?> json = {"useFreezerStrategy": true, "ownedAmounts": "none", "ownedProductCounts": 5};

      expect(ShoppingProgress.fromJsonLenient(json), const ShoppingProgress(useFreezerStrategy: true));
    });
  });

  group("ShoppingProgress.ownedProductCountsByIndex", () {
    test("turns each product link into the index of that product", () {
      const ShoppingProgress progress = ShoppingProgress(
        ownedProductCounts: {
          "rice": {_riceLargeLink: 2, _riceSmallLink: 1},
        },
      );

      expect(progress.ownedProductCountsByIndex(ingredients: const [_rice, _salt]), {
        "rice": {1: 2.0, 0: 1.0},
      });
    });

    test("drops a count whose link matches no product", () {
      const ShoppingProgress progress = ShoppingProgress(
        ownedProductCounts: {
          "rice": {_riceSmallLink: 1, "https://example.com/rice-gone": 3},
        },
      );

      expect(progress.ownedProductCountsByIndex(ingredients: const [_rice]), {
        "rice": {0: 1.0},
      });
    });

    test("drops the counts of an ingredient that no longer exists", () {
      const ShoppingProgress progress = ShoppingProgress(
        ownedProductCounts: {
          "rice": {_riceSmallLink: 1},
          "gone": {"https://example.com/gone": 2},
        },
      );

      expect(progress.ownedProductCountsByIndex(ingredients: const [_rice]), {
        "rice": {0: 1.0},
      });
    });
  });

  group("ShoppingProgress.fromPageState", () {
    test("keys each product count by the link of the product", () {
      ShoppingProgress progress = ShoppingProgress.fromPageState(
        previous: null,
        ownedAmounts: const {"salt": (amount: 20, unit: Unit.grams), "rice": (amount: 0, unit: null)},
        ownedProductCountsByIndex: const {
          "salt": {},
          "rice": {1: 2, 0: 0},
        },
        useFreezerStrategy: true,
        ingredients: const [_rice, _salt],
      );

      expect(
        progress,
        const ShoppingProgress(
          ownedAmounts: {"salt": (amount: 20, unit: Unit.grams)},
          ownedProductCounts: {
            "rice": {_riceLargeLink: 2},
          },
          useFreezerStrategy: true,
        ),
      );
    });

    test("drops a count whose index matches no product", () {
      ShoppingProgress progress = ShoppingProgress.fromPageState(
        previous: null,
        ownedAmounts: const {"rice": (amount: 0, unit: null)},
        ownedProductCountsByIndex: const {
          "rice": {0: 1, 5: 3},
        },
        useFreezerStrategy: false,
        ingredients: const [_rice],
      );

      expect(
        progress,
        const ShoppingProgress(
          ownedProductCounts: {
            "rice": {_riceSmallLink: 1},
          },
        ),
      );
    });

    test("keeps the stock of an ingredient that the page does not show", () {
      const ShoppingProgress previous = ShoppingProgress(
        ownedAmounts: {"flour": (amount: 300, unit: Unit.grams), "salt": (amount: 50, unit: Unit.grams)},
        ownedProductCounts: {
          "pasta": {"https://example.com/pasta": 2},
          "rice": {_riceSmallLink: 4},
        },
        useFreezerStrategy: true,
      );

      ShoppingProgress progress = ShoppingProgress.fromPageState(
        previous: previous,
        ownedAmounts: const {"salt": (amount: 0, unit: Unit.grams), "rice": (amount: 0, unit: null)},
        ownedProductCountsByIndex: const {
          "salt": {},
          "rice": {1: 1},
        },
        useFreezerStrategy: false,
        ingredients: const [_rice, _salt],
      );

      expect(
        progress,
        const ShoppingProgress(
          ownedAmounts: {"flour": (amount: 300, unit: Unit.grams)},
          ownedProductCounts: {
            "pasta": {"https://example.com/pasta": 2},
            "rice": {_riceLargeLink: 1},
          },
        ),
      );
    });
  });
}
