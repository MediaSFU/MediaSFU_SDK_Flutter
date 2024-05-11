import 'package:flutter/material.dart';

/// A widget that maintains aspect ratio based on the screen size and updates its dimensions dynamically.
///
/// Parameters:
/// - backgroundColor: The background color of the component.
/// - children: The widgets to be displayed inside the component.
/// - showControls: A boolean indicating whether to show controls.
/// - containerWidthFraction: The width fraction of the container.
/// - containerHeightFraction: The height fraction of the container.
/// - defaultFraction: The default fraction value.
/// - updateIsWideScreen: A function to update whether the screen is wide.
/// - updateIsMediumScreen: A function to update whether the screen is medium-sized.
/// - updateIsSmallScreen: A function to update whether the screen is small.
///
/// Example:
/// ```dart
/// MainAspectComponent(
///   backgroundColor: Colors.blue,
///   children: [
///     // Your widgets here
///   ],
///   showControls: true,
///   containerWidthFraction: 0.8,
///   containerHeightFraction: 0.6,
///   defaultFraction: 0.9,
///   updateIsWideScreen: (isWide) {},
///   updateIsMediumScreen: (isMedium) {},
///   updateIsSmallScreen: (isSmall) {},
/// )
/// ```

class MainAspectComponent extends StatefulWidget {
  final Color backgroundColor;
  final List<Widget> children;
  final bool showControls;
  final double containerWidthFraction;
  final double containerHeightFraction;
  final double defaultFraction;
  final Function(bool) updateIsWideScreen;
  final Function(bool) updateIsMediumScreen;
  final Function(bool) updateIsSmallScreen;

  // ignore: prefer_const_constructors_in_immutables
  MainAspectComponent({
    super.key,
    required this.backgroundColor,
    required this.children,
    this.showControls = true,
    this.containerWidthFraction = 1,
    this.containerHeightFraction = 1,
    this.defaultFraction = 0.94,
    required this.updateIsWideScreen,
    required this.updateIsMediumScreen,
    required this.updateIsSmallScreen,
  });

  @override
  // ignore: library_private_types_in_public_api
  _MainAspectComponentState createState() => _MainAspectComponentState();
}

class _MainAspectComponentState extends State<MainAspectComponent>
    with WidgetsBindingObserver {
  late double _height;
  late double _width;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _updateAspectStyles();
  }

  void _updateAspectStyles() {
    setState(() {
      final EdgeInsets safeAreaInsets = MediaQuery.of(context).padding +
          MediaQuery.of(context).systemGestureInsets;

      final Size size = MediaQuery.of(context).size;

      final parentWidth = (size.width) * widget.containerWidthFraction;
      final isWideScreen = parentWidth > 768;
      final isMediumScreen = parentWidth > 576 && parentWidth <= 768;
      final isSmallScreen = parentWidth <= 576;

      widget.updateIsWideScreen(isWideScreen);
      widget.updateIsMediumScreen(isMediumScreen);
      widget.updateIsSmallScreen(isSmallScreen);

      _height = widget.showControls
          ? (widget.containerHeightFraction *
                  (size.height - 0.0) *
                  widget.defaultFraction)
              .floorToDouble()
          : (widget.containerHeightFraction *
                  (size.height - safeAreaInsets.top))
              .floorToDouble();

      _width = (widget.containerWidthFraction * (size.width)).floorToDouble();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Call _updateAspectStyles() in the build method
    _updateAspectStyles();

    return Container(
      color: widget.backgroundColor,
      width: _width,
      height: _height,
      child: Stack(
        children: widget.children,
      ),
    );
  }
}
