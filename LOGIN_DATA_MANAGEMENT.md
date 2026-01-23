# Login Data Management Architecture

## Overview
Both **Buyer** and **Seller** login screens share a single `RegisterViewModel` that handles authentication, role management, and data flow. This document explains how the architecture works.

---

## 📊 Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    App Root (main.dart)                      │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         MultiProvider (appProviders)                  │   │
│  │  ┌──────────────────────────────────────────────┐    │   │
│  │  │  ChangeNotifierProvider<RegisterViewModel>   │    │   │
│  │  │  ┌──────────────────────────────────────┐    │    │   │
│  │  │  │  RegisterViewModel (Shared Instance) │    │    │   │
│  │  │  │  • loginRole: 'buyer' | 'seller'     │    │    │   │
│  │  │  │  • loginEmailController              │    │    │   │
│  │  │  │  • loginPasswordController           │    │    │   │
│  │  │  │  • _loginErrorMessage                │    │    │   │
│  │  │  │  • login()                           │    │    │   │
│  │  │  │  • handleLogin(context)              │    │    │   │
│  │  │  └──────────────────────────────────────┘    │    │   │
│  │  └──────────────────────────────────────────────┘    │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ (Consumer/Provider.of)
                            │
            ┌───────────────┴───────────────┐
            │                               │
    ┌───────▼────────┐           ┌─────────▼─────────┐
    │ BuyerLoginScreen│           │  SellerLoginScreen │
    │ role: 'buyer'   │           │  role: 'seller'   │
    └─────────────────┘           └───────────────────┘
            │                               │
            │ Sets:                         │ Sets:
            │ viewModel.loginRole = 'buyer' │ viewModel.loginRole = 'seller'
            │                               │
            └───────────────┬───────────────┘
                            │
                    ┌───────▼────────┐
                    │ RegisterViewModel│
                    │   handleLogin()  │
                    └─────────────────┘
                            │
                            │ Based on _loginRole:
                            │ • Calls API with role
                            │ • Navigates to:
                            │   - MainSellerScreen (if seller)
                            │   - BuyerMainScreen (if buyer)
                            │
```

---

## 🔧 Provider Setup

### 1. Provider Registration (`lib/app/all_provider.dart`)

```dart
List<SingleChildWidget> appProviders = [
  // RegisterViewModel is provided globally
  ChangeNotifierProvider<RegisterViewModel>(
    create: (context) => locator<RegisterViewModel>(),
  ),
  // ... other providers
];
```

### 2. Locator Registration (`lib/app/locator.dart`)

```dart
// RegisterViewModel is registered as a factory
locator.registerFactory<RegisterViewModel>(
  () => RegisterViewModel(locator<AuthService>()),
);
```

**Note:** Using `registerFactory` means a new instance is created each time, but in practice, Provider maintains a single instance per context tree.

---

## 🎯 RegisterViewModel Structure

### Shared State Properties

```dart
class RegisterViewModel extends ChangeNotifier {
  // ✅ Shared between Buyer & Seller
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();
  
  // ✅ Role management
  String _loginRole = 'buyer'; // Default: 'buyer'
  
  String get loginRole => _loginRole;
  set loginRole(String value) {
    _loginRole = value;
    notifyListeners(); // Updates UI when role changes
  }
  
  // ✅ Error handling
  String? _loginErrorMessage;
  String? get loginErrorMessage => _loginErrorMessage;
  
  // ✅ Loading state
  bool _isLoginLoading = false;
  bool get isLoginLoading => _isLoginLoading;
}
```

---

## 📱 Buyer Login Screen Implementation

### File: `lib/views/Buyer/login.dart/buyer_login_screen.dart`

```dart
class BuyerLoginScreen extends StatefulWidget {
  final String role; // ✅ Always 'buyer'
  const BuyerLoginScreen({super.key, required this.role});
}

class _BuyerLoginScreenState extends State<BuyerLoginScreen> {
  Widget _buildLoginCard(BuildContext context) {
    return Consumer<RegisterViewModel>(
      builder: (context, viewModel, child) {
        // ✅ Set role in ViewModel
        if (viewModel.loginRole != widget.role) {
          viewModel.loginRole = widget.role; // Sets to 'buyer'
        }
        
        return Card(
          child: Column(
            children: [
              // Email & Password fields use viewModel controllers
              CustomTextFormField.email(
                controller: viewModel.loginEmailController,
              ),
              CustomTextFormField.password(
                controller: viewModel.loginPasswordController,
              ),
              
              // Login button
              ElevatedButton(
                onPressed: () => _handleLogin(context, viewModel),
              ),
              
              // ✅ Error message display
              if (viewModel.loginErrorMessage != null)
                Text(viewModel.loginErrorMessage!),
            ],
          ),
        );
      },
    );
  }
  
  Future<void> _handleLogin(
    BuildContext context,
    RegisterViewModel viewModel,
  ) async {
    // ✅ Validate form
    if (_formKey.currentState?.validate() != true) return;
    
    // ✅ Show loading
    showDialog(/* loading dialog */);
    
    try {
      // ✅ Call login() - uses viewModel.loginRole
      final result = await viewModel.login();
      
      if (result == null) {
        // Error - already set in viewModel.loginErrorMessage
        return;
      }
      
      // ✅ Success - Navigate based on widget.role
      if (widget.role == 'seller') {
        Navigator.pushReplacement(/* MainSellerScreen */);
      } else {
        Navigator.pushReplacement(/* BuyerMainScreen */);
      }
    } catch (error) {
      // Handle error
    }
  }
}
```

**Key Points:**
- ✅ Uses `Consumer<RegisterViewModel>` to access shared ViewModel
- ✅ Sets `viewModel.loginRole = 'buyer'` when screen loads
- ✅ Calls `viewModel.login()` which uses the role internally
- ✅ Error messages are displayed from `viewModel.loginErrorMessage`

---

## 🏪 Seller Login Screen Implementation

### File: `lib/views/Seller/seller_login.dart/seller_login.dart`

```dart
class SellerLogin extends StatefulWidget {
  final String role; // ✅ Always 'seller'
  SellerLogin({super.key, required this.role});
}

class _SellerLoginState extends State<SellerLogin> {
  @override
  void initState() {
    super.initState();
    _initializeViewModel();
  }
  
  void _initializeViewModel() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<RegisterViewModel>();
      // ✅ Set role to 'seller'
      if (viewModel.loginRole != 'seller') {
        viewModel.loginRole = 'seller';
      }
    });
  }
  
  Future<void> _submitLogin(
    BuildContext context,
    RegisterViewModel viewModel,
  ) async {
    // ✅ Validate form
    if (_formKey.currentState?.validate() != true) return;
    
    // ✅ Explicitly set role
    viewModel.loginRole = 'seller';
    
    // ✅ Call handleLogin which manages everything
    await viewModel.handleLogin(context);
  }
  
  Widget _buildCard(BuildContext context) {
    return Consumer<RegisterViewModel>(
      builder: (context, viewModel, child) {
        return Card(
          child: Column(
            children: [
              // ✅ Uses shared controllers
              CustomTextFormField(
                controller: viewModel.loginEmailController,
              ),
              CustomTextFormField(
                controller: viewModel.loginPasswordController,
              ),
              
              // ✅ Error message display
              if (viewModel.loginErrorMessage != null)
                Text(viewModel.loginErrorMessage!),
            ],
          ),
        );
      },
    );
  }
}
```

**Key Points:**
- ✅ Sets `viewModel.loginRole = 'seller'` in `initState`
- ✅ Calls `viewModel.handleLogin(context)` which handles:
  - Loading dialog
  - Error dialogs/snackbars
  - Navigation to `MainSellerScreen`

---

## 🔄 Login Flow in RegisterViewModel

### Method: `login()`

```dart
Future<Map<String, dynamic>?> login() async {
  // ✅ 1. Validate form
  if (!validateLoginForm()) {
    _loginErrorMessage = 'Validation failed';
    return null;
  }
  
  _isLoginLoading = true;
  notifyListeners();
  
  try {
    // ✅ 2. Call API with role
    final response = await _authService.login(
      email: loginEmailController.text.trim(),
      password: loginPasswordController.text,
      role: _loginRole, // ✅ Uses current role ('buyer' or 'seller')
    );
    
    // ✅ 3. Save user data to storage
    await _saveUserData(response);
    
    _isLoginLoading = false;
    notifyListeners();
    return response;
    
  } catch (e) {
    // ✅ 4. Handle errors
    _loginErrorMessage = e.toString();
    _isLoginLoading = false;
    notifyListeners();
    return null;
  }
}
```

### Method: `handleLogin(context)`

```dart
Future<void> handleLogin(BuildContext context) async {
  // ✅ 1. Show loading
  showDialog(/* loading */);
  
  try {
    // ✅ 2. Call login()
    final result = await login();
    
    // Close loading
    Navigator.of(context).pop();
    
    if (result == null) {
      // ✅ 3. Show error dialog & snackbar
      ScaffoldMessenger.of(context).showSnackBar(/* error */);
      showDialog(/* error dialog */);
      return;
    }
    
    // ✅ 4. Success - Navigate based on role
    if (_loginRole == 'seller') {
      Navigator.pushReplacement(/* MainSellerScreen */);
    } else if (_loginRole == 'buyer') {
      Navigator.pushReplacement(/* BuyerMainScreen */);
    }
    
  } catch (error) {
    // Handle unexpected errors
  }
}
```

---

## 🔀 Data Flow Comparison

### Buyer Login Flow
```
BuyerLoginScreen
    │
    ├─ Sets: viewModel.loginRole = 'buyer'
    │
    ├─ Calls: viewModel.login()
    │   │
    │   ├─ API: POST /auth/login { role: 'buyer', ... }
    │   │
    │   ├─ Success: Save to storage
    │   │
    │   └─ Returns: response or null
    │
    ├─ If success: Navigate to BuyerMainScreen
    │
    └─ If error: Display from viewModel.loginErrorMessage
```

### Seller Login Flow
```
SellerLoginScreen
    │
    ├─ Sets: viewModel.loginRole = 'seller' (in initState)
    │
    ├─ Calls: viewModel.handleLogin(context)
    │   │
    │   ├─ Shows: Loading dialog
    │   │
    │   ├─ Calls: viewModel.login()
    │   │   │
    │   │   ├─ API: POST /auth/login { role: 'seller', ... }
    │   │   │
    │   │   ├─ Success: Save to storage
    │   │   │
    │   │   └─ Returns: response or null
    │   │
    │   ├─ Closes: Loading dialog
    │   │
    │   ├─ If error: Shows SnackBar + Dialog
    │   │
    │   └─ If success: Navigate to MainSellerScreen
    │
    └─ Error displayed in UI via Consumer
```

---

## ⚠️ Key Differences

| Aspect | Buyer Login | Seller Login |
|--------|------------|--------------|
| **Error Display** | Manual handling in `_handleLogin` | Automatic via `handleLogin` |
| **Loading Dialog** | Manual in `_handleLogin` | Automatic in `handleLogin` |
| **Navigation** | Manual in `_handleLogin` | Automatic in `handleLogin` |
| **Role Setting** | In `Consumer` builder | In `initState` + button handler |
| **Error Messages** | From `viewModel.loginErrorMessage` | From `viewModel.loginErrorMessage` |

---

## ✅ Best Practices Used

1. **Single Source of Truth**: `RegisterViewModel` manages all login state
2. **Role-Based Logic**: `_loginRole` determines behavior
3. **Reactive UI**: Uses `Consumer` and `notifyListeners()` for updates
4. **Error Handling**: Centralized error messages in ViewModel
5. **Shared Controllers**: Both screens use the same text controllers

---

## 🚨 Potential Issues & Solutions

### Issue 1: Role Not Set Correctly
**Problem:** If role isn't set, default 'buyer' is used.

**Solution:** Both screens explicitly set role:
- Buyer: `viewModel.loginRole = widget.role` in Consumer
- Seller: `viewModel.loginRole = 'seller'` in initState

### Issue 2: Shared State Between Screens
**Problem:** If both screens exist in navigation stack, they share state.

**Solution:** Clear form after successful login:
```dart
loginEmailController.clear();
loginPasswordController.clear();
_loginErrorMessage = null;
```

### Issue 3: Error Not Showing
**Problem:** Error set but UI not updating.

**Solution:** Use `Consumer` to listen to changes:
```dart
Consumer<RegisterViewModel>(
  builder: (context, viewModel, child) {
    if (viewModel.loginErrorMessage != null) {
      return Text(viewModel.loginErrorMessage!);
    }
  },
)
```

---

## 📝 Summary

- ✅ **One ViewModel**: `RegisterViewModel` handles both buyer and seller
- ✅ **Role-Based**: `_loginRole` property determines behavior
- ✅ **Shared State**: Controllers and error messages are shared
- ✅ **Reactive UI**: `Consumer` listens to ViewModel changes
- ✅ **Automatic Navigation**: `handleLogin()` manages flow for seller
- ✅ **Manual Navigation**: Buyer screen handles navigation manually

The architecture allows code reuse while maintaining clear separation between buyer and seller login flows.
