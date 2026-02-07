import 'package:menu_management/recipes/models/ingredient_usage.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';
import 'package:menu_management/recipes/models/result.dart';

part 'instruction.freezed.dart';
part 'instruction.g.dart';

@freezed
class Instruction with _$Instruction {
  const factory Instruction({
    required String id,
    @Default([]) List<IngredientUsage> ingredientsUsed,
    @Default(10) int workingTimeMinutes,
    @Default(10) int cookingTimeMinutes,
    required String description,
    @Default([]) List<Result> outputs,
    @Default([]) List<String> inputs,
  }) = _Instruction;

  factory Instruction.fromJson(Map<String, Object?> json) =>
      _$InstructionFromJson(json);

  // Empty constant constructor. Must not have any parameter. Needed to be able to add non-static methods and getters
  const Instruction._();

  int get totalTimeMinutes => workingTimeMinutes + cookingTimeMinutes;
}
