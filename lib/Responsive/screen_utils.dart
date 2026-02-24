import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Main Screen Utils class for responsive design
/// Provides easy access to width, height, font sizes, radius, and spacing
class ScreenUtils {
  // Private constructor to prevent instantiation
  ScreenUtils._();

  /// Initialize ScreenUtil with design size
  /// Use ScreenUtilInit widget in your MaterialApp instead
  /// Or call this in MaterialApp builder
  static void init(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812), // iPhone X design size (most common)
      minTextAdapt: true,
      splitScreenMode: true,
    );
  }

  /// Get ScreenUtilInit widget for MaterialApp
  /// Use this to wrap your MaterialApp
  static Widget initWidget({
    required Widget child,
    Size designSize = const Size(375, 812),
    bool minTextAdapt = true,
    bool splitScreenMode = true,
  }) {
    return ScreenUtilInit(
      designSize: designSize,
      minTextAdapt: minTextAdapt,
      splitScreenMode: splitScreenMode,
      builder: (context, child) => child!,
      child: child,
    );
  }

  // ========== WIDTH METHODS ==========

  /// Get responsive width (percentage of screen width)
  /// Example: ScreenUtils.w(50) = 50% of screen width
  static double w(double width) => ScreenUtil().setWidth(width);

  /// Get screen width
  static double get screenWidth => ScreenUtil().screenWidth;

  /// Get screen width percentage
  /// Example: ScreenUtils.widthPercent(50) = 50% of screen width
  static double widthPercent(double percent) => screenWidth * (percent / 100);

  // ========== HEIGHT METHODS ==========

  /// Get responsive height (percentage of screen height)
  /// Example: ScreenUtils.h(100) = responsive height of 100
  static double h(double height) => ScreenUtil().setHeight(height);

  /// Get screen height
  static double get screenHeight => ScreenUtil().screenHeight;

  /// Get screen height percentage
  /// Example: ScreenUtils.heightPercent(50) = 50% of screen height
  static double heightPercent(double percent) => screenHeight * (percent / 100);

  // ========== FONT SIZE METHODS ==========

  /// Get responsive font size (sp)
  /// Example: ScreenUtils.sp(16) = responsive font size of 16
  static double sp(double fontSize) => ScreenUtil().setSp(fontSize);

  /// Get responsive font size with minimum size
  /// Example: ScreenUtils.spMin(16, min: 12) = at least 12sp
  static double spMin(double fontSize, {double min = 10}) {
    final size = sp(fontSize);
    return size < min ? min : size;
  }

  /// Get responsive font size with maximum size
  /// Example: ScreenUtils.spMax(16, max: 20) = at most 20sp
  static double spMax(double fontSize, {double max = 30}) {
    final size = sp(fontSize);
    return size > max ? max : size;
  }

  // ========== RADIUS METHODS ==========

  /// Get responsive radius
  /// Example: ScreenUtils.r(8) = responsive radius of 8
  static double r(double radius) => ScreenUtil().radius(radius);

  /// Get responsive border radius
  /// Example: ScreenUtils.borderRadius(12) = BorderRadius.circular(12)
  static BorderRadius borderRadius(double radius) {
    return BorderRadius.circular(r(radius));
  }

  /// Get responsive border radius only top
  static BorderRadius borderRadiusTop(double radius) {
    return BorderRadius.only(
      topLeft: Radius.circular(r(radius)),
      topRight: Radius.circular(r(radius)),
    );
  }

  /// Get responsive border radius only bottom
  static BorderRadius borderRadiusBottom(double radius) {
    return BorderRadius.only(
      bottomLeft: Radius.circular(r(radius)),
      bottomRight: Radius.circular(r(radius)),
    );
  }

  // ========== SPACING METHODS ==========

  /// Get responsive spacing (padding/margin)
  /// Example: ScreenUtils.space(16) = responsive spacing of 16
  static double space(double spacing) => ScreenUtil().setWidth(spacing);

  /// Get responsive horizontal spacing
  static double spaceH(double spacing) => ScreenUtil().setWidth(spacing);

  /// Get responsive vertical spacing
  static double spaceV(double spacing) => ScreenUtil().setHeight(spacing);

  // ========== PADDING METHODS ==========

  /// Get responsive EdgeInsets all
  /// Example: ScreenUtils.paddingAll(16)
  static EdgeInsets paddingAll(double value) {
    return EdgeInsets.all(space(value));
  }

  /// Get responsive EdgeInsets symmetric
  /// Example: ScreenUtils.paddingSym(h: 16, v: 8)
  static EdgeInsets paddingSym({double? h, double? v}) {
    return EdgeInsets.symmetric(
      horizontal: h != null ? spaceH(h) : 0,
      vertical: v != null ? spaceV(v) : 0,
    );
  }

  /// Get responsive EdgeInsets only
  /// Example: ScreenUtils.paddingOnly(left: 16, top: 8)
  static EdgeInsets paddingOnly({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return EdgeInsets.only(
      left: left != null ? spaceH(left) : 0,
      top: top != null ? spaceV(top) : 0,
      right: right != null ? spaceH(right) : 0,
      bottom: bottom != null ? spaceV(bottom) : 0,
    );
  }

  // ========== MARGIN METHODS ==========

  /// Get responsive EdgeInsets margin all
  static EdgeInsets marginAll(double value) => paddingAll(value);

  /// Get responsive EdgeInsets margin symmetric
  static EdgeInsets marginSym({double? h, double? v}) => paddingSym(h: h, v: v);

  /// Get responsive EdgeInsets margin only
  static EdgeInsets marginOnly({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) => paddingOnly(left: left, top: top, right: right, bottom: bottom);

  // ========== SIZE METHODS ==========

  /// Get responsive Size
  /// Example: ScreenUtils.size(100, 50) = Size(100w, 50h)
  static Size size(double width, double height) {
    return Size(w(width), h(height));
  }

  /// Get responsive square size
  /// Example: ScreenUtils.square(50) = Size(50w, 50h)
  static Size square(double size) => ScreenUtils.size(size, size);

  // ========== SCREEN INFO METHODS ==========

  /// Check if screen is tablet
  static bool get isTablet => screenWidth >= 600;

  /// Check if screen is phone
  static bool get isPhone => !isTablet;

  /// Check if screen is small phone
  static bool get isSmallPhone => screenWidth < 360;

  /// Check if screen is large phone
  static bool get isLargePhone => screenWidth >= 414;

  /// Get device pixel ratio
  static double get pixelRatio => ScreenUtil().pixelRatio ?? 1.0;

  /// Get status bar height
  static double get statusBarHeight => ScreenUtil().statusBarHeight;

  /// Get bottom bar height
  static double get bottomBarHeight => ScreenUtil().bottomBarHeight;

  /// Get screen width in pixels
  static double get screenWidthPx => ScreenUtil().screenWidth * pixelRatio;

  /// Get screen height in pixels
  static double get screenHeightPx => ScreenUtil().screenHeight * pixelRatio;

  // ========== ORIENTATION METHODS ==========

  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Check if device is in portrait mode
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  // ========== SAFE AREA METHODS ==========

  /// Get safe area padding
  static EdgeInsets safeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get safe area top
  static double safeAreaTop(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  /// Get safe area bottom
  static double safeAreaBottom(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }

  /// Get safe area left
  static double safeAreaLeft(BuildContext context) {
    return MediaQuery.of(context).padding.left;
  }

  /// Get safe area right
  static double safeAreaRight(BuildContext context) {
    return MediaQuery.of(context).padding.right;
  }

  // ========== KEYBOARD METHODS ==========

  /// Check if keyboard is visible
  static bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }

  /// Get keyboard height
  static double keyboardHeight(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom;
  }
}
