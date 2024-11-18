import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';
import '../types/types.dart'
    show
        PrepopulateUserMediaParameters,
        PrepopulateUserMediaType,
        PrepopulateUserMediaOptions;

/// Represents the parameters required to disconnect the audio send transport.
abstract class DisconnectSendTransportAudioParameters
    implements PrepopulateUserMediaParameters {
  Producer? get audioProducer;
  io.Socket? get socket;
  bool get videoAlreadyOn;
  String get islevel;
  bool get lockScreen;
  bool get shared;
  bool get updateMainWindow;
  String get hostLabel;
  String get roomName;

  /// Function to update the audio producer state.
  void Function(Producer? audioProducer) get updateAudioProducer;

  /// Function to update the main window state.
  void Function(bool updateMainWindow) get updateUpdateMainWindow;

  /// Function to prepopulate user media.
  PrepopulateUserMediaType get prepopulateUserMedia;

  // Dynamic access to additional properties if needed
  // dynamic operator [](String key);
}

/// Represents the options required to disconnect the audio send transport.
class DisconnectSendTransportAudioOptions {
  final DisconnectSendTransportAudioParameters parameters;

  DisconnectSendTransportAudioOptions({
    required this.parameters,
  });
}

/// Type definition for the disconnectSendTransportAudio function.
typedef DisconnectSendTransportAudioType = Future<void> Function(
    DisconnectSendTransportAudioOptions options);

/// Disconnects the send transport for audio by pausing the audio producer and updating the UI.
///
/// This function is responsible for pausing the current audio producer and managing the corresponding
/// UI changes. Additionally, it notifies the server to pause the audio producer in the current room.
///
/// ### Parameters:
/// - `options` (`DisconnectSendTransportAudioOptions`): Holds the parameters required for the operation,
///   such as the audio producer instance, socket connection, and relevant UI state.
///
/// ### Function Flow:
/// 1. **Pause Audio Producer**:
///    - If an active audio producer exists, it is paused, and the UI is updated to reflect this change.
/// 2. **UI Update**:
///    - Based on conditions (such as video status, user level, and screen lock status), the main window UI
///      is updated. If no video is active, and certain conditions are met, user media may be prepopulated.
/// 3. **Server Notification**:
///    - Emits a `pauseProducerMedia` event to the server, specifying that the audio producer has been paused
///      in the current room, thus notifying the server of the status change.
///
/// ### Exceptions:
/// - Catches and logs any errors that occur during the process. Further error handling can be implemented
///   as needed, such as user alerts or retries.
///
/// ### Example Usage:
/// ```dart
/// final options = DisconnectSendTransportAudioOptions(
///   parameters: MyDisconnectSendTransportAudioParameters(
///     audioProducer: myAudioProducer,
///     socket: mySocket,
///     videoAlreadyOn: false,
///     islevel: '2',
///     lockScreen: false,
///     shared: false,
///     updateMainWindow: false,
///     hostLabel: 'host123',
///     roomName: 'room1',
///     updateAudioProducer: (producer) => print('Audio Producer Updated: $producer'),
///     updateUpdateMainWindow: (update) => print('Main Window Update: $update'),
///     prepopulateUserMedia: myPrepopulateUserMedia,
///   ),
/// );
///
/// disconnectSendTransportAudio(options).then((_) {
///   print('Audio transport disconnected successfully');
/// }).catchError((error) {
///   print('Error disconnecting audio transport: $error');
/// });
/// ```
///
/// ### Notes:
/// - This function integrates with `prepopulateUserMedia` to manage the state of the main window if video
///   is inactive and specific conditions are met.
/// - It assumes that the server listens to `pauseProducerMedia` events and takes appropriate action upon
///   receiving it.

Future<void> disconnectSendTransportAudio(
    DisconnectSendTransportAudioOptions options) async {
  try {
    // Destructure parameters using getters
    final parameters = options.parameters;
    final Producer? audioProducer = parameters.audioProducer;
    final io.Socket? socket = parameters.socket;
    final bool videoAlreadyOn = parameters.videoAlreadyOn;
    final String islevel = parameters.islevel;
    final bool lockScreen = parameters.lockScreen;
    final bool shared = parameters.shared;
    bool updateMainWindow = parameters.updateMainWindow;
    final String hostLabel = parameters.hostLabel;
    final String roomName = parameters.roomName;

    // Callback functions
    final void Function(Producer? audioProducer) updateAudioProducer =
        parameters.updateAudioProducer;
    final void Function(bool updateMainWindow) updateUpdateMainWindow =
        parameters.updateUpdateMainWindow;

    // mediasfu function
    final PrepopulateUserMediaType prepopulateUserMedia =
        parameters.prepopulateUserMedia;

    // Pause the audio producer
    if (audioProducer != null) {
      audioProducer.pause();
      updateAudioProducer(audioProducer);
    }

    // Update the UI based on conditions
    if (!videoAlreadyOn && islevel == '2') {
      if (!lockScreen && !shared) {
        updateMainWindow = true;
        updateUpdateMainWindow(updateMainWindow);

        // Prepopulate user media
        final optionsPrepopulate = PrepopulateUserMediaOptions(
          name: hostLabel,
          parameters: parameters,
        );
        await prepopulateUserMedia(
          optionsPrepopulate,
        );

        updateMainWindow = false;
        updateUpdateMainWindow(updateMainWindow);
      }
    }

    // Notify the server about pausing the audio producer
    socket!.emit('pauseProducerMedia', {
      'mediaTag': 'audio',
      'roomName': roomName,
    });
  } catch (error) {
    if (kDebugMode) {
      print('MediaSFU - disconnectSendTransportAudio error: $error');
    }
    // Handle errors as needed (e.g., show alert, retry logic)
  }
}
