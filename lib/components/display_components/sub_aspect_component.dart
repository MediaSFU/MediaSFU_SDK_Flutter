import 'package:flutter/material.dart';

/// SubAspectComponentOptions - Configuration options for the `SubAspectComponent` widget.
class SubAspectComponentOptions {
  final Color backgroundColor;
  final List<Widget> children;
  final bool showControls;
  final double? containerWidthFraction;
  final double? containerHeightFraction;
  final double defaultFractionSub;

  const SubAspectComponentOptions({
    required this.backgroundColor,
    required this.children,
    this.showControls = true,
    this.containerWidthFraction,
    this.containerHeightFraction,
    this.defaultFractionSub = 40.0,
  });
}

typedef SubAspectComponentType = Widget Function(
    {required SubAspectComponentOptions options});

/// `SubAspectComponent` - A widget for displaying a sub-aspect component with customizable features.
///
/// This widget allows users to display a sub-aspect component with options for background color, control visibility,
/// and scaling based on the viewport.
///
/// ### Properties:
/// - `backgroundColor`: Background color of the component.
/// - `children`: List of child widgets to render within the component.
/// - `showControls`: Flag to determine if controls should be visible. Defaults to true.
/// - `containerWidthFraction`: Fraction of the container width the component occupies. Defaults to full width.
/// - `containerHeightFraction`: Fraction of the container height the component occupies. Defaults to full height.
/// - `defaultFractionSub`: Default height fraction in pixels if controls are visible. Defaults to 40.0.
///
/// ### Example Usage:
/// ```dart
/// SubAspectComponent(
///   options: SubAspectComponentOptions(
///     backgroundColor: Colors.black,
///     children: [Text('Content goes here')],
///     showControls: true,
///     containerWidthFraction: 0.5,
///     containerHeightFraction: 0.5,
///     defaultFractionSub: 40.0,
///   ),
/// );
/// ```
class SubAspectComponent extends StatefulWidget {
  final SubAspectComponentOptions options;

  const SubAspectComponent({super.key, required this.options});

  @override
  _SubAspectComponentState createState() => _SubAspectComponentState();
}

class _SubAspectComponentState extends State<SubAspectComponent> {
  late double _height;
  late double _width;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateAspectStyles();
  }

  void _updateAspectStyles() {
    final double windowWidth = MediaQuery.of(context).size.width;

    double subAspectFraction =
        widget.options.showControls ? widget.options.defaultFractionSub : 0;

    subAspectFraction = subAspectFraction > 0 && subAspectFraction < 40
        ? 40
        : subAspectFraction;

    if (!mounted) return;
    setState(() {
      _height = widget.options.showControls ? subAspectFraction : 0;
      _width = (widget.options.containerWidthFraction ?? 1.0) * windowWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.options.showControls,
      child: Positioned(
        bottom: 0,
        child: Container(
          width: _width,
          height: widget.options.showControls ? _height : 0,
          color: widget.options.backgroundColor,
          child: Stack(
            children: widget.options.children,
          ),
        ),
      ),
    );
  }
}
