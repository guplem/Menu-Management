// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Recipe _$RecipeFromJson(Map<String, dynamic> json) => _Recipe(
  id: json['id'] as String,
  name: json['name'] as String,
  instructions:
      (json['instructions'] as List<dynamic>?)
          ?.map((e) => Instruction.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  carbs: json['carbs'] as bool? ?? true,
  proteins: json['proteins'] as bool? ?? true,
  vegetables: json['vegetables'] as bool? ?? true,
  type:
      $enumDecodeNullable(_$RecipeTypeEnumMap, json['type']) ?? RecipeType.meal,
  lunch: json['lunch'] as bool? ?? true,
  dinner: json['dinner'] as bool? ?? true,
  canBeStored: json['canBeStored'] as bool? ?? true,
  includeInMenuGeneration: json['includeInMenuGeneration'] as bool? ?? true,
);

Map<String, dynamic> _$RecipeToJson(_Recipe instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'instructions': instance.instructions,
  'carbs': instance.carbs,
  'proteins': instance.proteins,
  'vegetables': instance.vegetables,
  'type': _$RecipeTypeEnumMap[instance.type]!,
  'lunch': instance.lunch,
  'dinner': instance.dinner,
  'canBeStored': instance.canBeStored,
  'includeInMenuGeneration': instance.includeInMenuGeneration,
};

const _$RecipeTypeEnumMap = {
  RecipeType.breakfast: 'breakfast',
  RecipeType.meal: 'meal',
  RecipeType.snack: 'snack',
  RecipeType.dessert: 'dessert',
};
