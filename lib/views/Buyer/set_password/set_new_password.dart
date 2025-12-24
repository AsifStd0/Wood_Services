import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/views/Buyer/phone_verification/phone_verification.dart';
import 'package:wood_service/widgets/custom_button.dart';

class SetNewPasswordScreen extends StatefulWidget {
  const SetNewPasswordScreen({super.key});

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  double _strength = 0;
  String _strengthLabel = "Weak";

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  void _checkPasswordStrength(String password) {
    double strength = 0;

    if (password.isEmpty) {
      strength = 0;
    } else if (password.length < 6) {
      strength = 0.25;
    } else if (password.length < 8) {
      strength = 0.5;
    } else if (password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[0-9]')) &&
        password.contains(RegExp(r'[!@#\$&*~]'))) {
      strength = 1.0;
    } else {
      strength = 0.75;
    }

    String label;
    if (strength <= 0.25) {
      label = "Weak";
    } else if (strength <= 0.5) {
      label = "Fair";
    } else if (strength <= 0.75) {
      label = "Good";
    } else {
      label = "Strong";
    }

    setState(() {
      _strength = strength;
      _strengthLabel = label;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color accentColor = const Color(0xFFB97A56); // brownish like image

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F3), // light beige background
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF6F3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Set New Password",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // New Password
            const Text(
              "New Password",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              onChanged: _checkPasswordStrength,
              decoration: InputDecoration(
                hintText: "Enter your new password",
                filled: true,
                fillColor: accentColor.withOpacity(0.08),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: accentColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Password Strength
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Password Strength",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                ),
                Text(
                  _strengthLabel,
                  style: TextStyle(
                    fontSize: 13,
                    color: accentColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _strength,
                backgroundColor: Colors.grey.shade300,
                color: accentColor,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 20),

            // Confirm Password
            const Text(
              "Confirm New Password",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _confirmController,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                hintText: "Confirm your new password",
                filled: true,
                fillColor: accentColor.withOpacity(0.08),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: accentColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirm = !_obscureConfirm;
                    });
                  },
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            Spacer(),
            CustomButtonUtils.login(
              title: 'Reset Password',
              backgroundColor: AppColors.brightOrange,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) {
                      return PhoneVerificationScreen();
                    },
                  ),
                );
                // context.push('/phone_verificaion');
              },
            ),
          ],
        ),
      ),
    );
  }
}
