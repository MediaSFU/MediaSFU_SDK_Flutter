import 'package:flutter/material.dart';

import '../theme/mediasfu_colors.dart';
import '../theme/mediasfu_spacing.dart';
import '../theme/mediasfu_typography.dart';

/// Elevated gradient card used for hero sections and highlight tiles.
class GradientCard extends StatelessWidget {
  const GradientCard({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.child,
    this.gradient,
    this.onTap,
    this.padding,
  });

  final String? title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Widget? child;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final decoration = BoxDecoration(
      gradient: gradient ?? MediasfuColors.brandGradient(darkMode: isDark),
      borderRadius: BorderRadius.circular(24),
      boxShadow: MediasfuColors.elevation(level: 2, darkMode: isDark),
    );

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: padding ?? MediasfuSpacing.insetAll(MediasfuSpacing.lg),
      decoration: decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null || trailing != null)
            Row(
              children: [
                if (leading != null) leading!,
                const Spacer(),
                if (trailing != null) trailing!,
              ],
            ),
          if (leading != null || trailing != null)
            SizedBox(height: MediasfuSpacing.sm),
          if (title != null)
            Text(
              title!,
              style: MediasfuTypography.headlineLarge.copyWith(
                color: Colors.white,
              ),
            ),
          if (subtitle != null)
            Padding(
              padding: EdgeInsets.only(
                  top: MediasfuSpacing.sm,
                  bottom: child == null ? 0 : MediasfuSpacing.md),
              child: Text(
                subtitle!,
                style: MediasfuTypography.bodyLarge.copyWith(
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
            ),
          if (child != null) child!,
        ],
      ),
    );

    if (onTap == null) return content;

    return GestureDetector(
      onTap: onTap,
      child: content,
    );
  }
}
