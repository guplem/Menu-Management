enum WeekDay {
  saturday(0),
  sunday(1),
  monday(2),
  tuesday(3),
  wednesday(4),
  thursday(5),
  friday(6);

  const WeekDay(this.value);
  final int value;

  factory WeekDay.fromValue(int value) {
    return WeekDay.values.firstWhere((x) => x.value == value);
  }

  bool goesBefore(WeekDay other) {
    return value < other.value;
  }

  bool goesAfter(WeekDay other) {
    return value > other.value;
  }
}
