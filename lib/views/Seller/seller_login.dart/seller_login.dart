import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/core/theme/app_test_style.dart';
import 'package:wood_service/widgets/auth_button_txt.dart';
import 'package:wood_service/widgets/custom_button.dart';
import 'package:wood_service/widgets/custom_text_style.dart';
import 'package:wood_service/widgets/custom_textfield.dart';

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

  bool _isLoading = false;
  bool _obscurePassword = true;

  // Use nullable so we can guard in build during hot-reload glitches.
  AnimationController? _animController;
  Animation<double>? _fadeAnim;
  Animation<Offset>? _slideAnim;

  @override
  void initState() {
    super.initState();

    // Initialize controller and animations here.
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

    // Start entrance animation
    _animController!.forward();
  }

  @override
  void dispose() {
    _animController?.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter your email';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(v.trim())) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Please enter password';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // simulate auth
    await Future.delayed(const Duration(milliseconds: 900));

    setState(() => _isLoading = false);

    // Navigate on success (example)
    context.push('/seller_dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slideAnim;
    final fade = _fadeAnim;

    Widget content = Stack(
      children: [
        // Main content
        _buildCard(context),

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
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => context.push('/seller_signup'),
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
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Card(
      elevation: 18,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  // Email
                  CustomTextFormField.email(
                    controller: _emailController,
                    hintText: 'Email Address',
                    onChanged: (value) {
                      print('Email: $value');
                    },
                    focusNode: _emailFocusNode,
                  ),
                  const SizedBox(height: 14),
                  CustomTextFormField.password(
                    controller: _passwordController,
                    hintText: 'Password',
                    onChanged: (value) {
                      print('Password: $value');
                    },
                    focusNode: _passwordFocusNode,
                  ),

                  const SizedBox(height: 10),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        context.push('/forgot_password');
                      },
                      child: Text(
                        'Forgot Password?',
                        // style: AppCustomTextStyle.bodyText(context)
                        //       .copyWith(color: AppColors.brightOrange),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Login button
                  CustomButtonUtils.login(
                    backgroundColor: AppColors.brightOrange,
                    padding: EdgeInsets.all(0),
                    title: 'Login',
                    onPressed: () {
                      context.push('/seller_signup');
                    },
                  ),
                  const SizedBox(height: 18),

                  // Divider with text
                  Row(
                    children: [
                      Expanded(child: Divider(color: AppColors.grey)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
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
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: wire Google sign-in
                          },
                          icon: const Icon(Icons.apple, size: 20),
                          label: Text(
                            'Google',
                            // style: AppCustomTextStyle.bodyText(context)
                            // .copyWith(color: Colors.black87),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side: BorderSide(color: Colors.grey.shade300),
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: wire Apple sign-in
                          },
                          icon: const Icon(Icons.apple, size: 20),
                          label: Text(
                            'Apple',
                            //   style: AppCustomTextStyle.bodyText(context)
                            //       .copyWith(color: Colors.black87),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side: BorderSide(color: Colors.grey.shade300),
                            backgroundColor: Colors.white,
                          ),
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
  }
}
