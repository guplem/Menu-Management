import "package:menu_management/menu/enums/meal_type.dart";
import "package:menu_management/menu/enums/week_day.dart";
import "package:freezed_annotation/freezed_annotation.dart";
// ignore: unused_import
import "package:flutter/foundation.dart";

part "meal_time.freezed.dart";
part "meal_time.g.dart";

@freezed
class MealTime with _$MealTime {
  const factory MealTime({
    /// 0 = Saturday, 1 = Sunday, 2 = Monday, 3 = Tuesday, 4 = Wednesday, 5 = Thursday, 6 = Friday
    required WeekDay weekDay,
    required MealType mealType,
  }) = _MealTime;

  factory MealTime.fromJson(Map<String, Object?> json) =>
      _$MealTimeFromJson(json);

  const MealTime._();

  bool isSameTime(MealTime other) {
    return weekDay == other.weekDay && mealType == other.mealType;
  }

  bool goesBefore(MealTime other) {
    if (weekDay == other.weekDay) {
      return mealType.goesBefore(other.mealType);
    }
    return weekDay.goesBefore(other.weekDay);
  }

  bool goesAfter(MealTime other) {
    if (weekDay == other.weekDay) {
      return mealType.goesAfter(other.mealType);
    }
    return weekDay.goesAfter(other.weekDay);
  }
}
