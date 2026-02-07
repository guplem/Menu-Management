// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Menu _$MenuFromJson(Map<String, dynamic> json) => _Menu(
  meals:
      (json['meals'] as List<dynamic>?)
          ?.map((e) => Meal.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$MenuToJson(_Menu instance) => <String, dynamic>{
  'meals': instance.meals,
};
