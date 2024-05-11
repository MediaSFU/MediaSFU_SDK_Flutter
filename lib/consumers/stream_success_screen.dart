// ignore_for_file: empty_catches

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Handles the success scenario of sharing a screen in a video conference.
///
/// This function takes in a [stream] of type [MediaStream] and [parameters] of type [Map<String, dynamic>].
/// The [stream] represents the media stream of the shared screen, while the [parameters] contain various parameters and callbacks required for the screen sharing process.
///
/// The function performs the following steps:
/// 1. Destructures the [parameters] map to access the required values.
/// 2. Shares the screen by creating or connecting to a send transport.
/// 3. Alerts the socket that the screen sharing has started.
/// 4. Updates the screen display and participants array to reflect the change.
/// 5. Reorders the streams if required.
/// 6. Handles the end of screen sharing.
/// 7. Updates the state variables related to screen action and transport creation.
///
/// If an error occurs during the screen sharing process, an alert is displayed and the error is rethrown.
///
/// Example usage:
/// ```dart
/// await streamSuccessScreen(stream: mediaStream, parameters: {
///   'socket': socket,
///   'screenAction': true,
///   'transportCreated': false,
///   'hostLabel': 'host',
///   'eventType': 'conference',
///   'showAlert': showAlertCallback,
///   'updateTransportCreatedScreen': updateTransportCreatedScreenCallback,
///   'updateScreenAlreadyOn': updateScreenAlreadyOnCallback,
///   'updateScreenAction': updateScreenActionCallback,
///   'updateTransportCreated': updateTransportCreatedCallback,
///   'updateShared': updateSharedCallback,
///   'updateLocalStreamScreen': updateLocalStreamScreenCallback,
///   'disconnectSendTransportScreen': disconnectSendTransportScreenCallback,
///   'stopShareScreen': stopShareScreenCallback,
///   'reorderStreams': reorderStreamsCallback,
///   'prepopulateUserMedia': prepopulateUserMediaCallback,
///   'rePort': rePortCallback,
///   'createSendTransport': createSendTransportCallback,
///   'connectSendTransportScreen': connectSendTransportScreenCallback,
/// });
/// ```

typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

typedef ConnectSendTransportScreen = Future<void> Function({
  required MediaStream stream,
  required Map<String, dynamic> parameters,
});

typedef OnScreenChanges = Future<void> Function(
    {bool changed, required Map<String, dynamic> parameters});
typedef StopShareScreen = Future<void> Function(
    {required Map<String, dynamic> parameters});
typedef DisconnectSendTransportVideo = Future<void> Function(
    {required Map<String, dynamic> parameters});
typedef DisconnectSendTransportAudio = Future<void> Function(
    {required Map<String, dynamic> parameters});
typedef DisconnectSendTransportScreen = Future<void> Function(
    {required Map<String, dynamic> parameters});

typedef PrepopulateUserMedia = List<dynamic> Function({
  required String name,
  required Map<String, dynamic> parameters,
});

typedef ReorderStreams = Future<void> Function({
  bool add,
  bool screenChanged,
  required Map<String, dynamic> parameters,
});

typedef CreateSendTransport = Future<void> Function({
  required String option,
  required Map<String, dynamic> parameters,
});

typedef RePort = Future<void> Function(
    {bool restart, required Map<String, dynamic> parameters});

typedef UpdateTransportCreatedScreen = void Function(
    bool transportCreatedScreen);
typedef UpdateScreenAlreadyOn = void Function(bool screenAlreadyOn);
typedef UpdateScreenAction = void Function(bool screenAction);
typedef UpdateTransportCreated = void Function(bool transportCreated);
typedef UpdateLocalStreamScreen = void Function(MediaStream stream);
typedef UpdateShared = void Function(bool shared);

Future<void> streamSuccessScreen(
    {required MediaStream stream,
    required Map<String, dynamic> parameters}) async {
  try {
    // Destructure parameters
    final io.Socket socket = parameters['socket'];

    // Access values from the parameters map directly
    bool screenAction = parameters['screenAction'] ?? false;
    bool transportCreated = parameters['transportCreated'] ?? false;
    String hostLabel = parameters['hostLabel'] ?? 'host';
    String eventType = parameters['eventType'] ?? 'conference';
    ShowAlert? showAlert = parameters['showAlert'];
    UpdateTransportCreatedScreen updateTransportCreatedScreen =
        parameters['updateTransportCreatedScreen'];
    UpdateScreenAlreadyOn updateScreenAlreadyOn =
        parameters['updateScreenAlreadyOn'];
    UpdateScreenAction updateScreenAction = parameters['updateScreenAction'];
    UpdateTransportCreated updateTransportCreated =
        parameters['updateTransportCreated'];
    UpdateShared updateShared = parameters['updateShared'];
    UpdateLocalStreamScreen updateLocalStreamScreen =
        parameters['updateLocalStreamScreen'];

    // mediasfu functions
    DisconnectSendTransportScreen disconnectSendTransportScreen =
        parameters['disconnectSendTransportScreen'];
    StopShareScreen stopShareScreen = parameters['stopShareScreen'];
    ReorderStreams reorderStreams = parameters['reorderStreams'];
    PrepopulateUserMedia prepopulateUserMedia =
        parameters['prepopulateUserMedia'];
    RePort rePort = parameters['rePort'];
    CreateSendTransport createSendTransport = parameters['createSendTransport'];
    ConnectSendTransportScreen connectSendTransportScreen =
        parameters['connectSendTransportScreen'];

    // Share screen on success
    MediaStream localStreamScreen = stream;
    updateLocalStreamScreen(localStreamScreen);

    try {
      // Create transport if not created else connect transport
      if (!transportCreated) {
        await createSendTransport(
            option: 'screen',
            parameters: {...parameters, 'localStreamScreen': stream});
      } else {
        await connectSendTransportScreen(
            stream: stream,
            parameters: {...parameters, 'localStreamScreen': stream});
      }

      // Alert the socket that you are sharing screen
      socket.emit('startScreenShare');
    } catch (error) {
      if (showAlert != null) {
        showAlert(
            message: 'Error sharing screen: $error',
            type: 'danger',
            duration: 3000);
      }
    }

    // Reupdate the screen display
    try {
      updateShared(true);
      prepopulateUserMedia(name: hostLabel, parameters: {
        ...parameters,
        'localStreamScreen': stream,
        'shared': true
      });
    } catch (error) {}

    // Update the participants array to reflect the change
    updateScreenAlreadyOn(true);

    // Reorder streams if required
    try {
      if (eventType == 'conference') {
        await reorderStreams(
            add: false, screenChanged: true, parameters: parameters);
        prepopulateUserMedia(name: hostLabel, parameters: parameters);
      } else {
        reorderStreams(parameters: parameters);
      }
    } catch (error) {
      rePort(parameters: parameters);
    }

    // Handle screen share end
    stream.getVideoTracks().first.onEnded = () async {
      // Supports both manual and automatic screen share end
      disconnectSendTransportScreen(parameters: parameters);
      stopShareScreen(parameters: parameters);
    };

    // If user requested to share screen, update the screenAction state
    if (screenAction == true) {
      screenAction = false;
    }
    updateScreenAction(screenAction);

    // Update the transport created state
    updateTransportCreatedScreen(true);
    updateTransportCreated(true);
  } catch (error) {
    try {
      // Display an alert if an error occurs

      final ShowAlert? showAlert = parameters['showAlert'];
      if (showAlert != null) {
        showAlert(
          message: 'Error sharing screen - check and try again',
          type: 'danger',
          duration: 3000,
        );
      }
    } catch (error) {}
    rethrow;
  }
}
