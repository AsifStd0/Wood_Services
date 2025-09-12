import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wood_service/views/auth/login.dart/auth_provider.dart';
import 'package:wood_service/views/auth/register.dart/register_screen.dart';
import 'package:wood_service/widgets/custom_button.dart';
import 'package:wood_service/widgets/custom_textfield.dart';

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
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 60),
                // App Logo/Title
                Text(
                  'Wood Service',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Welcome back!',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 40),

                // Email Field
                CustomTextFormField(
                  controller: _emailController,
                  textFieldType: TextFieldType.email,
                  onChanged: (value) {},

                  hintText: 'Enter your email',
                  prefixIcon: Icon(Icons.email, color: theme.primaryColor),
                ),

                const SizedBox(height: 20),

                // Password Field
                CustomTextFormField(
                  controller: _passwordController,
                  textFieldType: TextFieldType.password,
                  onChanged: (value) {},
                  hintText: 'Enter your password',
                  obscureText: true,
                  prefixIcon: Icon(Icons.lock, color: theme.primaryColor),
                ),
                const SizedBox(height: 16),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: CustomButtonUtils.text(
                    onPressed: () {
                      // Navigate to forgot password screen
                      print('Forgot password pressed');
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Login Button
                CustomButtonUtils.primary(
                  onPressed: authProvider.isLoading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            authProvider.login(
                              _emailController.text,
                              _passwordController.text,
                            );
                          }
                        },
                  isLoading: authProvider.isLoading,
                  size: ButtonSize.large,
                  width: double.infinity,

                  child: const Text('Login'),
                ),
                const SizedBox(height: 20),

                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[300])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[300])),
                  ],
                ),
                const SizedBox(height: 20),

                // Create Account Button
                CustomButtonUtils.primary(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => SignUpScreen()),
                    );
                    // Navigate to register screen
                    print('Create account pressed');
                  },
                  size: ButtonSize.large,
                  width: double.infinity,
                  child: const Text('Create New Account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
