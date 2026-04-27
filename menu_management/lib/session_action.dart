enum SessionAction {
  saved(0),
  loaded(1);

  const SessionAction(this.value);
  final int value;

  factory SessionAction.fromValue(int value) {
    return SessionAction.values.firstWhere((x) => x.value == value);
  }
}
