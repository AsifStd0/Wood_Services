/// Responsive breakpoints configuration
class ResponsiveConfig {
  ResponsiveConfig._();

  // ========== BREAKPOINTS ==========

  /// Mobile breakpoint (phones)
  static const double mobileBreakpoint = 600;

  /// Tablet breakpoint
  static const double tabletBreakpoint = 900;

  /// Desktop breakpoint
  static const double desktopBreakpoint = 1200;

  // ========== DESIGN SIZES ==========

  /// Default design width (iPhone X)
  static const double designWidth = 375;

  /// Default design height (iPhone X)
  static const double designHeight = 812;

  // ========== SPACING SCALE ==========

  /// Base spacing unit
  static const double baseSpacing = 4.0;

  /// Spacing scale multipliers
  static const Map<String, double> spacing = {
    'xs': 4.0, // 0.25rem
    'sm': 8.0, // 0.5rem
    'md': 16.0, // 1rem
    'lg': 24.0, // 1.5rem
    'xl': 32.0, // 2rem
    '2xl': 48.0, // 3rem
    '3xl': 64.0, // 4rem
  };

  // ========== FONT SIZES ==========

  /// Font size scale
  static const Map<String, double> fontSize = {
    'xs': 10.0,
    'sm': 12.0,
    'base': 14.0,
    'md': 16.0,
    'lg': 18.0,
    'xl': 20.0,
    '2xl': 24.0,
    '3xl': 30.0,
    '4xl': 36.0,
    '5xl': 48.0,
  };

  // ========== BORDER RADIUS ==========

  /// Border radius scale
  static const Map<String, double> radius = {
    'none': 0.0,
    'sm': 4.0,
    'md': 8.0,
    'lg': 12.0,
    'xl': 16.0,
    '2xl': 20.0,
    'full': 9999.0,
  };

  // ========== SCREEN TYPE METHODS ==========

  /// Get screen type based on width
  static ScreenType getScreenType(double width) {
    if (width < mobileBreakpoint) {
      return ScreenType.mobile;
    } else if (width < tabletBreakpoint) {
      return ScreenType.tablet;
    } else if (width < desktopBreakpoint) {
      return ScreenType.desktop;
    } else {
      return ScreenType.largeDesktop;
    }
  }

  /// Check if mobile
  static bool isMobile(double width) => width < mobileBreakpoint;

  /// Check if tablet
  static bool isTablet(double width) =>
      width >= mobileBreakpoint && width < tabletBreakpoint;

  /// Check if desktop
  static bool isDesktop(double width) =>
      width >= tabletBreakpoint && width < desktopBreakpoint;

  /// Check if large desktop
  static bool isLargeDesktop(double width) => width >= desktopBreakpoint;
}

/// Screen type enum
enum ScreenType { mobile, tablet, desktop, largeDesktop }

/// Extension on ScreenType for easy access
extension ScreenTypeExtension on ScreenType {
  /// Get columns for grid layout
  int get columns {
    switch (this) {
      case ScreenType.mobile:
        return 1;
      case ScreenType.tablet:
        return 2;
      case ScreenType.desktop:
        return 3;
      case ScreenType.largeDesktop:
        return 4;
    }
  }

  /// Get padding value
  double get padding {
    switch (this) {
      case ScreenType.mobile:
        return 16.0;
      case ScreenType.tablet:
        return 24.0;
      case ScreenType.desktop:
        return 32.0;
      case ScreenType.largeDesktop:
        return 48.0;
    }
  }
}
