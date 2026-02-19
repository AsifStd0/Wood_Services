import 'package:flutter/material.dart';
import 'package:wood_service/views/Seller/data/models/visit_request_model.dart';

/// Centralized color system for the entire application
/// All colors used across Buyer and Seller modules should reference this class
class AppColors {
  // ========== PRIMARY COLORS ==========
  static const Color primary = Color(0xFF795548);
  static const Color primaryDark = Color(0xFF5D4037);
  static const Color primaryLight = Color(0xFFD7CCC8);

  // ========== SECONDARY COLORS ==========
  static const Color secondary = Color(0xFF8D6E63);
  static const Color secondaryDark = Color(0xFF6D4C41);
  static const Color secondaryLight = Color(0xFFBCAAA4);

  // ========== NEUTRAL COLORS ==========
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  // ========== GREY SCALE ==========
  static const Color darkGrey = Color(0xFF333333);
  static const Color greySecondary = Color(0xFF666666);
  static const Color mediumGrey = Color(0xFF999999);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFCCCCCC);
  static const Color extraLightGrey = Color(0xFFF5F5F5);
  static const Color greyLight = Color(0xFFF5F5F5);
  static const Color greyDark = Color(0xFF616161);
  static const Color greyDim = Color(0x999E9E9E);

  // ========== BACKGROUND COLORS ==========
  static const Color background = Color(0xFFFAFAFA);
  static const Color scaffoldBackground = Color(0xFFFFFFFF);

  // ========== TEXT COLORS ==========
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textHint = Color(0xFF999999);

  // ========== STATUS COLORS ==========
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  static const Color redColor = Color(0xFFB62A2A);

  // ========== BORDER COLORS ==========
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF424242);

  // ========== BUTTON COLORS ==========
  static const Color buttonBlue = Color(0xFF1791D0);
  static const Color buttonLightBlue = Color(0xFFC8E3EF);
  static const Color buttonColor = Color(0xFF7E12ED);
  static const Color buttonLavender = Color(0xFFEBDFF7);
  static const Color yellowButton = Color(0xFFFAC808);
  static const Color yellowLight = Color(0xFFEDC064);

  // ========== TEXT FIELD COLORS ==========
  static const Color textFieldBackground = Color(0xFFEBDFF7);
  static const Color textFieldBorder = Color(0xFF7A808A);
  static const Color orangeLight = Color(0xFFF6DCC9);

  // ========== CUSTOM THEME COLORS ==========
  static const Color brightOrange = Color(0xFFFA8232);
  static const Color socialOrange = Color(0xFFF4F8FF);
  static const Color chairBackColor = Color(0xFFF4F8FF);

  // ========== SEMANTIC COLOR ALIASES ==========
  static const Color bluePrimary = Color(0xFF1791D0);
  static const Color blueLight = Color(0xFFC8E3EF);
  static const Color lavender = Color(0xFFEBDFF7);
  static const Color grayMedium = Color(0xFF7A808A);

  // ========== GRADIENT COLORS ==========
  static const Color gradientStart = Color(0xFF667EEA);
  static const Color gradientEnd = Color(0xFF764BA2);
  static const Color primaryColor = Color(0xFF7B61FF);
  static const Color secondaryColor = Color(0xFFFF6B6B);

  // ========== GRADIENT HELPERS ==========
  static LinearGradient get primaryGradient => const LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ========== STATUS COLOR HELPERS ==========
  static Color getStatusColor(VisitStatus status) {
    switch (status) {
      case VisitStatus.pending:
        return Colors.orange;
      case VisitStatus.accepted:
        return success;
      case VisitStatus.rejected:
        return error;
      case VisitStatus.declined:
        return error;
      case VisitStatus.completed:
        return info;
      case VisitStatus.noshow:
        return Colors.purple;
      case VisitStatus.active:
        return warning;
    }
  }

  // ========== SHADOW COLORS ==========
  static Color shadowColor([double opacity = 0.1]) =>
      Colors.black.withOpacity(opacity);
}
