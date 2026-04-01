import "package:freezed_annotation/freezed_annotation.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/menu/models/menu.dart";
import "package:menu_management/recipes/models/quantity.dart";

part "multi_week_menu.freezed.dart";
part "multi_week_menu.g.dart";

@freezed
abstract class MultiWeekMenu with _$MultiWeekMenu {
  const factory MultiWeekMenu({@Default([]) List<Menu> weeks}) = _MultiWeekMenu;

  factory MultiWeekMenu.fromJson(Map<String, Object?> json) => _$MultiWeekMenuFromJson(json);

  const MultiWeekMenu._();

  /// Validates that the menu has at least one week.
  /// Use this factory instead of the default constructor when creating from user actions.
  factory MultiWeekMenu.validated({required List<Menu> weeks}) {
    if (weeks.isEmpty) throw ArgumentError("MultiWeekMenu must have at least one week");
    return MultiWeekMenu(weeks: weeks);
  }

  int get weekCount => weeks.length;

  MultiWeekMenu addWeek(Menu week) {
    return copyWith(weeks: [...weeks, week]);
  }

  MultiWeekMenu removeLastWeek() {
    if (weeks.length <= 1) return this;
    return copyWith(weeks: weeks.sublist(0, weeks.length - 1));
  }

  MultiWeekMenu updateWeekAt(int index, Menu updatedWeek) {
    final List<Menu> newWeeks = [...weeks];
    newWeeks[index] = updatedWeek;
    return copyWith(weeks: newWeeks);
  }

  Map<String, List<Quantity>> get allIngredients {
    Map<String, List<Quantity>> combined = {};

    for (Menu week in weeks) {
      Map<String, List<Quantity>> weekIngredients = week.allIngredients;
      for (MapEntry<String, List<Quantity>> entry in weekIngredients.entries) {
        if (combined[entry.key] == null) {
          combined[entry.key] = [];
        }
        for (Quantity quantity in entry.value) {
          Quantity? existing = combined[entry.key]!.firstWhereOrNull((q) => q.unit == quantity.unit);
          if (existing != null) {
            combined[entry.key]!.remove(existing);
            combined[entry.key]!.add(existing.copyWith(amount: existing.amount + quantity.amount));
          } else {
            combined[entry.key]!.add(quantity);
          }
        }
      }
    }

    return combined;
  }

  String toStringBeautified() {
    String result = "";
    for (int i = 0; i < weeks.length; i++) {
      result += "Week ${i + 1}\n";
      result += "${weeks[i].toStringBeautified()}\n\n";
    }
    return result.trim();
  }
}
