import 'package:flutter/material.dart';
import '../theme/mediasfu_spacing.dart';

/// A subtle card container used for grouped settings rows.
///
/// Consistent styling: semi-transparent background, rounded corners,
/// 1px border, inner padding.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    required this.isDarkMode,
    this.padding,
  });

  /// The card content.
  final Widget child;

  /// Whether dark mode is active.
  final bool isDarkMode;

  /// Custom padding. Defaults to `EdgeInsets.all(MediasfuSpacing.md)`.
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(MediasfuSpacing.md),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
        ),
      ),
      child: child,
    );
  }
}
