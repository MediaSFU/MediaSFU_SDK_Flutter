import 'package:flutter/material.dart';

/// `FlexibleVideoOptions` - Configuration options for the `FlexibleVideo` widget.
///
/// ### Properties:
/// - `customWidth` (`double`): The width of the video container in pixels.
/// - `customHeight` (`double`): The height of the video container in pixels.
/// - `rows` (`int`): The number of rows in the video grid layout. (Note: Currently not utilized in the widget build.)
/// - `columns` (`int`): The number of columns in the video grid layout. (Note: Currently not utilized in the widget build.)
/// - `componentsToRender` (`List<Widget>`): A list of child widgets to display within the video container. Typically, these would be video streams or related UI components.
/// - `showAspect` (`bool`): Determines whether the video container should be visible. Defaults to `true`.
/// - `backgroundColor` (`Color`): The background color of the video container. Defaults to `Colors.transparent`.
///
/// ### Example Usage:
/// ```dart
/// FlexibleVideoOptions(
///   customWidth: 300.0,
///   customHeight: 200.0,
///   rows: 2,
///   columns: 3,
///   componentsToRender: [
///     VideoStreamWidget(userId: 'user1'),
///     VideoStreamWidget(userId: 'user2'),
///     // Add more video streams as needed
///   ],
///   showAspect: true,
///   backgroundColor: Colors.black,
/// );
/// ```
class FlexibleVideoOptions {
  final double customWidth;
  final double customHeight;
  final int rows;
  final int columns;
  final List<Widget> componentsToRender;
  final bool showAspect;
  final Color backgroundColor;

  const FlexibleVideoOptions(
      {required this.customWidth,
      required this.customHeight,
      required this.rows,
      required this.columns,
      required this.componentsToRender,
      this.showAspect = true,
      this.backgroundColor = Colors.transparent});
}

typedef FlexibleVideoType = Widget Function(
    {required FlexibleVideoOptions options});

/// `FlexibleVideo` - A widget that displays a customizable video container.
///
/// This widget provides a flexible container for video streams or related UI components.
/// It allows customization of dimensions, background color, and the content to render within.
/// The visibility of the container can be controlled via the `showAspect` option.
///
/// ### Example Usage:
/// ```dart
/// FlexibleVideo(
///   options: FlexibleVideoOptions(
///     customWidth: 300.0,
///     customHeight: 200.0,
///     rows: 2,
///     columns: 3,
///     componentsToRender: [
///       VideoStreamWidget(userId: 'user1'),
///       VideoStreamWidget(userId: 'user2'),
///       // Add more video streams as needed
///     ],
///     showAspect: true,
///     backgroundColor: Colors.black,
///   ),
/// );
/// ```

class FlexibleVideo extends StatelessWidget {
  final FlexibleVideoOptions options;

  const FlexibleVideo({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    final customWidth = options.customWidth;
    final customHeight = options.customHeight;
    final componentsToRender = options.componentsToRender;
    final showAspect = options.showAspect;

    return Visibility(
      visible: componentsToRender.isNotEmpty && showAspect,
      child: Container(
        key: ValueKey(componentsToRender),
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
