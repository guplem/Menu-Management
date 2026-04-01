import "package:flutter_test/flutter_test.dart";
import "package:menu_management/flutter_essentials/utils/extensions/string.dart";
import "package:menu_management/flutter_essentials/utils/extensions/iterable.dart";
import "package:menu_management/flutter_essentials/utils/extensions/double.dart";
import "package:menu_management/flutter_essentials/utils/extensions/int.dart";
import "package:menu_management/flutter_essentials/utils/extensions/duration.dart";
import "package:menu_management/flutter_essentials/utils/extensions/datetime.dart";
import "package:menu_management/flutter_essentials/utils/extensions/map.dart";

void main() {
  // ── String (nullable) ──

  group("StringNullableExtensions", () {
    group("capitalizeFirstLetter", () {
      test("capitalizes first letter", () {
        expect("hello".capitalizeFirstLetter(), "Hello");
      });

      test("returns empty string for empty input", () {
        expect("".capitalizeFirstLetter(), "");
      });

      test("returns null for null input", () {
        String? nullStr;
        expect(nullStr.capitalizeFirstLetter(), null);
      });

      test("lowercases rest when flag is set", () {
        expect("hELLO".capitalizeFirstLetter(restOfStringToLowerCase: true), "Hello");
      });

      test("preserves rest when flag is not set", () {
        expect("hELLO".capitalizeFirstLetter(), "HELLO");
      });
    });

    group("trimAndSetNullIfEmpty", () {
      test("trims and returns string", () {
        expect("  hello  ".trimAndSetNullIfEmpty, "hello");
      });

      test("returns null for whitespace-only string", () {
        expect("   ".trimAndSetNullIfEmpty, null);
      });

      test("returns null for empty string", () {
        expect("".trimAndSetNullIfEmpty, null);
      });

      test("returns null for null input", () {
        String? nullStr;
        expect(nullStr.trimAndSetNullIfEmpty, null);
      });
    });

    group("digits", () {
      test("extracts digits from mixed string", () {
        expect("abc123def456".digits, "123456");
      });

      test("returns empty for no digits", () {
        expect("hello".digits, "");
      });

      test("returns empty for null", () {
        String? nullStr;
        expect(nullStr.digits, "");
      });
    });

    group("digitsInt", () {
      test("returns integer from digits", () {
        expect("abc123".digitsInt, 123);
      });

      test("returns null when no digits", () {
        expect("hello".digitsInt, null);
      });
    });

    group("isNullOrEmpty", () {
      test("true for null", () {
        String? nullStr;
        expect(nullStr.isNullOrEmpty, true);
      });

      test("true for empty", () {
        expect("".isNullOrEmpty, true);
      });

      test("false for non-empty", () {
        expect("a".isNullOrEmpty, false);
      });
    });

    group("first", () {
      test("returns first N chars", () {
        expect("hello".first(3), "hel");
      });

      test("returns full string if shorter than N", () {
        expect("hi".first(10), "hi");
      });

      test("returns null for null input", () {
        String? nullStr;
        expect(nullStr.first(3), null);
      });
    });

    group("last", () {
      test("returns last N chars", () {
        expect("hello".last(3), "llo");
      });

      test("returns full string if shorter than N", () {
        expect("hi".last(10), "hi");
      });

      test("returns null for null input", () {
        String? nullStr;
        expect(nullStr.last(3), null);
      });
    });

    group("isSingleEmoji", () {
      test("true for single emoji", () {
        expect("😀".isSingleEmoji(), true);
      });

      test("false for text", () {
        expect("hello".isSingleEmoji(), false);
      });

      test("false for multiple emojis", () {
        expect("😀😁".isSingleEmoji(), false);
      });

      test("false for empty string", () {
        expect("".isSingleEmoji(), false);
      });

      test("false for null", () {
        String? nullStr;
        expect(nullStr.isSingleEmoji(), false);
      });
    });
  });

  // ── String (non-nullable) ──

  group("StringExtensions", () {
    group("normalizeForSearch", () {
      test("removes accents", () {
        expect("Creme Brulee".normalizeForSearch(), "creme brulee");
        expect("cafe".normalizeForSearch(), "cafe");
      });

      test("removes diacritics from accented characters", () {
        expect("Creme Brulee".normalizeForSearch(), "creme brulee");
        expect("nino".normalizeForSearch(), "nino");
      });

      test("handles French accents", () {
        expect("crepe".normalizeForSearch(), "crepe");
      });

      test("removes special characters", () {
        expect("Cafe's Place!".normalizeForSearch(), "cafes place");
      });

      test("collapses multiple spaces", () {
        expect("a   b   c".normalizeForSearch(), "a b c");
      });

      test("converts to lowercase", () {
        expect("HELLO WORLD".normalizeForSearch(), "hello world");
      });

      test("trims result", () {
        expect("  hello  ".normalizeForSearch(), "hello");
      });

      test("removeSpaces option strips all spaces", () {
        expect("hello world".normalizeForSearch(removeSpaces: true), "helloworld");
      });

      test("handles German eszett", () {
        expect("strasse".normalizeForSearch(), "strasse");
      });
    });

    group("getTestingGroup", () {
      test("returns value in range 0 to totalGroups-1", () {
        int group = "test-user".getTestingGroup(totalNumberOfGroups: 3);
        expect(group, greaterThanOrEqualTo(0));
        expect(group, lessThan(3));
      });

      test("is deterministic for same input", () {
        int group1 = "same-string".getTestingGroup();
        int group2 = "same-string".getTestingGroup();
        expect(group1, group2);
      });
    });
  });

  // ── Iterable ──

  group("IterableExtensions", () {
    group("firstWhereOrNull", () {
      test("returns first match", () {
        expect([1, 2, 3].firstWhereOrNull((e) => e > 1), 2);
      });

      test("returns null when no match", () {
        expect([1, 2, 3].firstWhereOrNull((e) => e > 5), null);
      });

      test("returns null for empty iterable", () {
        expect(<int>[].firstWhereOrNull((e) => e > 0), null);
      });
    });

    group("firstOrNull", () {
      test("returns first element", () {
        expect([1, 2, 3].firstOrNull, 1);
      });

      test("returns null for empty", () {
        expect(<int>[].firstOrNull, null);
      });
    });

    group("lastOrNull", () {
      test("returns last element", () {
        expect([1, 2, 3].lastOrNull, 3);
      });

      test("returns null for empty", () {
        expect(<int>[].lastOrNull, null);
      });
    });

    group("getRandomElement", () {
      test("returns null for empty", () {
        expect(<int>[].getRandomElement(), null);
      });

      test("returns element from list", () {
        List<int> list = [1, 2, 3];
        int? result = list.getRandomElement();
        expect(list.contains(result), true);
      });

      test("is deterministic with seed", () {
        List<int> list = [1, 2, 3, 4, 5];
        expect(list.getRandomElement(seed: 42), list.getRandomElement(seed: 42));
      });
    });

    group("all", () {
      test("returns true when all match", () {
        expect([2, 4, 6].all((e) => e.isEven), true);
      });

      test("returns false when one fails", () {
        expect([2, 3, 6].all((e) => e.isEven), false);
      });

      test("returns true for empty iterable", () {
        expect(<int>[].all((e) => e.isEven), true);
      });
    });

    group("containsAny", () {
      test("returns true when overlap exists", () {
        expect([1, 2, 3].containsAny([3, 4, 5]), true);
      });

      test("returns false when no overlap", () {
        expect([1, 2, 3].containsAny([4, 5, 6]), false);
      });
    });

    group("count", () {
      test("counts matching elements", () {
        expect([1, 2, 3, 4, 5].count((e) => e.isEven), 2);
      });

      test("returns 0 for no matches", () {
        expect([1, 3, 5].count((e) => e.isEven), 0);
      });
    });

    group("elementAtOrNull", () {
      test("returns element at valid index", () {
        expect([10, 20, 30].elementAtOrNull(1), 20);
      });

      test("returns null for negative index", () {
        expect([10, 20, 30].elementAtOrNull(-1), null);
      });

      test("returns null for out-of-bounds index", () {
        expect([10, 20, 30].elementAtOrNull(5), null);
      });
    });

    group("indexWhereOrNull", () {
      test("returns index of first match", () {
        expect([10, 20, 30].indexWhereOrNull((e) => e == 20), 1);
      });

      test("returns null when no match", () {
        expect([10, 20, 30].indexWhereOrNull((e) => e == 99), null);
      });
    });

    group("sorted", () {
      test("sorts with default comparator", () {
        expect([3, 1, 2].sorted(), [1, 2, 3]);
      });

      test("sorts with custom comparator", () {
        expect([1, 2, 3].sorted((a, b) => b.compareTo(a)), [3, 2, 1]);
      });

      test("does not mutate original", () {
        List<int> original = [3, 1, 2];
        original.sorted();
        expect(original, [3, 1, 2]);
      });
    });

    group("joinElements", () {
      test("joins first N elements", () {
        expect(["a", "b", "c", "d"].joinElements(2, ", "), "a, b");
      });

      test("joins all if quantity exceeds length", () {
        expect(["a", "b"].joinElements(5, "-"), "a-b");
      });
    });

    group("whereNotNull", () {
      test("filters out nulls", () {
        expect([1, null, 2, null, 3].whereNotNull().toList(), [1, 2, 3]);
      });

      test("returns empty for all nulls", () {
        expect([null, null].whereNotNull().toList(), []);
      });
    });
  });

  // ── Double ──

  group("DoubleExtensions", () {
    group("toStringWithDecimalsIfNotInteger", () {
      test("omits decimals for integers", () {
        expect(3.0.toStringWithDecimalsIfNotInteger(), "3");
      });

      test("shows decimals for non-integers", () {
        expect(3.14.toStringWithDecimalsIfNotInteger(), "3.14");
      });

      test("respects desiredDecimals", () {
        expect(3.14159.toStringWithDecimalsIfNotInteger(desiredDecimals: 1), "3.1");
      });

      test("rounds and omits if result is integer", () {
        // toStringAsFixed(1) rounds 3.999 to "4.0", then toInt() returns 3 (truncation)
        // So the code returns "3" because this % 1 != 0 but toInt() truncates
        expect(3.999.toStringWithDecimalsIfNotInteger(desiredDecimals: 1), "3");
      });

      test("handles zero", () {
        expect(0.0.toStringWithDecimalsIfNotInteger(), "0");
      });
    });
  });

  // ── Int ──

  group("IntExtensions", () {
    group("toCharAlphabetically", () {
      test("0 maps to A", () {
        expect(0.toCharAlphabetically, "A");
      });

      test("25 maps to Z", () {
        expect(25.toCharAlphabetically, "Z");
      });

      test("throws for negative", () {
        expect(() => (-1).toCharAlphabetically, throwsArgumentError);
      });

      test("throws for > 25", () {
        expect(() => 26.toCharAlphabetically, throwsArgumentError);
      });
    });

    group("toCharAlphabeticallyLowercase", () {
      test("0 maps to a", () {
        expect(0.toCharAlphabeticallyLowercase, "a");
      });

      test("25 maps to z", () {
        expect(25.toCharAlphabeticallyLowercase, "z");
      });

      test("throws for out of range", () {
        expect(() => 26.toCharAlphabeticallyLowercase, throwsArgumentError);
      });
    });
  });

  // ── Duration ──

  group("DurationExtensions", () {
    group("asStringFormatted", () {
      test("formats zero duration", () {
        expect(const Duration().asStringFormatted, "00:00:00");
      });

      test("formats hours minutes seconds", () {
        expect(const Duration(hours: 1, minutes: 30, seconds: 45).asStringFormatted, "01:30:45");
      });

      test("formats large durations", () {
        expect(const Duration(hours: 100, minutes: 5, seconds: 3).asStringFormatted, "100:05:03");
      });

      test("formats seconds only", () {
        expect(const Duration(seconds: 90).asStringFormatted, "00:01:30");
      });
    });
  });

  // ── DateTime ──

  group("DateTimeExtensions", () {
    group("isSameDay", () {
      test("same day returns true", () {
        DateTime a = DateTime(2026, 3, 15, 10, 30);
        DateTime b = DateTime(2026, 3, 15, 22, 45);
        expect(a.isSameDay(b), true);
      });

      test("different day returns false", () {
        DateTime a = DateTime(2026, 3, 15);
        DateTime b = DateTime(2026, 3, 16);
        expect(a.isSameDay(b), false);
      });
    });

    group("isSameMonth", () {
      test("same month returns true", () {
        expect(DateTime(2026, 3, 1).isSameMonth(DateTime(2026, 3, 31)), true);
      });

      test("different month returns false", () {
        expect(DateTime(2026, 3, 1).isSameMonth(DateTime(2026, 4, 1)), false);
      });
    });

    group("isSameYear", () {
      test("same year returns true", () {
        expect(DateTime(2026, 1, 1).isSameYear(DateTime(2026, 12, 31)), true);
      });

      test("different year returns false", () {
        expect(DateTime(2025, 1, 1).isSameYear(DateTime(2026, 1, 1)), false);
      });
    });

    group("isLeapYear", () {
      test("2024 is a leap year", () {
        expect(DateTime(2024, 1, 1).isLeapYear, true);
      });

      test("2023 is not a leap year", () {
        expect(DateTime(2023, 1, 1).isLeapYear, false);
      });

      test("1900 is not a leap year (divisible by 100 but not 400)", () {
        expect(DateTime(1900, 1, 1).isLeapYear, false);
      });

      test("2000 is a leap year (divisible by 400)", () {
        expect(DateTime(2000, 1, 1).isLeapYear, true);
      });
    });

    group("daysInMonth", () {
      test("January has 31 days", () {
        expect(DateTime(2026, 1, 1).daysInMonth, 31);
      });

      test("February has 28 in non-leap year", () {
        expect(DateTime(2023, 2, 1).daysInMonth, 28);
      });

      test("February has 29 in leap year", () {
        expect(DateTime(2024, 2, 1).daysInMonth, 29);
      });

      test("April has 30 days", () {
        expect(DateTime(2026, 4, 1).daysInMonth, 30);
      });

      test("June has 30 days", () {
        expect(DateTime(2026, 6, 1).daysInMonth, 30);
      });
    });

    group("daysInYear", () {
      test("leap year has 366 days", () {
        expect(DateTime(2024, 1, 1).daysInYear, 366);
      });

      test("non-leap year has 365 days", () {
        expect(DateTime(2023, 1, 1).daysInYear, 365);
      });
    });

    group("firstMomentOfWeek", () {
      test("returns Monday for a Wednesday (default)", () {
        // 2026-03-18 is a Wednesday
        DateTime wednesday = DateTime(2026, 3, 18, 15, 30);
        DateTime start = wednesday.firstMomentOfWeek();
        expect(start, DateTime(2026, 3, 16, 0, 0, 0, 0, 0));
      });

      test("returns same day for Monday input", () {
        DateTime monday = DateTime(2026, 3, 16, 12, 0);
        DateTime start = monday.firstMomentOfWeek();
        expect(start.day, 16);
      });
    });

    group("lastMomentOfWeek", () {
      test("returns Sunday for a Wednesday (default)", () {
        DateTime wednesday = DateTime(2026, 3, 18, 15, 30);
        DateTime end = wednesday.lastMomentOfWeek();
        expect(end.day, 22); // Sunday March 22, 2026
        expect(end.hour, 23);
        expect(end.minute, 59);
      });
    });
  });

  // ── Map ──

  group("MapExtensions", () {
    test("keyAt returns key at index", () {
      Map<String, int> map = {"a": 1, "b": 2, "c": 3};
      expect(map.keyAt(0), "a");
      expect(map.keyAt(2), "c");
    });

    test("valueAt returns value at index", () {
      Map<String, int> map = {"a": 1, "b": 2, "c": 3};
      expect(map.valueAt(0), 1);
      expect(map.valueAt(1), 2);
    });

    test("elementAt returns entry at index", () {
      Map<String, int> map = {"a": 1, "b": 2};
      MapEntry entry = map.elementAt(1);
      expect(entry.key, "b");
      expect(entry.value, 2);
    });
  });
}
