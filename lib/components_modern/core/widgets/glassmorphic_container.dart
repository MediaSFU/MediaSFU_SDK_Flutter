import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/mediasfu_colors.dart';
import '../theme/mediasfu_spacing.dart';

/// Reusable frosted glass surface used for overlays and floating UI.
class GlassmorphicContainer extends StatelessWidget {
  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.blur = 16,
    this.padding,
    this.gradient,
    this.onTap,
  });

  final Widget child;
  final double borderRadius;
  final double blur;
  final EdgeInsets? padding;
  final Gradient? gradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final decoration = BoxDecoration(
      gradient: gradient ??
          LinearGradient(
            colors: [
              MediasfuColors.glassBackground(darkMode: isDark),
              MediasfuColors.glassBackground(darkMode: isDark).withOpacity(0.4),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
      border: Border.all(
        color: MediasfuColors.glassBorder(darkMode: isDark),
        width: 1,
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: MediasfuColors.elevation(level: 1, darkMode: isDark),
    );

    final content = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: padding ?? MediasfuSpacing.insetAll(MediasfuSpacing.md),
          decoration: decoration,
          child: child,
        ),
      ),
    );

    if (onTap == null) return content;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: content,
    );
  }
}
