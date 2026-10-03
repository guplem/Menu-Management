import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/recipes/enums/unit.dart";
import "package:menu_management/shopping/shopping_progress.dart";

const String _riceSmallLink = "https://example.com/rice-500";
const String _riceLargeLink = "https://example.com/rice-1000";
const String _breadLink = "https://example.com/bread";

const Ingredient _rice = Ingredient(
  id: "rice",
  name: "Rice",
  products: [
    Product(link: _riceSmallLink, quantityPerItem: 500, itemsPerPack: 1, unit: Unit.grams),
    Product(link: _riceLargeLink, quantityPerItem: 1000, itemsPerPack: 1, unit: Unit.grams),
  ],
);

// The store sells one loaf, so the weight product and the pieces product share one link.
const Ingredient _bread = Ingredient(
  id: "bread",
  name: "Bread",
  products: [
    Product(link: _breadLink, quantityPerItem: 400, itemsPerPack: 1, unit: Unit.grams),
    Product(link: _breadLink, quantityPerItem: 1, itemsPerPack: 1, unit: Unit.pieces),
  ],
);

// Two products with the same link and the same unit: only the first one can carry a saved count.
const Ingredient _twinFlour = Ingredient(
  id: "flour",
  name: "Flour",
  products: [
    Product(link: "https://example.com/flour", quantityPerItem: 1000, itemsPerPack: 1, unit: Unit.grams),
    Product(link: "https://example.com/flour", quantityPerItem: 1000, itemsPerPack: 2, unit: Unit.grams),
  ],
);

const Ingredient _salt = Ingredient(id: "salt", name: "Salt");

const Ingredient _pasta = Ingredient(
  id: "pasta",
  name: "Pasta",
  products: [Product(link: "https://example.com/pasta", quantityPerItem: 500, itemsPerPack: 1, unit: Unit.grams)],
);

void main() {
  group("ShoppingProgress JSON", () {
    test("writes every part of the progress", () {
      const ShoppingProgress progress = ShoppingProgress(
        ownedAmounts: {"salt": (amount: 20, unit: Unit.grams), "oil": (amount: 1.5, unit: null)},
        ownedProductCounts: {
          "rice": {(link: _riceLargeLink, unit: Unit.grams): 2},
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
          "rice": [
            {"link": _riceLargeLink, "unit": "grams", "count": 2.0},
          ],
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
          "rice": {(link: _riceLargeLink, unit: Unit.grams): 2},
          "bread": {(link: _breadLink, unit: Unit.grams): 1, (link: _breadLink, unit: Unit.pieces): 3},
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
          "rice": [
            {"link": _riceSmallLink, "unit": "grams", "count": 1},
            {"link": _riceLargeLink, "unit": "grams", "count": "two"},
            {"link": _riceLargeLink, "unit": "packs", "count": 2},
            {"link": _riceLargeLink, "count": 2},
            {"unit": "grams", "count": 2},
            "not an object",
          ],
          "milk": [
            {"link": "https://example.com/milk", "unit": "grams", "count": 0},
          ],
          "pasta": {"https://example.com/pasta": 3},
        },
      };

      expect(
        ShoppingProgress.fromJsonLenient(json),
        const ShoppingProgress(
          ownedProductCounts: {
            "rice": {(link: _riceSmallLink, unit: Unit.grams): 1},
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
    test("turns each product key into the index of that product", () {
      const ShoppingProgress progress = ShoppingProgress(
        ownedProductCounts: {
          "rice": {(link: _riceLargeLink, unit: Unit.grams): 2, (link: _riceSmallLink, unit: Unit.grams): 1},
        },
      );

      expect(progress.ownedProductCountsByIndex(ingredients: const [_rice, _salt]), {
        "rice": {1: 2.0, 0: 1.0},
      });
    });

    test("puts each count on its own product when two products share a link", () {
      const ShoppingProgress progress = ShoppingProgress(
        ownedProductCounts: {
          "bread": {(link: _breadLink, unit: Unit.pieces): 3, (link: _breadLink, unit: Unit.grams): 1},
        },
      );

      expect(progress.ownedProductCountsByIndex(ingredients: const [_bread]), {
        "bread": {0: 1.0, 1: 3.0},
      });
    });

    test("puts the count on the first product when two products share a link and a unit", () {
      const ShoppingProgress progress = ShoppingProgress(
        ownedProductCounts: {
          "flour": {(link: "https://example.com/flour", unit: Unit.grams): 2},
        },
      );

      expect(progress.ownedProductCountsByIndex(ingredients: const [_twinFlour]), {
        "flour": {0: 2.0},
      });
    });

    test("drops a count whose link matches no product", () {
      const ShoppingProgress progress = ShoppingProgress(
        ownedProductCounts: {
          "rice": {(link: _riceSmallLink, unit: Unit.grams): 1, (link: "https://example.com/rice-gone", unit: Unit.grams): 3},
        },
      );

      expect(progress.ownedProductCountsByIndex(ingredients: const [_rice]), {
        "rice": {0: 1.0},
      });
    });

    test("drops a count whose unit matches no product of its link", () {
      const ShoppingProgress progress = ShoppingProgress(
        ownedProductCounts: {
          "rice": {(link: _riceSmallLink, unit: Unit.grams): 1, (link: _riceLargeLink, unit: Unit.pieces): 3},
        },
      );

      expect(progress.ownedProductCountsByIndex(ingredients: const [_rice]), {
        "rice": {0: 1.0},
      });
    });

    test("drops the counts of an ingredient that no longer exists", () {
      const ShoppingProgress progress = ShoppingProgress(
        ownedProductCounts: {
          "rice": {(link: _riceSmallLink, unit: Unit.grams): 1},
          "gone": {(link: "https://example.com/gone", unit: Unit.grams): 2},
        },
      );

      expect(progress.ownedProductCountsByIndex(ingredients: const [_rice]), {
        "rice": {0: 1.0},
      });
    });
  });

  group("ShoppingProgress.fromPageState", () {
    test("keys each product count by the link and the unit of the product", () {
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
            "rice": {(link: _riceLargeLink, unit: Unit.grams): 2},
          },
          useFreezerStrategy: true,
        ),
      );
    });

    test("keeps both counts when two products share a link", () {
      ShoppingProgress progress = ShoppingProgress.fromPageState(
        previous: null,
        ownedAmounts: const {"bread": (amount: 0, unit: null)},
        ownedProductCountsByIndex: const {
          "bread": {0: 1, 1: 3},
        },
        useFreezerStrategy: false,
        ingredients: const [_bread],
      );

      expect(
        progress,
        const ShoppingProgress(
          ownedProductCounts: {
            "bread": {(link: _breadLink, unit: Unit.grams): 1, (link: _breadLink, unit: Unit.pieces): 3},
          },
        ),
      );
    });

    test("keeps the count of the first product when two products share a link and a unit", () {
      ShoppingProgress progress = ShoppingProgress.fromPageState(
        previous: null,
        ownedAmounts: const {"flour": (amount: 0, unit: null)},
        ownedProductCountsByIndex: const {
          "flour": {1: 5, 0: 2},
        },
        useFreezerStrategy: false,
        ingredients: const [_twinFlour],
      );

      expect(
        progress,
        const ShoppingProgress(
          ownedProductCounts: {
            "flour": {(link: "https://example.com/flour", unit: Unit.grams): 2},
          },
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
            "rice": {(link: _riceSmallLink, unit: Unit.grams): 1},
          },
        ),
      );
    });

    test("keeps the stock of an ingredient that the page does not show", () {
      const ShoppingProgress previous = ShoppingProgress(
        ownedAmounts: {"flour": (amount: 300, unit: Unit.grams), "salt": (amount: 50, unit: Unit.grams)},
        ownedProductCounts: {
          "pasta": {(link: "https://example.com/pasta", unit: Unit.grams): 2},
          "rice": {(link: _riceSmallLink, unit: Unit.grams): 4},
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
        ingredients: const [_rice, _salt, _twinFlour, _pasta],
      );

      expect(
        progress,
        const ShoppingProgress(
          ownedAmounts: {"flour": (amount: 300, unit: Unit.grams)},
          ownedProductCounts: {
            "pasta": {(link: "https://example.com/pasta", unit: Unit.grams): 2},
            "rice": {(link: _riceLargeLink, unit: Unit.grams): 1},
          },
        ),
      );
    });

    test("drops the previous stock of an ingredient that no longer exists", () {
      const ShoppingProgress previous = ShoppingProgress(
        ownedAmounts: {"gone": (amount: 300, unit: Unit.grams), "flour": (amount: 200, unit: Unit.grams)},
        ownedProductCounts: {
          "goneToo": {(link: "https://example.com/gone", unit: Unit.grams): 2},
          "pasta": {(link: "https://example.com/pasta", unit: Unit.grams): 1},
        },
      );

      ShoppingProgress progress = ShoppingProgress.fromPageState(
        previous: previous,
        ownedAmounts: const {"salt": (amount: 0, unit: Unit.grams)},
        ownedProductCountsByIndex: const {"salt": {}},
        useFreezerStrategy: false,
        ingredients: const [_salt, _twinFlour, _pasta],
      );

      expect(
        progress,
        const ShoppingProgress(
          ownedAmounts: {"flour": (amount: 200, unit: Unit.grams)},
          ownedProductCounts: {
            "pasta": {(link: "https://example.com/pasta", unit: Unit.grams): 1},
          },
        ),
      );
    });

    test("drops a previous count whose product no longer exists", () {
      const ShoppingProgress previous = ShoppingProgress(
        ownedProductCounts: {
          "bread": {(link: _breadLink, unit: Unit.grams): 1, (link: _breadLink, unit: Unit.teaspoons): 2},
          "pasta": {(link: "https://example.com/pasta-gone", unit: Unit.grams): 3},
        },
      );

      ShoppingProgress progress = ShoppingProgress.fromPageState(
        previous: previous,
        ownedAmounts: const {"salt": (amount: 0, unit: Unit.grams)},
        ownedProductCountsByIndex: const {"salt": {}},
        useFreezerStrategy: false,
        ingredients: const [_salt, _bread, _pasta],
      );

      expect(
        progress,
        const ShoppingProgress(
          ownedProductCounts: {
            "bread": {(link: _breadLink, unit: Unit.grams): 1},
          },
        ),
      );
    });
  });
}
