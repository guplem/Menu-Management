import "package:flutter_test/flutter_test.dart";
import "package:menu_management/flutter_essentials/utils/arithmetic_expression.dart";
import "package:menu_management/flutter_essentials/utils/input_format.dart";

void main() {
  group("evaluateArithmetic", () {
    group("plain numbers", () {
      test("reads a whole number and a decimal number", () {
        expect(evaluateArithmetic("5"), 5);
        expect(evaluateArithmetic("2.5"), 2.5);
        expect(evaluateArithmetic(".5"), 0.5);
        expect(evaluateArithmetic("3."), 3);
      });

      test("reads a comma as the decimal separator", () {
        expect(evaluateArithmetic("1,5"), 1.5);
        expect(evaluateArithmetic("1,5*2"), 3);
      });

      test("ignores spaces", () {
        expect(evaluateArithmetic("  2 * 3 "), 6);
      });
    });

    group("operations", () {
      test("adds, subtracts, multiplies, and divides", () {
        expect(evaluateArithmetic("2+3"), 5);
        expect(evaluateArithmetic("10-4"), 6);
        expect(evaluateArithmetic("6*7"), 42);
        expect(evaluateArithmetic("1/4"), 0.25);
        expect(evaluateArithmetic("1/6"), 1 / 6);
      });

      test("multiplies and divides before it adds and subtracts", () {
        expect(evaluateArithmetic("2*250+100"), 600);
        expect(evaluateArithmetic("100-10/2"), 95);
      });

      test("evaluates operators of equal priority from left to right", () {
        expect(evaluateArithmetic("10-4-3"), 3);
        expect(evaluateArithmetic("12/3/2"), 2);
      });

      test("evaluates parentheses first", () {
        expect(evaluateArithmetic("(1+2)/3"), 1);
        expect(evaluateArithmetic("2*(3+(4-1))"), 12);
      });

      test("reads a sign in front of a number or a parenthesis", () {
        expect(evaluateArithmetic("-3+5"), 2);
        expect(evaluateArithmetic("4*-2"), -8);
        expect(evaluateArithmetic("-(2+3)"), -5);
        expect(evaluateArithmetic("+2"), 2);
      });
    });

    group("invalid text", () {
      test("gives null for empty text", () {
        expect(evaluateArithmetic(""), isNull);
        expect(evaluateArithmetic("   "), isNull);
      });

      test("gives null for an expression that is not complete", () {
        // The user is still typing: "1/" must not count as any amount yet.
        expect(evaluateArithmetic("1/"), isNull);
        expect(evaluateArithmetic("2+"), isNull);
        expect(evaluateArithmetic("(1+2"), isNull);
        expect(evaluateArithmetic("1+2)"), isNull);
        expect(evaluateArithmetic("()"), isNull);
        expect(evaluateArithmetic("."), isNull);
      });

      test("gives null for a number with two decimal separators", () {
        expect(evaluateArithmetic("1.2.3"), isNull);
        expect(evaluateArithmetic("1,2.3"), isNull);
      });

      test("gives null for text that is not arithmetic", () {
        expect(evaluateArithmetic("abc"), isNull);
        expect(evaluateArithmetic("2x3"), isNull);
        expect(evaluateArithmetic("2 3"), isNull);
      });

      test("gives null for a division by zero", () {
        expect(evaluateArithmetic("1/0"), isNull);
        expect(evaluateArithmetic("1/(2-2)"), isNull);
      });
    });
  });

  group("evaluateWholeArithmetic", () {
    test("gives the whole number of an expression", () {
      expect(evaluateWholeArithmetic("90/2"), 45);
      expect(evaluateWholeArithmetic("6*4"), 24);
    });

    test("accepts a whole result that a double leaves a residue on", () {
      // 0.1 * 3 * 10 is 3.0000000000000004 in doubles.
      expect(evaluateWholeArithmetic("0.1*3*10"), 3);
    });

    test("gives null for a result that is not whole", () {
      expect(evaluateWholeArithmetic("10/3"), isNull);
      expect(evaluateWholeArithmetic("2.5"), isNull);
    });

    test("gives null for invalid text", () {
      expect(evaluateWholeArithmetic("1/"), isNull);
      expect(evaluateWholeArithmetic(""), isNull);
    });
  });

  group("InputFormat.arithmetic", () {
    TextEditingValue format(String text) {
      return InputFormat.arithmetic.formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: text));
    }

    test("keeps digits, separators, operators, parentheses, and spaces", () {
      expect(format("(1,5 + 2.5) * 3 / 4 - 1").text, "(1,5 + 2.5) * 3 / 4 - 1");
    });

    test("drops letters and other symbols", () {
      expect(format("2x3€=").text, "23");
    });
  });
}
