/// Extensions on [Future] for conditional execution.
extension FutureExtensions on Future {
  /// Conditionally awaits this future before executing [execute].
  ///
  /// If [condition] is true, awaits the future and passes the result to [execute].
  /// If false, calls [execute] immediately with [valueIfFutureNotAwaited].
  Future thenAfterAwaitingIf<R>({required bool condition, required R valueIfFutureNotAwaited, required dynamic Function(R) execute}) async {
    if (condition) {
      then((value) => execute(value));
    } else {
      this;
      execute(valueIfFutureNotAwaited);
    }
  }
}
