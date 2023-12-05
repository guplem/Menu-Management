import 'package:menu_management/recipes/models/recipe.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';

part 'cooking.freezed.dart';
part 'cooking.g.dart';

@freezed
class Cooking with $Cooking {
  const factory Cooking({
    required Recipe recipe,
    /// The amount to cook. [yield] = persons * meals. 0 means it should already be cooked.
    required int yield,
  }) = _Cooking;

  factory Cooking.fromJson(Map<String, Object?> json) => _$CookingFromJson(json);
}
