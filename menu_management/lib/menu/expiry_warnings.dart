import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/menu/models/cooking.dart";
import "package:menu_management/menu/models/meal.dart";
import "package:menu_management/menu/models/sub_meal.dart";
import "package:menu_management/recipes/models/ingredient_usage.dart";
import "package:menu_management/recipes/models/instruction.dart";
import "package:menu_management/recipes/models/recipe.dart";

/// Severity of a [MealExpiryWarning].
///
/// - [impossible]: every product variant is past sealed shelf life and none can be frozen.
///   The user cannot get fresh ingredients to this meal day under the single-trip assumption.
/// - [freezeRequired]: every product variant is past sealed shelf life, but at least one
///   variant can be frozen on arrival, so the meal is still doable.
enum MealExpirySeverity { impossible, freezeRequired }

/// A single ingredient on a meal that may have already expired by the meal's day.
class MealExpiryWarning {
  const MealExpiryWarning({required this.ingredient, required this.products, required this.severity});

  final Ingredient ingredient;

  /// All product variants of [ingredient] (every one of them may be expired by the meal day,
  /// otherwise the warning would not have been produced).
  final List<Product> products;

  final MealExpirySeverity severity;
}

/// Returns the expiry warnings for a single [subMeal] on [absoluteDayIndex] of a multi-week menu.
///
/// Assumes a single shopping trip the day before menu day 0 (purchase day = -1),
/// so days elapsed from purchase to a meal at day D is D + 1.
///
/// An ingredient warns when ALL of its product variants may be expired by [absoluteDayIndex]
/// (per [Product.mayBeExpiredOnDay]). If any variant survives (long-enough sealed shelf life
/// or null = indefinite when sealed), no warning fires for that ingredient -- the user can buy
/// the surviving variant.
///
/// The [MealExpiryWarning.severity] is [MealExpirySeverity.freezeRequired] when at least one
/// of the expired variants has [Product.canBeFrozen] set; the user can still buy on day -1 and
/// freeze on arrival. Otherwise it is [MealExpirySeverity.impossible].
///
/// Returns an empty list when [SubMeal.cooking] is null, when the cooking is a leftover
/// (yield == 0, since the raw ingredients were already consumed on the original cook day),
/// or when the recipe ID is unknown.
///
/// Ingredients with zero products are skipped (no shelf-life data to base a warning on).
List<MealExpiryWarning> expiryWarningsForSubMeal({
  required SubMeal subMeal,
  required int absoluteDayIndex,
  required List<Recipe> recipes,
  required List<Ingredient> ingredients,
}) {
  Cooking? cooking = subMeal.cooking;
  if (cooking == null) return const [];
  if (cooking.yield == 0) return const [];
  Recipe? recipe = recipes.firstWhereOrNull((Recipe r) => r.id == cooking.recipeId);
  if (recipe == null) return const [];

  Set<String> seenIngredientIds = {};
  List<MealExpiryWarning> warnings = [];

  for (Instruction instruction in recipe.instructions) {
    for (IngredientUsage usage in instruction.ingredientsUsed) {
      if (!seenIngredientIds.add(usage.ingredient)) continue;
      Ingredient? ingredient = ingredients.firstWhereOrNull((Ingredient i) => i.id == usage.ingredient);
      if (ingredient == null) continue;
      if (ingredient.products.isEmpty) continue;

      bool anySurvives = ingredient.products.any((Product p) => !p.mayBeExpiredOnDay(absoluteDayIndex));
      if (anySurvives) continue;

      bool anyFreezable = ingredient.products.any((Product p) => p.canBeFrozen);
      MealExpirySeverity severity = anyFreezable ? MealExpirySeverity.freezeRequired : MealExpirySeverity.impossible;
      warnings.add(MealExpiryWarning(ingredient: ingredient, products: ingredient.products, severity: severity));
    }
  }

  return warnings;
}

/// Aggregates [expiryWarningsForSubMeal] across every sub-meal in [meal], deduplicating
/// warnings that name the same ingredient (e.g., when two sibling sub-meals both use banana).
///
/// Prefer [expiryWarningsForSubMeal] when displaying a warning next to a specific sub-meal:
/// rendering meal-level warnings on each sub-meal would attribute one sub-meal's ingredient
/// risk to another sibling sub-meal that does not actually use that ingredient.
List<MealExpiryWarning> expiryWarningsForMeal({
  required Meal meal,
  required int absoluteDayIndex,
  required List<Recipe> recipes,
  required List<Ingredient> ingredients,
}) {
  Set<String> seenIngredientIds = {};
  List<MealExpiryWarning> warnings = [];

  for (SubMeal subMeal in meal.subMeals) {
    List<MealExpiryWarning> subWarnings = expiryWarningsForSubMeal(
      subMeal: subMeal,
      absoluteDayIndex: absoluteDayIndex,
      recipes: recipes,
      ingredients: ingredients,
    );
    for (MealExpiryWarning w in subWarnings) {
      if (seenIngredientIds.add(w.ingredient.id)) warnings.add(w);
    }
  }

  return warnings;
}
