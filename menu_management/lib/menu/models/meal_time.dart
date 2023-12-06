import 'package:menu_management/menu/enums/meal_type.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';

part 'meal_time.freezed.dart';
part 'meal_time.g.dart';

@freezed
class MealTime with _$MealTime {
  const factory MealTime({
    /// 0 = Saturday, 1 = Sunday, 2 = Monday, 3 = Tuesday, 4 = Wednesday, 5 = Thursday, 6 = Friday
    required int weekDay,
    required MealType mealType,
  }) = _MealTime;

  factory MealTime.fromJson(Map<String, Object?> json) => _$MealTimeFromJson(json);
}
