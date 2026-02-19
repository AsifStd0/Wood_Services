import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wood_service/core/theme/app_colors.dart';
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
  businessName,
  contactName,
  address,
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
    this.fillcolor,
    this.contentPadding,
    this.isCompact = false,
    this.validator,
    this.validate = true,
    this.isDialogField = false, // NEW: Add this parameter
    this.initialValue,
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
  final bool isCompact;
  final bool validate;
  final bool isDialogField; // NEW: For compact dialog fields
  final Color? fillcolor;
  final EdgeInsetsGeometry? contentPadding;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final TextInputType? textInputType;
  final int minLength;
  final int minline;
  final TextEditingController? originalPasswordController;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final String? initialValue;

  String? _defaultValidator(String? value) {
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
        case TextFieldType.businessName:
          return 'Please enter your business name';
        case TextFieldType.contactName:
          return 'Please enter your contact name';
        case TextFieldType.address:
          return 'Please enter your address';
        case TextFieldType.text:
          return 'Please enter text';
      }
    }

    switch (textFieldType) {
      case TextFieldType.name:
        final regex = RegExp(r'^[A-Za-z ]+$');
        if (!regex.hasMatch(value)) return 'Name can only contain letters';
        if (value.trim().length < 3) {
          return 'Name must be at least 3 characters';
        }
        break;

      case TextFieldType.businessName:
        if (value.trim().length < 3) {
          return 'Business name must be at least 3 characters';
        }
        break;

      case TextFieldType.contactName:
        final regex = RegExp(r'^[A-Za-z ]+$');
        if (!regex.hasMatch(value)) {
          return 'Contact name can only contain letters';
        }
        if (value.trim().length < 3) {
          return 'Contact name must be at least 3 characters';
        }
        break;

      case TextFieldType.address:
        if (value.trim().length < 5) {
          return 'Address must be at least 5 characters';
        }
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
        if (value.trim().length < 4) {
          return 'Password must be more than 8 characters';
        }
        break;

      case TextFieldType.confrimpassword:
        if (value.trim().length < 4) {
          return 'Password must be more than 8 characters';
        }
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

  String? _validator(String? value) {
    if (!validate) return null;
    if (validator != null) {
      return validator!(value);
    }
    return _defaultValidator(value);
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

    // FIXED: Proper padding calculation
    final EdgeInsetsGeometry effectiveContentPadding = isDialogField
        ? const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 12,
          ) // Compact for dialogs
        : contentPadding ??
              (isCompact
                  ? const EdgeInsets.symmetric(vertical: 12, horizontal: 16)
                  : const EdgeInsets.symmetric(vertical: 16, horizontal: 16));

    // FIXED: For dialog fields, use simple TextFormField without wrappers
    if (isDialogField) {
      return TextFormField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,

        onFieldSubmitted: onSubmitted,
        textAlign: textAlign ?? TextAlign.left,
        obscureText: obscureText ?? false,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontSize: 14,
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
        initialValue: initialValue,

        decoration: InputDecoration(
          alignLabelWithHint: true,

          isDense: true, // THIS FIXES THE HEIGHT
          filled: fillcolor != null,
          fillColor: fillcolor ?? AppColors.white,
          contentPadding: effectiveContentPadding,
          hintText: hintText,
          hintStyle: theme.textTheme.bodyMedium!.copyWith(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: AppColors.grey.withOpacity(0.6),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: AppColors.grey.withOpacity(0.6),
              width: 1,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.error, width: 1.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: AppColors.grey.withOpacity(0.6),
              width: 1,
            ),
          ),
        ),
      );
    }

    // Original code for non-dialog fields
    return FormField<String>(
      validator: _validator,
      autovalidateMode: validate
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      builder: (fieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
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
                fontSize: isCompact ? 14 : 15,
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
                isDense: true, // Added this
                filled: true,
                fillColor: fillcolor ?? AppColors.white,
                contentPadding: effectiveContentPadding,
                hintText: hintText,
                hintStyle: theme.textTheme.bodyMedium!.copyWith(
                  fontSize: isCompact ? 14 : 15,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isCompact ? 10 : 12),
                  borderSide: BorderSide(
                    color: AppColors.grey.withOpacity(0.6),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isCompact ? 10 : 12),
                  borderSide: BorderSide(
                    color: AppColors.grey.withOpacity(0.6),
                    width: 1,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isCompact ? 10 : 12),
                  borderSide: const BorderSide(
                    color: AppColors.error,
                    width: 1.0,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isCompact ? 10 : 12),
                  borderSide: const BorderSide(
                    color: AppColors.error,
                    width: 1.5,
                  ),
                ),
                prefixIcon: prefixIcon != null
                    ? Padding(
                        padding: EdgeInsets.only(
                          left: isCompact ? 12 : 16,
                          right: isCompact ? 8 : 12,
                        ),
                        child: prefixIcon,
                      )
                    : null,
                prefixIconConstraints: BoxConstraints(
                  minHeight: isCompact ? 20 : 24,
                  minWidth: isCompact ? 20 : 24,
                ),
                suffixIcon: suffixIcon != null
                    ? Padding(
                        padding: EdgeInsets.only(
                          right: isCompact ? 12 : 16,
                          left: isCompact ? 8 : 12,
                        ),
                        child: suffixIcon,
                      )
                    : null,
                suffixIconConstraints: BoxConstraints(
                  minHeight: isCompact ? 20 : 24,
                  minWidth: isCompact ? 20 : 24,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isCompact ? 10 : 12),
                  borderSide: BorderSide(
                    color: AppColors.grey.withOpacity(0.6),
                    width: 1,
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

  static CustomTextFormField password({
    Key? key,
    TextEditingController? controller,
    String? hintText = 'Password',
    ValueChanged<String>? onChanged,
    FocusNode? focusNode,
    ValueChanged<String>? onSubmitted,
    bool enabled = true,
    bool validate = true,
    String? Function(String?)? validator,
    Widget? suffixIcon, // ADD THIS
    bool? obscureText, // ADD THIS
  }) {
    return CustomTextFormField(
      key: key,
      controller: controller,
      textFieldType: TextFieldType.password,
      hintText: hintText,
      onChanged: onChanged,
      focusNode: focusNode,
      onSubmitted: onSubmitted,
      enabled: enabled,
      obscureText: obscureText ?? true, // USE PROVIDED VALUE OR DEFAULT TO TRUE
      validate: validate,
      validator: validator,
      prefixIcon: Icon(Icons.lock_outline, color: AppColors.grey, size: 20),
      suffixIcon: suffixIcon, // PASS THE SUFFIX ICON
    );
  }

  // Email field
  static CustomTextFormField email({
    Key? key,
    TextEditingController? controller,
    String? hintText = 'Email',
    ValueChanged<String>? onChanged,
    FocusNode? focusNode,
    ValueChanged<String>? onSubmitted,
    bool enabled = true,
    bool validate = true,
    String? Function(String?)? validator,
  }) {
    return CustomTextFormField(
      key: key,
      controller: controller,
      textFieldType: TextFieldType.email,
      hintText: hintText,
      onChanged: onChanged,
      focusNode: focusNode,
      onSubmitted: onSubmitted,
      enabled: enabled,
      validate: validate,
      validator: validator,
      prefixIcon: Icon(Icons.email_outlined, color: AppColors.grey, size: 20),
    );
  }

  // NEW: Special compact field for dialogs
  static CustomTextFormField dialog({
    Key? key,
    TextEditingController? controller,
    String? hintText,
    ValueChanged<String>? onChanged,
    FocusNode? focusNode,
    bool enabled = true,
  }) {
    return CustomTextFormField(
      key: key,
      controller: controller,
      textFieldType: TextFieldType.text,
      hintText: hintText,
      onChanged: onChanged,
      focusNode: focusNode,
      enabled: enabled,
      isDialogField: true, // Use the new dialog mode
      validate: false, // Usually no validation needed in dialogs
    );
  }
}
