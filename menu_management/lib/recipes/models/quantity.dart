import 'package:menu_management/recipes/enums/unit.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';

part 'quantity.freezed.dart';
part 'quantity.g.dart';

@freezed
class Quantity with _$Quantity {
  const factory Quantity({required double amount, required Unit unit}) =
      _Quantity;

  factory Quantity.fromJson(Map<String, Object?> json) =>
      _$QuantityFromJson(json);
}
