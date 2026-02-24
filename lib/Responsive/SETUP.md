# Setup Guide

## Step 1: Install Dependencies

Run this command in your terminal:
```bash
flutter pub get
```

## Step 2: Update main.dart

Update your `main.dart` file to initialize ScreenUtils. You have two options:

### Option 1: Using ScreenUtilInit (Recommended)

```dart
import 'package:flutter/material.dart';
import 'package:wood_service/Responsive/screen_utils.dart';
import 'package:wood_service/app/all_provider.dart';
import 'package:wood_service/app/helper.dart';
import 'package:wood_service/app/locator.dart';
// ... other imports

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await setupLocator();
    await checkAuthStatus();
    runApp(const AppWithProviders());
  } catch (e) {
    print('❌ App start error: $e');
  }
}

class AppWithProviders extends StatelessWidget {
  const AppWithProviders({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: appProviders,
      child: ScreenUtils.initWidget(
        child: const MyApp(),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _getInitialScreen(),
    );
  }
  
  // ... rest of your code
}
```

### Option 2: Using MaterialApp builder

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        ScreenUtils.init(context);
        return child ?? const SizedBox();
      },
      home: _getInitialScreen(),
    );
  }
}
```

## Step 3: Use in Your Widgets

Now you can use responsive utilities anywhere in your app:

```dart
import 'package:wood_service/Responsive/responsive.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtils.w(100),
      height: ScreenUtils.h(50),
      padding: ScreenUtils.paddingAll(16),
      child: Text(
        'Hello',
        style: TextStyle(fontSize: ScreenUtils.sp(16)),
      ),
    );
  }
}
```

## Quick Reference

- `ScreenUtils.w(100)` - Responsive width
- `ScreenUtils.h(50)` - Responsive height
- `ScreenUtils.sp(16)` - Responsive font size
- `ScreenUtils.r(8)` - Responsive radius
- `ScreenUtils.paddingAll(16)` - Responsive padding
- `context.w(100)` - Using context extension
- `100.w` - Using number extension

See README.md for complete documentation.
