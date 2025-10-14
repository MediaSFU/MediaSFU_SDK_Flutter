import 'package:flutter/material.dart';

import 'meeting_progress_timer.dart';

/// `MainGridComponentOptions` - Configuration options for the `MainGridComponent`.
///
/// ### Properties:
/// - `backgroundColor` (`Color`): Background color of the main grid container.
/// - `children` (`List<Widget>`): List of child widgets to be displayed inside the grid.
/// - `mainSize` (`double`): Main component size within the grid as a percentage (0-100).
/// - `height` (`double`): Height of the grid container.
/// - `width` (`double`): Width of the grid container.
/// - `showAspect` (`bool`): If `true`, displays the grid with aspect ratio; default is `true`.
/// - `timeBackgroundColor` (`Color`): Background color of the meeting progress timer.
/// - `showTimer` (`bool`): If `true`, displays the meeting progress timer; default is `true`.
/// - `meetingProgressTime` (`String`): Time to display on the meeting progress timer.
///
/// ### Example Usage:
/// ```dart
/// MainGridComponentOptions(
///   backgroundColor: Colors.blue,
///   children: [
///     // List of child widgets
///   ],
///   mainSize: 200,
///   height: 300,
///   width: 500,
///   showAspect: true,
///   timeBackgroundColor: Colors.white,
///   showTimer: true,
///   meetingProgressTime: '10:00',
/// );
/// ```

class MainGridComponentOptions {
  /// The background color of the main grid container.
  final Color backgroundColor;

  /// The list of child widgets to be displayed inside the main grid.
  final List<Widget> children;

  /// The main size percentage (0-100) of the primary component within the grid.
  final double mainSize;

  /// The height of the main grid container.
  final double height;

  /// The width of the main grid container.
  final double width;

  /// A flag indicating whether to show the aspect ratio of the grid.
  final bool showAspect;

  /// The background color of the meeting progress timer.
  final Color timeBackgroundColor;

  /// A flag indicating whether to show the meeting progress timer.
  final bool showTimer;

  /// The meeting progress time to display on the timer.
  final String meetingProgressTime;

  /// Custom decoration for the grid container.
  final Decoration? decoration;

  /// Optional padding for the grid container.
  final EdgeInsetsGeometry? padding;

  /// Optional margin for the grid container.
  final EdgeInsetsGeometry? margin;

  /// Clip behavior for the container.
  final Clip clipBehavior;

  /// Custom timer options (overrides deprecated timer fields when provided).
  final MeetingProgressTimerOptions? timerOptions;

  /// Custom timer builder (defaults to [MeetingProgressTimer]).
  final MeetingProgressTimerType? timerBuilder;

  /// Builder to override the container composition.
  final MainGridComponentContainerBuilder? containerBuilder;

  /// Builder to override child composition inside the stack.
  final MainGridComponentChildrenBuilder? childrenBuilder;

  /// Constructs a MainGridComponentOptions object.
  const MainGridComponentOptions({
    required this.backgroundColor,
    required this.children,
    required this.mainSize,
    required this.height,
    required this.width,
    this.showAspect = true,
    this.timeBackgroundColor = Colors.transparent,
    this.showTimer = true,
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

typedef MainGridComponentType = Widget Function(
    {required MainGridComponentOptions options});

/// Context for container builder overrides.
class MainGridComponentContainerContext {
  final BuildContext buildContext;
  final MainGridComponentOptions options;

  const MainGridComponentContainerContext({
    required this.buildContext,
    required this.options,
  });
}

/// Context for children builder overrides.
class MainGridComponentChildrenContext {
  final BuildContext buildContext;
  final MainGridComponentOptions options;
  final Size dimensions;

  const MainGridComponentChildrenContext({
    required this.buildContext,
    required this.options,
    required this.dimensions,
  });
}

typedef MainGridComponentContainerBuilder = Widget Function(
  MainGridComponentContainerContext context,
  Widget defaultContainer,
);

typedef MainGridComponentChildrenBuilder = Widget Function(
  MainGridComponentChildrenContext context,
  List<Widget> defaultChildren,
);

/// `MainGridComponent` - A flexible grid component with customizable layout, child widgets, and background color.
///
/// This widget displays a grid container that can include custom child widgets and a configurable meeting progress timer.
/// It provides options for controlling visibility, styling, and grid layout based on the provided configuration.
///
/// ### Parameters:
/// - `options` (`MainGridComponentOptions`): Configuration options for customizing the grid component.
///
/// ### Example Usage:
/// ```dart
/// MainGridComponent(
///   options: MainGridComponentOptions(
///     backgroundColor: Colors.blue,
///     children: [
///       Text("Child 1"),
///       Text("Child 2"),
///     ],
///     mainSize: 200,
///     height: 300,
///     width: 500,
///     showAspect: true,
///     timeBackgroundColor: Colors.white,
///     showTimer: true,
///     meetingProgressTime: '10:00',
///   ),
/// );
/// ```
///
/// ### Notes:
/// - `MainGridComponent` uses the `Stack` widget to layer child widgets within the grid container.
/// - `showAspect` controls the grid visibility; if `false`, the component is hidden.
class MainGridComponent extends StatelessWidget {
  final MainGridComponentOptions options;

  /// Constructs a MainGridComponent widget.
  ///
  /// ### Parameters:
  /// - `options` (`MainGridComponentOptions`): Configuration options for the main grid component.
  ///
  /// ### Example Usage:
  /// ```dart
  /// MainGridComponent(
  ///   options: MainGridComponentOptions(
  ///     backgroundColor: Colors.blue,
  ///     children: [
  ///       // Your widgets here
  ///     ],
  ///     mainSize: 200,
  ///     height: 300,
  ///     width: 500,
  ///     timeBackgroundColor: Colors.white,
  ///     showTimer: true,
  ///     meetingProgressTime: '10:00',
  ///   ),
  /// );
  /// ```
  const MainGridComponent({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    if (!options.showAspect) {
      return const SizedBox.shrink();
    }

    final size = Size(options.width, options.height);
    final timerBuilder = options.timerBuilder ??
        ({required MeetingProgressTimerOptions options}) =>
            MeetingProgressTimer(options: options);

    final timerOptions = options.timerOptions ?? MeetingProgressTimerOptions(
      meetingProgressTime: options.meetingProgressTime,
      initialBackgroundColor: options.timeBackgroundColor,
      showTimer: options.showTimer,
    );

    final defaultChildren = <Widget>[...options.children];
    if (timerOptions.showTimer) {
      defaultChildren.add(timerBuilder(options: timerOptions));
    }

    final childrenWidget = options.childrenBuilder?.call(
          MainGridComponentChildrenContext(
            buildContext: context,
            options: options,
            dimensions: size,
          ),
          defaultChildren,
        ) ??
        Stack(children: defaultChildren);

    final decoration = options.decoration ??
        BoxDecoration(
          color: options.backgroundColor,
          border: Border.all(color: Colors.black, width: 4),
        );

    final defaultContainer = Container(
      width: options.width,
      height: options.height,
      padding: options.padding,
      margin: options.margin,
      clipBehavior: options.clipBehavior,
      decoration: decoration,
      child: childrenWidget,
    );

    final container = options.containerBuilder?.call(
          MainGridComponentContainerContext(
            buildContext: context,
            options: options,
          ),
          defaultContainer,
        ) ??
        defaultContainer;

    return container;
  }
}
