import 'dart:ui';

import 'package:flutter/material.dart';

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
    final bool isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final Color glassColor = isDark
        ? Colors.white.withValues(
            alpha: opacity * 0.10,
          )
        : Colors.white.withValues(
            alpha: opacity,
          );

    final Color borderColor = isDark
        ? Colors.white.withValues(
            alpha: 0.14,
          )
        : Colors.white.withValues(
            alpha: 0.75,
          );

    final Widget glass = ClipRRect(
      borderRadius:
          BorderRadius.circular(
        borderRadius,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: blur,
          sigmaY: blur,
        ),
        child: AnimatedContainer(
          duration:
              const Duration(
            milliseconds: 250,
          ),
          curve: Curves.easeOut,
          width: width,
          height: height,
          padding: padding ??
              const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: glassColor,
            borderRadius:
                BorderRadius.circular(
              borderRadius,
            ),
            border: Border.all(
              color: borderColor,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withValues(
                  alpha:
                      isDark ? 0.20 : 0.06,
                ),
                blurRadius: 22,
                offset:
                    const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    return Padding(
      padding:
          margin ?? EdgeInsets.zero,
      child: onTap == null
          ? glass
          : GestureDetector(
              onTap: onTap,
              behavior:
                  HitTestBehavior.opaque,
              child: glass,
            ),
    );
  }
}