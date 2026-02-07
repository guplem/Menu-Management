/// Extensions on [DateTime] for common date comparison and calculation operations.
extension DateTimeExtensions on DateTime {
  /// Returns true if this date is the same calendar day as [other] (defaults to now).
  bool isSameDay([DateTime? other]) {
    other ??= DateTime.now();
    return other.year == year && other.month == month && other.day == day;
  }

  bool isSameWeek([DateTime? other]) {
    other ??= DateTime.now();
    DateTime startWeek = firstMomentOfWeek();
    DateTime endWeek = lastMomentOfWeek();
    return startWeek.isBefore(other) && endWeek.isAfter(other);
  }

  bool isSameMonth([DateTime? other]) {
    other ??= DateTime.now();
    return other.year == year && other.month == month;
  }

  bool isSameYear([DateTime? other]) {
    other ??= DateTime.now();
    return other.year == year;
  }

  // Altered version of in_date_utils package
  /// Returns start of the first day of the week
  ///
  /// For example: (2020, 4, 9, 15, 16) -> (2020, 4, 6, 0, 0, 0, 0).
  ///
  /// You can define first weekday (Monday, Sunday or Saturday) with
  /// parameter [firstWeekday]. It should be one of the constant values
  /// [DateTime.monday], ..., [DateTime.sunday].
  ///
  /// By default it's [DateTime.monday].
  DateTime firstMomentOfWeek({int? firstWeekday}) {
    assert(firstWeekday == null || firstWeekday > 0 && firstWeekday < 8);

    var days = weekday - (firstWeekday ?? DateTime.monday);
    if (days < 0) days += DateTime.daysPerWeek;

    return DateTime(year, month, day - days, 0, 0, 0, 0, 0);
  }

  // Altered version of in_date_utils package
  /// Returns start of the last day of the week
  ///
  /// For example: (2020, 4, 9, 15, 16) -> (2020, 4, 12, 23, 59, 59, 999, 999).
  ///
  /// You can define first weekday (Monday, Sunday or Saturday) with
  /// parameter [firstWeekday]. It should be one of the constant values
  /// [DateTime.monday], ..., [DateTime.sunday].
  ///
  /// By default it's [DateTime.monday],
  /// so the last day will be [DateTime.sunday].
  DateTime lastMomentOfWeek({int? firstWeekday}) {
    assert(firstWeekday == null || firstWeekday > 0 && firstWeekday < 8);

    var days = (firstWeekday ?? DateTime.monday) - 1 - weekday;
    if (days < 0) days += DateTime.daysPerWeek;

    return DateTime(year, month, day + days, 23, 59, 59, 999, 999);
  }

  bool get isLeapYear {
    // A leap year is divisible by 4, but not by 100 unless it is also divisible by 400.
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  int get daysInMonth {
    switch (month) {
      case 4:
      case 6:
      case 9:
      case 11:
        return 30;
      case 2:
        return isLeapYear ? 29 : 28;
      default:
        return 31;
    }
  }

  int get daysInYear {
    return isLeapYear ? 366 : 365;
  }
}
