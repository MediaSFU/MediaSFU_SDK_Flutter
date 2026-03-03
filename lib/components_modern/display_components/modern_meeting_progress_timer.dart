import 'dart:ui';
import 'package:flutter/material.dart';

import '../../components/display_components/meeting_progress_timer.dart'
    show
        MeetingProgressTimerOptions,
        MeetingProgressTimerTextContext,
        MeetingProgressTimerBadgeContext,
        MeetingProgressTimerContainerContext,
        MeetingProgressTimerPositionContext;
import '../core/theme/mediasfu_spacing.dart';

typedef ModernMeetingProgressTimerType = Widget Function({
  required MeetingProgressTimerOptions options,
});

/// `ModernMeetingProgressTimer` - Displays the meeting progress time with glassmorphic styling.
///
/// This modern widget accepts the standard [MeetingProgressTimerOptions] for API compatibility
/// and adds modern styling features via additional widget parameters.
///
/// ### Features:
/// - Glassmorphic blur effect with subtle transparency
/// - Animated scale transitions on time changes
/// - Optional pulse animation for running timer
/// - Gradient or solid color backgrounds
/// - Clock icon with glow effect
/// - Recording state indicator icons
/// - Fully customizable via builder callbacks from base options
///
/// ### Modern styling parameters:
/// - `useGlassmorphism`: Whether to use glassmorphic styling (defaults to `true`).
/// - `useGradient`: Whether to use gradient instead of solid color (defaults to `false`).
/// - `animateOnChange`: Whether to animate when time changes (defaults to `true`).
/// - `showPulse`: Whether to show pulse animation for running timer (defaults to `true`).
/// - `showIcon`: Whether to show a clock icon (defaults to `true`).
/// - `recordingState`: Recording state indicator: 'red' = recording, 'yellow' = paused, 'green' = not recording.
class ModernMeetingProgressTimer extends StatefulWidget {
  final MeetingProgressTimerOptions options;

  /// Whether to use glassmorphic styling (defaults to `true`).
  final bool useGlassmorphism;

  /// Whether to use gradient instead of solid color (defaults to `false`).
  final bool useGradient;

  /// Whether to animate when time changes (defaults to `true`).
  final bool animateOnChange;

  /// Whether to show pulse animation for running timer (defaults to `true`).
  final bool showPulse;

  /// Whether to show a clock icon (defaults to `true`).
  final bool showIcon;

  /// Recording state indicator: 'red' = recording, 'yellow' = paused, 'green' = not recording
  /// When not 'green', shows a record or pause icon instead of the clock icon
  final String? recordingState;

  const ModernMeetingProgressTimer({
    super.key,
    required this.options,
    this.useGlassmorphism = true,
    this.useGradient = false,
    this.animateOnChange = false,
    this.showPulse = false,
    this.showIcon = true,
    this.recordingState,
  });

  @override
  State<ModernMeetingProgressTimer> createState() =>
      _ModernMeetingProgressTimerState();
}

class _ModernMeetingProgressTimerState extends State<ModernMeetingProgressTimer>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  String _previousTime = '';

  @override
  void initState() {
    super.initState();
    _previousTime = widget.options.meetingProgressTime;

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.showPulse && widget.options.showTimer) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ModernMeetingProgressTimer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Animate on time change
    if (widget.animateOnChange &&
        widget.options.meetingProgressTime != _previousTime) {
      _previousTime = widget.options.meetingProgressTime;
      _scaleController.forward().then((_) {
        _scaleController.reverse();
      });
    }

    // Handle pulse animation state
    if (widget.showPulse && widget.options.showTimer) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  /// Returns the appropriate icon based on recording state or background color
  /// - 'red' or red background (recording): fiber_manual_record (solid circle)
  /// - 'yellow' or yellow background (paused): pause_circle_filled
  /// - 'green' or green background or null (not recording): access_time_filled (clock)
  IconData _getTimerIcon() {
    final recordingState = widget.recordingState;
    final bgColor = widget.options.initialBackgroundColor;

    // Check explicit recording state first
    if (recordingState == 'red') {
      return Icons.fiber_manual_record_rounded;
    } else if (recordingState == 'yellow') {
      return Icons.pause_circle_filled_rounded;
    } else if (recordingState != null && recordingState != 'green') {
      return Icons.access_time_filled;
    }

    // If no explicit state, infer from background color
    if (bgColor == Colors.red || bgColor.value == Colors.red.value) {
      return Icons.fiber_manual_record_rounded;
    } else if (bgColor == Colors.yellow ||
        bgColor.value == Colors.yellow.value) {
      return Icons.pause_circle_filled_rounded;
    }

    return Icons.access_time_filled;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.options.showTimer) {
      return Visibility(
        visible: false,
        maintainState: widget.options.maintainState,
        child: const SizedBox.shrink(),
      );
    }

    double? top;
    double? bottom;
    double? left;
    double? right;

    switch (widget.options.position) {
      case 'topLeft':
        top = 0;
        left = 0;
        break;
      case 'topRight':
        top = 0;
        right = 0;
        break;
      case 'bottomLeft':
        bottom = 0;
        left = 0;
        break;
      case 'bottomRight':
        bottom = 0;
        right = 0;
        break;
      default:
        top = 0;
        left = 0;
    }

    final override = widget.options.positionOverride;
    top = override?.top ?? top;
    right = override?.right ?? right;
    bottom = override?.bottom ?? bottom;
    left = override?.left ?? left;

    final effectiveBackgroundColor = widget.options.initialBackgroundColor;

    final textStyle = widget.options.textStyle ??
        TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.none,
          shadows: [
            Shadow(
              blurRadius: 4,
              color: Colors.black.withOpacity(0.3),
            ),
          ],
        );

    // Build the timer text
    final defaultText = Text(
      widget.options.meetingProgressTime,
      style: textStyle,
    );

    final textNode = widget.options.textBuilder?.call(
          MeetingProgressTimerTextContext(
            buildContext: context,
            options: widget.options,
          ),
          defaultText,
        ) ??
        defaultText;

    // Build the badge with glassmorphic styling
    Widget defaultBadge;

    if (widget.useGlassmorphism) {
      defaultBadge = ClipRRect(
        borderRadius: (widget.options.badgeBorderRadius as BorderRadius?) ??
            BorderRadius.circular(MediasfuSpacing.md),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: widget.options.badgePadding ??
                EdgeInsets.symmetric(
                  horizontal: MediasfuSpacing.md,
                  vertical: MediasfuSpacing.sm,
                ),
            margin: widget.options.badgeMargin,
            decoration: widget.options.badgeDecoration ??
                BoxDecoration(
                  color: widget.useGradient
                      ? null
                      : effectiveBackgroundColor.withOpacity(0.7),
                  gradient: widget.useGradient
                      ? LinearGradient(
                          colors: [
                            effectiveBackgroundColor.withOpacity(0.8),
                            effectiveBackgroundColor.withOpacity(0.6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  borderRadius:
                      (widget.options.badgeBorderRadius as BorderRadius?) ??
                          BorderRadius.circular(MediasfuSpacing.md),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.showIcon) ...[
                  Icon(
                    _getTimerIcon(),
                    size: 16,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ],
                  ),
                  SizedBox(width: MediasfuSpacing.xs),
                ],
                textNode,
              ],
            ),
          ),
        ),
      );
    } else {
      // Non-glassmorphic fallback
      defaultBadge = Container(
        padding: widget.options.badgePadding ??
            EdgeInsets.symmetric(
              horizontal: MediasfuSpacing.md,
              vertical: MediasfuSpacing.sm,
            ),
        margin: widget.options.badgeMargin,
        decoration: widget.options.badgeDecoration ??
            BoxDecoration(
              color: effectiveBackgroundColor,
              borderRadius:
                  (widget.options.badgeBorderRadius as BorderRadius?) ??
                      BorderRadius.circular(MediasfuSpacing.md),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showIcon) ...[
              Icon(
                _getTimerIcon(),
                size: 16,
                color: Colors.white,
              ),
              SizedBox(width: MediasfuSpacing.xs),
            ],
            textNode,
          ],
        ),
      );
    }

    final badgeNode = widget.options.badgeBuilder?.call(
          MeetingProgressTimerBadgeContext(
            buildContext: context,
            options: widget.options,
            showTimer: widget.options.showTimer,
          ),
          defaultBadge,
        ) ??
        defaultBadge;

    // Apply animations
    Widget animatedBadge = badgeNode;

    if (widget.animateOnChange) {
      animatedBadge = AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: animatedBadge,
      );
    }

    if (widget.showPulse) {
      animatedBadge = AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) => Transform.scale(
          scale: _pulseAnimation.value,
          child: child,
        ),
        child: animatedBadge,
      );
    }

    final defaultContainer = Container(
      padding:
          widget.options.containerPadding ?? EdgeInsets.all(MediasfuSpacing.sm),
      margin: widget.options.containerMargin,
      decoration: widget.options.containerDecoration,
      child: animatedBadge,
    );

    final containerNode = widget.options.containerBuilder?.call(
          MeetingProgressTimerContainerContext(
            buildContext: context,
            options: widget.options,
          ),
          defaultContainer,
        ) ??
        defaultContainer;

    // Determine alignment and padding for Align widget (instead of Positioned)
    Alignment alignment = Alignment.topLeft;
    EdgeInsets padding = EdgeInsets.zero;

    if (top != null && left != null) {
      alignment = Alignment.topLeft;
      padding = EdgeInsets.only(top: top, left: left);
    } else if (top != null && right != null) {
      alignment = Alignment.topRight;
      padding = EdgeInsets.only(top: top, right: right);
    } else if (bottom != null && left != null) {
      alignment = Alignment.bottomLeft;
      padding = EdgeInsets.only(bottom: bottom, left: left);
    } else if (bottom != null && right != null) {
      alignment = Alignment.bottomRight;
      padding = EdgeInsets.only(bottom: bottom, right: right);
    } else if (top != null) {
      alignment = Alignment.topCenter;
      padding = EdgeInsets.only(top: top);
    } else if (bottom != null) {
      alignment = Alignment.bottomCenter;
      padding = EdgeInsets.only(bottom: bottom);
    }

    final defaultPositioned = Align(
      alignment: alignment,
      child: Padding(
        padding: padding,
        child: Visibility(
          visible: widget.options.showTimer,
          maintainSize: widget.options.maintainState,
          maintainAnimation: widget.options.maintainState,
          maintainState: widget.options.maintainState,
          child: containerNode,
        ),
      ),
    );

    final positionedNode = widget.options.positionBuilder?.call(
          MeetingProgressTimerPositionContext(
            buildContext: context,
            options: widget.options,
            top: top,
            right: right,
            bottom: bottom,
            left: left,
          ),
          defaultPositioned,
        ) ??
        defaultPositioned;

    return positionedNode;
  }
}
