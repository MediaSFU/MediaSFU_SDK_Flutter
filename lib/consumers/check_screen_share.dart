import 'dart:async';
import 'package:flutter/foundation.dart';

/// Checks the screen sharing status and performs the necessary actions based on the status.
///
/// The [parameters] parameter is a map that contains the following keys:
/// - 'shared': A boolean value indicating whether the screen is currently being shared.
/// - 'stopShareScreen': A function that stops the screen sharing.
/// - 'requestScreenShare': A function that requests to start screen sharing.
/// - 'showAlert': A function to show alert messages.
/// - 'whiteboardStarted': A boolean value indicating if the whiteboard is active.
/// - 'whiteboardEnded': A boolean value indicating if the whiteboard session has ended.
/// - 'breakOutRoomStarted': A boolean value indicating if a breakout room is active.
/// - 'breakOutRoomEnded': A boolean value indicating if the breakout room session has ended.
///
/// If the screen is already being shared (shared = true), the [stopShareScreen] function is called with the [parameters].
/// Otherwise, the [requestScreenShare] function is called with the [parameters].
///
/// Throws an error if any error occurs during the process.

typedef StopShareScreenFunction = Future<void> Function(
    {required Map<String, dynamic> parameters});
typedef RequestScreenShareFunction = Future<void> Function(
    {required Map<String, dynamic> parameters});
typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});
typedef CheckScreenShareFunction = Future<void> Function(
    {Map<String, dynamic> parameters});

Future<void> checkScreenShare(
    {required Map<String, dynamic> parameters}) async {
  try {
    final bool shared = parameters['shared'];
    final StopShareScreenFunction stopShareScreen =
        parameters['stopShareScreen'];
    final RequestScreenShareFunction requestScreenShare =
        parameters['requestScreenShare'];
    final ShowAlert showAlert = parameters['showAlert'];
    final bool whiteboardStarted = parameters['whiteboardStarted'] ?? false;
    final bool whiteboardEnded = parameters['whiteboardEnded'] ?? false;
    final bool breakOutRoomStarted = parameters['breakOutRoomStarted'] ?? false;
    final bool breakOutRoomEnded = parameters['breakOutRoomEnded'] ?? false;

    // Stop screen share if already shared or request screen share if not shared
    if (shared) {
      if (whiteboardStarted && !whiteboardEnded) {
        showAlert(
            message: 'Screen share is not allowed when whiteboard is active',
            type: 'danger',
            duration: 3000);
        return;
      }
      await stopShareScreen(parameters: parameters);
    } else {
      // Can't share if breakout room is active
      if (breakOutRoomStarted && !breakOutRoomEnded) {
        showAlert(
            message: 'Screen share is not allowed when breakout room is active',
            type: 'danger',
            duration: 3000);
        return;
      }

      if (whiteboardStarted && !whiteboardEnded) {
        showAlert(
            message: 'Screen share is not allowed when whiteboard is active',
            type: 'danger',
            duration: 3000);
        return;
      }
      await requestScreenShare(parameters: parameters);
    }
  } catch (error) {
    if (kDebugMode) {
      print('checkScreenShare error $error');
    }
    // throw error;
  }
}
