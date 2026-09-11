import "package:flutter_test/flutter_test.dart";
import "package:menu_management/menu/enums/week_day.dart";
import "package:menu_management/menu/menu_dates.dart";

void main() {
  // 2025-08-06 is a Wednesday.
  final DateTime wednesday6Aug2025 = DateTime(2025, 8, 6);

  group("menuDateForDay", () {
    test("returns null when the menu has no start date", () {
      expect(menuDateForDay(startDate: null, dayOffset: 3), isNull);
    });

    test("returns the start date itself for day 0", () {
      expect(menuDateForDay(startDate: wednesday6Aug2025, dayOffset: 0), DateTime(2025, 8, 6));
    });

    test("adds one day per offset", () {
      expect(menuDateForDay(startDate: wednesday6Aug2025, dayOffset: 8), DateTime(2025, 8, 14));
    });

    test("accepts a negative offset for the shopping day before the menu", () {
      expect(menuDateForDay(startDate: wednesday6Aug2025, dayOffset: -1), DateTime(2025, 8, 5));
    });

    test("drops the time of day of the start date", () {
      expect(menuDateForDay(startDate: DateTime(2025, 8, 6, 17, 30), dayOffset: 1), DateTime(2025, 8, 7));
    });

    test("crosses a month boundary", () {
      expect(menuDateForDay(startDate: DateTime(2025, 8, 30), dayOffset: 3), DateTime(2025, 9, 2));
    });
  });

  group("menuDayName", () {
    test("uses the WeekDay enum order when there is no start date", () {
      expect(menuDayName(startDate: null, dayOffset: 0), "Saturday");
      expect(menuDayName(startDate: null, dayOffset: 6), "Friday");
    });

    test("wraps the enum order for a day in a later week", () {
      expect(menuDayName(startDate: null, dayOffset: 8), "Sunday");
    });

    test("uses the real weekday of the start date", () {
      expect(menuDayName(startDate: wednesday6Aug2025, dayOffset: 0), "Wednesday");
      expect(menuDayName(startDate: wednesday6Aug2025, dayOffset: 6), "Tuesday");
      expect(menuDayName(startDate: wednesday6Aug2025, dayOffset: 7), "Wednesday");
    });
  });

  group("formatShortDate", () {
    test("writes the day number and the short month name", () {
      expect(formatShortDate(DateTime(2025, 8, 6)), "6 Aug");
      expect(formatShortDate(DateTime(2025, 12, 31)), "31 Dec");
    });
  });

  group("menuDayLabel", () {
    test("shows only the weekday name when there is no start date", () {
      expect(menuDayLabel(startDate: null, weekIndex: 0, weekDay: WeekDay.saturday), "Saturday");
      expect(menuDayLabel(startDate: null, weekIndex: 1, weekDay: WeekDay.monday), "Monday");
    });

    test("adds the real date when a start date is set", () {
      expect(menuDayLabel(startDate: wednesday6Aug2025, weekIndex: 0, weekDay: WeekDay.saturday), "Wednesday 6 Aug");
      expect(menuDayLabel(startDate: wednesday6Aug2025, weekIndex: 1, weekDay: WeekDay.saturday), "Wednesday 13 Aug");
      expect(menuDayLabel(startDate: wednesday6Aug2025, weekIndex: 0, weekDay: WeekDay.friday), "Tuesday 12 Aug");
    });
  });

  group("menuWeekRangeLabel", () {
    test("is empty when there is no start date", () {
      expect(menuWeekRangeLabel(startDate: null, weekIndex: 0), "");
    });

    test("covers the seven days of the week", () {
      expect(menuWeekRangeLabel(startDate: wednesday6Aug2025, weekIndex: 0), "6 Aug - 12 Aug");
      expect(menuWeekRangeLabel(startDate: wednesday6Aug2025, weekIndex: 1), "13 Aug - 19 Aug");
    });
  });

  group("shoppingTripLabel", () {
    test("falls back to the week number when there is no start date", () {
      expect(shoppingTripLabel(startDate: null, weekIndex: 0), "Week 1");
      expect(shoppingTripLabel(startDate: null, weekIndex: 1), "Week 2");
    });

    test("names the day before the week starts", () {
      expect(shoppingTripLabel(startDate: wednesday6Aug2025, weekIndex: 0), "Tuesday 5 Aug");
      expect(shoppingTripLabel(startDate: wednesday6Aug2025, weekIndex: 1), "Tuesday 12 Aug");
    });
  });
}
