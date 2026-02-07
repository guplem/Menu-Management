// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_configuration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MenuConfiguration _$MenuConfigurationFromJson(Map<String, dynamic> json) =>
    _MenuConfiguration(
      mealTime: MealTime.fromJson(json['mealTime'] as Map<String, dynamic>),
      requiresMeal: json['requiresMeal'] as bool? ?? true,
      availableCookingTimeMinutes:
          (json['availableCookingTimeMinutes'] as num?)?.toInt() ?? 60,
    );

Map<String, dynamic> _$MenuConfigurationToJson(_MenuConfiguration instance) =>
    <String, dynamic>{
      'mealTime': instance.mealTime,
      'requiresMeal': instance.requiresMeal,
      'availableCookingTimeMinutes': instance.availableCookingTimeMinutes,
    };
