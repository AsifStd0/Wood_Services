import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/Responsive/responsive_context_extensions.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/core/theme/app_text_style.dart';
import 'package:wood_service/views/Buyer/buyer_signup.dart/buyer_signup.dart';
import 'package:wood_service/views/Buyer/forgot_password/forgot_password.dart';
import 'package:wood_service/views/Seller/data/registration_data/register_viewmodel.dart';
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
    _initializeAnimations();
    _initializeViewModel();
  }

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

  void _initializeAnimations() {
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
          child: Stack(
            children: [
              // Main content
              Center(
                child: SingleChildScrollView(
                  padding: context.paddingSym(
                    horizontal: context.responsiveValue(
                      mobile: 20,
                      tablet: 40,
                      desktop: 60,
                    ),
                    vertical: context.h(28),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: context.responsiveValue(
                        mobile: double.infinity,
                        tablet: 520,
                        desktop: 600,
                      ),
                    ),
                    child: _buildAnimatedContent(slide, fade),
                  ),
                ),
              ),

              // Custom back button in top-left corner
              Positioned(
                top: context.h(16),
                left: context.w(16),
                child: _buildBackButton(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(),
        borderRadius: BorderRadius.circular(context.r(12)),
        child: Container(
          padding: context.paddingAll(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(context.r(12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, context.h(2)),
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back_ios_new,
            size: context.sp(20),
            color: AppColors.brightOrange,
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
            padding: EdgeInsets.symmetric(vertical: context.h(14)),
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
        // Note: loginRole is set in _initializeViewModel() to avoid setState during build
        return Card(
          elevation: 18,
          shape: RoundedRectangleBorder(borderRadius: context.borderRadius(16)),
          shadowColor: Colors.black.withOpacity(0.06),
          child: Padding(
            padding: context.paddingSym(
              horizontal: context.w(22),
              vertical: context.h(56),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: context.h(54),
                      width: context.w(54),
                      decoration: BoxDecoration(
                        color: AppColors.brightOrange,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.brightOrange.withOpacity(0.18),
                            blurRadius: 10,
                            offset: Offset(0, context.h(6)),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.shopping_cart_outlined,
                          color: Colors.white,
                          size: context.sp(28),
                        ),
                      ),
                    ),
                    SizedBox(width: context.w(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            'Welcome Buyer',
                            type: CustomTextType.headingLittleLarge,
                          ),
                          SizedBox(height: context.h(2)),
                          Text(
                            'Login to continue your shopping journey',
                            style: AppCustomTextStyle.appSubtitle(
                              context,
                            ).copyWith(fontSize: context.sp(13)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: context.h(22)),

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
                      SizedBox(height: context.h(14)),

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

                      SizedBox(height: context.h(10)),

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
                              fontSize: context.sp(14),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: context.h(6)),

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
                          padding: EdgeInsets.only(top: context.h(12)),
                          child: Text(
                            viewModel.loginErrorMessage!,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: context.sp(14),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      SizedBox(height: context.h(18)),

                      // Divider with text
                      Row(
                        children: [
                          Expanded(child: Divider(color: AppColors.grey)),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.w(12),
                            ),
                            child: Text(
                              'Or continue with',
                              style: AppCustomTextStyle.inputHint(context)
                                  .copyWith(
                                    color: AppColors.grey,
                                    fontSize: context.sp(12),
                                  ),
                            ),
                          ),
                          Expanded(child: Divider(color: AppColors.grey)),
                        ],
                      ),

                      SizedBox(height: context.h(16)),

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
                          SizedBox(width: context.w(12)),
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

                SizedBox(height: context.h(12)),
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

    // Set login role to buyer
    viewModel.loginRole = 'buyer';

    // Call handleLogin which handles everything (loading, errors, navigation)
    try {
      await viewModel.handleLogin(context);
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
              fontSize: context.sp(14),
            ),
          ),
        ),
      ],
    );
  }
}
