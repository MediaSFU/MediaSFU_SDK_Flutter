import 'dart:async';
import 'package:flutter/foundation.dart';
import '../types/types.dart'
    show TriggerParameters, TriggerType, ScreenState, TriggerOptions;

/// Parameters for comparing screen states.
abstract class CompareScreenStatesParameters extends TriggerParameters {
  String get recordingDisplayType;
  bool get recordingVideoOptimized;
  List<ScreenState> get screenStates;
  List<ScreenState> get prevScreenStates;
  List<String> get activeNames;

  // Mediasfu functions
  TriggerType get trigger;
  CompareScreenStatesParameters Function() get getUpdatedAllParams;
}

/// Options for comparing screen states.
class CompareScreenStatesOptions {
  final bool restart;
  final CompareScreenStatesParameters parameters;

  CompareScreenStatesOptions({
    this.restart = false,
    required this.parameters,
  });
}

/// Type definition for the [compareScreenStates] function.
typedef CompareScreenStatesType = Future<void> Function(
    CompareScreenStatesOptions options);

/// Compares the current `screenStates` list with the `prevScreenStates` list and triggers actions if there are differences.
/// This is useful for detecting changes in screen states and responding accordingly in a real-time application.
///
/// The function performs the following steps:
/// 1. If the `restart` flag is true, it skips the comparison and exits early.
/// 2. Iterates through each pair of `screenStates` and `prevScreenStates`, comparing key-value pairs.
/// 3. If any differences are detected between a current and previous screen state, it triggers an action.
/// 4. The trigger action is based on the `recordingDisplayType` and `recordingVideoOptimized` flags.
///
/// ### Parameters:
/// - `options` (`CompareScreenStatesOptions`): Configuration options for the function:
///   - `restart` (`bool`): When true, the function exits without performing comparisons.
///   - `parameters` (`CompareScreenStatesParameters`): Provides the lists of `screenStates` and `prevScreenStates`
///     for comparison, as well as the `activeNames` for triggering events when changes are detected.
///
/// ### Returns:
/// A `Future<void>` that completes when the comparison and possible trigger actions are finished.
///
/// ### Example Usage:
/// ```dart
/// final options = CompareScreenStatesOptions(
///   restart: false,
///   parameters: MyCompareScreenStatesParameters(
///     recordingDisplayType: 'video',
///     recordingVideoOptimized: true,
///     screenStates: [ScreenState(...), ScreenState(...)],
///     prevScreenStates: [ScreenState(...), ScreenState(...)],
///     activeNames: ['name1', 'name2'],
///     trigger: (TriggerOptions options) => print('Triggered with ${options.refActiveNames}'),
///   ),
/// );
///
/// compareScreenStates(options).then((_) {
///   print('Screen states compared successfully');
/// });
/// ```
///
/// ### Error Handling:
/// If an error occurs during the comparison or triggering process, it is caught and logged in debug mode without being rethrown.

Future<void> compareScreenStates(CompareScreenStatesOptions options) async {
  var parameters = options.parameters.getUpdatedAllParams();

  // Extract parameters
  String recordingDisplayType = parameters.recordingDisplayType;
  bool recordingVideoOptimized = parameters.recordingVideoOptimized;
  List<ScreenState> screenStates = parameters.screenStates;
  List<ScreenState> prevScreenStates = parameters.prevScreenStates;
  List<String> activeNames = parameters.activeNames;
  var trigger = parameters.trigger;

  try {
    // Restart the comparison if needed
    if (options.restart) {
      // Perform necessary actions on restart if specified
      return;
    }

    // Compare each key-value pair in screenStates objects
    for (int i = 0; i < screenStates.length; i++) {
      final currentScreenState = screenStates[i].toMap();
      final prevScreenState = prevScreenStates[i].toMap();

      // Check if any value has changed
      final hasChanged = currentScreenState.keys.any(
        (key) => currentScreenState[key] != prevScreenState[key],
      );

      // Signal change if any value has changed
      if (hasChanged) {
        // Perform actions or trigger events based on the change
        if (recordingDisplayType == 'video' && recordingVideoOptimized) {
          final optionsTrigger = TriggerOptions(
            parameters: parameters,
            refActiveNames: activeNames,
          );
          trigger(optionsTrigger);
          break;
        }
        final optionsTrigger = TriggerOptions(
          parameters: parameters,
          refActiveNames: activeNames,
        );
        trigger(optionsTrigger);
        break;
      }
    }
  } catch (error) {
    if (kDebugMode) {
      print('compareScreenStates error: $error');
    }
  }
}
