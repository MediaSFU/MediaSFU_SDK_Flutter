import 'package:flutter/material.dart';

import 'meeting_progress_timer.dart';

/// OtherGridComponentOptions - Configuration options for the `OtherGridComponent`.
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

/// OtherGridComponent - A widget for displaying a grid with customizable background color, children, and optional timer.
///
/// This widget displays a grid-like container with optional timer functionality. It allows flexibility for various layouts
/// by accepting child widgets and controlling visibility through `showAspect`.
///
/// ### Parameters:
/// - `options` (`OtherGridComponentOptions`): Configuration options for the grid component.
///
/// ### Example Usage:
/// ```dart
/// OtherGridComponent(
///   options: OtherGridComponentOptions(
///     backgroundColor: Colors.black,
///     width: 100.0,
///     height: 100.0,
///     showAspect: true,
///     timeBackgroundColor: Colors.white,
///     showTimer: true,
///     meetingProgressTime: "10:00",
///     children: [ChildWidget()],
///   ),
/// );
/// ```
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
