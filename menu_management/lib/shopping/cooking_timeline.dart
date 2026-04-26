import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/menu/models/meal.dart";
import "package:menu_management/menu/models/menu.dart";
import "package:menu_management/menu/models/multi_week_menu.dart";
import "package:menu_management/recipes/enums/unit.dart";
import "package:menu_management/recipes/models/ingredient_usage.dart";
import "package:menu_management/recipes/models/instruction.dart";
import "package:menu_management/recipes/models/quantity.dart";
import "package:menu_management/recipes/models/recipe.dart";

/// A single cooking event where an ingredient is used on a specific day.
class CookingEvent {
  const CookingEvent({required this.dayIndex, required this.quantities});

  /// 0-based absolute day index: weekIndex * 7 + weekDay.value.
  final int dayIndex;

  /// Raw quantities used in this cooking event (may contain multiple units).
  final List<Quantity> quantities;

  /// Returns the total amount in the given [targetUnit], converting via grams when possible.
  /// [toGrams] and [fromGrams] are the ingredient's conversion functions.
  double amountInUnit(Unit targetUnit, {required double? Function(Quantity) toGrams, required double? Function(double, Unit) fromGrams}) {
    double total = 0;
    for (Quantity q in quantities) {
      if (q.unit == targetUnit) {
        total += q.amount;
      } else {
        double? grams = toGrams(q);
        if (grams != null) {
          double? converted = fromGrams(grams, targetUnit);
          if (converted != null) total += converted;
        }
      }
    }
    return total;
  }
}

/// Builds a timeline of cooking events per ingredient from a multi-week menu.
///
/// Returns a map from ingredient ID to a sorted list of [CookingEvent]s.
/// Events on the same day for the same ingredient are merged (quantities summed by unit).
Map<String, List<CookingEvent>> buildCookingTimeline({
  required MultiWeekMenu multiWeekMenu,
  required List<Recipe> recipes,
}) {
  // Intermediate: ingredientId -> dayIndex -> unit -> amount
  Map<String, Map<int, Map<Unit, double>>> raw = {};

  for (int weekIndex = 0; weekIndex < multiWeekMenu.weeks.length; weekIndex++) {
    Menu week = multiWeekMenu.weeks[weekIndex];
    Set<String> processedStorableRecipeIds = {};

    for (Meal meal in week.meals) {
      if (meal.cooking == null || meal.cooking!.yield <= 0) continue;

      String recipeId = meal.cooking!.recipeId;
      Recipe? recipe = recipes.firstWhereOrNull((Recipe r) => r.id == recipeId);
      if (recipe == null) continue;

      int peopleFactor;
      if (recipe.canBeStored) {
        if (processedStorableRecipeIds.contains(recipeId)) continue;
        processedStorableRecipeIds.add(recipeId);
        peopleFactor = week.meals.where((Meal m) => m.cooking?.recipeId == recipeId).fold(0, (int sum, Meal m) => sum + m.people);
      } else {
        peopleFactor = meal.people;
      }

      int dayIndex = weekIndex * 7 + meal.mealTime.weekDay.value;

      for (Instruction instruction in recipe.instructions) {
        for (IngredientUsage usage in instruction.ingredientsUsed) {
          String ingredientId = usage.ingredient;
          double amount = usage.quantity.amount * peopleFactor;

          raw[ingredientId] ??= {};
          raw[ingredientId]![dayIndex] ??= {};
          raw[ingredientId]![dayIndex]![usage.quantity.unit] = (raw[ingredientId]![dayIndex]![usage.quantity.unit] ?? 0) + amount;
        }
      }
    }
  }

  // Convert intermediate map to sorted CookingEvent lists
  Map<String, List<CookingEvent>> result = {};
  for (MapEntry<String, Map<int, Map<Unit, double>>> ingredientEntry in raw.entries) {
    List<CookingEvent> events = ingredientEntry.value.entries.map((MapEntry<int, Map<Unit, double>> dayEntry) {
      List<Quantity> quantities = dayEntry.value.entries.map((MapEntry<Unit, double> unitEntry) => Quantity(amount: unitEntry.value, unit: unitEntry.key)).toList();
      return CookingEvent(dayIndex: dayEntry.key, quantities: quantities);
    }).toList();
    events.sort((CookingEvent a, CookingEvent b) => a.dayIndex.compareTo(b.dayIndex));
    result[ingredientEntry.key] = events;
  }

  return result;
}
