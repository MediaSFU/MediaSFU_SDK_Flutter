import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/mediasfu_animations.dart';
import '../theme/mediasfu_colors.dart';
import '../theme/mediasfu_spacing.dart';
import 'modern_pressable.dart';

/// Reusable frosted glass surface used for overlays and floating UI.
///
/// Mounts with a short fade and scale, and lifts on hover when it is
/// interactive — the two behaviours its React counterpart has had and this one
/// lacked. Both degrade to a static render under the platform's reduce-motion
/// setting, and hover is compiled out entirely on touch platforms.
class GlassmorphicContainer extends StatefulWidget {
  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.blur = 16,
    this.padding,
    this.gradient,
    this.onTap,
    this.animateOnMount = true,
    this.hoverEffect = true,
    this.elevation = 1,
  });

  final Widget child;
  final double borderRadius;
  final double blur;
  final EdgeInsets? padding;
  final Gradient? gradient;
  final VoidCallback? onTap;

  /// Fade and scale in on first build.
  final bool animateOnMount;

  /// Brighten the border and lift slightly while hovered. Only applies when
  /// [onTap] is set, since a surface that does nothing should not invite a
  /// click.
  final bool hoverEffect;

  /// Shadow depth passed to [MediasfuColors.elevation].
  final int elevation;

  @override
  State<GlassmorphicContainer> createState() => _GlassmorphicContainerState();
}

class _GlassmorphicContainerState extends State<GlassmorphicContainer> {
  bool _mounted = false;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    if (!widget.animateOnMount) {
      _mounted = true;
      return;
    }
    // A frame late, so the first paint is the "from" state.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _mounted = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final bool interactive = widget.onTap != null;
    final bool lifted = interactive && widget.hoverEffect && _hovered;

    final BoxDecoration decoration = BoxDecoration(
      gradient: widget.gradient ??
          LinearGradient(
            colors: <Color>[
              MediasfuColors.glassBackground(darkMode: isDark),
              MediasfuColors.glassBackground(darkMode: isDark).withOpacity(0.4),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
      border: Border.all(
        // The border is what reads first on glass, so hover brightens it
        // rather than shifting the fill.
        color: MediasfuColors.glassBorder(darkMode: isDark)
            .withOpacity(lifted ? 0.85 : 0.5),
        width: 1,
      ),
      borderRadius: BorderRadius.circular(widget.borderRadius),
      boxShadow: MediasfuColors.elevation(
        level: lifted ? widget.elevation + 1 : widget.elevation,
        darkMode: isDark,
      ),
    );

    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
        child: AnimatedContainer(
          duration: MediasfuAnimations.normal,
          curve: Curves.easeOut,
          padding: widget.padding ?? MediasfuSpacing.insetAll(MediasfuSpacing.md),
          decoration: decoration,
          child: widget.child,
        ),
      ),
    );

    if (widget.animateOnMount && !reduced) {
      // Child passed by reference through both, so the subtree is not rebuilt
      // for the entrance — only the opacity and transform are.
      content = AnimatedOpacity(
        opacity: _mounted ? 1 : 0,
        duration: MediasfuAnimations.normal,
        curve: Curves.easeOut,
        child: AnimatedScale(
          scale: _mounted ? 1 : 0.97,
          duration: MediasfuAnimations.normal,
          curve: Curves.easeOutCubic,
          child: content,
        ),
      );
    }

    if (!interactive) return content;

    return ModernPressable(
      onTap: widget.onTap,
      hoverLift: widget.hoverEffect ? 2 : 0,
      onStateChanged: widget.hoverEffect
          ? (bool hovered, bool _) {
              if (hovered != _hovered) setState(() => _hovered = hovered);
            }
          : null,
      child: content,
    );
  }
}
