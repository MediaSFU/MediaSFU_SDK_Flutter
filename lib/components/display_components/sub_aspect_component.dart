import 'package:flutter/material.dart';

class SubAspectContentContext {
  final BuildContext buildContext;
  final SubAspectComponentOptions options;
  final bool showControls;
  final Widget defaultContent;

  const SubAspectContentContext({
    required this.buildContext,
    required this.options,
    required this.showControls,
    required this.defaultContent,
  });
}

class SubAspectContainerContext {
  final BuildContext buildContext;
  final SubAspectComponentOptions options;
  final bool showControls;
  final double width;
  final double height;
  final Widget child;
  final Widget defaultContainer;

  const SubAspectContainerContext({
    required this.buildContext,
    required this.options,
    required this.showControls,
    required this.width,
    required this.height,
    required this.child,
    required this.defaultContainer,
  });
}

class SubAspectWrapperContext {
  final BuildContext buildContext;
  final SubAspectComponentOptions options;
  final bool showControls;
  final Widget container;
  final Widget defaultWrapper;

  const SubAspectWrapperContext({
    required this.buildContext,
    required this.options,
    required this.showControls,
    required this.container,
    required this.defaultWrapper,
  });
}

typedef SubAspectContentBuilder = Widget Function(
  SubAspectContentContext context,
);

typedef SubAspectContainerBuilder = Widget Function(
  SubAspectContainerContext context,
);

typedef SubAspectWrapperBuilder = Widget Function(
  SubAspectWrapperContext context,
);

/// Configuration options for the `SubAspectComponent` widget.
///
/// Defines styling, sizing, and builder hooks for a responsive sub-video area
/// (e.g., screenshare preview, secondary video, controls overlay) typically positioned
/// at the bottom-left of the screen. Supports dynamic height calculation based on
/// viewport dimensions and control visibility state.
///
/// **Properties:**
/// - `backgroundColor`: Default background color when `containerDecoration` is null
/// - `children`: List of widgets to render in Stack (e.g., video stream, audio cards, controls)
/// - `showControls`: Visibility flag (true = container visible with computed dimensions; false = height collapses to 0)
/// - `containerWidthFraction`: Optional width as fraction of screen width (0.0-1.0). Defaults to 1.0 (full width)
/// - `containerHeightFraction`: Optional height as fraction of screen height (0.0-1.0). Takes precedence over `defaultFractionSub`
/// - `defaultFractionSub`: Height calculation fallback. If ≤1: fraction of screen height (e.g., 0.3 = 30%); if >1: fixed pixel height (e.g., 40.0 = 40px). Defaults to 40.0 pixels
/// - `padding`: Inner padding for container content area
/// - `margin`: Outer margin around container
/// - `alignment`: Child alignment within container (defaults to Alignment.centerLeft)
/// - `containerDecoration`: Optional BoxDecoration for borders, gradients, shadows (overrides `backgroundColor`)
/// - `clipBehavior`: Clipping behavior for Stack children (defaults to Clip.hardEdge)
/// - `contentBuilder`: Hook to wrap Stack of children (receives `defaultContent` = Stack with all children)
/// - `containerBuilder`: Hook to wrap Container with dimensions/styling (receives `child` = processed content, computed `width`/`height`)
/// - `wrapperBuilder`: Hook to wrap Positioned widget (receives `container` = styled container, `defaultWrapper` = Positioned at bottom-left)
///
/// **Dimension Calculation Logic:**
/// ```
/// Width:
///   = (containerWidthFraction ?? 1.0) * screenWidth
///   Clamped to [0.0, 1.0] range before multiplication
///
/// Height (when showControls = true):
///   If containerHeightFraction provided:
///     = containerHeightFraction * screenHeight (clamped to [0.0, 1.0])
///   Else if 0 < defaultFractionSub ≤ 1:
///     = defaultFractionSub * screenHeight (fractional mode)
///   Else if defaultFractionSub > 1:
///     = defaultFractionSub (fixed pixel mode)
///   Else:
///     = 40 pixels (minimum fallback)
///
/// Height (when showControls = false):
///   = 0 (collapses container)
/// ```
///
/// **Builder Hook Flow:**
/// ```
/// 1. Create Stack with children → defaultContent
/// 2. contentBuilder?(defaultContent) → content
/// 3. Wrap content in Container with dimensions → defaultContainer
/// 4. containerBuilder?(content, width, height) → container
/// 5. Wrap container in Positioned(bottom: 0, left: 0) → defaultWrapper
/// 6. wrapperBuilder?(container) → wrapper
/// 7. Wrap wrapper in Visibility(showControls)
/// ```
///
/// **Common Configurations:**
/// ```dart
/// // 1. Fixed pixel height (e.g., 150px control bar at bottom)
/// SubAspectComponentOptions(
///   backgroundColor: Colors.black87,
///   children: [controlButtonsWidget],
///   defaultFractionSub: 150.0, // pixels
/// )
///
/// // 2. Fractional height (e.g., 30% of screen for screenshare preview)
/// SubAspectComponentOptions(
///   backgroundColor: Colors.grey[900]!,
///   children: [screensharePreview],
///   containerHeightFraction: 0.3, // 30% of screen height
///   containerWidthFraction: 0.5,   // 50% of screen width
/// )
///
/// // 3. Custom positioning (e.g., top-right instead of bottom-left)
/// SubAspectComponentOptions(
///   backgroundColor: Colors.transparent,
///   children: [miniVideoPreview],
///   defaultFractionSub: 0.25,
///   wrapperBuilder: (context) {
///     return Positioned(
///       top: 16,
///       right: 16,
///       child: context.container,
///     );
///   },
/// )
///
/// // 4. Rounded container with shadow
/// SubAspectComponentOptions(
///   backgroundColor: Colors.white,
///   children: [videoStreamWidget],
///   defaultFractionSub: 200.0,
///   containerDecoration: BoxDecoration(
///     borderRadius: BorderRadius.circular(12),
///     boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 8)],
///   ),
///   padding: EdgeInsets.all(8),
///   margin: EdgeInsets.all(16),
/// )
/// ```
///
/// **Typical Use Cases:**
/// - Screenshare preview area (fractional sizing, positioned at bottom)
/// - Control button overlay (fixed pixel height, full width)
/// - Secondary video stream (mini player in corner)
/// - Audio-only participant grid (compact list at bottom)
/// - Meeting timer/status bar (fixed height, left-aligned)
class SubAspectComponentOptions {
  final Color backgroundColor;
  final List<Widget> children;
  final bool showControls;
  final double? containerWidthFraction;
  final double? containerHeightFraction;
  final double defaultFractionSub;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final AlignmentGeometry alignment;
  final BoxDecoration? containerDecoration;
  final Clip clipBehavior;
  final SubAspectContentBuilder? contentBuilder;
  final SubAspectContainerBuilder? containerBuilder;
  final SubAspectWrapperBuilder? wrapperBuilder;

  const SubAspectComponentOptions({
    required this.backgroundColor,
    required this.children,
    this.showControls = true,
    this.containerWidthFraction,
    this.containerHeightFraction,
    this.defaultFractionSub = 40.0,
    this.padding,
    this.margin,
    this.alignment = Alignment.centerLeft,
    this.containerDecoration,
    this.clipBehavior = Clip.hardEdge,
    this.contentBuilder,
    this.containerBuilder,
    this.wrapperBuilder,
  });
}

typedef SubAspectComponentType = Widget Function({
  required SubAspectComponentOptions options,
});

/// A stateful widget rendering a responsive sub-video area with dynamic dimension management.
///
/// Displays a secondary video/content area (typically positioned at bottom-left) that adapts
/// to screen dimensions and control visibility state. Commonly used for screenshare previews,
/// mini video players, control overlays, or audio participant grids.
///
/// **Lifecycle & State Management:**
/// - Tracks computed `_width` and `_height` based on screen size and configuration
/// - Recalculates dimensions in `didChangeDependencies()` (screen rotation, initial build)
/// - Recalculates dimensions in `didUpdateWidget()` when showControls, fractions, or defaultFractionSub change
/// - Uses `MediaQuery.of(context).size` to get current screen dimensions
///
/// **Rendering Pipeline:**
/// ```
/// 1. Create Stack with children (clipBehavior applied)
/// 2. Call contentBuilder (if provided) to wrap Stack
/// 3. Build Container with:
///    - Computed width (_width)
///    - Computed height (_height if showControls=true, else 0)
///    - Decoration (containerDecoration or backgroundColor)
///    - Padding, margin, alignment
/// 4. Call containerBuilder (if provided) to customize Container
/// 5. Wrap in Positioned(bottom: 0, left: 0) for absolute positioning
/// 6. Call wrapperBuilder (if provided) to customize positioning
/// 7. Wrap in Visibility widget (visible only if showControls=true)
/// ```
///
/// **Dimension Calculation Details:**
/// ```dart
/// // Width calculation:
/// widthFraction = (containerWidthFraction ?? 1.0).clamp(0.0, 1.0);
/// _width = widthFraction * MediaQuery.of(context).size.width;
///
/// // Height calculation (only if showControls = true):
/// if (containerHeightFraction != null) {
///   heightFraction = containerHeightFraction.clamp(0.0, 1.0);
///   _height = heightFraction * screenHeight;
/// } else if (0 < defaultFractionSub <= 1) {
///   _height = defaultFractionSub * screenHeight; // fractional mode
/// } else if (defaultFractionSub > 1) {
///   _height = defaultFractionSub; // fixed pixel mode
/// } else {
///   _height = 40; // minimum fallback
/// }
///
/// // When showControls = false:
/// _height = 0; (container collapses, Visibility hides entire widget)
/// ```
///
/// **Builder Hook Priorities:**
/// 1. `contentBuilder`: Wrap Stack of children (e.g., add border around entire content area)
/// 2. `containerBuilder`: Customize Container with dimensions (e.g., apply gradient, adjust padding)
/// 3. `wrapperBuilder`: Customize Positioned widget (e.g., reposition from bottom-left to top-right)
///
/// **Common Use Cases:**
/// 1. **Screenshare Preview at Bottom:**
///    ```dart
///    SubAspectComponent(
///      options: SubAspectComponentOptions(
///        backgroundColor: Colors.black,
///        children: [
///          VideoCard(
///            options: VideoCardOptions(
///              videoStream: screenshareStream,
///              participant: presenter,
///              parameters: parameters,
///            ),
///          ),
///        ],
///        showControls: parameters.shared, // visible only when screensharing active
///        containerHeightFraction: 0.3, // 30% of screen height
///        containerWidthFraction: 0.5,  // 50% of screen width
///        padding: EdgeInsets.all(8),
///        containerDecoration: BoxDecoration(
///          border: Border.all(color: Colors.blue, width: 2),
///          borderRadius: BorderRadius.circular(8),
///        ),
///      ),
///    )
///    ```
///
/// 2. **Fixed-Height Control Bar:**
///    ```dart
///    SubAspectComponent(
///      options: SubAspectComponentOptions(
///        backgroundColor: Colors.grey[900]!,
///        children: [
///          ControlButtonsComponent(
///            options: ControlButtonsComponentOptions(
///              buttons: allButtons,
///              parameters: parameters,
///            ),
///          ),
///        ],
///        showControls: true,
///        defaultFractionSub: 80.0, // 80 pixels fixed height
///        alignment: Alignment.center,
///      ),
///    )
///    ```
///
/// 3. **Mini Video Player (Top-Right):**
///    ```dart
///    SubAspectComponent(
///      options: SubAspectComponentOptions(
///        backgroundColor: Colors.black,
///        children: [
///          VideoCard(
///            options: VideoCardOptions(
///              videoStream: localStream,
///              participant: localParticipant,
///              parameters: parameters,
///            ),
///          ),
///        ],
///        showControls: true,
///        defaultFractionSub: 0.2, // 20% of screen height
///        containerWidthFraction: 0.25, // 25% of screen width
///        wrapperBuilder: (context) {
///          return Positioned(
///            top: 16,
///            right: 16,
///            child: context.container,
///          );
///        },
///        containerDecoration: BoxDecoration(
///          borderRadius: BorderRadius.circular(12),
///          boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 6)],
///        ),
///      ),
///    )
///    ```
///
/// 4. **Audio Participant Grid (Compact):**
///    ```dart
///    SubAspectComponent(
///      options: SubAspectComponentOptions(
///        backgroundColor: Colors.transparent,
///        children: [
///          AudioGrid(
///            options: AudioGridOptions(
///              componentsToRender: audioCards,
///            ),
///          ),
///        ],
///        showControls: parameters.audioOnlyRoom,
///        defaultFractionSub: 100.0, // 100 pixels for audio cards
///        padding: EdgeInsets.symmetric(horizontal: 8),
///      ),
///    )
///    ```
///
/// **Override Integration:**
/// Integrates with `MediasfuUICustomOverrides` for global styling:
/// ```dart
/// overrides: MediasfuUICustomOverrides(
///   subAspectComponentOptions: ComponentOverride<SubAspectComponentOptions>(
///     builder: (existingOptions) => SubAspectComponentOptions(
///       backgroundColor: existingOptions.backgroundColor,
///       children: existingOptions.children,
///       showControls: existingOptions.showControls,
///       defaultFractionSub: 0.25, // Always use 25% height
///       containerWidthFraction: 0.4, // Always use 40% width
///       containerDecoration: BoxDecoration(
///         gradient: LinearGradient(
///           colors: [Colors.black87, Colors.grey[850]!],
///         ),
///         borderRadius: BorderRadius.circular(16),
///       ),
///       padding: EdgeInsets.all(12),
///       margin: EdgeInsets.only(bottom: 16, left: 16),
///     ),
///   ),
/// ),
/// ```
///
/// **Responsive Behavior:**
/// - Dimensions recalculate automatically on orientation change (via `didChangeDependencies`)
/// - Width/height update immediately when fractions change (via `didUpdateWidget`)
/// - Container collapses to zero height when `showControls = false` (smooth hide/show)
/// - Fractional sizing adapts to different screen sizes (tablet, phone, desktop)
///
/// **State Update Triggers:**
/// - `showControls` change → height recalculated (collapse or expand)
/// - `containerWidthFraction` change → width recalculated
/// - `containerHeightFraction` change → height recalculated
/// - `defaultFractionSub` change → height recalculated (if containerHeightFraction null)
/// - Screen rotation → all dimensions recalculated (didChangeDependencies)
///
/// **Performance Notes:**
/// - Stateful widget (maintains _width and _height state)
/// - setState() called only when dimensions change (not every frame)
/// - Builder hooks called during every build (not cached)
/// - Positioned widget prevents layout reflow (absolute positioning)
/// - Visibility widget efficiently hides without removing from tree
///
/// **Implementation Details:**
/// - Uses `MediaQuery.of(context).size` for screen dimensions
/// - Clamps fractions to [0.0, 1.0] range to prevent invalid sizes
/// - Checks `mounted` before calling setState() (prevents errors after dispose)
/// - Stack uses `clipBehavior` from options (defaults to Clip.hardEdge)
/// - Container dimensions default to full width if no fraction provided
/// - Positioned always places container at bottom-left unless wrapperBuilder overrides
///
/// **Typical Usage Context:**
/// - Secondary video area in video conferencing
/// - Screenshare preview overlay
/// - Control button panel at bottom
/// - Mini participant video (picture-in-picture style)
/// - Audio-only participant list (compact view)
class SubAspectComponent extends StatefulWidget {
  final SubAspectComponentOptions options;

  const SubAspectComponent({super.key, required this.options});

  @override
  State<SubAspectComponent> createState() => _SubAspectComponentState();
}

class _SubAspectComponentState extends State<SubAspectComponent> {
  double _height = 0;
  double _width = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateAspectStyles();
  }

  @override
  void didUpdateWidget(covariant SubAspectComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.options.showControls != widget.options.showControls ||
        oldWidget.options.containerWidthFraction !=
            widget.options.containerWidthFraction ||
        oldWidget.options.containerHeightFraction !=
            widget.options.containerHeightFraction ||
        oldWidget.options.defaultFractionSub !=
            widget.options.defaultFractionSub) {
      _updateAspectStyles();
    }
  }

  void _updateAspectStyles() {
    final Size size = MediaQuery.of(context).size;

    final double widthFraction =
        (widget.options.containerWidthFraction ?? 1.0).clamp(0.0, 1.0);
    final double computedWidth = widthFraction * size.width;

    double computedHeight = 0;
    if (widget.options.showControls) {
      if (widget.options.containerHeightFraction != null) {
        final double heightFraction =
            widget.options.containerHeightFraction!.clamp(0.0, 1.0);
        computedHeight = heightFraction * size.height;
      } else if (widget.options.defaultFractionSub > 0 &&
          widget.options.defaultFractionSub <= 1) {
        computedHeight = widget.options.defaultFractionSub * size.height;
      } else if (widget.options.defaultFractionSub > 1) {
        computedHeight = widget.options.defaultFractionSub;
      } else {
        computedHeight = 40;
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _width = computedWidth;
      _height = computedHeight;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get bottom safe area for iOS home indicator/gesture bar
    final double bottomSafeArea = MediaQuery.of(context).viewPadding.bottom;

    final Widget defaultContent = Stack(
      clipBehavior: widget.options.clipBehavior,
      children: widget.options.children,
    );

    final Widget content = widget.options.contentBuilder?.call(
          SubAspectContentContext(
            buildContext: context,
            options: widget.options,
            showControls: widget.options.showControls,
            defaultContent: defaultContent,
          ),
        ) ??
        defaultContent;

    final BoxDecoration decoration = widget.options.containerDecoration ??
        BoxDecoration(color: widget.options.backgroundColor);

    final Widget defaultContainer = Container(
      width: _width,
      height: widget.options.showControls ? _height : 0,
      decoration: decoration,
      padding: widget.options.padding,
      margin: widget.options.margin,
      alignment: widget.options.alignment,
      child: content,
    );

    final Widget container = widget.options.containerBuilder?.call(
          SubAspectContainerContext(
            buildContext: context,
            options: widget.options,
            showControls: widget.options.showControls,
            width: _width,
            height: _height,
            child: content,
            defaultContainer: defaultContainer,
          ),
        ) ??
        defaultContainer;

    final Widget defaultWrapper = Positioned(
      bottom: bottomSafeArea, // Account for iOS home indicator
      left: 0,
      child: container,
    );

    final Widget wrapper = widget.options.wrapperBuilder?.call(
          SubAspectWrapperContext(
            buildContext: context,
            options: widget.options,
            showControls: widget.options.showControls,
            container: container,
            defaultWrapper: defaultWrapper,
          ),
        ) ??
        defaultWrapper;

    return Visibility(
      visible: widget.options.showControls,
      child: wrapper,
    );
  }
}
