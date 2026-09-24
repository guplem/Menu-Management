import "package:freezed_annotation/freezed_annotation.dart";
import "package:menu_management/menu/models/meal_time.dart";
import "package:menu_management/recipes/models/quantity.dart";

part "ingredient_meal_requirement.freezed.dart";
part "ingredient_meal_requirement.g.dart";

/// Says which single meal needs an ingredient, and how much of it that meal needs.
///
/// IngredientSource groups the need per recipe, so it cannot say which day needs the
/// ingredient. This record keeps the meal: the week, the day and the meal slot ([mealTime]),
/// the sub-meal inside that slot, and the recipe. Use it to justify a shopping line.
///
/// [isCookEvent] is false when the meal eats leftovers of an earlier cook. Such a meal still
/// needs the ingredient, because the earlier cook buys the food for it.
///
/// [cookDayIndex] is the day of the cook event that cooks the food of this meal, counted from the
/// first day of the menu (`weekIndex * 7 + weekDay`, the same count as `CookingEvent.dayIndex`).
/// For a leftover meal it is an earlier day, and it can be in an earlier week, because a cook
/// event late in one week can feed a meal of the next week. The shopping trip that buys the food
/// is the trip that buys that cook day (`TripItem.cookDays`), so use [cookDayIndex] to put the
/// meal under a trip.
///
/// The record holds the recipe id, never the Recipe object, the same way Cooking does.
@freezed
abstract class IngredientMealRequirement with _$IngredientMealRequirement {
  const factory IngredientMealRequirement({
    required int weekIndex,
    required int cookDayIndex,
    required MealTime mealTime,
    required int subMealIndex,
    required String recipeId,
    required String recipeName,
    required int people,
    required bool isCookEvent,
    @Default([]) List<Quantity> quantities,
  }) = _IngredientMealRequirement;

  const IngredientMealRequirement._();

  /// The week of the cook event that cooks the food of this meal.
  int get cookWeekIndex => cookDayIndex ~/ 7;

  factory IngredientMealRequirement.fromJson(Map<String, Object?> json) => _$IngredientMealRequirementFromJson(json);
}
