import 'package:flutter/material.dart';

/// Additional positional overrides for the participants counter badge.
class ParticipantsCounterBadgePositionOverride {
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;

  const ParticipantsCounterBadgePositionOverride({
    this.top,
    this.right,
    this.bottom,
    this.left,
  });
}

/// Context passed to custom container builders.
class ParticipantsCounterBadgeContainerContext {
  final BuildContext buildContext;
  final ParticipantsCounterBadgeOptions options;

  const ParticipantsCounterBadgeContainerContext({
    required this.buildContext,
    required this.options,
  });
}

/// Context passed to custom badge builders.
class ParticipantsCounterBadgeBadgeContext {
  final BuildContext buildContext;
  final ParticipantsCounterBadgeOptions options;
  final bool showBadge;

  const ParticipantsCounterBadgeBadgeContext({
    required this.buildContext,
    required this.options,
    required this.showBadge,
  });
}

/// Context passed to custom text builders.
class ParticipantsCounterBadgeTextContext {
  final BuildContext buildContext;
  final ParticipantsCounterBadgeOptions options;

  const ParticipantsCounterBadgeTextContext({
    required this.buildContext,
    required this.options,
  });
}

/// Context passed to custom position builders.
class ParticipantsCounterBadgePositionContext {
  final BuildContext buildContext;
  final ParticipantsCounterBadgeOptions options;
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;

  const ParticipantsCounterBadgePositionContext({
    required this.buildContext,
    required this.options,
    this.top,
    this.right,
    this.bottom,
    this.left,
  });
}

typedef ParticipantsCounterBadgeContainerBuilder = Widget Function(
  ParticipantsCounterBadgeContainerContext context,
  Widget defaultContainer,
);

typedef ParticipantsCounterBadgeBadgeBuilder = Widget Function(
  ParticipantsCounterBadgeBadgeContext context,
  Widget defaultBadge,
);

typedef ParticipantsCounterBadgeTextBuilder = Widget Function(
  ParticipantsCounterBadgeTextContext context,
  Widget defaultText,
);

typedef ParticipantsCounterBadgePositionBuilder = Widget Function(
  ParticipantsCounterBadgePositionContext context,
  Widget defaultPositioned,
);

/// ParticipantsCounterBadgeOptions - Configuration options for the `ParticipantsCounterBadge` widget.
///
/// ### Properties:
/// - `participantsCount` (`int`): The number of participants to display (required).
/// - `backgroundColor` (`Color`): Background color for the badge (default is semi-transparent dark).
/// - `position` (`String`): Corner position for the badge (`topLeft`, `topRight`, `bottomLeft`, `bottomRight`).
/// - `positionOverride` (`ParticipantsCounterBadgePositionOverride?`): Fine-grained overrides for the badge offsets.
/// - `containerPadding` / `containerMargin`: Padding and margin for the positioned container.
/// - `containerDecoration`: Custom decoration for the positioned container.
/// - `badgePadding` / `badgeMargin`: Padding and margin for the badge element.
/// - `badgeDecoration`: Custom decoration for the badge.
/// - `badgeBorderRadius`: Overrides the badge border radius.
/// - `textStyle`: Custom text style for the count string.
/// - `iconColor`: Color for the people icon.
/// - `iconSize`: Size of the people icon.
/// - `textBuilder`, `badgeBuilder`, `containerBuilder`, `positionBuilder`: Hooks to override portions of the widget tree.
/// - `showBadge`: Controls visibility of the badge.
/// - `maintainState`: Whether to keep state when the badge is hidden (defaults to `false`).
class ParticipantsCounterBadgeOptions {
  final int participantsCount;
  final Color backgroundColor;
  final String position;
  final ParticipantsCounterBadgePositionOverride? positionOverride;
  final EdgeInsetsGeometry? containerPadding;
  final EdgeInsetsGeometry? containerMargin;
  final Decoration? containerDecoration;
  final EdgeInsetsGeometry? badgePadding;
  final EdgeInsetsGeometry? badgeMargin;
  final Decoration? badgeDecoration;
  final BorderRadiusGeometry? badgeBorderRadius;
  final TextStyle? textStyle;
  final Color? iconColor;
  final double? iconSize;
  final bool showBadge;
  final bool maintainState;
  final ParticipantsCounterBadgeContainerBuilder? containerBuilder;
  final ParticipantsCounterBadgeBadgeBuilder? badgeBuilder;
  final ParticipantsCounterBadgeTextBuilder? textBuilder;
  final ParticipantsCounterBadgePositionBuilder? positionBuilder;

  const ParticipantsCounterBadgeOptions({
    required this.participantsCount,
    this.backgroundColor = const Color(0xCC2D3436),
    this.position = 'topRight',
    this.positionOverride,
    this.containerPadding,
    this.containerMargin,
    this.containerDecoration,
    this.badgePadding,
    this.badgeMargin,
    this.badgeDecoration,
    this.badgeBorderRadius,
    this.textStyle,
    this.iconColor,
    this.iconSize,
    this.showBadge = true,
    this.maintainState = false,
    this.containerBuilder,
    this.badgeBuilder,
    this.textBuilder,
    this.positionBuilder,
  });
}

typedef ParticipantsCounterBadgeType = Widget Function({
  required ParticipantsCounterBadgeOptions options,
});

/// `ParticipantsCounterBadge` - Displays the participants count with an icon and extensive customization hooks.
///
/// This widget can be positioned in any screen corner and offers styling hooks for the container,
/// badge, and text content. It shows a people icon alongside the count for visual clarity.
class ParticipantsCounterBadge extends StatelessWidget {
  final ParticipantsCounterBadgeOptions options;

  const ParticipantsCounterBadge({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    if (!options.showBadge) {
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
        right = 0;
    }

    final override = options.positionOverride;
    top = override?.top ?? top;
    right = override?.right ?? right;
    bottom = override?.bottom ?? bottom;
    left = override?.left ?? left;

    final textStyle = options.textStyle ??
        const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.none,
        );

    final iconColor = options.iconColor ?? Colors.white;
    final iconSize = options.iconSize ?? 16.0;

    final defaultText = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.people_rounded,
          color: iconColor,
          size: iconSize,
        ),
        const SizedBox(width: 4),
        Text(
          '${options.participantsCount}',
          style: textStyle,
        ),
      ],
    );

    final textNode = options.textBuilder?.call(
          ParticipantsCounterBadgeTextContext(
            buildContext: context,
            options: options,
          ),
          defaultText,
        ) ??
        defaultText;

    final badgeDecoration = options.badgeDecoration ??
        BoxDecoration(
          color: options.backgroundColor,
          borderRadius: options.badgeBorderRadius ?? BorderRadius.circular(16),
        );

    final defaultBadge = Container(
      padding: options.badgePadding ??
          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      margin: options.badgeMargin,
      decoration: badgeDecoration,
      child: textNode,
    );

    final badgeNode = options.badgeBuilder?.call(
          ParticipantsCounterBadgeBadgeContext(
            buildContext: context,
            options: options,
            showBadge: options.showBadge,
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
          ParticipantsCounterBadgeContainerContext(
            buildContext: context,
            options: options,
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
        child: containerNode,
      ),
    );

    final positionedNode = options.positionBuilder?.call(
          ParticipantsCounterBadgePositionContext(
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
      visible: options.showBadge,
      maintainSize: options.maintainState,
      maintainAnimation: options.maintainState,
      maintainState: options.maintainState,
      child: positionedNode,
    );
  }
}
