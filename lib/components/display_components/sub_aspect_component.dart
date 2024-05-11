import 'package:flutter/material.dart';

/// SubAspectComponent - A widget for displaying a sub-aspect component with customizable background color and children.
///
/// This widget allows you to display a sub-aspect component with customizable background color and child widgets.
/// It provides options to control the visibility of the sub-aspect component and adjust its size.
///
/// The background color of the sub-aspect component.
/// final Color backgroundColor;
///
/// The list of child widgets to display within the sub-aspect component.
/// final List<Widget> children;
/// A flag indicating whether to show the controls of the sub-aspect component.
/// Defaults to true if not provided.
/// final bool showControls;

/// The fraction of the container's width that the sub-aspect component occupies.
/// Defaults to null if not provided.
/// final double? containerWidthFraction;

/// The fraction of the container's height that the sub-aspect component occupies.
/// Defaults to null if not provided.
/// final double? containerHeightFraction;

/// The default fraction (pixesl) used for calculating the size of the sub-aspect component.
/// Defaults to 40px if not provided.
/// final double defaultFractionSub;

class SubAspectComponent extends StatefulWidget {
  final Color backgroundColor;
  final List<Widget> children;
  final bool showControls;
  final double? containerWidthFraction;
  final double? containerHeightFraction;
  final double defaultFractionSub;

  const SubAspectComponent({
    super.key,
    required this.backgroundColor,
    required this.children,
    this.showControls = true,
    this.containerWidthFraction = 1,
    this.containerHeightFraction = 1,
    this.defaultFractionSub = 40,
  });

  @override
  // ignore: library_private_types_in_public_api
  _SubAspectComponentState createState() => _SubAspectComponentState();
}

class _SubAspectComponentState extends State<SubAspectComponent> {
  late double _height;
  late double _width;

  @override
  void initState() {
    super.initState();
    // Don't perform operations that depend on context here
    // Move it to the build() method or didChangeDependencies() method
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Perform operations that depend on context here
    _updateAspectStyles();
  }

  void _updateAspectStyles() {
    // ignore: unused_local_variable
    final EdgeInsets safeAreaInsets = MediaQuery.of(context).padding +
        MediaQuery.of(context).systemGestureInsets;
    final double windowWidth = MediaQuery.of(context).size.width;
    double subAspectFraction =
        widget.showControls ? widget.defaultFractionSub : 0;

    subAspectFraction = subAspectFraction > 0 && subAspectFraction < 40
        ? 40
        : subAspectFraction;

    setState(() {
      _height = widget.showControls ? subAspectFraction : 0;

      _width = widget.containerWidthFraction != null
          ? widget.containerWidthFraction! * windowWidth
          : windowWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.showControls,
      child: Positioned(
        bottom: 0,
        child: SizedBox(
          height: _height,
          width: _width,
          child: Container(
            color: widget.backgroundColor,
            child: Stack(
              children: widget.children,
            ),
          ),
        ),
      ),
    );
  }
}
