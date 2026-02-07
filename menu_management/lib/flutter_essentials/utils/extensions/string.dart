// ignore_for_file: valid_regexps

/// Extensions on nullable [String] for common text operations.
extension StringNullableExtensions on String? {
  /// Capitalizes the first letter of the string.
  ///
  /// If [restOfStringToLowerCase] is true, the remaining characters are lowercased.
  String? capitalizeFirstLetter({bool restOfStringToLowerCase = false}) {
    if (this == null) return null;
    if (this!.isEmpty) return "";
    String rest = restOfStringToLowerCase ? this!.substring(1).toLowerCase() : this!.substring(1);
    return "${this![0].toUpperCase()}$rest";
  }

  /// Trims whitespace and returns null if the result is empty.
  String? get trimAndSetNullIfEmpty {
    String? result = this?.trim();
    if (result.isNullOrEmpty) return null;
    return result;
  }

  /// Extracts only digit characters from the string.
  String get digits {
    return (this ?? "").replaceAll(RegExp(r"[^0-9]"), "");
  }

  /// Extracts digits and parses them as an integer, or returns null if no digits exist.
  int? get digitsInt {
    String? txt = digits.trimAndSetNullIfEmpty;
    if (txt.isNullOrEmpty) return null;
    return int.parse(txt!);
  }

  /// Returns true if the string is null or empty.
  bool get isNullOrEmpty {
    return this == null || this!.isEmpty;
  }

  /// Returns the first [charCount] characters, or the whole string if shorter.
  String? first(int charCount) {
    if (this == null) return null;
    if (this!.length <= charCount) return this;
    return this!.substring(0, charCount);
  }

  /// Returns the last [charCount] characters, or the whole string if shorter.
  String? last(int charCount) {
    if (this == null) return null;
    if (this!.length <= charCount) return this;
    return this!.substring(this!.length - charCount);
  }

  /// Returns true if the string is a single emoji (including compound emojis).
  bool isSingleEmoji() {
    if (isNullOrEmpty) return false;

    RegExp emojiRegExp = RegExp(
      r"(\p{Emoji_Presentation}\uFE0F?(?:\p{Emoji_Modifier})?|\p{Extended_Pictographic}\uFE0F?(?:\p{Emoji_Modifier})?)(?:\u200D(\p{Emoji_Presentation}\uFE0F?(?:\p{Emoji_Modifier})?|\p{Extended_Pictographic}\uFE0F?(?:\p{Emoji_Modifier})?))*",
      unicode: true,
    );

    Iterable<RegExpMatch> matches = emojiRegExp.allMatches(this!);
    return matches.length == 1 && matches.first.group(0) == this;
  }
}

/// Extensions on non-nullable [String].
extension StringExtensions on String {
  /// Assigns this string to a testing group (0-based index) using its hash code.
  ///
  /// Useful for A/B testing or feature flag rollouts.
  int getTestingGroup({int totalNumberOfGroups = 2}) {
    assert(totalNumberOfGroups > 1, "Total number of groups must be > 1");
    assert(isNotEmpty, "String cannot be empty");
    return hashCode.abs() % totalNumberOfGroups;
  }
}
