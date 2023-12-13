// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecipeImpl _$$RecipeImplFromJson(Map<String, dynamic> json) => _$RecipeImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      instructions: (json['instructions'] as List<dynamic>?)
              ?.map((e) => Instruction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      carbs: json['carbs'] as bool? ?? false,
      proteins: json['proteins'] as bool? ?? false,
      vegetables: json['vegetables'] as bool? ?? false,
      type: $enumDecodeNullable(_$RecipeTypeEnumMap, json['type']),
      maxStorageDays: json['maxStorageDays'] as int? ?? 7,
    );

Map<String, dynamic> _$$RecipeImplToJson(_$RecipeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'instructions': instance.instructions,
      'carbs': instance.carbs,
      'proteins': instance.proteins,
      'vegetables': instance.vegetables,
      'type': _$RecipeTypeEnumMap[instance.type],
      'maxStorageDays': instance.maxStorageDays,
    };

const _$RecipeTypeEnumMap = {
  RecipeType.breakfast: 'breakfast',
  RecipeType.heavy: 'heavy',
  RecipeType.light: 'light',
  RecipeType.snack: 'snack',
  RecipeType.dessert: 'dessert',
};
