// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';

/// `MainAspectComponentOptions` - Configuration options for the `MainAspectComponent`.
///
/// ### Properties:
/// - `backgroundColor` (`Color`): Background color of the component.
/// - `children` (`List<Widget>`): List of child widgets displayed inside the component.
/// - `showControls` (`bool`): Determines if additional UI controls are displayed (default is `true`).
/// - `containerWidthFraction` (`double`): Fraction of the screen width that the container occupies (default is `1.0`).
/// - `containerHeightFraction` (`double`): Fraction of the screen height that the container occupies (default is `1.0`).
/// - `defaultFraction` (`double`): Default fraction value used to adjust dimensions when `showControls` is enabled (default is `0.94`).
/// - `updateIsWideScreen`, `updateIsMediumScreen`, `updateIsSmallScreen`: Callback functions for screen size changes, providing updates based on screen width breakpoints.
///
/// ### Example Usage:
/// ```dart
/// MainAspectComponentOptions(
///   backgroundColor: Colors.blue,
///   children: [
///     Text("Sample Text"),
///   ],
///   showControls: true,
///   containerWidthFraction: 0.8,
///   containerHeightFraction: 0.6,
///   defaultFraction: 0.9,
///   updateIsWideScreen: (isWide) => print('Wide screen: $isWide'),
///   updateIsMediumScreen: (isMedium) => print('Medium screen: $isMedium'),
///   updateIsSmallScreen: (isSmall) => print('Small screen: $isSmall'),
/// );
/// ```
///
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

/// `MainAspectComponent` - A responsive component adjusting dimensions based on screen size and optional controls.
///
/// ### Features:
/// - Resizes according to screen width and height, with optional padding and control visibility.
/// - Provides real-time screen size updates (e.g., `isWideScreen`, `isMediumScreen`, `isSmallScreen`) through callbacks.
/// - Listens to screen metrics changes for responsive layout updates in real-time.
///
/// ### Example Usage:
/// ```dart
/// MainAspectComponent(
///   options: MainAspectComponentOptions(
///     backgroundColor: Colors.green,
///     children: [Text("Content goes here")],
///     showControls: true,
///     containerWidthFraction: 0.9,
///     containerHeightFraction: 0.8,
///     defaultFraction: 0.85,
///     updateIsWideScreen: (isWide) => print("Wide screen? $isWide"),
///     updateIsMediumScreen: (isMedium) => print("Medium screen? $isMedium"),
///     updateIsSmallScreen: (isSmall) => print("Small screen? $isSmall"),
///   ),
/// );
/// ```
///
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
    final EdgeInsets safeAreaInsets = MediaQuery.of(context).padding +
        MediaQuery.of(context).systemGestureInsets;

    final double parentWidth =
        size.width * widget.options.containerWidthFraction;
    final double parentHeight = widget.options.showControls == true
        ? size.height *
            widget.options.containerHeightFraction *
            widget.options.defaultFraction
        : size.height * widget.options.containerHeightFraction -
            safeAreaInsets.top;

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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Calculate dimensions based on current screen size and fractions
    final Size size = MediaQuery.of(context).size;
    final EdgeInsets safeAreaInsets = MediaQuery.of(context).padding +
        MediaQuery.of(context).systemGestureInsets;

    final double parentWidth =
        size.width * widget.options.containerWidthFraction;
    final double parentHeight = widget.options.showControls
        ? size.height *
            widget.options.containerHeightFraction *
            widget.options.defaultFraction
        : size.height * widget.options.containerHeightFraction -
            safeAreaInsets.top;

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
