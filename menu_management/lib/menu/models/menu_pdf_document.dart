import "package:freezed_annotation/freezed_annotation.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/menu/enums/meal_type.dart";
import "package:menu_management/menu/enums/week_day.dart";
import "package:menu_management/menu/menu_dates.dart";
import "package:menu_management/menu/models/cooking.dart";
import "package:menu_management/menu/models/meal.dart";
import "package:menu_management/menu/models/menu.dart";
import "package:menu_management/menu/models/multi_week_menu.dart";
import "package:menu_management/menu/models/sub_meal.dart";
import "package:menu_management/recipes/models/ingredient_usage.dart";
import "package:menu_management/recipes/models/instruction.dart";
import "package:menu_management/recipes/models/quantity.dart";
import "package:menu_management/recipes/models/recipe.dart";

part "menu_pdf_document.freezed.dart";

/// The name of an ingredient that the ingredient list does not hold.
///
/// A recipe can point at a deleted ingredient (ADR 0016). The line still shows the amount, so the
/// reader sees that the recipe needs something and can ask for it.
const String unknownIngredientName = "Unknown ingredient";

/// The dish name of a meal with no recipe, and of a meal whose recipe is deleted (ADR 0016).
/// The clipboard text writes the same dash, so both exports read the same.
const String emptyDishName = "-";

/// Where the food of one sub-meal comes from.
enum MenuPdfDishSource {
  /// The cook makes the food at this meal.
  cooked,

  /// The meal eats the leftovers of an earlier cook event.
  leftovers,

  /// The meal has no recipe yet.
  empty,
}

/// One sub-meal of one slot: one dish for one group of people.
@freezed
abstract class MenuPdfDish with _$MenuPdfDish {
  const factory MenuPdfDish({
    required String recipeName,
    required int people,
    required MenuPdfDishSource source,

    /// The servings that the cook makes at this meal, from `MultiWeekMenu.servingsForCookEvent`.
    /// It counts the later leftover meals too, so it is above [people] whenever the menu reuses
    /// the dish. It is 0 for every source but [MenuPdfDishSource.cooked].
    required int servingsToCook,
  }) = _MenuPdfDish;

  const MenuPdfDish._();

  /// Says what the reader must do with this dish, for example "cook 5 servings" or "leftovers".
  /// A dish with no recipe says nothing, because its name is already a dash.
  String get note {
    return switch (source) {
      MenuPdfDishSource.cooked => "cook $servingsToCook ${servingsToCook == 1 ? "serving" : "servings"}",
      MenuPdfDishSource.leftovers => "leftovers",
      MenuPdfDishSource.empty => "",
    };
  }
}

/// One cell of the week table: one meal slot of one day. A slot with no meal holds no dish.
@freezed
abstract class MenuPdfSlot with _$MenuPdfSlot {
  const factory MenuPdfSlot({required MealType mealType, @Default([]) List<MenuPdfDish> dishes}) = _MenuPdfSlot;
}

/// One row of the week table: one day, with its three meal slots in the order of the clock.
@freezed
abstract class MenuPdfDayRow with _$MenuPdfDayRow {
  const factory MenuPdfDayRow({required String dayLabel, required List<MenuPdfSlot> slots}) = _MenuPdfDayRow;
}

/// One week of the menu: one table of seven days.
@freezed
abstract class MenuPdfWeekSection with _$MenuPdfWeekSection {
  const factory MenuPdfWeekSection({required String title, required List<MenuPdfDayRow> days}) = _MenuPdfWeekSection;
}

/// One ingredient line, with the amount already scaled and written as text.
@freezed
abstract class MenuPdfIngredientLine with _$MenuPdfIngredientLine {
  const factory MenuPdfIngredientLine({required String ingredientName, required String amounts}) = _MenuPdfIngredientLine;
}

/// One numbered instruction of a recipe, with its times and the ingredients that it uses.
@freezed
abstract class MenuPdfStep with _$MenuPdfStep {
  const factory MenuPdfStep({
    required int number,
    required String description,
    required int workingTimeMinutes,
    required int cookingTimeMinutes,
    @Default([]) List<MenuPdfIngredientLine> ingredients,
  }) = _MenuPdfStep;
}

/// One recipe of the menu, with every amount scaled to the servings that the menu cooks.
@freezed
abstract class MenuPdfRecipeSection with _$MenuPdfRecipeSection {
  const factory MenuPdfRecipeSection({
    required String recipeName,
    required int servings,
    required int workingTimeMinutes,
    required int cookingTimeMinutes,
    @Default([]) List<MenuPdfIngredientLine> ingredients,
    @Default([]) List<MenuPdfStep> steps,
  }) = _MenuPdfRecipeSection;

  const MenuPdfRecipeSection._();

  int get totalTimeMinutes => workingTimeMinutes + cookingTimeMinutes;
}

/// Everything that the menu PDF prints, with no page, no font and no byte in it.
///
/// The renderer in `menu_pdf.dart` turns this into a PDF. The split keeps the content testable:
/// a test reads the rows, the labels and the amounts here, and never decodes a PDF.
@freezed
abstract class MenuPdfDocument with _$MenuPdfDocument {
  const factory MenuPdfDocument({
    required String title,
    @Default([]) List<MenuPdfWeekSection> weeks,
    @Default([]) List<MenuPdfRecipeSection> recipes,
  }) = _MenuPdfDocument;
}

/// Builds the content of the menu PDF.
///
/// Pure: it reads no provider, so a test calls it with no widget and no device (ADR 0009).
/// [recipes] and [ingredients] carry every name and every amount that the document needs.
///
/// The walk goes week by week, day by day, and slot by slot, so the recipe sections come in the
/// order of the first meal that eats each recipe.
MenuPdfDocument buildMenuPdfDocument({required MultiWeekMenu multiWeekMenu, required List<Recipe> recipes, required List<Ingredient> ingredients}) {
  final List<MenuPdfWeekSection> weekSections = [];

  // The id of every recipe that the menu eats, in the order of the first meal that eats it, which
  // is the order of the recipe sections. A recipe enters the list once.
  final List<String> recipeIdsInMenuOrder = [];

  for (int weekIndex = 0; weekIndex < multiWeekMenu.weeks.length; weekIndex++) {
    final Menu week = multiWeekMenu.weeks[weekIndex];
    final List<MenuPdfDayRow> days = [];

    for (WeekDay weekDay in WeekDay.values) {
      final List<Meal?> dayMeals = week.mealsOfDay(weekDay);
      final List<MenuPdfSlot> slots = [];

      for (int mealTypeIndex = 0; mealTypeIndex < MealType.values.length; mealTypeIndex++) {
        final Meal? meal = dayMeals[mealTypeIndex];
        final List<MenuPdfDish> dishes = [];

        for (int subMealIndex = 0; subMealIndex < (meal?.subMeals.length ?? 0); subMealIndex++) {
          final SubMeal subMeal = meal!.subMeals[subMealIndex];
          final Cooking? cooking = subMeal.cooking;

          if (cooking == null) {
            dishes.add(MenuPdfDish(recipeName: emptyDishName, people: subMeal.people, source: MenuPdfDishSource.empty, servingsToCook: 0));
            continue;
          }

          final Recipe? recipe = recipes.firstWhereOrNull((Recipe candidate) => candidate.id == cooking.recipeId);
          if (recipe == null) {
            // The menu points at a deleted recipe (ADR 0016). The PDF holds no section to cook
            // from, so the cell asks for no work and reads like an empty slot.
            dishes.add(MenuPdfDish(recipeName: emptyDishName, people: subMeal.people, source: MenuPdfDishSource.empty, servingsToCook: 0));
            continue;
          }
          if (!recipeIdsInMenuOrder.contains(recipe.id)) recipeIdsInMenuOrder.add(recipe.id);

          if (cooking.yield <= 0) {
            dishes.add(MenuPdfDish(recipeName: recipe.name, people: subMeal.people, source: MenuPdfDishSource.leftovers, servingsToCook: 0));
            continue;
          }

          final int servings = multiWeekMenu.servingsForCookEvent(
            cookWeekIndex: weekIndex,
            cookMealTime: meal.mealTime,
            subMealIndex: subMealIndex,
            recipes: recipes,
          );
          dishes.add(MenuPdfDish(recipeName: recipe.name, people: subMeal.people, source: MenuPdfDishSource.cooked, servingsToCook: servings));
        }

        slots.add(MenuPdfSlot(mealType: MealType.values[mealTypeIndex], dishes: dishes));
      }

      days.add(
        MenuPdfDayRow(
          dayLabel: menuDayLabel(startDate: multiWeekMenu.startDate, weekIndex: weekIndex, weekDay: weekDay),
          slots: slots,
        ),
      );
    }

    final String weekRange = menuWeekRangeLabel(startDate: multiWeekMenu.startDate, weekIndex: weekIndex);
    weekSections.add(MenuPdfWeekSection(title: weekRange.isEmpty ? "Week ${weekIndex + 1}" : "Week ${weekIndex + 1} ($weekRange)", days: days));
  }

  final List<MenuPdfRecipeSection> recipeSections = [];
  for (String recipeId in recipeIdsInMenuOrder) {
    final Recipe recipe = recipes.firstWhere((Recipe candidate) => candidate.id == recipeId);
    // The section feeds every person that eats the recipe, over every week.
    // `totalServingsForRecipe` folds the people of each sub-meal once, so it never counts a
    // person twice. The sum of the cook events does: a recipe that keeps no leftovers gets one
    // cook event per meal, and each event already counts the people of every meal of that day.
    final int servings = multiWeekMenu.totalServingsForRecipe(recipe.id);
    recipeSections.add(_buildRecipeSection(recipe: recipe, servings: servings, ingredients: ingredients));
  }

  return MenuPdfDocument(title: _documentTitle(multiWeekMenu), weeks: weekSections, recipes: recipeSections);
}

/// Names the document after the days that it covers, for example "Menu 6 Aug - 19 Aug".
/// A menu with no first day is named "Menu", because it holds no date to write.
/// A menu with no week is named "Menu" too: it covers no day, so a range would end before it
/// starts.
String _documentTitle(MultiWeekMenu multiWeekMenu) {
  if (multiWeekMenu.weeks.isEmpty) return "Menu";
  final DateTime? firstDay = menuDateForDay(startDate: multiWeekMenu.startDate, dayOffset: 0);
  final DateTime? lastDay = menuDateForDay(startDate: multiWeekMenu.startDate, dayOffset: multiWeekMenu.weeks.length * 7 - 1);
  if (firstDay == null || lastDay == null) return "Menu";
  return "Menu ${firstDay.toShortDateString()} - ${lastDay.toShortDateString()}";
}

/// Writes one recipe of the menu, with every amount scaled to [servings].
MenuPdfRecipeSection _buildRecipeSection({required Recipe recipe, required int servings, required List<Ingredient> ingredients}) {
  final List<MenuPdfStep> steps = [];
  for (int index = 0; index < recipe.instructions.length; index++) {
    final Instruction instruction = recipe.instructions[index];
    final Map<String, List<Quantity>> stepQuantities = {};
    for (IngredientUsage usage in instruction.ingredientsUsed) {
      addQuantityInto(stepQuantities.putIfAbsent(usage.ingredient, () => <Quantity>[]), usage.quantity);
    }
    steps.add(
      MenuPdfStep(
        number: index + 1,
        description: instruction.description,
        workingTimeMinutes: instruction.workingTimeMinutes,
        cookingTimeMinutes: instruction.cookingTimeMinutes,
        ingredients: _ingredientLines(quantitiesPerServing: stepQuantities, servings: servings, ingredients: ingredients),
      ),
    );
  }

  return MenuPdfRecipeSection(
    recipeName: recipe.name,
    servings: servings,
    workingTimeMinutes: recipe.workingTimeMinutes,
    cookingTimeMinutes: recipe.cookingTimeMinutes,
    ingredients: _ingredientLines(quantitiesPerServing: recipe.perServingQuantities(), servings: servings, ingredients: ingredients),
    steps: steps,
  );
}

/// Writes one line per ingredient, with the per-serving amounts scaled to [servings].
///
/// `Quantity.scaledBy` does the math and `Quantity.toDisplayText` writes the number, so the PDF,
/// cook mode and the markdown export always show the same amount for the same input.
List<MenuPdfIngredientLine> _ingredientLines({
  required Map<String, List<Quantity>> quantitiesPerServing,
  required int servings,
  required List<Ingredient> ingredients,
}) {
  final List<MenuPdfIngredientLine> lines = [];
  for (MapEntry<String, List<Quantity>> entry in quantitiesPerServing.entries) {
    final Ingredient? ingredient = ingredients.firstWhereOrNull((Ingredient candidate) => candidate.id == entry.key);
    final String amounts = entry.value.map((Quantity quantity) => quantity.scaledBy(servings).toDisplayText()).join(" + ");
    lines.add(MenuPdfIngredientLine(ingredientName: ingredient?.name ?? unknownIngredientName, amounts: amounts));
  }
  return lines;
}
