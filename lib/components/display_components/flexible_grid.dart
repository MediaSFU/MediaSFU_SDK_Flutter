import 'package:flutter/material.dart';

/// `FlexibleGridOptions` - Configuration options for the `FlexibleGrid` widget.
///
/// ### Properties:
/// - `customWidth` (`double?`): Optional width of each grid item. If `null`, a default aspect ratio of 1.0 is used.
/// - `customHeight` (`double?`): Optional height of each grid item. If `null`, a default aspect ratio of 1.0 is used.
/// - `rows` (`int`): The number of rows in the grid layout. Must be greater than 0.
/// - `columns` (`int`): The number of columns in the grid layout. Must be greater than 0.
/// - `componentsToRender` (`List<Widget>`): A list of widgets (e.g., video streams or images) to render in the grid cells. If fewer components are provided than cells in the grid, the components are repeated.
/// - `backgroundColor` (`Color`): The background color of each grid cell. Defaults to `Colors.transparent`.
/// - `showAspect` (`bool`): Controls the visibility of the entire grid. If `false`, the grid is hidden. Defaults to `true`.
///
/// ### Example Usage:
/// ```dart
/// FlexibleGridOptions(
///   customWidth: 100.0,
///   customHeight: 100.0,
///   rows: 3,
///   columns: 3,
///   componentsToRender: [
///     Text("Item 1"),
///     Text("Item 2"),
///     Icon(Icons.star),
///   ],
///   backgroundColor: Colors.blueAccent,
///   showAspect: true,
/// );
/// ```
class FlexibleGridOptions {
  final double? customWidth;
  final double? customHeight;
  final int rows;
  final int columns;
  final List<Widget> componentsToRender;
  final Color backgroundColor;
  final bool showAspect;

  FlexibleGridOptions({
    required this.customWidth,
    required this.customHeight,
    required this.rows,
    required this.columns,
    required this.componentsToRender,
    this.backgroundColor = Colors.transparent,
    this.showAspect = true,
  });
}

typedef FlexibleGridType = Widget Function(
    {required FlexibleGridOptions options});

/// `FlexibleGrid` - A widget that displays a flexible grid layout based on specified rows and columns.
///
/// The `FlexibleGrid` widget uses the options provided in `FlexibleGridOptions` to construct a grid layout.
/// The grid cells can display a repeated pattern of components when there are fewer components than slots in the grid.
///
/// ### Example Usage:
/// ```dart
/// FlexibleGrid(
///   options: FlexibleGridOptions(
///     customWidth: 100.0,
///     customHeight: 100.0,
///     rows: 2,
///     columns: 2,
///     componentsToRender: [
///       Text("Component 1"),
///       Icon(Icons.star),
///       Icon(Icons.circle),
///     ],
///     backgroundColor: Colors.grey,
///   ),
/// );
/// ```
///
/// ### Notes:
/// - If there are fewer components than grid slots, the provided components are repeated across the grid.
/// - `customWidth` and `customHeight` determine the cell dimensions; otherwise, the cells use a default 1:1 aspect ratio.
class FlexibleGrid extends StatelessWidget {
  final FlexibleGridOptions options;

  const FlexibleGrid({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    if (options.columns <= 0 ||
        options.rows <= 0 ||
        options.componentsToRender.isEmpty) {
      // Handle invalid configuration
      return Container(); // or any other fallback widget
    }

    try {
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: options.columns > 1 ? options.columns : 1,
          crossAxisSpacing: 1,
          mainAxisSpacing: 1,
          childAspectRatio:
              options.customWidth != null && options.customHeight != null
                  ? options.customWidth! / options.customHeight!
                  : 1.0, // Default aspect ratio
        ),
        itemCount: options.rows * options.columns,
        itemBuilder: (BuildContext context, int index) {
          // Repeat components if fewer components are available than grid slots
          final component = options
              .componentsToRender[index % options.componentsToRender.length];
          return Container(
            color: options.backgroundColor,
            child: Center(child: component),
          );
        },
      );
    } catch (e) {
      return Container(); // or any other fallback widget
    }
  }
}
