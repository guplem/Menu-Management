import "dart:math" as math;

import "package:flutter/animation.dart";

/// A custom elastic animation curve that produces a spring-like bounce effect.
///
/// This curve overshoots the target value and oscillates before settling,
/// creating a natural elastic feel. The [period] parameter controls the
/// frequency of oscillation (lower values = tighter oscillation).
///
/// Usage:
/// ```dart
/// AnimationController(
///   vsync: this,
///   duration: Duration(milliseconds: 500),
/// ).drive(CurveTween(curve: ElasticCurve()));
/// ```
class ElasticCurve extends Curve {
  /// The period of the oscillation. Default is 0.4.
  /// Lower values produce tighter, more frequent oscillations.
  final double period;

  const ElasticCurve({this.period = 0.4});

  @override
  double transformInternal(double t) {
    double s = period / 4.0;
    return math.pow(2.0, -10 * t) * math.sin((t - s) * (math.pi * 2.0) / period) + 1.0;
  }
}
