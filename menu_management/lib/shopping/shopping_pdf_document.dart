import "package:freezed_annotation/freezed_annotation.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/menu/menu_dates.dart";
import "package:menu_management/menu/models/multi_week_menu.dart";
import "package:menu_management/recipes/models/quantity.dart";
import "package:menu_management/recipes/models/recipe.dart";
import "package:menu_management/shopping/cooking_timeline.dart";
import "package:menu_management/shopping/ingredient_meal_requirement.dart";
import "package:menu_management/shopping/multi_trip_planner.dart";
import "package:menu_management/shopping/shopping_copy_text.dart";
import "package:menu_management/shopping/trip_amount_distributor.dart";
import "package:menu_management/shopping/waste_optimizer.dart";

part "shopping_pdf_document.freezed.dart";

/// One product that the reader can buy for an ingredient.
///
/// [packs] is the number of packs to buy when the reader buys this product and no other one. Every
/// matching product carries its own count, so the reader who finds an empty shelf swaps to the next
/// line and still buys enough.
@freezed
abstract class ShoppingPdfProductOption with _$ShoppingPdfProductOption {
  const factory ShoppingPdfProductOption({
    /// Names the product and the size of one pack, for example "Espaguetis (6x125grams)".
    required String label,

    /// The store link of the product. It is empty when the product carries no link.
    required String link,

    /// The packs to buy of this product alone.
    required int packs,

    /// True for the product that wastes the least, which is the one that the app recommends.
    required bool isRecommended,
  }) = _ShoppingPdfProductOption;
}

/// One meal that needs an ingredient. It is the justification of one shopping line.
@freezed
abstract class ShoppingPdfMealNeed with _$ShoppingPdfMealNeed {
  const factory ShoppingPdfMealNeed({
    /// Names the week of the menu, for example "Week 1".
    required String weekLabel,

    /// Names the day, for example "Wednesday 6 Aug", or "Saturday" for a menu with no start date.
    required String dayLabel,

    /// Names the meal slot, for example "Lunch".
    required String mealName,
    required String recipeName,
    required int people,

    /// False when the meal eats the leftovers of an earlier cook event. Such a meal still needs
    /// the ingredient, because the earlier cook buys the food for it.
    required bool isCookEvent,

    /// The amount that this meal needs, for example "200 grams".
    required String amounts,
  }) = _ShoppingPdfMealNeed;
}

/// One ingredient to buy, with every product that fits it and every meal that needs it.
@freezed
abstract class ShoppingPdfIngredientEntry with _$ShoppingPdfIngredientEntry {
  const factory ShoppingPdfIngredientEntry({
    required String ingredientName,

    /// The amount to buy, for example "500 grams + 2 pieces".
    required String amounts,

    /// True when the reader must freeze the item on the day of the trip (ADR 0015).
    @Default(false) bool freezeOnArrival,
    @Default([]) List<ShoppingPdfProductOption> products,
    @Default([]) List<ShoppingPdfMealNeed> meals,
  }) = _ShoppingPdfIngredientEntry;
}

/// One shop trip of the plan (ADR 0014), with everything to buy on that trip.
///
/// [title] is empty when the planner found no trip. The document then holds one plain list, the
/// same way the copied text drops every section header for such a plan.
@freezed
abstract class ShoppingPdfTripSection with _$ShoppingPdfTripSection {
  const factory ShoppingPdfTripSection({required String title, @Default([]) List<ShoppingPdfIngredientEntry> ingredients}) = _ShoppingPdfTripSection;
}

/// Everything that the shopping PDF prints, with no page, no font and no byte in it.
///
/// The renderer in `shopping_pdf.dart` turns this into a PDF. The split keeps the content
/// testable: a test reads the sections, the amounts and the labels here, and never decodes a PDF.
///
/// Every model of this file is derived: the app builds it on demand from the shopping page and
/// saves it never. This is why it carries no JSON, the same way `MenuPdfDocument` carries none.
///
/// Every list field of this file is `@Default([])`. A section with nothing in it is a valid value,
/// so one rule covers every list and no caller has to write an empty literal.
@freezed
abstract class ShoppingPdfDocument with _$ShoppingPdfDocument {
  const factory ShoppingPdfDocument({required String title, @Default([]) List<ShoppingPdfTripSection> trips}) = _ShoppingPdfDocument;
}

/// Builds the content of the shopping PDF.
///
/// Pure: it reads no provider, so a test calls it with no widget and no device (ADR 0009). The
/// shopping page passes every value, and it passes the same values that it gives to the copied
/// text, so the two exports can never start from different data.
///
/// [remainingByIngredientId] holds what the user must still buy of each ingredient, in the units
/// of the screen and already rounded with `roundNeededAmount`. An amount that rounds below one
/// unit arrives here as one unit, so the PDF lists it like every other need.
///
/// [trips] comes from `planShoppingTrips` and [tripLabel] names one trip. The split of an amount
/// over the trips runs through [distributeRemainingAcrossTrips], which the copied text calls too.
///
/// [multiWeekMenu] and [recipes] serve the justification only. `ingredientMealRequirements` says
/// which meal needs which amount of an ingredient.
///
/// Known gap (issue #49): the amounts of the meals of one ingredient do not always add up to the
/// amount to buy. A cook event that feeds a meal of the next week is counted once by
/// `allIngredients`, which feeds the amount to buy, and once per meal by
/// `ingredientMealRequirements`, which feeds the justification. Do not build on that difference.
ShoppingPdfDocument buildShoppingPdfDocument({
  required List<Ingredient> ingredients,
  required Map<String, List<Quantity>> remainingByIngredientId,
  required List<ShoppingTrip> trips,
  required String Function(ShoppingTrip trip) tripLabel,
  required MultiWeekMenu multiWeekMenu,
  required List<Recipe> recipes,
  required Map<String, List<CookingEvent>> cookingTimeline,
}) {
  final Map<String, List<IngredientMealRequirement>> mealRequirements = multiWeekMenu.ingredientMealRequirements(recipes: recipes);
  final List<Ingredient> sorted = sortIngredientsForCopy(ingredients);

  ShoppingPdfIngredientEntry? entryOf({required Ingredient ingredient, required List<Quantity> remaining, required bool freezeOnArrival}) {
    assertWholeShoppingAmounts(ingredient: ingredient, remaining: remaining);
    if (!remaining.any((Quantity quantity) => quantity.amount > 0)) return null;
    return ShoppingPdfIngredientEntry(
      ingredientName: ingredient.name,
      amounts: shoppingAmountsText(remaining),
      freezeOnArrival: freezeOnArrival,
      products: _productOptions(ingredient: ingredient, remaining: remaining, events: cookingTimeline[ingredient.id] ?? const []),
      meals: _mealNeeds(startDate: multiWeekMenu.startDate, requirements: mealRequirements[ingredient.id] ?? const []),
    );
  }

  final List<ShoppingPdfTripSection> sections = [];

  if (trips.isEmpty) {
    final List<ShoppingPdfIngredientEntry> entries = [];
    for (Ingredient ingredient in sorted) {
      final ShoppingPdfIngredientEntry? entry = entryOf(
        ingredient: ingredient,
        remaining: remainingForCopy(ingredient: ingredient, remainingByIngredientId: remainingByIngredientId),
        freezeOnArrival: false,
      );
      if (entry != null) entries.add(entry);
    }
    sections.add(ShoppingPdfTripSection(title: "", ingredients: entries));
    return ShoppingPdfDocument(title: _documentTitle(multiWeekMenu), trips: sections);
  }

  final Map<int, List<ShoppingPdfIngredientEntry>> entriesByWeek = {for (ShoppingTrip trip in trips) trip.weekIndex: []};
  for (Ingredient ingredient in sorted) {
    final List<Quantity> remaining = remainingForCopy(ingredient: ingredient, remainingByIngredientId: remainingByIngredientId);
    for (TripAllocation allocation in distributeRemainingAcrossTrips(ingredient: ingredient, pageRemaining: remaining, trips: trips)) {
      final ShoppingPdfIngredientEntry? entry = entryOf(
        ingredient: ingredient,
        remaining: allocation.quantities,
        freezeOnArrival: allocation.freezeOnArrival,
      );
      if (entry != null) entriesByWeek[allocation.weekIndex]!.add(entry);
    }
  }

  for (ShoppingTrip trip in trips) {
    final List<ShoppingPdfIngredientEntry> entries = entriesByWeek[trip.weekIndex]!;
    if (entries.isEmpty) continue;
    sections.add(ShoppingPdfTripSection(title: tripLabel(trip), ingredients: entries));
  }

  return ShoppingPdfDocument(title: _documentTitle(multiWeekMenu), trips: sections);
}

/// Names the document after the days that the menu covers, for example
/// "Shopping list 6 Aug - 19 Aug". A menu with no week and a menu with no start date are named
/// "Shopping list", because neither holds a date to write.
String _documentTitle(MultiWeekMenu multiWeekMenu) {
  const String plainTitle = "Shopping list";
  if (multiWeekMenu.weeks.isEmpty) return plainTitle;
  final DateTime? firstDay = menuDateForDay(startDate: multiWeekMenu.startDate, dayOffset: 0);
  final DateTime? lastDay = menuDateForDay(startDate: multiWeekMenu.startDate, dayOffset: multiWeekMenu.weeks.length * 7 - 1);
  if (firstDay == null || lastDay == null) return plainTitle;
  return "$plainTitle ${firstDay.toShortDateString()} - ${lastDay.toShortDateString()}";
}

/// Lists every product of [ingredient] that the reader can buy for [remaining].
///
/// A product enters the list when its unit matches the first amount that any product of the
/// ingredient can cover. [Product.packsNeeded] then counts the packs of buying that product and
/// no other one, which is what the reader needs when the shelf of another product is empty.
///
/// The first result of [rankProducts] wastes the least, so it carries the recommendation.
/// `recommendCombination` is not used here on purpose: it picks a mix of products and drops every
/// product that the mix leaves out, and it returns null for most amounts (issue #48).
List<ShoppingPdfProductOption> _productOptions({
  required Ingredient ingredient,
  required List<Quantity> remaining,
  required List<CookingEvent> events,
}) {
  if (ingredient.products.isEmpty) return const [];

  final Quantity? primary = remaining.firstWhereOrNull(
    (Quantity quantity) => quantity.amount > 0 && ingredient.products.any((Product product) => product.unit == quantity.unit),
  );
  if (primary == null) return const [];

  final List<Product> matching = ingredient.products.where((Product product) => product.unit == primary.unit).toList();
  final List<ProductRecommendation> ranked = rankProducts(totalNeeded: primary.amount, events: events, ingredient: ingredient, products: matching);
  final Product? best = ranked.isEmpty ? null : ranked.first.product;

  return matching
      .map(
        (Product product) => ShoppingPdfProductOption(
          label: productShoppingLabel(product),
          link: product.link,
          packs: product.packsNeeded(primary.amount),
          isRecommended: product == best,
        ),
      )
      .toList();
}

/// Writes one justification line per meal that needs the ingredient, in the order of the menu.
List<ShoppingPdfMealNeed> _mealNeeds({required DateTime? startDate, required List<IngredientMealRequirement> requirements}) {
  return requirements
      .map(
        (IngredientMealRequirement requirement) => ShoppingPdfMealNeed(
          weekLabel: "Week ${requirement.weekIndex + 1}",
          dayLabel: menuDayLabel(startDate: startDate, weekIndex: requirement.weekIndex, weekDay: requirement.mealTime.weekDay),
          mealName: requirement.mealTime.mealType.name.capitalizeFirstLetter() ?? requirement.mealTime.mealType.name,
          recipeName: requirement.recipeName,
          people: requirement.people,
          isCookEvent: requirement.isCookEvent,
          amounts: requirement.quantities.map((Quantity quantity) => quantity.toDisplayText()).join(" + "),
        ),
      )
      .toList();
}
