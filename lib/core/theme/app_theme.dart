import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_fonts.dart';
import 'app_styles.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      titleTextStyle: AppStyles.appBarTitle,
      iconTheme: const IconThemeData(color: AppColors.white),
    ),
    textTheme: TextTheme(
      displayLarge: AppStyles.heading1,
      displayMedium: AppStyles.heading2,
      bodyLarge: AppStyles.bodyLarge,
      bodyMedium: AppStyles.bodyMedium,
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: AppColors.primary,
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      filled: true,
      fillColor: AppColors.white,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    primaryColor: AppColors.primaryDark,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primaryDark,
      titleTextStyle: AppStyles.appBarTitle.copyWith(color: AppColors.white),
    ),
    textTheme: TextTheme(
      displayLarge: AppStyles.heading1.copyWith(color: AppColors.white),
      displayMedium: AppStyles.heading2.copyWith(color: AppColors.white),
      bodyLarge: AppStyles.bodyLarge.copyWith(color: AppColors.white),
      bodyMedium: AppStyles.bodyMedium.copyWith(color: AppColors.white),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.greyDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      filled: true,
      fillColor: AppColors.greyDark,
    ),
  );
}
