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

/// SubAspectComponentOptions - Configuration options for the `SubAspectComponent` widget.
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
      bottom: 0,
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
