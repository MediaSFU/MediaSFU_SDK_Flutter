import 'package:flutter/foundation.dart';
import 'dart:async';
import '../types/types.dart'
    show
        ScreenState,
        CompareScreenStatesParameters,
        CompareScreenStatesType,
        CompareActiveNamesParameters,
        CompareActiveNamesType,
        CompareScreenStatesOptions,
        CompareActiveNamesOptions;

// Define RePortParameters class
abstract class RePortParameters
    implements CompareScreenStatesParameters, CompareActiveNamesParameters {
  // Properties as abstract getters
  String get islevel;
  String get mainScreenPerson;
  bool get adminOnMainScreen;
  bool get mainScreenFilled;
  bool get recordStarted;
  bool get recordStopped;
  bool get recordPaused;
  bool get recordResumed;
  List<ScreenState> get screenStates;
  List<ScreenState> get prevScreenStates;

  // Update functions as abstract getters
  void Function(List<ScreenState>) get updateScreenStates;
  void Function(List<ScreenState>) get updatePrevScreenStates;

  // Mediasfu functions as abstract getters
  CompareActiveNamesType get compareActiveNames;
  CompareScreenStatesType get compareScreenStates;

  // Method to get updated parameters
  RePortParameters Function() get getUpdatedAllParams;

  // Dynamic key-value support
  // dynamic operator [](String key);
}

// Define RePortOptions class
class RePortOptions {
  final bool restart;
  final RePortParameters parameters;

  RePortOptions({
    this.restart = false,
    required this.parameters,
  });
}

typedef RePortType = Future<void> Function(RePortOptions options);

/// Re-ports the screen states and active names for the main screen in a conference or event session.
///
/// This function updates the current and previous screen states, compares active names and screen states,
/// and adds a timestamp. If recording is started or resumed, it performs the re-porting operations.
/// If `restart` is true, it only re-compares active names.
///
/// Parameters:
/// - [options] (`RePortOptions`): Contains a flag to restart comparisons and parameters for re-porting.
///
/// If the user level is "2", it updates the current and previous screen states and timestamps the operation.
///
/// Example:
/// ```dart
/// final rePortOptions = RePortOptions(
///   restart: true,
///   parameters: RePortParameters(
///     islevel: '2',
///     mainScreenPerson: 'Admin',
///     adminOnMainScreen: true,
///     mainScreenFilled: true,
///     recordStarted: true,
///     recordStopped: false,
///     recordPaused: false,
///     recordResumed: false,
///     screenStates: [/* existing screen states */],
///     prevScreenStates: [/* previous screen states */],
///     updateScreenStates: (List<ScreenState> newStates) => print("Updated screen states."),
///     updatePrevScreenStates: (List<ScreenState> prevStates) => print("Updated previous screen states."),
///     compareActiveNames: (CompareActiveNamesOptions options) async => /* function logic */,
///     compareScreenStates: (CompareScreenStatesOptions options) async => /* function logic */,
///     getUpdatedAllParams: () => /* function to get updated parameters */,
///   ),
/// );
///
/// await rePort(rePortOptions);
/// ```

Future<void> rePort(
  RePortOptions options,
) async {
  var parameters = options.parameters.getUpdatedAllParams();
  final bool restart = options.restart;

  final String islevel = parameters.islevel;
  final String mainScreenPerson = parameters.mainScreenPerson;
  final bool adminOnMainScreen = parameters.adminOnMainScreen;
  final bool mainScreenFilled = parameters.mainScreenFilled;
  final bool recordStarted = parameters.recordStarted;
  final bool recordStopped = parameters.recordStopped;
  final bool recordPaused = parameters.recordPaused;
  final bool recordResumed = parameters.recordResumed;
  List<ScreenState> screenStates = parameters.screenStates;
  List<ScreenState> prevScreenStates = parameters.prevScreenStates;

  final void Function(List<ScreenState>) updateScreenStates =
      parameters.updateScreenStates;
  final void Function(List<ScreenState>) updatePrevScreenStates =
      parameters.updatePrevScreenStates;
  final CompareActiveNamesType compareActiveNames =
      parameters.compareActiveNames;
  final CompareScreenStatesType compareScreenStates =
      parameters.compareScreenStates;

  try {
    if (recordStarted || recordResumed) {
      if (recordStopped || recordPaused) {
        // Recording stopped or paused, do nothing
        return;
      }
      if (islevel == '2') {
        prevScreenStates = List.from(screenStates);
        updatePrevScreenStates(prevScreenStates);

        screenStates = [
          ScreenState(
            mainScreenPerson: mainScreenPerson,
            adminOnMainScreen: adminOnMainScreen,
            mainScreenFilled: mainScreenFilled,
          )
        ];

        updateScreenStates(screenStates);

        // Timestamp generation
        // final now = DateTime.now();
        // final tStamp =
        //     '${now.year}${now.month}${now.day}_${now.hour}${now.minute}${now.second}';

        final optionsCompareActive = CompareActiveNamesOptions(
          restart: restart,
          parameters: parameters,
        );
        if (restart) {
          await compareActiveNames(optionsCompareActive);
          return;
        }

        final optionsCompareScreen = CompareScreenStatesOptions(
          restart: restart,
          parameters: parameters,
        );
        await compareActiveNames(optionsCompareActive);
        await compareScreenStates(optionsCompareScreen);
      }
    }
  } catch (error) {
    if (kDebugMode) {
      print('Error during rePorting: $error');
    }
  }
}
