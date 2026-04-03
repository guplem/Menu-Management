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
    return (requiredAmount / totalQuantityPerPack).ceil();
  }

  String formatQuantityForDisplay(double requiredAmount, Unit requiredUnit) {
    String amountRounded = requiredAmount.toStringAsFixed(0);
    String unitName = requiredUnit.toString().split(".").last;
    if (unit == requiredUnit) {
      int packs = packsNeeded(requiredAmount);
      String totalInPack = (packs * totalQuantityPerPack).toStringAsFixed(0);
      return "$packs packs ($totalInPack $unitName)";
    }
    return "$amountRounded $unitName";
  }
}
