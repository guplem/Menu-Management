import "package:freezed_annotation/freezed_annotation.dart";
import "package:menu_management/menu/enums/meal_type.dart";
import "package:menu_management/menu/menu_provider.dart";
import "package:menu_management/menu/models/meal_time.dart";

part "menu_configuration.freezed.dart";
part "menu_configuration.g.dart";

@freezed
abstract class MenuConfiguration with _$MenuConfiguration {
  const factory MenuConfiguration({required MealTime mealTime, @Default(true) bool requiresMeal, @Default(60) int availableCookingTimeMinutes}) =
      _MenuConfiguration;

  factory MenuConfiguration.fromJson(Map<String, Object?> json) => _$MenuConfigurationFromJson(json);

  // Empty constant constructor. Must not have any parameter. Needed to be able to add non-static methods and getters
  const MenuConfiguration._();

  bool get isMeal => mealTime.mealType == MealType.lunch || mealTime.mealType == MealType.dinner;

  bool get canBeCookedAtTheSpot => requiresMeal && availableCookingTimeMinutes > 0;

  void saveToProvider() {
    MenuProvider.update(newConfiguration: this);
  }

  bool goesBefore(MenuConfiguration b) {
    return mealTime.goesBefore(b.mealTime);
  }
}
