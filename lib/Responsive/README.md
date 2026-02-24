# Responsive Design System

A comprehensive, easy-to-use responsive design system for Flutter projects. This system provides simple methods for handling responsive layouts, fonts, spacing, and more across different screen sizes.

## 📦 Installation

Add `flutter_screenutil` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_screenutil: ^5.9.0
```

Then run:
```bash
flutter pub get
```

## 🚀 Quick Start

### 1. Initialize in main.dart

```dart
import 'package:flutter/material.dart';
import 'package:wood_service/Responsive/screen_utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtils
    ScreenUtils.init(context);
    
    return MaterialApp(
      title: 'My App',
      home: HomeScreen(),
    );
  }
}
```

### 2. Use in Your Widgets

```dart
import 'package:wood_service/Responsive/responsive.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtils.w(100),      // Responsive width
      height: ScreenUtils.h(50),      // Responsive height
      padding: ScreenUtils.paddingAll(16),  // Responsive padding
      child: Text(
        'Hello',
        style: TextStyle(
          fontSize: ScreenUtils.sp(16),  // Responsive font size
        ),
      ),
    );
  }
}
```

## 📚 API Reference

### Width & Height

```dart
// Width
ScreenUtils.w(100)              // Responsive width
ScreenUtils.screenWidth        // Full screen width
ScreenUtils.widthPercent(50)   // 50% of screen width

// Height
ScreenUtils.h(100)             // Responsive height
ScreenUtils.screenHeight        // Full screen height
ScreenUtils.heightPercent(50)   // 50% of screen height
```

### Font Sizes

```dart
ScreenUtils.sp(16)                    // Responsive font size
ScreenUtils.spMin(16, min: 12)        // Minimum 12sp
ScreenUtils.spMax(16, max: 20)        // Maximum 20sp
```

### Radius & Borders

```dart
ScreenUtils.r(8)                      // Responsive radius
ScreenUtils.borderRadius(12)          // BorderRadius.circular(12)
ScreenUtils.borderRadiusTop(12)       // Top corners only
ScreenUtils.borderRadiusBottom(12)    // Bottom corners only
```

### Spacing & Padding

```dart
// Spacing
ScreenUtils.space(16)                 // General spacing
ScreenUtils.spaceH(16)               // Horizontal spacing
ScreenUtils.spaceV(16)               // Vertical spacing

// Padding
ScreenUtils.paddingAll(16)           // All sides
ScreenUtils.paddingSym(h: 16, v: 8)  // Symmetric
ScreenUtils.paddingOnly(left: 16, top: 8)  // Specific sides

// Margin (same as padding)
ScreenUtils.marginAll(16)
ScreenUtils.marginSym(h: 16, v: 8)
ScreenUtils.marginOnly(left: 16)
```

### Screen Information

```dart
ScreenUtils.isTablet                 // true if tablet
ScreenUtils.isPhone                  // true if phone
ScreenUtils.isSmallPhone             // true if small phone
ScreenUtils.isLargePhone             // true if large phone
ScreenUtils.pixelRatio               // Device pixel ratio
ScreenUtils.statusBarHeight          // Status bar height
ScreenUtils.bottomBarHeight          // Bottom bar height
```

### Orientation

```dart
ScreenUtils.isLandscape(context)     // Check landscape
ScreenUtils.isPortrait(context)      // Check portrait
```

### Safe Area

```dart
ScreenUtils.safeAreaPadding(context)    // All safe area padding
ScreenUtils.safeAreaTop(context)         // Top safe area
ScreenUtils.safeAreaBottom(context)      // Bottom safe area
ScreenUtils.safeAreaLeft(context)        // Left safe area
ScreenUtils.safeAreaRight(context)       // Right safe area
```

### Keyboard

```dart
ScreenUtils.isKeyboardVisible(context)   // Check if keyboard is visible
ScreenUtils.keyboardHeight(context)      // Get keyboard height
```

## 🎨 Extension Methods

### BuildContext Extension

```dart
// Using context extension
Container(
  width: context.w(100),
  height: context.h(50),
  padding: context.paddingAll(16),
  child: Text(
    'Hello',
    style: TextStyle(fontSize: context.sp(16)),
  ),
)
```

### Number Extensions

```dart
// Using number extensions
Container(
  width: 100.w,           // Same as ScreenUtils.w(100)
  height: 50.h,           // Same as ScreenUtils.h(50)
  padding: EdgeInsets.all(16.space),
  child: Text(
    'Hello',
    style: TextStyle(
      fontSize: 16.sp,    // Same as ScreenUtils.sp(16)
    ),
  ),
)
```

## 🧩 Responsive Widgets

### ResponsiveContainer

```dart
ResponsiveContainer(
  padding: EdgeInsets.all(16),  // Auto-adjusts based on screen size
  child: YourWidget(),
)
```

### ResponsivePadding

```dart
ResponsivePadding(
  all: 16,  // or use horizontal, vertical, etc.
  child: YourWidget(),
)
```

### ResponsiveSizedBox

```dart
ResponsiveSizedBox(
  width: 100,
  height: 50,
  child: YourWidget(),
)

// Square box
ResponsiveSizedBox.square(size: 50)
```

### ResponsiveText

```dart
ResponsiveText(
  'Hello World',
  fontSize: 16,
  fontWeight: FontWeight.bold,
  color: Colors.black,
)
```

### ResponsiveGridView

```dart
ResponsiveGridView(
  children: [
    // Your grid items
  ],
  crossAxisSpacing: 8,
  mainAxisSpacing: 8,
  childAspectRatio: 1.0,
)
```

### ResponsiveRow & ResponsiveColumn

```dart
ResponsiveRow(
  children: [Widget1(), Widget2()],
  spacing: 16,  // Auto spacing between children
  mainAxisAlignment: MainAxisAlignment.center,
)

ResponsiveColumn(
  children: [Widget1(), Widget2()],
  spacing: 16,  // Auto spacing between children
)
```

## 📐 Responsive Config

### Breakpoints

```dart
ResponsiveConfig.mobileBreakpoint      // 600
ResponsiveConfig.tabletBreakpoint     // 900
ResponsiveConfig.desktopBreakpoint    // 1200
```

### Screen Type

```dart
final screenType = ResponsiveConfig.getScreenType(screenWidth);
// Returns: ScreenType.mobile, tablet, desktop, or largeDesktop

// Get columns for grid
final columns = screenType.columns;  // 1, 2, 3, or 4

// Get padding
final padding = screenType.padding;  // 16, 24, 32, or 48
```

### Spacing Scale

```dart
ResponsiveConfig.spacing['xs']    // 4.0
ResponsiveConfig.spacing['sm']    // 8.0
ResponsiveConfig.spacing['md']    // 16.0
ResponsiveConfig.spacing['lg']    // 24.0
ResponsiveConfig.spacing['xl']    // 32.0
```

### Font Size Scale

```dart
ResponsiveConfig.fontSize['xs']   // 10.0
ResponsiveConfig.fontSize['sm']   // 12.0
ResponsiveConfig.fontSize['base'] // 14.0
ResponsiveConfig.fontSize['md']   // 16.0
ResponsiveConfig.fontSize['lg']   // 18.0
```

## 💡 Usage Examples

### Example 1: Simple Container

```dart
Container(
  width: ScreenUtils.w(300),
  height: ScreenUtils.h(200),
  padding: ScreenUtils.paddingAll(16),
  decoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: ScreenUtils.borderRadius(12),
  ),
  child: Text(
    'Responsive Container',
    style: TextStyle(fontSize: ScreenUtils.sp(16)),
  ),
)
```

### Example 2: Using Extensions

```dart
Container(
  width: 300.w,
  height: 200.h,
  padding: 16.space.paddingAll,
  decoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: 12.r.borderRadius,
  ),
  child: Text(
    'Responsive Container',
    style: TextStyle(fontSize: 16.sp),
  ),
)
```

### Example 3: Responsive Grid

```dart
ResponsiveGridView(
  children: products.map((product) => ProductCard(product)).toList(),
  crossAxisSpacing: 16,
  mainAxisSpacing: 16,
  childAspectRatio: 0.75,
)
```

### Example 4: Conditional Layout

```dart
Widget build(BuildContext context) {
  if (context.isTablet) {
    return TabletLayout();
  } else {
    return PhoneLayout();
  }
}
```

### Example 5: Safe Area Handling

```dart
Scaffold(
  body: Padding(
    padding: ScreenUtils.safeAreaPadding(context),
    child: YourContent(),
  ),
)
```

## 🎯 Best Practices

1. **Always initialize** `ScreenUtils.init(context)` in your main app widget
2. **Use consistent spacing** - Use the spacing scale from `ResponsiveConfig`
3. **Test on multiple devices** - Always test on different screen sizes
4. **Use responsive widgets** - Prefer `ResponsiveContainer`, `ResponsivePadding`, etc.
5. **Avoid hardcoded values** - Always use responsive methods instead of fixed pixels

## 📱 Design Size

The default design size is **375x812** (iPhone X). You can change this in `screen_utils.dart`:

```dart
ScreenUtil.init(
  context,
  designSize: const Size(375, 812),  // Change this
  minTextAdapt: true,
  splitScreenMode: true,
);
```

## 🔧 Customization

You can customize breakpoints, spacing, and font sizes in `responsive_config.dart`.

## 📝 Notes

- All methods automatically scale based on screen size
- Font sizes use `sp` (scale-independent pixels) for better accessibility
- The system works with both portrait and landscape orientations
- Safe area is automatically handled where needed

## 🤝 Support

For issues or questions, please refer to the main project documentation.
