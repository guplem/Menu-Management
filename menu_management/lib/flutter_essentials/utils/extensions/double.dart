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
