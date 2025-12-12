import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/app/locator.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/views/Seller/data/services/seller_auth.dart';
import 'package:wood_service/views/Seller/data/views/shop_setting/shop_widgets.dart';
import 'package:wood_service/views/Seller/seller_login.dart/login_view_model.dart';
import 'package:wood_service/widgets/auth_button_txt.dart';
import 'package:wood_service/widgets/custom_textfield.dart';
import 'package:wood_service/widgets/custom_button.dart';
import 'package:wood_service/widgets/custom_text.dart';

class SellerLogin extends StatefulWidget {
  const SellerLogin({super.key});

  @override
  State<SellerLogin> createState() => _SellerLoginState();
}

class _SellerLoginState extends State<SellerLogin>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.02),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    // Start entrance animation
    _animController.forward();

    // Check if already logged in
    _checkExistingLogin();
  }

  Future<void> _checkExistingLogin() async {
    final viewModel = context.read<SellerLoginViewModel>();
    final isLoggedIn = await viewModel.checkExistingLogin();
    if (isLoggedIn && mounted) {
      // Already logged in, navigate to home
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // context.go('/main_seller_screen');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) {
              return MainSellerScreen();
            },
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<SellerLoginViewModel>();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Clear previous errors
    viewModel.clearMessages();

    final result = await viewModel.login(email: email, password: password);

    result.fold(
      // Failure
      (failure) {
        // Error is already shown by ViewModel
        log('❌ Login failed: ${failure.message}');
      },
      // Success
      (authResponse) async {
        log(
          '✅ Login successful for: ${authResponse.seller.personalInfo.fullName}',
        );

        // Show success message
        viewModel.setSuccess('Login successful!');

        // Wait a moment for user to see success message
        await Future.delayed(const Duration(milliseconds: 500));

        // Navigate to main seller screen
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) {
                return MainSellerScreen();
              },
            ),
          );
          // context.go('/main_seller_screen');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          SellerLoginViewModel(sellerAuthService: locator<SellerAuthService>()),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.brightOrange.withOpacity(0.06), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 28.0,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Stack(
                    children: [
                      // Main content
                      SlideTransition(
                        position: _slideAnim,
                        child: FadeTransition(
                          opacity: _fadeAnim,
                          child: _buildCard(context),
                        ),
                      ),

                      // Bottom signup text
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          child: AuthBottomText(
                            questionText: "Don't have an account? ",
                            actionText: "Sign Up",
                            onPressed: () {
                              // context.go('/seller_signup');
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) {
                                    return SellerSignupScreen();
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Consumer<SellerLoginViewModel>(
      builder: (context, viewModel, child) {
        return Card(
          elevation: 18,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: Colors.black.withOpacity(0.06),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 56),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 54,
                      width: 54,
                      decoration: BoxDecoration(
                        color: AppColors.brightOrange,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.brightOrange.withOpacity(0.18),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.storefront_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            'Welcome Seller',
                            type: CustomTextType.headingLittleLarge,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Login to continue your future journey',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // Show error/success messages
                if (viewModel.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              viewModel.errorMessage!,
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (viewModel.successMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              viewModel.successMessage!,
                              style: TextStyle(color: Colors.green),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email
                      CustomTextFormField(
                        controller: _emailController,
                        hintText: 'Email Address',
                        prefixIcon: Icon(Icons.email, color: AppColors.grey),
                        textInputType: TextInputType.emailAddress,
                        validator: (value) => viewModel.validateEmail(value),
                        onChanged: (value) => viewModel.clearMessages(),
                        focusNode: _emailFocusNode,
                      ),
                      const SizedBox(height: 14),

                      // Password
                      CustomTextFormField(
                        controller: _passwordController,
                        hintText: 'Password',
                        prefixIcon: Icon(Icons.lock, color: AppColors.grey),
                        obscureText: viewModel.obscurePassword,
                        validator: (value) => viewModel.validatePassword(value),
                        onChanged: (value) => viewModel.clearMessages(),
                        focusNode: _passwordFocusNode,
                        suffixIcon: IconButton(
                          icon: Icon(
                            viewModel.obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.grey,
                          ),
                          onPressed: () {
                            viewModel.setObscurePassword(
                              !viewModel.obscurePassword,
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // context.go('/buyer_forgot');
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) {
                                  return BuyerForgotPassword();
                                },
                              ),
                            );
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(color: AppColors.brightOrange),
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Login button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: viewModel.isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brightOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: viewModel.isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Divider with text
                      Row(
                        children: [
                          Expanded(child: Divider(color: AppColors.grey)),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                            ),
                            child: Text(
                              'Or continue with',
                              style: TextStyle(
                                color: AppColors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: AppColors.grey)),
                        ],
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}



                  // // Social buttons
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: OutlinedButton.icon(
                  //         onPressed: () {
                  //           // TODO: wire Google sign-in
                  //         },
                  //         icon: const Icon(Icons.apple, size: 20),
                  //         label: Text(
                  //           'Google',
                       
                  //         ),
                  //         style: OutlinedButton.styleFrom(
                  //           padding: const EdgeInsets.symmetric(vertical: 12),
                  //           shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(10),
                  //           ),
                  //           side: BorderSide(color: Colors.grey.shade300),
                  //           backgroundColor: Colors.white,
                  //         ),
                  //       ),
                  //     ),
                  //     const SizedBox(width: 12),
                  //     Expanded(
                  //       child: OutlinedButton.icon(
                  //         onPressed: () {
                  //           // TODO: wire Apple sign-in
                  //         },
                  //         icon: const Icon(Icons.apple, size: 20),
                  //         label: Text(
                  //           'Apple',
                  //           //   style: AppCustomTextStyle.bodyText(context)
                  //           //       .copyWith(color: Colors.black87),
                  //         ),
                  //         style: OutlinedButton.styleFrom(
                  //           padding: const EdgeInsets.symmetric(vertical: 12),
                  //           shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(10),
                  //           ),
                  //           side: BorderSide(color: Colors.grey.shade300),
                  //           backgroundColor: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
               
               