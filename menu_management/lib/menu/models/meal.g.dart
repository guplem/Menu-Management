// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Meal _$MealFromJson(Map<String, dynamic> json) => _Meal(
  cooking: json['cooking'] == null ? null : Cooking.fromJson(json['cooking'] as Map<String, dynamic>),
  mealTime: MealTime.fromJson(json['mealTime'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MealToJson(_Meal instance) => <String, dynamic>{'cooking': instance.cooking, 'mealTime': instance.mealTime};
