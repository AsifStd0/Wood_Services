import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/core/theme/app_test_style.dart';
import 'package:wood_service/widgets/auth_button_txt.dart';
import 'package:wood_service/widgets/custom_button.dart';
import 'package:wood_service/widgets/custom_text_style.dart';
import 'package:wood_service/widgets/custom_textfield.dart';

class BuyerLoginScreen extends StatefulWidget {
  const BuyerLoginScreen({super.key});

  @override
  State<BuyerLoginScreen> createState() => _BuyerLoginScreenState();
}

class _BuyerLoginScreenState extends State<BuyerLoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;

  AnimationController? _animController;
  Animation<double>? _fadeAnim;
  Animation<Offset>? _slideAnim;

  @override
  void initState() {
    super.initState();

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

  Future<void> _submit() async {
    context.push('/buyer_signup');
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
                  (_) => context.push('/buyer_signup'),
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
            // Header - Changed to buyer theme
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

                  // Password
                  CustomTextFormField.password(
                    controller: _passwordController,
                    hintText: 'Password',
                    onChanged: (value) {
                      print('Password: $value');
                    },
                    focusNode: _passwordFocusNode,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: CustomButtonUtils.textButton(
                      onPressed: () {
                        context.push('/buyer_forgot');
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

                  // Login button
                  SizedBox(
                    width: double.infinity,
                    child: CustomButtonUtils.login(
                      backgroundColor: AppColors.brightOrange,
                      title: 'Login',
                      onPressed: _submit,
                    ),
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

                  // Social buttons - Using your custom widgets
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
  }
}
