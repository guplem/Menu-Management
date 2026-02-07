import "package:menu_management/flutter_essentials/library.dart";

/// A utility class for measuring and logging the duration of code segments.
///
/// Usage:
/// ```dart
/// final timer = DebugTimer(name: "MyOperation");
/// timer.start();
/// // ... perform work ...
/// timer.addEvent("Step 1 complete");
/// // ... perform more work ...
/// timer.addEvent("Step 2 complete");
/// timer.stop(); // Prints all events with their durations
/// ```
class DebugTimer {
  final String _name;
  final Stopwatch _stopwatch = Stopwatch();
  final List<MapEntry<Duration, String>> _events = [];
  Duration _lastEventDuration = Duration.zero;

  DebugTimer({required String name}) : _name = name;

  /// Starts the internal stopwatch.
  void start() => _stopwatch.start();

  /// Records a named event with the elapsed time since the last event (or start).
  void addEvent(String event) {
    _events.add(MapEntry(_stopwatch.elapsed - _lastEventDuration, event));
    _lastEventDuration = _stopwatch.elapsed;
  }

  /// Stops the stopwatch and prints all recorded events with their durations.
  void stop() {
    _stopwatch.stop();

    if (_events.isEmpty) {
      Debug.logDev("DebugTimer '$_name': No events recorded. Total: ${_stopwatch.elapsed}", maxStackTraceRows: 2);
      return;
    }

    Debug.logDev(
      "DebugTimer events of $_name:\n${_events.map((MapEntry<Duration, String> entry) {
        return "${entry.key}: ${entry.value}";
      }).join("\n")}\nTOTAL: ${_events.map((MapEntry<Duration, String> event) => event.key).reduce((Duration value, Duration duration) => value + duration)}",
      maxStackTraceRows: 2,
    );
  }
}
