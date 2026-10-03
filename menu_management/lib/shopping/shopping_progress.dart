import "package:freezed_annotation/freezed_annotation.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/recipes/enums/unit.dart";

part "shopping_progress.freezed.dart";

/// One owned amount that the user typed in the header input of an ingredient.
/// A null [unit] means "packs", the same rule as `OwnedStock.unit`.
typedef OwnedAmountProgress = ({double amount, Unit? unit});

/// Names one product of an ingredient in a saved count: its store link plus its unit.
///
/// The link alone is not unique. The grams product and the pieces product of one store item share
/// one link, so the unit tells them apart.
typedef ProductCountKey = ({String link, Unit unit});

/// The JSON text of the "packs" unit, which has no [Unit] value.
const String _packsUnitName = "packs";

/// What the user typed on the shopping page, so the user can stop and continue later.
///
/// The menu file (`.tsm`) stores this object on `MultiWeekMenu.shoppingProgress`.
/// - [ownedAmounts]: the header owned amount and unit per ingredient id.
/// - [ownedProductCounts]: the owned count per product, keyed by ingredient id and then by the
///   [ProductCountKey] of the product. The shopping page keys the counts by product index, and the
///   index changes when the user adds, removes or reorders products. The link and the unit stay the
///   same. Two products with the same link and the same unit share one key: the first of them in
///   `Ingredient.products` gets the count.
/// - [useFreezerStrategy]: the "Try to make one trip" switch.
///
/// Only amounts and counts above zero are stored.
@freezed
abstract class ShoppingProgress with _$ShoppingProgress {
  const factory ShoppingProgress({
    @Default({}) Map<String, OwnedAmountProgress> ownedAmounts,
    @Default({}) Map<String, Map<ProductCountKey, double>> ownedProductCounts,
    @Default(false) bool useFreezerStrategy,
  }) = _ShoppingProgress;

  const ShoppingProgress._();

  /// Builds the progress from the state of the shopping page.
  ///
  /// [ownedAmounts] and [ownedProductCountsByIndex] hold the ingredients that the page shows.
  /// The function turns each product index into the [ProductCountKey] of that product in
  /// [ingredients], and drops an index that matches no product. When two products share a key, the
  /// count of the lower index wins and the other count is dropped with a warning.
  ///
  /// The page shows only the ingredients of the current menu. The function copies the entries of
  /// [previous] for every other ingredient in [ingredients], so the stock at home survives a new
  /// menu. It drops a previous entry of an ingredient that is not in [ingredients], and a previous
  /// count whose link and unit match no product of its ingredient.
  factory ShoppingProgress.fromPageState({
    required ShoppingProgress? previous,
    required Map<String, OwnedAmountProgress> ownedAmounts,
    required Map<String, Map<int, double>> ownedProductCountsByIndex,
    required bool useFreezerStrategy,
    required List<Ingredient> ingredients,
  }) {
    Set<String> pageIngredientIds = {...ownedAmounts.keys, ...ownedProductCountsByIndex.keys};
    Map<String, Ingredient> ingredientsById = {for (Ingredient ingredient in ingredients) ingredient.id: ingredient};

    Map<String, OwnedAmountProgress> mergedAmounts = {
      for (MapEntry<String, OwnedAmountProgress> entry in (previous?.ownedAmounts ?? const {}).entries)
        if (!pageIngredientIds.contains(entry.key) && ingredientsById.containsKey(entry.key)) entry.key: entry.value,
      for (MapEntry<String, OwnedAmountProgress> entry in ownedAmounts.entries)
        if (entry.value.amount > 0) entry.key: entry.value,
    };

    Map<String, Map<ProductCountKey, double>> mergedCounts = {};
    for (MapEntry<String, Map<ProductCountKey, double>> entry in (previous?.ownedProductCounts ?? const {}).entries) {
      Ingredient? ingredient = ingredientsById[entry.key];
      if (pageIngredientIds.contains(entry.key) || ingredient == null) continue;
      Map<ProductCountKey, double> counts = {
        for (MapEntry<ProductCountKey, double> count in entry.value.entries)
          if (ingredient.products.any((Product product) => product.link == count.key.link && product.unit == count.key.unit)) count.key: count.value,
      };
      if (counts.isNotEmpty) mergedCounts[entry.key] = counts;
    }
    for (MapEntry<String, Map<int, double>> entry in ownedProductCountsByIndex.entries) {
      Ingredient? ingredient = ingredients.firstWhereOrNull((Ingredient i) => i.id == entry.key);
      if (ingredient == null) continue;
      Map<ProductCountKey, double> countsByKey = {};
      List<int> productIndexes = entry.value.keys.toList()..sort();
      for (int productIndex in productIndexes) {
        double count = entry.value[productIndex]!;
        if (count <= 0 || productIndex < 0 || productIndex >= ingredient.products.length) continue;
        Product product = ingredient.products[productIndex];
        ProductCountKey key = (link: product.link, unit: product.unit);
        if (countsByKey.containsKey(key)) {
          Debug.logWarning(
            true,
            "Shopping progress dropped: ${ingredient.name} has two products with the link ${product.link} in ${product.unit.name}.",
            asAssertion: false,
          );
          continue;
        }
        countsByKey[key] = count;
      }
      if (countsByKey.isNotEmpty) mergedCounts[entry.key] = countsByKey;
    }

    return ShoppingProgress(ownedAmounts: mergedAmounts, ownedProductCounts: mergedCounts, useFreezerStrategy: useFreezerStrategy);
  }

  /// True when the progress holds no amount, no count, and the trip switch is off.
  bool get isEmpty => ownedAmounts.isEmpty && ownedProductCounts.isEmpty && !useFreezerStrategy;

  /// Returns the owned product counts keyed by the index of each product in [ingredients], which
  /// is the shape that the shopping page uses.
  ///
  /// A count goes to the first product whose link and unit match its [ProductCountKey]. A count that
  /// matches no product is dropped with a warning. The counts of an ingredient that is not in
  /// [ingredients] are dropped with a warning too.
  Map<String, Map<int, double>> ownedProductCountsByIndex({required List<Ingredient> ingredients}) {
    Map<String, Map<int, double>> countsByIndex = {};
    for (MapEntry<String, Map<ProductCountKey, double>> entry in ownedProductCounts.entries) {
      Ingredient? ingredient = ingredients.firstWhereOrNull((Ingredient i) => i.id == entry.key);
      if (ingredient == null) {
        Debug.logWarning(true, 'Shopping progress dropped: no ingredient has the id "${entry.key}".', asAssertion: false);
        continue;
      }
      Map<int, double> counts = {};
      for (MapEntry<ProductCountKey, double> count in entry.value.entries) {
        int productIndex = ingredient.products.indexWhere((Product product) => product.link == count.key.link && product.unit == count.key.unit);
        if (productIndex < 0) {
          Debug.logWarning(
            true,
            'Shopping progress dropped: ${ingredient.name} has no product with the link "${count.key.link}" in ${count.key.unit.name}.',
            asAssertion: false,
          );
          continue;
        }
        counts[productIndex] = count.value;
      }
      if (counts.isNotEmpty) countsByIndex[entry.key] = counts;
    }
    return countsByIndex;
  }

  /// Writes the progress as JSON. Each empty part is left out.
  ///
  /// The code writes the JSON by hand: json_serializable cannot write a record type, and each
  /// product count becomes one object with its link, its unit and its count.
  Map<String, Object?> toJson() {
    return {
      if (useFreezerStrategy) "useFreezerStrategy": true,
      if (ownedAmounts.isNotEmpty)
        "ownedAmounts": {
          for (MapEntry<String, OwnedAmountProgress> entry in ownedAmounts.entries)
            entry.key: {"amount": entry.value.amount, "unit": entry.value.unit?.name ?? _packsUnitName},
        },
      if (ownedProductCounts.isNotEmpty)
        "ownedProductCounts": {
          for (MapEntry<String, Map<ProductCountKey, double>> entry in ownedProductCounts.entries)
            entry.key: [
              for (MapEntry<ProductCountKey, double> count in entry.value.entries)
                {"link": count.key.link, "unit": count.key.unit.name, "count": count.value},
            ],
        },
    };
  }

  /// Writes [progress] as JSON, or null when it holds nothing. `MultiWeekMenu` uses it, so the
  /// menu file leaves out an empty progress.
  static Map<String, Object?>? toJsonOrNull(ShoppingProgress? progress) {
    if (progress == null || progress.isEmpty) return null;
    return progress.toJson();
  }

  /// Reads the progress from JSON, and never throws.
  ///
  /// The menu loader catches every error and returns no menu, so one bad value would cost the
  /// user the whole file. This function drops each bad value with a warning and keeps the rest.
  /// It returns null when [json] is not an object or when nothing valid is left.
  static ShoppingProgress? fromJsonLenient(Object? json) {
    if (json == null) return null;
    if (json is! Map) {
      Debug.logWarning(true, 'Shopping progress dropped: "$json" is not an object.', asAssertion: false);
      return null;
    }

    Object? rawSwitch = json["useFreezerStrategy"];
    if (rawSwitch != null && rawSwitch is! bool) {
      Debug.logWarning(true, 'Shopping progress: the trip switch "$rawSwitch" is not true or false.', asAssertion: false);
    }

    ShoppingProgress progress = ShoppingProgress(
      ownedAmounts: _parseOwnedAmounts(json["ownedAmounts"]),
      ownedProductCounts: _parseOwnedProductCounts(json["ownedProductCounts"]),
      useFreezerStrategy: rawSwitch == true,
    );
    return progress.isEmpty ? null : progress;
  }

  static Map<String, OwnedAmountProgress> _parseOwnedAmounts(Object? json) {
    if (json == null) return {};
    if (json is! Map) {
      Debug.logWarning(true, 'Shopping progress: the owned amounts "$json" are not an object.', asAssertion: false);
      return {};
    }
    Map<String, OwnedAmountProgress> amounts = {};
    for (MapEntry<Object?, Object?> entry in json.entries) {
      Object? rawEntry = entry.value;
      Object? rawAmount = rawEntry is Map ? rawEntry["amount"] : null;
      Object? rawUnit = rawEntry is Map ? rawEntry["unit"] : null;
      Unit? unit = Unit.values.firstWhereOrNull((Unit u) => u.name == rawUnit);
      bool isValidUnit = unit != null || rawUnit == _packsUnitName;
      if (entry.key is! String || !_isPositiveNumber(rawAmount) || !isValidUnit) {
        Debug.logWarning(true, 'Shopping progress: dropped the owned amount "$rawEntry" of "${entry.key}".', asAssertion: false);
        continue;
      }
      amounts[entry.key as String] = (amount: (rawAmount as num).toDouble(), unit: unit);
    }
    return amounts;
  }

  static Map<String, Map<ProductCountKey, double>> _parseOwnedProductCounts(Object? json) {
    if (json == null) return {};
    if (json is! Map) {
      Debug.logWarning(true, 'Shopping progress: the product counts "$json" are not an object.', asAssertion: false);
      return {};
    }
    Map<String, Map<ProductCountKey, double>> countsByIngredient = {};
    for (MapEntry<Object?, Object?> entry in json.entries) {
      Object? rawCounts = entry.value;
      if (entry.key is! String || rawCounts is! List) {
        Debug.logWarning(true, 'Shopping progress: dropped the product counts "$rawCounts" of "${entry.key}".', asAssertion: false);
        continue;
      }
      Map<ProductCountKey, double> counts = {};
      for (Object? rawCount in rawCounts) {
        Object? rawLink = rawCount is Map ? rawCount["link"] : null;
        Unit? unit = rawCount is Map ? Unit.values.firstWhereOrNull((Unit u) => u.name == rawCount["unit"]) : null;
        Object? rawValue = rawCount is Map ? rawCount["count"] : null;
        if (rawLink is! String || unit == null || !_isPositiveNumber(rawValue)) {
          Debug.logWarning(true, 'Shopping progress: dropped the product count "$rawCount" of "${entry.key}".', asAssertion: false);
          continue;
        }
        counts[(link: rawLink, unit: unit)] = (rawValue as num).toDouble();
      }
      if (counts.isNotEmpty) countsByIngredient[entry.key as String] = counts;
    }
    return countsByIngredient;
  }

  static bool _isPositiveNumber(Object? value) => value is num && value.isFinite && value > 0;
}
