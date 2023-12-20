import 'package:freezed_annotation/freezed_annotation.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';

part 'output.freezed.dart';
part 'output.g.dart';

@freezed
class Output with _$Output {
  const factory Output({
    required String id,
    required String description,
  }) = _Output;

  factory Output.fromJson(Map<String, Object?> json) => _$OutputFromJson(json);
}
