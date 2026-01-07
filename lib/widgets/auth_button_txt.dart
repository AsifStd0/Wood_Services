import 'package:flutter/material.dart';
import 'package:wood_service/core/theme/app_colors.dart';

class AuthBottomText extends StatelessWidget {
  final String questionText; // e.g. "Don't have an account?"
  final String actionText; // e.g. "Sign Up"
  final VoidCallback onPressed; // action when clicked
  // final Color questionColor;
  // final Color actionColor;

  const AuthBottomText({
    super.key,
    required this.questionText,
    required this.actionText,
    required this.onPressed,
    // this.questionColor = Colors.grey,
    // this.actionColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(questionText, style: TextStyle(color: AppColors.brightOrange)),
          TextButton(
            onPressed: onPressed,
            child: Text(
              actionText,
              style: TextStyle(color: AppColors.brightOrange),
            ),
          ),
        ],
      ),
    );
  }
}
