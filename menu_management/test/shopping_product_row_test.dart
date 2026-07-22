import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/recipes/enums/unit.dart";
import "package:menu_management/shopping/shopping_product_row.dart";
import "package:menu_management/shopping/waste_optimizer.dart";

Product _packProduct() => const Product(link: "", quantityPerItem: 125, itemsPerPack: 6, unit: Unit.grams);

ProductRecommendation _recommendation(Product product) =>
    ProductRecommendation(product: product, packsNeeded: 0, overBuyWaste: 0, expiryWaste: 0, isViable: true);

Future<void> _pumpRow(
  WidgetTester tester, {
  required Product product,
  required int packsToBuy,
  List<ProductTripPurchase> tripPurchases = const [],
  double ownedCount = 0,
  ValueChanged<double>? onOwnedCountChanged,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ShoppingProductRow(
          product: product,
          recommendation: _recommendation(product),
          isBestOption: true,
          packsToBuy: packsToBuy,
          tripPurchases: tripPurchases,
          ownedCount: ownedCount,
          onOwnedCountChanged: onOwnedCountChanged,
        ),
      ),
    ),
  );
}

void main() {
  group("ShoppingProductRow buy area", () {
    testWidgets("renders per-trip split lines when 2+ trip purchases are given", (WidgetTester tester) async {
      Product product = _packProduct();
      await _pumpRow(
        tester,
        product: product,
        packsToBuy: 9,
        tripPurchases: const [
          ProductTripPurchase(weekIndex: 0, packs: 6, isFirstTrip: true),
          ProductTripPurchase(weekIndex: 1, packs: 3, isFirstTrip: false),
        ],
      );

      expect(find.text("Buy 6 packs now"), findsOneWidget);
      expect(find.text("+ 3 packs week 2"), findsOneWidget);
      // The single-total label must not appear when the row is split.
      expect(find.text("Buy 9 packs"), findsNothing);
    });

    testWidgets("renders a single total line when no trip purchases are given", (WidgetTester tester) async {
      Product product = _packProduct();
      await _pumpRow(tester, product: product, packsToBuy: 9);

      expect(find.text("Buy 9 packs"), findsOneWidget);
      expect(find.text("Buy 6 packs now"), findsNothing);
    });

    testWidgets("renders 'Covered' when nothing needs buying", (WidgetTester tester) async {
      Product product = _packProduct();
      await _pumpRow(tester, product: product, packsToBuy: 0);

      expect(find.text("Covered"), findsOneWidget);
    });

    testWidgets("shows a per-product owned input and reports typed counts", (WidgetTester tester) async {
      double? reported;
      await _pumpRow(tester, product: _packProduct(), packsToBuy: 9, onOwnedCountChanged: (double value) => reported = value);

      Finder ownedField = find.widgetWithText(TextField, "Owned");
      expect(ownedField, findsOneWidget);

      await tester.enterText(ownedField, "2");
      expect(reported, 2);
    });

    testWidgets("hides the owned input when no owned callback is provided", (WidgetTester tester) async {
      await _pumpRow(tester, product: _packProduct(), packsToBuy: 9);

      expect(find.widgetWithText(TextField, "Owned"), findsNothing);
    });

    testWidgets("re-seeds the owned field when ownedCount changes from the parent", (WidgetTester tester) async {
      double owned = 0;
      late StateSetter setOuter;
      Product product = _packProduct();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                setOuter = setState;
                return ShoppingProductRow(
                  product: product,
                  recommendation: _recommendation(product),
                  isBestOption: true,
                  packsToBuy: 9,
                  ownedCount: owned,
                  onOwnedCountChanged: (double value) {},
                );
              },
            ),
          ),
        ),
      );

      Finder ownedField = find.widgetWithText(TextField, "Owned");
      expect(tester.widget<TextField>(ownedField).controller!.text, "");

      // The parent resets the owned count to 3; the field must reflect it without recreating the widget.
      setOuter(() => owned = 3);
      await tester.pump();
      expect(tester.widget<TextField>(ownedField).controller!.text, "3");
    });

    testWidgets("uses 'piece' wording for single-item packs", (WidgetTester tester) async {
      const Product piecesProduct = Product(link: "", quantityPerItem: 1, itemsPerPack: 1, unit: Unit.pieces);
      await _pumpRow(
        tester,
        product: piecesProduct,
        packsToBuy: 3,
        tripPurchases: const [
          ProductTripPurchase(weekIndex: 0, packs: 2, isFirstTrip: true),
          ProductTripPurchase(weekIndex: 2, packs: 1, isFirstTrip: false),
        ],
      );

      expect(find.text("Buy 2 pieces now"), findsOneWidget);
      expect(find.text("+ 1 piece week 3"), findsOneWidget);
    });
  });
}
