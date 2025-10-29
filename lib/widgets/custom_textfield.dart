import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wood_service/core/theme/app_colors.dart';
import 'package:wood_service/core/utils/debouncer.dart';

// With default validation (existing behavior)
// CustomTextFormField.email(
//   controller: emailController,
// );

// // Without any validation
// CustomTextFormField.email(
//   controller: emailController,
//   validate: false,
// );

// With custom validator
// CustomTextFormField.email(
//   controller: emailController,
//   validator: (value) {
//     if (value?.contains('test') ?? false) {
//       return 'Test emails are not allowed';
//     }
//     return null;
//   },
// );

// Search field without validation (default)
// CustomTextFormField.compactSearch(
//   controller: searchController,
//   hintText: 'Search...',
// );

// Search field with validation
// CustomTextFormField.compactSearch(
//   controller: searchController,
//   hintText: 'Search...',
//   validate: true,
//   validator: (value) {
//     if (value?.length ?? 0 < 3) {
//       return 'Enter at least 3 characters';
//     }
//     return null;
//   },
// );
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
    this.fillcolor,
    this.contentPadding,
    this.isCompact = false,
    this.validator, // New: Optional custom validator
    this.validate = true, // New: Toggle validation on/off
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
  final bool validate; // New: Enable/disable validation
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
  final String? Function(String?)? validator; // New: Custom validator

  // Validator with confirm password logic
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

  // Combined validator that uses custom validator or default validator
  String? _validator(String? value) {
    // If validation is disabled, return null (no error)
    if (!validate) return null;

    // Use custom validator if provided
    if (validator != null) {
      return validator!(value);
    }

    // Use default validator
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

    final EdgeInsetsGeometry effectiveContentPadding =
        contentPadding ??
        (isCompact
            ? const EdgeInsets.symmetric(vertical: 12, horizontal: 16)
            : const EdgeInsets.symmetric(vertical: 18, horizontal: 18));

    return FormField<String>(
      validator: _validator, // Use the combined validator
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
                isDense: true,
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
                // Borders
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
                // Prefix & Suffix icons
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

  // Password field with visibility toggle
  static CustomTextFormField password({
    Key? key,
    TextEditingController? controller,
    String? hintText = 'Password',
    ValueChanged<String>? onChanged,
    FocusNode? focusNode,
    ValueChanged<String>? onSubmitted,
    bool enabled = true,
    bool validate = true, // New: optional validation
    String? Function(String?)? validator, // New: custom validator
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
      obscureText: true,
      validate: validate,
      validator: validator,
      prefixIcon: Icon(Icons.lock_outline, color: AppColors.grey, size: 20),
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
    bool validate = true, // New: optional validation
    String? Function(String?)? validator, // New: custom validator
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
      prefixIcon: Icon(
        Icons.email_outlined,
        color: AppColors.color7a808a,
        size: 20,
      ),
    );
  }

  // Phone number field
  static CustomTextFormField phone({
    Key? key,
    TextEditingController? controller,
    String? hintText = 'Phone Number',
    ValueChanged<String>? onChanged,
    FocusNode? focusNode,
    ValueChanged<String>? onSubmitted,
    bool enabled = true,
    bool validate = true, // New: optional validation
    String? Function(String?)? validator, // New: custom validator
  }) {
    return CustomTextFormField(
      key: key,
      controller: controller,
      textFieldType: TextFieldType.phoneNumber,
      hintText: hintText,
      onChanged: onChanged,
      focusNode: focusNode,
      onSubmitted: onSubmitted,
      enabled: enabled,
      validate: validate,
      validator: validator,
      prefixIcon: Icon(
        Icons.phone_outlined,
        color: AppColors.color7a808a,
        size: 20,
      ),
    );
  }

  // Name field
  static CustomTextFormField name({
    Key? key,
    TextEditingController? controller,
    String? hintText = 'Full Name',
    ValueChanged<String>? onChanged,
    FocusNode? focusNode,
    ValueChanged<String>? onSubmitted,
    bool enabled = true,
    bool validate = true, // New: optional validation
    String? Function(String?)? validator, // New: custom validator
  }) {
    return CustomTextFormField(
      key: key,
      controller: controller,
      textFieldType: TextFieldType.name,
      hintText: hintText,
      onChanged: onChanged,
      focusNode: focusNode,
      onSubmitted: onSubmitted,
      enabled: enabled,
      validate: validate,
      validator: validator,
      prefixIcon: Icon(
        Icons.person_outline,
        color: AppColors.color7a808a,
        size: 20,
      ),
    );
  }

  // Compact search field with smaller height
  static CustomTextFormField compactSearch({
    Key? key,
    TextEditingController? controller,
    String? hintText = 'Type a message...',
    ValueChanged<String>? onChanged,
    FocusNode? focusNode,
    ValueChanged<String>? onSubmitted,
    bool enabled = true,
    Widget? suffixIcon,
    bool validate = false, // Default: no validation for search
    String? Function(String?)? validator, // Custom validator if needed
  }) {
    return CustomTextFormField(
      key: key,
      controller: controller,
      textFieldType: TextFieldType.text,
      hintText: hintText,
      onChanged: onChanged,
      focusNode: focusNode,
      onSubmitted: onSubmitted,
      enabled: enabled,
      isCompact: true,
      validate: validate,
      validator: validator,
      suffixIcon: suffixIcon,
    );
  }

  // Regular search field
  static CustomTextFormField search({
    Key? key,
    TextEditingController? controller,
    String? hintText = 'Search...',
    ValueChanged<String>? onChanged,
    FocusNode? focusNode,
    ValueChanged<String>? onSubmitted,
    bool enabled = true,
    bool validate = false, // Default: no validation for search
    String? Function(String?)? validator, // Custom validator if needed
  }) {
    return CustomTextFormField(
      key: key,
      controller: controller,
      textFieldType: TextFieldType.text,
      hintText: hintText,
      onChanged: onChanged,
      focusNode: focusNode,
      onSubmitted: onSubmitted,
      enabled: enabled,
      validate: validate,
      validator: validator,
      prefixIcon: Icon(Icons.search, color: AppColors.color7a808a, size: 20),
    );
  }

  // Simple text field
  static CustomTextFormField text({
    Key? key,
    TextEditingController? controller,
    String? hintText,
    ValueChanged<String>? onChanged,
    FocusNode? focusNode,
    ValueChanged<String>? onSubmitted,
    bool enabled = true,
    Widget? prefixIcon,
    Widget? suffixIcon,
    int maxLines = 1,
    bool isCompact = false,
    bool validate = true, // New: optional validation
    String? Function(String?)? validator, // New: custom validator
  }) {
    return CustomTextFormField(
      key: key,
      controller: controller,
      textFieldType: TextFieldType.text,
      hintText: hintText,
      onChanged: onChanged,
      focusNode: focusNode,
      onSubmitted: onSubmitted,
      enabled: enabled,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      maxLines: maxLines,
      isCompact: isCompact,
      validate: validate,
      validator: validator,
    );
  }
}
// enum TextFieldType {
//   text,
//   name,
//   email,
//   password,
//   confrimpassword,
//   phoneNumber,
//   number,
//   alphabet,
// }

// class CustomTextFormField extends StatelessWidget {
//   final _debouncer = Debouncer(milliseconds: 500);

//   CustomTextFormField({
//     super.key,
//     this.controller,
//     this.textFieldType = TextFieldType.text,
//     this.hintText,
//     this.helperText,
//     this.onChanged,
//     this.maxLength,
//     this.suffixIcon,
//     this.prefixIcon,
//     this.obscureText = false,
//     this.maxLines = 1,
//     this.helperMaxLines,
//     this.textAlign = TextAlign.left,
//     this.inputFormatters,
//     this.enabled = true,
//     this.textInputAction,
//     this.textInputType,
//     this.minLength = 1,
//     this.minline = 1,
//     this.originalPasswordController,
//     this.focusNode,
//     this.onSubmitted,
//     this.fillcolor,
//     this.contentPadding,
//   });

//   final TextEditingController? controller;
//   final TextFieldType textFieldType;
//   final String? hintText;
//   final String? helperText;
//   final Widget? suffixIcon;
//   final Widget? prefixIcon;
//   final bool? obscureText;
//   final int? maxLines;
//   final int? helperMaxLines;
//   final int? maxLength;
//   final TextAlign? textAlign;
//   final List<TextInputFormatter>? inputFormatters;
//   final bool enabled;

//   final Color? fillcolor;
//   final EdgeInsetsGeometry? contentPadding;
//   final ValueChanged<String>? onChanged;
//   final ValueChanged<String>? onSubmitted;
//   final TextInputAction? textInputAction;
//   final TextInputType? textInputType;
//   final int minLength;
//   final int minline;
//   final TextEditingController? originalPasswordController;
//   final FocusNode? focusNode;

//   // Validator with confirm password logic
//   String? validator(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       switch (textFieldType) {
//         case TextFieldType.name:
//           return 'Please enter your name';
//         case TextFieldType.email:
//           return 'Please enter your email';
//         case TextFieldType.password:
//           return 'Please enter your password';
//         case TextFieldType.confrimpassword:
//           return 'Please confirm your password';
//         case TextFieldType.phoneNumber:
//           return 'Please enter your phone number';
//         case TextFieldType.number:
//           return 'Please enter a number';
//         case TextFieldType.alphabet:
//           return 'Please enter text';
//         case TextFieldType.text:
//           return 'Please enter your name';
//       }
//     }

//     switch (textFieldType) {
//       case TextFieldType.name:
//         final regex = RegExp(r'^[A-Za-z ]+$');
//         if (!regex.hasMatch(value)) return 'Name can only contain letters';
//         if (value.trim().length < 3)
//           return 'Name must be at least 3 characters';
//         break;
//       case TextFieldType.alphabet:
//         final regex = RegExp(r'^[A-Za-z_ .,]+$');
//         if (!regex.hasMatch(value)) return 'Invalid data format';
//         break;
//       case TextFieldType.email:
//         final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
//         if (!regex.hasMatch(value)) return 'Invalid email address format';
//         break;
//       case TextFieldType.password:
//         if (value.trim().isEmpty) return 'Please enter your password';
//         if (value.trim().length < 8) {
//           return 'Password must be more than 8 characters';
//         }
//         return null;
//       case TextFieldType.confrimpassword:
//         if (value.length < 8) return 'Password must be more than 8 characters';
//         if (originalPasswordController != null &&
//             value != originalPasswordController!.text) {
//           return 'Passwords do not match';
//         }
//         break;
//       case TextFieldType.phoneNumber:
//         final regex = RegExp(r'^[0-9]+$');
//         if (value.length < 8 || !regex.hasMatch(value)) {
//           return 'Invalid phone number format';
//         }
//         break;

//       case TextFieldType.number:
//         final regex = RegExp(r'^[0-9]+$');
//         if (!regex.hasMatch(value)) return 'Invalid number format';
//         break;

//       case TextFieldType.text:
//         if (value.length < minLength) return 'Data is too short';
//         break;
//     }

//     return null;
//   }

//   TextInputType keyboardType(TextFieldType textFieldType) {
//     switch (textFieldType) {
//       case TextFieldType.alphabet:
//         return TextInputType.text;
//       case TextFieldType.email:
//         return TextInputType.emailAddress;
//       case TextFieldType.number:
//         return TextInputType.number;
//       case TextFieldType.password:
//         return TextInputType.text;
//       case TextFieldType.phoneNumber:
//         return TextInputType.phone;
//       case TextFieldType.text:
//       default:
//         return TextInputType.text;
//     }
//   }

//   @override
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return FormField<String>(
//       validator: validator,
//       autovalidateMode: AutovalidateMode.onUserInteraction,
//       builder: (fieldState) {
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // REMOVE the Container with shadow and use TextFormField directly
//             TextFormField(
//               controller: controller,
//               focusNode: focusNode,
//               onChanged: (text) {
//                 _debouncer.run(() {
//                   onChanged?.call(text);
//                   fieldState.didChange(text);
//                 });
//               },
//               onFieldSubmitted: onSubmitted,
//               textAlign: textAlign ?? TextAlign.left,
//               obscureText: obscureText ?? false,
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 fontSize: 15,
//                 color: Colors.black,
//                 fontWeight: FontWeight.w400,
//               ),
//               inputFormatters: inputFormatters ?? [],
//               keyboardType: textInputType ?? keyboardType(textFieldType),
//               textInputAction: textInputAction,
//               minLines: minline,
//               maxLines: maxLines,
//               maxLength: maxLength,
//               enabled: enabled,
//               decoration: InputDecoration(
//                 isDense: true,
//                 filled: true,
//                 fillColor: fillcolor ?? AppColors.white,
//                 contentPadding:
//                     contentPadding ??
//                     const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
//                 hintText: hintText,
//                 hintStyle: theme.textTheme.bodyMedium!.copyWith(
//                   fontSize: 15,
//                   color: Theme.of(
//                     context,
//                   ).colorScheme.onSurface.withOpacity(0.5),
//                   // fontStyle: FontStyle.italic,
//                 ),

//                 // theme.textTheme.bodyMedium?.copyWith(
//                 //   color: AppColors.textSecondary.withOpacity(0.7),
//                 //   fontSize: 16,
//                 // ),
//                 // Borders
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12), // Reduced radius
//                   borderSide: BorderSide(
//                     color: AppColors.grey.withOpacity(0.6),
//                     width: 1,
//                   ),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12), // Reduced radius
//                   borderSide: BorderSide(
//                     color: AppColors.grey.withOpacity(0.6),
//                     width: 1,
//                   ),
//                 ),
//                 errorBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12), // Reduced radius
//                   borderSide: const BorderSide(
//                     color: AppColors.error,
//                     width: 1.0,
//                   ),
//                 ),
//                 focusedErrorBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12), // Reduced radius
//                   borderSide: const BorderSide(
//                     color: AppColors.error,
//                     width: 1.5,
//                   ),
//                 ),
//                 // Prefix & Suffix icons
//                 prefixIcon: prefixIcon != null
//                     ? Padding(
//                         padding: const EdgeInsets.only(left: 16, right: 12),
//                         child: prefixIcon,
//                       )
//                     : null,
//                 prefixIconConstraints: const BoxConstraints(
//                   minHeight: 24,
//                   minWidth: 24,
//                 ),
//                 suffixIcon: suffixIcon != null
//                     ? Padding(
//                         padding: const EdgeInsets.only(right: 16, left: 12),
//                         child: suffixIcon,
//                       )
//                     : null,
//                 suffixIconConstraints: const BoxConstraints(
//                   minHeight: 24,
//                   minWidth: 24,
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12), // Reduced radius
//                   borderSide: BorderSide(
//                     color: AppColors.grey.withOpacity(0.6),
//                     width: 1,
//                   ),
//                 ),
//               ),
//             ),
//             if (fieldState.errorText != null)
//               Padding(
//                 padding: const EdgeInsets.only(left: 16, top: 8),
//                 child: Text(
//                   fieldState.errorText!,
//                   style: theme.textTheme.bodySmall?.copyWith(
//                     color: AppColors.error,
//                     fontSize: 12,
//                   ),
//                 ),
//               ),
//           ],
//         );
//       },
//     );
//   }

//   // Password field with visibility toggle
//   static CustomTextFormField password({
//     Key? key,
//     TextEditingController? controller,
//     String? hintText = 'Password',
//     ValueChanged<String>? onChanged,
//     FocusNode? focusNode,
//     ValueChanged<String>? onSubmitted,
//     bool enabled = true,
//   }) {
//     return CustomTextFormField(
//       key: key,
//       controller: controller,
//       textFieldType: TextFieldType.password,
//       hintText: hintText,
//       onChanged: onChanged,
//       focusNode: focusNode,
//       onSubmitted: onSubmitted,
//       enabled: enabled,
//       obscureText: true,
//       prefixIcon: Icon(Icons.lock_outline, color: AppColors.grey, size: 20),
//     );
//   }

//   // Email field
//   static CustomTextFormField email({
//     Key? key,
//     TextEditingController? controller,
//     String? hintText = 'Email',
//     ValueChanged<String>? onChanged,
//     FocusNode? focusNode,
//     ValueChanged<String>? onSubmitted,
//     bool enabled = true,
//   }) {
//     return CustomTextFormField(
//       key: key,
//       controller: controller,
//       textFieldType: TextFieldType.email,
//       hintText: hintText,
//       onChanged: onChanged,
//       focusNode: focusNode,
//       onSubmitted: onSubmitted,
//       enabled: enabled,

//       prefixIcon: Icon(
//         Icons.email_outlined,
//         color: AppColors.color7a808a,
//         size: 20,
//       ),
//     );
//   }

//   // Phone number field
//   static CustomTextFormField phone({
//     Key? key,
//     TextEditingController? controller,
//     String? hintText = 'Phone Number',
//     ValueChanged<String>? onChanged,
//     FocusNode? focusNode,
//     ValueChanged<String>? onSubmitted,
//     bool enabled = true,
//   }) {
//     return CustomTextFormField(
//       key: key,
//       controller: controller,
//       textFieldType: TextFieldType.phoneNumber,
//       hintText: hintText,
//       onChanged: onChanged,
//       focusNode: focusNode,
//       onSubmitted: onSubmitted,
//       enabled: enabled,
//       prefixIcon: Icon(
//         Icons.phone_outlined,
//         color: AppColors.color7a808a,
//         size: 20,
//       ),
//     );
//   }

//   // Name field
//   static CustomTextFormField name({
//     Key? key,
//     TextEditingController? controller,
//     String? hintText = 'Full Name',
//     ValueChanged<String>? onChanged,
//     FocusNode? focusNode,
//     ValueChanged<String>? onSubmitted,
//     bool enabled = true,
//   }) {
//     return CustomTextFormField(
//       key: key,
//       controller: controller,
//       textFieldType: TextFieldType.name,
//       hintText: hintText,
//       onChanged: onChanged,
//       focusNode: focusNode,
//       onSubmitted: onSubmitted,
//       enabled: enabled,
//       prefixIcon: Icon(
//         Icons.person_outline,
//         color: AppColors.color7a808a,
//         size: 20,
//       ),
//     );
//   }

//   // Search field (for future use)
//   static CustomTextFormField search({
//     Key? key,
//     TextEditingController? controller,
//     String? hintText = 'Search...',
//     ValueChanged<String>? onChanged,
//     FocusNode? focusNode,
//     ValueChanged<String>? onSubmitted,
//     bool enabled = true,
//   }) {
//     return CustomTextFormField(
//       key: key,
//       controller: controller,
//       textFieldType: TextFieldType.text,
//       hintText: hintText,
//       onChanged: onChanged,
//       focusNode: focusNode,
//       onSubmitted: onSubmitted,
//       enabled: enabled,
//       prefixIcon: Icon(Icons.search, color: AppColors.color7a808a, size: 20),
//     );
//   }

//   // Simple text field
//   static CustomTextFormField text({
//     Key? key,
//     TextEditingController? controller,
//     String? hintText,
//     ValueChanged<String>? onChanged,
//     FocusNode? focusNode,
//     ValueChanged<String>? onSubmitted,
//     bool enabled = true,
//     Widget? prefixIcon,
//     Widget? suffixIcon,
//     int maxLines = 1,
//   }) {
//     return CustomTextFormField(
//       key: key,
//       controller: controller,
//       textFieldType: TextFieldType.text,
//       hintText: hintText,
//       onChanged: onChanged,
//       focusNode: focusNode,
//       onSubmitted: onSubmitted,
//       enabled: enabled,
//       prefixIcon: prefixIcon,
//       suffixIcon: suffixIcon,
//       maxLines: maxLines,
//     );
//   }
// }
