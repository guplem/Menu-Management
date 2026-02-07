enum MealType {
  breakfast(0),
  lunch(1),
  dinner(2);

  const MealType(this.value);
  final int value;

  factory MealType.fromValue(int value) {
    return MealType.values.firstWhere((x) => x.value == value);
  }

  bool goesBefore(MealType other) {
    return value < other.value;
  }

  bool goesAfter(MealType other) {
    return value > other.value;
  }
}
