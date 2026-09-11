import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/menu/enums/week_day.dart";

/// Translates menu day offsets into real calendar dates and labels.
///
/// The menu schedules everything in absolute day offsets from menu day 0
/// (`weekIndex * 7 + weekDay.value`). A menu can also carry a start date, which is the
/// real calendar date of menu day 0. These functions only translate an offset into a
/// date or a label for the user. They never change the planning math.
///
/// Every function accepts a null [startDate]. A null start date means the menu has no
/// calendar date, so the labels keep the date-less wording of the [WeekDay] enum.

/// Returns the real date of the menu day at [dayOffset], or null when [startDate] is null.
///
/// [dayOffset] is the absolute day offset from menu day 0. It accepts a negative value,
/// because a shopping trip happens the day before the week that it covers.
DateTime? menuDateForDay({required DateTime? startDate, required int dayOffset}) {
  if (startDate == null) return null;
  return DateTime(startDate.year, startDate.month, startDate.day + dayOffset);
}

/// Returns the name of the weekday at [dayOffset], capitalized.
///
/// With a start date, the name comes from the real date. Without one, the name comes from
/// the [WeekDay] enum, which starts at Saturday.
String menuDayName({required DateTime? startDate, required int dayOffset}) {
  final DateTime? date = menuDateForDay(startDate: startDate, dayOffset: dayOffset);
  if (date == null) return _weekDayName(dayOffset);
  // DateTime.weekday is 1 for Monday and 7 for Sunday. WeekDay.value is 0 for Saturday,
  // so the shift of one place and the wrap map one scale onto the other.
  return _weekDayName((date.weekday + 1) % 7);
}

/// Returns the label of one menu day: "Saturday" without a start date, "Wednesday 6 Aug" with one.
String menuDayLabel({required DateTime? startDate, required int weekIndex, required WeekDay weekDay}) {
  final int dayOffset = weekIndex * 7 + weekDay.value;
  final String dayName = menuDayName(startDate: startDate, dayOffset: dayOffset);
  final DateTime? date = menuDateForDay(startDate: startDate, dayOffset: dayOffset);
  if (date == null) return dayName;
  return "$dayName ${date.toShortDateString()}";
}

/// Returns the date range of the week at [weekIndex], such as "6 Aug - 12 Aug".
/// Returns an empty string when [startDate] is null.
String menuWeekRangeLabel({required DateTime? startDate, required int weekIndex}) {
  final DateTime? first = menuDateForDay(startDate: startDate, dayOffset: weekIndex * 7);
  final DateTime? last = menuDateForDay(startDate: startDate, dayOffset: weekIndex * 7 + 6);
  if (first == null || last == null) return "";
  return "${first.toShortDateString()} - ${last.toShortDateString()}";
}

/// Returns the label of the shopping trip that covers the week at [weekIndex].
///
/// [tripDay] is the day offset of the trip. The caller reads it from `ShoppingTrip`, which
/// owns the rule that says when a trip happens. Without a start date the label falls back
/// to "Week N", which is why the function also needs [weekIndex].
///
/// Set [isFirstTrip] for the earliest trip of the plan. That trip happens before menu day 0,
/// so its calendar date is already past. The label is "now" instead, and every screen that
/// names a trip reads this one rule.
String shoppingTripLabel({required DateTime? startDate, required int weekIndex, required int tripDay, required bool isFirstTrip}) {
  if (isFirstTrip) return "now";
  final DateTime? date = menuDateForDay(startDate: startDate, dayOffset: tripDay);
  if (date == null) return "Week ${weekIndex + 1}";
  return "${menuDayName(startDate: startDate, dayOffset: tripDay)} ${date.toShortDateString()}";
}

/// Returns the capitalized [WeekDay] name at [dayOffset].
///
/// Dart returns a value in 0..6 for `%` with a positive divisor, also for a negative
/// [dayOffset]. The wrap for a negative [dayOffset] is defensive only: no production caller
/// reaches it, because [shoppingTripLabel] returns "Week N" for a date-less menu first.
String _weekDayName(int dayOffset) {
  return WeekDay.fromValue(dayOffset % 7).name.capitalizeFirstLetter() ?? "";
}
