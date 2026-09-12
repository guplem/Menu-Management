enum Unit {
  grams(0),
  centiliters(1),
  pieces(2),
  tablespoons(3),
  teaspoons(4);

  const Unit(this.value);
  final int value;

  factory Unit.fromValue(int value) {
    return Unit.values.firstWhere((x) => x.value == value);
  }

  /// Short name of the unit, for places with little room such as the cook mode step list.
  String get abbreviation {
    switch (this) {
      case Unit.grams:
        return "g";
      case Unit.centiliters:
        return "cl";
      case Unit.pieces:
        return "pcs";
      case Unit.tablespoons:
        return "tbsp";
      case Unit.teaspoons:
        return "tsp";
    }
  }
}
