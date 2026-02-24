import 'package:flutter/material.dart';
import 'package:wood_service/Responsive/responsive_config.dart';
import 'package:wood_service/Responsive/screen_utils.dart';

/// Responsive Container Widget
/// Automatically adjusts padding based on screen size
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final Decoration? decoration;
  final double? width;
  final double? height;
  final Alignment? alignment;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
    this.width,
    this.height,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenType = ResponsiveConfig.getScreenType(screenWidth);

    return Container(
      width: width != null ? ScreenUtils.w(width!) : null,
      height: height != null ? ScreenUtils.h(height!) : null,
      padding: padding ?? EdgeInsets.all(screenType.padding),
      margin: margin,
      color: color,
      decoration: decoration,
      alignment: alignment,
      child: child,
    );
  }
}

/// Responsive Padding Widget
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? all;
  final double? horizontal;
  final double? vertical;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.padding,
    this.all,
    this.horizontal,
    this.vertical,
    this.top,
    this.bottom,
    this.left,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    EdgeInsets? finalPadding;

    if (padding != null) {
      finalPadding = padding;
    } else if (all != null) {
      finalPadding = ScreenUtils.paddingAll(all!);
    } else {
      finalPadding = ScreenUtils.paddingOnly(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
      );
      if (horizontal != null || vertical != null) {
        finalPadding = ScreenUtils.paddingSym(h: horizontal, v: vertical);
      }
    }

    return Padding(padding: finalPadding ?? EdgeInsets.zero, child: child);
  }
}

/// Responsive SizedBox Widget
class ResponsiveSizedBox extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget? child;

  const ResponsiveSizedBox({super.key, this.width, this.height, this.child});

  ResponsiveSizedBox.square({super.key, required double size, this.child})
    : width = size,
      height = size;

  ResponsiveSizedBox.fromSize({super.key, required Size size, this.child})
    : width = size.width,
      height = size.height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width != null ? ScreenUtils.w(width!) : null,
      height: height != null ? ScreenUtils.h(height!) : null,
      child: child,
    );
  }
}

/// Responsive Text Widget
class ResponsiveText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextStyle? style;
  final double? letterSpacing;
  final double? lineHeight;

  const ResponsiveText(
    this.text, {
    super.key,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.style,
    this.letterSpacing,
    this.lineHeight,
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle = TextStyle(
      fontSize: fontSize != null ? ScreenUtils.sp(fontSize!) : null,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: lineHeight,
    );

    return Text(
      text,
      style: style?.merge(defaultStyle) ?? defaultStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Responsive Grid View Builder
class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;
  final EdgeInsets? padding;
  final int? crossAxisCount;
  final ScrollPhysics? physics;

  const ResponsiveGridView({
    super.key,
    required this.children,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 8.0,
    this.childAspectRatio = 1.0,
    this.padding,
    this.crossAxisCount,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenType = ResponsiveConfig.getScreenType(screenWidth);

    return GridView.builder(
      padding: padding ?? ScreenUtils.paddingAll(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount ?? screenType.columns,
        crossAxisSpacing: ScreenUtils.spaceH(crossAxisSpacing),
        mainAxisSpacing: ScreenUtils.spaceV(mainAxisSpacing),
        childAspectRatio: childAspectRatio,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
      physics: physics,
    );
  }
}

/// Responsive Row Widget with spacing
class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;
  final MainAxisSize mainAxisSize;

  const ResponsiveRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.spacing = 0,
    this.mainAxisSize = MainAxisSize.max,
  });

  @override
  Widget build(BuildContext context) {
    if (spacing == 0) {
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: children,
      );
    }

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: _buildChildrenWithSpacing(),
    );
  }

  List<Widget> _buildChildrenWithSpacing() {
    final List<Widget> spacedChildren = [];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(ResponsiveSizedBox(width: spacing));
      }
    }
    return spacedChildren;
  }
}

/// Responsive Column Widget with spacing
class ResponsiveColumn extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;
  final MainAxisSize mainAxisSize;

  const ResponsiveColumn({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.spacing = 0,
    this.mainAxisSize = MainAxisSize.max,
  });

  @override
  Widget build(BuildContext context) {
    if (spacing == 0) {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: children,
      );
    }

    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: _buildChildrenWithSpacing(),
    );
  }

  List<Widget> _buildChildrenWithSpacing() {
    final List<Widget> spacedChildren = [];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(ResponsiveSizedBox(height: spacing));
      }
    }
    return spacedChildren;
  }
}

/// Responsive Safe Area Widget
class ResponsiveSafeArea extends StatelessWidget {
  final Widget child;
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;

  const ResponsiveSafeArea({
    super.key,
    required this.child,
    this.top = true,
    this.bottom = true,
    this.left = true,
    this.right = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: child,
    );
  }
}
