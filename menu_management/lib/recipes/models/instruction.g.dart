// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'instruction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InstructionImpl _$$InstructionImplFromJson(Map<String, dynamic> json) => _$InstructionImpl(
  id: json['id'] as String,
  ingredientsUsed: (json['ingredientsUsed'] as List<dynamic>?)?.map((e) => IngredientUsage.fromJson(e as Map<String, dynamic>)).toList() ?? const [],
  workingTimeMinutes: (json['workingTimeMinutes'] as num?)?.toInt() ?? 10,
  cookingTimeMinutes: (json['cookingTimeMinutes'] as num?)?.toInt() ?? 10,
  description: json['description'] as String,
  outputs: (json['outputs'] as List<dynamic>?)?.map((e) => Result.fromJson(e as Map<String, dynamic>)).toList() ?? const [],
  inputs: (json['inputs'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
);

Map<String, dynamic> _$$InstructionImplToJson(_$InstructionImpl instance) => <String, dynamic>{
  'id': instance.id,
  'ingredientsUsed': instance.ingredientsUsed,
  'workingTimeMinutes': instance.workingTimeMinutes,
  'cookingTimeMinutes': instance.cookingTimeMinutes,
  'description': instance.description,
  'outputs': instance.outputs,
  'inputs': instance.inputs,
};
