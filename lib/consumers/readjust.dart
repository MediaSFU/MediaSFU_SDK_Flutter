import 'dart:async';
import 'package:flutter/foundation.dart';
import '../types/types.dart'
    show
        PrepopulateUserMediaType,
        EventType,
        PrepopulateUserMediaParameters,
        PrepopulateUserMediaOptions;

abstract class ReadjustParameters implements PrepopulateUserMediaParameters {
  // Properties as abstract getters
  EventType get eventType;
  bool get shareScreenStarted;
  bool get shared;
  double get mainHeightWidth;
  double get prevMainHeightWidth;
  String get hostLabel;
  bool get firstRound;
  bool get lockScreen;

  // Update function as an abstract getter
  void Function(double) get updateMainHeightWidth;

  // Mediasfu function as an abstract getter
  PrepopulateUserMediaType get prepopulateUserMedia;

  // Method to get updated parameters
  ReadjustParameters Function() get getUpdatedAllParams;

  // Dynamic key-value support
  // dynamic operator [](String key);
}

class ReadjustOptions {
  final int n;
  final int state;
  final ReadjustParameters parameters;

  ReadjustOptions({
    required this.n,
    required this.state,
    required this.parameters,
  });
}

typedef ReadjustType = Future<void> Function({
  required ReadjustOptions options,
});

/// Adjusts the layout parameters based on the current state, participant count, and event type.
///
/// This function recalculates layout values to determine the main and secondary display areas
/// for participants in a media application. It considers various factors such as whether screen sharing
/// is active, the type of event (e.g., conference, broadcast, chat), and the number of participants.
/// If the layout changes, it triggers a function to prepopulate user media.
///
/// ### Parameters:
/// - `options` (`ReadjustOptions`): Options for the adjustment, containing:
///   - `n` (int): The participant count, influencing layout decisions.
///   - `state` (int): The current layout state (0 for initial layout, others for adjustments).
///   - `parameters` (`ReadjustParameters`): Includes:
///     - `eventType`: The type of event being held (e.g., conference, broadcast).
///     - `shareScreenStarted`: Indicates if screen sharing is in progress.
///     - `shared`: Indicates if media is shared among participants.
///     - `mainHeightWidth`: Current main area height/width used for layout.
///     - `prevMainHeightWidth`: Previous height/width for comparison.
///     - `hostLabel`: The name of the host, affecting layout if they are present.
///     - `firstRound`: Indicates if this is the first adjustment round.
///     - `lockScreen`: Indicates if the screen is locked.
///     - `updateMainHeightWidth`: A function to update the main height/width value.
///     - `prepopulateUserMedia`: A function to prepopulate media when layout changes.
///
/// ### Returns:
/// - `Future<void>`: Completes when the adjustment is finished. Handles any errors that occur during execution.
///
/// ### Example Usage:
/// ```dart
/// final readjustParams = ReadjustParameters(
///   eventType: EventType.conference,
///   shareScreenStarted: false,
///   shared: false,
///   mainHeightWidth: 50.0,
///   prevMainHeightWidth: 50.0,
///   hostLabel: 'HostUser',
///   firstRound: true,
///   lockScreen: false,
///   updateMainHeightWidth: (width) => print('Updated width: $width'),
///   prepopulateUserMedia: (name, params) async {
///     print('Prepopulating media for $name');
///   },
///   getUpdatedAllParams: () => updatedParams, // Function that provides updated parameters
/// );
///
/// await readjust(
///   options: ReadjustOptions(
///     n: 5,
///     state: 1,
///     parameters: readjustParams,
///   ),
/// );
/// ```
///
/// ### Error Handling:
/// - Logs any errors encountered during the adjustment process to the debug console.

Future<void> readjust({
  required ReadjustOptions options,
}) async {
  ReadjustParameters parameters = options.parameters.getUpdatedAllParams();
  final int n = options.n;
  final int state = options.state;

  try {
    // Destructure parameters
    final EventType eventType = parameters.eventType;
    final bool shareScreenStarted = parameters.shareScreenStarted;
    final bool shared = parameters.shared;
    double mainHeightWidth = parameters.mainHeightWidth;
    double prevMainHeightWidth = parameters.prevMainHeightWidth;
    final String hostLabel = parameters.hostLabel;
    final bool firstRound = parameters.firstRound;
    final bool lockScreen = parameters.lockScreen;

    // Logic to update the layout parameters based on the state and event conditions
    if (state == 0) {
      prevMainHeightWidth = mainHeightWidth;
    }

    int val1 = 6;
    int val2 = 12 - val1;
    int cal1 = ((val1 / 12) * 100).floor();
    int cal2 = 100 - cal1;

    if (eventType == EventType.broadcast) {
      val1 = 0;
      val2 = 12;
      if (n == 0) {
        val1 = 0;
        val2 = 12;
      }
    } else if (eventType == EventType.chat ||
        (eventType == EventType.conference &&
            !(shareScreenStarted || shared))) {
      val1 = 12;
      val2 = 0;
    } else if (shareScreenStarted || shared) {
      val1 = 2;
      val2 = 10;
    } else {
      // Adjust layout based on participant count
      if (n == 0) {
        val1 = 1;
      } else if (n < 4) {
        val1 = 4;
      } else if (n < 6) {
        val1 = 6;
      } else if (n < 12) {
        val1 = 8;
      } else {
        val1 = 10;
      }
      val2 = 12 - val1;
    }

    if (state == 0) {
      mainHeightWidth = val2.toDouble();
    }

    cal1 = ((val1 / 12) * 100).floor();
    cal2 = 100 - cal1;
    parameters.updateMainHeightWidth(cal2.toDouble());

    // Trigger media prepopulation if layout changed
    if (prevMainHeightWidth != mainHeightWidth) {
      if (!lockScreen && !shared || !firstRound) {
        final optionsPrepopulate = PrepopulateUserMediaOptions(
          name: hostLabel,
          parameters: parameters,
        );
        await parameters.prepopulateUserMedia(
          optionsPrepopulate,
        );
      }
    }
  } catch (error) {
    if (kDebugMode) {
      print("Error updating layout: $error");
    }
  }
}
