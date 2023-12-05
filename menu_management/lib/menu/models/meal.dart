import 'package:menu_management/menu/models/cooking.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';

part 'meal.freezed.dart';
part 'meal.g.dart';

@freezed
class Meal with _$Meal {
  const factory Meal({
    required List<Cooking> recipes,
  }) = _Meal;

  factory Meal.fromJson(Map<String, Object?> json) => _$MealFromJson(json);
}
