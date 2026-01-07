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

  static TextStyle titleSmall(BuildContext context) {
    return Theme.of(context).textTheme.titleSmall?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: AppColors.textPrimary,
        ) ??
        const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
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

  static TextStyle bodySmall(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          color: AppColors.textSecondary,
        ) ??
        const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          color: AppColors.textSecondary,
        );
  }

  // Label Text Styles
  static TextStyle labelLarge(BuildContext context) {
    return Theme.of(context).textTheme.labelLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: AppColors.textPrimary,
        ) ??
        const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: AppColors.textPrimary,
        );
  }

  static TextStyle labelMedium(BuildContext context) {
    return Theme.of(context).textTheme.labelMedium?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: AppColors.textPrimary,
        ) ??
        const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: AppColors.textPrimary,
        );
  }

  static TextStyle labelSmall(BuildContext context) {
    return Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: AppColors.textSecondary,
        ) ??
        const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: AppColors.textSecondary,
        );
  }

  // Custom App Specific Styles
  static TextStyle appTitle(BuildContext context) {
    return headlineLarge(context).copyWith(
      fontWeight: FontWeight.w700,
      color: AppColors.black,
      letterSpacing: 0.5,
    );
  }

  static TextStyle appSubtitle(BuildContext context) {
    return titleMedium(
      context,
    ).copyWith(color: AppColors.grayMedium, fontWeight: FontWeight.w400);
  }

  static TextStyle buttonPrimary(BuildContext context) {
    return bodyLarge(context).copyWith(
      fontWeight: FontWeight.w600,
      color: AppColors.white,
      letterSpacing: 0.75,
    );
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

  static TextStyle sectionHeader(BuildContext context) {
    return titleLarge(
      context,
    ).copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  }

  static TextStyle cardTitle(BuildContext context) {
    return titleMedium(
      context,
    ).copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  }

  static TextStyle cardSubtitle(BuildContext context) {
    return bodyMedium(context).copyWith(color: AppColors.textSecondary);
  }

  static TextStyle priceText(BuildContext context) {
    return titleMedium(
      context,
    ).copyWith(fontWeight: FontWeight.w700, color: AppColors.bluePrimary);
  }

  static TextStyle discountText(BuildContext context) {
    return bodySmall(context).copyWith(
      fontWeight: FontWeight.w500,
      color: AppColors.error,
      decoration: TextDecoration.lineThrough,
    );
  }

  static TextStyle tagText(BuildContext context) {
    return labelSmall(
      context,
    ).copyWith(fontWeight: FontWeight.w600, color: AppColors.white);
  }

  static TextStyle inputLabel(BuildContext context) {
    return bodyMedium(
      context,
    ).copyWith(fontWeight: FontWeight.w500, color: AppColors.textPrimary);
  }

  static TextStyle inputText(BuildContext context) {
    return bodyLarge(context).copyWith(color: AppColors.textPrimary);
  }

  static TextStyle inputHint(BuildContext context) {
    return bodyLarge(context).copyWith(color: AppColors.textSecondary);
  }

  static TextStyle errorText(BuildContext context) {
    return bodySmall(
      context,
    ).copyWith(color: AppColors.error, fontWeight: FontWeight.w500);
  }

  static TextStyle successText(BuildContext context) {
    return bodySmall(
      context,
    ).copyWith(color: AppColors.success, fontWeight: FontWeight.w500);
  }

  static TextStyle linkText(BuildContext context) {
    return bodyMedium(context).copyWith(
      color: AppColors.bluePrimary,
      fontWeight: FontWeight.w500,
      decoration: TextDecoration.underline,
    );
  }

  // Navigation Styles
  static TextStyle navBarTitle(BuildContext context) {
    return titleMedium(
      context,
    ).copyWith(fontWeight: FontWeight.w600, color: AppColors.bluePrimary);
  }

  static TextStyle navBarItem(BuildContext context) {
    return bodyMedium(context).copyWith(fontWeight: FontWeight.w500);
  }

  static TextStyle navBarItemSelected(BuildContext context) {
    return bodyMedium(
      context,
    ).copyWith(fontWeight: FontWeight.w600, color: AppColors.bluePrimary);
  }
}
