extension StringNullableExtensions on String? {
  String? capitalizeFirstLetter({bool restOfStringToLowerCase = false}) {
    if (this == null) return null;
    if (this!.isEmpty) return "";
    String rest = restOfStringToLowerCase
        ? this!.substring(1).toLowerCase()
        : this!.substring(1);
    return "${this![0].toUpperCase()}$rest";
  }

  String? get trimAndSetNullIfEmpty {
    String? result = this?.trim();
    if (result.isNullOrEmpty) return null;
    return result;
  }

  String get digits {
    return (this ?? "").replaceAll(RegExp(r"[^0-9]"), "");
  }

  int? get digitsInt {
    String? txt = digits.trimAndSetNullIfEmpty;
    if (txt.isNullOrEmpty) return null;
    return int.parse(txt!);
  }

  bool get isNullOrEmpty {
    return this == null || this!.isEmpty || this == "";
  }
}
