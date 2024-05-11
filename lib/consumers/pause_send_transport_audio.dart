import 'dart:async';
import 'package:flutter/foundation.dart';

/// Pauses the audio producer and updates the UI accordingly.
///
/// This function takes a map of parameters, including the audio producer,
/// socket, videoAlreadyOn flag, islevel, lockScreen flag, shared flag,
/// updateMainWindow function, hostLabel, roomName, updateAudioProducer
/// function, updateUpdateMainWindow function, and prepopulateUserMedia
/// function. It pauses the audio producer, updates the audio producer if
/// an update function is provided, and updates the UI based on the
/// videoAlreadyOn flag, islevel, lockScreen flag, and shared flag. It also
/// notifies the server about pausing the audio producer.
///
/// If an error occurs, it is caught and handled. In debug mode, the error
/// message is printed to the console.
///
/// Example usage:
/// ```dart
/// await pauseSendTransportAudio(parameters: {
///   'audioProducer': audioProducer,
///   'socket': socket,
///   'videoAlreadyOn': true,
///   'islevel': '2',
///   'lockScreen': false,
///   'shared': false,
///   'updateMainWindow': (bool value) {},
///   'hostLabel': 'Host',
///   'roomName': 'Room 1',
///   'updateAudioProducer': (dynamic value) {},
///   'updateUpdateMainWindow': (bool value) {},
///   'prepopulateUserMedia': (Map<String, dynamic> parameters) => [],
/// });
///

typedef UpdateFunction<T> = void Function(T);
typedef PrepopulateUserMedia = List<dynamic> Function({
  required String name,
  required Map<String, dynamic> parameters,
});
Future<void> pauseSendTransportAudio(
    {required Map<String, dynamic> parameters}) async {
  try {
    // Destructure parameters
    dynamic audioProducer = parameters['audioProducer'];
    dynamic socket = parameters['socket'];
    bool videoAlreadyOn = parameters['videoAlreadyOn'] ?? false;
    String islevel = parameters['islevel'] ?? '1';
    bool lockScreen = parameters['lockScreen'] ?? false;
    bool shared = parameters['shared'] ?? false;
    UpdateFunction<bool>? updateMainWindow = parameters['updateMainWindow'];
    String hostLabel = parameters['hostLabel'] ?? 'Host';
    String roomName = parameters['roomName'];
    UpdateFunction<dynamic>? updateAudioProducer =
        parameters['updateAudioProducer'];
    UpdateFunction<bool>? updateUpdateMainWindow =
        parameters['updateUpdateMainWindow'];

    // mediasfu functions
    PrepopulateUserMedia? prepopulateUserMedia =
        parameters['prepopulateUserMedia'];

    // Pause the audio producer
    await audioProducer.pause();
    if (updateAudioProducer != null) {
      updateAudioProducer(audioProducer);
    }

    // Update the UI
    if (!videoAlreadyOn && islevel == '2') {
      if (!lockScreen && !shared) {
        if (updateMainWindow != null && updateUpdateMainWindow != null) {
          updateMainWindow(true);
          updateUpdateMainWindow(true);
          prepopulateUserMedia?.call(name: hostLabel, parameters: parameters);
          updateMainWindow(false);
          updateUpdateMainWindow(false);
        }
      }
    }

    // Notify the server about pausing audio producer
    await socket.emit(
        'pauseProducerMedia', {'mediaTag': 'audio', 'roomName': roomName});
  } catch (error) {
    // Handle errors
    if (kDebugMode) {
      // print('Error pausing send transport audio: ${error.toString()}');
    }
  }
}
