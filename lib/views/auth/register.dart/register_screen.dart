import 'package:flutter/material.dart';
import '../../../app/index.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegisterProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            // Profile Image
            GestureDetector(
              onTap: () => provider.showImageSourceDialog(context),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                backgroundImage: provider.profileImage != null
                    ? FileImage(provider.profileImage!)
                    : null,
                child: provider.profileImage == null
                    ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                    : null,
              ),
            ),

            const SizedBox(height: 20),

            CustomTextFormField(
              hintText: 'Enter your full name',
              prefixIcon: Icon(Icons.person, color: theme.primaryColor),
              onChanged: provider.updateName,
            ),
            const SizedBox(height: 20),

            // Email Field
            CustomTextFormField(
              hintText: 'Enter your email',
              prefixIcon: Icon(Icons.email, color: theme.primaryColor),
              onChanged: provider.updateEmail,
            ),

            const SizedBox(height: 15),

            CustomTextFormField(
              hintText: 'Password',
              prefixIcon: Icon(
                Icons.lock_open_outlined,
                color: theme.primaryColor,
              ),
              onChanged: provider.updatePassword,
              obscureText: true,
            ),

            const SizedBox(height: 15),

            CustomTextFormField(
              hintText: 'Confirm Password',
              prefixIcon: Icon(Icons.lock_outline, color: theme.primaryColor),
              onChanged: provider.updateConfirmPassword,
              obscureText: true,
            ),
            const SizedBox(height: 15),

            // Terms Checkbox
            Row(
              children: [
                Checkbox(
                  value: provider.termsAccepted,
                  onChanged: provider.toggleTerms,
                ),
                const Text('I agree to Terms and Conditions'),
              ],
            ),

            const SizedBox(height: 20),

            // Register Button
            ElevatedButton(
              onPressed: provider.isLoading
                  ? null
                  : () async {
                      final result = await provider.register();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result['message'])),
                      );
                      if (result['success'] == true) {
                        Navigator.pop(context);
                      }
                    },
              child: provider.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Create Account'),
            ),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
