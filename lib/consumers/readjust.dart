import 'dart:async';
import 'package:flutter/foundation.dart';

/// Adjusts the grid sizes based on the given parameters.
///
/// The [readjust] function is responsible for adjusting the grid sizes based on the provided parameters. It takes in the following required parameters:
/// - [n]: An integer representing a value.
/// - [state]: An integer representing the state.
/// - [parameters]: A map of string keys and dynamic values representing the parameters.
///
/// The function performs the following steps:
/// 1. Retrieves the [getUpdatedAllParams] function from the [parameters] map and assigns it to the [getUpdatedAllParams] variable.
/// 2. Updates the [parameters] map by calling the [getUpdatedAllParams] function.
/// 3. Retrieves various values from the [parameters] map, such as [eventType], [shareScreenStarted], [shared], [mainHeightWidth], [prevMainHeightWidth], [hostLabel], [firstRound], and [lockScreen].
/// 4. Retrieves the [updateMainHeightWidth] function from the [parameters] map and assigns it to the [updateMainHeightWidth] variable.
/// 5. Retrieves the [prepopulateUserMedia] function from the [parameters] map and assigns it to the [prepopulateUserMedia] variable.
/// 6. Performs calculations based on the [eventType], [shareScreenStarted], [shared], and [n] values to determine the values of [val1] and [val2].
/// 7. Updates the [mainHeightWidth] value based on the [state] and [val2] values.
/// 8. Performs additional calculations to determine the values of [cal1] and [cal2].
/// 9. Calls the [updateMainHeightWidth] function with the [cal2] value.
/// 10. Checks if the [prevMainHeightWidth] is different from the [mainHeightWidth] and performs the necessary actions based on the [lockScreen], [shared], and [firstRound] values.
///
/// Throws an error if any errors occur during the process of updating grid sizes.

typedef UpdateMainHeightWidth = void Function(double value);
typedef PrepopulateUserMedia = List<dynamic> Function({
  required String name,
  required Map<String, dynamic> parameters,
});

typedef OnScreenChanges = Future<void> Function(
    {bool changed, required Map<String, dynamic> parameters});
typedef GetUpdatedAllParams = Map<String, dynamic> Function();

Future<void> readjust({
  required int n,
  required int state,
  required Map<String, dynamic> parameters,
}) async {
  try {
    GetUpdatedAllParams getUpdatedAllParams = parameters['getUpdatedAllParams'];
    parameters = getUpdatedAllParams();

    String eventType = parameters['eventType'];
    bool shareScreenStarted = parameters['shareScreenStarted'];
    bool shared = parameters['shared'];
    double mainHeightWidth = parameters['mainHeightWidth'];
    double prevMainHeightWidth = parameters['prevMainHeightWidth'];
    String hostLabel = parameters['hostLabel'];
    bool firstRound = parameters['firstRound'];
    bool lockScreen = parameters['lockScreen'];

    UpdateMainHeightWidth updateMainHeightWidth =
        parameters['updateMainHeightWidth'];

    // mediasfu functions
    PrepopulateUserMedia prepopulateUserMedia =
        parameters['prepopulateUserMedia'];

    if (state == 0) {
      prevMainHeightWidth = mainHeightWidth;
    }

    var val1 = 6;
    var val2 = 12 - val1;
    var cal1 = ((val1 / 12) * 100).floor();
    var cal2 = 100 - cal1;

    if (eventType == 'broadcast') {
      val1 = 0;
      val2 = 12 - val1;

      if (n == 0) {
        val1 = 0;
        val2 = 12 - val1;
      }
    } else if (eventType == 'chat' ||
        (eventType == 'conference' && !(shareScreenStarted || shared))) {
      val1 = 12;
      val2 = 12 - val1;
    } else {
      if (shareScreenStarted || shared) {
        val2 = 10;
        val1 = 12 - val2;
      } else {
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

    if (state == 0) {
      mainHeightWidth = val2.toDouble();
    }

    cal1 = ((val1 / 12) * 100).floor();
    cal2 = 100 - cal1;

    updateMainHeightWidth(cal2.toDouble());

    if (prevMainHeightWidth != mainHeightWidth) {
      if (!lockScreen && !shared) {
        prepopulateUserMedia(name: hostLabel, parameters: parameters);
      } else {
        if (!firstRound) {
          prepopulateUserMedia(name: hostLabel, parameters: parameters);
        }
      }
    }
  } catch (error) {
    // Handle errors during the process of updating grid sizes
    if (kDebugMode) {
      // print('Error updating grid sizes: $error');
    }
    // throw error;
  }
}
