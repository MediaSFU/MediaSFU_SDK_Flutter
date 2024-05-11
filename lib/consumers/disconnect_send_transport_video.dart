import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Disconnects the send transport for video.
///
/// This function closes the video producer, notifies the server about pausing video sharing,
/// and updates the UI based on the participant's level and screen lock status.
///
/// Parameters:
/// - `parameters`: A map containing the required parameters for the disconnection process.
///
/// Throws:
/// - Any error that occurs during the disconnection process.
///
/// Example usage:
/// ```dart
/// await disconnectSendTransportVideo(parameters: {
///   'getUpdatedAllParams': getUpdatedAllParams,
///   'videoProducer': videoProducer,
///   'socket': socket,
///   'islevel': islevel,
///   'roomName': roomName,
///   'updateMainWindow': updateMainWindow,
///   'lockScreen': lockScreen,
///   'updateVideoProducer': updateVideoProducer,
///   'updateUpdateMainWindow': updateUpdateMainWindow,
///   'reorderStreams': reorderStreams,
/// });
///

typedef ReorderStreams = Future<void> Function({
  bool add,
  bool screenChanged,
  required Map<String, dynamic> parameters,
});
typedef UpdateVideoProducer = void Function(dynamic videoProducer);
typedef UpdateUpdateMainWindow = void Function(bool updateMainWindow);
typedef GetUpdatedAllParams = Map<String, dynamic> Function();

Future<void> disconnectSendTransportVideo(
    {required Map<String, dynamic> parameters}) async {
  try {
    // Destructure parameters
    GetUpdatedAllParams getUpdatedAllParams = parameters['getUpdatedAllParams'];
    parameters = getUpdatedAllParams();

    dynamic videoProducer = parameters['videoProducer'];
    final io.Socket socket = parameters['socket'];
    final String islevel = parameters['islevel'];
    final String roomName = parameters['roomName'];
    bool updateMainWindow = parameters['updateMainWindow'];
    final bool lockScreen = parameters['lockScreen'];

    final UpdateVideoProducer updateVideoProducer =
        parameters['updateVideoProducer'];
    final UpdateUpdateMainWindow updateUpdateMainWindow =
        parameters['updateUpdateMainWindow'];

    //mediasfu functions
    final ReorderStreams reorderStreams = parameters['reorderStreams'];

    // Close the video producer and update the state
    await videoProducer.close();
    updateVideoProducer(null);

    // Notify the server about pausing video sharing
    socket.emit(
        'pauseProducerMedia', {'mediaTag': 'video', 'roomName': roomName});

    // Update the UI based on the participant's level and screen lock status
    if (islevel == '2') {
      updateMainWindow = true;
      updateUpdateMainWindow(updateMainWindow);
    }

    if (lockScreen) {
      await reorderStreams(
          add: true, screenChanged: true, parameters: parameters);
    } else {
      await reorderStreams(
          add: false, screenChanged: true, parameters: parameters);
    }
  } catch (error) {
    // Handle errors during the disconnection process
    if (kDebugMode) {
      // print('Error disconnecting send transport for video: ${error.toString()}');
    }
  }
}
