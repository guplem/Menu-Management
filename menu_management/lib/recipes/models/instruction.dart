import 'package:menu_management/recipes/models/ingredient_usage.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';

part 'instruction.freezed.dart';
part 'instruction.g.dart';

@freezed
class Instruction with _$Instruction {
  const factory Instruction({
    required String id,
    @Default([])
    List<IngredientUsage> ingredientUsage,
    required String description,
  }) = _Instruction;

  factory Instruction.fromJson(Map<String, Object?> json) => _$InstructionFromJson(json);
}
