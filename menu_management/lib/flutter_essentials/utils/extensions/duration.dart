/// Extensions on [Duration] for formatting.
extension DurationExtensions on Duration {
  /// Returns the duration as a formatted string in HH:MM:SS format.
  String get asStringFormatted {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(inSeconds.remainder(60));
    return "${twoDigits(inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}
