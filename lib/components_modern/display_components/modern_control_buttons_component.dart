
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../components/display_components/control_buttons_component.dart'
    show ControlButton, ControlButtonsComponentOptions;
import '../core/theme/mediasfu_colors.dart';
import '../core/theme/mediasfu_spacing.dart';
import '../core/theme/mediasfu_animations.dart';
import '../core/widgets/animated_icon_button.dart';
import '../core/widgets/glassmorphic_container.dart';

/// Modern replacement for ControlButtonsComponent.
///
/// Provides the same API via [ControlButtonsComponentOptions] while rendering
/// a FAB-style glassmorphic control bar with micro-animated icon buttons,
/// glow effects, and premium styling.
class ModernControlButtonsComponent extends StatefulWidget {
  final ControlButtonsComponentOptions options;

  const ModernControlButtonsComponent({super.key, required this.options});

  @override
  State<ModernControlButtonsComponent> createState() =>
      _ModernControlButtonsComponentState();
}

class _ModernControlButtonsComponentState
    extends State<ModernControlButtonsComponent>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: MediasfuAnimations.normal,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );
    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final axis = widget.options.vertical ? Axis.vertical : Axis.horizontal;
    final visibleButtons =
        widget.options.buttons.where((b) => b.show).toList(growable: false);

    if (visibleButtons.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<Widget> children = [];
    for (var i = 0; i < visibleButtons.length; i++) {
      if (i > 0) {
        children.add(SizedBox(
          width: axis == Axis.horizontal ? MediasfuSpacing.sm : 0,
          height: axis == Axis.vertical ? MediasfuSpacing.sm : 0,
        ));
      }
      children.add(_PremiumControlButton(
        button: visibleButtons[i],
        options: widget.options,
        index: i,
      ));
    }

    return AnimatedBuilder(
      animation: _entryController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: MediasfuColors.primary.withValues(alpha: 0.15),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
        ),
        child: GlassmorphicContainer(
          borderRadius: 32,
          blur: 20,
          padding: MediasfuSpacing.insetSymmetric(
            horizontal: MediasfuSpacing.md,
            vertical: MediasfuSpacing.sm,
          ),
          child: Flex(
            direction: axis,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: widget.options.alignment,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: children,
          ),
        ),
      ),
    );
  }
}

/// Premium control button with glow effects and animations.
class _PremiumControlButton extends StatefulWidget {
  final ControlButton button;
  final ControlButtonsComponentOptions options;
  final int index;

  const _PremiumControlButton({
    required this.button,
    required this.options,
    required this.index,
  });

  @override
  State<_PremiumControlButton> createState() => _PremiumControlButtonState();
}

class _PremiumControlButtonState extends State<_PremiumControlButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final button = widget.button;

    if (button.customComponent != null) {
      return button.customComponent!;
    }

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isActive = button.active;
    final IconData effectiveIcon =
        isActive ? (button.alternateIcon ?? button.icon!) : button.icon!;
    final Color activeColor = button.activeColor ??
        widget.options.activeIconColor ??
        (isDark ? MediasfuColors.primaryDark : MediasfuColors.primary);

    // Determine glow color based on state
    final Color glowColor = isActive
        ? activeColor
        : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.transparent);

    Widget iconButton = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) {
          if (!button.disabled) {
            _pressController.forward();
            HapticFeedback.lightImpact();
          }
        },
        onTapUp: (_) {
          _pressController.reverse();
        },
        onTapCancel: () {
          _pressController.reverse();
        },
        onTap: button.disabled ? null : (button.onPress ?? () {}),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? activeColor.withValues(alpha: 0.15)
                  : (_isHovered
                      ? (isDark ? Colors.white : Colors.black)
                          .withValues(alpha: 0.1)
                      : Colors.transparent),
              boxShadow: isActive || _isHovered
                  ? [
                      BoxShadow(
                        color: glowColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: AnimatedIconButton(
              icon: effectiveIcon,
              isActive: isActive,
              activeColor: activeColor,
              size: button.iconSize ?? widget.options.iconSize ?? 22,
              tooltip: button.name,
              onPressed: button.disabled ? () {} : (button.onPress ?? () {}),
            ),
          ),
        ),
      ),
    );

    if (button.disabled) {
      iconButton = Opacity(opacity: 0.4, child: iconButton);
    }

    // Optionally show label below/right depending on axis
    if (button.name != null && button.name!.isNotEmpty) {
      final labelStyle = button.textStyle ??
          widget.options.textStyle ??
          TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : Colors.black87,
          );
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconButton,
          const SizedBox(height: 2),
          Text(button.name!, style: labelStyle),
        ],
      );
    }

    return iconButton;
  }
}
