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
    required this.isRecommended,
    required this.packsToBuy,
  });

  final Product product;
  final ProductRecommendation recommendation;
  final bool isRecommended;
  final int packsToBuy;

  @override
  Widget build(BuildContext context) {
    String? packLabel = product.packLabel();
    String totalLabel = "${product.totalQuantityPerPack.toStringAsFixed(0)} ${product.unit.name}/pack";
    bool covered = packsToBuy <= 0;

    return FilledCard(
      outlined: true,
      borderColor: isRecommended ? ThemeCustom.colorScheme(context).tertiary : null,
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
                  Text(totalLabel, style: packLabel != null ? Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor) : Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Recommendation chip
            if (isRecommended)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Chip(
                  label: const Text("Best value"),
                  backgroundColor: ThemeCustom.colorScheme(context).tertiaryContainer,
                  labelStyle: TextStyle(color: ThemeCustom.colorScheme(context).onTertiaryContainer, fontSize: 12),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
              ),

            if (!recommendation.isViable && product.shelfLifeDays != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Tooltip(
                  message: "Expires in ${product.shelfLifeDays} days after opening",
                  child: Icon(Icons.warning_amber_rounded, color: ThemeCustom.colorScheme(context).error, size: 20),
                ),
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
                  : Text("Buy $packsToBuy", style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.right),
            ),
          ],
        ),
      ),
    );
  }
}
