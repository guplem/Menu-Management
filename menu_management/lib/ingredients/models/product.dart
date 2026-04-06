import "package:freezed_annotation/freezed_annotation.dart";
import "package:menu_management/recipes/enums/unit.dart";

part "product.freezed.dart";
part "product.g.dart";

@freezed
abstract class Product with _$Product {
  const factory Product({
    required String link,
    @Default(1) int itemsPerPack,
    required double quantityPerItem,
    required Unit unit,
  }) = _Product;

  factory Product.fromJson(Map<String, Object?> json) => _$ProductFromJson(json);

  const Product._();

  double get totalQuantityPerPack => itemsPerPack * quantityPerItem;

  int packsNeeded(double requiredAmount) {
    if (requiredAmount <= 0) return 0;
    final double totalQuantity = totalQuantityPerPack;
    if (totalQuantity <= 0) return 0;
    return (requiredAmount / totalQuantity).ceil();
  }

  String formatQuantityForDisplay(double requiredAmount, Unit requiredUnit) {
    String amountRounded = requiredAmount.toStringAsFixed(0);
    String unitName = requiredUnit.name;
    if (unit == requiredUnit) {
      int packs = packsNeeded(requiredAmount);
      String totalInPack = (packs * totalQuantityPerPack).toStringAsFixed(0);
      String packLabel = packs == 1 ? "pack" : "packs";
      return "$packs $packLabel ($totalInPack $unitName)";
    }
    return "$amountRounded $unitName";
  }
}
