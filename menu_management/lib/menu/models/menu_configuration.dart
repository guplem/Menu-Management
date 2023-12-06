import 'package:menu_management/menu/enums/meal_type.dart';
import 'package:menu_management/menu/models/cooking.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';
import 'package:menu_management/menu/models/meal_time.dart';

part 'menu_configuration.freezed.dart';
part 'menu_configuration.g.dart';

@freezed
class MenuConfiguration with _$MenuConfiguration {
  const factory MenuConfiguration({
    required MealTime mealTime,
    @Default(true)
    bool requiresMeal,
    @Default(60)
    int availableCookingTime,
  }) = _Configuration;

  factory MenuConfiguration.fromJson(Map<String, Object?> json) => _$MenuConfigurationFromJson(json);
}
