import 'package:flutter/material.dart';

import 'meeting_progress_timer.dart';

/// Configuration payload for [OtherGridComponent].
///
/// These options power the MediaSFU "other participants" grid override and
/// expose points for responsive layout and builder customization:
///
/// * `width` / `height` act as optional hints. When non-positive they are
///   replaced with values derived from the surrounding layout constraints so the
///   grid never collapses during first paint.
/// * `children` are rendered inside a [Stack]; `childrenBuilder` can wrap or
///   replace the stack and receives the computed surface [Size].
/// * `showTimer`, `meetingProgressTime`, `timerOptions`, and `timerBuilder`
///   allow the MediaSFU session timer to be injected alongside your widgets.
/// * `containerBuilder` gives the opportunity to re-theme the host container
///   while preserving padding, margin, and clipping semantics defined in the
///   options.
///
/// Supply this object via `MediasfuUICustomOverrides` when overriding
/// `otherGrid`.
class OtherGridComponentOptions {
  final Color backgroundColor;
  final List<Widget> children;
  final double width;
  final double height;
  final bool showAspect;
  final Color timeBackgroundColor;
  final bool showTimer;
  final String meetingProgressTime;
  final Decoration? decoration;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Clip clipBehavior;
  final MeetingProgressTimerOptions? timerOptions;
  final MeetingProgressTimerType? timerBuilder;
  final OtherGridComponentContainerBuilder? containerBuilder;
  final OtherGridComponentChildrenBuilder? childrenBuilder;

  const OtherGridComponentOptions({
    required this.backgroundColor,
    required this.children,
    required this.width,
    required this.height,
    this.showAspect = true,
    required this.timeBackgroundColor,
    required this.showTimer,
    required this.meetingProgressTime,
    this.decoration,
    this.padding,
    this.margin,
    this.clipBehavior = Clip.none,
    this.timerOptions,
    this.timerBuilder,
    this.containerBuilder,
    this.childrenBuilder,
  });
}

typedef OtherGridComponentType = Widget Function(
    {required OtherGridComponentOptions options});

class OtherGridComponentContainerContext {
  final BuildContext buildContext;
  final OtherGridComponentOptions options;

  const OtherGridComponentContainerContext({
    required this.buildContext,
    required this.options,
  });
}

class OtherGridComponentChildrenContext {
  final BuildContext buildContext;
  final OtherGridComponentOptions options;
  final Size dimensions;

  const OtherGridComponentChildrenContext({
    required this.buildContext,
    required this.options,
    required this.dimensions,
  });
}

typedef OtherGridComponentContainerBuilder = Widget Function(
  OtherGridComponentContainerContext context,
  Widget defaultContainer,
);

typedef OtherGridComponentChildrenBuilder = Widget Function(
  OtherGridComponentChildrenContext context,
  List<Widget> defaultChildren,
);

/// Responsive container backing the MediaSFU "other participants" surface.
///
/// * Uses [LayoutBuilder] to derive usable dimensions when width/height are
///   unset or non-positive, preventing the grid from disappearing while session
///   metadata loads.
/// * Emits the resolved [Size] to `childrenBuilder` so nested layouts can adapt
///   to available space.
/// * Rehydrates timer UI through `timerBuilder` / `timerOptions` and can be
///   themed by wrapping it in `containerBuilder`.
/// * Returns [SizedBox.shrink] when `showAspect` is `false`, mirroring the
///   built-in component lifecycle.
class OtherGridComponent extends StatelessWidget {
  final OtherGridComponentOptions options;

  const OtherGridComponent({super.key, required this.options});

  double? _positive(double value) {
    if (value.isNaN || value.isInfinite || value <= 0) {
      return null;
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    if (!options.showAspect) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaSize = MediaQuery.of(context).size;
        double? derivedWidth = _positive(options.width);
        double? derivedHeight = _positive(options.height);

        double widthValue = derivedWidth ??
            (constraints.maxWidth.isFinite ? constraints.maxWidth : null) ??
            mediaSize.width;
        double heightValue = derivedHeight ??
            (constraints.maxHeight.isFinite ? constraints.maxHeight : null) ??
            mediaSize.height;

        final double displayWidth = widthValue;
        final double displayHeight = heightValue;

        final size = Size(displayWidth, displayHeight);
        final timerBuilder = options.timerBuilder ??
            ({required MeetingProgressTimerOptions options}) =>
                MeetingProgressTimer(options: options);

        final timerOptions = options.timerOptions ??
            MeetingProgressTimerOptions(
              meetingProgressTime: options.meetingProgressTime,
              initialBackgroundColor: options.timeBackgroundColor,
              showTimer: options.showTimer,
            );

        final defaultChildren = <Widget>[...options.children];
        if (timerOptions.showTimer) {
          defaultChildren.add(timerBuilder(options: timerOptions));
        }

        final childrenWidget = options.childrenBuilder?.call(
              OtherGridComponentChildrenContext(
                buildContext: context,
                options: options,
                dimensions: size,
              ),
              defaultChildren,
            ) ??
            Stack(children: defaultChildren);

        final BoxDecoration fallbackDecoration =
            BoxDecoration(color: options.backgroundColor);

        final containerChild = Container(
          width: displayWidth.isFinite ? displayWidth : null,
          height: displayHeight.isFinite ? displayHeight : null,
          padding: options.padding,
          margin: options.margin,
          clipBehavior: options.clipBehavior,
          decoration: options.decoration ?? fallbackDecoration,
          child: childrenWidget,
        );

        final container = options.containerBuilder?.call(
              OtherGridComponentContainerContext(
                buildContext: context,
                options: options,
              ),
              containerChild,
            ) ??
            containerChild;

        return container;
      },
    );
  }
}
