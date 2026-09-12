import "package:freezed_annotation/freezed_annotation.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/recipes/enums/unit.dart";

part "quantity.freezed.dart";
part "quantity.g.dart";

/// Adds [quantity] into [totals], in place.
///
/// [totals] holds at most one entry per unit. The function adds the amount to the entry of the
/// same unit, and keeps that entry where it is. A unit that is not there yet goes to the end.
///
/// This is the one merge rule for the amounts of a single ingredient. The shopping list, the
/// per-meal breakdown, and the per-recipe totals all call it, so they can never split an
/// ingredient in two different ways, and they always show the units in the same order.
void addQuantityInto(List<Quantity> totals, Quantity quantity) {
  int index = totals.indexWhere((Quantity total) => total.unit == quantity.unit);
  if (index < 0) {
    totals.add(quantity);
    return;
  }
  totals[index] = totals[index].copyWith(amount: totals[index].amount + quantity.amount);
}

@freezed
abstract class Quantity with _$Quantity {
  const factory Quantity({required double amount, required Unit unit}) = _Quantity;

  factory Quantity.fromJson(Map<String, Object?> json) => _$QuantityFromJson(json);

  // Empty constant constructor. Must not have any parameter. Needed to be able to add non-static methods and getters
  const Quantity._();

  /// Returns this quantity multiplied by [servings].
  ///
  /// A recipe always stores the amounts of one serving, so every screen that cooks or exports a
  /// recipe for more people scales them. This method is the one place that does the math, so two
  /// screens can never show two different numbers for the same recipe and the same servings.
  Quantity scaledBy(int servings) => copyWith(amount: amount * servings);

  /// Writes the quantity as text, for example "150 grams".
  ///
  /// Set [abbreviateUnit] to true for the short unit name, for example "150 g". The number is the
  /// same in both forms: decimals appear only when the amount is not a whole number.
  String toDisplayText({bool abbreviateUnit = false}) {
    return "${amount.toStringWithDecimalsIfNotInteger()} ${abbreviateUnit ? unit.abbreviation : unit.name}";
  }
}
