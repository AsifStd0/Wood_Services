import 'package:flutter/material.dart';
import 'package:wood_service/core/theme/app_colors.dart';

// ! End Helper
enum CustomTextType {
  // 🎯 MAIN HEADINGS
  // mainheadingSmall,

  // 🎯 HEADINGS
  headingLarge,
  headingLittleSmall,
  headingLittleLarge,
  headingMedium,
  headingSmall,
  headingXSmall,

  // 🎯 SUBTITLES
  subtitleLarge,
  subtitleMedium,
  subtitleSmall,
  subtitleXSmall,
  // Setting heading
  activityHeading,

  // 🎯 BODY TEXT
  bodyLarge,
  bodyMedium,
  bodyMediumBold,
  bodySmall,
  bodyXSmall,

  // 🎯 CAPTIONS & LABELS
  captionLarge,
  captionMedium,
  captionSmall,
  captionXSmall,

  // 🎯 BUTTON TEXT
  buttonLarge,
  buttonMedium,
  buttonSmall,

  // 🎯 SPECIAL TEXT
  overline,
  label,
  hint,
  error,
  success,
  warning,
  info,
  appbar,

  // 🎯 CUSTOM BUSINESS TEXT
  productTitle,
  productPrice,
  productDescription,
  productCategory,
  sellerName,
  locationText,
  ratingText,
  discountText,

  // 🎯 CHAT & MESSAGING
  chatMessage,
  chatTimestamp,
  chatSender,

  // 🎯 FORM & INPUT
  formLabel,
  formHint,
  formError,
  formSuccess,
}

class CustomText extends StatelessWidget {
  final String text;
  final CustomTextType? type;

  final TextStyle? style;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final bool? softWrap;
  final TextOverflow? overflow;
  final double? textScaleFactor;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;
  final bool? inherit;
  final Color? color;
  final Color? backgroundColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final double? letterSpacing;
  final double? wordSpacing;
  final TextBaseline? textBaseline;
  final double? height;
  final Paint? foreground;
  final Paint? background;
  final List<Shadow>? shadows;
  final List<FontFeature>? fontFeatures;
  final TextDecoration? decoration;
  final Color? decorationColor;
  final TextDecorationStyle? decorationStyle;
  final double? decorationThickness;
  final String? debugLabel;
  final String? fontFamily;
  final List<String>? fontFamilyFallback;
  final String? package;

  const CustomText(
    this.text, {
    super.key,
    this.type = CustomTextType.bodyMedium,
    this.style,
    this.textAlign,
    this.textDirection,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.inherit = true,
    this.color,
    this.backgroundColor,
    this.fontSize,
    this.fontWeight,
    this.fontStyle,
    this.letterSpacing,
    this.wordSpacing,
    this.textBaseline,
    this.height,
    this.foreground,
    this.background,
    this.shadows,
    this.fontFeatures,
    this.decoration,
    this.decorationColor,
    this.decorationStyle,
    this.decorationThickness,
    this.debugLabel,
    this.fontFamily,
    this.fontFamilyFallback,
    this.package,
  });

  TextStyle _getBaseStyle(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    switch (type) {
      // 🎯 MAIN HEADINGS

      // 🎯 HEADINGS
      case CustomTextType.headingLarge:
        return theme.headlineLarge!.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.black,
          letterSpacing: 0.5,
        );
      case CustomTextType.headingLittleLarge:
        return theme.headlineLarge!.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.black,
          fontSize: 24,
          letterSpacing: 0.5,
        );
      case CustomTextType.headingLittleSmall:
        return theme.headlineLarge!.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.black,
          fontSize: 22,
          letterSpacing: 0.5,
        );

      case CustomTextType.headingMedium:
        return theme.headlineMedium!.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        );

      case CustomTextType.headingSmall:
        return theme.headlineSmall!.copyWith(
          fontSize: 18,
          color: AppColors.textSecondary,
          // fontWeight: FontWeight.w600,
        );

      case CustomTextType.headingXSmall:
        return theme.headlineSmall!.copyWith(
          fontSize: 16,
          color: AppColors.textSecondary,

          fontWeight: FontWeight.w500,
        );

      // 🎯 SUBTITLES
      case CustomTextType.subtitleLarge:
        return theme.titleLarge!.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.grey[800],
        );

      case CustomTextType.subtitleMedium:
        return theme.titleMedium!.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.darkGrey,
        );

      case CustomTextType.subtitleSmall:
        return theme.titleSmall!.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.grey[600],
        );

      case CustomTextType.subtitleXSmall:
        return theme.titleSmall!.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.grey[500],
        );

      // 🎯 BODY TEXT
      case CustomTextType.bodyLarge:
        return theme.bodyLarge!.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.normal,
          color: Colors.brown,
        );

      case CustomTextType.activityHeading:
        return theme.bodyLarge!.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          height: 1.5,
        );

      case CustomTextType.bodyMediumBold:
        return theme.bodyMedium!.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          height: 1,
          color: AppColors.black.withOpacity(0.7),
        );
      case CustomTextType.bodyMedium:
        return theme.bodyMedium!.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          height: 1.4,
          color: AppColors.black.withOpacity(0.7),
        );

      case CustomTextType.bodySmall:
        return theme.bodySmall!.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          height: 1.3,
        );

      case CustomTextType.bodyXSmall:
        return theme.bodySmall!.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          height: 1.2,
        );

      // 🎯 CAPTIONS & LABELS
      case CustomTextType.captionLarge:
        return theme.labelLarge!.copyWith(
          fontSize: 14,
          color: Colors.grey[600],
          fontWeight: FontWeight.w400,
        );

      case CustomTextType.captionMedium:
        return theme.labelMedium!.copyWith(
          fontSize: 12,
          color: Colors.grey[600],
          fontWeight: FontWeight.w400,
        );

      case CustomTextType.captionSmall:
        return theme.labelSmall!.copyWith(
          fontSize: 11,
          color: Colors.grey[500],
          fontWeight: FontWeight.w400,
        );

      case CustomTextType.captionXSmall:
        return theme.labelSmall!.copyWith(
          fontSize: 10,
          color: Colors.grey[400],
          fontWeight: FontWeight.w400,
        );

      // 🎯 BUTTON TEXT
      case CustomTextType.buttonLarge:
        return theme.labelLarge!.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        );

      case CustomTextType.buttonMedium:
        return theme.labelLarge!.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.25,
        );

      case CustomTextType.buttonSmall:
        return theme.labelLarge!.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        );

      // 🎯 SPECIAL TEXT
      case CustomTextType.overline:
        return theme.labelSmall!.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.5,
          color: Colors.grey[500],
        );

      case CustomTextType.label:
        return theme.labelMedium!.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colors.onSurface.withOpacity(0.7),
        );

      case CustomTextType.hint:
        return theme.bodyMedium!.copyWith(
          fontSize: 14,
          color: colors.onSurface.withOpacity(0.5),
          fontStyle: FontStyle.italic,
        );

      case CustomTextType.error:
        return theme.bodyMedium!.copyWith(
          fontSize: 14,
          color: colors.error,
          fontWeight: FontWeight.w500,
        );

      case CustomTextType.success:
        return theme.bodyMedium!.copyWith(
          fontSize: 14,
          color: Colors.green[700],
          fontWeight: FontWeight.w500,
        );

      case CustomTextType.warning:
        return theme.bodyMedium!.copyWith(
          fontSize: 14,
          color: Colors.orange[700],
          fontWeight: FontWeight.w500,
        );

      case CustomTextType.info:
        return theme.bodyMedium!.copyWith(
          fontSize: 14,
          color: Colors.blue[700],
          fontWeight: FontWeight.w500,
        );

      case CustomTextType.appbar:
        return theme.bodyMedium!.copyWith(
          fontSize: 20,
          color: Colors.black,
          fontWeight: FontWeight.w600,
        );

      // 🎯 CUSTOM BUSINESS TEXT
      case CustomTextType.productTitle:
        return theme.titleLarge!.copyWith(fontSize: 15, color: AppColors.black);

      case CustomTextType.productPrice:
        return theme.headlineSmall!.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.green[700],
        );

      case CustomTextType.productDescription:
        return theme.bodyMedium!.copyWith(
          fontSize: 14,
          color: Colors.grey[700],
          height: 1.4,
        );

      case CustomTextType.productCategory:
        return theme.labelSmall!.copyWith(
          fontSize: 12,
          color: Colors.blue[600],
          fontWeight: FontWeight.w500,
        );

      case CustomTextType.sellerName:
        return theme.bodyMedium!.copyWith(
          fontSize: 14,
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        );

      case CustomTextType.locationText:
        return theme.bodySmall!.copyWith(
          fontSize: 12,
          color: Colors.grey[500],
          fontStyle: FontStyle.italic,
        );

      case CustomTextType.ratingText:
        return theme.labelSmall!.copyWith(
          fontSize: 12,
          color: Colors.amber[700],
          fontWeight: FontWeight.w600,
        );

      case CustomTextType.discountText:
        return theme.labelSmall!.copyWith(
          fontSize: 11,
          color: Colors.red[600],
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.lineThrough,
        );

      // 🎯 CHAT & MESSAGING
      case CustomTextType.chatMessage:
        return theme.bodyMedium!.copyWith(fontSize: 15, height: 1.3);

      case CustomTextType.chatTimestamp:
        return theme.labelSmall!.copyWith(
          fontSize: 10,
          color: Colors.grey[400],
        );

      case CustomTextType.chatSender:
        return theme.bodySmall!.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.blue[600],
        );

      // 🎯 FORM & INPUT
      case CustomTextType.formLabel:
        return theme.bodyMedium!.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colors.onSurface,
        );

      case CustomTextType.formHint:
        return theme.bodyMedium!.copyWith(
          fontSize: 14,
          color: colors.onSurface.withOpacity(0.5),
        );

      case CustomTextType.formError:
        return theme.bodySmall!.copyWith(
          fontSize: 12,
          color: colors.error,
          fontWeight: FontWeight.w500,
        );

      case CustomTextType.formSuccess:
        return theme.bodySmall!.copyWith(
          fontSize: 12,
          color: Colors.green[600],
          fontWeight: FontWeight.w500,
        );

      default:
        return theme.bodyMedium!.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.normal,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = _getBaseStyle(context);

    return Text(
      text,
      style: baseStyle
          .copyWith(
            color: color ?? baseStyle.color,
            backgroundColor: backgroundColor,
            fontSize: fontSize ?? baseStyle.fontSize,
            fontWeight: fontWeight ?? baseStyle.fontWeight,
            fontStyle: fontStyle ?? baseStyle.fontStyle,
            letterSpacing: letterSpacing ?? baseStyle.letterSpacing,
            wordSpacing: wordSpacing ?? baseStyle.wordSpacing,
            textBaseline: textBaseline ?? baseStyle.textBaseline,
            height: height ?? baseStyle.height,
            foreground: foreground ?? baseStyle.foreground,
            background: background ?? baseStyle.background,
            shadows: shadows ?? baseStyle.shadows,
            fontFeatures: fontFeatures ?? baseStyle.fontFeatures,
            decoration: decoration ?? baseStyle.decoration,
            decorationColor: decorationColor ?? baseStyle.decorationColor,
            decorationStyle: decorationStyle ?? baseStyle.decorationStyle,
            decorationThickness:
                decorationThickness ?? baseStyle.decorationThickness,
            debugLabel: debugLabel ?? baseStyle.debugLabel,
            fontFamily: fontFamily ?? baseStyle.fontFamily,
            fontFamilyFallback:
                fontFamilyFallback ?? baseStyle.fontFamilyFallback,
          )
          .merge(style),
      textAlign: textAlign,
      textDirection: textDirection,
      softWrap: softWrap,
      overflow: overflow,
      textScaleFactor: textScaleFactor,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
    );
  }
}

// // Quick constructors for common use cases
// CustomText.heading(String text, {CustomTextType type = CustomTextType.headingMedium, Color? color}) 
//   : this(text, type: type, color: color);

// CustomText.body(String text, {CustomTextType type = CustomTextType.bodyMedium, Color? color}) 
//   : this(text, type: type, color: color);

// CustomText.caption(String text, {CustomTextType type = CustomTextType.captionMedium, Color? color}) 
//   : this(text, type: type, color: color);

// // With max lines and overflow
// CustomText.ellipsis(String text, {CustomTextType type = CustomTextType.bodyMedium, int maxLines = 1}) 
//   : this(text, type: type, maxLines: maxLines, overflow: TextOverflow.ellipsis);

// // 🎯 HEADINGS
// CustomText("Welcome to AgriMarket", type: CustomTextType.displayLarge),
// CustomText("Fresh Products", type: CustomTextType.mainheadingMedium),
// CustomText("Featured Items", type: CustomTextType.headingSmall),

// // 🎯 PRODUCT RELATED
// CustomText("Organic Apples", type: CustomTextType.productTitle),
// CustomText("Rs. 1200/kg", type: CustomTextType.productPrice),
// CustomText("Fresh organic apples from local farms", type: CustomTextType.productDescription),
// CustomText("Fruits & Vegetables", type: CustomTextType.productCategory),
// CustomText("Farmer Ali Store", type: CustomTextType.sellerName),
// CustomText("Lahore, Punjab", type: CustomTextType.locationText),
// CustomText("4.5 ★", type: CustomTextType.ratingText),
// CustomText("Rs. 1500", type: CustomTextType.discountText),

// // 🎯 BODY TEXT
// CustomText("This is a detailed description of the product with all the features and benefits explained in depth.", 
//   type: CustomTextType.bodyLarge),
// CustomText("Regular body text for paragraphs", type: CustomTextType.bodyMedium),

// // 🎯 CAPTIONS & LABELS
// CustomText("Last updated 2 hours ago", type: CustomTextType.captionMedium),
// CustomText("In Stock", type: CustomTextType.captionSmall),

// // 🎯 SPECIAL STATES
// CustomText("This field is required", type: CustomTextType.error),
// CustomText("Order placed successfully!", type: CustomTextType.success),
// CustomText("Low stock available", type: CustomTextType.warning),
// CustomText("Free delivery available", type: CustomTextType.info),

// // 🎯 BUTTONS
// CustomText("Add to Cart", type: CustomTextType.buttonLarge),
// CustomText("Buy Now", type: CustomTextType.buttonMedium),
// CustomText("View Details", type: CustomTextType.buttonSmall),

// // 🎯 FORM ELEMENTS
// CustomText("Email Address", type: CustomTextType.formLabel),
// CustomText("Enter your email", type: CustomTextType.formHint),
// CustomText("Invalid email format", type: CustomTextType.formError),

// // 🎯 CHAT MESSAGES
// CustomText("Hello, I'm interested in this product", type: CustomTextType.chatMessage),
// CustomText("2:30 PM", type: CustomTextType.chatTimestamp),
// CustomText("Seller Ali", type: CustomTextType.chatSender),

// import 'package:flutter/material.dart';
// import 'package:wood_service/core/theme/app_colors.dart';
