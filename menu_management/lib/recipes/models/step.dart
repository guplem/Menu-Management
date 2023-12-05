import 'package:menu_management/ingredients/models/ingredient.dart';
import 'package:menu_management/recipes/models/ingredient_usage.dart';
import 'package:menu_management/recipes/models/quantity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';

part 'step.freezed.dart';
part 'step.g.dart';

@freezed
class Step with $Step {
  const factory Step({
    required List<IngredientUsage> ingredientUsage,
    required String description,
  }) = _Step;

  factory Step.fromJson(Map<String, Object?> json) => _$StepFromJson(json);
}
