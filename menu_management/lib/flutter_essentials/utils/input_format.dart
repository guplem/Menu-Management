import "package:flutter/services.dart";

/// A collection of common [TextInputFormatter] presets for form fields.
///
/// Provides ready-to-use formatters for names, usernames, prices,
/// digit-only inputs, and alphanumeric text.
class InputFormat {
  /// Allows letters (including accented), apostrophes, middle dots, and spaces.
  static TextInputFormatter get name {
    return FilteringTextInputFormatter.allow(RegExp("[a-zA-Zá-úÁ-Ú'· ]"));
  }

  /// Allows usernames starting with @ followed by alphanumeric characters,
  /// dots, underscores, and hyphens.
  static TextInputFormatter get username {
    return FilteringTextInputFormatter.allow(RegExp(r"^@[a-zA-Z0-9._-]*"));
  }

  /// Allows price input with optional € prefix, digits, and up to 2 decimal places.
  static TextInputFormatter get price {
    return FilteringTextInputFormatter.allow(RegExp(r"^€?\d+\.?\d{0,2}"));
  }

  /// Allows only digits (0-9).
  static TextInputFormatter get digitsOnly {
    return FilteringTextInputFormatter.digitsOnly;
  }

  /// Allows only alphanumeric characters (a-z, A-Z, 0-9).
  static TextInputFormatter get alphanumeric {
    return FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9]"));
  }
}
