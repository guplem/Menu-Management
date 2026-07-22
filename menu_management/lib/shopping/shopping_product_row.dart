import "dart:io";

import "package:flutter/material.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/shopping/waste_optimizer.dart";
import "package:menu_management/theme/theme_custom.dart";

/// One shopping trip's share of a single product's buy count, for the on-screen per-trip split.
class ProductTripPurchase {
  const ProductTripPurchase({required this.weekIndex, required this.packs, required this.isFirstTrip});

  final int weekIndex; // 0-based; displayed as "W${weekIndex + 1}"
  final int packs;
  final bool isFirstTrip; // true for the plan's earliest trip -> tooltip says "first shop visit"
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
  /// trip (e.g. "Buy 6 packs (W1)" + "Buy 3 packs (W2)"); otherwise it shows a single total.
  final List<ProductTripPurchase> tripPurchases;

  /// Singular/plural unit word: pieces for single-item packs, packs otherwise.
  String _packWord(int count) => product.itemsPerPack == 1 ? (count == 1 ? "piece" : "pieces") : (count == 1 ? "pack" : "packs");

  /// Short label shown on each split line, e.g. "Buy 3 packs (W2)". "W2" is the shop visit
  /// the day before week 2, matching the "Week 2" section header in the copied list.
  String _tripPurchaseLabel(ProductTripPurchase purchase) => "Buy ${purchase.packs} ${_packWord(purchase.packs)} (W${purchase.weekIndex + 1})";

  /// Full-words explanation of the short "W${n}" label, shown as the line's tooltip.
  String _tripPurchaseTooltip(ProductTripPurchase purchase) {
    int week = purchase.weekIndex + 1;
    if (purchase.isFirstTrip) return "W$week = first shop visit, the day before week $week starts.";
    return "W$week = shop visit the day before week $week starts.";
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
                        for (final ProductTripPurchase purchase in tripPurchases)
                          Tooltip(
                            message: _tripPurchaseTooltip(purchase),
                            child: Text(
                              _tripPurchaseLabel(purchase),
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.right,
                            ),
                          ),
                      ],
                    )
                  : Text(
                      "Buy $packsToBuy ${_packWord(packsToBuy)}",
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
