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
    @JsonKey(includeIfNull: false) int? shelfLifeDaysOpened,
    @JsonKey(includeIfNull: false) int? shelfLifeDaysClosed,
    @Default(false) bool canBeFrozen,
  }) = _Product;

  factory Product.fromJson(Map<String, Object?> json) => _$ProductFromJson(_migrateShelfLifeDays(json));

  /// Backward compatibility: legacy "shelfLifeDays" JSON key (formerly "days after opening")
  /// is mapped to [shelfLifeDaysOpened]. The new key takes precedence when both are present.
  static Map<String, Object?> _migrateShelfLifeDays(Map<String, Object?> json) {
    if (json.containsKey("shelfLifeDays") && !json.containsKey("shelfLifeDaysOpened")) {
      json = {...json, "shelfLifeDaysOpened": json["shelfLifeDays"]};
      json.remove("shelfLifeDays");
    }
    return json;
  }

  const Product._();

  double get totalQuantityPerPack => itemsPerPack * quantityPerItem;

  /// Whether this product may already be expired by [absoluteDayIndex] of the menu,
  /// assuming a single shopping trip the day before the menu starts (purchase day = -1).
  /// Returns false when [shelfLifeDaysClosed] is null (treated as indefinite when sealed).
  bool mayBeExpiredOnDay(int absoluteDayIndex) {
    final int? closed = shelfLifeDaysClosed;
    if (closed == null) return false;
    return absoluteDayIndex + 1 >= closed;
  }

  /// Returns a human-readable pack label, or null when a single-item pack has no extra info to show.
  ///
  /// - Pieces unit: "N pieces/pack" or "N piece/pack"
  /// - Multi-item weight/volume: "NxMunit" (e.g. "6x125grams")
  /// - Single-item weight/volume: null (redundant with total line)
  String? packLabel() {
    if (unit == Unit.pieces) {
      int total = (itemsPerPack * quantityPerItem).round();
      return "$total ${total == 1 ? "piece" : "pieces"}/pack";
    }
    if (itemsPerPack > 1) {
      return "${itemsPerPack}x${quantityPerItem.toStringAsFixed(0)}${unit.name}";
    }
    return null;
  }

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
