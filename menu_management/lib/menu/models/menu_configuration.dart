import 'package:menu_management/menu/menu_provider.dart';
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
    int? availableCookingTimeMinutes,
  }) = _MenuConfiguration;

  factory MenuConfiguration.fromJson(Map<String, Object?> json) => _$MenuConfigurationFromJson(json);

  // Empty constant constructor. Must not have any parameter. Needed to be able to add non-static methods and getters
  const MenuConfiguration._();

  void saveToProvider() {
    MenuProvider.update(newConfiguration: this);
  }
}
