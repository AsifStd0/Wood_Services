import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_fonts.dart';

class AppStyles {
  // Text styles
  static const TextStyle heading1 = TextStyle(
    fontFamily: AppFonts.primary,
    fontSize: AppFonts.display,
    fontWeight: AppFonts.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: AppFonts.primary,
    fontSize: AppFonts.title,
    fontWeight: AppFonts.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading3 = TextStyle(
    fontFamily: AppFonts.primary,
    fontSize: AppFonts.heading,
    fontWeight: AppFonts.semiBold,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: AppFonts.primary,
    fontSize: AppFonts.large,
    fontWeight: AppFonts.regular,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: AppFonts.primary,
    fontSize: AppFonts.mediumFont,
    fontWeight: AppFonts.regular,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: AppFonts.primary,
    fontSize: AppFonts.small,
    fontWeight: AppFonts.regular,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: AppFonts.primary,
    fontSize: AppFonts.extraSmall,
    fontWeight: AppFonts.regular,
    color: AppColors.textSecondary,
  );

  // Button styles
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: AppFonts.primary,
    fontSize: AppFonts.large,
    fontWeight: AppFonts.medium,
    color: AppColors.white,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: AppFonts.primary,
    fontSize: AppFonts.mediumFont,
    fontWeight: AppFonts.medium,
    color: AppColors.white,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: AppFonts.primary,
    fontSize: AppFonts.small,
    fontWeight: AppFonts.medium,
    color: AppColors.white,
  );

  // App bar title
  static const TextStyle appBarTitle = TextStyle(
    fontFamily: AppFonts.primary,
    fontSize: AppFonts.mediumFont,
    fontWeight: AppFonts.medium,
    color: AppColors.white,
  );

  // Input decoration styles
  static InputDecoration textFieldDecoration(
    String labelText, {
    String? hintText,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      filled: true,
      fillColor: AppColors.white,
    );
  }
}
