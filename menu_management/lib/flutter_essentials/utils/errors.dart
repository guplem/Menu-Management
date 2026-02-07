/// An error type for features or operations that are recognized but not supported.
///
/// Unlike [UnsupportedError], which indicates something that is fundamentally
/// not possible, [NotSupportedError] conveys that the operation exists but
/// is intentionally not supported in the current context.
class NotSupportedError extends Error implements UnsupportedError {
  @override
  final String? message;

  NotSupportedError([this.message]);

  @override
  String toString() {
    String? message = this.message;
    return (message != null) ? "NotSupportedError: $message" : "NotSupportedError";
  }
}
