/// Evaluates the arithmetic in [text], for example "1/6", "2*250+100", or "(1+2)/3".
///
/// The text can hold numbers, `+`, `-`, `*`, `/`, parentheses, and spaces. A number can use a dot
/// or a comma as its decimal separator. `*` and `/` apply before `+` and `-`. Operators of equal
/// priority apply from left to right. A `+` or `-` in front of a number or a parenthesis is its sign.
///
/// Returns null for empty text, for text that is not complete arithmetic (such as "1/" while the
/// user types), for a division by zero, and for a number too large for a double. A plain decimal
/// number such as "2.5" or "1,5" gives its value.
double? evaluateArithmetic(String text) {
  _ArithmeticParser parser = _ArithmeticParser(text);
  if (parser.isAtEnd) return null;
  double? result = parser.parseSum();
  if (result == null || !parser.isAtEnd || !result.isFinite) return null;
  return result;
}

/// Evaluates the arithmetic in [text] like [evaluateArithmetic], for a field that needs a whole number.
///
/// Returns null when the text is not valid arithmetic or when the result is not whole. A result
/// that is whole apart from a double residue (0.1 * 3 * 10 gives 3.0000000000000004) counts as whole.
int? evaluateWholeArithmetic(String text) {
  double? result = evaluateArithmetic(text);
  if (result == null) return null;
  int rounded = result.round();
  if ((result - rounded).abs() > _wholeNumberTolerance) return null;
  return rounded;
}

/// The largest distance from a whole number that [evaluateWholeArithmetic] still reads as that number.
const double _wholeNumberTolerance = 1e-9;

/// A recursive-descent parser: each grammar rule below is one method.
///
/// ```
/// sum     = product (("+" | "-") product)*
/// product = factor (("*" | "/") factor)*
/// factor  = ("+" | "-") factor | "(" sum ")" | number
/// ```
///
/// Each method returns null when the text breaks its rule.
class _ArithmeticParser {
  _ArithmeticParser(this._text);

  final String _text;
  int _position = 0;

  static final RegExp _numberCharacter = RegExp(r"[\d.,]");

  /// Whether only spaces are left. It moves the position past those spaces, like [_peek].
  bool get isAtEnd => _peek() == null;

  /// The next character that is not a space, or null at the end of the text.
  ///
  /// It moves past spaces, so spaces can stand between numbers and operators. [_parseNumber]
  /// reads the text directly, so a space inside a number ("2 3") ends that number.
  String? _peek() {
    while (_position < _text.length && _text[_position] == " ") {
      _position++;
    }
    return _position < _text.length ? _text[_position] : null;
  }

  double? parseSum() {
    double? result = _parseProduct();
    while (result != null && (_peek() == "+" || _peek() == "-")) {
      String operator = _peek()!;
      _position++;
      double? right = _parseProduct();
      if (right == null) return null;
      result = operator == "+" ? result + right : result - right;
    }
    return result;
  }

  double? _parseProduct() {
    double? result = _parseFactor();
    while (result != null && (_peek() == "*" || _peek() == "/")) {
      String operator = _peek()!;
      _position++;
      double? right = _parseFactor();
      if (right == null) return null;
      if (operator == "/" && right == 0) return null;
      result = operator == "*" ? result * right : result / right;
    }
    return result;
  }

  double? _parseFactor() {
    String? current = _peek();
    if (current == "+" || current == "-") {
      _position++;
      double? value = _parseFactor();
      if (value == null) return null;
      return current == "-" ? -value : value;
    }
    if (current == "(") {
      _position++;
      double? value = parseSum();
      if (value == null || _peek() != ")") return null;
      _position++;
      return value;
    }
    return _parseNumber();
  }

  double? _parseNumber() {
    int start = _position;
    while (_position < _text.length && _numberCharacter.hasMatch(_text[_position])) {
      _position++;
    }
    String number = _text.substring(start, _position).replaceAll(",", ".");
    // double.tryParse also reads forms such as "1e3" or "NaN". The loop above lets through
    // only digits and separators, so here it reads a plain decimal number.
    double? value = double.tryParse(number);
    // A number too large for a double reads as infinity. 1 divided by it would give a finite 0.
    if (value == null || !value.isFinite) return null;
    return value;
  }
}
