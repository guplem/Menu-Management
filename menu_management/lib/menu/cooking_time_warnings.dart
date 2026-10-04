import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/menu/models/cooking.dart";
import "package:menu_management/menu/models/menu_configuration.dart";
import "package:menu_management/menu/models/sub_meal.dart";
import "package:menu_management/recipes/models/recipe.dart";

/// A sub-meal whose recipe needs more time than its meal slot has to cook.
class CookingTimeWarning {
  const CookingTimeWarning({required this.recipe, required this.availableMinutes});

  final Recipe recipe;

  /// The time to cook of the meal slot, from [MenuConfiguration.availableCookingTimeMinutes].
  final int availableMinutes;

  /// The work time plus the cooking time of [recipe].
  int get requiredMinutes => recipe.totalTimeMinutes;
}

/// Returns the cooking time warning for a single [subMeal] in the slot of [configuration], or null.
///
/// The warning fires when [Recipe.totalTimeMinutes] is more than [MenuConfiguration.availableCookingTimeMinutes].
/// [Recipe.fitsConfiguration] makes the generator apply the same rule, so the warning mostly marks
/// a recipe that the user picked by hand, or a slot whose time changed after the generation.
///
/// Returns null when [SubMeal.cooking] is null, when the cooking is a leftover
/// (yield == 0, because the cook event happens at an earlier meal), or when the recipe ID is unknown.
CookingTimeWarning? cookingTimeWarningForSubMeal({
  required SubMeal subMeal,
  required MenuConfiguration configuration,
  required List<Recipe> recipes,
}) {
  Cooking? cooking = subMeal.cooking;
  if (cooking == null) return null;
  if (cooking.yield == 0) return null;
  Recipe? recipe = recipes.firstWhereOrNull((Recipe r) => r.id == cooking.recipeId);
  if (recipe == null) return null;
  if (recipe.totalTimeMinutes <= configuration.availableCookingTimeMinutes) return null;
  return CookingTimeWarning(recipe: recipe, availableMinutes: configuration.availableCookingTimeMinutes);
}

/// The tooltip text of the warning icon on the menu page.
String cookingTimeWarningMessage(CookingTimeWarning warning) {
  String available = warning.availableMinutes > 0 ? "this meal has only ${warning.availableMinutes} min" : "this meal has no time to cook";
  return "Not enough time to cook this dish.\nIt needs ${warning.requiredMinutes} min, but $available.";
}
