import "package:flutter_test/flutter_test.dart";
import "package:menu_management/menu/enums/week_day.dart";
import "package:menu_management/menu/menu_dates.dart";
import "package:menu_management/shopping/multi_trip_planner.dart";

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

    test("wraps the enum order for a negative offset", () {
      // No production caller reaches this case: shoppingTripLabel returns "Week N" for a
      // date-less menu before it can ask for the name of a negative day. The wrap is a
      // defensive guard, and this test locks its result.
      expect(menuDayName(startDate: null, dayOffset: -1), "Friday");
      expect(menuDayName(startDate: null, dayOffset: -8), "Friday");
    });

    test("uses the real weekday of the start date", () {
      expect(menuDayName(startDate: wednesday6Aug2025, dayOffset: 0), "Wednesday");
      expect(menuDayName(startDate: wednesday6Aug2025, dayOffset: 6), "Tuesday");
      expect(menuDayName(startDate: wednesday6Aug2025, dayOffset: 7), "Wednesday");
    });

    test("names every weekday of one real week", () {
      // 2025-08-06 is a Wednesday, so the seven offsets cover the seven names.
      expect(
        [for (int offset = 0; offset < 7; offset++) menuDayName(startDate: wednesday6Aug2025, dayOffset: offset)],
        ["Wednesday", "Thursday", "Friday", "Saturday", "Sunday", "Monday", "Tuesday"],
      );
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
      expect(shoppingTripLabel(startDate: null, weekIndex: 0, tripDay: -1, isFirstTrip: false), "Week 1");
      expect(shoppingTripLabel(startDate: null, weekIndex: 1, tripDay: 6, isFirstTrip: false), "Week 2");
    });

    test("names the trip day that the caller gives", () {
      expect(shoppingTripLabel(startDate: wednesday6Aug2025, weekIndex: 0, tripDay: -1, isFirstTrip: false), "Tuesday 5 Aug");
      expect(shoppingTripLabel(startDate: wednesday6Aug2025, weekIndex: 1, tripDay: 6, isFirstTrip: false), "Tuesday 12 Aug");
    });

    test("uses the trip day of the planner, not the week index", () {
      // ShoppingTrip.dayForWeek owns the rule. The label must follow the day that it gives.
      expect(
        shoppingTripLabel(startDate: wednesday6Aug2025, weekIndex: 1, tripDay: ShoppingTrip.dayForWeek(1), isFirstTrip: false),
        "Tuesday 12 Aug",
      );
    });

    test("says now for the first trip, with or without a start date", () {
      // The first trip of the plan happens the day before menu day 0, which is already past.
      // The user shops for it now, so no calendar date is correct for it.
      expect(shoppingTripLabel(startDate: wednesday6Aug2025, weekIndex: 0, tripDay: -1, isFirstTrip: true), "now");
      expect(shoppingTripLabel(startDate: null, weekIndex: 0, tripDay: -1, isFirstTrip: true), "now");
    });

    test("says now for a first trip that is not week 0", () {
      // The planner can drop week 0, so the earliest trip of the plan is the one that is now.
      expect(shoppingTripLabel(startDate: wednesday6Aug2025, weekIndex: 1, tripDay: 6, isFirstTrip: true), "now");
    });
  });
}
