import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart'
    show Producer, Transport;
import '../types/types.dart'
    show
        Participant,
        PrepopulateUserMediaParameters,
        ShowAlert,
        ResumeSendTransportAudioParameters,
        PrepopulateUserMediaType,
        ResumeSendTransportAudioType,
        ProducerOptionsType;

abstract class ConnectSendTransportAudioParameters
    implements
        ResumeSendTransportAudioParameters,
        PrepopulateUserMediaParameters {
  io.Socket? get socket;
  List<Participant> get participants;
  MediaStream? get localStream;
  bool get transportCreated;
  bool get transportCreatedAudio;
  bool get audioAlreadyOn;
  bool get micAction;
  ProducerOptionsType? get audioParams;
  MediaStream? get localStreamAudio;
  String get defAudioID;
  String get userDefaultAudioInputDevice;
  ProducerOptionsType? get params;
  ProducerOptionsType? get aParams;
  String get hostLabel;
  String get islevel;
  String get member;
  bool get updateMainWindow;
  bool get lockScreen;
  bool get shared;
  bool get videoAlreadyOn;
  ShowAlert? get showAlert;
  Transport? get producerTransport;
  Transport? get localProducerTransport;

  // Update Functions
  void Function(List<Participant> participants) get updateParticipants;
  void Function(bool transportCreated) get updateTransportCreated;
  void Function(bool transportCreatedAudio) get updateTransportCreatedAudio;
  void Function(bool audioAlreadyOn) get updateAudioAlreadyOn;
  void Function(bool micAction) get updateMicAction;
  void Function(ProducerOptionsType audioParams) get updateAudioParams;
  void Function(MediaStream? localStream) get updateLocalStream;
  void Function(MediaStream? localStreamAudio) get updateLocalStreamAudio;
  void Function(String defAudioID) get updateDefAudioID;
  void Function(String userDefaultAudioInputDevice)
      get updateUserDefaultAudioInputDevice;
  void Function(bool updateMainWindow) get updateUpdateMainWindow;
  void Function(Transport producerTransport) get updateProducerTransport;
  void Function(Transport? localProducerTransport)?
      get updateLocalProducerTransport;
  void Function(double audioLevel) get updateAudioLevel;

  // MediaSFU functions
  ResumeSendTransportAudioType get resumeSendTransportAudio;
  PrepopulateUserMediaType get prepopulateUserMedia;

  ConnectSendTransportAudioParameters Function() get getUpdatedAllParams;
  // dynamic operator [](String key);
}

class ConnectSendTransportAudioOptions {
  MediaStream stream;
  final ConnectSendTransportAudioParameters parameters;
  final Map<String, dynamic>? audioConstraints;
  String? targetOption; // 'all', 'local', 'remote'

  ConnectSendTransportAudioOptions(
      {required this.stream,
      required this.parameters,
      this.audioConstraints,
      this.targetOption = 'all'});
}

typedef ConnectSendTransportAudioType = Future<void> Function(
    ConnectSendTransportAudioOptions options);

/// Updates the microphone audio level periodically.
///
/// This function retrieves stats from the audio producer's RTP sender every 1 second,
/// calculates the audio level, and calls the provided `updateAudioLevel` callback.
///
/// Parameters:
/// - `audioSender`: The [RTCRtpSender] instance for the audio producer.
/// - `updateAudioLevel`: A callback function to handle the updated audio level.
///
/// Example usage:
/// ```dart
/// updateMicLevel(audioSender, (level) {
///   print('Current audio level: $level');
/// });
/// ```
void updateMicLevel(
    Producer? audioProducer, void Function(double level) updateAudioLevel) {
  if (audioProducer == null) {
    return;
  }

  final audioSender = audioProducer.rtpSender;

  Timer.periodic(const Duration(seconds: 1), (timer) async {
    try {
      final stats = await audioSender?.getStats();

      if (stats == null) {
        return;
      }

      for (var report in stats) {
        if (report.type == 'media-source' &&
            report.values['audioLevel'] != null) {
          final double audioLevel = report.values['audioLevel'] as double;
          final double newLevel = 127.5 + (audioLevel * 127.5);
          updateAudioLevel(newLevel);
        }
      }
    } catch (_) {
      // Handle error if showAlert is available
    }
  });
}

/// Connects the local send transport for audio by producing audio data and updating the local audio producer and transport.
Future<void> connectLocalSendTransportAudio({
  required ConnectSendTransportAudioOptions options,
}) async {
  try {
    final parameters = options.parameters;
    final audioParams = parameters.audioParams;

    if (parameters.localProducerTransport != null && audioParams != null) {
      // Produce audio on the local transport
      parameters.localProducerTransport!.produce(
        track: options.stream.getAudioTracks().first,
        stream: options.stream,
        source: 'mic',
      );

      // Update local audio producer and transport
      if (parameters.updateLocalProducerTransport != null) {
        parameters
            .updateLocalProducerTransport!(parameters.localProducerTransport!);
      }
    }
  } catch (error) {
    if (kDebugMode) {
      print('Error connecting local audio transport: $error');
    }
    rethrow; // Re-throw to allow parent function to handle it
  }
}

/// Sets up and connects the audio stream for media sharing, handling updates to
/// local audio streams and producer transports.
///
/// ### Parameters:
/// - `options` (`ConnectSendTransportAudioOptions`): Options containing:
///   - `stream` (`MediaStream`): The audio stream to be used.
///   - `audioConstraints` (`Map<String, dynamic>`): Constraints for the audio stream, if any.
///   - `targetOption` (`String?`): Specifies the target option for connection ('all' by default).
///   - `parameters` (`ConnectSendTransportAudioParameters`): Contains all necessary parameters and update functions.
///
/// ### Workflow:
/// 1. **Audio Track Handling**:
///    - Checks for any existing audio tracks in the local stream (`localStream` or `localStreamAudio`) and removes them.
/// 2. **Media Constraints**:
///    - Retrieves `audioConstraints` and fetches a new audio stream based on these constraints.
/// 3. **Stream and Track Management**:
///    - Adds the new audio track to the `localStream`, removing any existing tracks.
/// 4. **Transport Production**:
///    - Produces the audio data for transport using `producerTransport`, enabling audio streaming from the local device.
///
/// ### Returns:
/// - A `Future<void>` which completes after setting up the audio stream and connecting the producer transport.
///
/// ### Example Usage:
/// ```dart
/// final audioOptions = ConnectSendTransportAudioOptions(
///   stream: myAudioStream,
///   targetOption: 'all',
///   audioConstraints: myAudioConstraints,
///   parameters: myConnectSendTransportAudioParameters,
/// );
///
/// connectSendTransportAudio(audioOptions).then(() {
///   print("Audio stream successfully set up for sharing.");
/// }).catchError((error) {
///   print("Error setting up audio stream: $error");
/// });
/// ```
///
/// ### Error Handling:
/// - Logs errors to the console if `showAlert` is available in debug mode.

Future<void> connectSendTransportAudio(
    ConnectSendTransportAudioOptions options) async {
  try {
    final audioConstraints = options.audioConstraints;
    MediaStream stream = options.stream;
    final ConnectSendTransportAudioParameters parameters = options.parameters;
    final targetOption = options.targetOption;

    // Destructuring the parameters for easier access
    MediaStream? localStreamAudio =
        parameters.getUpdatedAllParams().localStreamAudio;
    // Check if localStream exists and update accordingly
    MediaStream? localStream = parameters.localStream;

    // Close the existing audio track
    if (localStream != null) {
      var audioTracks = localStream.getAudioTracks().toList();
      for (var track in audioTracks) {
        await localStream.removeTrack(track);
      }
    }

    if (localStreamAudio != null) {
      var audioTracks = localStreamAudio.getAudioTracks().toList();
      for (var track in audioTracks) {
        await localStreamAudio.removeTrack(track);
      }
    }

    stream = await navigator.mediaDevices
        .getUserMedia(audioConstraints ?? {'audio': true});

    parameters.updateLocalStreamAudio(stream);

    // Add video track to localStream
    if (localStream == null) {
      localStream = stream;

      // Update the localStream
      parameters.updateLocalStream(localStream);
    } else {
      // Remove existing video tracks from localStream
      for (var track in localStream.getAudioTracks().toList()) {
        await parameters.localStream!.removeTrack(track);
      }

      // Add the new video track to the localStream
      await localStream.addTrack(stream.getAudioTracks().first);
      parameters.updateLocalStream(localStream);
    }

    // Connect the send transport for audio by producing audio data
    //get the first codec from the first video track
    if (targetOption == 'all' || targetOption == 'remote') {
      parameters.producerTransport!.produce(
        track: stream.getAudioTracks().first,
        stream: stream,
        source: 'mic',
      );
    }

    //Update the audio level
    if (parameters.audioProducer == null) {
      Future.delayed(const Duration(seconds: 1), () {
        updateMicLevel(parameters.getUpdatedAllParams().audioProducer,
            parameters.updateAudioLevel);
      });
    } else {
      updateMicLevel(parameters.audioProducer, parameters.updateAudioLevel);
    }

    // Update the audio producer and producer transport objects
    parameters.updateProducerTransport(parameters.producerTransport!);

    if (targetOption == 'all' || targetOption == 'local') {
      try {
        final optionsLocal = ConnectSendTransportAudioOptions(
          stream: stream,
          parameters: parameters,
          audioConstraints: audioConstraints,
        );
        await connectLocalSendTransportAudio(
          options: optionsLocal,
        );

        if (targetOption == 'local') {
          if (parameters.localAudioProducer == null) {
            Future.delayed(const Duration(seconds: 1), () {
              updateMicLevel(
                  parameters.getUpdatedAllParams().localAudioProducer,
                  parameters.updateAudioLevel);
            });
          } else {
            updateMicLevel(
                parameters.localAudioProducer, parameters.updateAudioLevel);
          }
        }
      } catch (error) {
        if (kDebugMode) {
          print('Error connecting local audio transport: $error');
        }
      }
    }
  } catch (error) {
    // Handle error if showAlert is available
    if (kDebugMode) {
      print('connectSendTransportAudio error: $error');
    }
  }
}
