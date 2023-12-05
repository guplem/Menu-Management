// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MealImpl _$$MealImplFromJson(Map<String, dynamic> json) => _$MealImpl(
      recipes: (json['recipes'] as List<dynamic>)
          .map((e) => Cooking.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$MealImplToJson(_$MealImpl instance) =>
    <String, dynamic>{
      'recipes': instance.recipes,
    };
