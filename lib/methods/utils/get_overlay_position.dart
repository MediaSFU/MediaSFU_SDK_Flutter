/// Options for configuring the overlay position.
class GetOverlayPositionOptions {
  final String position;

  GetOverlayPositionOptions({required this.position});
}

typedef GetOverlayPositionType = Map<String, dynamic> Function(
    GetOverlayPositionOptions options);

/// Returns the overlay position based on the specified options.
///
/// The [options] parameter contains the desired position of the overlay.
/// The position can be one of the following values:
///   - 'topLeft': Returns the position with 'top' set to 0 and 'left' set to 0.
///   - 'topRight': Returns the position with 'top' set to 0 and 'right' set to 0.
///   - 'bottomLeft': Returns the position with 'bottom' set to 0 and 'left' set to 0.
///   - 'bottomRight': Returns the position with 'bottom' set to 0 and 'right' set to 0.
///   - Any other value: Returns an empty map.
///
/// Example usage:
/// ```dart
/// Map<String, dynamic> position = getOverlayPosition(GetOverlayPositionOptions(position: 'topLeft'));
/// print(position); // Output: {'top': 0, 'left': 0}
/// ```
Map<String, dynamic> getOverlayPosition(GetOverlayPositionOptions options) {
  switch (options.position) {
    case 'topLeft':
      return {'top': 0, 'left': 0};
    case 'topRight':
      return {'top': 0, 'right': 0};
    case 'bottomLeft':
      return {'bottom': 0, 'left': 0};
    case 'bottomRight':
      return {'bottom': 0, 'right': 0};
    default:
      return {};
  }
}
