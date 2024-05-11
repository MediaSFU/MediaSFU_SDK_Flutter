import 'dart:async';
import 'package:flutter/foundation.dart';

/// Compares the active names with the previous active names and triggers a function if there are any changes.
///
/// The [compareActiveNames] function takes the following parameters:
/// - [tStamp]: A required string representing a timestamp.
/// - [restart]: An optional boolean indicating whether to restart the comparison. Defaults to `false`.
/// - [parameters]: A required map of string keys and dynamic values containing additional parameters.
///
/// The [compareActiveNames] function performs the following steps:
/// 1. Retrieves the updated parameters using the `getUpdatedAllParams` function from the [parameters] map.
/// 2. Extracts the [activeNames], [prevActiveNames], and [updatePrevActiveNames] from the updated parameters.
/// 3. Initializes a trigger function using the `trigger` function from the [parameters] map.
/// 4. Restarts the comparison if [restart] is `true` by calling the trigger function with the [activeNames] and [parameters].
/// 5. Compares each name in [activeNames] with the names in [prevActiveNames].
///    - If a name in [activeNames] is not present in [prevActiveNames], triggers the function and breaks the loop.
/// 6. If no changes are detected in step 5, checks for new names in [prevActiveNames].
///    - If a name in [prevActiveNames] is not present in [activeNames], triggers the function and breaks the loop.
/// 7. Updates [prevActiveNames] with the current [activeNames] and calls [updatePrevActiveNames] with [prevActiveNames].
///
/// If an error occurs during the comparison, it is caught and logged in debug mode.
///
/// Example usage:
/// ```dart
/// await compareActiveNames(
///   tStamp: '2022-01-01',
///   restart: true,
///   parameters: {
///     'getUpdatedAllParams': getUpdatedAllParams,
///     'activeNames': ['John', 'Jane'],
///     'prevActiveNames': ['John'],
///     'updatePrevActiveNames': updatePrevActiveNames,
///     'trigger': triggerFunction,
///   },
/// );
/// ```

typedef TriggerFunction = void Function(
    {required List<String> refActiveNames,
    required Map<String, dynamic> parameters});

typedef CompareActiveNames = Future<void> Function({
  required String tStamp,
  bool restart,
  required Map<String, dynamic> parameters,
});

typedef GetUpdatedAllParams = Map<String, dynamic> Function();

typedef UpdatePrevActiveNames = void Function(List<String> prevActiveNames);

Future<void> compareActiveNames({
  required String tStamp,
  bool restart = false,
  required Map<String, dynamic> parameters,
}) async {
  try {
    GetUpdatedAllParams getUpdatedAllParams = parameters['getUpdatedAllParams'];

    parameters = getUpdatedAllParams();

    List<String> activeNames = parameters['activeNames'];
    List<String> prevActiveNames = parameters['prevActiveNames'];
    Function updatePrevActiveNames = parameters['updatePrevActiveNames'];

    // mediasfu functions
    TriggerFunction trigger = parameters['trigger'];

    // Restart the comparison if needed
    if (restart) {
      trigger(refActiveNames: activeNames, parameters: parameters);
      return;
    }

    // List to track changes in activeNames
    List<bool> nameChanged = [];

    // Compare each name in activeNames
    for (int i = 0; i < activeNames.length; i++) {
      final currentName = activeNames[i];

      // Check if the name is present in prevActiveNames
      final hasNameChanged = !prevActiveNames.contains(currentName);

      if (hasNameChanged) {
        nameChanged.add(true);
        trigger(refActiveNames: activeNames, parameters: parameters);
        break;
      }
    }

    // Count the number of true in nameChanged
    final count = nameChanged.where((value) => value).length;

    if (count < 1) {
      // Check for new names in prevActiveNames
      for (int i = 0; i < prevActiveNames.length; i++) {
        final currentName = prevActiveNames[i];

        // Check if the name is present in activeNames
        final hasNameChanged = !activeNames.contains(currentName);

        // Signal change if the name is new
        if (hasNameChanged) {
          trigger(refActiveNames: activeNames, parameters: parameters);
          break;
        }
      }
    }

    // Update prevActiveNames with current activeNames
    prevActiveNames = List<String>.from(activeNames);
    updatePrevActiveNames(prevActiveNames);
  } catch (error) {
    if (kDebugMode) {
      // print('compareActiveNames error: $error');
      // print('compareActiveNames stackTrace: $stackTrace');
    }

    // throw error;
  }
}
