// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sub_meal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubMeal _$SubMealFromJson(Map<String, dynamic> json) => _SubMeal(
  cooking: json['cooking'] == null
      ? null
      : Cooking.fromJson(json['cooking'] as Map<String, dynamic>),
  people: (json['people'] as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$SubMealToJson(_SubMeal instance) => <String, dynamic>{
  'cooking': instance.cooking?.toJson(),
  'people': instance.people,
};
