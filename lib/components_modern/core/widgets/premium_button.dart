// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/mediasfu_colors.dart';
import '../theme/mediasfu_animations.dart';
import '../theme/mediasfu_spacing.dart';
import '../theme/modern_style_options.dart';

/// Style variants for [PremiumButton].
enum PremiumButtonVariant {
  /// Filled/solid button with background color.
  filled,

  /// Outlined button with border and transparent background.
  outlined,

  /// Ghost/text button with no background or border.
  ghost,

  /// Gradient button with gradient background.
  gradient,

  /// Glass/frosted button with blur effect.
  glass,

  /// Glow button with glowing effect.
  glow,

  /// Neumorphic button with soft 3D effect.
  neumorphic,
}

/// Size presets for [PremiumButton].
enum PremiumButtonSize {
  /// Extra small: 28px height.
  xs,

  /// Small: 32px height.
  sm,

  /// Medium (default): 40px height.
  md,

  /// Large: 48px height.
  lg,

  /// Extra large: 56px height.
  xl,
}

/// A premium button component with modern styling and animations.
///
/// Features:
/// - Multiple style variants (filled, outlined, ghost, gradient, glass, glow, neumorphic)
/// - Size presets (xs, sm, md, lg, xl)
/// - Icon support (leading and trailing)
/// - Loading state with spinner
/// - Disabled state
/// - Press and hover animations
/// - Haptic feedback support
/// - Full customization via [ModernStyleOptions]
///
/// Example usage:
/// ```dart
/// PremiumButton(
///   label: 'Continue',
///   variant: PremiumButtonVariant.gradient,
///   size: PremiumButtonSize.lg,
///   leadingIcon: Icons.arrow_forward,
///   onPressed: () => handleContinue(),
/// )
/// ```
class PremiumButton extends StatefulWidget {
  /// Button label text.
  final String? label;

  /// Child widget (alternative to label).
  final Widget? child;

  /// Icon to display before the label.
  final IconData? leadingIcon;

  /// Icon to display after the label.
  final IconData? trailingIcon;

  /// Custom leading widget.
  final Widget? leading;

  /// Custom trailing widget.
  final Widget? trailing;

  /// Callback when button is pressed.
  final VoidCallback? onPressed;

  /// Callback when button is long pressed.
  final VoidCallback? onLongPress;

  /// Style variant.
  final PremiumButtonVariant variant;

  /// Size preset.
  final PremiumButtonSize size;

  /// Whether the button is in loading state.
  final bool isLoading;

  /// Whether the button is disabled.
  final bool isDisabled;

  /// Primary color for the button.
  final Color? color;

  /// Text color.
  final Color? textColor;

  /// Custom gradient (for gradient variant).
  final Gradient? gradient;

  /// Border radius override.
  final double? borderRadius;

  /// Whether to use full-width button.
  final bool fullWidth;

  /// Custom width.
  final double? width;

  /// Custom height.
  final double? height;

  /// Custom padding.
  final EdgeInsetsGeometry? padding;

  /// Custom elevation.
  final double elevation;

  /// Whether to enable haptic feedback.
  final bool hapticFeedback;

  /// Whether to use dark mode styling.
  final bool isDarkMode;

  /// Scale factor when pressed.
  final double pressedScale;

  /// Duration of press animation.
  final Duration animationDuration;

  /// Custom style options.
  final ModernStyleOptions? styleOptions;

  /// Tooltip text.
  final String? tooltip;

  const PremiumButton({
    super.key,
    this.label,
    this.child,
    this.leadingIcon,
    this.trailingIcon,
    this.leading,
    this.trailing,
    this.onPressed,
    this.onLongPress,
    this.variant = PremiumButtonVariant.filled,
    this.size = PremiumButtonSize.md,
    this.isLoading = false,
    this.isDisabled = false,
    this.color,
    this.textColor,
    this.gradient,
    this.borderRadius,
    this.fullWidth = false,
    this.width,
    this.height,
    this.padding,
    this.elevation = 0,
    this.hapticFeedback = true,
    this.isDarkMode = true,
    this.pressedScale = 0.96,
    this.animationDuration = const Duration(milliseconds: 150),
    this.styleOptions,
    this.tooltip,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pressedScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isEnabled =>
      !widget.isDisabled && !widget.isLoading && widget.onPressed != null;

  double get _height {
    if (widget.height != null) return widget.height!;
    switch (widget.size) {
      case PremiumButtonSize.xs:
        return 28;
      case PremiumButtonSize.sm:
        return 32;
      case PremiumButtonSize.md:
        return 40;
      case PremiumButtonSize.lg:
        return 48;
      case PremiumButtonSize.xl:
        return 56;
    }
  }

  double get _fontSize {
    switch (widget.size) {
      case PremiumButtonSize.xs:
        return 12;
      case PremiumButtonSize.sm:
        return 13;
      case PremiumButtonSize.md:
        return 14;
      case PremiumButtonSize.lg:
        return 15;
      case PremiumButtonSize.xl:
        return 16;
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case PremiumButtonSize.xs:
        return 14;
      case PremiumButtonSize.sm:
        return 16;
      case PremiumButtonSize.md:
        return 18;
      case PremiumButtonSize.lg:
        return 20;
      case PremiumButtonSize.xl:
        return 22;
    }
  }

  EdgeInsetsGeometry get _padding {
    if (widget.padding != null) return widget.padding!;
    switch (widget.size) {
      case PremiumButtonSize.xs:
        return const EdgeInsets.symmetric(horizontal: 10, vertical: 4);
      case PremiumButtonSize.sm:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case PremiumButtonSize.md:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case PremiumButtonSize.lg:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 10);
      case PremiumButtonSize.xl:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    }
  }

  double get _borderRadius {
    if (widget.borderRadius != null) return widget.borderRadius!;
    switch (widget.size) {
      case PremiumButtonSize.xs:
        return 6;
      case PremiumButtonSize.sm:
        return 8;
      case PremiumButtonSize.md:
        return 10;
      case PremiumButtonSize.lg:
        return 12;
      case PremiumButtonSize.xl:
        return 14;
    }
  }

  Color get _primaryColor {
    return widget.color ?? MediasfuColors.primary;
  }

  Color get _textColor {
    if (widget.textColor != null) return widget.textColor!;

    switch (widget.variant) {
      case PremiumButtonVariant.filled:
      case PremiumButtonVariant.gradient:
      case PremiumButtonVariant.glow:
        return Colors.white;
      case PremiumButtonVariant.outlined:
      case PremiumButtonVariant.ghost:
        return _primaryColor;
      case PremiumButtonVariant.glass:
        return widget.isDarkMode ? Colors.white : Colors.black87;
      case PremiumButtonVariant.neumorphic:
        return widget.isDarkMode ? Colors.white70 : Colors.black87;
    }
  }

  BoxDecoration _buildDecoration() {
    final borderRadius = BorderRadius.circular(_borderRadius);

    switch (widget.variant) {
      case PremiumButtonVariant.filled:
        return BoxDecoration(
          color:
              _isEnabled ? _primaryColor : _primaryColor.withOpacity(0.5),
          borderRadius: borderRadius,
          boxShadow: widget.elevation > 0
              ? [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.3),
                    blurRadius: widget.elevation * 2,
                    offset: Offset(0, widget.elevation),
                  ),
                ]
              : null,
        );

      case PremiumButtonVariant.outlined:
        return BoxDecoration(
          color: _isPressed
              ? _primaryColor.withOpacity(0.1)
              : (_isHovered
                  ? _primaryColor.withOpacity(0.05)
                  : Colors.transparent),
          borderRadius: borderRadius,
          border: Border.all(
            color: _isEnabled
                ? _primaryColor
                : _primaryColor.withOpacity(0.5),
            width: 1.5,
          ),
        );

      case PremiumButtonVariant.ghost:
        return BoxDecoration(
          color: _isPressed
              ? _primaryColor.withOpacity(0.15)
              : (_isHovered
                  ? _primaryColor.withOpacity(0.08)
                  : Colors.transparent),
          borderRadius: borderRadius,
        );

      case PremiumButtonVariant.gradient:
        final gradient = widget.gradient ??
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _primaryColor,
                MediasfuColors.secondary,
              ],
            );
        return BoxDecoration(
          gradient: _isEnabled
              ? gradient
              : LinearGradient(
                  colors: gradient.colors
                      .map((c) => c.withOpacity(0.5))
                      .toList(),
                ),
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withOpacity(_isPressed ? 0.4 : 0.25),
              blurRadius: _isPressed ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        );

      case PremiumButtonVariant.glass:
        return BoxDecoration(
          color: widget.isDarkMode
              ? Colors.white.withOpacity(_isPressed ? 0.15 : 0.1)
              : Colors.black.withOpacity(_isPressed ? 0.08 : 0.05),
          borderRadius: borderRadius,
          border: Border.all(
            color: widget.isDarkMode
                ? Colors.white.withOpacity(0.2)
                : Colors.black.withOpacity(0.1),
            width: 1,
          ),
        );

      case PremiumButtonVariant.glow:
        return BoxDecoration(
          color: _primaryColor,
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withOpacity(_isPressed ? 0.6 : 0.4),
              blurRadius: _isPressed ? 20 : 16,
              spreadRadius: _isPressed ? 2 : 1,
            ),
            BoxShadow(
              color: _primaryColor.withOpacity(0.3),
              blurRadius: 8,
            ),
          ],
        );

      case PremiumButtonVariant.neumorphic:
        final baseColor = widget.isDarkMode
            ? MediasfuColors.surfaceDark
            : MediasfuColors.surface;
        return BoxDecoration(
          color: baseColor,
          borderRadius: borderRadius,
          boxShadow: _isPressed
              ? [
                  // Inset shadows for pressed state
                  BoxShadow(
                    color: widget.isDarkMode
                        ? const Color(0xFF0A0A12)
                        : const Color(0xFFD1D9E6),
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                  ),
                  BoxShadow(
                    color: widget.isDarkMode
                        ? const Color(0xFF404060)
                        : Colors.white,
                    offset: const Offset(-2, -2),
                    blurRadius: 4,
                  ),
                ]
              : [
                  // Raised shadows for normal state
                  BoxShadow(
                    color: widget.isDarkMode
                        ? const Color(0xFF404060).withOpacity(0.4)
                        : Colors.white.withOpacity(0.8),
                    offset: const Offset(-4, -4),
                    blurRadius: 8,
                  ),
                  BoxShadow(
                    color: widget.isDarkMode
                        ? const Color(0xFF0A0A12).withOpacity(0.6)
                        : const Color(0xFFD1D9E6).withOpacity(0.6),
                    offset: const Offset(4, 4),
                    blurRadius: 8,
                  ),
                ],
        );
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (!_isEnabled) return;
    setState(() => _isPressed = true);
    _controller.forward();
    if (widget.hapticFeedback) {
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTap() {
    if (_isEnabled) {
      widget.onPressed!();
    }
  }

  Widget _buildContent() {
    final color = _isEnabled ? _textColor : _textColor.withOpacity(0.5);

    if (widget.isLoading) {
      return SizedBox(
        width: _iconSize,
        height: _iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    final List<Widget> children = [];

    // Leading
    if (widget.leading != null) {
      children.add(widget.leading!);
      children.add(SizedBox(width: MediasfuSpacing.xs));
    } else if (widget.leadingIcon != null) {
      children.add(Icon(widget.leadingIcon, size: _iconSize, color: color));
      children.add(SizedBox(width: MediasfuSpacing.xs));
    }

    // Label or child
    if (widget.child != null) {
      children.add(widget.child!);
    } else if (widget.label != null) {
      children.add(Text(
        widget.label!,
        style: TextStyle(
          fontSize: _fontSize,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.3,
        ),
      ));
    }

    // Trailing
    if (widget.trailing != null) {
      children.add(SizedBox(width: MediasfuSpacing.xs));
      children.add(widget.trailing!);
    } else if (widget.trailingIcon != null) {
      children.add(SizedBox(width: MediasfuSpacing.xs));
      children.add(Icon(widget.trailingIcon, size: _iconSize, color: color));
    }

    return Row(
      mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget button = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor:
          _isEnabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: _handleTap,
        onLongPress: _isEnabled ? widget.onLongPress : null,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: widget.fullWidth ? double.infinity : widget.width,
                height: _height,
                padding: _padding,
                decoration: _buildDecoration(),
                child: Center(child: _buildContent()),
              ),
            );
          },
        ),
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}

/// A circular icon button with premium styling.
class PremiumIconButton extends StatefulWidget {
  /// The icon to display.
  final IconData icon;

  /// Callback when button is pressed.
  final VoidCallback? onPressed;

  /// Size of the button.
  final double size;

  /// Icon size.
  final double? iconSize;

  /// Background color.
  final Color? backgroundColor;

  /// Icon color.
  final Color? iconColor;

  /// Style variant.
  final PremiumButtonVariant variant;

  /// Whether to use dark mode.
  final bool isDarkMode;

  /// Whether the button is disabled.
  final bool isDisabled;

  /// Tooltip text.
  final String? tooltip;

  /// Whether to enable haptic feedback.
  final bool hapticFeedback;

  const PremiumIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 44,
    this.iconSize,
    this.backgroundColor,
    this.iconColor,
    this.variant = PremiumButtonVariant.filled,
    this.isDarkMode = true,
    this.isDisabled = false,
    this.tooltip,
    this.hapticFeedback = true,
  });

  @override
  State<PremiumIconButton> createState() => _PremiumIconButtonState();
}

class _PremiumIconButtonState extends State<PremiumIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isEnabled => !widget.isDisabled && widget.onPressed != null;

  Color get _bgColor {
    if (widget.backgroundColor != null) return widget.backgroundColor!;

    switch (widget.variant) {
      case PremiumButtonVariant.filled:
      case PremiumButtonVariant.gradient:
      case PremiumButtonVariant.glow:
        return MediasfuColors.primary;
      case PremiumButtonVariant.outlined:
      case PremiumButtonVariant.ghost:
        return Colors.transparent;
      case PremiumButtonVariant.glass:
        return widget.isDarkMode
            ? Colors.white.withOpacity(0.1)
            : Colors.black.withOpacity(0.05);
      case PremiumButtonVariant.neumorphic:
        return widget.isDarkMode
            ? MediasfuColors.surfaceDark
            : MediasfuColors.surface;
    }
  }

  Color get _fgColor {
    if (widget.iconColor != null) return widget.iconColor!;

    switch (widget.variant) {
      case PremiumButtonVariant.filled:
      case PremiumButtonVariant.gradient:
      case PremiumButtonVariant.glow:
        return Colors.white;
      case PremiumButtonVariant.outlined:
      case PremiumButtonVariant.ghost:
        return MediasfuColors.primary;
      case PremiumButtonVariant.glass:
      case PremiumButtonVariant.neumorphic:
        return widget.isDarkMode ? Colors.white70 : Colors.black87;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget button = GestureDetector(
      onTapDown: (_) {
        if (!_isEnabled) return;
        setState(() => _isPressed = true);
        _controller.forward();
        if (widget.hapticFeedback) HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTap: _isEnabled ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isEnabled ? _bgColor : _bgColor.withOpacity(0.5),
                border: widget.variant == PremiumButtonVariant.outlined
                    ? Border.all(color: MediasfuColors.primary, width: 1.5)
                    : null,
                boxShadow: widget.variant == PremiumButtonVariant.glow
                    ? MediasfuColors.glowShadow(
                        _bgColor,
                        intensity: _isPressed ? 0.5 : 0.3,
                      )
                    : null,
              ),
              child: Center(
                child: Icon(
                  widget.icon,
                  size: widget.iconSize ?? widget.size * 0.5,
                  color:
                      _isEnabled ? _fgColor : _fgColor.withOpacity(0.5),
                ),
              ),
            ),
          );
        },
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(message: widget.tooltip!, child: button);
    }

    return button;
  }
}
