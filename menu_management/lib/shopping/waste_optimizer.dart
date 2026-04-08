import "package:menu_management/ingredients/models/product.dart";

class ProductRecommendation {
  const ProductRecommendation({
    required this.product,
    required this.packsNeeded,
    required this.overBuyWaste,
    required this.expiryWaste,
    required this.isViable,
  });

  final Product product;
  final int packsNeeded;
  final double overBuyWaste;
  final double expiryWaste;
  final bool isViable;

  double get totalWaste => overBuyWaste + expiryWaste;
}

/// Ranks products by total waste (over-buy + expiry) for a given required amount.
///
/// [totalNeeded] is the total amount needed in the product's unit.
/// [dailyUsage] is how much is consumed per day (for expiry calculations).
/// [products] is the list of available products to compare.
///
/// Returns recommendations sorted by total waste (lowest first).
/// The first viable product (isViable == true) is the recommended pick.
List<ProductRecommendation> rankProducts({
  required double totalNeeded,
  required double dailyUsage,
  required List<Product> products,
}) {
  if (products.isEmpty) return const [];

  List<ProductRecommendation> recommendations = products.map((Product product) {
    int packs = product.packsNeeded(totalNeeded);
    double bought = packs * product.totalQuantityPerPack;
    double overBuyWaste = bought - totalNeeded;
    double expiryWaste = 0;
    bool viable = true;

    int? shelfLife = product.shelfLifeDays;

    if (shelfLife != null && dailyUsage > 0 && packs > 0) {
      if (product.itemsPerPack > 1) {
        // Sealed individual items: each is opened independently
        double daysToConsumeItem = product.quantityPerItem / dailyUsage;
        if (daysToConsumeItem > shelfLife) {
          double wastePerItem = product.quantityPerItem - dailyUsage * shelfLife;
          expiryWaste = wastePerItem.clamp(0.0, product.quantityPerItem) * packs * product.itemsPerPack;
          viable = false;
        }
      } else {
        // Single container: whole pack opens at once
        double daysToConsumePack = product.totalQuantityPerPack / dailyUsage;
        if (daysToConsumePack > shelfLife) {
          double wastePer = product.totalQuantityPerPack - dailyUsage * shelfLife;
          expiryWaste = wastePer.clamp(0.0, product.totalQuantityPerPack) * packs;
          viable = false;
        }
      }
    }

    return ProductRecommendation(
      product: product,
      packsNeeded: packs,
      overBuyWaste: overBuyWaste,
      expiryWaste: expiryWaste,
      isViable: viable,
    );
  }).toList();

  recommendations.sort((a, b) => a.totalWaste.compareTo(b.totalWaste));
  return recommendations;
}
