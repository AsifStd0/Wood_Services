import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/core/theme/app_fonts.dart';

enum ButtonType { primary, secondary, outline, textButton, buyButton }

enum ButtonSize { small, medium, large, extraLarge }

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.onPressed,
    this.onLongPress,
    required this.child,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.disabled = false,
    this.width,
    this.height,
    this.borderRadius,
    this.padding,
    this.prefixIcon,
    this.suffixIcon,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.hapticFeedback = true,
    this.elevation,
    this.shadowColor,
    this.gradient,
    this.borderWidth = 1.0,
  });

  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final Widget child;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final bool disabled;
  final double? width;
  final double? height;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final bool hapticFeedback;
  final double? elevation;
  final Color? shadowColor;
  final Gradient? gradient;
  final double borderWidth;

  bool get _isEnabled => !disabled && !isLoading && onPressed != null;

  Color _getBackgroundColor(BuildContext context) {
    if (backgroundColor != null) return backgroundColor!;

    switch (type) {
      case ButtonType.primary:
        return Theme.of(context).primaryColor;
      case ButtonType.secondary:
        return AppColors.secondary;
      case ButtonType.outline:
        return Colors.transparent;
      case ButtonType.textButton:
        return Colors.transparent;
      case ButtonType buyButton:
        return AppColors.yellowButton;
    }
  }

  Color _getForegroundColor(BuildContext context) {
    if (foregroundColor != null) return foregroundColor!;

    switch (type) {
      case ButtonType.primary:
        return AppColors.white;
      case ButtonType.secondary:
        return AppColors.white;
      case ButtonType.outline:
        return Theme.of(context).primaryColor;
      case ButtonType.textButton:
        return Theme.of(context).primaryColor;
      case ButtonType.buyButton:
        return AppColors.yellowButton;
    }
  }

  Color _getBorderColor(BuildContext context) {
    if (borderColor != null) return borderColor!;

    switch (type) {
      case ButtonType.primary:
      case ButtonType.secondary:
        return _getBackgroundColor(context);
      case ButtonType.outline:
        return Theme.of(context).primaryColor;
      case ButtonType.textButton:
        return Colors.transparent;
      case ButtonType.buyButton:
        return AppColors.yellowButton;
    }
  }

  Color _getDisabledBackgroundColor(BuildContext context) {
    switch (type) {
      case ButtonType.primary:
      case ButtonType.secondary:
        return AppColors.grey.withOpacity(0.5);
      case ButtonType.outline:
      case ButtonType.textButton:
        return Colors.transparent;
      case ButtonType.buyButton:
        return AppColors.yellowButton;
    }
  }

  Color _getDisabledForegroundColor(BuildContext context) {
    switch (type) {
      case ButtonType.primary:
      case ButtonType.secondary:
        return AppColors.white.withOpacity(0.7);
      case ButtonType.outline:
      case ButtonType.textButton:
        return AppColors.grey.withOpacity(0.7);
      case ButtonType.buyButton:
        return AppColors.yellowButton;
    }
  }

  Color _getDisabledBorderColor(BuildContext context) {
    switch (type) {
      case ButtonType.primary:
      case ButtonType.secondary:
        return AppColors.grey.withOpacity(0.5);
      case ButtonType.outline:
        return AppColors.grey.withOpacity(0.5);
      case ButtonType.textButton:
        return Colors.transparent;
      case ButtonType.buyButton:
        return AppColors.yellowButton;
    }
  }

  double _getBorderRadius() {
    return borderRadius ??
        (size == ButtonSize.small
            ? 6.0
            : size == ButtonSize.medium
            ? 8.0
            : size == ButtonSize.large
            ? 12.0
            : 16.0);
  }

  EdgeInsetsGeometry _getPadding() {
    if (padding != null) return padding!;

    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 16);
      case ButtonSize.extraLarge:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 20);
    }
  }

  double _getElevation() {
    return elevation ??
        (type == ButtonType.textButton || type == ButtonType.outline
            ? 0.0
            : 2.0);
  }

  TextStyle _getTextStyle(BuildContext context) {
    switch (size) {
      case ButtonSize.small:
        return Theme.of(context).textTheme.bodySmall!.copyWith(
          fontWeight: AppFonts.medium,
          color: _isEnabled
              ? _getForegroundColor(context)
              : _getDisabledForegroundColor(context),
        );
      case ButtonSize.medium:
        return Theme.of(context).textTheme.bodyMedium!.copyWith(
          fontWeight: AppFonts.medium,
          color: _isEnabled
              ? _getForegroundColor(context)
              : _getDisabledForegroundColor(context),
        );
      case ButtonSize.large:
        return Theme.of(context).textTheme.bodyLarge!.copyWith(
          fontWeight: AppFonts.medium,
          color: _isEnabled
              ? _getForegroundColor(context)
              : _getDisabledForegroundColor(context),
        );
      case ButtonSize.extraLarge:
        return Theme.of(context).textTheme.titleSmall!.copyWith(
          fontWeight: AppFonts.semiBold,
          color: _isEnabled
              ? _getForegroundColor(context)
              : _getDisabledForegroundColor(context),
        );
    }
  }

  void _handlePress() {
    if (hapticFeedback) {
      HapticFeedback.lightImpact();
    }
    onPressed?.call();
  }

  void _handleLongPress() {
    if (hapticFeedback) {
      HapticFeedback.mediumImpact();
    }
    onLongPress?.call();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _isEnabled
        ? _getBackgroundColor(context)
        : _getDisabledBackgroundColor(context);
    final foregroundColor = _isEnabled
        ? _getForegroundColor(context)
        : _getDisabledForegroundColor(context);
    final borderColor = _isEnabled
        ? _getBorderColor(context)
        : _getDisabledBorderColor(context);
    final borderRadius = _getBorderRadius();
    final padding = _getPadding();
    final elevation = _getElevation();

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: _isEnabled ? _handlePress : null,
        onLongPress: _isEnabled && onLongPress != null
            ? _handleLongPress
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: gradient != null
              ? Colors.transparent
              : backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: _getDisabledBackgroundColor(context),
          disabledForegroundColor: _getDisabledForegroundColor(context),
          elevation: elevation,
          shadowColor: shadowColor,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: BorderSide(color: borderColor, width: borderWidth),
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Container(
          decoration: gradient != null
              ? BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(borderRadius),
                )
              : null,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Content
              Opacity(
                opacity: isLoading ? 0.0 : 1.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (prefixIcon != null) ...[
                      prefixIcon!,
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: DefaultTextStyle(
                        style: _getTextStyle(context),
                        child: child,
                      ),
                    ),
                    if (suffixIcon != null) ...[
                      const SizedBox(width: 8),
                      suffixIcon!,
                    ],
                  ],
                ),
              ),
              // Loading indicator
              if (isLoading)
                Positioned.fill(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        foregroundColor,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Utility class with static methods for common button types
class CustomButtonUtils {
  // "I'm Buying" and "I'm Selling" buttons
  static CustomButton categorySelection({
    Key? key,
    required VoidCallback? onPressed,
    required Widget child,
    Color color = AppColors.blueLight,
    bool isLoading = false,
    bool disabled = false,
    double? width,
    bool hapticFeedback = true,
  }) {
    return CustomButton(
      key: key,
      onPressed: onPressed,
      child: child,
      type: ButtonType.outline,
      size: ButtonSize.large,
      isLoading: isLoading,
      disabled: disabled,
      width: width ?? double.infinity,
      height: 60, // Tall height for category buttons
      borderRadius: 16.0, // More rounded corners
      // padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      hapticFeedback: hapticFeedback,
      // elevation: 2.0,
      borderWidth: 2.0, // Thicker border
      backgroundColor: color,
    );
  }

  // "Google" button
  static CustomButton googleSignIn({
    Key? key,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool disabled = false,
    double? width,
    bool hapticFeedback = true,
  }) {
    return CustomButton(
      key: key,
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.g_mobiledata, size: 24), // Placeholder icon
          const SizedBox(width: 12),
          Text(
            'Google',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ],
      ),
      type: ButtonType.outline,
      size: ButtonSize.large,
      isLoading: isLoading,
      disabled: disabled,
      width: width ?? double.infinity,
      height: 56,
      borderRadius: 12.0,
      padding: const EdgeInsets.symmetric(vertical: 16),
      hapticFeedback: hapticFeedback,
      borderWidth: 1.5,
      borderColor: AppColors.greyDim,
      backgroundColor: AppColors.white,

      foregroundColor: Colors.black87,
    );
  }

  // "Apple" button
  static CustomButton appleSignIn({
    Key? key,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool disabled = false,
    double? width,
    bool hapticFeedback = true,
  }) {
    return CustomButton(
      key: key,
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.apple, size: 24), // Apple icon
          const SizedBox(width: 12),
          Text(
            'Apple',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
      type: ButtonType.primary,
      // size: ButtonSize.large,
      isLoading: isLoading,
      disabled: disabled,
      width: width ?? double.infinity,
      height: 56,
      borderRadius: 12.0,
      padding: const EdgeInsets.symmetric(vertical: 16),
      hapticFeedback: hapticFeedback,
      elevation: 0,
      borderWidth: 1.5,
      borderColor: AppColors.greyDim,
      backgroundColor: AppColors.white,

      foregroundColor: AppColors.black,
    );
  }

  static CustomButton login({
    Key? key,
    required String title,
    Color? backgroundColor,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool disabled = false,
    double? width,
    bool hapticFeedback = true,
    EdgeInsetsGeometry? padding,
    double? height,
    Color? color,
    double? borderRadius,
    Widget? child, // ADD THIS
  }) {
    return CustomButton(
      key: key,
      onPressed: onPressed,
      child:
          child ??
          Text(
            // USE CHILD IF PROVIDED, ELSE USE TITLE
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: color ?? AppColors.white,
            ),
          ),
      type: ButtonType.primary,
      // size: ButtonSize.large,
      isLoading: isLoading,
      disabled: disabled,
      width: width ?? double.infinity,
      height: height ?? 50,
      backgroundColor: backgroundColor ?? AppColors.buttonColor,
      borderRadius: borderRadius ?? 15.0,
      // padding: padding ?? EdgeInsets.symmetric(vertical: 16),
      hapticFeedback: hapticFeedback,
      elevation: 4.0,
      borderWidth: 0,
    );
  }

  static CustomButton primary({
    Key? key,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    required Widget child,
    ButtonSize size = ButtonSize.medium,
    bool isLoading = false,
    bool disabled = false,
    double? width,
    double? height,
    double? borderRadius,
    EdgeInsetsGeometry? padding,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool hapticFeedback = true,
    double? elevation,
    Color? shadowColor,
    double borderWidth = 1.0,
    Color? backgroundColor = AppColors.buttonColor,
  }) {
    return CustomButton(
      key: key,

      onPressed: onPressed,
      onLongPress: onLongPress,
      child: child,
      type: ButtonType.primary,
      size: size,
      isLoading: isLoading,
      disabled: disabled,
      width: width,
      height: height,
      borderRadius: borderRadius,
      padding: padding,
      backgroundColor: backgroundColor,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      hapticFeedback: hapticFeedback,
      elevation: elevation,
      shadowColor: shadowColor,
      borderWidth: borderWidth,
    );
  }

  static CustomButton textButton({
    Key? key,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    required Widget child,
    ButtonSize size = ButtonSize.medium,
    bool isLoading = false,
    bool disabled = false,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    Widget? prefixIcon,
    Widget? suffixIcon,
    Color? foregroundColor,
    bool hapticFeedback = true,
  }) {
    return CustomButton(
      key: key,
      onPressed: onPressed,
      onLongPress: onLongPress,
      child: child,
      type: ButtonType.textButton,
      size: size,
      isLoading: isLoading,
      disabled: disabled,
      width: width,
      height: height,
      padding: padding,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      foregroundColor: foregroundColor,
      hapticFeedback: hapticFeedback,
      elevation: 0,
      borderWidth: 0,
    );
  }

  static CustomButton buyButton({
    Key? key,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    required Widget child,
    ButtonSize size = ButtonSize.medium,
    bool isLoading = false,
    bool disabled = false,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    Widget? prefixIcon,
    Widget? suffixIcon,
    Color? foregroundColor,
    bool hapticFeedback = true,
  }) {
    return CustomButton(
      key: key,
      onPressed: onPressed,
      onLongPress: onLongPress,
      child: child,
      type: ButtonType.textButton,
      size: size,
      isLoading: isLoading,
      disabled: disabled,
      width: width,
      height: height,
      padding: padding,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      foregroundColor: foregroundColor,
      hapticFeedback: hapticFeedback,
      elevation: 0,
      borderWidth: 0,
    );
  }
}
