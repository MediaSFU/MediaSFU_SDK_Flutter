// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import '../theme/mediasfu_colors.dart';
import '../theme/mediasfu_animations.dart';

/// A neumorphic container with soft shadow effects creating a 3D raised appearance.
///
/// Supports:
/// - Light and dark mode adaptive shadows
/// - Pressed/inset state
/// - Customizable depth and blur
/// - Interactive press animations
class NeumorphicContainer extends StatefulWidget {
  /// The child widget to display inside the container.
  final Widget child;

  /// Background color of the container. Defaults to theme surface color.
  final Color? backgroundColor;

  /// Border radius for the container corners.
  final double borderRadius;

  /// Padding inside the container.
  final EdgeInsetsGeometry? padding;

  /// Margin around the container.
  final EdgeInsetsGeometry? margin;

  /// The depth of the neumorphic effect (1-3).
  final int depth;

  /// Whether the container appears pressed/inset.
  final bool isPressed;

  /// Whether the container is interactive (responds to taps).
  final bool isInteractive;

  /// Callback when the container is tapped.
  final VoidCallback? onTap;

  /// Callback when the container is long pressed.
  final VoidCallback? onLongPress;

  /// Optional width constraint.
  final double? width;

  /// Optional height constraint.
  final double? height;

  const NeumorphicContainer({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderRadius = 16,
    this.padding,
    this.margin,
    this.depth = 2,
    this.isPressed = false,
    this.isInteractive = false,
    this.onTap,
    this.onLongPress,
    this.width,
    this.height,
  });

  @override
  State<NeumorphicContainer> createState() => _NeumorphicContainerState();
}

class _NeumorphicContainerState extends State<NeumorphicContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: MediasfuAnimations.fast,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: MediasfuAnimations.snappy),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.isInteractive) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.isInteractive) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.isInteractive) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = widget.backgroundColor ??
        (isDark ? MediasfuColors.surfaceDark : MediasfuColors.surface);

    final shadows = _buildShadows(isDark, _isPressed || widget.isPressed);

    Widget container = AnimatedContainer(
      duration: MediasfuAnimations.fast,
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      padding: widget.padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: shadows,
      ),
      child: widget.child,
    );

    if (widget.isInteractive) {
      container = GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: container,
        ),
      );
    }

    return container;
  }

  List<BoxShadow> _buildShadows(bool isDark, bool isPressed) {
    final depth = widget.depth.clamp(1, 3);
    final baseOffset = 4.0 * depth;
    final baseBlur = 8.0 * depth;

    if (isPressed) {
      // Inset/pressed state - inverted shadows
      if (isDark) {
        return [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: baseBlur / 2,
            offset: Offset(-baseOffset / 2, -baseOffset / 2),
          ),
          BoxShadow(
            color: const Color(0xFF2D3A4F).withOpacity(0.2),
            blurRadius: baseBlur / 2,
            offset: Offset(baseOffset / 2, baseOffset / 2),
          ),
        ];
      } else {
        return [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: baseBlur / 2,
            offset: Offset(-baseOffset / 2, -baseOffset / 2),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.5),
            blurRadius: baseBlur / 2,
            offset: Offset(baseOffset / 2, baseOffset / 2),
          ),
        ];
      }
    }

    // Normal raised state
    if (isDark) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.5),
          blurRadius: baseBlur,
          offset: Offset(baseOffset, baseOffset),
        ),
        BoxShadow(
          color: const Color(0xFF2D3A4F).withOpacity(0.3),
          blurRadius: baseBlur,
          offset: Offset(-baseOffset, -baseOffset),
        ),
      ];
    } else {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: baseBlur,
          offset: Offset(baseOffset, baseOffset),
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.8),
          blurRadius: baseBlur,
          offset: Offset(-baseOffset, -baseOffset),
        ),
      ];
    }
  }
}

/// A neumorphic button with press feedback.
class NeumorphicButton extends StatelessWidget {
  /// The child widget (usually text or icon).
  final Widget child;

  /// Callback when pressed.
  final VoidCallback? onPressed;

  /// Background color.
  final Color? backgroundColor;

  /// Border radius.
  final double borderRadius;

  /// Padding inside the button.
  final EdgeInsetsGeometry? padding;

  /// Depth of the neumorphic effect.
  final int depth;

  const NeumorphicButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.borderRadius = 12,
    this.padding,
    this.depth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      isInteractive: true,
      onTap: onPressed,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      depth: depth,
      child: child,
    );
  }
}

/// A circular neumorphic icon button.
class NeumorphicIconButton extends StatelessWidget {
  /// The icon to display.
  final IconData icon;

  /// Callback when pressed.
  final VoidCallback? onPressed;

  /// Size of the button.
  final double size;

  /// Icon size.
  final double iconSize;

  /// Icon color.
  final Color? iconColor;

  /// Background color.
  final Color? backgroundColor;

  /// Depth of the neumorphic effect.
  final int depth;

  const NeumorphicIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 48,
    this.iconSize = 24,
    this.iconColor,
    this.backgroundColor,
    this.depth = 2,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = iconColor ??
        (isDark ? MediasfuColors.textPrimaryDark : MediasfuColors.textPrimary);

    return NeumorphicContainer(
      isInteractive: true,
      onTap: onPressed,
      backgroundColor: backgroundColor,
      borderRadius: size / 2,
      width: size,
      height: size,
      padding: EdgeInsets.zero,
      depth: depth,
      child: Center(
        child: Icon(icon, size: iconSize, color: color),
      ),
    );
  }
}
