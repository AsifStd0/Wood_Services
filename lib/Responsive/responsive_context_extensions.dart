import 'package:flutter/material.dart';
import 'package:wood_service/Responsive/responsive_size.dart';
import 'package:wood_service/Responsive/screen_breakpoints.dart';

/// Extension methods on BuildContext for responsive design
extension ResponsiveContextExtension on BuildContext {
  // ========== SCREEN TYPE CHECKS ==========

  /// Check if current screen is mobile (< 600px)
  bool get isMobile => ScreenBreakpoints.isMobile(this);

  /// Check if current screen is tablet (600px - 1024px)
  bool get isTablet => ScreenBreakpoints.isTablet(this);

  /// Check if current screen is desktop (> 1024px)
  bool get isDesktop => ScreenBreakpoints.isDesktop(this);

  // ========== WIDTH & HEIGHT PERCENTAGES ==========

  /// Get width percentage of screen
  /// Example: context.wp(50) = 50% of screen width
  double wp(double percentage) {
    final screenWidth = MediaQuery.of(this).size.width;
    return (screenWidth * percentage) / 100;
  }

  /// Get height percentage of screen
  /// Example: context.hp(50) = 50% of screen height
  double hp(double percentage) {
    final screenHeight = MediaQuery.of(this).size.height;
    return (screenHeight * percentage) / 100;
  }

  /// Get responsive width (design-based)
  /// Example: context.w(300) = responsive width based on design size
  double w(double value) => ResponsiveSize.width(this, value);

  /// Get responsive height (design-based)
  /// Example: context.h(100) = responsive height based on design size
  double h(double value) => ResponsiveSize.height(this, value);

  // ========== RESPONSIVE FONT SIZE ==========

  /// Get scalable font size based on screen size
  /// Example: context.sp(16) = responsive 16sp font size
  double sp(double fontSize) {
    return ResponsiveSize.fontSize(this, fontSize);
  }

  // ========== RESPONSIVE VALUES ==========

  /// Get different values based on device type
  /// Example: context.responsiveValue(mobile: 16, tablet: 24, desktop: 32)
  T responsiveValue<T>({
    required T mobile,
    required T tablet,
    required T desktop,
  }) {
    if (isMobile) return mobile;
    if (isTablet) return tablet;
    return desktop;
  }

  // ========== RESPONSIVE WIDTH & HEIGHT ==========

  // /// Get responsive width
  // /// Example: context.w(300) = responsive width of 300
  // double w(double value) => ResponsiveSize.width(this, value);

  // /// Get responsive height
  // /// Example: context.h(100) = responsive height of 100
  // double h(double value) => ResponsiveSize.height(this, value);

  // ========== RESPONSIVE PADDING ==========

  /// Get responsive padding all
  EdgeInsets paddingAll(double value) => ResponsiveSize.paddingAll(this, value);

  /// Get responsive padding symmetric
  EdgeInsets paddingSym({double? horizontal, double? vertical}) =>
      ResponsiveSize.paddingSymmetric(
        this,
        horizontal: horizontal,
        vertical: vertical,
      );

  /// Get responsive padding only
  EdgeInsets paddingOnly({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) => ResponsiveSize.paddingOnly(
    this,
    left: left,
    top: top,
    right: right,
    bottom: bottom,
  );

  // ========== RESPONSIVE MARGIN ==========

  /// Get responsive margin all
  EdgeInsets marginAll(double value) => ResponsiveSize.marginAll(this, value);

  /// Get responsive margin symmetric
  EdgeInsets marginSym({double? horizontal, double? vertical}) =>
      ResponsiveSize.marginSymmetric(
        this,
        horizontal: horizontal,
        vertical: vertical,
      );

  /// Get responsive margin only
  EdgeInsets marginOnly({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) => ResponsiveSize.marginOnly(
    this,
    left: left,
    top: top,
    right: right,
    bottom: bottom,
  );

  // ========== RESPONSIVE RADIUS ==========

  /// Get responsive border radius
  BorderRadius borderRadius(double radius) =>
      ResponsiveSize.borderRadius(this, radius);

  /// Get responsive radius value
  double r(double value) => ResponsiveSize.radius(this, value);

  // ========== SCREEN DIMENSIONS ==========

  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;
}
