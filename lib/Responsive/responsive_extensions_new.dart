import 'package:flutter/material.dart';
import 'package:wood_service/Responsive/responsive_size.dart';
import 'package:wood_service/Responsive/screen_breakpoints.dart';

/// Extension methods on BuildContext for easy responsive access
extension ResponsiveContextExtension on BuildContext {
  /// Check if screen is mobile
  bool get isMobile => ScreenBreakpoints.isMobile(this);

  /// Check if screen is tablet
  bool get isTablet => ScreenBreakpoints.isTablet(this);

  /// Check if screen is desktop
  bool get isDesktop => ScreenBreakpoints.isDesktop(this);

  /// Get width percentage (0.0 to 1.0)
  /// Example: context.wp(0.5) = 50% of screen width
  double wp(double percentage) {
    return MediaQuery.of(this).size.width * percentage;
  }

  /// Get height percentage (0.0 to 1.0)
  /// Example: context.hp(0.5) = 50% of screen height
  double hp(double percentage) {
    return MediaQuery.of(this).size.height * percentage;
  }

  /// Get scalable font size
  /// Example: context.sp(16) = responsive 16sp font size
  double sp(double fontSize) {
    return ResponsiveSize.fontSize(this, fontSize);
  }

  /// Get responsive value based on device type
  /// Returns different values for mobile, tablet, and desktop
  /// Example: context.responsiveValue(mobile: 16, tablet: 20, desktop: 24)
  T responsiveValue<T>({
    required T mobile,
    required T tablet,
    required T desktop,
  }) {
    if (isMobile) return mobile;
    if (isTablet) return tablet;
    return desktop;
  }

  /// Get responsive width
  double w(double value) => ResponsiveSize.width(this, value);

  /// Get responsive height
  double h(double value) => ResponsiveSize.height(this, value);

  /// Get responsive padding all
  EdgeInsets pa(double value) => ResponsiveSize.paddingAll(this, value);

  /// Get responsive padding symmetric
  EdgeInsets ps({double? h, double? v}) =>
      ResponsiveSize.paddingSymmetric(this, horizontal: h, vertical: v);

  /// Get responsive padding only
  EdgeInsets po({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) =>
      ResponsiveSize.paddingOnly(
        this,
        left: left,
        top: top,
        right: right,
        bottom: bottom,
      );

  /// Get responsive margin all
  EdgeInsets ma(double value) => ResponsiveSize.marginAll(this, value);

  /// Get responsive margin symmetric
  EdgeInsets ms({double? h, double? v}) =>
      ResponsiveSize.marginSymmetric(this, horizontal: h, vertical: v);

  /// Get responsive margin only
  EdgeInsets mo({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) =>
      ResponsiveSize.marginOnly(
        this,
        left: left,
        top: top,
        right: right,
        bottom: bottom,
      );

  /// Get responsive border radius
  BorderRadius br(double radius) => ResponsiveSize.borderRadius(this, radius);
}
