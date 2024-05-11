import 'package:flutter/material.dart';

/// Returns the position of a modal based on the specified position, context, modal width, and modal height.
///
/// The position can be one of the following:
/// - 'center': Positions the modal at the center of the screen.
/// - 'topLeft': Positions the modal at the top left corner of the screen.
/// - 'topRight': Positions the modal at the top right corner of the screen.
/// - 'bottomLeft': Positions the modal at the bottom left corner of the screen.
/// - 'bottomRight': Positions the modal at the bottom right corner of the screen.
///
/// The `context` parameter is required to access the screen size using `MediaQuery.of(context).size`.
/// The `modalWidth` and `modalHeight` parameters specify the width and height of the modal, respectively.
///
/// Returns a map containing the 'top' and 'right' positions of the modal.

Map<String, double> getModalPosition(String position, BuildContext context,
    double modalWidth, double modalHeight) {
  final Size size = MediaQuery.of(context).size;
  switch (position) {
    case 'center':
      return {
        'top': ((size.height - modalHeight) / 2),
        'right': (size.width - modalWidth) / 2
      };
    case 'topLeft':
      return {'top': 0, 'right': size.width - modalWidth};
    case 'topRight':
      return {'top': 0, 'right': 0};
    case 'bottomLeft':
      return {
        'top': size.height - modalHeight,
        'right': size.width - modalWidth
      };
    case 'bottomRight':
    default:
      return {'top': size.height - modalHeight, 'right': 0};
  }
}
