import "package:freezed_annotation/freezed_annotation.dart";
// ignore: unused_import
import "package:flutter/foundation.dart";

part "result.freezed.dart";
part "result.g.dart";

@freezed
class Result with _$Result {
  const factory Result({required String id, required String description}) = _Result;

  factory Result.fromJson(Map<String, Object?> json) => _$ResultFromJson(json);
}
