import 'package:flutter/material.dart';

/// Additional positional overrides for the meeting progress timer.
class MeetingProgressTimerPositionOverride {
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;

  const MeetingProgressTimerPositionOverride({
    this.top,
    this.right,
    this.bottom,
    this.left,
  });
}

/// Context passed to custom container builders.
class MeetingProgressTimerContainerContext {
  final BuildContext buildContext;
  final MeetingProgressTimerOptions options;

  const MeetingProgressTimerContainerContext({
    required this.buildContext,
    required this.options,
  });
}

/// Context passed to custom badge builders.
class MeetingProgressTimerBadgeContext {
  final BuildContext buildContext;
  final MeetingProgressTimerOptions options;
  final bool showTimer;

  const MeetingProgressTimerBadgeContext({
    required this.buildContext,
    required this.options,
    required this.showTimer,
  });
}

/// Context passed to custom text builders.
class MeetingProgressTimerTextContext {
  final BuildContext buildContext;
  final MeetingProgressTimerOptions options;

  const MeetingProgressTimerTextContext({
    required this.buildContext,
    required this.options,
  });
}

/// Context passed to custom position builders.
class MeetingProgressTimerPositionContext {
  final BuildContext buildContext;
  final MeetingProgressTimerOptions options;
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;

  const MeetingProgressTimerPositionContext({
    required this.buildContext,
    required this.options,
    this.top,
    this.right,
    this.bottom,
    this.left,
  });
}

typedef MeetingProgressTimerContainerBuilder = Widget Function(
  MeetingProgressTimerContainerContext context,
  Widget defaultContainer,
);

typedef MeetingProgressTimerBadgeBuilder = Widget Function(
  MeetingProgressTimerBadgeContext context,
  Widget defaultBadge,
);

typedef MeetingProgressTimerTextBuilder = Widget Function(
  MeetingProgressTimerTextContext context,
  Widget defaultText,
);

typedef MeetingProgressTimerPositionBuilder = Widget Function(
  MeetingProgressTimerPositionContext context,
  Widget defaultPositioned,
);

/// MeetingProgressTimerOptions - Configuration options for the `MeetingProgressTimer` widget.
///
/// ### Properties:
/// - `meetingProgressTime` (`String`): The time to display as the meeting progress (required).
/// - `initialBackgroundColor` (`Color`): Background color for the timer badge (default is `Colors.green`).
/// - `position` (`String`): Corner position for the timer (`topLeft`, `topRight`, `bottomLeft`, `bottomRight`).
/// - `positionOverride` (`MeetingProgressTimerPositionOverride?`): Fine-grained overrides for the badge offsets.
/// - `containerPadding` / `containerMargin`: Padding and margin for the positioned container.
/// - `containerDecoration`: Custom decoration for the positioned container.
/// - `badgePadding` / `badgeMargin`: Padding and margin for the badge element.
/// - `badgeDecoration`: Custom decoration for the badge.
/// - `badgeBorderRadius`: Overrides the badge border radius.
/// - `textStyle`: Custom text style for the timer string.
/// - `textBuilder`, `badgeBuilder`, `containerBuilder`, `positionBuilder`: Hooks to override portions of the widget tree.
/// - `showTimer`: Controls visibility of the timer.
/// - `maintainState`: Whether to keep state when the timer is hidden (defaults to `false`).
class MeetingProgressTimerOptions {
  final String meetingProgressTime;
  final Color initialBackgroundColor;
  final String position;
  final MeetingProgressTimerPositionOverride? positionOverride;
  final EdgeInsetsGeometry? containerPadding;
  final EdgeInsetsGeometry? containerMargin;
  final Decoration? containerDecoration;
  final EdgeInsetsGeometry? badgePadding;
  final EdgeInsetsGeometry? badgeMargin;
  final Decoration? badgeDecoration;
  final BorderRadiusGeometry? badgeBorderRadius;
  final TextStyle? textStyle;
  final bool showTimer;
  final bool maintainState;
  final MeetingProgressTimerContainerBuilder? containerBuilder;
  final MeetingProgressTimerBadgeBuilder? badgeBuilder;
  final MeetingProgressTimerTextBuilder? textBuilder;
  final MeetingProgressTimerPositionBuilder? positionBuilder;

  const MeetingProgressTimerOptions({
    required this.meetingProgressTime,
    this.initialBackgroundColor = Colors.green,
    this.position = 'topLeft',
    this.positionOverride,
    this.containerPadding,
    this.containerMargin,
    this.containerDecoration,
    this.badgePadding,
    this.badgeMargin,
    this.badgeDecoration,
    this.badgeBorderRadius,
    this.textStyle,
    this.showTimer = true,
    this.maintainState = false,
    this.containerBuilder,
    this.badgeBuilder,
    this.textBuilder,
    this.positionBuilder,
  });
}

typedef MeetingProgressTimerType = Widget Function({
  required MeetingProgressTimerOptions options,
});

/// `MeetingProgressTimer` - Displays the meeting progress time with extensive customization hooks.
///
/// This widget can be positioned in any screen corner and offers styling hooks for the container,
/// badge, and text content. It mirrors the flexibility introduced on the React side, enabling
/// advanced composition and override scenarios.
class MeetingProgressTimer extends StatelessWidget {
  final MeetingProgressTimerOptions options;

  const MeetingProgressTimer({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    if (!options.showTimer) {
      return Visibility(
        visible: false,
        maintainState: options.maintainState,
        child: const SizedBox.shrink(),
      );
    }

    double? top;
    double? bottom;
    double? left;
    double? right;

    switch (options.position) {
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

    final override = options.positionOverride;
    top = override?.top ?? top;
    right = override?.right ?? right;
    bottom = override?.bottom ?? bottom;
    left = override?.left ?? left;

    final textStyle = options.textStyle ??
        const TextStyle(
          color: Colors.white,
          fontSize: 18,
          decoration: TextDecoration.none,
        );

    final defaultText = Text(
      options.meetingProgressTime,
      style: textStyle,
    );

    final textNode = options.textBuilder?.call(
          MeetingProgressTimerTextContext(
            buildContext: context,
            options: options,
          ),
          defaultText,
        ) ??
        defaultText;

    final badgeDecoration = options.badgeDecoration ?? BoxDecoration(
      color: options.initialBackgroundColor,
      borderRadius: options.badgeBorderRadius ?? BorderRadius.circular(10),
    );

    final defaultBadge = Container(
      padding: options.badgePadding ??
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: options.badgeMargin,
      decoration: badgeDecoration,
      child: textNode,
    );

    final badgeNode = options.badgeBuilder?.call(
          MeetingProgressTimerBadgeContext(
            buildContext: context,
            options: options,
            showTimer: options.showTimer,
          ),
          defaultBadge,
        ) ??
        defaultBadge;

    final defaultContainer = Container(
      padding: options.containerPadding,
      margin: options.containerMargin,
      decoration: options.containerDecoration,
      child: badgeNode,
    );

    final containerNode = options.containerBuilder?.call(
          MeetingProgressTimerContainerContext(
            buildContext: context,
            options: options,
          ),
          defaultContainer,
        ) ??
        defaultContainer;

    final defaultPositioned = Positioned(
      top: top,
      right: right,
      bottom: bottom,
      left: left,
      child: containerNode,
    );

    final positionedNode = options.positionBuilder?.call(
          MeetingProgressTimerPositionContext(
            buildContext: context,
            options: options,
            top: top,
            right: right,
            bottom: bottom,
            left: left,
          ),
          defaultPositioned,
        ) ??
        defaultPositioned;

    return Visibility(
      visible: options.showTimer,
      maintainSize: options.maintainState,
      maintainAnimation: options.maintainState,
      maintainState: options.maintainState,
      child: positionedNode,
    );
  }
}
