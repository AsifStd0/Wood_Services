import 'package:flutter/material.dart';

/// ResponsiveSize class for handling responsive sizing
/// Provides methods for width, height, font size, padding, and margin
class ResponsiveSize {
  ResponsiveSize._();

  /// Get responsive width based on screen width
  /// [value] is the design width (e.g., 300 for 300px design width)
  static double width(BuildContext context, double value) {
    final screenWidth = MediaQuery.of(context).size.width;
    final designWidth = 375.0; // iPhone X design width
    return (value / designWidth) * screenWidth;
  }

  /// Get responsive height based on screen height
  /// [value] is the design height (e.g., 100 for 100px design height)
  static double height(BuildContext context, double value) {
    final screenHeight = MediaQuery.of(context).size.height;
    final designHeight = 812.0; // iPhone X design height
    return (value / designHeight) * screenHeight;
  }

  /// Get responsive font size that scales with screen size
  /// [fontSize] is the base font size (e.g., 16 for 16sp)
  static double fontSize(BuildContext context, double fontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final designWidth = 375.0;
    final scaleFactor = screenWidth / designWidth;
    
    // Clamp scale factor between 0.8 and 1.2 for better readability
    final clampedScale = scaleFactor.clamp(0.8, 1.2);
    
    return fontSize * clampedScale;
  }

  /// Get responsive padding value
  /// [value] is the padding value in design pixels
  static double padding(BuildContext context, double value) {
    return width(context, value);
  }

  /// Get responsive margin value
  /// [value] is the margin value in design pixels
  static double margin(BuildContext context, double value) {
    return width(context, value);
  }

  /// Get responsive spacing value
  /// [value] is the spacing value in design pixels
  static double spacing(BuildContext context, double value) {
    return width(context, value);
  }

  /// Get responsive radius value
  /// [value] is the radius value in design pixels
  static double radius(BuildContext context, double value) {
    return width(context, value);
  }

  /// Get responsive EdgeInsets with all sides equal
  static EdgeInsets paddingAll(BuildContext context, double value) {
    final paddingValue = padding(context, value);
    return EdgeInsets.all(paddingValue);
  }

  /// Get responsive EdgeInsets symmetric
  static EdgeInsets paddingSymmetric(
    BuildContext context, {
    double? horizontal,
    double? vertical,
  }) {
    return EdgeInsets.symmetric(
      horizontal: horizontal != null ? padding(context, horizontal) : 0,
      vertical: vertical != null ? padding(context, vertical) : 0,
    );
  }

  /// Get responsive EdgeInsets only
  static EdgeInsets paddingOnly(
    BuildContext context, {
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return EdgeInsets.only(
      left: left != null ? padding(context, left) : 0,
      top: top != null ? padding(context, top) : 0,
      right: right != null ? padding(context, right) : 0,
      bottom: bottom != null ? padding(context, bottom) : 0,
    );
  }

  /// Get responsive EdgeInsets margin with all sides equal
  static EdgeInsets marginAll(BuildContext context, double value) {
    return paddingAll(context, value);
  }

  /// Get responsive EdgeInsets margin symmetric
  static EdgeInsets marginSymmetric(
    BuildContext context, {
    double? horizontal,
    double? vertical,
  }) {
    return paddingSymmetric(context, horizontal: horizontal, vertical: vertical);
  }

  /// Get responsive EdgeInsets margin only
  static EdgeInsets marginOnly(
    BuildContext context, {
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return paddingOnly(
      context,
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    );
  }

  /// Get responsive BorderRadius
  static BorderRadius borderRadius(BuildContext context, double radius) {
    return BorderRadius.circular(ResponsiveSize.radius(context, radius));
  }
}
