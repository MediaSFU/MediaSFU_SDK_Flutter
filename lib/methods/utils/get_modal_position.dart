import 'package:flutter/material.dart';

/// Options for configuring the modal position.
class GetModalPositionOptions {
  final String position;
  final double modalWidth;
  final double modalHeight;
  final BuildContext context;

  GetModalPositionOptions({
    required this.position,
    required this.modalWidth,
    required this.modalHeight,
    required this.context,
  });
}

typedef GetModalPositionType = Map<String, double> Function(
    GetModalPositionOptions options);

/// Returns the position of a modal based on the specified options.
///
/// The `options` parameter specifies the desired position of the modal:
///   - 'center': Positions the modal at the center of the screen.
///   - 'topLeft': Positions the modal at the top left corner of the screen.
///   - 'topRight': Positions the modal at the top right corner of the screen.
///   - 'bottomLeft': Positions the modal at the bottom left corner of the screen.
///   - 'bottomRight': Positions the modal at the bottom right corner of the screen.
///
/// The `context` parameter is required to access the screen size using `MediaQuery.of(context).size`.
/// The `modalWidth` and `modalHeight` parameters specify the width and height of the modal.
///
/// Example usage:
/// ```dart
/// final options = GetModalPositionOptions(
///  position: 'center',
/// modalWidth: 200,
/// modalHeight: 100,
/// context: context,
/// );
/// final modalPosition = getModalPosition(options, context, 200, 100);
/// ```
/// Returns a map containing the top and right positions of the modal.
/// The top position is the distance from the top of the screen, and the right position is the distance from the right of the screen.
/// The modal position is calculated based on the specified options and screen size.
/// The modal width and height are used to center the modal on the screen.
/// The modal is positioned at the top left, top right, bottom left, or bottom right corner of the screen.
/// The modal is positioned at the center of the screen.
/// The modal is positioned at the top right corner of the screen.
///
///

Map<String, double> getModalPosition(GetModalPositionOptions options) {
  final modalWidth = options.modalWidth;
  final modalHeight = options.modalHeight;
  final context = options.context;

  final Size size = MediaQuery.of(context).size;

  switch (options.position) {
    case 'center':
      return {
        'top': (size.height - modalHeight) / 2,
        'right': (size.width - modalWidth) / 2,
      };
    case 'topLeft':
      return {'top': 0, 'right': size.width - modalWidth};
    case 'topRight':
      return {'top': 0, 'right': 0};
    case 'bottomLeft':
      return {
        'top': size.height - modalHeight,
        'right': size.width - modalWidth,
      };
    case 'bottomRight':
    default:
      return {'top': size.height - modalHeight, 'right': 0};
  }
}
