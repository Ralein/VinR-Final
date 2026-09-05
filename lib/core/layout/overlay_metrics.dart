import 'dart:math';
import 'package:flutter/material.dart';

/// VinR Overlay Metrics — Standard layout dimensions to prevent UI overlap collisions
class VinROverlayMetrics {
  VinROverlayMetrics._();

  /// Height of the bottom navigation bar excluding safe area
  static const double navBarHeight = 60.0;

  /// Diameter of the AI ChatHub (Buddy Chat FAB)
  static const double aiChatHubDiameter = 50.0;

  /// Margins for the AI ChatHub FAB
  static const double aiChatHubBottomMargin = 2.0;
  static const double aiChatHubRightMargin = 4.0;

  /// Minimum comfortable bottom gap to guarantee no interactive content
  /// is obscured by the AI ChatHub or bottom navigation bar.
  static double bottomContentPadding(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    // 60 (nav) + 50 (FAB) + bottomInset + 36 (comfortable breathing margin)
    return max(160.0, navBarHeight + aiChatHubDiameter + bottomInset + 36.0);
  }
}
