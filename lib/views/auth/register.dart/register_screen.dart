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

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
              // 📌 Top scrollable form content
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        WelcomeFurni(onBack: () => Navigator.pop(context)),
                        const SizedBox(height: 20),

                        CustomTextFormField(
                          controller: _nameController,
                          textFieldType: TextFieldType.name,
                          hintText: 'Name',
                          prefixIcon: AppIcons.person,
                        ),
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
                        const SizedBox(height: 20),

                        CustomTextFormField(
                          controller: _confirmPasswordController,
                          textFieldType: TextFieldType.confrimpassword,
                          hintText: 'Confirm Password',
                          obscureText: true,
                          prefixIcon: AppIcons.lock,
                        ),
                        const SizedBox(height: 24),

                        CustomButtonUtils.signUp(
                          onPressed: authProvider.isLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    if (_passwordController.text !=
                                        _confirmPasswordController.text) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Passwords do not match!',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    print('object data is here ....');
                                    WidgetsBinding.instance
                                        .addPostFrameCallback(
                                          (_) => context.push('/otp'),
                                        );
                                  }
                                },
                          isLoading: authProvider.isLoading,
                          width: double.infinity,
                          child: const Text('Sign Up'),
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
                                'or Sign up with',
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
                questionText: "Already have an account? ",
                actionText: "Login",
                onTap: () {
                  context.push('/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import '../../../app/index.dart';

// class SignUpScreen extends StatelessWidget {
//   const SignUpScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<RegisterProvider>();
//     final theme = Theme.of(context);

//     return Scaffold(
//       appBar: AppBar(title: const Text('Create Account')),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: ListView(
//           children: [
//             // Profile Image
//             GestureDetector(
//               onTap: () => provider.showImageSourceDialog(context),
//               child: CircleAvatar(
//                 radius: 50,
//                 backgroundColor: Colors.grey[200],
//                 backgroundImage: provider.profileImage != null
//                     ? FileImage(provider.profileImage!)
//                     : null,
//                 child: provider.profileImage == null
//                     ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
//                     : null,
//               ),
//             ),

//             const SizedBox(height: 20),

//             CustomTextFormField(
//               hintText: 'Enter your full name',
//               prefixIcon: Icon(Icons.person, color: theme.primaryColor),
//               onChanged: provider.updateName,
//             ),
//             const SizedBox(height: 20),

//             // Email Field
//             CustomTextFormField(
//               hintText: 'Enter your email',
//               prefixIcon: Icon(Icons.email, color: theme.primaryColor),
//               onChanged: provider.updateEmail,
//             ),

//             const SizedBox(height: 15),

//             CustomTextFormField(
//               hintText: 'Password',
//               prefixIcon: Icon(
//                 Icons.lock_open_outlined,
//                 color: theme.primaryColor,
//               ),
//               onChanged: provider.updatePassword,
//               obscureText: true,
//             ),

//             const SizedBox(height: 15),

//             CustomTextFormField(
//               hintText: 'Confirm Password',
//               prefixIcon: Icon(Icons.lock_outline, color: theme.primaryColor),
//               onChanged: provider.updateConfirmPassword,
//               obscureText: true,
//             ),
//             const SizedBox(height: 15),

//             // Terms Checkbox
//             Row(
//               children: [
//                 Checkbox(
//                   value: provider.termsAccepted,
//                   onChanged: provider.toggleTerms,
//                 ),
//                 const Text('I agree to Terms and Conditions'),
//               ],
//             ),

//             const SizedBox(height: 20),

//             // Register Button
//             ElevatedButton(
//               onPressed: provider.isLoading
//                   ? null
//                   : () async {
//                       final result = await provider.register();
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text(result['message'])),
//                       );
//                       if (result['success'] == true) {
//                         Navigator.pop(context);
//                       }
//                     },
//               child: provider.isLoading
//                   ? const CircularProgressIndicator()
//                   : const Text('Create Account'),
//             ),

//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Already have an account? Login'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
