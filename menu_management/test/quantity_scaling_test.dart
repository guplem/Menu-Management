import "package:flutter_test/flutter_test.dart";
import "package:menu_management/recipes/enums/unit.dart";
import "package:menu_management/recipes/models/quantity.dart";

void main() {
  group("Unit.abbreviation", () {
    test("gives a short label to every unit", () {
      expect(Unit.grams.abbreviation, "g");
      expect(Unit.centiliters.abbreviation, "cl");
      expect(Unit.pieces.abbreviation, "pcs");
      expect(Unit.tablespoons.abbreviation, "tbsp");
      expect(Unit.teaspoons.abbreviation, "tsp");
    });
  });

  group("Quantity.scaledBy", () {
    test("multiplies the amount by the servings and keeps the unit", () {
      const Quantity base = Quantity(amount: 12.5, unit: Unit.grams);

      expect(base.scaledBy(4), const Quantity(amount: 50, unit: Unit.grams));
    });

    test("returns the base amount for one serving", () {
      const Quantity base = Quantity(amount: 7, unit: Unit.pieces);

      expect(base.scaledBy(1), base);
    });
  });

  group("Quantity.toDisplayText", () {
    test("writes the full unit name by default", () {
      expect(const Quantity(amount: 150, unit: Unit.grams).toDisplayText(), "150 grams");
    });

    test("writes the short unit name when the caller asks for it", () {
      expect(const Quantity(amount: 150, unit: Unit.grams).toDisplayText(abbreviateUnit: true), "150 g");
    });

    test("drops the decimals of a whole amount", () {
      expect(const Quantity(amount: 3, unit: Unit.teaspoons).toDisplayText(), "3 teaspoons");
    });

    test("keeps the decimals of a fractional amount", () {
      // Two decimals, the same as the cook mode screen showed before this helper existed.
      expect(const Quantity(amount: 2.5, unit: Unit.tablespoons).toDisplayText(), "2.50 tablespoons");
    });

    test("writes the same number in both unit spellings", () {
      // Cook mode and the markdown export must never show two different numbers for one amount.
      const Quantity scaled = Quantity(amount: 0.5, unit: Unit.centiliters);

      expect(scaled.toDisplayText(), "0.50 centiliters");
      expect(scaled.toDisplayText(abbreviateUnit: true), "0.50 cl");
    });

    test("rounds a scaled amount up instead of cutting the decimals away", () {
      // 33.333 grams for three servings is 99.999 grams. A truncating formatter printed "99 grams".
      const Quantity perServing = Quantity(amount: 33.333, unit: Unit.grams);

      expect(perServing.scaledBy(3).toDisplayText(), "100 grams");
    });
  });
}
