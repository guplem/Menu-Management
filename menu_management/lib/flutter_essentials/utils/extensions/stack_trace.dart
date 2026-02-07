/// Extensions on [StackTrace] for filtering and manipulating stack trace lines.
///
/// Provides utilities to trim stack traces by removing initial lines or
/// limiting the total number of lines displayed, which is useful for
/// cleaner debug output.
extension StackTraceExtensions on StackTrace {
  /// Returns a new [StackTrace] with lines filtered based on the provided parameters.
  ///
  /// [ignoredFirstStackTraceRows] - Number of initial lines to skip (e.g., to hide
  /// internal framework calls).
  ///
  /// [maxStackTraceRows] - Maximum number of lines to include in the result.
  /// If null, all remaining lines after [ignoredFirstStackTraceRows] are included.
  /// If 0 or negative, returns [StackTrace.empty].
  StackTrace withoutLines({int ignoredFirstStackTraceRows = 0, int? maxStackTraceRows}) {
    if (maxStackTraceRows != null && maxStackTraceRows <= 0) {
      return StackTrace.empty;
    }

    String fullMessage = "";
    Iterable<String> lines = toString().trimRight().split("\n");
    List<String> list = lines.toList();
    maxStackTraceRows ??= lines.length;

    for (int i = ignoredFirstStackTraceRows; i < lines.length && i < maxStackTraceRows + ignoredFirstStackTraceRows; i++) {
      String callLoc = "${list[i]}\n";
      fullMessage = "$fullMessage$callLoc";
    }

    return StackTrace.fromString(fullMessage);
  }
}
