import "dart:io";

import "package:flutter/material.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/shopping/waste_optimizer.dart";
import "package:menu_management/theme/theme_custom.dart";

class ShoppingProductRow extends StatelessWidget {
  const ShoppingProductRow({
    super.key,
    required this.product,
    required this.recommendation,
    required this.isBestOption,
    required this.packsToBuy,
  });

  final Product product;
  final ProductRecommendation recommendation;

  /// True when this product's totalWaste equals the minimum among all alternatives
  /// (includes ties and single-product ingredients).
  final bool isBestOption;
  final int packsToBuy;

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
        labelStyle: TextStyle(color: ColorScheme.fromSeed(seedColor: Colors.amber, brightness: Theme.of(context).brightness).onPrimaryContainer, fontSize: 12),
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
                  if (packLabel == null || packLabel != totalLabel) Text(totalLabel, style: packLabel != null ? Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor) : Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Waste status chip (shown for all products)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildChip(context),
            ),

            // Product link button
            IconButton(
              icon: const Icon(Icons.open_in_new_rounded, size: 20),
              tooltip: "Open product page",
              onPressed: product.link.isEmpty ? null : () => Process.run("start", [product.link], runInShell: true),
            ),

            const Spacer(),

            // Packs to buy (far right)
            SizedBox(
              width: 100,
              child: covered
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [Icon(Icons.check_rounded, color: Theme.of(context).hintColor, size: 18), const SizedBox(width: 4), Text("Covered", style: TextStyle(color: Theme.of(context).hintColor))],
                    )
                  : Text("Buy $packsToBuy ${product.itemsPerPack == 1 ? (packsToBuy == 1 ? "piece" : "pieces") : (packsToBuy == 1 ? "pack" : "packs")}", style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.right),
            ),
          ],
        ),
      ),
    );
  }
}
