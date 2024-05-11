import 'dart:async';
import 'package:flutter/foundation.dart';

/// Re-ports the screen states based on the provided parameters.
///
/// The [restart] parameter determines whether to restart the comparison process.
/// The [parameters] parameter is a map containing various parameters needed for the re-porting process.
///
/// The [rePort] function performs the following steps:
/// 1. Destructures the parameters to extract necessary values.
/// 2. Calls the [getUpdatedAllParams] function to update the parameters.
/// 3. Checks the conditions and performs operations based on the values of [recordStarted] and [recordResumed].
///    - If [recordStarted] or [recordResumed] is true:
///      - If [recordStopped] or [recordPaused] is true, the recording is stopped or paused, and no further action is taken.
///      - If [islevel] is '2', the screen states are updated and the [compareActiveNames] and [compareScreenStates] functions are called.
///        - The [prevScreenStates] are updated with the current [screenStates].
///        - The [screenStates] are updated with a new map containing [mainScreenPerson], [adminOnMainScreen], and [mainScreenFilled].
///        - The [updateScreenStates] function is called with the updated [screenStates].
///        - The current timestamp is generated and stored in [tStamp].
///        - If [restart] is true, the [compareActiveNames] function is called with the provided parameters.
///        - The [compareScreenStates] function is called with the provided parameters.
///
/// If any error occurs during the re-porting process, it is caught and handled, and the error message is printed in debug mode.
///
/// Example usage:
/// ```dart
/// rePort(restart: true, parameters: {
///   'getUpdatedAllParams': getUpdatedAllParams,
///   'islevel': '2',
///   'mainScreenPerson': 'John Doe',
///   'adminOnMainScreen': true,
///   'mainScreenFilled': true,
///   'recordStarted': true,
///   'recordStopped': false,
///   'recordPaused': false,
///   'recordResumed': false,
///   'screenStates': [],
///   'prevScreenStates': [],
///   'updateScreenStates': updateScreenStates,
///   'updatePrevScreenStates': updatePrevScreenStates,
///   'compareActiveNames': compareActiveNames,
///   'compareScreenStates': compareScreenStates,
/// });
///

typedef UpdateScreenStates = void Function(List<Map<String, dynamic>>);
typedef UpdatePrevScreenStates = void Function(List<Map<String, dynamic>>);
typedef GetUpdatedAllParams = Map<String, dynamic> Function();

typedef TriggerFunction = void Function(
    {List<String> refActiveNames,
    String tStamp,
    Map<String, dynamic> parameters});

typedef CompareActiveNames = Future<void> Function({
  required String tStamp,
  bool restart,
  required Map<String, dynamic> parameters,
});

typedef CompareScreenStates = Future<void> Function({
  required String tStamp,
  bool restart,
  required Map<String, dynamic> parameters,
});

Future<void> rePort(
    {restart = false, required Map<String, dynamic> parameters}) async {
  try {
    // Destructure parameters
    GetUpdatedAllParams getUpdatedAllParams = parameters['getUpdatedAllParams'];
    parameters = getUpdatedAllParams();
    String islevel = parameters['islevel'];
    String mainScreenPerson = parameters['mainScreenPerson'];
    bool adminOnMainScreen = parameters['adminOnMainScreen'];
    bool mainScreenFilled = parameters['mainScreenFilled'];
    bool recordStarted = parameters['recordStarted'];
    bool recordStopped = parameters['recordStopped'];
    bool recordPaused = parameters['recordPaused'];
    bool recordResumed = parameters['recordResumed'];
    List<Map<String, dynamic>>? screenStates = parameters['screenStates'];
    List<Map<String, dynamic>>? prevScreenStates =
        parameters['prevScreenStates'];

    UpdateScreenStates updateScreenStates = parameters['updateScreenStates'];
    UpdatePrevScreenStates updatePrevScreenStates =
        parameters['updatePrevScreenStates'];

    //mediasfu functions
    CompareActiveNames compareActiveNames = parameters['compareActiveNames'];
    CompareScreenStates compareScreenStates = parameters['compareScreenStates'];

    // Check conditions and perform operations
    if (recordStarted || recordResumed) {
      if (recordStopped || recordPaused) {
        // Recording stopped or paused, do nothing
      } else {
        if (islevel == '2') {
          prevScreenStates = [...screenStates!];
          updatePrevScreenStates(prevScreenStates);

          screenStates = [
            {
              'mainScreenPerson': mainScreenPerson,
              'adminOnMainScreen': adminOnMainScreen,
              'mainScreenFilled': mainScreenFilled
            }
          ];
          updateScreenStates(screenStates);

          var now = DateTime.now();
          var tStamp =
              '${now.year}${now.month}${now.day}_${now.hour}${now.minute}${now.second}';

          if (restart == true) {
            await compareActiveNames(
                tStamp: tStamp, restart: restart, parameters: parameters);
            return;
          }
          await compareActiveNames(
              tStamp: tStamp, restart: restart, parameters: parameters);
          await compareScreenStates(
              tStamp: tStamp, restart: restart, parameters: parameters);
        }
      }
    }
  } catch (error) {
    // Handle errors during the process of rePorting
    if (kDebugMode) {
      // print('Error during rePorting: $error');
    }
  }
}
