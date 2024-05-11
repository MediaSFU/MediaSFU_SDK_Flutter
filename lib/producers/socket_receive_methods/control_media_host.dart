import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// Controls the media of the participant based on the request from the host/co-host.
///
/// The [type] parameter specifies the type of media to control, such as 'audio', 'video', 'screenshare', 'chat', or 'all'.
/// The [parameters] parameter is a map that contains various callback functions and values used for controlling the media host.
///
/// The callback functions include:
/// - [onScreenChanges]: A function that is called when the screen changes.
/// - [stopShareScreen]: A function that is called to stop sharing the screen.
/// - [disconnectSendTransportVideo]: A function that is called to disconnect the video send transport.
/// - [disconnectSendTransportAudio]: A function that is called to disconnect the audio send transport.
/// - [disconnectSendTransportScreen]: A function that is called to disconnect the screen send transport.
///
/// The value change functions include:
/// - [updateAudioAlreadyOn]: A function that is called to update the audio already on status.
/// - [updateVideoAlreadyOn]: A function that is called to update the video already on status.
/// - [updateScreenAlreadyOn]: A function that is called to update the screen already on status.
/// - [updateChatAlreadyOn]: A function that is called to update the chat already on status.
/// - [updateLocalStream]: A function that is called to update the local media stream.
/// - [updateLocalStreamScreen]: A function that is called to update the local screen media stream.
/// - [updateAdminRestrictSetting]: A function that is called to update the admin restrict setting.
///
/// This function controls the media host based on the given [type] and [parameters].
/// It performs various actions such as enabling/disabling audio/video tracks, disconnecting send transports,
/// stopping screen sharing, and updating status variables.
/// If the [type] is 'all', it performs all the actions mentioned above.
///
/// Throws an error if any error occurs during the control process.

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

typedef ValueChanged<T> = void Function(T value);

void controlMediaHost({
  required String type,
  required Map<String, dynamic> parameters,
}) async {
  // mediasfu functions
  final OnScreenChanges onScreenChanges = parameters['onScreenChanges'];
  final StopShareScreen stopShareScreen = parameters['stopShareScreen'];
  final DisconnectSendTransportVideo disconnectSendTransportVideo =
      parameters['disconnectSendTransportVideo'];
  final DisconnectSendTransportAudio disconnectSendTransportAudio =
      parameters['disconnectSendTransportAudio'];
  final DisconnectSendTransportScreen disconnectSendTransportScreen =
      parameters['disconnectSendTransportScreen'];

  final ValueChanged<bool> updateAudioAlreadyOn =
      parameters['updateAudioAlreadyOn'];
  final ValueChanged<bool> updateVideoAlreadyOn =
      parameters['updateVideoAlreadyOn'];
  final ValueChanged<bool> updateScreenAlreadyOn =
      parameters['updateScreenAlreadyOn'];
  final ValueChanged<bool> updateChatAlreadyOn =
      parameters['updateChatAlreadyOn'];
  final ValueChanged<MediaStream> updateLocalStream =
      parameters['updateLocalStream'];
  final ValueChanged<MediaStream> updateLocalStreamScreen =
      parameters['updateLocalStreamScreen'];
  final ValueChanged<bool> updateAdminRestrictSetting =
      parameters['updateAdminRestrictSetting'];

  bool adminRestrictSetting = true;
  updateAdminRestrictSetting(adminRestrictSetting);

  try {
    if (type == 'audio') {
      parameters['localStream'].getAudioTracks()[0].enabled = false;
      updateLocalStream(parameters['localStream']);
      await disconnectSendTransportAudio(parameters: parameters);
      updateAudioAlreadyOn(false);
    } else if (type == 'video') {
      parameters['localStream'].getVideoTracks()[0].enabled = false;
      updateLocalStream(parameters['localStream']);
      await disconnectSendTransportVideo(parameters: parameters);
      updateVideoAlreadyOn(false);
      await onScreenChanges(changed: true, parameters: parameters);
    } else if (type == 'screenshare') {
      parameters['localStreamScreen'].getVideoTracks()[0].enabled = false;
      updateLocalStreamScreen(parameters['localStreamScreen']);
      await disconnectSendTransportScreen(parameters: parameters);
      await stopShareScreen(parameters: parameters);
      updateScreenAlreadyOn(false);
    } else if (type == 'chat') {
      updateChatAlreadyOn(false);
    } else if (type == 'all') {
      try {
        parameters['localStream'].getAudioTracks()[0].enabled = false;
        updateLocalStream(parameters['localStream']);
        await disconnectSendTransportAudio(parameters: parameters);
        updateAudioAlreadyOn(false);
      } catch (error) {
        if (kDebugMode) {
          print('Error controlling audio: $error');
        }
      }

      try {
        parameters['localStreamScreen'].getVideoTracks()[0].enabled = false;
        updateLocalStreamScreen(parameters['localStreamScreen']);
        await disconnectSendTransportScreen(parameters: parameters);
        await stopShareScreen(parameters: parameters);
        updateScreenAlreadyOn(false);
      } catch (error) {
        if (kDebugMode) {
          print('Error controlling screenshare: $error');
        }
      }

      try {
        parameters['localStream'].getVideoTracks()[0].enabled = false;
        updateLocalStream(parameters['localStream']);
        await disconnectSendTransportVideo(parameters: parameters);
        updateVideoAlreadyOn(false);
        await onScreenChanges(changed: true, parameters: parameters);
      } catch (error) {
        if (kDebugMode) {
          print('Error controlling video: $error');
        }
      }
    }
  } catch (error) {
    if (kDebugMode) {
      print('Error in controlMediaHost: $error');
    }
  }
}
