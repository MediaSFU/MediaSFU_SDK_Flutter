import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Requests screen share based on the provided parameters.
///
/// The [parameters] map should contain the following keys:
/// - 'socket': The socket to communicate with the server.
/// - 'showAlert': An optional callback function to show an alert to the user.
/// - 'localUIMode': A boolean indicating whether the user is in local UI mode.
/// - 'startShareScreen': The callback function to start the screen sharing process.
///
/// If [localUIMode] is true, the screen sharing process will be started immediately.
/// Otherwise, a request will be sent to the server to check if screen sharing is allowed.
/// If screen sharing is allowed, the [startShareScreen] callback function will be called.
/// Otherwise, an alert will be shown to the user using the [showAlert] callback function.
///
/// Throws an error if any error occurs during the process of requesting screen share.

typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

typedef StartShareScreen = Future<void> Function({
  required Map<String, dynamic> parameters,
});

Future<void> requestScreenShare(
    {required Map<String, dynamic> parameters}) async {
  io.Socket socket = parameters['socket'];
  ShowAlert? showAlert = parameters['showAlert'];
  bool localUIMode = parameters['localUIMode'] ?? false;

  // mediasfu functions
  StartShareScreen startShareScreen = parameters['startShareScreen'];

  try {
    // Check if the user is in local UI mode
    if (localUIMode == true) {
      await startShareScreen(parameters: parameters);
      return;
    }

    // Send a request to the socket to request screen share with no parameters
    socket.emitWithAck('requestScreenShare', [], ack: (responseData) async {
      var allowScreenShare = responseData['allowScreenShare'] ?? false;
      if (!allowScreenShare) {
        // Send an alert to the user
        if (showAlert != null) {
          showAlert(
            message: 'You are not allowed to share screen',
            type: 'danger',
            duration: 3000,
          );
        }
      } else {
        await startShareScreen(parameters: parameters);
      }
    });
  } catch (error) {
    // Handle errors during the process of requesting screen share
    // throw new Error("Error during requesting screen share: $error");
    if (kDebugMode) {
      print("Error during requesting screen share: $error");
    }
  }
}
