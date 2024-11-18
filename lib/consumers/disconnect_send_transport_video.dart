import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';
import '../types/types.dart'
    show ReorderStreamsType, ReorderStreamsParameters, ReorderStreamsOptions;

/// Callback types
typedef UpdateVideoProducer = void Function(Producer? videoProducer);
typedef UpdateUpdateMainWindow = void Function(bool updateMainWindow);

/// Represents the parameters required to disconnect the video send transport.
abstract class DisconnectSendTransportVideoParameters {
  Producer? get videoProducer;
  io.Socket? get socket;
  String get islevel;
  String get roomName;
  bool get lockScreen;
  bool get updateMainWindow;

  UpdateVideoProducer get updateVideoProducer;
  UpdateUpdateMainWindow get updateUpdateMainWindow;
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

/// Disconnects the send transport for video by closing the video producer, updating the UI, and notifying the server.
///
/// This function handles video disconnection through these key actions:
/// 1. **Closes the Video Producer**:
///    - If there is an active `videoProducer`, it is closed, stopping video transmission on the client side.
///    - Updates the producer state to reflect the closure.
/// 2. **Server Notification**:
///    - Notifies the server about the paused video sharing by emitting the `pauseProducerMedia` event with the `video` media tag.
/// 3. **UI Updates**:
///    - Adjusts the main window display state based on the `islevel` and `lockScreen` properties.
///    - Reorders streams on the UI according to the updated parameters, enhancing the visual layout.
///
/// ### Parameters:
/// - `options` (`DisconnectSendTransportVideoOptions`): The options for disconnecting the video send transport.
///   - Contains required parameters, including the video producer, socket connection, room name, and callback functions.
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
///     socket: mySocket,
///     islevel: '2',
///     roomName: 'myRoom',
///     lockScreen: false,
///     updateMainWindow: true,
///     updateVideoProducer: (producer) => print('Video producer updated: $producer'),
///     updateUpdateMainWindow: (value) => print('Main window updated: $value'),
///     reorderStreams: (options) => print('Streams reordered: $options'),
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
    final UpdateVideoProducer updateVideoProducer =
        parameters.updateVideoProducer;
    final UpdateUpdateMainWindow updateUpdateMainWindow =
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
  } catch (error) {
    if (kDebugMode) {
      print('Error disconnecting send transport for video: $error');
    }
  }
}
