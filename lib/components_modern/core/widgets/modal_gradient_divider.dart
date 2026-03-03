import 'package:flutter/material.dart';
import '../theme/mediasfu_colors.dart';
import '../theme/mediasfu_spacing.dart';

/// A horizontal gradient divider used between modal sections.
///
/// Renders a 1px line that fades from transparent through the brand
/// accent colours and back to transparent, giving a premium feel.
class ModalGradientDivider extends StatelessWidget {
  const ModalGradientDivider({
    super.key,
    this.isDarkMode = true,
    this.margin,
  });

  /// Whether dark mode is active.
  final bool isDarkMode;

  /// Custom margin. Defaults to horizontal `MediasfuSpacing.lg`.
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: margin ??
          const EdgeInsets.symmetric(horizontal: MediasfuSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            (isDarkMode ? MediasfuColors.primaryDark : MediasfuColors.primary)
                .withOpacity(0.4),
            (isDarkMode ? MediasfuColors.secondary : MediasfuColors.accent)
                .withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
