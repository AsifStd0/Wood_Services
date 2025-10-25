import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/core/theme/app_test_style.dart';
import 'package:wood_service/widgets/auth_button_txt.dart';
import 'package:wood_service/widgets/custom_button.dart';
import 'package:wood_service/widgets/custom_text_style.dart';
import 'package:wood_service/widgets/custom_textfield.dart';

//  WidgetsBinding.instance
//                                       .addPostFrameCallback(
//                                         (_) => context.push('/otp'),
//                                       );
class SellerLogin extends StatefulWidget {
  @override
  State<SellerLogin> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<SellerLogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            /// Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 50, bottom: 40),
                      child: CustomText(
                        'Welcome Seller Login',
                        type: CustomTextType.headingLittleLarge,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: CustomText(
                        'Login to continue your future journey',
                      ),
                    ),
                    CustomTextFormField.email(
                      controller: _emailController,
                      hintText: 'Email Address',
                      onChanged: (value) {
                        print('Email: $value');
                      },
                      focusNode: _emailFocusNode,
                    ),
                    const SizedBox(height: 16),
                    CustomTextFormField.password(
                      controller: _passwordController,
                      hintText: 'Password',
                      onChanged: (value) {
                        print('Password: $value');
                      },
                      focusNode: _passwordFocusNode,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: CustomButtonUtils.textButton(
                        onPressed: () {},
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(color: AppColors.brightOrange),
                        ),
                      ),
                    ),
                    CustomButtonUtils.login(
                      backgroundColor: AppColors.brightOrange,
                      padding: EdgeInsets.all(0),
                      title: 'Login',
                      onPressed: () {
                        context.push('/seller_signup');
                      },
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(child: Divider(color: AppColors.grey)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Or continue with',
                            style: TextStyle(
                              color: AppColors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: AppColors.grey)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButtonUtils.googleSignIn(
                            onPressed: () {},
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: CustomButtonUtils.appleSignIn(
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            /// Always at bottom
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: AuthBottomText(
                questionText: "Don't have an account? ",
                actionText: "Sign Up",
                onPressed: () {
                  print('object');
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => context.push('/seller_signup'),
                  );
                  // Navigator.pushNamed(context, '/signup');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}
