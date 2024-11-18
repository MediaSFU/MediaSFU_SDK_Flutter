import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../types/types.dart'
    show
        OnScreenChangesType,
        StopShareScreenType,
        DisconnectSendTransportVideoType,
        DisconnectSendTransportAudioType,
        DisconnectSendTransportScreenType,
        OnScreenChangesParameters,
        StopShareScreenParameters,
        DisconnectSendTransportVideoParameters,
        DisconnectSendTransportAudioParameters,
        DisconnectSendTransportScreenParameters,
        DisconnectSendTransportVideoOptions,
        DisconnectSendTransportAudioOptions,
        DisconnectSendTransportScreenOptions,
        OnScreenChangesOptions,
        StopShareScreenOptions;

/// Defines parameters for controlling media host actions in a meeting or room.
abstract class ControlMediaHostParameters
    implements
        OnScreenChangesParameters,
        StopShareScreenParameters,
        DisconnectSendTransportVideoParameters,
        DisconnectSendTransportAudioParameters,
        DisconnectSendTransportScreenParameters {
  // Core properties as abstract getters
  ValueChanged<bool> get updateAdminRestrictSetting;
  MediaStream? get localStream;
  ValueChanged<MediaStream?> get updateLocalStream;
  ValueChanged<bool> get updateAudioAlreadyOn;
  MediaStream? get localStreamScreen;
  ValueChanged<MediaStream?> get updateLocalStreamScreen;
  MediaStream? get localStreamVideo;
  ValueChanged<MediaStream?> get updateLocalStreamVideo;
  ValueChanged<bool> get updateScreenAlreadyOn;
  ValueChanged<bool> get updateVideoAlreadyOn;
  ValueChanged<bool> get updateChatAlreadyOn;

  // MediaSFU functions as abstract getters
  OnScreenChangesType get onScreenChanges;
  StopShareScreenType get stopShareScreen;
  DisconnectSendTransportVideoType get disconnectSendTransportVideo;
  DisconnectSendTransportAudioType get disconnectSendTransportAudio;
  DisconnectSendTransportScreenType get disconnectSendTransportScreen;

  // Method to retrieve updated parameters as an abstract getter
  ControlMediaHostParameters Function() get getUpdatedAllParams;

  // Allows dynamic property access if needed
  // dynamic operator [](String key);
}

/// Defines the options needed for controlling media actions on the host side.
class ControlMediaHostOptions {
  final String type; // 'audio', 'video', 'screenshare', 'chat', or 'all'
  final ControlMediaHostParameters parameters;

  ControlMediaHostOptions({
    required this.type,
    required this.parameters,
  });
}

typedef ControlMediaHostType = Future<void> Function(
    ControlMediaHostOptions options);

/// Controls media actions based on the specified [ControlMediaHostOptions].
///
/// This function manages media control actions (such as disabling audio, video, or screenshare)
/// for the host in a meeting or room. It performs actions based on the provided `type` and
/// updates the relevant media states through callbacks in `ControlMediaHostParameters`.
///
/// - [options] defines the media action type and the parameters needed for the function:
///   - `type`: Specifies the media type to control, which can be `'audio'`, `'video'`,
///     `'screenshare'`, `'chat'`, or `'all'`.
///   - `parameters`: Contains the callbacks and media streams to manage each media action,
///     such as disconnecting transports, updating local streams, and stopping screenshare.
///
/// ### Function Actions
/// - If `type` is `'audio'`, disables audio in the local stream and disconnects the audio transport.
/// - If `type` is `'video'`, disables video in the local and video streams, and disconnects the video transport.
/// - If `type` is `'screenshare'`, stops the screenshare stream and disconnects the screenshare transport.
/// - If `type` is `'chat'`, updates the chat state to be inactive.
/// - If `type` is `'all'`, performs all media actions: disables audio, video, and screenshare, and disconnects each transport.
///
/// ### Example Usage:
/// ```dart
/// final options = ControlMediaHostOptions(
///   type: 'video',
///   parameters: ControlMediaHostParameters(
///     updateAdminRestrictSetting: (value) => print('Admin restriction set to: $value'),
///     localStream: MediaStream(),
///     updateLocalStream: (stream) => print('Local stream updated: $stream'),
///     updateAudioAlreadyOn: (value) => print('Audio already on updated: $value'),
///     localStreamScreen: MediaStream(),
///     updateLocalStreamScreen: (stream) => print('Local screen stream updated: $stream'),
///     localStreamVideo: MediaStream(),
///     updateLocalStreamVideo: (stream) => print('Local video stream updated: $stream'),
///     updateScreenAlreadyOn: (value) => print('Screen already on updated: $value'),
///     updateVideoAlreadyOn: (value) => print('Video already on updated: $value'),
///     updateChatAlreadyOn: (value) => print('Chat already on updated: $value'),
///     onScreenChanges: (isOn) async => print('Screen changes: $isOn'),
///     stopShareScreen: () async => print('Screenshare stopped'),
///     disconnectSendTransportVideo: () async => print('Video transport disconnected'),
///     disconnectSendTransportAudio: () async => print('Audio transport disconnected'),
///     disconnectSendTransportScreen: () async => print('Screen transport disconnected'),
///   ),
/// );
///
/// await controlMediaHost(options);
/// ```
///
/// In this example:
/// - The `type` is set to `'video'`, so the function disables video in the local stream
///   and disconnects the video transport.
/// - Callbacks are provided for each media action, printing updates to the console as
///   the function progresses through the control actions.

Future<void> controlMediaHost(ControlMediaHostOptions options) async {
  final params = options.parameters.getUpdatedAllParams();

  params.updateAdminRestrictSetting(true);

  try {
    switch (options.type) {
      case 'audio':
        params.localStream?.getAudioTracks().first.enabled = false;
        params.updateLocalStream(params.localStream);
        final optionsDisconnect = DisconnectSendTransportAudioOptions(
          parameters: params,
        );
        await params.disconnectSendTransportAudio(optionsDisconnect);
        params.updateAudioAlreadyOn(false);
        break;

      case 'video':
        params.localStream?.getVideoTracks().first.enabled = false;
        params.updateLocalStream(params.localStream);
        final optionsDisconnect = DisconnectSendTransportVideoOptions(
          parameters: params,
        );
        await params.disconnectSendTransportVideo(optionsDisconnect);
        final optionsOnScreen = OnScreenChangesOptions(
          changed: true,
          parameters: params,
        );
        await params.onScreenChanges(optionsOnScreen);
        params.updateVideoAlreadyOn(false);

        params.localStreamVideo?.getVideoTracks().first.enabled = false;
        params.updateLocalStreamVideo(params.localStreamVideo);
        await params.disconnectSendTransportVideo(optionsDisconnect);
        await params.onScreenChanges(optionsOnScreen);
        params.updateVideoAlreadyOn(false);
        break;

      case 'screenshare':
        params.localStreamScreen?.getVideoTracks().first.enabled = false;
        params.updateLocalStreamScreen(params.localStreamScreen);
        final optionsDisconnect = DisconnectSendTransportScreenOptions(
          parameters: params,
        );
        await params.disconnectSendTransportScreen(optionsDisconnect);
        final optionsStopShare = StopShareScreenOptions(
          parameters: params,
        );
        await params.stopShareScreen(optionsStopShare);
        params.updateScreenAlreadyOn(false);
        break;

      case 'chat':
        params.updateChatAlreadyOn(false);
        break;

      case 'all':
        try {
          params.localStream?.getAudioTracks().first.enabled = false;
          params.updateLocalStream(params.localStream);
          final optionsDisconnect = DisconnectSendTransportAudioOptions(
            parameters: params,
          );
          await params.disconnectSendTransportAudio(optionsDisconnect);
          params.updateAudioAlreadyOn(false);
        } catch (error) {
          if (kDebugMode) print('Error controlling audio: $error');
        }

        try {
          params.localStreamScreen?.getVideoTracks().first.enabled = false;
          params.updateLocalStreamScreen(params.localStreamScreen);
          final optionsDisconnect = DisconnectSendTransportScreenOptions(
            parameters: params,
          );
          await params.disconnectSendTransportScreen(optionsDisconnect);
          final optionsStopShare = StopShareScreenOptions(
            parameters: params,
          );
          await params.stopShareScreen(optionsStopShare);
          params.updateScreenAlreadyOn(false);
        } catch (error) {
          if (kDebugMode) print('Error controlling screenshare: $error');
        }

        try {
          params.localStream?.getVideoTracks().first.enabled = false;
          params.updateLocalStream(params.localStream);
          final optionsDisconnect = DisconnectSendTransportVideoOptions(
            parameters: params,
          );
          await params.disconnectSendTransportVideo(optionsDisconnect);
          final optionsOnScreen = OnScreenChangesOptions(
            changed: true,
            parameters: params,
          );
          await params.onScreenChanges(optionsOnScreen);
          params.updateVideoAlreadyOn(false);

          params.localStreamVideo?.getVideoTracks().first.enabled = false;
          params.updateLocalStreamVideo(params.localStreamVideo);
          await params.disconnectSendTransportVideo(optionsDisconnect);
          await params.onScreenChanges(optionsOnScreen);
          params.updateVideoAlreadyOn(false);
        } catch (error) {
          if (kDebugMode) print('Error controlling video: $error');
        }
        break;

      default:
        throw ArgumentError('Invalid media control type');
    }
  } catch (error) {
    if (kDebugMode) print('Error in controlMediaHost: $error');
  }
}
