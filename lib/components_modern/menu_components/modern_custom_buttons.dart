import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/mediasfu_colors.dart';
import '../core/theme/mediasfu_spacing.dart';
import '../core/theme/mediasfu_animations.dart';

/// `ModernCustomButton` - Defines options for each button within `ModernCustomButtons`.
///
/// A modern glassmorphic button definition with gradient backgrounds,
/// icons, text, and optional custom content.
class ModernCustomButton {
  final VoidCallback action;
  final bool show;
  final Color? backgroundColor;
  final Color? gradientStartColor;
  final Color? gradientEndColor;
  final bool disabled;
  final IconData? icon;
  final TextStyle? textStyle;
  final String? text;
  final Widget? customComponent;
  final Color? iconColor;
  final double? iconSize;
  final bool enableGlow;

  ModernCustomButton({
    required this.action,
    this.show = true,
    this.backgroundColor,
    this.gradientStartColor,
    this.gradientEndColor,
    this.disabled = false,
    this.icon,
    this.text,
    this.textStyle,
    this.customComponent,
    this.iconColor,
    this.iconSize,
    this.enableGlow = true,
  });
}

/// `ModernCustomButtonsOptions` - Configuration options for multiple buttons.
class ModernCustomButtonsOptions {
  final List<ModernCustomButton> buttons;
  final bool useGlassmorphism;
  final bool compact;
  final bool staggerAnimation;

  ModernCustomButtonsOptions({
    required this.buttons,
    this.useGlassmorphism = true,
    this.compact = false,
    this.staggerAnimation = true,
  });
}

typedef ModernCustomButtonsType = Widget Function(
    ModernCustomButtonsOptions options);

/// `ModernCustomButtons` - A modern widget displaying a list of customizable buttons.
///
/// Features:
/// - Glassmorphic design with frosted backgrounds
/// - Premium gradient backgrounds with glow effects
/// - Smooth press animations with spring physics
/// - Staggered entry animations
/// - Icon and text combinations
/// - Support for custom component content
///
/// ### Example Usage:
/// ```dart
/// ModernCustomButtons(
///   options: ModernCustomButtonsOptions(
///     buttons: [
///       ModernCustomButton(
///         action: () => print("Action 1"),
///         text: "First Button",
///         icon: Icons.add,
///         gradientStartColor: MediasfuColors.primary,
///         gradientEndColor: MediasfuColors.secondary,
///       ),
///       ModernCustomButton(
///         action: () => print("Action 2"),
///         text: "Second Button",
///         icon: Icons.remove,
///         disabled: true,
///       ),
///     ],
///   ),
/// )
/// ```
class ModernCustomButtons extends StatefulWidget {
  final ModernCustomButtonsOptions options;

  const ModernCustomButtons({super.key, required this.options});

  @override
  State<ModernCustomButtons> createState() => _ModernCustomButtonsState();
}

class _ModernCustomButtonsState extends State<ModernCustomButtons>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    if (widget.options.staggerAnimation) {
      _staggerController.forward();
    }
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleButtons = widget.options.buttons.where((b) => b.show).toList();
    final buttonCount = visibleButtons.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: visibleButtons.asMap().entries.map((entry) {
        final index = entry.key;
        final button = entry.value;

        // Calculate stagger delay
        final startInterval = index / (buttonCount + 1);
        final endInterval = (index + 1) / (buttonCount + 1);

        return widget.options.staggerAnimation
            ? AnimatedBuilder(
                animation: _staggerController,
                builder: (context, child) {
                  final animValue = Interval(
                    startInterval,
                    endInterval.clamp(0.0, 1.0),
                    curve: Curves.easeOutCubic,
                  ).transform(_staggerController.value);

                  // Clamp opacity to valid range (0.0 to 1.0)
                  final clampedOpacity = animValue.clamp(0.0, 1.0);

                  return Opacity(
                    opacity: clampedOpacity,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - animValue)),
                      child: child,
                    ),
                  );
                },
                child: _buildButtonPadding(button),
              )
            : _buildButtonPadding(button);
      }).toList(),
    );
  }

  Widget _buildButtonPadding(ModernCustomButton button) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: widget.options.compact ? 2 : MediasfuSpacing.xs,
      ),
      child: _ModernButtonItem(
        button: button,
        useGlassmorphism: widget.options.useGlassmorphism,
        compact: widget.options.compact,
      ),
    );
  }
}

class _ModernButtonItem extends StatefulWidget {
  final ModernCustomButton button;
  final bool useGlassmorphism;
  final bool compact;

  const _ModernButtonItem({
    required this.button,
    required this.useGlassmorphism,
    required this.compact,
  });

  @override
  State<_ModernButtonItem> createState() => _ModernButtonItemState();
}

class _ModernButtonItemState extends State<_ModernButtonItem>
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
      duration: MediasfuAnimations.fast,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (!widget.button.disabled) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails _) {
    if (!widget.button.disabled) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (!widget.button.disabled) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final button = widget.button;
    final isDisabled = button.disabled;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine colors - use teal/cyan scheme for professional look
    final gradientStart = button.gradientStartColor ??
        (isDark ? const Color(0xFF0D9488) : const Color(0xFF14B8A6)); // Teal
    final gradientEnd = button.gradientEndColor ??
        (isDark ? const Color(0xFF0891B2) : const Color(0xFF06B6D4)); // Cyan

    return Tooltip(
      message: button.text ?? 'Action button',
      decoration: MediasfuColors.tooltipDecoration(darkMode: isDark),
      textStyle: TextStyle(
        color: MediasfuColors.tooltipText(darkMode: isDark),
        fontSize: 12,
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: isDisabled ? null : button.action,
            child: AnimatedOpacity(
              duration: MediasfuAnimations.fast,
              opacity: isDisabled ? 0.5 : 1.0,
              child: AnimatedContainer(
                duration: MediasfuAnimations.fast,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: button.enableGlow && !isDisabled
                      ? [
                          BoxShadow(
                            color: gradientStart.withValues(
                                alpha: _isPressed
                                    ? 0.4
                                    : (_isHovered ? 0.3 : 0.15)),
                            blurRadius:
                                _isPressed ? 20 : (_isHovered ? 16 : 12),
                            spreadRadius: _isPressed ? 2 : 0,
                          ),
                        ]
                      : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: widget.useGlassmorphism
                        ? ImageFilter.blur(sigmaX: 15, sigmaY: 15)
                        : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                    child: AnimatedContainer(
                      duration: MediasfuAnimations.fast,
                      padding: EdgeInsets.symmetric(
                        horizontal: MediasfuSpacing.md,
                        vertical: widget.compact
                            ? MediasfuSpacing.sm
                            : MediasfuSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _isPressed
                                ? gradientStart
                                : gradientStart.withValues(alpha: 0.9),
                            _isPressed
                                ? gradientEnd
                                : gradientEnd.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isPressed || _isHovered
                              ? Colors.white.withValues(alpha: 0.3)
                              : Colors.white.withValues(alpha: 0.15),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Custom component if provided
                          if (button.customComponent != null)
                            button.customComponent!,

                          // Icon with clean styling
                          if (button.icon != null) ...[
                            AnimatedContainer(
                              duration: MediasfuAnimations.fast,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(
                                    alpha: _isPressed ? 0.25 : 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                button.icon,
                                size: button.iconSize ??
                                    (widget.compact ? 16 : 18),
                                color: button.iconColor ?? Colors.white,
                              ),
                            ),
                            const SizedBox(width: MediasfuSpacing.sm),
                          ],

                          // Text with enhanced typography
                          if (button.text != null)
                            Expanded(
                              child: Text(
                                button.text!,
                                style: button.textStyle ??
                                    TextStyle(
                                      color: Colors.white,
                                      fontSize: widget.compact ? 13 : 14,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.3,
                                    ),
                              ),
                            ),

                          // Animated arrow indicator
                          if (!isDisabled && button.text != null)
                            AnimatedContainer(
                              duration: MediasfuAnimations.fast,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withValues(alpha: _isHovered ? 0.2 : 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 12,
                                color: Colors.white
                                    .withValues(alpha: _isHovered ? 0.9 : 0.6),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
