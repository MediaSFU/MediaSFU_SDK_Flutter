import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/mediasfu_colors.dart';

/// A premium toggle switch with gradient fill when active.
///
/// 50×28 track, 24×24 knob, animated position + colour.
/// Includes haptic feedback on toggle.
class ModernSwitch extends StatelessWidget {
  const ModernSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.isDarkMode = true,
    this.semanticLabel,
  });

  /// Current toggle state.
  final bool value;

  /// Called when the user toggles the switch.
  final ValueChanged<bool> onChanged;

  /// Whether dark mode is active.
  final bool isDarkMode;

  /// Accessibility label (e.g. "Display audiographs toggle").
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      toggled: value,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onChanged(!value);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          width: 50,
          height: 28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: value
                ? LinearGradient(
                    colors: [
                      MediasfuColors.primary,
                      MediasfuColors.secondary,
                    ],
                  )
                : null,
            color: value
                ? null
                : (isDarkMode
                    ? Colors.white.withOpacity(0.2)
                    : Colors.black.withOpacity(0.2)),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                left: value ? 24 : 2,
                top: 2,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
