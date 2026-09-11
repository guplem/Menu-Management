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

const List<String> _weekDayNames = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];

const List<String> _shortMonthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

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
  if (date == null) return _enumDayName(dayOffset);
  return _weekDayNames[date.weekday - 1];
}

/// Returns a short date such as "6 Aug".
String formatShortDate(DateTime date) {
  return "${date.day} ${_shortMonthNames[date.month - 1]}";
}

/// Returns the label of one menu day: "Saturday" without a start date, "Wednesday 6 Aug" with one.
String menuDayLabel({required DateTime? startDate, required int weekIndex, required WeekDay weekDay}) {
  final int dayOffset = weekIndex * 7 + weekDay.value;
  final String dayName = menuDayName(startDate: startDate, dayOffset: dayOffset);
  final DateTime? date = menuDateForDay(startDate: startDate, dayOffset: dayOffset);
  if (date == null) return dayName;
  return "$dayName ${formatShortDate(date)}";
}

/// Returns the date range of the week at [weekIndex], such as "6 Aug - 12 Aug".
/// Returns an empty string when [startDate] is null.
String menuWeekRangeLabel({required DateTime? startDate, required int weekIndex}) {
  final DateTime? first = menuDateForDay(startDate: startDate, dayOffset: weekIndex * 7);
  final DateTime? last = menuDateForDay(startDate: startDate, dayOffset: weekIndex * 7 + 6);
  if (first == null || last == null) return "";
  return "${formatShortDate(first)} - ${formatShortDate(last)}";
}

/// Returns the label of the shopping trip that covers the week at [weekIndex].
///
/// The trip happens the day before the week starts, which is day `weekIndex * 7 - 1`.
/// Without a start date the label falls back to "Week N".
String shoppingTripLabel({required DateTime? startDate, required int weekIndex}) {
  final DateTime? date = menuDateForDay(startDate: startDate, dayOffset: weekIndex * 7 - 1);
  if (date == null) return "Week ${weekIndex + 1}";
  return "${menuDayName(startDate: startDate, dayOffset: weekIndex * 7 - 1)} ${formatShortDate(date)}";
}

String _enumDayName(int dayOffset) {
  final int wrapped = dayOffset % 7;
  final int weekDayValue = wrapped < 0 ? wrapped + 7 : wrapped;
  final String name = WeekDay.fromValue(weekDayValue).name;
  return "${name[0].toUpperCase()}${name.substring(1)}";
}
