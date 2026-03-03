// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';

/// Configuration options for the `MainAspectComponent` widget.
///
/// Defines styling, sizing fractions, and responsive callbacks for the primary video area.
/// This component typically occupies the main portion of the screen and adjusts dimensions
/// based on control visibility, screen size, and safe area insets.
///
/// **Properties:**
/// - `backgroundColor`: Background color for the container (visible when no children fill the area)
/// - `children`: List of widgets rendered in Stack (e.g., main video grid, participant cards, overlays)
/// - `showControls`: Visibility flag affecting height calculation (true = apply `defaultFraction` to height; false = subtract safe area top inset)
/// - `containerWidthFraction`: Width as fraction of screen width (0.0-1.0). Defaults to 1.0 (full width)
/// - `containerHeightFraction`: Height as fraction of screen height (0.0-1.0). Defaults to 1.0 (full height)
/// - `defaultFraction`: Height reduction factor when `showControls = true` (e.g., 0.94 = 94% height to reserve space for controls). Defaults to 0.94
/// - `updateIsWideScreen`: Callback invoked when wide screen state changes (parentWidth > 768 or aspectRatio > 1.5)
/// - `updateIsMediumScreen`: Callback invoked when medium screen state changes (576 < parentWidth ≤ 768)
/// - `updateIsSmallScreen`: Callback invoked when small screen state changes (parentWidth ≤ 576)
///
/// **Dimension Calculation Logic:**
/// ```
/// Width:
///   parentWidth = screenWidth * containerWidthFraction
///
/// Height (when showControls = true):
///   parentHeight = screenHeight * containerHeightFraction * defaultFraction
///   (Applies defaultFraction to reserve space for control bar)
///
/// Height (when showControls = false):
///   parentHeight = screenHeight * containerHeightFraction - safeAreaTop
///   (Subtracts safe area inset to avoid notch/status bar overlap)
/// ```
///
/// **Screen Size Breakpoints:**
/// ```
/// Small: parentWidth ≤ 576px (mobile portrait)
/// Medium: 576px < parentWidth ≤ 768px (mobile landscape, small tablets)
/// Wide: parentWidth > 768px OR aspectRatio > 1.5 (tablets, desktops, wide screens)
///
/// Special case: If aspectRatio > 1.5 (very wide screen), force isWideScreen=true
/// ```
///
/// **Callback Invocation:**
/// - Called in `initState()` (addPostFrameCallback) for initial state
/// - Called in `didChangeMetrics()` (WidgetsBindingObserver) on screen rotation, resize, or keyboard visibility change
/// - Callbacks update parent state to trigger responsive layout adjustments elsewhere
///
/// **Common Configurations:**
/// ```dart
/// // 1. Full-screen main video area with control bar space
/// MainAspectComponentOptions(
///   backgroundColor: Colors.black,
///   children: [mainVideoGrid],
///   showControls: true, // reserves 6% height for control bar (94% height)
///   containerWidthFraction: 1.0, // full width
///   containerHeightFraction: 1.0, // full height
///   defaultFraction: 0.94, // 94% height when controls visible
///   updateIsWideScreen: (isWide) => parameters.updateIsWideScreen(isWide),
///   updateIsMediumScreen: (isMed) => parameters.updateIsMediumScreen(isMed),
///   updateIsSmallScreen: (isSmall) => parameters.updateIsSmallScreen(isSmall),
/// )
///
/// // 2. Reduced width/height for picture-in-picture mode
/// MainAspectComponentOptions(
///   backgroundColor: Colors.grey[900]!,
///   children: [singleParticipantVideo],
///   showControls: false, // full height minus safe area
///   containerWidthFraction: 0.5, // 50% width
///   containerHeightFraction: 0.5, // 50% height
///   defaultFraction: 1.0, // no reduction (not applied when showControls=false)
///   updateIsWideScreen: (_) {},
///   updateIsMediumScreen: (_) {},
///   updateIsSmallScreen: (_) {},
/// )
///
/// // 3. Custom fraction for bottom control panel
/// MainAspectComponentOptions(
///   backgroundColor: Colors.black,
///   children: [participantGrid, audioIndicators],
///   showControls: true,
///   containerWidthFraction: 1.0,
///   containerHeightFraction: 1.0,
///   defaultFraction: 0.88, // reserve 12% height for larger control bar
///   updateIsWideScreen: (isWide) => updateLayoutMode(isWide),
///   updateIsMediumScreen: (isMed) => updateLayoutMode(!isWide && !isSmall),
///   updateIsSmallScreen: (isSmall) => updateLayoutMode(false),
/// )
/// ```
///
/// **Typical Use Cases:**
/// - Primary video conference area (main participant grid)
/// - Screenshare display area (presenter content)
/// - Single participant video (spotlight mode)
/// - Gallery view container (multiple participant tiles)
/// - Webinar stage area (hosts/speakers only)
class MainAspectComponentOptions {
  /// The background color of the component.
  final Color backgroundColor;

  /// The list of child widgets to be displayed inside the component.
  final List<Widget> children;

  /// A flag indicating whether to show controls.
  final bool showControls;

  /// The fraction of the screen width that the container should occupy.
  final double containerWidthFraction;

  /// The fraction of the screen height that the container should occupy.
  final double containerHeightFraction;

  /// The default fraction value used when [showControls] is true.
  final double defaultFraction;

  /// Callback to update whether the screen is wide.
  final Function(bool) updateIsWideScreen;

  /// Callback to update whether the screen is medium-sized.
  final Function(bool) updateIsMediumScreen;

  /// Callback to update whether the screen is small.
  final Function(bool) updateIsSmallScreen;

  /// Constructs a MainAspectComponentOptions object.
  const MainAspectComponentOptions({
    required this.backgroundColor,
    required this.children,
    this.showControls = true,
    this.containerWidthFraction = 1.0,
    this.containerHeightFraction = 1.0,
    this.defaultFraction = 0.94,
    required this.updateIsWideScreen,
    required this.updateIsMediumScreen,
    required this.updateIsSmallScreen,
  });
}

typedef MainAspectComponentType = Widget Function(
    {required MainAspectComponentOptions options});

/// A stateful widget rendering the primary responsive video area with real-time screen size detection.
///
/// Manages the main video/content container that adapts to screen dimensions, orientation changes,
/// and control visibility. Implements WidgetsBindingObserver to detect screen metric changes and
/// invokes callbacks to update parent state for responsive layout adjustments across the app.
///
/// **Lifecycle & Observers:**
/// - Implements `WidgetsBindingObserver` to listen for screen metric changes
/// - Registers observer in `initState()` (adds addPostFrameCallback for initial calculation)
/// - Removes observer in `dispose()` to prevent memory leaks
/// - `didChangeMetrics()` called automatically on screen rotation, resize, keyboard visibility
///
/// **Dimension Calculation (performed in `_updateAspectStyles()`):**
/// ```dart
/// // Computed dimensions:
/// parentWidth = screenWidth * containerWidthFraction
///
/// // Height depends on showControls flag:
/// if (showControls) {
///   parentHeight = screenHeight * containerHeightFraction * defaultFraction
///   // Example: 1920 * 1.0 * 0.94 = 1804.8px (reserves 6% for controls)
/// } else {
///   parentHeight = screenHeight * containerHeightFraction - safeAreaTop
///   // Example: 1920 * 1.0 - 44 = 1876px (full height minus notch)
/// }
/// ```
///
/// **Screen Size Classification Logic:**
/// ```dart
/// // Initial classification based on width:
/// isWideScreen = parentWidth > 768
/// isMediumScreen = parentWidth > 576 && parentWidth <= 768
/// isSmallScreen = parentWidth <= 576
///
/// // Override for very wide aspect ratios:
/// if (parentWidth > 1.5 * parentHeight) {
///   isWideScreen = true
///   isMediumScreen = false
///   isSmallScreen = false
/// }
/// // This handles landscape tablets/desktops with wide aspect ratios
/// ```
///
/// **Callback Execution Flow:**
/// ```
/// 1. Screen metric change detected (rotation, resize, keyboard)
/// 2. didChangeMetrics() called by WidgetsBinding
/// 3. _updateAspectStyles() calculates new dimensions
/// 4. Screen size breakpoints evaluated
/// 5. Callbacks invoked with new boolean states:
///    - updateIsWideScreen(bool)
///    - updateIsMediumScreen(bool)
///    - updateIsSmallScreen(bool)
/// 6. setState() called to trigger rebuild with new dimensions
/// 7. Parent state updates (via callbacks) trigger other responsive adjustments
/// ```
///
/// **Rendering Structure:**
/// ```
/// Container
///   ├─ color: backgroundColor
///   ├─ width: parentWidth (calculated)
///   ├─ height: parentHeight (calculated)
///   └─ child: Stack
///      ├─ children[0] (typically MainGridComponent)
///      ├─ children[1] (e.g., audio indicators)
///      └─ children[N] (e.g., overlays)
/// ```
///
/// **Common Use Cases:**
/// 1. **Full-Screen Video Conference:**
///    ```dart
///    MainAspectComponent(
///      options: MainAspectComponentOptions(
///        backgroundColor: Colors.black,
///        children: [
///          MainGridComponent(
///            options: MainGridComponentOptions(
///              mainSize: mainGridStream != null ? mainGridStream!.length : 0,
///              height: parameters.componentSizes.mainHeight,
///              width: parameters.componentSizes.mainWidth,
///              backgroundColor: Colors.grey[900]!,
///              children: mainGridStreams,
///              showAspect: showMainVideo,
///              timeBackgroundColor: Colors.green,
///              meetingProgressTime: parameters.meetingProgressTime,
///            ),
///          ),
///        ],
///        showControls: true, // reserves space for control bar
///        containerWidthFraction: 1.0,
///        containerHeightFraction: 1.0,
///        defaultFraction: 0.94, // 94% height for video, 6% for controls
///        updateIsWideScreen: (isWide) {
///          parameters.updateIsWideScreen(isWide);
///          // Trigger grid layout recalculation
///        },
///        updateIsMediumScreen: (isMed) {
///          parameters.updateIsMediumScreen(isMed);
///        },
///        updateIsSmallScreen: (isSmall) {
///          parameters.updateIsSmallScreen(isSmall);
///        },
///      ),
///    )
///    ```
///
/// 2. **Screenshare Display (No Control Bar):**
///    ```dart
///    MainAspectComponent(
///      options: MainAspectComponentOptions(
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
///        showControls: false, // full height minus safe area
///        containerWidthFraction: 1.0,
///        containerHeightFraction: 1.0,
///        defaultFraction: 1.0, // not applied when showControls=false
///        updateIsWideScreen: (isWide) => handleScreenResize(isWide),
///        updateIsMediumScreen: (_) {},
///        updateIsSmallScreen: (_) {},
///      ),
///    )
///    ```
///
/// 3. **Split-Screen Layout:**
///    ```dart
///    MainAspectComponent(
///      options: MainAspectComponentOptions(
///        backgroundColor: Colors.grey[900]!,
///        children: [
///          Row(
///            children: [
///              Expanded(child: videoGrid), // main participants
///              Expanded(child: screenshareView), // shared content
///            ],
///          ),
///        ],
///        showControls: true,
///        containerWidthFraction: 1.0,
///        containerHeightFraction: 1.0,
///        defaultFraction: 0.92, // slightly more space for controls
///        updateIsWideScreen: (isWide) {
///          // Switch to vertical layout if not wide
///          if (!isWide) {
///            updateLayout(LayoutMode.vertical);
///          } else {
///            updateLayout(LayoutMode.horizontal);
///          }
///        },
///        updateIsMediumScreen: (_) {},
///        updateIsSmallScreen: (_) {},
///      ),
///    )
///    ```
///
/// 4. **Responsive Gallery Mode:**
///    ```dart
///    MainAspectComponent(
///      options: MainAspectComponentOptions(
///        backgroundColor: Colors.black,
///        children: [
///          FlexibleGrid(
///            options: FlexibleGridOptions(
///              customWidth: parameters.componentSizes.mainWidth,
///              customHeight: parameters.componentSizes.mainHeight,
///              rows: parameters.gridRows,
///              columns: parameters.gridCols,
///              componentsToRender: allParticipantCards,
///              backgroundColor: Colors.transparent,
///            ),
///          ),
///        ],
///        showControls: true,
///        containerWidthFraction: 1.0,
///        containerHeightFraction: 1.0,
///        defaultFraction: 0.94,
///        updateIsWideScreen: (isWide) {
///          // Adjust grid dimensions based on screen size
///          parameters.updateIsWideScreen(isWide);
///          if (isWide) {
///            parameters.updateGridCols(4); // more columns on wide screens
///          } else {
///            parameters.updateGridCols(2); // fewer columns on narrow screens
///          }
///        },
///        updateIsMediumScreen: (isMed) {
///          parameters.updateIsMediumScreen(isMed);
///          if (isMed) parameters.updateGridCols(3);
///        },
///        updateIsSmallScreen: (isSmall) {
///          parameters.updateIsSmallScreen(isSmall);
///          if (isSmall) parameters.updateGridCols(1);
///        },
///      ),
///    )
///    ```
///
/// **Override Integration:**
/// Override not typically used for MainAspectComponent (core layout component),
/// but dimensions can be influenced via parameters:
/// ```dart
/// // In parameters initialization:
/// parameters.updateComponentSizes(ComponentSizesType(
///   mainHeight: MediaQuery.of(context).size.height * 0.94,
///   mainWidth: MediaQuery.of(context).size.width,
///   otherHeight: MediaQuery.of(context).size.height * 0.06,
///   otherWidth: MediaQuery.of(context).size.width,
/// ));
/// ```
///
/// **Responsive Behavior:**
/// - Automatically recalculates dimensions on orientation change (portrait ↔ landscape)
/// - Updates screen size states when keyboard appears/disappears (height change)
/// - Adjusts for safe area insets (notch, status bar) when showControls=false
/// - Invokes callbacks to propagate screen size changes to parent state
/// - Rebuilds only when dimensions change (not on every frame)
///
/// **State Update Triggers:**
/// - Orientation change → didChangeMetrics() → _updateAspectStyles() → callbacks + setState()
/// - Screen resize (desktop window) → didChangeMetrics() → recalculation
/// - Keyboard visibility change → didChangeMetrics() → height recalculation
/// - Initial build → addPostFrameCallback → _updateAspectStyles()
/// - showControls prop change → widget update → build with new height logic
///
/// **Performance Notes:**
/// - Stateful widget (maintains no internal state beyond component lifecycle)
/// - Uses WidgetsBindingObserver for efficient screen metric listening
/// - Callbacks invoked only on actual dimension changes (not every frame)
/// - setState() called only when screen metrics change (efficient rebuilds)
/// - Stack renders all children without lazy loading (suitable for small child count)
///
/// **Implementation Details:**
/// - Calculates parentWidth/parentHeight fresh on every build (no caching)
/// - Safe area insets use only MediaQuery.padding (not systemGestureInsets)
/// - Aspect ratio override (width > 1.5 * height) handles ultra-wide displays
/// - Checks `mounted` before setState() to prevent errors after dispose
/// - Container uses calculated dimensions (no intrinsic sizing)
///
/// **Typical Usage Context:**
/// - Primary video area in video conferencing apps
/// - Main stage for webinar/broadcast applications
/// - Central content area for screenshare display
/// - Gallery view container for participant grid
/// - Spotlight mode for single active speaker
class MainAspectComponent extends StatefulWidget {
  final MainAspectComponentOptions options;

  const MainAspectComponent({super.key, required this.options});

  @override
  _MainAspectComponentState createState() => _MainAspectComponentState();
}

class _MainAspectComponentState extends State<MainAspectComponent>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initial calculation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateAspectStyles();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Called when the screen metrics change (e.g., orientation, size).
  @override
  void didChangeMetrics() {
    _updateAspectStyles();
  }

  /// Updates aspect styles and invokes callbacks based on current screen size.
  void _updateAspectStyles() {
    final Size size = MediaQuery.of(context).size;
    final EdgeInsets safeAreaInsets = MediaQuery.of(context).padding;

    final double parentWidth =
        size.width * widget.options.containerWidthFraction;

    // Subtract only safe area padding (status bar, nav bar).
    // systemGestureInsets is excluded — it affects touch, not layout.
    // The outer SafeArea zeros out padding for sides it consumes.
    final double availableHeight =
        size.height - safeAreaInsets.top - safeAreaInsets.bottom;
    final double parentHeight = widget.options.showControls == true
        ? availableHeight *
            widget.options.containerHeightFraction *
            widget.options.defaultFraction
        : availableHeight * widget.options.containerHeightFraction;

    bool isWideScreen = parentWidth > 768;
    bool isMediumScreen = parentWidth > 576 && parentWidth <= 768;
    bool isSmallScreen = parentWidth <= 576;

    if (!isWideScreen && parentWidth > 1.5 * parentHeight) {
      isWideScreen = true;
      isMediumScreen = false;
      isSmallScreen = false;
    }

    // Update screen size states via callbacks
    widget.options.updateIsWideScreen(isWideScreen);
    widget.options.updateIsMediumScreen(isMediumScreen);
    widget.options.updateIsSmallScreen(isSmallScreen);

    // Trigger a rebuild to adjust dimensions
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Calculate dimensions based on current screen size and fractions
    final Size size = MediaQuery.of(context).size;
    final EdgeInsets safeAreaInsets = MediaQuery.of(context).padding;

    final double parentWidth =
        size.width * widget.options.containerWidthFraction;

    // Subtract only safe area padding (status bar, nav bar).
    // systemGestureInsets is excluded — it affects touch, not layout.
    // The outer SafeArea zeros out padding for sides it consumes.
    final double availableHeight =
        size.height - safeAreaInsets.top - safeAreaInsets.bottom;
    final double parentHeight = widget.options.showControls
        ? availableHeight *
            widget.options.containerHeightFraction *
            widget.options.defaultFraction
        : availableHeight * widget.options.containerHeightFraction;

    return Container(
      color: widget.options.backgroundColor,
      width: parentWidth,
      height: parentHeight,
      child: Stack(
        children: widget.options.children,
      ),
    );
  }
}
