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
  // Remote Audio Transport and Producer
  Producer? get audioProducer;
  io.Socket? get socket;

  // Local Audio Transport and Producer
  Producer? get localAudioProducer;
  io.Socket? get localSocket;

  // Other Parameters
  bool get videoAlreadyOn;
  String get islevel;
  bool get lockScreen;
  bool get shared;
  bool get updateMainWindow;
  String get hostLabel;
  String get roomName;

  /// Function to update the audio producer state.
  void Function(Producer? audioProducer) get updateAudioProducer;
  void Function(Producer? localAudioProducer)? get updateLocalAudioProducer;
  void Function(bool updateMainWindow) get updateUpdateMainWindow;

  // Mediasfu Functions
  PrepopulateUserMediaType get prepopulateUserMedia;

  // Dynamic access to additional properties if needed
  // dynamic operator [](String key);
  // void operator []=(String key, dynamic value);
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

/// Disconnects the local send transport for audio by pausing the local audio producer and notifying the server.
///
/// ### Parameters:
/// - `options` (`DisconnectSendTransportAudioOptions`): Contains the parameters required for disconnecting the local audio transport.
///
/// ### Workflow:
/// 1. **Pause Local Audio Producer**:
///    - If an active local audio producer exists, it is paused, and the local state is updated.
/// 2. **Notify Server**:
///    - Emits a `pauseProducerMedia` event to the server to notify about the paused local audio producer.
///
/// ### Returns:
/// - A `Future<void>` that completes when the local audio transport is successfully disconnected.
///
/// ### Error Handling:
/// - Logs errors to the console in debug mode and rethrows them for higher-level handling.
///
/// ### Example Usage:
/// ```dart
/// final options = DisconnectSendTransportAudioOptions(
///   parameters: myDisconnectSendTransportAudioParameters,
/// );
///
/// disconnectLocalSendTransportAudio(options)
///   .then(() => print('Local audio send transport disconnected successfully'))
///   .catchError((error) => print('Error disconnecting local audio send transport: $error'));
/// ```
Future<void> disconnectLocalSendTransportAudio(
    DisconnectSendTransportAudioOptions options) async {
  try {
    final parameters = options.parameters;

    final Producer? localAudioProducer = parameters.localAudioProducer;
    final io.Socket? localSocket = parameters.localSocket;
    final String roomName = parameters.roomName;
    final void Function(Producer? localAudioProducer)?
        updateLocalAudioProducer = parameters.updateLocalAudioProducer;

    if (localSocket == null || localSocket.id == null) {
      // Local socket is not connected; nothing to disconnect
      return;
    }

    // Pause the local audio producer
    if (localAudioProducer != null) {
      localAudioProducer
          .pause(); // MediaSFU prefers pause instead of close for recording
      updateLocalAudioProducer?.call(null); // Set to null after pausing
    }

    // Notify the server about pausing the local audio producer
    localSocket.emit('pauseProducerMedia', {
      'mediaTag': 'audio',
      'roomName': roomName,
    });
  } catch (error) {
    if (kDebugMode) {
      print('Error disconnecting local audio send transport: $error');
    }
    rethrow; // Re-throw to propagate the error
  }
}

/// Disconnects the send transport for audio by pausing the audio producer(s) and updating the UI accordingly.
///
/// This function supports both a primary and a local audio producer, delegating local handling to a separate function.
///
/// ### Parameters:
/// - `options` (`DisconnectSendTransportAudioOptions`): Contains the parameters required for disconnecting the audio send transport.
///
/// ### Workflow:
/// 1. **Pause Primary Audio Producer**:
///    - If an active primary audio producer exists, it is paused, and the primary state is updated.
/// 2. **Update UI**:
///    - Based on conditions (such as video status, user level, and screen lock status), the main window UI is updated.
///    - If no video is active and certain conditions are met, user media may be prepopulated.
/// 3. **Notify Server**:
///    - Emits a `pauseProducerMedia` event to the server to notify about the paused primary audio producer.
/// 4. **Handle Local Audio Transport**:
///    - Invokes `disconnectLocalSendTransportAudio` to handle the local audio transport disconnection.
///
/// ### Returns:
/// - A `Future<void>` that completes when the audio send transport(s) are successfully disconnected.
///
/// ### Error Handling:
/// - Logs errors to the console in debug mode and rethrows them for higher-level handling.
///
/// ### Example Usage:
/// ```dart
/// final options = DisconnectSendTransportAudioOptions(
///   parameters: MyDisconnectSendTransportAudioParameters(
///     audioProducer: myAudioProducer,
///     localAudioProducer: myLocalAudioProducer,
///     socket: mySocket,
///     localSocket: myLocalSocket,
///     videoAlreadyOn: false,
///     islevel: '1',
///     lockScreen: false,
///     shared: false,
///     updateMainWindow: true,
///     hostLabel: 'Host',
///     roomName: 'Room 1',
///     updateAudioProducer: (producer) => print('Updated audio producer: $producer'),
///     updateLocalAudioProducer: (producer) => print('Updated local audio producer: $producer'),
///     updateUpdateMainWindow: (state) => print('Main window state updated: $state'),
///     prepopulateUserMedia: myPrepopulateUserMediaFunction,
///   ),
/// );
///
/// disconnectSendTransportAudio(options)
///   .then(() => print('Audio send transport disconnected successfully'))
///   .catchError((error) => print('Error disconnecting audio send transport: $error'));
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

    // Handle local audio transport disconnection
    try {
      await disconnectLocalSendTransportAudio(options);
    } catch (localError) {
      if (kDebugMode) {
        print('Error disconnecting local audio send transport: $localError');
      }
      // Optionally, handle the local error (e.g., show a notification)
    }
  } catch (error) {
    if (kDebugMode) {
      print('MediaSFU - disconnectSendTransportAudio error: $error');
    }
    // Handle errors as needed (e.g., show alert, retry logic)
  }
}
