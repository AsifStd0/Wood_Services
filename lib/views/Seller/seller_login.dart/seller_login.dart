import 'package:flutter/material.dart';
import 'package:wood_service/app/index.dart';
import 'package:wood_service/views/Seller/data/registration_data/register_viewmodel.dart';

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
      appBar: AppBar(
        title: Text('Login'),
        centerTitle: true,
        backgroundColor: AppColors.brightOrange,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
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
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Consumer<RegisterViewModel>(
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
                      const SizedBox(height: 14),

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

                      const SizedBox(height: 10),

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
                            style: TextStyle(color: AppColors.brightOrange),
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

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
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: viewModel.isLoginLoading
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
