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
}