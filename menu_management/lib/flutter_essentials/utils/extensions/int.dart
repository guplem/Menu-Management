/// Extensions on [int] for character conversion.
extension IntExtensions on int {
  /// Converts an integer (0-25) to its corresponding uppercase letter (A-Z).
  ///
  /// Throws [ArgumentError] if the value is outside the range 0-25.
  ///
  /// ```dart
  /// 0.toCharAlphabetically // "A"
  /// 25.toCharAlphabetically // "Z"
  /// ```
  String get toCharAlphabetically {
    if (this < 0 || this > 25) {
      throw ArgumentError("toCharAlphabetically only works for numbers between 0 and 25, but got $this");
    }
    return String.fromCharCode(65 + this);
  }

  /// Converts an integer (0-25) to its corresponding lowercase letter (a-z).
  ///
  /// Throws [ArgumentError] if the value is outside the range 0-25.
  ///
  /// ```dart
  /// 0.toCharAlphabeticallyLowercase // "a"
  /// 25.toCharAlphabeticallyLowercase // "z"
  /// ```
  String get toCharAlphabeticallyLowercase {
    if (this < 0 || this > 25) {
      throw ArgumentError("toCharAlphabeticallyLowercase only works for numbers between 0 and 25, but got $this");
    }
    return String.fromCharCode(97 + this);
  }
}
