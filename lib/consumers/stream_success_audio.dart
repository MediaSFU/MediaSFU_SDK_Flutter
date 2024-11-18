import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../types/types.dart'
    show
        Participant,
        ShowAlert,
        CreateSendTransportParameters,
        ConnectSendTransportAudioParameters,
        PrepopulateUserMediaType,
        CreateSendTransportType,
        ConnectSendTransportAudioType,
        ResumeSendTransportAudioType,
        PrepopulateUserMediaOptions,
        CreateSendTransportOptions,
        ConnectSendTransportAudioOptions,
        ResumeSendTransportAudioOptions,
        ProducerOptionsType;

/// StreamSuccessAudioParameters class equivalent to your TypeScript interface
abstract class StreamSuccessAudioParameters
    implements
        ConnectSendTransportAudioParameters,
        CreateSendTransportParameters {
  // Core properties as abstract getters
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

  //  functions as abstract getters
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

  // Mediasfu functions as abstract getters
  CreateSendTransportType get createSendTransport;
  ConnectSendTransportAudioType get connectSendTransportAudio;
  ResumeSendTransportAudioType get resumeSendTransportAudio;
  PrepopulateUserMediaType get prepopulateUserMedia;

  // Method to retrieve updated parameters as an abstract getter
  StreamSuccessAudioParameters Function() get getUpdatedAllParams;

  // Allow any other key-value pairs
  // dynamic operator [](String key);
  // void operator []=(String key, dynamic value);
}

/// StreamSuccessAudioOptions class equivalent to your TypeScript interface
class StreamSuccessAudioOptions {
  final MediaStream stream;
  final StreamSuccessAudioParameters parameters;
  final Map<String, dynamic>? audioConstraints;

  StreamSuccessAudioOptions({
    required this.stream,
    required this.parameters,
    this.audioConstraints,
  });
}

typedef StreamSuccessAudioType = Future<void> Function(
    StreamSuccessAudioOptions options);

/// Manages the setup and successful transition of audio streaming by configuring necessary transports,
/// updating audio settings, and updating UI state as required.
///
/// ### Function Overview
/// - **Audio Stream Update**: Sets up or switches to a new local audio stream, manages the default audio device, and updates local tracks.
/// - **Transport Creation**: Creates or connects to a new audio transport if required, and resumes audio if already connected.
/// - **UI and Participant Management**: Updates UI components, participant mute states, and screen locks based on user roles and permissions.
///
/// ### Parameters:
/// - `options` (`StreamSuccessAudioOptions`): Configuration for the audio streaming setup, containing:
///   - `stream` (`MediaStream`): The new audio stream to be set up.
///   - `parameters` (`StreamSuccessAudioParameters`): Parameters including:
///     - `socket`: (`io.Socket`): Socket instance for server communication.
///     - `participants`: (`List<Participant>`): List of participants in the session.
///     - `localStream`, `localStreamAudio`: (`MediaStream?`): The primary local stream and audio stream.
///     - `transportCreated`, `transportCreatedAudio`: (`bool`): Flags indicating if the transport has been created for audio.
///     - `audioParams`: (`ProducerOptionsType`): Current audio parameters.
///     - `audioAlreadyOn`, `micAction`: (`bool`): Flags to track audio state and mic action.
///     - `defAudioID`, `userDefaultAudioInputDevice`: (`String`): Audio device IDs for the current audio setup.
///     - `showAlert`: (`ShowAlert?`): Optional function to display alerts to the user.
///
/// ### Steps:
/// 1. **Update Local Audio Stream**:
///    - Sets `localStreamAudio` to the new audio stream, updating `localStream` if necessary to include the new audio track.
///    - Retrieves and updates the default audio device ID from the new audio stream.
///
/// 2. **Transport Creation or Connection**:
///    - If the transport has not been created, a new send transport is created for the audio stream.
///    - If the transport is created but not connected, it connects the audio transport with updated parameters.
///    - If the transport is connected, the audio is resumed if paused.
///
/// 3. **UI and Participant List Updates**:
///    - Sets `audioAlreadyOn` to `true`, indicating audio streaming is active.
///    - Updates the `micAction` state if the microphone was previously active.
///    - Updates participant list to unmute the local participant.
///
/// 4. **Main Window Update**:
///    - Adjusts the main display if necessary, prepopulating user media based on user role, level, and lock state.
///
/// ### Example Usage:
/// ```dart
/// final parameters = StreamSuccessAudioParameters(
///   socket: io.Socket(),
///   participants: [Participant(id: '123', name: 'User1')],
///   localStream: null,
///   transportCreated: false,
///   transportCreatedAudio: false,
///   audioAlreadyOn: false,
///   micAction: false,
///   audioParams: ProducerOptionsType(),
///   defAudioID: 'defaultAudioID',
///   userDefaultAudioInputDevice: 'defaultAudioID',
///   showAlert: (message, type, duration) {
///     print("Alert: $message");
///   },
///
/// );
///
/// await streamSuccessAudio(
///  StreamSuccessAudioOptions(
///     stream: newAudioStream,
///     parameters: parameters,
///    audioConstraints: {
///     'audio': true,
///     'video': false,
///      },
///   ),
/// );
/// ```
///
/// ### Error Handling:
/// - Logs any errors encountered during the audio setup process for debugging.
/// - Displays an alert to the user if audio setup fails.

Future<void> streamSuccessAudio(
  StreamSuccessAudioOptions options,
) async {
  final MediaStream stream = options.stream;
  final StreamSuccessAudioParameters parameters = options.parameters;

  try {
    // Destructure parameters
    io.Socket? socket = parameters.socket;
    List<Participant> participants = parameters.participants;
    MediaStream? localStream = parameters.localStream;
    bool transportCreated = parameters.transportCreated;
    bool transportCreatedAudio = parameters.transportCreatedAudio;
    bool audioAlreadyOn = parameters.audioAlreadyOn;
    bool micAction = parameters.micAction;
    ProducerOptionsType? audioParams = parameters.audioParams;
    ProducerOptionsType? aParams = parameters.aParams;
    MediaStream? localStreamAudio = parameters.localStreamAudio;
    String defAudioID = parameters.defAudioID;
    String userDefaultAudioInputDevice = parameters.userDefaultAudioInputDevice;
    String hostLabel = parameters.hostLabel;
    String islevel = parameters.islevel;
    String member = parameters.member;
    bool updateMainWindow = parameters.updateMainWindow;
    bool lockScreen = parameters.lockScreen;
    bool shared = parameters.shared;
    bool videoAlreadyOn = parameters.videoAlreadyOn;

    //  functions
    void Function(List<Participant> participants) updateParticipants =
        parameters.updateParticipants;
    void Function(bool transportCreated) updateTransportCreated =
        parameters.updateTransportCreated;
    void Function(bool transportCreatedAudio) updateTransportCreatedAudio =
        parameters.updateTransportCreatedAudio;
    void Function(bool audioAlreadyOn) updateAudioAlreadyOn =
        parameters.updateAudioAlreadyOn;
    void Function(bool micAction) updateMicAction = parameters.updateMicAction;
    void Function(ProducerOptionsType audioParams) updateAudioParams =
        parameters.updateAudioParams;
    void Function(MediaStream? localStream) updateLocalStream =
        parameters.updateLocalStream;
    void Function(MediaStream? localStreamAudio) updateLocalStreamAudio =
        parameters.updateLocalStreamAudio;
    void Function(String defAudioID) updateDefAudioID =
        parameters.updateDefAudioID;
    void Function(String userDefaultAudioInputDevice)
        updateUserDefaultAudioInputDevice =
        parameters.updateUserDefaultAudioInputDevice;
    void Function(bool updateMainWindow) updateUpdateMainWindow =
        parameters.updateUpdateMainWindow;

    // Mediasfu functions
    CreateSendTransportType createSendTransport =
        parameters.createSendTransport;
    ConnectSendTransportAudioType connectSendTransportAudio =
        parameters.connectSendTransportAudio;
    ResumeSendTransportAudioType resumeSendTransportAudio =
        parameters.resumeSendTransportAudio;
    PrepopulateUserMediaType prepopulateUserMedia =
        parameters.prepopulateUserMedia;

    // Update the local audio stream
    localStreamAudio = stream;
    updateLocalStreamAudio(localStreamAudio);

    if (localStream == null) {
      localStream = localStreamAudio;
    } else {
      // Remove existing audio tracks from localStream
      for (MediaStreamTrack track
          in List<MediaStreamTrack>.from(localStream.getAudioTracks())) {
        await localStream.removeTrack(track);
      }

      // Add the first audio track from localStreamAudio to localStream
      if (localStreamAudio.getAudioTracks().isNotEmpty) {
        localStream.addTrack(localStreamAudio.getAudioTracks().first);
      }

      // Update the local stream
      updateLocalStream(localStream);
    }

    // Get the new default audio device ID from the new audio track
    try {
      MediaStreamTrack audioTracked = localStream.getAudioTracks().first;
      defAudioID = audioTracked.getSettings()['deviceId'] ?? "";
      userDefaultAudioInputDevice = defAudioID;

      updateDefAudioID(defAudioID);
      updateUserDefaultAudioInputDevice(userDefaultAudioInputDevice);
    } catch (_) {}

    // Update audioParams with the new audio track and codec options
    if (audioParams == null && aParams != null) {
      audioParams = aParams;
    }

    audioParams!.track = localStream.getAudioTracks().first;

    updateAudioParams(audioParams);

    // Create or connect transport for audio
    if (!transportCreated) {
      try {
        parameters.updateAudioParams(audioParams);
        final optionsCreate = CreateSendTransportOptions(
          option: 'audio',
          parameters: parameters,
          audioConstraints: options.audioConstraints,
        );
        await createSendTransport(
          optionsCreate,
        );
      } catch (error) {
        if (kDebugMode) {
          print("Error creating transport: $error");
        }
      }
    } else {
      if (!transportCreatedAudio) {
        parameters.updateAudioParams(audioParams);
        final optionsConnect = ConnectSendTransportAudioOptions(
          stream: localStream,
          parameters: parameters,
          audioConstraints: options.audioConstraints,
        );
        await connectSendTransportAudio(
          optionsConnect,
        );
      } else {
        final optionsResume = ResumeSendTransportAudioOptions(
          parameters: parameters,
        );
        await resumeSendTransportAudio(
          options: optionsResume,
        );
      }
    }

    // Update audio already on state
    audioAlreadyOn = true;
    updateAudioAlreadyOn(audioAlreadyOn);

    // Update mic action state
    if (micAction == true) {
      micAction = false;
      updateMicAction(micAction);
    }

    // Update participants list to unmute the current participant
    for (var participant in participants) {
      if (participant['socketId'] == socket!.id && participant.name == member) {
        participant.muted = false;
      }
    }
    updateParticipants(participants);

    // Update transport creation flags
    transportCreated = true;
    transportCreatedAudio = true;
    updateTransportCreated(transportCreated);
    updateTransportCreatedAudio(transportCreatedAudio);

    // Update the UI based on the participant's level and screen lock status
    if (!videoAlreadyOn && islevel == '2') {
      if (!lockScreen && !shared) {
        updateMainWindow = true;
        updateUpdateMainWindow(updateMainWindow);
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
  } catch (error) {
    if (kDebugMode) {
      print('streamSuccessAudio error: $error');
    }

    parameters.showAlert!(
      message: 'Error setting up audio streaming: ${error.toString()}',
      type: 'danger',
      duration: 3000,
    );
  }
}
