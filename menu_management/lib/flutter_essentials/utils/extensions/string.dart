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

  /// Normalizes the string for search operations by:
  /// - Removing accents and diacritics
  /// - Removing special characters (keeping only alphanumeric and spaces)
  /// - Converting to lowercase
  /// - Collapsing multiple spaces
  /// - Trimming the result
  ///
  /// This is useful for case-insensitive, accent-insensitive searching.
  ///
  /// Example:
  /// ```dart
  /// "Crème Brûlée".normalizeForSearch() // "creme brulee"
  /// "Café's Place".normalizeForSearch() // "cafes place"
  /// ```
  String normalizeForSearch({bool removeSpaces = false}) {
    String normalized = this;

    // Remove accents and diacritics using Unicode decomposition
    const decompositions = {
      "à": "a",
      "á": "a",
      "â": "a",
      "ã": "a",
      "ä": "a",
      "å": "a",
      "ā": "a",
      "ă": "a",
      "ą": "a",
      "ć": "c",
      "č": "c",
      "ċ": "c",
      "ç": "c",
      "ď": "d",
      "đ": "d",
      "è": "e",
      "é": "e",
      "ê": "e",
      "ë": "e",
      "ē": "e",
      "ĕ": "e",
      "ė": "e",
      "ę": "e",
      "ě": "e",
      "ĝ": "g",
      "ğ": "g",
      "ġ": "g",
      "ģ": "g",
      "ĥ": "h",
      "ħ": "h",
      "ì": "i",
      "í": "i",
      "î": "i",
      "ï": "i",
      "ĩ": "i",
      "ī": "i",
      "ĭ": "i",
      "į": "i",
      "ı": "i",
      "ĵ": "j",
      "ķ": "k",
      "ĺ": "l",
      "ļ": "l",
      "ľ": "l",
      "ŀ": "l",
      "ł": "l",
      "ñ": "n",
      "ń": "n",
      "ņ": "n",
      "ň": "n",
      "ŉ": "n",
      "ŋ": "n",
      "ò": "o",
      "ó": "o",
      "ô": "o",
      "õ": "o",
      "ö": "o",
      "ø": "o",
      "ō": "o",
      "ŏ": "o",
      "ő": "o",
      "ŕ": "r",
      "ŗ": "r",
      "ř": "r",
      "ś": "s",
      "ŝ": "s",
      "ş": "s",
      "š": "s",
      "ţ": "t",
      "ť": "t",
      "ŧ": "t",
      "ù": "u",
      "ú": "u",
      "û": "u",
      "ü": "u",
      "ũ": "u",
      "ū": "u",
      "ŭ": "u",
      "ů": "u",
      "ű": "u",
      "ų": "u",
      "ŵ": "w",
      "ŷ": "y",
      "ý": "y",
      "ÿ": "y",
      "ź": "z",
      "ż": "z",
      "ž": "z",
      "æ": "ae",
      "œ": "oe",
      "ß": "ss",
      "ð": "d",
      "þ": "th",
    };

    decompositions.forEach((accented, replacement) {
      normalized = normalized.replaceAll(accented, replacement);
      normalized = normalized.replaceAll(accented.toUpperCase(), replacement);
    });

    // Remove special characters, keep only alphanumeric and spaces
    normalized = normalized.replaceAll(RegExp(r"[^a-zA-Z0-9\s]"), "");

    // Collapse multiple spaces into one
    normalized = normalized.replaceAll(RegExp(r"\s+"), " ");

    // Remove spaces
    if (removeSpaces) {
      normalized = normalized.replaceAll(" ", "");
    }

    // Convert to lowercase and trim
    return normalized.toLowerCase().trim();
  }
}
