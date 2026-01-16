import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/core/theme/app_text_style.dart';
import 'package:wood_service/views/Buyer/buyer_main/buyer_main.dart';
import 'package:wood_service/views/Buyer/buyer_signup.dart/buyer_signup.dart';
import 'package:wood_service/views/Buyer/forgot_password/forgot_password.dart';
import 'package:wood_service/views/Seller/data/registration_data/register_viewmodel.dart';
import 'package:wood_service/views/Seller/main_seller_screen.dart';
import 'package:wood_service/widgets/custom_button.dart';
import 'package:wood_service/widgets/custom_text_style.dart';
import 'package:wood_service/widgets/custom_textfield.dart';

class BuyerLoginScreen extends StatefulWidget {
  final String role;

  const BuyerLoginScreen({super.key, required this.role});

  @override
  State<BuyerLoginScreen> createState() => _BuyerLoginScreenState();
}

class _BuyerLoginScreenState extends State<BuyerLoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  AnimationController? _animController;
  Animation<double>? _fadeAnim;
  Animation<Offset>? _slideAnim;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController!,
      curve: Curves.easeInOut,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.02),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController!, curve: Curves.easeOut));

    // Use WidgetsBinding to ensure safe animation start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animController!.forward();
      }
    });
  }

  @override
  void dispose() {
    _animController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slideAnim;
    final fade = _fadeAnim;

    return Scaffold(
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
                child: _buildAnimatedContent(slide, fade),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedContent(
    Animation<Offset>? slide,
    Animation<double>? fade,
  ) {
    Widget content = Stack(
      children: [
        // Main content
        _buildLoginCard(),

        // Bottom signup text positioned at bottom
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
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BuyerSignupScreen(role: 'buyer'),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );

    if (slide != null && fade != null) {
      content = SlideTransition(
        position: slide,
        child: FadeTransition(opacity: fade, child: content),
      );
    }

    return content;
  }

  Widget _buildLoginCard() {
    return Consumer<RegisterViewModel>(
      builder: (context, viewModel, child) {
        // Set the login role
        if (viewModel.loginRole != widget.role) {
          viewModel.loginRole = widget.role;
        }

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
                      child: Center(
                        child: Icon(
                          Icons.shopping_cart_outlined,
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
                            'Welcome Buyer',
                            type: CustomTextType.headingLittleLarge,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Login to continue your shopping journey',
                            style: AppCustomTextStyle.appSubtitle(
                              context,
                            ).copyWith(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email Field
                      CustomTextFormField.email(
                        controller: viewModel.loginEmailController,
                        hintText: 'Email Address',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Password Field
                      CustomTextFormField.password(
                        controller: viewModel.loginPasswordController,
                        hintText: 'Password',
                        obscureText: viewModel.obscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                        suffixIcon: IconButton(
                          icon: Icon(
                            viewModel.obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.grey,
                          ),
                          onPressed: viewModel.togglePasswordVisibility,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: CustomButtonUtils.textButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const BuyerForgotPassword(),
                              ),
                            );
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: AppColors.brightOrange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: CustomButtonUtils.login(
                          backgroundColor: AppColors.brightOrange,
                          title: viewModel.isLoginLoading
                              ? 'Logging in...'
                              : 'Login',
                          onPressed: viewModel.isLoginLoading
                              ? null
                              : () => _handleLogin(context, viewModel),
                        ),
                      ),

                      // Error Message
                      if (viewModel.loginErrorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            viewModel.loginErrorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
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
                              style: AppCustomTextStyle.inputHint(
                                context,
                              ).copyWith(color: AppColors.grey),
                            ),
                          ),
                          Expanded(child: Divider(color: AppColors.grey)),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Social buttons
                      Row(
                        children: [
                          Expanded(
                            child: CustomButtonUtils.googleSignIn(
                              onPressed: () {
                                // TODO: Add Google sign-in logic
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomButtonUtils.appleSignIn(
                              onPressed: () {
                                // TODO: Add Apple sign-in logic
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleLogin(
    BuildContext context,
    RegisterViewModel viewModel,
  ) async {
    // Validate form
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    // Close keyboard
    FocusScope.of(context).unfocus();

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Call login
      final result = await viewModel.login();

      // Close loading
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (result == null) {
        // Login failed - error is already shown in viewModel
        return;
      }

      // Login successful
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login Successful!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(seconds: 1));

        // Navigate based on role
        if (widget.role == 'seller') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => MainSellerScreen()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const BuyerMainScreen()),
          );
        }
      }
    } catch (error) {
      // Close loading
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login error: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Helper widget for bottom text
class AuthBottomText extends StatelessWidget {
  final String questionText;
  final String actionText;
  final VoidCallback onPressed;

  const AuthBottomText({
    super.key,
    required this.questionText,
    required this.actionText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(questionText, style: AppCustomTextStyle.inputHint(context)),
        GestureDetector(
          onTap: onPressed,
          child: Text(
            actionText,
            style: TextStyle(
              color: AppColors.brightOrange,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
