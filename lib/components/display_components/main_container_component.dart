import 'package:flutter/material.dart';

/// A container component with customizable dimensions and background color.
///
/// Parameters:
/// - backgroundColor: The background color of the container.
/// - children: The widgets to be displayed inside the container.
/// - containerWidthFraction: The width fraction of the container.
/// - containerHeightFraction: The height fraction of the container.
/// - marginLeft: The margin from the left side of the container.
/// - marginRight: The margin from the right side of the container.
/// - marginTop: The margin from the top of the container.
/// - marginBottom: The margin from the bottom of the container.
///
/// Example:
/// ```dart
/// MainContainerComponent(
///   backgroundColor: Colors.blue,
///   children: [
///     // Your widgets here
///   ],
///   containerWidthFraction: 0.8,
///   containerHeightFraction: 0.6,
///   marginLeft: 10,
///   marginRight: 10,
///   marginTop: 20,
///   marginBottom: 20,
/// )
/// ```

class MainContainerComponent extends StatefulWidget {
  final Color backgroundColor;
  final List<Widget> children;
  final double? containerWidthFraction;
  final double? containerHeightFraction;
  final double marginLeft;
  final double marginRight;
  final double marginTop;
  final double marginBottom;

  const MainContainerComponent({
    super.key,
    required this.backgroundColor,
    required this.children,
    this.containerWidthFraction,
    this.containerHeightFraction,
    this.marginLeft = 0,
    this.marginRight = 0,
    this.marginTop = 0,
    this.marginBottom = 0,
  });

  @override
  // ignore: library_private_types_in_public_api
  _MainContainerComponentState createState() => _MainContainerComponentState();
}

class _MainContainerComponentState extends State<MainContainerComponent> {
  late double _height;
  late double _width;

  @override
  Widget build(BuildContext context) {
    final double windowHeight = MediaQuery.of(context).size.height - 0.0;
    final double windowWidth = MediaQuery.of(context).size.width;

    _height = widget.containerHeightFraction != null
        ? widget.containerHeightFraction! * windowHeight
        : windowHeight;

    _width = widget.containerWidthFraction != null
        ? widget.containerWidthFraction! * windowWidth
        : windowWidth;

    return Container(
      width: _width,
      height: _height,
      margin: EdgeInsets.fromLTRB(
        widget.marginLeft,
        widget.marginTop,
        widget.marginRight,
        widget.marginBottom,
      ),
      color: widget.backgroundColor,
      child: Stack(
        children: widget.children,
      ),
    );
  }
}
