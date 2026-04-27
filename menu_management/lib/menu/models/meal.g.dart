// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Meal _$MealFromJson(Map<String, dynamic> json) => _Meal(
  mealTime: MealTime.fromJson(json['mealTime'] as Map<String, dynamic>),
  subMeals:
      (json['subMeals'] as List<dynamic>?)
          ?.map((e) => SubMeal.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$MealToJson(_Meal instance) => <String, dynamic>{
  'mealTime': instance.mealTime.toJson(),
  'subMeals': instance.subMeals.map((e) => e.toJson()).toList(),
};
