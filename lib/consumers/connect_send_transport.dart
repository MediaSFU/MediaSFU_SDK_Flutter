import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';
import '../types/types.dart'
    show
        ConnectSendTransportAudioOptions,
        ConnectSendTransportAudioParameters,
        ConnectSendTransportAudioType,
        ConnectSendTransportScreenOptions,
        ConnectSendTransportScreenParameters,
        ConnectSendTransportScreenType,
        ConnectSendTransportVideoOptions,
        ConnectSendTransportVideoParameters,
        ConnectSendTransportVideoType,
        ProducerOptionsType;

// Define abstract class for parameters with getter methods
abstract class ConnectSendTransportParameters
    implements
        ConnectSendTransportAudioParameters,
        ConnectSendTransportVideoParameters,
        ConnectSendTransportScreenParameters {
  ProducerOptionsType? get audioParams;
  ProducerOptionsType? get videoParams;
  MediaStream? get localStreamScreen;
  MediaStream? get canvasStream;
  bool get whiteboardStarted;
  bool get whiteboardEnded;
  bool get shared;
  String get islevel;

  ConnectSendTransportAudioType get connectSendTransportAudio;
  ConnectSendTransportVideoType get connectSendTransportVideo;
  ConnectSendTransportScreenType get connectSendTransportScreen;

  ConnectSendTransportParameters Function() get getUpdatedAllParams;

  // dynamic operator [](String key);
}

// Options class for specifying the connection option and parameters
class ConnectSendTransportOptions {
  final String option; // 'audio', 'video', 'screen', or 'all'
  final ConnectSendTransportParameters parameters;
  final Map<String, dynamic>? audioConstraints;
  final Map<String, dynamic>? videoConstraints;

  ConnectSendTransportOptions({
    required this.option,
    required this.parameters,
    this.audioConstraints,
    this.videoConstraints,
  });
}

typedef ConnectSendTransportType = Future<void> Function(
    ConnectSendTransportOptions options);

/// Connects send transport for audio, video, or screen based on the specified option.
///
/// This function manages media stream connections, allowing flexible configuration for different types
/// of media transmission (audio, video, screen) based on the `option` provided. The `option` can be 'audio',
/// 'video', 'screen', or 'all', and the function will handle each case accordingly, utilizing the appropriate
/// connection functions and media streams from `parameters`.
///
/// ### Parameters:
/// - `options` (`ConnectSendTransportOptions`): Contains:
///   - `option` (`String`): Specifies the media type to connect ('audio', 'video', 'screen', or 'all').
///   - `parameters` (`ConnectSendTransportParameters`): Holds necessary configurations, streams, and functions for connection:
///     - `connectSendTransportAudio`, `connectSendTransportVideo`, `connectSendTransportScreen`: Functions for initiating transport.
///     - `audioParams`, `videoParams`: Producer options for audio and video encoding settings.
///     - `localStreamAudio`, `localStreamScreen`, `canvasStream`: Media streams for different types of transmission.
///     - `whiteboardStarted`, `whiteboardEnded`, `shared`, `islevel`: Flags for handling screen sharing or whiteboard state.
///
/// ### Workflow:
/// 1. **Audio Transport**:
///    - If `option` is 'audio', connects the audio stream with `connectSendTransportAudio`.
/// 2. **Video Transport**:
///    - If `option` is 'video', connects the video stream with `connectSendTransportVideo`, using the configured `videoParams`.
/// 3. **Screen Transport**:
///    - If `option` is 'screen', decides which stream to connect based on whiteboard and screen sharing state:
///      - Uses `canvasStream` for a whiteboard in progress if available and permitted by `islevel` and `shared`.
///      - Otherwise, connects `localStreamScreen`.
/// 4. **All Transports**:
///    - If `option` is 'all', initiates connections for both audio and video transports.
///
/// ### Error Handling:
/// - Catches and logs any errors during connection attempts if in debug mode.
///
/// ### Example Usage:
/// ```dart
/// final options = ConnectSendTransportOptions(
///   option: 'all',
///   parameters: myConnectSendTransportParameters,
/// );
///
/// connectSendTransport(options).then(() {
///   print("Send transports connected successfully.");
/// }).catchError((error) {
///   print("Error connecting send transports: $error");
/// });
/// ```
///
/// ### Notes:
/// - This function is designed for flexibility in managing different transport types and media sources,
/// allowing adaptive media handling based on user settings and session requirements.

// Function for connecting the send transport based on the option specified
Future<void> connectSendTransport(
  ConnectSendTransportOptions options,
) async {
  try {
    final videoParams = options.parameters.videoParams;
    final localStreamScreen = options.parameters.localStreamScreen;
    final canvasStream = options.parameters.canvasStream;
    final whiteboardStarted = options.parameters.whiteboardStarted;
    final whiteboardEnded = options.parameters.whiteboardEnded;
    final shared = options.parameters.shared;
    final islevel = options.parameters.islevel;

    final connectSendTransportAudio =
        options.parameters.connectSendTransportAudio;
    final connectSendTransportVideo =
        options.parameters.connectSendTransportVideo;
    final connectSendTransportScreen =
        options.parameters.connectSendTransportScreen;

    // Connect send transport based on the specified option
    if (options.option == 'audio') {
      final optionsAudio = ConnectSendTransportAudioOptions(
        stream: options.parameters.localStreamAudio!,
        parameters: options.parameters,
        audioConstraints: options.audioConstraints,
      );
      await connectSendTransportAudio(
        optionsAudio,
      );
    } else if (options.option == 'video') {
      final optionsVideo = ConnectSendTransportVideoOptions(
        videoParams: videoParams!,
        parameters: options.parameters,
        videoConstraints: options.videoConstraints,
      );
      await connectSendTransportVideo(
        optionsVideo,
      );
    } else if (options.option == 'screen') {
      if (whiteboardStarted &&
          !whiteboardEnded &&
          canvasStream != null &&
          islevel == '2' &&
          !shared) {
        final optionsScreen = ConnectSendTransportScreenOptions(
          stream: canvasStream,
          parameters: options.parameters,
        );
        await connectSendTransportScreen(
          optionsScreen,
        );
      } else if (localStreamScreen != null) {
        final optionsScreen = ConnectSendTransportScreenOptions(
          stream: localStreamScreen,
          parameters: options.parameters,
        );
        await connectSendTransportScreen(
          optionsScreen,
        );
      }
    } else {
      // Connect both audio and video send transports
      final optionsAudio = ConnectSendTransportAudioOptions(
        stream: options.parameters.localStreamAudio!,
        parameters: options.parameters,
        audioConstraints: options.audioConstraints,
      );
      await connectSendTransportAudio(
        optionsAudio,
      );
      final optionsVideo = ConnectSendTransportVideoOptions(
        videoParams: videoParams!,
        parameters: options.parameters,
        videoConstraints: options.videoConstraints,
      );
      await connectSendTransportVideo(
        optionsVideo,
      );
    }
  } catch (error) {
    if (kDebugMode) {
      print('MediaSFU - connectSendTransport error: $error');
    }
  }
}
