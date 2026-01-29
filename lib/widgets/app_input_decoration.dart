import 'package:flutter/material.dart';
import 'package:wood_service/core/theme/app_colors.dart';

class AppInputDecoration {
  static InputDecoration outlined({
    required BuildContext context,
    String? labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool isDense = true,
    EdgeInsetsGeometry? contentPadding,
    double radius = 8,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      alignLabelWithHint: true,
      isDense: isDense,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      contentPadding:
          contentPadding ??
          const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
        fontSize: 14,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(
          color: AppColors.grey.withOpacity(0.6),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(
          color: AppColors.grey.withOpacity(0.6),
          width: 1,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(
          color: AppColors.grey.withOpacity(0.6),
          width: 1,
        ),
      ),
    );
  }
}
