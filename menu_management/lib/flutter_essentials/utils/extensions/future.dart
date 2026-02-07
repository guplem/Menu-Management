extension FutureExtensions on Future {
  // https://stackoverflow.com/a/61632770/7927429
  Future thenAfterAwaitingIf<R>({
    required bool condition,
    required R valueIfFutureNotAwaited,
    required dynamic Function(R) execute,
  }) async {
    if (condition) {
      then((value) => execute(value));
    } else {
      this;
      execute(valueIfFutureNotAwaited);
    }
  }
}
