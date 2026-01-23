import 'package:flutter/material.dart';
import 'package:wood_service/core/theme/app_colors.dart';

class AppCustomTextStyle {
  // Headline Text Styles
  static TextStyle headlineLarge(BuildContext context) {
    return Theme.of(context).textTheme.headlineLarge?.copyWith(
          fontSize: 32,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ) ??
        const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        );
  }

  static TextStyle headlineMedium(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ) ??
        const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        );
  }

  static TextStyle headlineSmall(BuildContext context) {
    return Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ) ??
        const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        );
  }

  // Title Text Styles
  static TextStyle titleLarge(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge?.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ) ??
        const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        );
  }

  static TextStyle titleMedium(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          color: AppColors.textPrimary,
        ) ??
        const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          color: AppColors.textPrimary,
        );
  }

  // Body Text Styles
  static TextStyle bodyLarge(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          color: AppColors.textPrimary,
        ) ??
        const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          color: AppColors.textPrimary,
        );
  }

  static TextStyle bodyMedium(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          color: AppColors.textPrimary,
        ) ??
        const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          color: AppColors.textPrimary,
        );
  }

  static TextStyle appSubtitle(BuildContext context) {
    return titleMedium(
      context,
    ).copyWith(color: AppColors.grayMedium, fontWeight: FontWeight.w400);
  }

  static TextStyle buttonSecondary(BuildContext context) {
    return bodyLarge(context).copyWith(
      fontWeight: FontWeight.w600,
      color: AppColors.bluePrimary,
      letterSpacing: 0.75,
    );
  }

  static TextStyle buttonText(BuildContext context) {
    return bodyMedium(context).copyWith(
      fontWeight: FontWeight.w500,
      color: AppColors.white,
      fontSize: 17,
    );
  }

  static TextStyle inputHint(BuildContext context) {
    return bodyLarge(context).copyWith(color: AppColors.textSecondary);
  }
}
