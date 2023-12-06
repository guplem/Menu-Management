// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_configuration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConfigurationImpl _$$ConfigurationImplFromJson(Map<String, dynamic> json) =>
    _$ConfigurationImpl(
      mealTime: MealTime.fromJson(json['mealTime'] as Map<String, dynamic>),
      requiresMeal: json['requiresMeal'] as bool? ?? true,
      availableCookingTime: json['availableCookingTime'] as int? ?? 60,
    );

Map<String, dynamic> _$$ConfigurationImplToJson(_$ConfigurationImpl instance) =>
    <String, dynamic>{
      'mealTime': instance.mealTime,
      'requiresMeal': instance.requiresMeal,
      'availableCookingTime': instance.availableCookingTime,
    };
