import 'package:flutter/material.dart';
import '../theme/mediasfu_colors.dart';
import '../theme/mediasfu_spacing.dart';

/// Reusable modal header with gradient icon, title, and close button.
///
/// Provides a consistent look across all modern modals:
/// - Gradient-filled icon container with glow shadow
/// - Bold title
/// - Close button with ink ripple, tooltip, and minimum 48×48 touch target
class ModalHeader extends StatelessWidget {
  const ModalHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.onClose,
    required this.isDarkMode,
    this.gradientColors,
    this.subtitle,
    this.trailing,
  });

  /// The icon displayed in the gradient container.
  final IconData icon;

  /// The title text.
  final String title;

  /// Called when the close button is tapped.
  final VoidCallback onClose;

  /// Whether dark mode is active.
  final bool isDarkMode;

  /// Custom gradient colours for the icon container.
  /// Defaults to `[primary, primary.withOpacity(0.7)]`.
  final List<Color>? gradientColors;

  /// Optional subtitle shown below the title in a smaller, muted style.
  final String? subtitle;

  /// Optional widget placed between the title and close button
  /// (e.g. a count badge).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final accent = gradientColors?.first ?? MediasfuColors.primary;
    final colors = gradientColors ??
        [MediasfuColors.primary, MediasfuColors.primary.withOpacity(0.7)];

    return Container(
      padding: const EdgeInsets.all(MediasfuSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDarkMode
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          // Gradient icon
          Container(
            padding: const EdgeInsets.all(MediasfuSpacing.sm),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: MediasfuSpacing.sm),

          // Title + optional subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.white54 : Colors.black45,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Optional trailing widget (e.g. count badge)
          if (trailing != null) ...[
            const SizedBox(width: MediasfuSpacing.sm),
            trailing!,
          ],

          // Close button — Material ripple + 48×48 touch target
          Tooltip(
            message: 'Close',
            decoration: MediasfuColors.tooltipDecoration(darkMode: isDarkMode),
            textStyle: TextStyle(
              color: MediasfuColors.tooltipText(darkMode: isDarkMode),
              fontSize: 12,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onClose,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isDarkMode ? Colors.white : Colors.black)
                        .withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (isDarkMode ? Colors.white : Colors.black)
                          .withOpacity(0.06),
                    ),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
