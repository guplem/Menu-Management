import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/menu/models/cooking.dart";
import "package:menu_management/menu/models/meal.dart";
import "package:menu_management/menu/models/sub_meal.dart";
import "package:menu_management/recipes/models/ingredient_usage.dart";
import "package:menu_management/recipes/models/instruction.dart";
import "package:menu_management/recipes/models/recipe.dart";

/// A single ingredient on a meal that may have already expired by the meal's day.
class MealExpiryWarning {
  const MealExpiryWarning({required this.ingredient, required this.products});

  final Ingredient ingredient;

  /// All product variants of [ingredient] (every one of them may be expired by the meal day,
  /// otherwise the warning would not have been produced).
  final List<Product> products;
}

/// Returns the expiry warnings for [meal] on [absoluteDayIndex] of a multi-week menu.
///
/// Assumes a single shopping trip the day before menu day 0 (purchase day = -1),
/// so days elapsed from purchase to a meal at day D is D + 1.
///
/// An ingredient warns when ALL of its product variants may be expired by [absoluteDayIndex]
/// (per [Product.mayBeExpiredOnDay]). If any variant survives (long-enough sealed shelf life
/// or null = indefinite when sealed), no warning fires for that ingredient -- the user can buy
/// the surviving variant.
///
/// Ingredients with zero products are skipped (no shelf-life data to base a warning on).
List<MealExpiryWarning> expiryWarningsForMeal({
  required Meal meal,
  required int absoluteDayIndex,
  required List<Recipe> recipes,
  required List<Ingredient> ingredients,
}) {
  Set<String> seenIngredientIds = {};
  List<MealExpiryWarning> warnings = [];

  for (SubMeal subMeal in meal.subMeals) {
    Cooking? cooking = subMeal.cooking;
    if (cooking == null) continue;
    Recipe? recipe = recipes.firstWhereOrNull((Recipe r) => r.id == cooking.recipeId);
    if (recipe == null) continue;

    for (Instruction instruction in recipe.instructions) {
      for (IngredientUsage usage in instruction.ingredientsUsed) {
        if (!seenIngredientIds.add(usage.ingredient)) continue;
        Ingredient? ingredient = ingredients.firstWhereOrNull((Ingredient i) => i.id == usage.ingredient);
        if (ingredient == null) continue;
        if (ingredient.products.isEmpty) continue;

        bool anySurvives = ingredient.products.any((Product p) => !p.mayBeExpiredOnDay(absoluteDayIndex));
        if (anySurvives) continue;

        warnings.add(MealExpiryWarning(ingredient: ingredient, products: ingredient.products));
      }
    }
  }

  return warnings;
}
