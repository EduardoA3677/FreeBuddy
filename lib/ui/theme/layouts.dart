import 'package:flutter/cupertino.dart';

/// An enum to categorize the current window size class based on width.
///
/// Window size classes are a convenient way to define UI breakpoints:
/// - [compact]: Phones in portrait mode or very small devices.
/// - [medium]: Foldables, small tablets, or phones in landscape mode.
/// - [expanded]: Larger tablets or desktop screens.
///
/// Reference:
/// https://m3.material.io/foundations/layout/applying-layout/window-size-classes
enum WindowSizeClass {
  compact,
  medium,
  expanded;

  /// Determines the [WindowSizeClass] for the current screen width.
  ///
  /// - `compact`: width < 600
  /// - `medium`: 600 ≤ width < 840
  /// - `expanded`: width ≥ 840
  static WindowSizeClass of(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < 600) {
      return WindowSizeClass.compact;
    } else if (width < 840) {
      return WindowSizeClass.medium;
    } else {
      return WindowSizeClass.expanded;
    }
  }
}
