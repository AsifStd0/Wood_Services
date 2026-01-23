# Login Implementation Summary

## ✅ Both Buyer and Seller Login Screens Now Use `handleLogin()`

Both login screens now follow the **same pattern** using `RegisterViewModel.handleLogin()` for consistent error handling, loading management, and navigation.

---

## 📱 Buyer Login Screen

### File: `lib/views/Buyer/login.dart/buyer_login_screen.dart`

#### ✅ Key Implementation:

```dart
class BuyerLoginScreen extends StatefulWidget {
  final String role; // Always 'buyer'
  const BuyerLoginScreen({super.key, required this.role});
}

class _BuyerLoginScreenState extends State<BuyerLoginScreen> {
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeViewModel(); // ✅ Sets role to 'buyer'
  }

  // ✅ Initialize ViewModel - Set role
  void _initializeViewModel() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final viewModel = context.read<RegisterViewModel>();
        // Set login role to buyer
        if (viewModel.loginRole != widget.role) {
          viewModel.loginRole = widget.role; // Sets to 'buyer'
        }
      }
    });
  }

  // ✅ Login Handler - Uses handleLogin()
  Future<void> _handleLogin(
    BuildContext context,
    RegisterViewModel viewModel,
  ) async {
    // 1. Validate form
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    // 2. Close keyboard
    FocusScope.of(context).unfocus();

    // 3. Set login role to buyer
    viewModel.loginRole = 'buyer';

    // 4. Call handleLogin which handles everything
    try {
      await viewModel.handleLogin(context);
      // ✅ handleLogin() manages:
      //    - Loading dialog
      //    - API call
      //    - Error dialogs/snackbars
      //    - Navigation to BuyerMainScreen
    } catch (e) {
      // Fallback error handling if handleLogin fails
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ✅ UI uses Consumer to display errors
  Widget _buildLoginCard() {
    return Consumer<RegisterViewModel>(
      builder: (context, viewModel, child) {
        // Set role if needed
        if (viewModel.loginRole != widget.role) {
          viewModel.loginRole = widget.role;
        }

        return Card(
          child: Column(
            children: [
              // Email & Password fields
              CustomTextFormField.email(
                controller: viewModel.loginEmailController,
              ),
              CustomTextFormField.password(
                controller: viewModel.loginPasswordController,
              ),
              
              // Login button
              CustomButtonUtils.login(
                onPressed: () => _handleLogin(context, viewModel),
              ),
              
              // ✅ Error message display
              if (viewModel.loginErrorMessage != null)
                Text(
                  viewModel.loginErrorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
            ],
          ),
        );
      },
    );
  }
}
```

---

## 🏪 Seller Login Screen

### File: `lib/views/Seller/seller_login.dart/seller_login.dart`

#### ✅ Key Implementation:

```dart
class SellerLogin extends StatefulWidget {
  final String role; // Always 'seller'
  SellerLogin({super.key, required this.role});
}

class _SellerLoginState extends State<SellerLogin> {
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeViewModel(); // ✅ Sets role to 'seller'
  }

  // ✅ Initialize ViewModel - Set role
  void _initializeViewModel() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<RegisterViewModel>();
      if (viewModel.loginRole != 'seller') {
        viewModel.loginRole = 'seller'; // Sets to 'seller'
      }
    });
  }

  // ✅ Login Handler - Uses handleLogin()
  Future<void> _submitLogin(
    BuildContext context,
    RegisterViewModel viewModel,
  ) async {
    // 1. Validate form
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    // 2. Set login role to seller
    viewModel.loginRole = 'seller';

    // 3. Call handleLogin which handles everything
    try {
      await viewModel.handleLogin(context);
      // ✅ handleLogin() manages:
      //    - Loading dialog
      //    - API call
      //    - Error dialogs/snackbars
      //    - Navigation to MainSellerScreen
    } catch (e) {
      // Fallback error handling if handleLogin fails
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ✅ UI uses Consumer to display errors
  Widget _buildCard(BuildContext context) {
    return Consumer<RegisterViewModel>(
      builder: (context, viewModel, child) {
        return Card(
          child: Column(
            children: [
              // Email & Password fields
              CustomTextFormField(
                controller: viewModel.loginEmailController,
              ),
              CustomTextFormField(
                controller: viewModel.loginPasswordController,
              ),
              
              // Login button
              ElevatedButton(
                onPressed: () => _submitLogin(context, viewModel),
              ),
              
              // ✅ Error message display
              if (viewModel.loginErrorMessage != null)
                Text(
                  viewModel.loginErrorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
            ],
          ),
        );
      },
    );
  }
}
```

---

## 🔄 RegisterViewModel.handleLogin() Method

### File: `lib/views/Seller/data/registration_data/register_viewmodel.dart`

```dart
// ✅ Handle login submission - Used by both Buyer and Seller
Future<void> handleLogin(BuildContext context) async {
  if (!context.mounted) return;

  // 1. Show loading dialog
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  try {
    // 2. Call login() - Uses _loginRole internally
    final result = await login();

    // Wait a bit to ensure state is updated
    await Future.delayed(const Duration(milliseconds: 100));

    if (!context.mounted) return;

    // 3. Close loading dialog
    Navigator.of(context).pop();

    if (result == null) {
      // 4. Login failed - Show error
      final errorMessage = _loginErrorMessage?.isNotEmpty == true
          ? _loginErrorMessage!
          : 'Unknown error occurred';

      if (!context.mounted) return;

      // Show SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );

      // Show error dialog
      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 24),
              SizedBox(width: 8),
              Text('Login Failed'),
            ],
          ),
          content: Text(errorMessage, style: const TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // 5. ✅ SUCCESS - Show success message
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Login Successful!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    await Future.delayed(const Duration(seconds: 1));

    if (!context.mounted) return;

    // 6. Navigate based on login role
    if (_loginRole == 'seller') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => MainSellerScreen()),
      );
    } else if (_loginRole == 'buyer') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => BuyerMainScreen()),
      );
    }
  } catch (error) {
    // Handle unexpected errors
    if (!context.mounted) return;

    try {
      Navigator.of(context).pop(); // Close loading
    } catch (e) {
      // Dialog might already be closed
    }

    String errorMessage = error.toString();
    if (errorMessage.startsWith('Exception: ')) {
      errorMessage = errorMessage.substring(11);
    }

    // Show error SnackBar and Dialog
    ScaffoldMessenger.of(context).showSnackBar(/* error snackbar */);
    await showDialog(/* error dialog */);
  }
}
```

---

## 📋 Comparison Table

| Feature | Buyer Login | Seller Login | Status |
|---------|------------|--------------|--------|
| **Role Setting** | ✅ In `initState` + button handler | ✅ In `initState` + button handler | ✅ Consistent |
| **Uses `handleLogin()`** | ✅ Yes | ✅ Yes | ✅ Consistent |
| **Error Display** | ✅ Consumer + handleLogin | ✅ Consumer + handleLogin | ✅ Consistent |
| **Loading Dialog** | ✅ Managed by handleLogin | ✅ Managed by handleLogin | ✅ Consistent |
| **Navigation** | ✅ Managed by handleLogin | ✅ Managed by handleLogin | ✅ Consistent |
| **Form Validation** | ✅ Before handleLogin | ✅ Before handleLogin | ✅ Consistent |
| **Fallback Error** | ✅ Try-catch around handleLogin | ✅ Try-catch around handleLogin | ✅ Consistent |

---

## ✅ Benefits of This Implementation

1. **Code Reuse**: Both screens use the same `handleLogin()` method
2. **Consistency**: Same error handling, loading, and navigation pattern
3. **Maintainability**: Changes to login flow only need to be made in one place
4. **Error Handling**: Unified error display (SnackBar + Dialog)
5. **User Experience**: Consistent behavior across buyer and seller logins
6. **Role Management**: Clear role setting in both screens

---

## 🔧 Provider Setup

### File: `lib/app/all_provider.dart`

```dart
List<SingleChildWidget> appProviders = [
  // Services
  Provider<UnifiedLocalStorageServiceImpl>(
    create: (context) => locator<UnifiedLocalStorageServiceImpl>(),
  ),
  Provider<AuthService>(
    create: (context) => locator<AuthService>(),
  ),

  // ✅ RegisterViewModel - Shared by Buyer and Seller
  ChangeNotifierProvider<RegisterViewModel>(
    create: (context) => locator<RegisterViewModel>(),
  ),
  
  // ... other providers
];
```

### File: `lib/app/locator.dart`

```dart
// ✅ RegisterViewModel registration
locator.registerFactory<RegisterViewModel>(
  () => RegisterViewModel(locator<AuthService>()),
);
```

---

## 📊 Data Flow

```
┌─────────────────────┐
│  BuyerLoginScreen   │
│  or                 │
│  SellerLoginScreen  │
└──────────┬──────────┘
           │
           │ 1. Sets viewModel.loginRole
           │
           │ 2. Calls viewModel.handleLogin(context)
           │
           ▼
┌──────────────────────────────────────┐
│   RegisterViewModel.handleLogin()    │
│                                      │
│   ├─ Show loading dialog             │
│   ├─ Call login()                    │
│   │   └─ API: POST /auth/login       │
│   │       { role: 'buyer'|'seller' } │
│   ├─ Close loading dialog            │
│   ├─ If error:                       │
│   │   ├─ Show SnackBar               │
│   │   └─ Show Dialog                 │
│   └─ If success:                     │
│       ├─ Show success SnackBar       │
│       └─ Navigate:                   │
│           ├─ BuyerMainScreen (buyer) │
│           └─ MainSellerScreen (seller)│
└──────────────────────────────────────┘
```

---

## ✅ Summary

Both **Buyer** and **Seller** login screens now:
- ✅ Use `handleLogin()` for consistent behavior
- ✅ Set role properly in `initState` and button handler
- ✅ Display errors via Consumer and handleLogin's dialogs/snackbars
- ✅ Have the same user experience
- ✅ Share the same RegisterViewModel instance
- ✅ Follow the same code pattern

**The implementation is now consistent and maintainable!** 🎉
