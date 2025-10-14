import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/core/theme/app_test_style.dart';
import 'package:wood_service/widgets/auth_button_txt.dart';
import 'package:wood_service/widgets/custom_button.dart';
import 'package:wood_service/widgets/custom_text_style.dart';
import 'package:wood_service/widgets/custom_textfield.dart';

class SignUpScreen extends StatefulWidget {
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final FocusNode _fullNameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _locationFocusNode = FocusNode();

  bool _agreeToTerms = false;

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
                      padding: const EdgeInsets.only(top: 70, bottom: 20),
                      child: Text(
                        'Create Account',
                        style: AppCustomTextStyle.appTitle(context),
                      ),
                    ),

                    CustomText('Full Name'),
                    // Full Name Field
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: CustomTextFormField(
                        controller: _fullNameController,
                        hintText: 'Enter Your Full Name',
                        onChanged: (value) {
                          print('Full Name: $value');
                        },
                        focusNode: _fullNameFocusNode,
                      ),
                    ),

                    // Email Field
                    CustomText('Email'),
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: CustomTextFormField.email(
                        controller: _emailController,
                        hintText: 'Enter Your Email',
                        onChanged: (value) {
                          print('Email: $value');
                        },
                        focusNode: _emailFocusNode,
                      ),
                    ),

                    // Password Field
                    CustomText('Password'),

                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: CustomTextFormField.password(
                        controller: _passwordController,
                        hintText: 'Enter Your Password',
                        onChanged: (value) {
                          print('Password: $value');
                        },
                        focusNode: _passwordFocusNode,
                      ),
                    ),

                    // Location Field
                    CustomText('Location'),

                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: CustomTextFormField(
                        controller: _locationController,
                        hintText: 'Enter Your Location',
                        onChanged: (value) {
                          print('Location: $value');
                        },
                        focusNode: _locationFocusNode,
                      ),
                    ),

                    // Terms and Conditions Radio Button with custom styling
                    agreeCondition(),
                    const SizedBox(height: 20),

                    // Sign Up Button
                    CustomButtonUtils.login(title: 'Login', onPressed: () {}),
                  ],
                ),
              ),
            ),

            /// Always at bottom
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AuthBottomText(
                questionText: "Already have an account? ",
                actionText: "Sign In",
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row agreeCondition() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _agreeToTerms = !_agreeToTerms;
            });
          },
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _agreeToTerms ? AppColors.buttonColor : Colors.grey,
                width: 2,
              ),
              color: _agreeToTerms ? AppColors.buttonColor : Colors.transparent,
            ),
            child: _agreeToTerms
                ? Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Wrap(
            children: [
              Text(
                'I agree to ',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to terms and conditions
                  print('Terms and Conditions tapped');
                },
                child: Text(
                  'Terms and Conditions',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.buttonColor,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _locationController.dispose();
    _fullNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _locationFocusNode.dispose();
    super.dispose();
  }
}
