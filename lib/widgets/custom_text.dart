import 'package:flutter/material.dart';
import 'package:wood_service/core/theme/app_colors.dart';

class AuthFooterText extends StatelessWidget {
  final String questionText;
  final String actionText;
  final Color questionColor;
  final Color actionColor;
  final double fontSize;
  final VoidCallback onTap;

  const AuthFooterText({
    super.key,
    required this.questionText,
    required this.actionText,
    required this.onTap,
    this.questionColor = Colors.grey,
    this.actionColor = AppColors.brightOrange,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          questionText,
          style: TextStyle(color: questionColor, fontSize: fontSize),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionText,
            style: TextStyle(
              color: actionColor,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
        ),
      ],
    );
  }
}
