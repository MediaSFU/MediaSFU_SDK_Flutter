import 'dart:async';

import '../types/types.dart' show EventType;

/// Options for adjusting values based on various parameters.
///
/// Contains properties such as the number of participants, the event type, and flags for screen sharing status.
class AutoAdjustOptions {
  final int n;
  final EventType eventType;
  final bool shareScreenStarted;
  final bool shared;

  AutoAdjustOptions({
    required this.n,
    required this.eventType,
    required this.shareScreenStarted,
    required this.shared,
  });
}

/// Type definition for the `autoAdjust` function.
///
/// Represents a function that takes in [AutoAdjustOptions] and returns a `Future<List<int>>`.
typedef AutoAdjustType = Future<List<int>> Function(AutoAdjustOptions options);

/// Adjusts values based on the provided options and the number of participants.
///
/// ### Parameters:
/// - `options` (AutoAdjustOptions): Options containing the number of participants, event type, and sharing status.
///
/// ### Returns:
/// - A `Future<List<int>>` containing the adjusted values.
///
/// ### Example:
/// ```dart
/// final options = AutoAdjustOptions(
///   n: 10,
///   eventType: 'conference',
///   shareScreenStarted: false,
///   shared: false,
/// );
///
/// autoAdjust(options).then((values) {
///   print('Adjusted values: $values');
/// }).catchError((error) {
///   print('Error adjusting values: $error');
/// });
/// ```
Future<List<int>> autoAdjust(AutoAdjustOptions options) async {
  // Default values
  int val1 = 6;
  int val2 = 12 - val1;

  // Adjust values based on eventType and other conditions
  if (options.eventType == EventType.broadcast) {
    val1 = 0;
    val2 = 12 - val1;
  } else if (options.eventType == EventType.chat ||
      (options.eventType == EventType.conference &&
          !(options.shareScreenStarted || options.shared))) {
    val1 = 12;
    val2 = 12 - val1;
  } else if (options.shareScreenStarted || options.shared) {
    val2 = 10;
    val1 = 12 - val2;
  } else {
    // Adjust values based on the number of participants (n)
    if (options.n == 0) {
      val1 = 1;
      val2 = 12 - val1;
    } else if (options.n >= 1 && options.n < 4) {
      val1 = 4;
      val2 = 12 - val1;
    } else if (options.n >= 4 && options.n < 6) {
      val1 = 6;
      val2 = 12 - val1;
    } else if (options.n >= 6 && options.n < 9) {
      val1 = 6;
      val2 = 12 - val1;
    } else if (options.n >= 9 && options.n < 12) {
      val1 = 6;
      val2 = 12 - val1;
    } else if (options.n >= 12 && options.n < 20) {
      val1 = 8;
      val2 = 12 - val1;
    } else if (options.n >= 20 && options.n < 50) {
      val1 = 8;
      val2 = 12 - val1;
    } else {
      val1 = 10;
      val2 = 12 - val1;
    }
  }

  // Return a list with adjusted values
  return [val1, val2];
}
