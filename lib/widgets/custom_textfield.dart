import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/core/utils/constants.dart';
import 'package:wood_service/core/utils/debouncer.dart';

enum TextFieldType {
  text,
  email,
  password,
  confrimpassword,
  phoneNumber,
  number,
  alphabet,
}

class CustomTextFormField extends StatelessWidget {
  final _debouncer = Debouncer(milliseconds: 500);

  CustomTextFormField({
    super.key,
    this.controller,
    this.textFieldType = TextFieldType.text,
    this.hintText,
    this.helperText,
    this.onChanged,
    this.maxLength,
    this.suffixIcon,
    this.prefixIcon,
    this.obscureText = false,
    this.maxLines = 1,
    this.helperMaxLines,
    this.textAlign = TextAlign.left,
    this.inputFormatters,
    this.enabled = true,
    this.textInputAction,
    this.textInputType,
    this.minLength = 1,
    this.minline = 1,
    this.originalPasswordController,
  });

  final TextEditingController? controller;
  final TextFieldType textFieldType;
  final String? hintText;
  final String? helperText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool? obscureText;
  final int? maxLines;
  final int? helperMaxLines;
  final int? maxLength;
  final TextAlign? textAlign;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final TextInputType? textInputType;
  final int minLength;
  final int minline;
  final TextEditingController? originalPasswordController;

  // Validator with confirm password logic
  String? validator(String? value) {
    if (value == null || value.trim().isEmpty) {
      switch (textFieldType) {
        case TextFieldType.email:
          return 'Please enter your email';
        case TextFieldType.password:
          return 'Please enter your password';
        case TextFieldType.confrimpassword:
          return 'Please confirm your password';
        case TextFieldType.phoneNumber:
          return 'Please enter your phone number';
        case TextFieldType.number:
          return 'Please enter a number';
        case TextFieldType.alphabet:
          return 'Please enter text';
        case TextFieldType.text:
          return 'Please enter your name';
      }
    }

    switch (textFieldType) {
      case TextFieldType.alphabet:
        final regex = RegExp(r'^[A-Za-z_ .,]+$');
        if (!regex.hasMatch(value)) return 'Invalid data format';
        break;
      case TextFieldType.email:
        final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!regex.hasMatch(value)) return 'Invalid email address format';
        break;
      case TextFieldType.password:
        if (value.trim().isEmpty) return 'Please enter your password';
        if (value.trim().length < 8) {
          return 'Password must be more than 8 characters';
        }
        return null;
      case TextFieldType.confrimpassword:
        if (value.length < 8) return 'Password must be more than 8 characters';
        if (originalPasswordController != null &&
            value != originalPasswordController!.text) {
          return 'Passwords do not match';
        }
        break;
      case TextFieldType.phoneNumber:
        final regex = RegExp(r'^[0-9]+$');
        if (value.length < 8 || !regex.hasMatch(value)) {
          return 'Invalid phone number format';
        }
        break;

      case TextFieldType.number:
        final regex = RegExp(r'^[0-9]+$');
        if (!regex.hasMatch(value)) return 'Invalid number format';
        break;

      case TextFieldType.text:
        if (value.length < minLength) return 'Data is too short';
        break;
    }

    return null;
  }

  TextInputType keyboardType(TextFieldType textFieldType) {
    switch (textFieldType) {
      case TextFieldType.alphabet:
        return TextInputType.text;
      case TextFieldType.email:
        return TextInputType.emailAddress;
      case TextFieldType.number:
        return TextInputType.number;
      case TextFieldType.password:
        return TextInputType.text;
      case TextFieldType.phoneNumber:
        return TextInputType.phone;
      case TextFieldType.text:
      default:
        return TextInputType.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FormField<String>(
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (fieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    // ! color: Color(0xffD6D2B5),
                    blurRadius: 0,
                    offset: Offset(4, 5),
                  ),
                ],
              ),
              child: TextFormField(
                controller: controller,
                onChanged: (text) {
                  _debouncer.run(() {
                    onChanged?.call(text);
                    fieldState.didChange(text);
                  });
                },
                textAlign: textAlign ?? TextAlign.left,
                obscureText: obscureText ?? false,
                style: theme.textTheme.bodyMedium,
                inputFormatters: inputFormatters ?? [],
                keyboardType: textInputType ?? keyboardType(textFieldType),
                textInputAction: textInputAction,
                minLines: minline,
                maxLines: maxLines,
                maxLength: maxLength,
                enabled: enabled,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  hintText: hintText,
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  enabled: enabled,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.greyLight,
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: theme.primaryColor, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(
                      color: AppColors.error,
                      width: 2,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.error,
                      width: 2,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: AppColors.greyLight,
                      width: 2,
                    ),
                  ),
                  prefixIcon: prefixIcon != null
                      ? Padding(
                          padding: const EdgeInsets.only(left: 12, right: 8),
                          child: prefixIcon,
                        )
                      : null,
                  prefixIconConstraints: const BoxConstraints(
                    minHeight: 24,
                    minWidth: 24,
                  ),
                  suffixIcon: suffixIcon != null
                      ? Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: suffixIcon,
                        )
                      : null,
                  suffixIconConstraints: const BoxConstraints(
                    minHeight: 24,
                    minWidth: 24,
                  ),
                  helperMaxLines: helperMaxLines,
                  helperText: helperText,
                  helperStyle: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.error,
                  ),
                  errorStyle: const TextStyle(height: 0),
                  border: InputBorder.none,
                ),
              ),
            ),
            if (fieldState.errorText != null)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 6),
                child: Text(
                  fieldState.errorText!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
