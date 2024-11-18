import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';
import 'package:flutter/foundation.dart';
import '../types/types.dart'
    show
        PrepopulateUserMediaParameters,
        PrepopulateUserMediaType,
        PrepopulateUserMediaOptions;

abstract class ResumeSendTransportAudioParameters
    implements PrepopulateUserMediaParameters {
  // Properties as abstract getters
  Producer? get audioProducer;
  String get islevel;
  String get hostLabel;
  bool get lockScreen;
  bool get shared;
  bool get videoAlreadyOn;

  // Update functions as abstract getters
  void Function(Producer?) get updateAudioProducer;
  void Function(bool) get updateUpdateMainWindow;

  // Mediasfu function as an abstract getter
  PrepopulateUserMediaType get prepopulateUserMedia;

  // Method to retrieve updated parameters
  ResumeSendTransportAudioParameters Function() get getUpdatedAllParams;

  // Dynamic key-value support
  // dynamic operator [](String key);
}

class ResumeSendTransportAudioOptions {
  final ResumeSendTransportAudioParameters parameters;

  ResumeSendTransportAudioOptions({required this.parameters});
}

typedef ResumeSendTransportAudioType = Future<void> Function(
    {required ResumeSendTransportAudioOptions options});

/// Resumes the audio send transport in the application.
///
/// This function handles resuming an audio producer, which enables audio streaming from the user’s device in a meeting or session.
/// It resumes the audio stream, updates the main window state, and potentially initiates video preloading based on user level and
/// screen lock status.
///
/// - If an audio producer is available, it resumes the audio stream.
/// - If the user is a host (indicated by `islevel` being "2"), has not locked their screen, and is not sharing content, it updates the main window
///   and preloads user media.
/// - After processing, it updates the audio producer state to reflect any changes.
///
/// Parameters:
/// - [options]: An instance of `ResumeSendTransportAudioOptions` containing transport parameters, user state, and functions for updating the UI.
///
/// Example:
/// ```dart
/// final options = ResumeSendTransportAudioOptions(
///   parameters: ResumeSendTransportAudioParameters(
///     audioProducer: currentAudioProducer,
///     islevel: '2',
///     hostLabel: 'MainHost',
///     lockScreen: false,
///     shared: false,
///     videoAlreadyOn: false,
///     updateAudioProducer: (producer) => setAudioProducer(producer),
///     updateUpdateMainWindow: (value) => setMainWindowUpdate(value),
///     prepopulateUserMedia: (name, params) => initializeMedia(name, params),
///   ),
/// );
///
/// await resumeSendTransportAudio(options: options);
/// ```

Future<void> resumeSendTransportAudio(
    {required ResumeSendTransportAudioOptions options}) async {
  final parameters = options.parameters;

  final audioProducer = parameters.audioProducer;
  final islevel = parameters.islevel;
  final hostLabel = parameters.hostLabel;
  final lockScreen = parameters.lockScreen;
  final shared = parameters.shared;
  final videoAlreadyOn = parameters.videoAlreadyOn;
  final updateAudioProducer = parameters.updateAudioProducer;
  final updateUpdateMainWindow = parameters.updateUpdateMainWindow;
  final prepopulateUserMedia = parameters.prepopulateUserMedia;

  try {
    // Resume audio producer if available
    audioProducer?.resume();

    if (!videoAlreadyOn && islevel == '2') {
      if (!lockScreen && !shared) {
        updateUpdateMainWindow(true);
        final optionsPrepopulate = PrepopulateUserMediaOptions(
          name: hostLabel,
          parameters: parameters,
        );
        prepopulateUserMedia(optionsPrepopulate);
        updateUpdateMainWindow(false);
      }
    }

    updateAudioProducer(audioProducer);
  } catch (error) {
    if (kDebugMode) {
      print('Error during resuming audio send transport: $error');
    }
  }
}
