import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 18,
    this.opacity = 0.65,
    this.borderRadius = 20,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // In light mode the panel has to stay nearly opaque. A translucent white
    // panel over a near-white canvas produced no edge and no depth, so cards
    // were invisible; the floor of 0.75 keeps the panel solid enough to read
    // against the tinted page while still honouring a caller asking for more.
    final Color glassColor = isDark
        ? Colors.white.withValues(alpha: opacity * 0.10)
        : Colors.white.withValues(alpha: opacity.clamp(0.75, 1.0));

    final Color borderColor = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : AppColors.cardBorder;

    final Widget glass = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: glassColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor),
            boxShadow: [
              // Light mode gets a soft brand-tinted shadow instead of grey.
              // Grey shadow under a blue-tinted card looked like dirt; this
              // reads as the card lifting off the page.
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.20)
                    : AppColors.primary.withValues(alpha: 0.10),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          // Material widgets paint their background and ink splashes on the
          // nearest Material ancestor rather than on the nearest decorated box.
          // Without this transparent surface a ListTile inside the panel would
          // have its ripples painted behind the glass colour, and Flutter warns
          // about it in debug builds. The ambient text style is passed through
          // so wrapping the child changes nothing else about it.
          child: Material(
            type: MaterialType.transparency,
            textStyle: DefaultTextStyle.of(context).style,
            child: child,
          ),
        ),
      ),
    );

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: onTap == null
          ? glass
          : GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: glass,
            ),
    );
  }
}
