enum RecipeType {
  breakfast(0),
  heavy(1),
  light(2),
  snack(3),
  dessert(4);

  const RecipeType(this.value);
  final int value;

  factory RecipeType.fromValue(int value) {
    return RecipeType.values.firstWhere((x) => x.value == value);
  }
}
