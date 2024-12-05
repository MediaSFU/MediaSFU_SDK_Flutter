import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';
import 'package:flutter/foundation.dart';
import '../types/types.dart'
    show
        PrepopulateUserMediaParameters,
        PrepopulateUserMediaType,
        PrepopulateUserMediaOptions;

abstract class ResumeSendTransportAudioParameters
    implements PrepopulateUserMediaParameters {
  // Remote Audio Transport and Producer
  Producer? get audioProducer;

  // Local Audio Transport and Producer
  Producer? get localAudioProducer;

  String get islevel;
  String get hostLabel;
  bool get lockScreen;
  bool get shared;
  bool get videoAlreadyOn;

  // Update Functions
  void Function(Producer? audioProducer) get updateAudioProducer;
  void Function(Producer? localAudioProducer)? get updateLocalAudioProducer;
  void Function(bool updateMainWindow) get updateUpdateMainWindow;

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

/// Resumes the local send transport for audio by resuming the local audio producer and updating the state.
///
/// ### Parameters:
/// - `options` (`ResumeSendTransportAudioOptions`): Contains the parameters required for resuming the local audio transport.
///
/// ### Workflow:
/// 1. **Resume Local Audio Producer**:
///    - If an active local audio producer exists, it is resumed.
///    - The local state is updated to reflect the resumed producer.
///
/// ### Returns:
/// - A `Future<void>` that completes when the local audio transport is successfully resumed.
///
/// ### Error Handling:
/// - Logs errors to the console in debug mode and rethrows them for higher-level handling.
///
/// ### Example Usage:
/// ```dart
/// final options = ResumeSendTransportAudioOptions(
///   parameters: myResumeSendTransportAudioParameters,
/// );
///
/// resumeLocalSendTransportAudio(options)
///   .then(() => print('Local audio send transport resumed successfully'))
///   .catchError((error) => print('Error resuming local audio send transport: $error'));
/// ```
Future<void> resumeLocalSendTransportAudio(
    ResumeSendTransportAudioOptions options) async {
  try {
    final parameters = options.parameters;

    final Producer? localAudioProducer = parameters.localAudioProducer;

    // Resume the local audio producer and update the state
    if (localAudioProducer != null) {
      localAudioProducer.resume();
      parameters.updateLocalAudioProducer?.call(localAudioProducer);
    }
  } catch (error) {
    if (kDebugMode) {
      print('Error resuming local audio send transport: $error');
    }
    rethrow; // Re-throw to propagate the error
  }
}

/// Resumes the send transport for audio and updates the UI and audio producer state accordingly.
///
/// This function supports both a primary and a local audio producer, delegating local handling to a separate function.
///
/// ### Parameters:
/// - `options` (`ResumeSendTransportAudioOptions`): Contains the parameters required for resuming the send transport.
///
/// ### Workflow:
/// 1. **Resume Primary Audio Producer**:
///    - If an active primary audio producer exists, it is resumed.
///    - The primary state is updated to reflect the resumed producer.
/// 2. **Update UI**:
///    - Based on conditions (`videoAlreadyOn`, `islevel`, `lockScreen`, `shared`), updates the main window state.
///    - If no video is active and specific conditions are met, user media is prepopulated using `prepopulateUserMedia`.
/// 3. **Update Audio Producer State**:
///    - Updates the audio producer state to reflect the resumed producer.
/// 4. **Handle Local Audio Transport Resumption**:
///    - Invokes `resumeLocalSendTransportAudio` to handle the local audio transport resumption.
///    - Errors during local resumption are caught and logged without interrupting the main flow.
///
/// ### Returns:
/// - A `Future<void>` that completes when the audio send transport(s) are successfully resumed.
///
/// ### Error Handling:
/// - Catches and logs any errors encountered during the resumption process.
/// - Errors are printed to the console in debug mode to aid troubleshooting.
///
/// ### Example Usage:
/// ```dart
/// final options = ResumeSendTransportAudioOptions(
///   parameters: MyResumeSendTransportAudioParameters(
///     audioProducer: myAudioProducer,
///     localAudioProducer: myLocalAudioProducer,
///     islevel: '2',
///     hostLabel: 'Host123',
///     lockScreen: false,
///     shared: false,
///     videoAlreadyOn: false,
///     updateAudioProducer: (producer) => setAudioProducer(producer),
///     updateLocalAudioProducer: (producer) => setLocalAudioProducer(producer),
///     updateUpdateMainWindow: (state) => setMainWindowState(state),
///     prepopulateUserMedia: prepopulateUserMediaFunction,
///     getUpdatedAllParams: () => updatedParameters,
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

    // Handle local audio transport resumption
    try {
      await resumeLocalSendTransportAudio(options);
    } catch (localError) {
      if (kDebugMode) {
        print('Error resuming local audio send transport: $localError');
      }
      // Optionally, handle the local error (e.g., show a notification)
    }
  } catch (error) {
    if (kDebugMode) {
      print('Error during resuming audio send transport: $error');
    }
  }
}
