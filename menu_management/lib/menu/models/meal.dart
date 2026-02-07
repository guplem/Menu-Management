// ignore: unused_import
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menu_management/menu/models/cooking.dart';
import 'package:menu_management/menu/models/meal_time.dart';

part 'meal.freezed.dart';
part 'meal.g.dart';

/// A meal is a cooking of a recipe at a certain time, for a menu
@freezed
class Meal with _$Meal {
  const factory Meal({required Cooking? cooking, required MealTime mealTime}) =
      _Meal;

  factory Meal.fromJson(Map<String, Object?> json) => _$MealFromJson(json);

  // Empty constant constructor. Must not have any parameter. Needed to be able to add non-static methods and getters
  const Meal._();

  Meal copyWithUpdatedCooking(Cooking? cooking) {
    return copyWith(cooking: cooking);
  }

  bool goesBefore(Meal meal) {
    return mealTime.goesBefore(meal.mealTime);
  }

  bool goesAfter(Meal meal) {
    return mealTime.goesAfter(meal.mealTime);
  }
}
