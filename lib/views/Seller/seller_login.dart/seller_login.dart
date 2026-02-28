import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/Responsive/responsive_context_extensions.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/core/theme/app_text_style.dart';
import 'package:wood_service/views/Buyer/forgot_password/forgot_password.dart';
import 'package:wood_service/views/Seller/data/registration_data/register_viewmodel.dart';
import 'package:wood_service/views/Seller/signup.dart/seller_signup.dart';
import 'package:wood_service/widgets/custom_textfield.dart';

class SellerLogin extends StatefulWidget {
  final String role;
  const SellerLogin({super.key, required this.role});

  @override
  State<SellerLogin> createState() => _SellerLoginState();
}

class _SellerLoginState extends State<SellerLogin>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeViewModel();
  }

  void _initializeViewModel() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<RegisterViewModel>();
      if (viewModel.loginRole != 'seller') {
        viewModel.loginRole = 'seller';
      }
    });
  }

  void _initializeAnimations() {
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

    _animController.forward();
  }

  Future<void> _submitLogin(
    BuildContext context,
    RegisterViewModel viewModel,
  ) async {
    // Validate form
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    // Set login role to seller
    viewModel.loginRole = 'seller';

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

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                            padding: EdgeInsets.symmetric(
                              vertical: context.h(14),
                            ),
                            child: AuthBottomTextData(
                              questionText: "Don't have an account? ",
                              actionText: "Sign Up",
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        SellerSignupScreen(role: widget.role),
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

  Widget _buildCard(BuildContext context) {
    return Consumer<RegisterViewModel>(
      builder: (context, viewModel, child) {
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
                          Icons.storefront_outlined,
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
                            'Welcome Seller',
                            type: CustomTextType.headingLittleLarge,
                          ),
                          SizedBox(height: context.h(2)),
                          Text(
                            'Login to continue your future journey',
                            style: TextStyle(
                              fontSize: context.sp(13),
                              color: Colors.grey[600],
                            ),
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
                      // Email
                      CustomTextFormField(
                        controller: viewModel.loginEmailController,
                        hintText: 'Email Address',
                        prefixIcon: Icon(Icons.email, color: AppColors.grey),
                        textInputType: TextInputType.emailAddress,
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

                      // Password
                      CustomTextFormField(
                        controller: viewModel.loginPasswordController,
                        hintText: 'Password',
                        prefixIcon: Icon(Icons.lock, color: AppColors.grey),
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
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.grey,
                          ),
                          onPressed: () {
                            viewModel.togglePasswordVisibility();
                          },
                        ),
                      ),

                      SizedBox(height: context.h(10)),

                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => BuyerForgotPassword(),
                              ),
                            );
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: AppColors.brightOrange,
                              fontSize: context.sp(14),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: context.h(6)),

                      // Login button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: viewModel.isLoginLoading
                              ? null
                              : () => _submitLogin(context, viewModel),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brightOrange,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: context.h(16),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: context.borderRadius(12),
                            ),
                          ),
                          child: viewModel.isLoginLoading
                              ? SizedBox(
                                  height: context.h(20),
                                  width: context.w(20),
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
                                    fontSize: context.sp(16),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
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
                              style: TextStyle(
                                color: AppColors.grey,
                                fontSize: context.sp(12),
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: AppColors.grey)),
                        ],
                      ),

                      SizedBox(height: context.h(16)),
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

// Helper widget for bottom text
class AuthBottomTextData extends StatelessWidget {
  final String questionText;
  final String actionText;
  final VoidCallback onPressed;

  const AuthBottomTextData({
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
        Text(questionText, style: TextStyle(fontSize: context.sp(14))),
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
