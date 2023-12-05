import 'package:menu_management/recipes/models/step.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';

part 'recipe.freezed.dart';
part 'recipe.g.dart';

@freezed
class Recipe with $Recipe {
  const factory Recipe({
    required String name,
    @Default([]) List<Step> steps,
    @Default(false) bool carbs,
    @Default(false) bool proteins,
    @Default(false) bool vegetables,
  }) = _Recipe;

  factory Recipe.fromJson(Map<String, Object?> json) => _$RecipeFromJson(json);
}
