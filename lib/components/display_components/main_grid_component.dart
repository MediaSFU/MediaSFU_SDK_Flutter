import 'package:flutter/material.dart';

import 'meeting_progress_timer.dart';

/// Configuration options for the `MainGridComponent`.
///
/// Provides properties to customize the main video grid container, including dimensions,
/// background styling, child widgets (participant videos), and optional meeting timer display.
///
/// **Core Display Properties:**
/// - `children`: List of child widgets (typically VideoCard/AudioCard components)
/// - `showAspect`: If false, hides entire component; useful for conditional visibility
/// - `backgroundColor`: Background color for grid container (default: transparent)
///
/// **Dimensions:**
/// - `width`: Container width in pixels
/// - `height`: Container height in pixels
/// - `mainSize`: Main component size as percentage (0-100); affects layout proportions
///
/// **Meeting Timer:**
/// - `showTimer`: If true, displays MeetingProgressTimer overlay (default: true)
/// - `meetingProgressTime`: Timer display text (e.g., "00:45:30")
/// - `timeBackgroundColor`: Timer background color (default: transparent)
/// - `timerOptions`: MeetingProgressTimerOptions for custom timer styling
/// - `timerBuilder`: Custom timer widget builder (overrides default MeetingProgressTimer)
///
/// **Styling:**
/// - `decoration`: BoxDecoration for container (overrides backgroundColor if provided)
/// - `padding`: Padding inside container
/// - `margin`: Margin around container
/// - `clipBehavior`: Clip behavior for container (default: Clip.none)
///
/// **Builder Hooks (2):**
/// - `containerBuilder`: Override outer Container; receives MainGridComponentContainerContext + default
/// - `childrenBuilder`: Override Stack children arrangement; receives MainGridComponentChildrenContext + defaultChildren
///
/// **Usage Patterns:**
/// 1. **Basic Grid with Videos:**
///    ```dart
///    MainGridComponent(
///      options: MainGridComponentOptions(
///        width: MediaQuery.of(context).size.width,
///        height: MediaQuery.of(context).size.height,
///        mainSize: 80,
///        backgroundColor: Colors.black,
///        children: videoParticipants.map((p) => VideoCard(...)).toList(),
///        meetingProgressTime: formattedTime,
///      ),
///    )
///    ```
///
/// 2. **Grid with Custom Timer:**
///    ```dart
///    MainGridComponent(
///      options: MainGridComponentOptions(
///        width: screenWidth,
///        height: screenHeight,
///        mainSize: 70,
///        backgroundColor: Colors.grey[900]!,
///        children: participantWidgets,
///        showTimer: true,
///        timerOptions: MeetingProgressTimerOptions(
///          backgroundColor: Colors.blue,
///          textColor: Colors.white,
///          fontSize: 16,
///        ),
///        meetingProgressTime: '01:23:45',
///      ),
///    )
///    ```
///
/// 3. **Hide Timer:**
///    ```dart
///    MainGridComponent(
///      options: MainGridComponentOptions(
///        width: width,
///        height: height,
///        mainSize: 100,
///        backgroundColor: Colors.black87,
///        children: videoCards,
///        showTimer: false,
///        meetingProgressTime: '',
///      ),
///    )
///    ```
///
/// 4. **Custom Children Layout:**
///    ```dart
///    MainGridComponent(
///      options: MainGridComponentOptions(
///        width: width,
///        height: height,
///        mainSize: 75,
///        backgroundColor: Colors.black,
///        children: participants,
///        meetingProgressTime: time,
///        childrenBuilder: (context, defaultChildren) {
///          return [
///            ...defaultChildren,
///            Positioned(
///              bottom: 16,
///              right: 16,
///              child: FloatingActionButton(
///                onPressed: openSettings,
///                child: Icon(Icons.settings),
///              ),
///            ),
///          ];
///        },
///      ),
///    )
///    ```
///
/// **Override Integration:**
/// Can be overridden via `MediasfuUICustomOverrides`:
/// ```dart
/// overrides: MediasfuUICustomOverrides(
///   mainGridOptions: ComponentOverride<MainGridComponentOptions>(
///     builder: (existingOptions) => MainGridComponentOptions(
///       width: existingOptions.width,
///       height: existingOptions.height,
///       mainSize: existingOptions.mainSize,
///       backgroundColor: Colors.deepPurple[900]!,
///       children: existingOptions.children,
///       meetingProgressTime: existingOptions.meetingProgressTime,
///       decoration: BoxDecoration(
///         gradient: LinearGradient(colors: [Colors.black, Colors.deepPurple[900]!]),
///       ),
///     ),
///   ),
/// ),
/// ```
///
/// **Timer Integration:**
/// - Timer positioned at top-center of grid (Positioned top: 0, left/right: 0)
/// - Timer renders above all child widgets (in Stack)
/// - `timerOptions` provides styling: backgroundColor, textColor, fontSize, padding, etc.
/// - `timerBuilder` allows full timer replacement for custom implementations
///
/// **Implementation Notes:**
/// - Uses Stack to layer children + timer overlay
/// - Container dimensions controlled by width/height props (no automatic sizing)
/// - mainSize affects internal layout calculations (used by parent components)
/// - showAspect=false makes entire component invisible (Visibility widget)
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

/// A stateless widget rendering the main participant video grid with optional timer overlay.
///
/// Displays a fixed-size container holding participant video/audio cards in a Stack layout,
/// with an optional MeetingProgressTimer positioned at the top center. Commonly used as
/// the primary display area in video conferencing interfaces.
///
/// **Rendering Logic:**
/// 1. If `showAspect=false` → returns invisible Container (Visibility.visible=false)
/// 2. Builds Container with width/height from options
/// 3. Creates Stack containing:
///    - All children from `options.children` (participant cards)
///    - MeetingProgressTimer (if showTimer=true) positioned at top-center
/// 4. Applies containerBuilder hook if provided
/// 5. Applies childrenBuilder hook if provided
///
/// **Layout Structure:**
/// ```
/// Visibility (showAspect)
///   └─ Container (containerBuilder)
///      ├─ width/height/backgroundColor/decoration
///      └─ Stack
///         ├─ ...children (VideoCard/AudioCard widgets)
///         └─ Positioned (top: 0, left/right: 0) [IF showTimer]
///            └─ Align (center)
///               └─ MeetingProgressTimer (timerBuilder)
/// ```
///
/// **Timer Positioning:**
/// - Positioned at top of Stack (top: 0, left: 0, right: 0)
/// - Aligned to Alignment.topCenter
/// - Renders above all participant cards (last child in Stack)
/// - Shows elapsed meeting time (e.g., "00:45:30")
///
/// **Builder Hook Priorities:**
/// - `containerBuilder`: Wraps outer Container; receives context + default container
/// - `childrenBuilder`: Wraps Stack children list; receives context + dimensions + defaultChildren
/// - Both hooks receive MainGridComponentOptions for access to all config
///
/// **Common Use Cases:**
/// 1. **Standard Video Grid:**
///    ```dart
///    MainGridComponent(
///      options: MainGridComponentOptions(
///        width: MediaQuery.of(context).size.width,
///        height: MediaQuery.of(context).size.height * 0.7,
///        mainSize: 80,
///        backgroundColor: Colors.black,
///        children: participants.map((p) => VideoCard(options: VideoCardOptions(...))).toList(),
///        meetingProgressTime: formatDuration(meetingDuration),
///        showTimer: true,
///      ),
///    )
///    ```
///
/// 2. **Responsive Grid:**
///    ```dart
///    LayoutBuilder(
///      builder: (context, constraints) {
///        return MainGridComponent(
///          options: MainGridComponentOptions(
///            width: constraints.maxWidth,
///            height: constraints.maxHeight,
///            mainSize: 75,
///            backgroundColor: Colors.grey[900]!,
///            children: buildParticipantCards(participants, constraints),
///            meetingProgressTime: meetingTime,
///          ),
///        );
///      },
///    )
///    ```
///
/// 3. **Grid with Custom Overlay:**
///    ```dart
///    MainGridComponent(
///      options: MainGridComponentOptions(
///        width: width,
///        height: height,
///        mainSize: 100,
///        backgroundColor: Colors.black,
///        children: videoCards,
///        meetingProgressTime: time,
///        childrenBuilder: (context, defaultChildren) {
///          return [
///            ...defaultChildren,
///            Positioned(
///              bottom: 20,
///              left: 20,
///              child: Text(
///                'Recording in progress',
///                style: TextStyle(color: Colors.red, fontSize: 16),
///              ),
///            ),
///          ];
///        },
///      ),
///    )
///    ```
///
/// 4. **Hide Grid Conditionally:**
///    ```dart
///    MainGridComponent(
///      options: MainGridComponentOptions(
///        width: width,
///        height: height,
///        mainSize: 80,
///        backgroundColor: Colors.black,
///        children: participants,
///        meetingProgressTime: time,
///        showAspect: isGridVisible, // Toggle visibility
///      ),
///    )
///    ```
///
/// **Override Integration:**
/// Integrates with `MediasfuUICustomOverrides` for global styling:
/// ```dart
/// overrides: MediasfuUICustomOverrides(
///   mainGridOptions: ComponentOverride<MainGridComponentOptions>(
///     builder: (existingOptions) => MainGridComponentOptions(
///       width: existingOptions.width,
///       height: existingOptions.height,
///       mainSize: existingOptions.mainSize,
///       backgroundColor: Colors.black,
///       children: existingOptions.children,
///       meetingProgressTime: existingOptions.meetingProgressTime,
///       decoration: BoxDecoration(
///         gradient: LinearGradient(
///           begin: Alignment.topCenter,
///           end: Alignment.bottomCenter,
///           colors: [Colors.black, Colors.grey[900]!],
///         ),
///       ),
///       timerOptions: MeetingProgressTimerOptions(
///         backgroundColor: Colors.blue[700],
///         textColor: Colors.white,
///         fontSize: 18,
///       ),
///     ),
///   ),
/// ),
/// ```
///
/// **Meeting Timer Features:**
/// - Displays elapsed meeting time (format: "HH:MM:SS")
/// - Updates via `meetingProgressTime` prop (parent manages timer state)
/// - Customizable via `timerOptions` (colors, fonts, padding)
/// - Can be fully replaced via `timerBuilder` hook
/// - Hidden if `showTimer=false`
///
/// **Dimension Management:**
/// - Fixed dimensions via width/height props (no automatic sizing)
/// - Parent responsible for responsive sizing (typically uses LayoutBuilder)
/// - mainSize prop passed to options but not directly used in rendering (used by parent layouts)
///
/// **Performance Notes:**
/// - Stateless widget (no internal state)
/// - Stack renders all children (no virtualization)
/// - Suitable for typical meeting sizes (2-50 participants)
/// - For larger meetings, consider implementing pagination or virtualization
///
/// **Implementation Details:**
/// - Uses Visibility widget for showAspect toggling
/// - Stack allows overlaying timer on top of participant grid
/// - Container provides background and dimensions
/// - Timer positioned absolutely at top-center
/// - Builder hooks called during build (not cached)
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
