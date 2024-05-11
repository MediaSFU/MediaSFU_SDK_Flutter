import 'dart:async';

/// Adjusts values based on various parameters and conditions.
///
/// The [autoAdjust] function takes in an integer [n] representing the number of participants
/// and a map of [parameters] containing additional parameters. It returns a [Future] that
/// resolves to a list of two integers [val1] and [val2], which are the adjusted values.
///
/// The [parameters] map should contain a function [getUpdatedAllParams] that returns a map
/// of updated parameters. The function retrieves specific parameters from the [parameters]
/// object and calculates percentage values based on those parameters. It then adjusts the
/// values based on the [eventType] and other conditions.
///
/// If the [eventType] is 'broadcast', [val1] is set to 0 and [val2] is set to 12 - [val1].
/// If the [eventType] is 'chat' or 'conference' and neither screen sharing nor sharing
/// has started, [val1] is set to 12 and [val2] is set to 12 - [val1].
/// If screen sharing or sharing has started, [val2] is set to 10 and [val1] is set to 12 - [val2].
/// If none of the above conditions are met, the values are adjusted based on the number of participants [n].
///
/// The adjusted values [val1] and [val2] are then returned as a list.
///

typedef GetUpdatedAllParams = Map<String, dynamic> Function();

Future<List<int>> autoAdjust(
    {required int n, required Map<String, dynamic> parameters}) async {
  GetUpdatedAllParams getUpdatedAllParams = parameters['getUpdatedAllParams'];
  parameters = getUpdatedAllParams();

  // Extract specific parameters from the parameters object
  final String eventType = parameters['eventType'];
  final bool shareScreenStarted = parameters['shareScreenStarted'];
  final bool shared = parameters['shared'];

  // Default values
  int val1 = 6;
  int val2 = 12 - val1;

  // Calculate percentage values
  ((val1 / 12) * 100).floor();

  // Adjust values based on eventType and other conditions
  if (eventType == 'broadcast') {
    val1 = 0;
    val2 = 12 - val1;
  } else if (eventType == 'chat' ||
      (eventType == 'conference' && !(shareScreenStarted || shared))) {
    val1 = 12;
    val2 = 12 - val1;
  } else {
    if (shareScreenStarted || shared) {
      val2 = 10;
      val1 = 12 - val2;
    } else {
      // Adjust values based on the number of participants (n)
      if (n == 0) {
        val1 = 1;
        val2 = 12 - val1;
      } else if (n >= 1 && n < 4) {
        val1 = 4;
        val2 = 12 - val1;
      } else if (n >= 4 && n < 6) {
        val1 = 6;
        val2 = 12 - val1;
      } else if (n >= 6 && n < 9) {
        val1 = 6;
        val2 = 12 - val1;
      } else if (n >= 9 && n < 12) {
        val1 = 6;
        val2 = 12 - val1;
      } else if (n >= 12 && n < 20) {
        val1 = 8;
        val2 = 12 - val1;
      } else if (n >= 20 && n < 50) {
        val1 = 8;
        val2 = 12 - val1;
      } else {
        val1 = 10;
        val2 = 12 - val1;
      }
    }
  }

  // Return a list with adjusted values
  return [val1, val2];
}
