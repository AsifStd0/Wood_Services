import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/core/utils/constants.dart';
import 'package:wood_service/core/utils/debouncer.dart';

enum TextFieldType {
  text,
  name,
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
    this.focusNode,
    this.onSubmitted,
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
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final TextInputType? textInputType;
  final int minLength;
  final int minline;
  final TextEditingController? originalPasswordController;
  final FocusNode? focusNode;

  // Validator with confirm password logic
  String? validator(String? value) {
    if (value == null || value.trim().isEmpty) {
      switch (textFieldType) {
        case TextFieldType.name:
          return 'Please enter your name';
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
      case TextFieldType.name:
        final regex = RegExp(r'^[A-Za-z ]+$');
        if (!regex.hasMatch(value)) return 'Name can only contain letters';
        if (value.trim().length < 3)
          return 'Name must be at least 3 characters';
        break;
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
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.greyLight.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextFormField(
                controller: controller,
                focusNode: focusNode,
                onChanged: (text) {
                  _debouncer.run(() {
                    onChanged?.call(text);
                    fieldState.didChange(text);
                  });
                },
                onFieldSubmitted: onSubmitted,
                textAlign: textAlign ?? TextAlign.left,
                obscureText: obscureText ?? false,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                ),
                inputFormatters: inputFormatters ?? [],
                keyboardType: textInputType ?? keyboardType(textFieldType),
                textInputAction: textInputAction,
                minLines: minline,
                maxLines: maxLines,
                maxLength: maxLength,
                enabled: enabled,
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 8,
                  ),
                  hintText: hintText,
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary.withOpacity(0.7),
                    fontSize: 16,
                  ),
                  // Borders
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.grey, width: 0.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.grey, width: 0.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.error,
                      width: 1.0,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.error,
                      width: 1.5,
                    ),
                  ),
                  // Prefix & Suffix icons
                  prefixIcon: prefixIcon != null
                      ? Padding(
                          padding: const EdgeInsets.only(left: 16, right: 12),
                          child: prefixIcon,
                        )
                      : null,
                  prefixIconConstraints: const BoxConstraints(
                    minHeight: 24,
                    minWidth: 24,
                  ),
                  suffixIcon: suffixIcon != null
                      ? Padding(
                          padding: const EdgeInsets.only(right: 16, left: 12),
                          child: suffixIcon,
                        )
                      : null,
                  suffixIconConstraints: const BoxConstraints(
                    minHeight: 24,
                    minWidth: 24,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            if (fieldState.errorText != null)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8),
                child: Text(
                  fieldState.errorText!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
