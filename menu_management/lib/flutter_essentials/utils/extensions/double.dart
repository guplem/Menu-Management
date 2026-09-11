/// Extensions on [double] for common formatting operations.
extension DoubleExtensions on double {
  /// Formats the double as an integer string with comma thousand separators for readability.
  ///
  /// ```dart
  /// 1500.0.toFormattedAmount() // "1,500"
  /// 42.0.toFormattedAmount()   // "42"
  /// 1234567.0.toFormattedAmount() // "1,234,567"
  /// ```
  String toFormattedAmount() {
    String str = toStringAsFixed(0);
    StringBuffer result = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) result.write(",");
      result.write(str[i]);
      count++;
    }
    return String.fromCharCodes(result.toString().codeUnits.reversed.toList());
  }

  /// Formats the double as a string, omitting decimal places if the value is an integer.
  ///
  /// If the value has meaningful decimals, it will be formatted to [desiredDecimals] places.
  /// If the value is effectively an integer (e.g., 3.0, 3.00), it omits the decimal part.
  ///
  /// The whole-number result is the rounded value, never the cut value. 0.999 gives "1", not "0".
  ///
  /// ```dart
  /// 3.0.toStringWithDecimalsIfNotInteger() // "3"
  /// 3.14.toStringWithDecimalsIfNotInteger() // "3.14"
  /// 3.999.toStringWithDecimalsIfNotInteger(desiredDecimals: 1) // "4"
  /// ```
  String toStringWithDecimalsIfNotInteger({int desiredDecimals = 2}) {
    assert(desiredDecimals >= 0, "desiredDecimals must be greater than or equal to 0");

    String formattedValue = toStringAsFixed(desiredDecimals);
    double roundedValue = double.parse(formattedValue);

    // Read the whole number from the rounded value. `toInt()` on the original value cuts the
    // decimals away, so 99.999 would print "99" and 0.999 would print "0".
    if (roundedValue % 1 == 0) {
      return roundedValue.toInt().toString();
    }

    return formattedValue;
  }
}
