import 'dart:async';
import 'package:flutter/foundation.dart';
import '../types/types.dart'
    show TriggerParameters, TriggerType, TriggerOptions;

/// Parameters interface for comparing active names.
abstract class CompareActiveNamesParameters extends TriggerParameters {
  List<String> get activeNames;
  List<String> get prevActiveNames;
  void Function(List<String> prevActiveNames) get updatePrevActiveNames;

  // Mediasfu functions
  TriggerType get trigger;
  CompareActiveNamesParameters Function() get getUpdatedAllParams;
}

/// Options interface for comparing active names.
class CompareActiveNamesOptions {
  final bool restart;
  final CompareActiveNamesParameters parameters;

  CompareActiveNamesOptions({
    this.restart = false,
    required this.parameters,
  });
}

/// Type definition for the [compareActiveNames] function.
typedef CompareActiveNamesType = Future<void> Function(
    CompareActiveNamesOptions options);

/// Compares the current `activeNames` list with the `prevActiveNames` list and triggers an action if there are any differences.
/// The function updates `prevActiveNames` after the comparison to keep track of changes.
///
/// This function performs the following steps:
/// 1. If the `restart` flag is true, it triggers the action without comparison.
/// 2. If `restart` is false, it compares each name in `activeNames` to check if any name is new or removed compared to `prevActiveNames`.
/// 3. If a change is detected, it calls the `trigger` function with the updated `activeNames`.
/// 4. Finally, it updates `prevActiveNames` to reflect the current `activeNames`.
///
/// ### Parameters:
/// - `options` (`CompareActiveNamesOptions`): Configuration options for comparing active names:
///   - `restart` (`bool`): When true, triggers an action immediately without comparison.
///   - `parameters` (`CompareActiveNamesParameters`): Provides the lists of `activeNames` and `prevActiveNames`,
///     as well as functions to update `prevActiveNames` and trigger actions when changes are detected.
///
/// ### Returns:
/// A `Future<void>` that completes when the comparison and possible trigger actions are finished.
///
/// ### Example:
///
/// ```dart
/// final options = CompareActiveNamesOptions(
///   restart: false,
///   parameters: MyCompareActiveNamesParameters(
///     activeNames: ['Alice', 'Bob'],
///     prevActiveNames: ['Alice'],
///     updatePrevActiveNames: (prevNames) => print('Previous names updated to: $prevNames'),
///     trigger: (TriggerOptions options) => print('Triggered action with ${options.refActiveNames}'),
///   ),
/// );
///
/// compareActiveNames(options).then((_) {
///   print('Active names comparison completed successfully.');
/// });
/// ```
///
/// ### Error Handling:
/// If an error occurs, it is caught and logged in debug mode without throwing further.

Future<void> compareActiveNames(CompareActiveNamesOptions options) async {
  var parameters = options.parameters.getUpdatedAllParams();

  // Extract parameters
  List<String> activeNames = parameters.activeNames;
  List<String> prevActiveNames = parameters.prevActiveNames;
  var updatePrevActiveNames = parameters.updatePrevActiveNames;
  var trigger = parameters.trigger;

  try {
    // Restart the comparison if needed
    if (options.restart) {
      final optionsTrigger = TriggerOptions(
        parameters: parameters,
        refActiveNames: activeNames,
      );
      trigger(optionsTrigger);
      return;
    }

    // Track changes in activeNames
    List<bool> nameChanged = [];

    // Compare each name in activeNames
    for (final currentName in activeNames) {
      // Check if the name is present in prevActiveNames
      final hasNameChanged = !prevActiveNames.contains(currentName);

      if (hasNameChanged) {
        nameChanged.add(true);
        final optionsTrigger = TriggerOptions(
          parameters: parameters,
          refActiveNames: activeNames,
        );
        trigger(optionsTrigger);
        break;
      }
    }

    // Count occurrences of true in nameChanged
    final count = nameChanged.where((value) => value).length;

    if (count < 1) {
      // Check for new names in prevActiveNames
      for (final currentName in prevActiveNames) {
        final hasNameChanged = !activeNames.contains(currentName);

        if (hasNameChanged) {
          final optionsTrigger = TriggerOptions(
            parameters: parameters,
            refActiveNames: activeNames,
          );
          trigger(optionsTrigger);
          break;
        }
      }
    }

    // Update prevActiveNames with current activeNames
    updatePrevActiveNames(List<String>.from(activeNames));
  } catch (error) {
    if (kDebugMode) {
      print('compareActiveNames error: $error');
    }
  }
}
