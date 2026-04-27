import "package:freezed_annotation/freezed_annotation.dart";
import "package:menu_management/menu/models/cooking.dart";

part "sub_meal.freezed.dart";
part "sub_meal.g.dart";

/// A single plate/portion within a meal time slot.
/// Each sub-meal represents one person's (or group's) food at that time.
@freezed
abstract class SubMeal with _$SubMeal {
  const factory SubMeal({
    Cooking? cooking,
    @Default(1) int people,
  }) = _SubMeal;

  factory SubMeal.fromJson(Map<String, Object?> json) => _$SubMealFromJson(json);
}
