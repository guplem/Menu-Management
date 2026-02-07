/// Extensions on [double] for common formatting operations.
extension DoubleExtensions on double {
  /// Formats the double as a string, omitting decimal places if the value is an integer.
  ///
  /// If the value has meaningful decimals, it will be formatted to [desiredDecimals] places.
  /// If the value is effectively an integer (e.g., 3.0, 3.00), it omits the decimal part.
  ///
  /// ```dart
  /// 3.0.toStringWithDecimalsIfNotInteger() // "3"
  /// 3.14.toStringWithDecimalsIfNotInteger() // "3.14"
  /// 3.999.toStringWithDecimalsIfNotInteger(desiredDecimals: 1) // "4"
  /// ```
  String toStringWithDecimalsIfNotInteger({int desiredDecimals = 2}) {
    assert(desiredDecimals >= 0, "desiredDecimals must be greater than or equal to 0");

    if (this % 1 == 0) {
      return toInt().toString();
    }

    String formattedValue = toStringAsFixed(desiredDecimals);

    if (double.parse(formattedValue) % 1 == 0) {
      return toInt().toString();
    }

    return formattedValue;
  }
}
