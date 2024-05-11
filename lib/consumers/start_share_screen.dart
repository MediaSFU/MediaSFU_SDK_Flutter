// ignore_for_file: empty_catches

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// Starts the screen sharing process.
///
/// This function allows the user to share their screen by capturing the display media.
/// It takes a map of parameters as input, including the following:
/// - `shared`: A boolean value indicating whether the screen is currently being shared.
/// - `showAlert`: A function that displays an alert message to the user.
/// - `updateShared`: A function that updates the shared variable.
/// - `onWeb`: A boolean value indicating whether the app is running on the web.
/// - `streamSuccessScreen`: A function that handles the success scenario after capturing the screen stream.
///
/// If the app is not running on the web, an alert message is displayed to the user and the function returns.
/// Otherwise, it attempts to capture the screen stream using the `navigator.mediaDevices.getDisplayMedia` method.
/// If successful, the `streamSuccessScreen` function is called with the captured stream and the parameters.
/// If unsuccessful, an alert message is displayed to the user.
/// Finally, the `shared` variable is updated using the `updateShared` function.
///
/// Throws an error if an error occurs during the screen sharing process.

typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

typedef StreamSuccessScreen = Future<void> Function(
    {required MediaStream stream, required Map<String, dynamic> parameters});

typedef StartShareScreen = Future<void> Function({
  required Map<String, dynamic> parameters,
});

typedef UpdateShared = void Function(bool shared);

Future<void> startShareScreen(
    {required Map<String, dynamic> parameters}) async {
  bool shared = parameters['shared'] ?? false;
  ShowAlert? showAlert = parameters['showAlert'];
  UpdateShared updateShared = parameters['updateShared'];
  bool onWeb = parameters['onWeb'];

  //mediasfu functions
  StreamSuccessScreen streamSuccessScreen = parameters['streamSuccessScreen'];

  try {
    if (!onWeb) {
      if (showAlert != null) {
        showAlert(
          message: 'You cannot share screen while on mobile',
          type: 'danger',
          duration: 3000,
        );
      }
      return;
    }

    // Check if navigator.mediaDevices.getDisplayMedia is supported; defer for later for flutter
    try {
      MediaStream stream = await navigator.mediaDevices.getDisplayMedia({
        'video': {
          'cursor': 'always',
          'width': 1280,
          'height': 720,
          'frameRate': 30
        },
        'audio': false
      });

      try {
        await streamSuccessScreen(stream: stream, parameters: parameters);
      } catch (error) {}
      shared = true;
    } catch (error) {
      shared = false;
      if (showAlert != null) {
        showAlert(
          message: 'Could not share screen, check and retry',
          type: 'danger',
          duration: 3000,
        );
      }
    }

    // Update the shared variable
    updateShared(shared);
  } catch (error) {
    if (kDebugMode) {
      print('Error starting screen share: $error');
    }
    rethrow;
  }
}
