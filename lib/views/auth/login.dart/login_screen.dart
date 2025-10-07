import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/core/theme/app_icons.dart';
import 'package:wood_service/views/auth/login.dart/auth_provider.dart';
import 'package:wood_service/widgets/custom_button.dart';
import 'package:wood_service/widgets/custom_data.dart';
import 'package:wood_service/widgets/custom_text.dart';
import 'package:wood_service/widgets/custom_textfield.dart';
import 'package:wood_service/widgets/social_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.chairBackColor,
        toolbarHeight: 10,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            children: [
              // 📌 Scrollable part
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        WelcomeFurni(onBack: () {}),
                        const SizedBox(height: 20),

                        CustomTextFormField(
                          controller: _emailController,
                          textFieldType: TextFieldType.email,
                          hintText: 'Email',
                          prefixIcon: AppIcons.email,
                        ),
                        const SizedBox(height: 20),

                        CustomTextFormField(
                          controller: _passwordController,
                          textFieldType: TextFieldType.password,
                          hintText: 'Password',
                          obscureText: true,
                          prefixIcon: AppIcons.lock,
                        ),
                        const SizedBox(height: 16),

                        RememberForgot(
                          initialRememberValue: false,
                          onRememberChanged: (value) {},
                          onForgotPassword: () {
                            Navigator.pushNamed(context, '/forgot-password');
                          },
                          rememberText: "Remember me",
                          forgotText: "Forgot Password?",
                          rememberTextColor: Colors.grey,
                          forgotTextColor: Colors.orange,
                          textSize: 14,
                        ),
                        const SizedBox(height: 24),

                        CustomButtonUtils.signUp(
                          onPressed: authProvider.isLoading
                              ? null
                              : () {
                                  context.push('/home');
                                  // if (_formKey.currentState!.validate()) {
                                  //   authProvider.login(
                                  //     _emailController.text,
                                  //     _passwordController.text,
                                  //   );
                                  // }
                                },
                          isLoading: authProvider.isLoading,
                          width: double.infinity,
                          child: const Text('Login'),
                        ),
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey[300])),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                'or Login With',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey[300])),
                          ],
                        ),
                        const SizedBox(height: 20),

                        SocialButtons(),
                      ],
                    ),
                  ),
                ),
              ),

              // 📌 Fixed footer at bottom
              AuthFooterText(
                questionText: "Don't have an account? ",
                actionText: "Register",
                onTap: () {
                  context.push('/signup');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
