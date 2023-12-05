// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecipeImpl _$$RecipeImplFromJson(Map<String, dynamic> json) => _$RecipeImpl(
      name: json['name'] as String,
      steps: (json['steps'] as List<dynamic>?)
              ?.map((e) => Step.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      carbs: json['carbs'] as bool? ?? false,
      proteins: json['proteins'] as bool? ?? false,
      vegetables: json['vegetables'] as bool? ?? false,
    );

Map<String, dynamic> _$$RecipeImplToJson(_$RecipeImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'steps': instance.steps,
      'carbs': instance.carbs,
      'proteins': instance.proteins,
      'vegetables': instance.vegetables,
    };
