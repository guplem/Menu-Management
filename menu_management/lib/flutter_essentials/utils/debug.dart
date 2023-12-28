import "package:flutter/foundation.dart";
import "package:menu_management/flutter_essentials/library.dart";

// COLORS IN CONSOLE: https://stackoverflow.com/a/65622986

enum ColorsConsole {
  black,
  red,
  green,
  yellow,
  blue,
  magenta,
  cyan,
  white,
  standard,
}

class Debug {
  static String _getColorCode(ColorsConsole color) {
    switch (color) {
      case ColorsConsole.black:
        return "\x1B[30m";
      case ColorsConsole.red:
        return "\x1B[31m";
      case ColorsConsole.green:
        return "\x1B[32m";
      case ColorsConsole.yellow:
        return "\x1B[33m";
      case ColorsConsole.blue:
        return "\x1B[34m";
      case ColorsConsole.magenta:
        return "\x1B[35m";
      case ColorsConsole.cyan:
        return "\x1B[36m";
      case ColorsConsole.white:
        return "\x1B[37m";
      case ColorsConsole.standard:
        return "\x1B[0m";
    }
  }

  /// General/standard log message. Shouldn't be used to log successful operations, errors or updates. Instead it should be used to provide relevant information that do not fall in any of those categories, so it should be rarely used.
  static void log(String message,
      {String signature = "🪵 ", int ignoredFirstStackTraceRows = 2, int maxStackTraceRows = 1, bool printInRelease = false, ColorsConsole messageColor = ColorsConsole.standard}) {
    if (kDebugMode || printInRelease) {
      // ignore: avoid_print
      print(
          "${_getColorCode(messageColor)}$signature${_getMessageWithStackTrace(message + _getColorCode(ColorsConsole.standard), ignoredFirstStackTraceRows: ignoredFirstStackTraceRows, maxStackTraceRows: maxStackTraceRows, showFullStackTrace: false)}");
    }
  }

  /// Used to log successful general operations that are not directly related to the upload or download of resources.
  static void logSuccess(String message,
      {String signature = "✔ ", int maxStackTraceRows = 1, int ignoredFirstStackTraceRows = 4, bool showFullStackTrace = false, ColorsConsole messageColor = ColorsConsole.green}) {
    log(message, signature: signature, ignoredFirstStackTraceRows: ignoredFirstStackTraceRows, maxStackTraceRows: maxStackTraceRows, messageColor: messageColor);
  }

  /// Used to log successful upload operations.
  static void logSuccessUpload(String message,
      {String signature = "⬆️", int maxStackTraceRows = 1, int ignoredFirstStackTraceRows = 4, bool showFullStackTrace = false, ColorsConsole messageColor = ColorsConsole.blue}) {
    log(message, signature: signature, ignoredFirstStackTraceRows: ignoredFirstStackTraceRows, maxStackTraceRows: maxStackTraceRows, messageColor: messageColor);
  }

  /// Used to log successful download operations.
  static void logSuccessDownload(String message,
      {String signature = "⬇️", int maxStackTraceRows = 1, int ignoredFirstStackTraceRows = 4, bool showFullStackTrace = false, ColorsConsole messageColor = ColorsConsole.cyan}) {
    log(message, signature: signature, ignoredFirstStackTraceRows: ignoredFirstStackTraceRows, maxStackTraceRows: maxStackTraceRows, messageColor: messageColor);
  }

  /// Used to log updates on the state/configuration of the app.
  static void logUpdate(String message,
      {String signature = "🔄 ", int maxStackTraceRows = 1, int ignoredFirstStackTraceRows = 4, bool showFullStackTrace = false, ColorsConsole messageColor = ColorsConsole.white}) {
    log(message, signature: signature, ignoredFirstStackTraceRows: ignoredFirstStackTraceRows, maxStackTraceRows: maxStackTraceRows, messageColor: messageColor);
  }

  /// Used to quickly debug things during development, this messages won't be printed in release mode.
  static void logDev(String message,
      {String signature = "🟥 ", int maxStackTraceRows = 1, int ignoredFirstStackTraceRows = 3, bool showFullStackTrace = false, ColorsConsole messageColor = ColorsConsole.magenta}) {
    if (kDebugMode) log(message, signature: signature, ignoredFirstStackTraceRows: ignoredFirstStackTraceRows, maxStackTraceRows: maxStackTraceRows, messageColor: messageColor);
  }

  /// Used to log warnings. Things that didn't go as expected, but the app can still continue working properly.
  static void logWarning(bool showIf, String message, {String signature = "⚠️", int maxStackTraceRows = 4, bool asAssertion = true}) {
    bool useAssertion = asAssertion && kDebugMode;
    if ((useAssertion && showIf) || showIf) {
      String msg = "${signature}Warning: ${_getMessageWithStackTrace(message, maxStackTraceRows: useAssertion ? 0 : maxStackTraceRows)}";
      if (useAssertion) {
        assert(!showIf, msg);
      } else if (showIf) {
        debugPrint("\x1B[33m$msg\x1B[0m");
      }
    }
  }

  /// Used to log errors. Things that didn't go as expected and the app might not continue working properly.
  static void logError(String message, {String signature = "‼️", int maxStackTraceRows = 5, bool showFullStackTrace = false, bool asException = true}) {
    String msg = "${signature}ERROR: ${_getMessageWithStackTrace(message, maxStackTraceRows: asException ? 0 : maxStackTraceRows)}";
    asException ? throw Exception(msg) : debugPrint("\x1B[31m$msg\x1B[0m");
  }

  static String _getMessageWithStackTrace(String message, {int ignoredFirstStackTraceRows = 2, int maxStackTraceRows = 2, bool showFullStackTrace = false}) {
    // Original code: https://github.com/sanihaq/better_print/blob/master/lib/better_print.dart

    if (message.runtimeType != String) message = message.toString();
    final stackTrace = StackTrace.current;
    Iterable<String> lines = stackTrace.toString().trimRight().split("\n");
    var list = lines.toList();
    String fullMessage = "$message\n";

    for (int i = ignoredFirstStackTraceRows; i < lines.length && i < maxStackTraceRows + ignoredFirstStackTraceRows; i++) {
      for (int t = i + 1 - ignoredFirstStackTraceRows; t > 0; t--) {
        fullMessage = "$fullMessage\t";
      }

      String callLoc = "";
      if (!showFullStackTrace) {
        final splitted = list[i].split(" ");
        callLoc = "${splitted.lastOrNull} [${splitted.first.split("/").lastOrNull} ${splitted[1]}]\n";
      } else {
        callLoc = "${list[i]}\n";
      }

      fullMessage = "$fullMessage↖ $callLoc"; //↖ //⬑
    }
    return fullMessage;
  }
}
