import 'package:flutter/material.dart';
import '../theme/mediasfu_colors.dart';
import '../theme/mediasfu_spacing.dart';

/// A section title with a small gradient accent bar on the left.
///
/// Provides a visual hierarchy cue across all modern modal sections.
class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    required this.isDarkMode,
  });

  /// The section title text.
  final String title;

  /// Whether dark mode is active.
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: MediasfuColors.brandGradient(darkMode: isDarkMode),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: MediasfuSpacing.sm),
        Text(
          title,
          style: TextStyle(
            color:
                isDarkMode ? MediasfuColors.primaryDark : MediasfuColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
