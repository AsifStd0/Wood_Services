import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/core/theme/app_icons.dart';
import 'package:wood_service/core/theme/app_test_style.dart';
import 'package:wood_service/widgets/custom_button.dart';
import 'package:wood_service/widgets/custom_data.dart';
import 'package:wood_service/widgets/custom_text.dart';
import 'package:wood_service/widgets/custom_textfield.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  TextEditingController verifyCode = TextEditingController();
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    verifyCode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.chairBackColor,
        toolbarHeight: 10,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // 👈 key
          children: [
            // 🔹 Top content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    WelcomeFurni(onBack: () => Navigator.pop(context)),
                    const SizedBox(height: 40),
                    CustomText(
                      'Nam ultricies lectus a risus blandit elementum. Quisque arcu arcu, tristique a eu in diam.',
                    ),
                    const SizedBox(height: 40),

                    CustomTextFormField(
                      controller: verifyCode,
                      textFieldType: TextFieldType.confrimpassword,
                      onChanged: (value) {},
                      hintText: 'Confirm Password',
                      obscureText: true,
                      prefixIcon: AppIcons.lock,
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomText(
                          'Resend Code',
                          color: AppColors.brightOrange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    CustomButtonUtils.signUp(
                      onPressed: () {
                        context.push('/home');
                      },
                      width: double.infinity,
                      child: const Text('Verify'),
                    ),
                  ],
                ),
              ),
            ),

            // 🔹 Bottom footer always at bottom
            AuthFooterText(
              questionText: "Already have an account? ",
              actionText: "register",
              onTap: () {
                context.push('/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}
