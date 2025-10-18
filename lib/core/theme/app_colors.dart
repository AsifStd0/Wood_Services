import 'package:flutter/material.dart';

//  Row(
//       children: [
//         Icon(Icons.security_outlined, size: 18, color: AppColors.darkGrey),
//         const SizedBox(width: 8),
//         CustomText(
//           'Secure Banking Details',
//           type: CustomTextType.subtitleMedium,
//           color: AppColors.darkGrey,
//         ),
//       ],
//     ),
//     const SizedBox(height: 4),
//     CustomText(
//       'Your information is encrypted and secure. We need this for seller payouts',
//       type: CustomTextType.hint,
//       color: AppColors.grey,
//     ),
//     const SizedBox(height: 8),
//     CustomTextFormField(

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF795548);
  static const Color primaryDark = Color(0xFF5D4037);
  static const Color primaryLight = Color(0xFFD7CCC8);

  // Grey Scale Colors
  static const Color darkGrey = Color(
    0xFF333333,
  ); // For text and important elements
  static const Color greySecondry = Color(0xFF666666); // For secondary text
  static const Color mediumGrey = Color(
    0xFF999999,
  ); // For hints and disabled states
  static const Color lightGrey = Color(0xFFCCCCCC); // For borders and dividers
  static const Color extraLightGrey = Color(0xFFF5F5F5); // For backgrounds

  // Secondary colors
  static const Color secondary = Color(0xFF8D6E63);
  static const Color secondaryDark = Color(0xFF6D4C41);
  static const Color secondaryLight = Color(0xFFBCAAA4);

  // Neutral colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static Color greyDim = Colors.grey.withOpacity(0.6);
  static const Color greyLight = Color(0xFFF5F5F5);
  static const Color greyDark = Color(0xFF616161);

  // Background colors
  static const Color background = Color(0xFFFAFAFA);

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFFFFFFF);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Border colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF424242);

  // Custom theme colors (added)
  static const Color buttonBlue = Color(0xFF1791D0); // For buttons
  static const Color buttonLightBlue = Color(0xFFC8E3EF); // Lighter variant

  // TextField theme colors
  static const Color textFieldBackground = Color(0xFFEBDFF7);
  static const Color textFieldBorder = Color(0xFF7A808A);

  // Additional custom colors
  static const brightOrange = Color(0xffFA8232);
  static const socialOrange = Color(0xffF4F8FF);
  static const chairBackColor = Color(0xffF4F8FF);

  // NEW COLORS ADDED FROM YOUR REQUEST
  static const Color color1791d0 = Color(0xFF1791D0);
  static const Color colorC8e3ef = Color(0xFFC8E3EF);
  static const Color colorEbdff7 = Color(0xFFEBDFF7);
  static const Color color7a808a = Color(0xFF7A808A);

  // You can also create semantic names for these new colors:
  static const Color bluePrimary = Color(0xFF1791D0);
  static const Color blueLight = Color(0xFFC8E3EF);
  static const Color lavender = Color(0xFFEBDFF7);
  static const Color grayMedium = Color(0xFF7A808A);

  // ! ****
  static const Color buttonColor = Color(0xFF7E12ED);
  // ! textfield
  static const Color orangeLight = Color(0xFFF6DCC9);

  static const Color buttonLavender = Color(0xFFEBDFF7);
}
