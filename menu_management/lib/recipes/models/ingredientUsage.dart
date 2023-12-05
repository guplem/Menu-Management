import 'package:menu_management/ingredients/models/ingredient.dart';
import 'package:menu_management/recipes/models/quantity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';

part 'step.freezed.dart';
part 'step.g.dart';

@freezed
class IngredientUsage with $IngredientUsage {
  const factory IngredientUsage({
    required Ingredient ingredient,
    required Quantity quantity,
  }) = _IngredientUsage;

  factory IngredientUsage.fromJson(Map<String, Object?> json) => _$IngredientUsageFromJson(json);
}
