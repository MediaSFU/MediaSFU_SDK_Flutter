import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:async';

/// Disconnects the send transport audio.
///
/// This function is responsible for pausing the audio producer, updating the UI,
/// and notifying the server about pausing the audio producer.
///
/// Parameters:
/// - `parameters`: A map containing the required parameters for disconnecting the send transport audio.
///
/// Throws:
/// - Any error that occurs during the execution of the function.
///
/// Usage:
/// ```dart
/// await disconnectSendTransportAudio(parameters: {
///   'audioProducer': audioProducer,
///   'socket': socket,
///   'videoAlreadyOn': videoAlreadyOn,
///   'islevel': islevel,
///   'lockScreen': lockScreen,
///   'shared': shared,
///   'updateMainWindow': updateMainWindow,
///   'HostLabel': hostLabel,
///   'roomName': roomName,
///   'updateAudioProducer': updateAudioProducer,
///   'updateUpdateMainWindow': updateUpdateMainWindow,
///   'prepopulateUserMedia': prepopulateUserMedia,
/// });

typedef UpdateAudioProducer = void Function(dynamic audioProducer);
typedef UpdateProducerTransport = void Function(dynamic producerTransport);

typedef PrepopulateUserMedia = List<dynamic> Function({
  required String name,
  required Map<String, dynamic> parameters,
});

typedef UpdateUpdateMainWindow = void Function(bool);

Future<void> disconnectSendTransportAudio({
  required Map<String, dynamic> parameters,
}) async {
  try {
    // Destructure parameters
    final audioProducer = parameters['audioProducer'];
    final io.Socket socket = parameters['socket'];
    final bool videoAlreadyOn = parameters['videoAlreadyOn'];
    final String islevel = parameters['islevel'];
    final bool lockScreen = parameters['lockScreen'];
    final bool shared = parameters['shared'];
    bool updateMainWindow = parameters['updateMainWindow'];
    final String hostLabel = parameters['HostLabel'];
    final String roomName = parameters['roomName'];

    final UpdateAudioProducer updateAudioProducer =
        parameters['updateAudioProducer'];

    final UpdateUpdateMainWindow updateUpdateMainWindow =
        parameters['updateUpdateMainWindow'];

    //mediasfu functions
    final PrepopulateUserMedia prepopulateUserMedia =
        parameters['prepopulateUserMedia'];

    // Pause the audio producer
    await audioProducer
        .pause(); // actual logic is to close (await audioProducer.close()) but mediaSFU prefers pause if recording
    updateAudioProducer(audioProducer);

    // Update the UI
    if (!videoAlreadyOn && islevel == '2') {
      if (!lockScreen && !shared) {
        updateMainWindow = true;
        updateUpdateMainWindow(updateMainWindow);
        prepopulateUserMedia(name: hostLabel, parameters: parameters);
        updateMainWindow = false;
        updateUpdateMainWindow(updateMainWindow);
      }
    }

    // Notify the server about pausing audio producer
    socket.emit(
        'pauseProducerMedia', {'mediaTag': 'audio', 'roomName': roomName});
  } catch (error) {
    // Handle errors here
  }
}
