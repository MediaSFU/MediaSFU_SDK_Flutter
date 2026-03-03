import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/mediasfu_colors.dart';
import '../theme/mediasfu_spacing.dart';

/// A full-width gradient action button for modern modal footers.
///
/// Provides consistent styling with:
/// - Brand gradient background
/// - Glow shadow below
/// - Ink ripple feedback
/// - Haptic tap
/// - Disabled state
class ModalFooterButton extends StatelessWidget {
  const ModalFooterButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.isDarkMode,
    this.gradientColors,
    this.isEnabled = true,
    this.icon,
  });

  /// Button label text.
  final String label;

  /// Called when tapped (and `isEnabled` is true).
  final VoidCallback onPressed;

  /// Whether dark mode is active.
  final bool isDarkMode;

  /// Custom gradient colours. Defaults to `[primary, secondary]`.
  final List<Color>? gradientColors;

  /// Whether the button is enabled.
  final bool isEnabled;

  /// Optional leading icon.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ??
        [MediasfuColors.primary, MediasfuColors.secondary];

    return Container(
      padding: const EdgeInsets.all(MediasfuSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDarkMode
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isEnabled
              ? () {
                  HapticFeedback.lightImpact();
                  onPressed();
                }
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: MediasfuSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isEnabled
                    ? colors
                    : [Colors.grey.shade600, Colors.grey.shade500],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: isEnabled
                  ? [
                      BoxShadow(
                        color: colors.first.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 18),
                  const SizedBox(width: MediasfuSpacing.sm),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withOpacity(isEnabled ? 1.0 : 0.6),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
