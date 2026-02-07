import "package:freezed_annotation/freezed_annotation.dart";
import "package:menu_management/recipes/enums/unit.dart";

part "quantity.freezed.dart";
part "quantity.g.dart";

@freezed
abstract class Quantity with _$Quantity {
  const factory Quantity({required double amount, required Unit unit}) = _Quantity;

  factory Quantity.fromJson(Map<String, Object?> json) => _$QuantityFromJson(json);
}
