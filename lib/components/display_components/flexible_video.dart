import 'package:flutter/material.dart';

/// A flexible video grid widget that dynamically adjusts its size based on the number of rows and columns.
///
/// Parameters:
/// - customWidth: The custom width of the video grid.
/// - customHeight: The custom height of the video grid.
/// - rows: The number of rows in the grid.
/// - columns: The number of columns in the grid.
/// - componentsToRender: The list of video components to render in the grid.
/// - showAspect: A boolean indicating whether to show the aspect ratio.
/// - backgroundColor: The background color of the grid.
///
/// Example:
/// ```dart
/// FlexibleVideo(
///   customWidth: 300,
///   customHeight: 200,
///   rows: 2,
///   columns: 2,
///   componentsToRender: [VideoComponent1(), VideoComponent2()],
///   showAspect: true,
///   backgroundColor: Colors.black,
/// )
/// ```

class FlexibleVideo extends StatelessWidget {
  final double customWidth;
  final double customHeight;
  final int rows;
  final int columns;
  final List<Widget> componentsToRender;
  final bool showAspect;
  final Color backgroundColor;

  const FlexibleVideo({
    super.key,
    required this.customWidth,
    required this.customHeight,
    required this.rows,
    required this.columns,
    required this.componentsToRender,
    required this.showAspect,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate the total width and height of the grid

    return Visibility(
      visible: componentsToRender.isNotEmpty && showAspect,
      child: Container(
        width: customWidth,
        height: customHeight,
        color: const Color.fromARGB(255, 134, 150, 179), // backgroundColor,
        child: Center(
          child: componentsToRender.isNotEmpty ? componentsToRender[0] : null,
        ),
      ),
    );
  }
}
