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
  ProductRecommendation? recommendation,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ShoppingProductRow(
          product: product,
          recommendation: recommendation ?? _recommendation(product),
          isBestOption: true,
          packsToBuy: packsToBuy,
          tripPurchases: tripPurchases,
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

  group("ShoppingProductRow under-buy warning", () {
    testWidgets("shows the 'buying less than recipes' warning chip and buys one pack less", (WidgetTester tester) async {
      Product product = _packProduct();
      ProductRecommendation underBuy = ProductRecommendation(
        product: product,
        packsNeeded: 2,
        overBuyWaste: 0,
        expiryWaste: 0,
        isViable: true,
        underBuy: true,
        shortfall: 100,
      );

      await _pumpRow(tester, product: product, packsToBuy: 3, recommendation: underBuy);

      // Warning chip shows the shortfall amount and flags the under-buy.
      expect(find.text("100 grams short"), findsOneWidget);
      // Its tooltip carries the full "buying less than the recipes calculate" wording.
      bool hasWarningTooltip = tester
          .widgetList<Tooltip>(find.byType(Tooltip))
          .any((Tooltip t) => (t.message ?? "").contains("Buying less than the recipes calculate"));
      expect(hasWarningTooltip, isTrue);
      // The single-total buy line drops by one pack.
      expect(find.text("Buy 2 packs"), findsOneWidget);
      expect(find.text("Buy 3 packs"), findsNothing);
    });

    testWidgets("does not reduce or warn when owned stock changed the buy count", (WidgetTester tester) async {
      Product product = _packProduct();
      // rankProducts computed the under-buy on the DESIRED need: the full buy is 3 packs (packsNeeded
      // holds the reduced 2). But owned stock left only 2 packs to actually buy, so the desired-based
      // analysis no longer matches (2 != 2 + 1). The row must buy the full 2 packs and NOT warn.
      ProductRecommendation underBuy = ProductRecommendation(
        product: product,
        packsNeeded: 2,
        overBuyWaste: 60,
        expiryWaste: 0,
        isViable: true,
        underBuy: true,
        shortfall: 100,
      );

      await _pumpRow(tester, product: product, packsToBuy: 2, recommendation: underBuy);

      // Full count, no bogus "-1".
      expect(find.text("Buy 2 packs"), findsOneWidget);
      expect(find.text("Buy 1 pack"), findsNothing);
      // No under-buy chip and no under-buy tooltip.
      expect(find.textContaining("short"), findsNothing);
      bool hasWarningTooltip = tester
          .widgetList<Tooltip>(find.byType(Tooltip))
          .any((Tooltip t) => (t.message ?? "").contains("Buying less than the recipes calculate"));
      expect(hasWarningTooltip, isFalse);
    });

    testWidgets("suppresses the under-buy warning chip when the trip-split layout is active", (WidgetTester tester) async {
      Product product = _packProduct();
      ProductRecommendation underBuy = ProductRecommendation(
        product: product,
        packsNeeded: 2,
        overBuyWaste: 60,
        expiryWaste: 0,
        isViable: true,
        underBuy: true,
        shortfall: 100,
      );

      await _pumpRow(
        tester,
        product: product,
        packsToBuy: 3,
        recommendation: underBuy,
        tripPurchases: const [
          ProductTripPurchase(weekIndex: 0, packs: 2, isFirstTrip: true),
          ProductTripPurchase(weekIndex: 1, packs: 1, isFirstTrip: false),
        ],
      );

      // Per-trip lines show the FULL round-up; the "N short" chip must not appear alongside them.
      expect(find.text("Buy 2 packs now"), findsOneWidget);
      expect(find.text("+ 1 pack week 2"), findsOneWidget);
      expect(find.textContaining("short"), findsNothing);
    });
  });
}
