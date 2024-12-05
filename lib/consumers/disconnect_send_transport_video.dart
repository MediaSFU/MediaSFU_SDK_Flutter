import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';
import '../types/types.dart'
    show ReorderStreamsType, ReorderStreamsParameters, ReorderStreamsOptions;

/// Callback types/// Represents the parameters required to disconnect the video send transport.
abstract class DisconnectSendTransportVideoParameters {
  // Remote Video Transport and Producer
  Producer? get videoProducer;
  io.Socket? get socket;

  // Local Video Transport and Producer
  Producer? get localVideoProducer;
  io.Socket? get localSocket;

  // Other Parameters
  String get islevel;
  String get roomName;
  bool get lockScreen;
  bool get updateMainWindow;

  // Update Functions
  void Function(Producer? videoProducer) get updateVideoProducer;
  void Function(Producer? localVideoProducer)? get updateLocalVideoProducer;
  void Function(bool updateMainWindow) get updateUpdateMainWindow;

  // Mediasfu Functions
  ReorderStreamsType get reorderStreams;

  // Function to get updated parameters
  DisconnectSendTransportVideoParameters Function() get getUpdatedAllParams;

  // Dynamic access to other properties if needed
  // dynamic operator [](String key);
}

/// Represents the options required to disconnect the video send transport.
class DisconnectSendTransportVideoOptions {
  final DisconnectSendTransportVideoParameters parameters;

  DisconnectSendTransportVideoOptions({
    required this.parameters,
  });
}

/// Type definition for disconnectSendTransportVideo function.
typedef DisconnectSendTransportVideoType = Future<void> Function(
    DisconnectSendTransportVideoOptions options);

/// Disconnects the local send transport for video by closing the local video producer and notifying the server.
///
/// ### Parameters:
/// - `options` (`DisconnectSendTransportVideoOptions`): Contains the parameters required for disconnecting the local video transport.
///
/// ### Workflow:
/// 1. **Close Local Video Producer**:
///    - If an active local video producer exists, it is closed.
///    - The local state is updated to reflect the closed producer.
/// 2. **Notify Server**:
///    - Emits `pauseProducerMedia` event with `mediaTag` as `video` to notify about the paused local video producer.
///
/// ### Returns:
/// - A `Future<void>` that completes when the local video transport is successfully disconnected.
///
/// ### Error Handling:
/// - Logs errors to the console in debug mode and rethrows them for higher-level handling.
///
/// ### Example Usage:
/// ```dart
/// final options = DisconnectSendTransportVideoOptions(
///   parameters: myDisconnectSendTransportVideoParameters,
/// );
///
/// disconnectLocalSendTransportVideo(options)
///   .then(() => print('Local video send transport disconnected successfully'))
///   .catchError((error) => print('Error disconnecting local video send transport: $error'));
/// ```
Future<void> disconnectLocalSendTransportVideo(
    DisconnectSendTransportVideoOptions options) async {
  try {
    final parameters = options.parameters;

    final Producer? localVideoProducer = parameters.localVideoProducer;
    final io.Socket? localSocket = parameters.localSocket;
    final String roomName = parameters.roomName;
    final void Function(Producer? localVideoProducer)?
        updateLocalVideoProducer = parameters.updateLocalVideoProducer;

    if (localSocket == null || localSocket.id == null) {
      // Local socket is not connected; nothing to disconnect
      return;
    }

    // Close the local video producer and update the state
    if (localVideoProducer != null) {
      localVideoProducer.close();
      updateLocalVideoProducer?.call(null); // Set to null after closing
    }

    // Notify the server about closing the local video producer and pausing video sharing
    localSocket.emit('pauseProducerMedia', {
      'mediaTag': 'video',
      'roomName': roomName,
    });
  } catch (error) {
    if (kDebugMode) {
      print('Error disconnecting local send transport for video: $error');
    }
    rethrow; // Re-throw to propagate the error
  }
}

/// Disconnects the send transport for video by closing the video producer(s), updating the UI, and notifying the server.
///
/// This function supports both a primary and a local video producer, delegating local handling to a separate function.
///
/// ### Parameters:
/// - `options` (`DisconnectSendTransportVideoOptions`): Contains the parameters required for disconnecting the video send transport.
///
/// ### Workflow:
/// 1. **Close Primary Video Producer**:
///    - If an active primary video producer exists, it is closed.
///    - The primary state is updated to reflect the closed producer.
/// 2. **Notify Server**:
///    - Emits `pauseProducerMedia` event with `mediaTag` as `video` to notify about the paused primary video producer.
/// 3. **Update UI**:
///    - Based on `islevel` and `lockScreen` status, updates the main window state.
/// 4. **Reorder Streams**:
///    - Calls `reorderStreams` to adjust the stream layout based on the current state.
/// 5. **Handle Local Video Transport Disconnection**:
///    - Invokes `disconnectLocalSendTransportVideo` to handle the local video transport disconnection.
///
/// ### Returns:
/// - A `Future<void>` that completes when the video send transport(s) are successfully disconnected.
///
/// ### Error Handling:
/// - Catches and logs any errors encountered during the disconnection process.
/// - Errors are printed to the console in debug mode to aid troubleshooting.
///
/// ### Example Usage:
/// ```dart
/// final options = DisconnectSendTransportVideoOptions(
///   parameters: MyDisconnectSendTransportVideoParameters(
///     videoProducer: myVideoProducer,
///     localVideoProducer: myLocalVideoProducer,
///     socket: mySocket,
///     localSocket: myLocalSocket,
///     islevel: '2',
///     roomName: 'myRoom',
///     lockScreen: false,
///     updateMainWindow: true,
///     updateVideoProducer: (producer) => print('Video producer updated: $producer'),
///     updateLocalVideoProducer: (producer) => print('Local video producer updated: $producer'),
///     updateUpdateMainWindow: (state) => print('Main window updated: $state'),
///     reorderStreams: reorderStreamsFunction,
///     getUpdatedAllParams: () => myUpdatedParameters,
///   ),
/// );
///
/// disconnectSendTransportVideo(options).then((_) {
///   print('Video send transport disconnected successfully');
/// }).catchError((error) {
///   print('Error disconnecting video send transport: $error');
/// });
/// ```
///
/// ### Notes:
/// - Assumes server processing of `pauseProducerMedia` and `reorderStreams` events to update video sharing status.
/// - Relies on `updateVideoProducer` and `updateUpdateMainWindow` callbacks to manage the state after video disconnection.
///
/// ### Additional Considerations:
/// - Ensures `ReorderStreamsOptions` are accurately set to reorder the stream layout on the UI based on `lockScreen` status.

Future<void> disconnectSendTransportVideo(
    DisconnectSendTransportVideoOptions options) async {
  try {
    // Retrieve updated parameters
    final parameters = options.parameters.getUpdatedAllParams();

    final Producer? videoProducer = parameters.videoProducer;
    final io.Socket? socket = parameters.socket;
    final String islevel = parameters.islevel;
    final String roomName = parameters.roomName;
    bool updateMainWindow = parameters.updateMainWindow;
    final bool lockScreen = parameters.lockScreen;

    // Callbacks
    final void Function(Producer? videoProducer) updateVideoProducer =
        parameters.updateVideoProducer;
    final void Function(bool updateMainWindow) updateUpdateMainWindow =
        parameters.updateUpdateMainWindow;
    final ReorderStreamsType reorderStreams = parameters.reorderStreams;

    // Close the video producer and update the state
    if (videoProducer != null) {
      videoProducer.close();
      updateVideoProducer(null);
    }

    // Notify the server about pausing video sharing
    socket!.emit(
        'pauseProducerMedia', {'mediaTag': 'video', 'roomName': roomName});

    // Update the UI based on level and lock status
    if (islevel == '2') {
      updateMainWindow = true;
      updateUpdateMainWindow(updateMainWindow);
    }

    final optionsReorder = ReorderStreamsOptions(
      add: lockScreen,
      screenChanged: true,
      parameters: parameters as ReorderStreamsParameters,
    );
    await reorderStreams(
      optionsReorder,
    );

    // Handle local video transport disconnection
    try {
      await disconnectLocalSendTransportVideo(options);
    } catch (localError) {
      if (kDebugMode) {
        print('Error disconnecting local video send transport: $localError');
      }
      // Optionally, handle the local error (e.g., show a notification)
    }
  } catch (error) {
    if (kDebugMode) {
      print('Error disconnecting send transport for video: $error');
    }
  }
}
