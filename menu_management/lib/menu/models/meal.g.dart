// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MealImpl _$$MealImplFromJson(Map<String, dynamic> json) => _$MealImpl(
      cookings: (json['cookings'] as List<dynamic>)
          .map((e) => Cooking.fromJson(e as Map<String, dynamic>))
          .toList(),
      mealTime: MealTime.fromJson(json['mealTime'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$MealImplToJson(_$MealImpl instance) =>
    <String, dynamic>{
      'cookings': instance.cookings,
      'mealTime': instance.mealTime,
    };
