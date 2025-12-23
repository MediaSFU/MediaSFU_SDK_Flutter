import 'package:flutter/material.dart';

import '../theme/mediasfu_colors.dart';
import '../theme/mediasfu_spacing.dart';

/// Micro-animated icon button used for control surfaces (mic, camera, etc.).
class AnimatedIconButton extends StatefulWidget {
  const AnimatedIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.isActive = false,
    this.tooltip,
    this.size = 24,
    this.duration = const Duration(milliseconds: 220),
    this.backgroundColor,
    this.activeColor,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool isActive;
  final String? tooltip;
  final double size;
  final Duration duration;
  final Color? backgroundColor;
  final Color? activeColor;

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color baseColor = widget.activeColor ?? theme.colorScheme.primary;
    final Color iconColor = widget.isActive
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface.withOpacity(0.8);
    final Color backgroundColor = widget.backgroundColor ??
        (widget.isActive
            ? baseColor
            : theme.colorScheme.surface.withOpacity(isDark ? 0.3 : 0.9));

    final child = AnimatedScale(
      duration: widget.duration,
      scale: _pressed ? 0.94 : 1,
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: widget.duration,
        curve: Curves.easeOut,
        padding: MediasfuSpacing.insetAll(MediasfuSpacing.sm),
        decoration: BoxDecoration(
          color: backgroundColor,
          gradient: widget.isActive
              ? MediasfuColors.brandGradient(darkMode: isDark)
              : null,
          borderRadius: BorderRadius.circular(9999),
          boxShadow: widget.isActive
              ? MediasfuColors.elevation(level: 2, darkMode: isDark)
              : null,
        ),
        child: Icon(
          widget.icon,
          size: widget.size,
          color: widget.isActive ? Colors.white : iconColor,
        ),
      ),
    );

    final button = GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onPressed,
      behavior: HitTestBehavior.translucent,
      child: child,
    );

    if (widget.tooltip == null) {
      return button;
    }

    return Tooltip(
      message: widget.tooltip!,
      child: button,
    );
  }
}
