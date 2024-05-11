import 'package:flutter/material.dart';

/// FlexibleGrid is a layout widget used to render a flexible grid of components.
///
/// It takes in the number of [rows] and [columns] to determine the grid layout.
/// The [componentsToRender] parameter specifies the list of widgets to be displayed within the grid.
/// The [showAspect] parameter controls the visibility of the widget.

class FlexibleGrid extends StatelessWidget {
  final double? customWidth;
  final double? customHeight;
  final int rows;
  final int columns;
  final List<Widget> componentsToRender;
  final bool showAspect;
  final Color backgroundColor;

  const FlexibleGrid({
    super.key,
    this.customWidth,
    this.customHeight,
    required this.rows,
    required this.columns,
    required this.componentsToRender,
    this.showAspect = false,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (columns <= 0 || rows <= 0 || componentsToRender.isEmpty) {
      // Handle invalid number of columns
      return Container(); // or any other fallback widget
    }

    try {
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns > 1 ? columns : 1,
          crossAxisSpacing: 1,
          mainAxisSpacing: 1,
          childAspectRatio: customWidth != null && customHeight != null
              ? customWidth! / customHeight!
              : 1, // Change the aspect ratio according to your need
        ),
        itemCount: rows * columns,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            color: backgroundColor,
            child: Center(
              child: componentsToRender[index % componentsToRender.length],
            ),
          );
        },
      );
    } catch (e) {
      return Container(); // or any other fallback widget
    }
  }
}
