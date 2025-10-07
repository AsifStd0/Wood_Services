import 'package:flutter/material.dart';
import 'package:wood_service/core/theme/app_colors.dart';

enum CustomTextType {
  mainheadingLarge,
  headingMedium,
  headingSmall,
  subtitle,
  body,
  caption,
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
    this.type = CustomTextType.body,
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

    switch (type) {
      case CustomTextType.mainheadingLarge:
        return theme.headlineLarge!.copyWith(
          fontSize: 26,
          color: AppColors.black,
          fontWeight: FontWeight.bold,
        );

      case CustomTextType.headingMedium:
        return theme.headlineMedium!.copyWith(
          fontSize: 26,
          fontWeight: FontWeight.w600,
        );
      case CustomTextType.headingSmall:
        return theme.headlineSmall!.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        );
      case CustomTextType.subtitle:
        return theme.titleMedium!.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        );
      case CustomTextType.caption:
        return theme.labelSmall!.copyWith(
          fontSize: 12,
          color: Colors.grey[600],
        );
      case CustomTextType.body:
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
            // package: package ?? baseStyle.package,
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
