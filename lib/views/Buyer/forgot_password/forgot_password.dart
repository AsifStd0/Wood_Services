import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/core/theme/app_test_style.dart';
import 'package:wood_service/widgets/custom_button.dart';
import 'package:wood_service/widgets/custom_text_style.dart';
import 'package:wood_service/widgets/custom_textfield.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: CustomText(
          'Forgot Password',
          type: CustomTextType.headingMedium,
        ),
        centerTitle: true,
      ),
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
                      padding: const EdgeInsets.only(top: 20, bottom: 5),
                      child: Text(
                        'Find Your Account',
                        style: AppCustomTextStyle.headlineMedium(context),
                      ),
                    ),
                    CustomText(
                      'Enter your phone address or phone number to reset your password',
                      fontSize: 14,
                      color: AppColors.grayMedium,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: CustomTextFormField(
                        controller: _emailController,
                        hintText: 'Email address or phone number',
                        onChanged: (value) {
                          print('Email: $value');
                        },
                        focusNode: _emailFocusNode,
                      ),
                    ),
                    SizedBox(height: 40),
                    // Sign Up Button
                    CustomButtonUtils.login(
                      title: 'Send Reset Instructions',
                      backgroundColor: AppColors.brightOrange,
                      onPressed: () {
                        context.push('/new_password');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
