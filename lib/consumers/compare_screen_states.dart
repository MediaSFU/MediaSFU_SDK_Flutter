import 'dart:async';
import 'package:flutter/foundation.dart';

/// Compares the screen states and triggers events based on changes.
///
/// The [compareScreenStates] function compares the screen states provided in the [screenStates] list with the previous screen states provided in the [prevScreenStates] list.
/// It checks if any value has changed in each key-value pair of the screen states objects.
/// If a change is detected, it performs actions or triggers events based on the change.
///
/// The [tStamp] parameter is a required string that represents the timestamp of the screen states.
/// The [restart] parameter is an optional boolean that indicates whether to restart the comparison. By default, it is set to false.
/// The [parameters] parameter is a required map that contains the necessary parameters for the comparison and triggering events.
/// The [parameters] map should include the following keys:
///   - 'getUpdatedAllParams': A function that returns a map of updated parameters.
///   - 'recordingDisplayType': A string that represents the type of recording display.
///   - 'recordingVideoOptimized': A boolean that indicates whether the recording video is optimized.
///   - 'screenStates': A list of dynamic objects representing the current screen states.
///   - 'prevScreenStates': A list of dynamic objects representing the previous screen states.
///   - 'activeNames': A list of strings representing the active names.
///   - 'trigger': A function that triggers events based on the change in screen states.
///
/// Example usage:
/// ```dart
/// await compareScreenStates(
///   tStamp: '2022-01-01 12:00:00',
///   restart: false,
///   parameters: {
///     'getUpdatedAllParams': () => {
///       // updated parameters
///     },
///     'recordingDisplayType': 'video',
///     'recordingVideoOptimized': true,
///     'screenStates': [
///       // current screen states
///     ],
///     'prevScreenStates': [
///       // previous screen states
///     ],
///     'activeNames': [
///       // active names
///     ],
///     'trigger': ({required List<String> refActiveNames, required Map<String, dynamic> parameters}) {
///       // trigger events based on the change
///     },
///   },
/// );
/// ```

typedef GetUpdatedAllParams = Map<String, dynamic> Function();
typedef TriggerFunction = void Function(
    {required List<String> refActiveNames,
    required Map<String, dynamic> parameters});

typedef CompareScreenStates = Future<void> Function({
  required String tStamp,
  bool restart,
  required Map<String, dynamic> parameters,
});

Future<void> compareScreenStates({
  required String tStamp,
  bool restart = false,
  required Map<String, dynamic> parameters,
}) async {
  try {
    GetUpdatedAllParams getUpdatedAllParams = parameters['getUpdatedAllParams'];
    parameters = getUpdatedAllParams();

    String recordingDisplayType = parameters['recordingDisplayType'];
    bool recordingVideoOptimized = parameters['recordingVideoOptimized'];
    List<dynamic> screenStates = parameters['screenStates'];
    List<dynamic> prevScreenStates = parameters['prevScreenStates'];
    List<String> activeNames = parameters['activeNames'];
    TriggerFunction trigger = parameters['trigger'];

    // Restart the comparison if needed
    if (restart) {
      // Perform necessary actions on restart
      return;
    }

    // Compare each key-value pair in the screenStates objects
    for (int i = 0; i < screenStates.length; i++) {
      final currentScreenState = screenStates[i];
      final prevScreenState = prevScreenStates[i];

      // Check if any value has changed
      final hasChanged = currentScreenState.keys
          .any((key) => currentScreenState[key] != prevScreenState[key]);

      // Signal change if any value has changed
      if (hasChanged) {
        // Perform actions or trigger events based on the change
        if (recordingDisplayType == 'video') {
          if (recordingVideoOptimized) {
            trigger(refActiveNames: activeNames, parameters: parameters);
            break;
          }
        }
        trigger(refActiveNames: activeNames, parameters: parameters);
        break;
      }
    }
  } catch (error) {
    if (kDebugMode) {
      // print('compareScreenStates error: $error');
    }
    // throw error;
  }
}
