// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'instruction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InstructionImpl _$$InstructionImplFromJson(Map<String, dynamic> json) =>
    _$InstructionImpl(
      ingredientUsage: (json['ingredientUsage'] as List<dynamic>?)
              ?.map((e) => IngredientUsage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      description: json['description'] as String,
    );

Map<String, dynamic> _$$InstructionImplToJson(_$InstructionImpl instance) =>
    <String, dynamic>{
      'ingredientUsage': instance.ingredientUsage,
      'description': instance.description,
    };
