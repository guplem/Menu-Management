import "package:flutter/foundation.dart";
import "package:menu_management/flutter_essentials/library.dart";

/// Console text color options for debug output.
enum ColorsConsole { black, red, green, yellow, blue, magenta, cyan, white, standard }

/// Categories of log messages, each with a distinct signature and color.
enum LogType { log, warning, error, start, success, uploaded, downloaded, update, dev }

/// A structured debug logging utility with colored output, stack trace support,
/// and multiple log levels for different types of messages.
///
/// All methods are no-ops in release mode unless [printInRelease] is set to true.
/// Uses [debugPrint] by default to avoid output truncation in some environments.
class Debug {
  static String _getColorCode(ColorsConsole? color) {
    switch (color) {
      case ColorsConsole.black:
        return " \x1B[30m";
      case ColorsConsole.red:
        return " \x1B[31m";
      case ColorsConsole.green:
        return " \x1B[32m";
      case ColorsConsole.yellow:
        return " \x1B[33m";
      case ColorsConsole.blue:
        return " \x1B[34m";
      case ColorsConsole.magenta:
        return " \x1B[35m";
      case ColorsConsole.cyan:
        return " \x1B[36m";
      case ColorsConsole.white:
        return " \x1B[37m";
      case ColorsConsole.standard:
        return " \x1B[0m";
      default:
        return " \x1B[0m";
    }
  }

  /// General/standard log message. Shouldn't be used to log successful operations, errors or updates.
  /// Instead it should be used to provide relevant information that do not fall in any of those categories.
  ///
  /// Set [useDebugPrint] to true (default) to use [debugPrint], which avoids output truncation.
  static void log(
    String message, {
    String? signature,
    int? maxStackTraceRows,
    int? ignoredFirstStackTraceRows,
    bool? printInRelease,
    ColorsConsole? messageColor,
    bool? useDebugPrint,
    LogType? logType = LogType.log,
    StackTrace? stack,
  }) {
    if (!_shouldPrint(printInRelease)) return;

    if (stack == null) {
      stack = StackTrace.current;
      stack = stack.withoutLines(ignoredFirstStackTraceRows: ignoredFirstStackTraceRows ?? 0 + 1);
    }
    stack = stack.withoutLines(maxStackTraceRows: maxStackTraceRows ?? _getMaxDefaultStackTraceRowsFor(logType));

    String printMsg = _getFormattedMessageWithStackTrace(
      stack: stack,
      messageColor: messageColor,
      logType: logType,
      signature: signature,
      message: message,
    );
    if (useDebugPrint ?? true) {
      debugPrint(printMsg);
    } else {
      // ignore: avoid_print
      print(printMsg);
    }
  }

  /// Used to log the start of an operation or initialization.
  static void logStart(
    String message, {
    String? signature,
    int? maxStackTraceRows,
    int? ignoredFirstStackTraceRows,
    bool? printInRelease = true,
    ColorsConsole? messageColor,
    bool? useDebugPrint,
    StackTrace? stack,
  }) {
    if (!_shouldPrint(printInRelease)) return;
    log(
      message,
      stack: stack,
      logType: LogType.start,
      signature: signature,
      maxStackTraceRows: maxStackTraceRows,
      ignoredFirstStackTraceRows: ignoredFirstStackTraceRows ?? 0 + 3,
      printInRelease: printInRelease,
      messageColor: messageColor,
      useDebugPrint: useDebugPrint,
    );
  }

  /// Used to log successful general operations that are not directly related to the upload or download of resources.
  static void logSuccess(
    String message, {
    String? signature,
    int? maxStackTraceRows,
    int? ignoredFirstStackTraceRows,
    bool? printInRelease = true,
    ColorsConsole? messageColor,
    bool? useDebugPrint,
    StackTrace? stack,
  }) {
    if (!_shouldPrint(printInRelease)) return;
    log(
      message,
      stack: stack,
      logType: LogType.success,
      signature: signature,
      maxStackTraceRows: maxStackTraceRows,
      ignoredFirstStackTraceRows: ignoredFirstStackTraceRows ?? 0 + 3,
      printInRelease: printInRelease,
      messageColor: messageColor,
      useDebugPrint: useDebugPrint,
    );
  }

  /// Used to log successful upload operations.
  static void logUploaded(
    String message, {
    String? signature,
    int? maxStackTraceRows,
    int? ignoredFirstStackTraceRows,
    bool? printInRelease = true,
    ColorsConsole? messageColor,
    bool? useDebugPrint,
    StackTrace? stack,
  }) {
    if (!_shouldPrint(printInRelease)) return;
    log(
      message,
      stack: stack,
      logType: LogType.uploaded,
      signature: signature,
      maxStackTraceRows: maxStackTraceRows,
      ignoredFirstStackTraceRows: ignoredFirstStackTraceRows ?? 0 + 3,
      printInRelease: printInRelease,
      messageColor: messageColor,
      useDebugPrint: useDebugPrint,
    );
  }

  /// Used to log successful download operations.
  static void logDownloaded(
    String message, {
    String? signature,
    int? maxStackTraceRows,
    int? ignoredFirstStackTraceRows,
    bool? printInRelease = true,
    ColorsConsole? messageColor,
    bool? useDebugPrint,
    StackTrace? stack,
  }) {
    if (!_shouldPrint(printInRelease)) return;
    log(
      message,
      stack: stack,
      logType: LogType.downloaded,
      signature: signature,
      maxStackTraceRows: maxStackTraceRows,
      ignoredFirstStackTraceRows: ignoredFirstStackTraceRows ?? 0 + 3,
      printInRelease: printInRelease,
      messageColor: messageColor,
      useDebugPrint: useDebugPrint,
    );
  }

  /// Used to log updates on the state/configuration of the app.
  static void logUpdate(
    String message, {
    String? signature,
    int? maxStackTraceRows,
    int? ignoredFirstStackTraceRows,
    bool? printInRelease = true,
    ColorsConsole? messageColor,
    bool? useDebugPrint,
    StackTrace? stack,
  }) {
    if (!_shouldPrint(printInRelease)) return;
    log(
      message,
      stack: stack,
      logType: LogType.update,
      signature: signature,
      maxStackTraceRows: maxStackTraceRows,
      ignoredFirstStackTraceRows: ignoredFirstStackTraceRows ?? 0 + 3,
      printInRelease: printInRelease,
      messageColor: messageColor,
      useDebugPrint: useDebugPrint,
    );
  }

  /// Used to quickly debug things during development. These messages won't be printed in release mode.
  static void logDev(
    String message, {
    String? signature,
    int? maxStackTraceRows,
    int? ignoredFirstStackTraceRows,
    bool? printInRelease = false,
    ColorsConsole? messageColor,
    bool? useDebugPrint = true,
    StackTrace? stack,
  }) {
    if (!_shouldPrint(printInRelease)) return;
    log(
      message,
      stack: stack,
      logType: LogType.dev,
      signature: signature,
      maxStackTraceRows: maxStackTraceRows,
      ignoredFirstStackTraceRows: ignoredFirstStackTraceRows ?? 0 + 2,
      printInRelease: printInRelease,
      messageColor: messageColor,
      useDebugPrint: useDebugPrint,
    );
  }

  /// Used to log warnings conditionally. Things that didn't go as expected, but the app can still continue working properly.
  ///
  /// Use [asAssertion] to configure if the warning should be thrown as an assertion during development or just reported/printed.
  static void logWarning(
    bool showIf,
    String message, {
    String? signature,
    int? maxStackTraceRows,
    int? ignoredFirstStackTraceRows,
    bool? printInRelease = true,
    ColorsConsole? messageColor,
    bool? useDebugPrint = false,
    StackTrace? stack,
    bool asAssertion = true,
  }) {
    if (asAssertion && !kReleaseMode) {
      signature ??= _getSignatureFor(LogType.warning);
      assertion(message, showIf: showIf, signature: signature);
    } else if (showIf) {
      if (!_shouldPrint(printInRelease)) return;
      log(
        message,
        stack: stack,
        logType: LogType.warning,
        signature: signature,
        maxStackTraceRows: maxStackTraceRows,
        ignoredFirstStackTraceRows: ignoredFirstStackTraceRows ?? 0 + 3,
        printInRelease: printInRelease,
        messageColor: messageColor,
        useDebugPrint: useDebugPrint,
      );
    }
  }

  /// Used to log errors. Things that didn't go as expected and the app might not continue working properly.
  ///
  /// Throws an exception by default. Set [asException] to false to just print the error message.
  static void logError(
    String message, {
    bool asException = true,
    StackTrace? stack,
    String? signature,
    int? maxStackTraceRows,
    int? ignoredFirstStackTraceRows,
    bool? printInRelease = true,
    ColorsConsole? messageColor,
    bool? useDebugPrint = false,
  }) {
    if (!_shouldPrint(printInRelease)) return;
    if (asException) {
      signature ??= _getSignatureFor(LogType.error);
      stack ??= StackTrace.current.withoutLines(ignoredFirstStackTraceRows: ignoredFirstStackTraceRows ?? 0 + 2);
      Error.throwWithStackTrace("$signature$message", stack);
    } else {
      log(
        message,
        logType: LogType.error,
        signature: signature,
        maxStackTraceRows: maxStackTraceRows,
        ignoredFirstStackTraceRows: ignoredFirstStackTraceRows ?? 0 + 3,
        printInRelease: printInRelease,
        messageColor: messageColor,
        useDebugPrint: useDebugPrint,
        stack: stack,
      );
    }
  }

  /// Used to disrupt normal execution in debug mode via assertions.
  /// In production code, assertions are ignored and arguments to assert aren't evaluated.
  static void assertion(String message, {required bool showIf, String? signature}) {
    if (!showIf) return;
    assert(!showIf, "$signature$message");
  }

  static String _getSignatureFor(LogType? logType) {
    switch (logType) {
      case LogType.log:
        return "🪵 - Log: ";
      case LogType.warning:
        return "⚠️ - Warning: ";
      case LogType.error:
        return "‼️ - ERROR: ";
      case LogType.start:
        return "🔰 - Start: ";
      case LogType.success:
        return "✔ - Success: ";
      case LogType.uploaded:
        return "⬆️ - Uploaded: ";
      case LogType.downloaded:
        return "⬇️ - Downloaded: ";
      case LogType.update:
        return "🔄 - Update: ";
      case LogType.dev:
        return "🤙🏽 - Dev: ";
      default:
        return "";
    }
  }

  static ColorsConsole _getColorFor(LogType? logType) {
    switch (logType) {
      case LogType.log:
        return ColorsConsole.standard;
      case LogType.warning:
        return ColorsConsole.yellow;
      case LogType.error:
        return ColorsConsole.red;
      case LogType.start:
        return ColorsConsole.green;
      case LogType.success:
        return ColorsConsole.green;
      case LogType.uploaded:
        return ColorsConsole.blue;
      case LogType.downloaded:
        return ColorsConsole.cyan;
      case LogType.update:
        return ColorsConsole.white;
      case LogType.dev:
        return ColorsConsole.magenta;
      default:
        return ColorsConsole.standard;
    }
  }

  /// Returns a string with the message formatted with colors, signature, and stack trace.
  static String _getFormattedMessageWithStackTrace({
    required String message,
    required LogType? logType,
    required StackTrace stack,
    ColorsConsole? messageColor,
    String? signature,
    bool startWithNewLine = true,
  }) {
    signature ??= _getSignatureFor(logType);
    messageColor ??= _getColorFor(logType);
    return "${startWithNewLine ? "\n" : ""}${_getColorCode(messageColor)}$signature${_getMessageWithStackTrace(message + _getColorCode(ColorsConsole.standard), stack: stack, showFullStackTrace: false)}";
  }

  /// Returns a string with the message and the stack trace.
  static String _getMessageWithStackTrace(
    String message, {
    required StackTrace stack,
    bool showFullStackTrace = false,
    bool useTabsToSeparateLines = false,
  }) {
    if (message.runtimeType != String) message = message.toString();
    Iterable<String> lines = stack.toString().trimRight().split("\n");
    List<String> list = lines.toList();
    String fullMessage = "$message\n";

    for (int i = 0; i < lines.length; i++) {
      if (list[i].trimAndSetNullIfEmpty == null) continue;

      for (int t = i + 1; t > 0; t--) {
        fullMessage = "$fullMessage\t";
      }

      String callLoc = "";
      if (!showFullStackTrace) {
        final split = list[i].split(" ");
        callLoc =
            "${split.lastOrNull} [${split.first.split('/').lastOrNull} ${split.length > 1 ? split[1] : ''}]${useTabsToSeparateLines ? ' \t' : '\n'}";
      } else {
        callLoc = '${list[i]}${useTabsToSeparateLines ? ' \t' : '\n'}';
      }

      fullMessage = "$fullMessage↖ $callLoc";
    }
    return fullMessage;
  }

  static int _getMaxDefaultStackTraceRowsFor(LogType? logType) {
    switch (logType) {
      case LogType.log:
        return 1;
      case LogType.warning:
        return 5;
      case LogType.error:
        return 5;
      case LogType.dev:
        return 3;
      default:
        return 1;
    }
  }

  static bool _shouldPrint(bool? printInRelease) {
    if (kDebugMode || (printInRelease ?? true)) {
      return true;
    }
    return false;
  }
}
