import 'package:flutter/material.dart';
import 'package:wood_service/Responsive/screen_utils.dart';

/// Extension on BuildContext for easy access to ScreenUtils
extension ResponsiveExtension on BuildContext {
  /// Get responsive width
  double w(double width) => ScreenUtils.w(width);

  /// Get responsive height
  double h(double height) => ScreenUtils.h(height);

  /// Get responsive font size
  double sp(double fontSize) => ScreenUtils.sp(fontSize);

  /// Get responsive radius
  double r(double radius) => ScreenUtils.r(radius);

  /// Get responsive spacing
  double space(double spacing) => ScreenUtils.space(spacing);

  /// Get screen width
  double get screenWidth => ScreenUtils.screenWidth;

  /// Get screen height
  double get screenHeight => ScreenUtils.screenHeight;

  /// Get responsive padding all
  EdgeInsets paddingAll(double value) => ScreenUtils.paddingAll(value);

  /// Get responsive padding symmetric
  EdgeInsets paddingSym({double? h, double? v}) =>
      ScreenUtils.paddingSym(h: h, v: v);

  /// Get responsive padding only
  EdgeInsets paddingOnly({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) =>
      ScreenUtils.paddingOnly(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
      );

  /// Get responsive border radius
  BorderRadius borderRadius(double radius) =>
      ScreenUtils.borderRadius(radius);

  /// Check if tablet
  bool get isTablet => ScreenUtils.isTablet;

  /// Check if phone
  bool get isPhone => ScreenUtils.isPhone;

  /// Check if landscape
  bool get isLandscape => ScreenUtils.isLandscape(this);

  /// Check if portrait
  bool get isPortrait => ScreenUtils.isPortrait(this);
}

/// Extension on double for responsive values
extension ResponsiveDoubleExtension on double {
  /// Convert to responsive width
  double get w => ScreenUtils.w(this);

  /// Convert to responsive height
  double get h => ScreenUtils.h(this);

  /// Convert to responsive font size
  double get sp => ScreenUtils.sp(this);

  /// Convert to responsive radius
  double get r => ScreenUtils.r(this);

  /// Convert to responsive spacing
  double get space => ScreenUtils.space(this);

  /// Convert to responsive padding all
  EdgeInsets get paddingAll => ScreenUtils.paddingAll(this);

  /// Convert to responsive border radius
  BorderRadius get borderRadius => ScreenUtils.borderRadius(this);
}

/// Extension on int for responsive values
extension ResponsiveIntExtension on int {
  /// Convert to responsive width
  double get w => ScreenUtils.w(toDouble());

  /// Convert to responsive height
  double get h => ScreenUtils.h(toDouble());

  /// Convert to responsive font size
  double get sp => ScreenUtils.sp(toDouble());

  /// Convert to responsive radius
  double get r => ScreenUtils.r(toDouble());

  /// Convert to responsive spacing
  double get space => ScreenUtils.space(toDouble());
}
