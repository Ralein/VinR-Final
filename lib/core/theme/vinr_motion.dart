import 'package:flutter/animation.dart';

/// VinR Motion System — Centralized animation durations and curves
class VinRMotion {
  VinRMotion._();

  // Standard Durations
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 450);
  static const Duration ambient = Duration(milliseconds: 1800);
  static const Duration breathe = Duration(milliseconds: 2500);

  // Curves
  static const Curve emphasized = Curves.easeOutCubic;
  static const Curve standard = Curves.easeInOut;
  static const Curve decelerate = Curves.easeOut;
  static const Curve bounce = Curves.elasticOut;
}
