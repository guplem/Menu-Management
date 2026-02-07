// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_configuration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MenuConfigurationImpl _$$MenuConfigurationImplFromJson(Map<String, dynamic> json) => _$MenuConfigurationImpl(
  mealTime: MealTime.fromJson(json['mealTime'] as Map<String, dynamic>),
  requiresMeal: json['requiresMeal'] as bool? ?? true,
  availableCookingTimeMinutes: (json['availableCookingTimeMinutes'] as num?)?.toInt() ?? 60,
);

Map<String, dynamic> _$$MenuConfigurationImplToJson(_$MenuConfigurationImpl instance) => <String, dynamic>{
  'mealTime': instance.mealTime,
  'requiresMeal': instance.requiresMeal,
  'availableCookingTimeMinutes': instance.availableCookingTimeMinutes,
};
