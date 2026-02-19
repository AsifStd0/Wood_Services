# Project Refactoring Guide

This document outlines the comprehensive refactoring applied to the Wood Service project to improve code organization, maintainability, and scalability.

## 📋 Overview

The refactoring focused on:
1. Centralized Color System
2. Centralized API Endpoints
3. Strings Management
4. Network Layer Cleanup
5. Error Handling Standardization
6. Asset Management
7. Theme Optimization
8. Dependency Injection (Locator)

## 🎨 1. Centralized Color System

### Location: `lib/core/theme/app_colors.dart`

All colors are now centralized in the `AppColors` class. This ensures consistency across both Buyer and Seller modules.

### Usage:
```dart
import 'package:wood_service/core/theme/app_colors.dart';

Container(
  color: AppColors.primary,
  child: Text(
    'Hello',
    style: TextStyle(color: AppColors.textPrimary),
  ),
)
```

### Key Colors:
- **Primary Colors**: `primary`, `primaryDark`, `primaryLight`
- **Secondary Colors**: `secondary`, `secondaryDark`, `secondaryLight`
- **Status Colors**: `success`, `warning`, `error`, `info`
- **Text Colors**: `textPrimary`, `textSecondary`, `textLight`
- **Background Colors**: `background`, `scaffoldBackground`

## 🔗 2. Centralized API Endpoints

### Location: `lib/app/ap_endpoint.dart`

All API endpoints are now centralized in the `ApiEndpoints` class, organized by module (Seller, Buyer, Auth, etc.).

### Usage:
```dart
import 'package:wood_service/app/ap_endpoint.dart';
import 'package:wood_service/app/config.dart';

final url = '${Config.apiBaseUrl}${ApiEndpoints.sellerOrders}';
final orderUrl = '${Config.apiBaseUrl}${ApiEndpoints.sellerOrderById(orderId)}';
```

### Structure:
- **Auth Endpoints**: `authRegister`, `authLogin`, `authProfile`
- **Seller Endpoints**: `sellerOrders`, `sellerServices`, `sellerOrderAccept(id)`
- **Buyer Endpoints**: `buyerOrders`, `buyerServices`, `buyerOrderCancel(id)`
- **Chat Endpoints**: `chats`, `chatMessages(id)`
- **Review Endpoints**: `reviews`, `reviewProduct(id)`

## 📝 3. Strings Management

### Location: `lib/core/constants/app_strings.dart`

All hardcoded strings are now centralized in the `AppStrings` class.

### Usage:
```dart
import 'package:wood_service/core/constants/app_strings.dart';

Text(AppStrings.welcome)
Text(AppStrings.login)
SnackBar(content: Text(AppStrings.error))
```

### Categories:
- App Info
- Authentication
- Navigation
- Orders
- Products/Services
- Cart
- Seller
- Profile
- Messages
- Errors
- Success
- Validation
- Loading
- Empty States
- Actions
- Date/Time

## 🖼️ 4. Asset Management

### Location: `lib/core/constants/app_images.dart`

Image and icon paths are centralized in `AppImages` and `AppIcons` classes.

### Usage:
```dart
import 'package:wood_service/core/constants/app_images.dart';

Image.asset(AppImages.chair)
Image.asset(AppIcons.home)
```

## 🌐 5. Network Layer

### Location: `lib/core/network/dio_client.dart`

A centralized `DioClient` class handles all HTTP requests with:
- Automatic token injection
- Error handling
- Request/response interceptors
- File upload support

### Usage:
```dart
import 'package:wood_service/core/network/dio_client.dart';

final dioClient = DioClient(storage: storage);
final response = await dioClient.get('/buyer/services');
```

## ⚠️ 6. Error Handling

### Location: `lib/core/error/`

### Files:
- `app_exception.dart`: Base exception classes
- `error_handler.dart`: Centralized error handling logic

### Usage:
```dart
import 'package:wood_service/core/error/app_exception.dart';
import 'package:wood_service/core/error/error_handler.dart';

try {
  // API call
} catch (e) {
  final exception = ErrorHandler.handleError(e);
  final message = ErrorHandler.getUserFriendlyMessage(exception);
  // Show error to user
}
```

### Exception Types:
- `NetworkException`: No internet connection
- `ApiException`: API-related errors
- `BadRequestException`: 400 errors
- `UnauthorizedException`: 401 errors
- `NotFoundException`: 404 errors
- `ServerException`: 500+ errors
- `ValidationException`: Validation errors

## 🎭 7. Theme Configuration

### Location: `lib/core/theme/app_theme.dart`

Complete theme configuration with:
- Light and Dark themes
- Button themes (Elevated, Text, Outlined)
- Input decoration theme
- Card theme
- Dialog theme
- Snackbar theme
- And more...

### Usage:
```dart
import 'package:wood_service/core/theme/app_theme.dart';

MaterialApp(
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  // ...
)
```

## 🔧 8. Dependency Injection

### Location: `lib/app/locator.dart`

The locator is already well-structured using GetIt. All services and providers are registered here.

### Usage:
```dart
import 'package:wood_service/app/locator.dart';

final dio = locator<Dio>();
final storage = locator<UnifiedLocalStorageServiceImpl>();
```

## 📦 Import Structure

### Recommended Imports:

```dart
// App-level
import 'package:wood_service/app/index.dart';

// Core utilities
import 'package:wood_service/core/index.dart';

// Or specific imports
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/core/constants/app_strings.dart';
import 'package:wood_service/app/ap_endpoint.dart';
```

## 🔄 Migration Guide

### Before:
```dart
Container(
  color: Colors.blue,
  child: Text('Login'),
)
```

### After:
```dart
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/core/constants/app_strings.dart';

Container(
  color: AppColors.primary,
  child: Text(AppStrings.login),
)
```

### Before:
```dart
final url = '${Config.apiBaseUrl}/seller/orders';
```

### After:
```dart
import 'package:wood_service/app/ap_endpoint.dart';

final url = '${Config.apiBaseUrl}${ApiEndpoints.sellerOrders}';
```

## ✅ Benefits

1. **Consistency**: All modules use the same colors, strings, and endpoints
2. **Maintainability**: Changes in one place affect the entire app
3. **Scalability**: Easy to add new colors, strings, or endpoints
4. **Type Safety**: Compile-time checking for all constants
5. **Clean Code**: No hardcoded values scattered across the codebase
6. **Easy Testing**: Centralized constants are easier to mock and test

## 📚 Next Steps

1. Gradually migrate existing code to use the new centralized classes
2. Remove any remaining hardcoded values
3. Update tests to use the new constants
4. Document any custom colors or strings added

## 🐛 Troubleshooting

If you encounter import errors:
1. Ensure you're using the correct import paths
2. Check that the files exist in the specified locations
3. Run `flutter pub get` to ensure dependencies are up to date

## 📝 Notes

- The old `constants.dart` file still exists for backward compatibility but redirects to new locations
- The old `exceptions.dart` file exports the new `app_exception.dart` for backward compatibility
- All new code should use the new centralized classes
