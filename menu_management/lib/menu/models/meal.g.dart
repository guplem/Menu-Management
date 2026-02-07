// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MealImpl _$$MealImplFromJson(Map<String, dynamic> json) => _$MealImpl(
  cooking: json['cooking'] == null ? null : Cooking.fromJson(json['cooking'] as Map<String, dynamic>),
  mealTime: MealTime.fromJson(json['mealTime'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$MealImplToJson(_$MealImpl instance) => <String, dynamic>{'cooking': instance.cooking, 'mealTime': instance.mealTime};
