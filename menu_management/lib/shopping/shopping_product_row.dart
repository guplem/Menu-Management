import "dart:io";

import "package:flutter/material.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/shopping/waste_optimizer.dart";
import "package:menu_management/theme/theme_custom.dart";

/// One shopping trip's share of a single product's buy count, for the on-screen per-trip split.
class ProductTripPurchase {
  const ProductTripPurchase({required this.weekIndex, required this.packs, required this.isFirstTrip});

  final int weekIndex; // 0-based; displayed as weekIndex + 1
  final int packs;
  final bool isFirstTrip; // true for the plan's earliest trip -> labeled "now"
}

class ShoppingProductRow extends StatelessWidget {
  const ShoppingProductRow({
    super.key,
    required this.product,
    required this.recommendation,
    required this.isBestOption,
    required this.packsToBuy,
    this.tripPurchases = const [],
  });

  final Product product;
  final ProductRecommendation recommendation;

  /// True when this product's totalWaste equals the minimum among all alternatives
  /// (includes ties and single-product ingredients).
  final bool isBestOption;
  final int packsToBuy;

  /// Per-trip split of [packsToBuy]. When it has 2+ entries the buy area shows one line per
  /// trip (e.g. "Buy 6 packs now" + "3 packs week 2"); otherwise it shows a single total.
  final List<ProductTripPurchase> tripPurchases;

  /// Singular/plural unit word: pieces for single-item packs, packs otherwise.
  String _packWord(int count) => product.itemsPerPack == 1 ? (count == 1 ? "piece" : "pieces") : (count == 1 ? "pack" : "packs");

  String _tripPurchaseLabel(ProductTripPurchase purchase, {required bool isFirstLine}) {
    String prefix = isFirstLine ? "Buy" : "+";
    String when = purchase.isFirstTrip ? "now" : "week ${purchase.weekIndex + 1}";
    return "$prefix ${purchase.packs} ${_packWord(purchase.packs)} $when";
  }

  String _wasteBreakdown() {
    String unit = product.unit.name;
    double over = recommendation.overBuyWaste;
    double expiry = recommendation.expiryWaste;

    List<String> parts = [];
    if (over > 0) parts.add("${over.toFormattedAmount()} $unit surplus from buying whole packs");
    if (expiry > 0) parts.add("${expiry.toFormattedAmount()} $unit will expire between cooking sessions");
    return parts.join(" + ");
  }

  Widget _buildChip(BuildContext context) {
    double totalWaste = recommendation.totalWaste;
    String unit = product.unit.name;

    // Under-buy: one pack less than the recipes calculate. Amber warning chip.
    // Label stays compact (like the waste chips); the full wording lives in the tooltip.
    if (recommendation.underBuy) {
      ColorScheme amber = ColorScheme.fromSeed(seedColor: Colors.amber, brightness: Theme.of(context).brightness);
      return Tooltip(
        message:
            "Buying less than the recipes calculate.\n"
            "Dropped one mostly-empty pack; recipes will be about ${recommendation.shortfall.toFormattedAmount()} $unit short.",
        child: Chip(
          avatar: Icon(Icons.warning_amber_rounded, size: 16, color: amber.onPrimaryContainer),
          label: Text("${recommendation.shortfall.toFormattedAmount()} $unit short"),
          backgroundColor: amber.primaryContainer,
          labelStyle: TextStyle(color: amber.onPrimaryContainer, fontSize: 12),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
        ),
      );
    }

    // No waste: green chip
    if (totalWaste == 0) {
      return Tooltip(
        message: "Perfect fit - covers exactly what you need, no waste.",
        child: Chip(
          label: const Text("No waste"),
          backgroundColor: ThemeCustom.colorScheme(context).primaryContainer,
          labelStyle: TextStyle(color: ThemeCustom.colorScheme(context).onPrimaryContainer, fontSize: 12),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
        ),
      );
    }

    String wasteLabel = "${totalWaste.toFormattedAmount()} $unit waste";

    // Best option (or tied for best): blue/teal chip with waste amount
    if (isBestOption) {
      return Tooltip(
        message: "Least total waste among available options.\n${_wasteBreakdown()}",
        child: Chip(
          label: Text("$wasteLabel (best option)"),
          backgroundColor: ThemeCustom.colorScheme(context).tertiaryContainer,
          labelStyle: TextStyle(color: ThemeCustom.colorScheme(context).onTertiaryContainer, fontSize: 12),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
        ),
      );
    }

    // Worse than the best option: yellow/amber chip
    return Tooltip(
      message: _wasteBreakdown(),
      child: Chip(
        label: Text(wasteLabel),
        backgroundColor: ColorScheme.fromSeed(seedColor: Colors.amber, brightness: Theme.of(context).brightness).primaryContainer,
        labelStyle: TextStyle(
          color: ColorScheme.fromSeed(seedColor: Colors.amber, brightness: Theme.of(context).brightness).onPrimaryContainer,
          fontSize: 12,
        ),
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String? packLabel = product.packLabel();
    String totalLabel = "${product.totalQuantityPerPack.toFormattedAmount()} ${product.unit.name}/pack";
    bool covered = packsToBuy <= 0;
    // When the recommendation is an under-buy, buy one pack less on the single-total line
    // (the warning chip explains why). Guarded so it never drops below one pack.
    int effectivePacksToBuy = recommendation.underBuy && packsToBuy >= 2 ? packsToBuy - 1 : packsToBuy;

    return FilledCard(
      outlined: true,
      borderColor: isBestOption && recommendation.totalWaste > 0 ? ThemeCustom.colorScheme(context).tertiary : null,
      color: ThemeCustom.colorScheme(context).secondaryContainer.withValues(alpha: covered ? 0.3 : 1),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          children: [
            // Pack description
            SizedBox(
              width: 160,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (packLabel != null) Text(packLabel, style: Theme.of(context).textTheme.bodyLarge),
                  // Only show totalLabel as subtitle when it adds info (e.g. "6x125grams" + "750 grams/pack")
                  if (packLabel == null || packLabel != totalLabel)
                    Text(
                      totalLabel,
                      style: packLabel != null
                          ? Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor)
                          : Theme.of(context).textTheme.bodyLarge,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Waste status chip (shown for all products)
            Padding(padding: const EdgeInsets.only(right: 8), child: _buildChip(context)),

            // Product link button
            IconButton(
              icon: const Icon(Icons.open_in_new_rounded, size: 20),
              tooltip: "Open product page",
              onPressed: product.link.isEmpty ? null : () => Process.run("start", [product.link], runInShell: true),
            ),

            const Spacer(),

            // Packs to buy (far right)
            SizedBox(
              width: 160,
              child: covered
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.check_rounded, color: Theme.of(context).hintColor, size: 18),
                        const SizedBox(width: 4),
                        Text("Covered", style: TextStyle(color: Theme.of(context).hintColor)),
                      ],
                    )
                  : tripPurchases.length >= 2
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (int i = 0; i < tripPurchases.length; i++)
                          Text(
                            _tripPurchaseLabel(tripPurchases[i], isFirstLine: i == 0),
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.right,
                          ),
                      ],
                    )
                  : Text(
                      "Buy $effectivePacksToBuy ${_packWord(effectivePacksToBuy)}",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
