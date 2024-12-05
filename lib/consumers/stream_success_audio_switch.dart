import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';
import '../types/types.dart'
    show
        ConnectSendTransportAudioOptions,
        ConnectSendTransportAudioParameters,
        ConnectSendTransportAudioType,
        CreateSendTransportOptions,
        CreateSendTransportParameters,
        CreateSendTransportType,
        PrepopulateUserMediaOptions,
        PrepopulateUserMediaParameters,
        PrepopulateUserMediaType,
        ProducerOptionsType,
        SleepOptions,
        SleepType;

/// Represents the parameters required for StreamSuccessAudioSwitch.
abstract class StreamSuccessAudioSwitchParameters
    implements
        PrepopulateUserMediaParameters,
        CreateSendTransportParameters,
        ConnectSendTransportAudioParameters {
  Producer? get audioProducer;
  io.Socket? get socket;
  // Local Audio Transport and Producer
  Producer? get localAudioProducer;
  io.Socket? get localSocket;
  String get roomName;
  MediaStream? get localStream;
  MediaStream? get localStreamAudio;
  ProducerOptionsType? get audioParams;
  bool get audioPaused;
  bool get audioAlreadyOn;
  bool get transportCreated;
  bool? get localTransportCreated;
  String get defAudioID;
  String get userDefaultAudioInputDevice;
  String get hostLabel;
  bool get updateMainWindow;
  bool get videoAlreadyOn;
  String get islevel;
  bool get lockScreen;
  bool get shared;

  void Function(Producer? audioProducer) get updateAudioProducer;
  void Function(Producer? localAudioProducer)? get updateLocalAudioProducer;
  void Function(MediaStream? localStream) get updateLocalStream;
  void Function(ProducerOptionsType audioParams) get updateAudioParams;
  void Function(String defAudioID) get updateDefAudioID;
  void Function(String userDefaultAudioInputDevice)
      get updateUserDefaultAudioInputDevice;
  void Function(bool updateMainWindow) get updateUpdateMainWindow;

  SleepType get sleep;
  PrepopulateUserMediaType get prepopulateUserMedia;
  CreateSendTransportType get createSendTransport;
  ConnectSendTransportAudioType get connectSendTransportAudio;

  /// Method to retrieve updated parameters
  StreamSuccessAudioSwitchParameters Function() get getUpdatedAllParams;

  /// Dynamic access to additional properties if needed
  // dynamic operator [](String key);

  /// Dynamic update to additional properties if needed
  // void operator []=(String key, dynamic value);
}

/// Represents the options required to perform StreamSuccessAudioSwitch.
class StreamSuccessAudioSwitchOptions {
  final MediaStream stream;
  final Map<String, dynamic>? audioConstraints;
  final StreamSuccessAudioSwitchParameters parameters;

  StreamSuccessAudioSwitchOptions({
    required this.stream,
    required this.parameters,
    this.audioConstraints,
  });
}

/// Type definition for the StreamSuccessAudioSwitch function.
typedef StreamSuccessAudioSwitchType = Future<void> Function(
    StreamSuccessAudioSwitchOptions options);

/// Manages switching to a new audio stream, updating the audio producer, local streams, and UI state as necessary.
///
/// This function handles the transition to a new audio stream by performing several key actions:
/// 1. **Audio Device Check**: Checks if the audio device has changed. If so, it closes the current audio producer,
///    updates the audio device ID, and prepares the new audio stream for transmission.
/// 2. **Local Stream Update**: Updates `localStream` and `localStreamAudio` with the new audio track.
/// 3. **Transport Handling**: Creates a new audio send transport if one does not exist; otherwise, it connects to the
///    existing transport with the updated audio parameters.
/// 4. **UI and Event Handling**: Updates UI elements based on user level, screen lock status, and if video is already on.
///
/// ### Parameters:
/// - `options` (`StreamSuccessAudioSwitchOptions`): Contains the configuration for the audio switch:
///   - `stream` (`MediaStream`): The new audio stream to switch to.
///   - `audioConstraints` (`Map<String, dynamic>?`): Constraints for the audio stream (optional).
///   - `parameters` (`StreamSuccessAudioSwitchParameters`): Parameters including:
///     - `audioProducer` (`Producer?`): The current audio producer.
///     - `socket` (`io.Socket`): Socket connection to emit control events.
///     - `localAudioProducer` and `localSocket` (`Producer?` and `io.Socket?`): Local audio producer and socket.
///     - `roomName` (`String`): The room name for socket events.
///     - `localStream` and `localStreamAudio` (`MediaStream?`): Current local streams for audio and combined audio-video.
///     - `audioParams` (`ProducerOptionsType`): Audio parameters for the producer.
///     - `audioPaused` (`bool`): Whether the audio stream is currently paused.
///     - `audioAlreadyOn` (`bool`): Whether the audio stream is already active.
///     - `transportCreated` (`bool`): Indicates if the send transport is already created.
///     - `localTransportCreated` (`bool?`): Indicates if the local send transport is already created.
///     - `defAudioID`, `userDefaultAudioInputDevice` (`String`): Default audio device IDs.
///     - `hostLabel` (`String`): Label for the host.
///     - `updateMainWindow`, `videoAlreadyOn`, `islevel`, `lockScreen`, `shared` (`bool`): UI control flags.
///
/// - **Callback Functions**:
///   - `updateAudioProducer`, `updateLocalStream`, `updateAudioParams`, `updateDefAudioID`, `updateUserDefaultAudioInputDevice`:
///   `updateUserDefaultAudioInputDevice`, `updateUpdateMainWindow`: Functions to update the state with new values.
///   - `sleep`: Function to pause the process for a specified duration.
///     `updateUserDefaultAudioInputDevice`, `updateUpdateMainWindow`:
///     Callbacks to update specific parameters as the audio transition occurs.
///
/// - **MediaSFU Functions**:
///   - `sleep`: Pauses the process for a specified duration.
///   - `createSendTransport`, `connectSendTransportAudio`: Handles audio transport setup and connection.
///   - `prepopulateUserMedia`: Adds necessary media elements to the UI based on updated audio stream.
///
/// ### Example Usage:
/// ```dart
/// final parameters = StreamSuccessAudioSwitchParameters(
///   audioProducer: null,
///   localAudioProducer: null,
///   socket: io.Socket(),
///   localSocket: io.Socket(),
///   roomName: 'myRoom',
///   localStream: localStream,
///   localStreamAudio: audioStream,
///   audioParams: ProducerOptionsType(track: newAudioTrack),
///   audioPaused: false,
///   audioAlreadyOn: true,
///   transportCreated: false,
///   localTransportCreated: false,
///   defAudioID: 'default-device-id',
///   userDefaultAudioInputDevice: 'default-device-id',
///   hostLabel: 'HostUser',
///   updateMainWindow: true,
///   videoAlreadyOn: false,
///   islevel: '2',
///   lockScreen: false,
///   shared: false,
///   updateAudioProducer: (audioProducer) => print('Updated audio producer'),
///   updateLocalStream: (stream) => print('Updated local stream'),
///   updateAudioParams: (audioParams) => print('Updated audio params'),
///   updateDefAudioID: (id) => print('Updated default audio ID: $id'),
///   updateUserDefaultAudioInputDevice: (deviceId) => print('Updated audio input device'),
///   updateUpdateMainWindow: (update) => print('Updated main window'),
///   sleep: (options) async => await Future.delayed(Duration(milliseconds: options.ms)),
///   prepopulateUserMedia: (name, params) => print('Prepopulating user media'),
///   createSendTransport: (options) => Future.value(),
///   connectSendTransportAudio: (options) => Future.value(),
/// );
///
/// final options = StreamSuccessAudioSwitchOptions(stream: newAudioStream, parameters: parameters);
/// await streamSuccessAudioSwitch(options);
/// ```
///
/// ### Error Handling:
/// - Logs errors encountered during audio stream transitions, transport connection, or device updates.
/// - All exceptions are logged for debugging purposes.

Future<void> streamSuccessAudioSwitch(
    StreamSuccessAudioSwitchOptions options) async {
  try {
    // Retrieve updated parameters
    final parameters = options.parameters.getUpdatedAllParams();
    final stream = options.stream;

    // Destructure parameters using getters
    Producer? audioProducer = parameters.audioProducer;
    Producer? localAudioProducer = parameters.localAudioProducer;
    io.Socket? socket = parameters.socket;
    io.Socket? localSocket = parameters.localSocket;
    String roomName = parameters.roomName;
    MediaStream? localStream = parameters.localStream;
    MediaStream? localStreamAudio = parameters.localStreamAudio;
    ProducerOptionsType? audioParams = parameters.audioParams;
    bool audioPaused = parameters.audioPaused;
    bool audioAlreadyOn = parameters.audioAlreadyOn;
    bool transportCreated = parameters.transportCreated;
    String defAudioID = parameters.defAudioID;
    String userDefaultAudioInputDevice = parameters.userDefaultAudioInputDevice;
    String hostLabel = parameters.hostLabel;
    bool updateMainWindow = parameters.updateMainWindow;
    bool videoAlreadyOn = parameters.videoAlreadyOn;
    String islevel = parameters.islevel;
    bool lockScreen = parameters.lockScreen;
    bool shared = parameters.shared;

    // Callback functions
    final Function(Producer? audioProducer) updateAudioProducer =
        parameters.updateAudioProducer;
    final Function(Producer? localAudioProducer)? updateLocalAudioProducer =
        parameters.updateLocalAudioProducer;
    final Function(MediaStream? localStream) updateLocalStream =
        parameters.updateLocalStream;
    final Function(ProducerOptionsType audioParams) updateAudioParams =
        parameters.updateAudioParams;
    final Function(String defAudioID) updateDefAudioID =
        parameters.updateDefAudioID;
    final Function(String userDefaultAudioInputDevice)
        updateUserDefaultAudioInputDevice =
        parameters.updateUserDefaultAudioInputDevice;
    final Function(bool updateMainWindow) updateUpdateMainWindow =
        parameters.updateUpdateMainWindow;

    // mediasfu functions
    final SleepType sleep = parameters.sleep;
    final CreateSendTransportType createSendTransport =
        parameters.createSendTransport;
    final ConnectSendTransportAudioType connectSendTransportAudio =
        parameters.connectSendTransportAudio;
    final PrepopulateUserMediaType prepopulateUserMedia =
        parameters.prepopulateUserMedia;

    // Get the new default audio device ID
    final MediaStreamTrack? newAudioTrack = stream.getAudioTracks().isNotEmpty
        ? stream.getAudioTracks().first
        : null;
    String? newDefAudioID = newAudioTrack?.getSettings()['deviceId'];

    // Check if the audio device has changed
    if (newDefAudioID != defAudioID) {
      // Close the current audioProducer
      if (audioProducer != null) {
        audioProducer.close();
        updateAudioProducer(null);
      }

      // Emit a pauseProducerMedia event to pause the audio media
      socket!.emit('pauseProducerMedia', {
        'mediaTag': 'audio',
        'roomName': roomName,
        'force': true,
      });

      try {
        if (localSocket != null && localSocket.id != null) {
          if (localAudioProducer != null) {
            localAudioProducer.close();
            if (updateLocalAudioProducer != null) {
              updateLocalAudioProducer(localAudioProducer);
            }
          }
          localSocket.emit('pauseProducerMedia', {
            'mediaTag': 'audio',
            'roomName': roomName,
          });
        }
      } catch (error) {
        if (kDebugMode) {
          print(
              'Error in streamSuccessAudioSwitch localSocket pauseProducerMedia:');
        }
      }

      // Update the localStreamAudio with the new audio tracks
      localStreamAudio = stream;

      // If localStream is null or has no audio tracks, assign the new audio stream
      if (localStream == null || localStream.getAudioTracks().isEmpty) {
        localStream = localStreamAudio;
      } else {
        // Remove all existing audio tracks from localStream and add the new audio track
        for (var track in localStream.getAudioTracks().toList()) {
          localStream.removeTrack(track);
        }
        if (localStreamAudio.getAudioTracks().isNotEmpty) {
          localStream.addTrack(localStreamAudio.getAudioTracks().first);
        }
      }

      // Update localStream
      updateLocalStream(localStream);

      // Get the new default audio device ID from the new audio track
      final MediaStreamTrack? audioTracked =
          localStream.getAudioTracks().isNotEmpty
              ? localStream.getAudioTracks().first
              : null;
      defAudioID = audioTracked?.getSettings()['deviceId'] ?? '';
      updateDefAudioID(defAudioID);

      // Update userDefaultAudioInputDevice
      userDefaultAudioInputDevice = defAudioID;
      updateUserDefaultAudioInputDevice(userDefaultAudioInputDevice);

      // Update audioParams with the new audio track and codec options
      audioParams!.track = stream.getAudioTracks().first;
      audioParams.stream = stream;
      updateAudioParams(audioParams);

      // Sleep for 500 milliseconds
      await sleep(SleepOptions(ms: 500));

      // Create a new send transport if not created, otherwise, connect the existing transport
      if (!transportCreated) {
        try {
          parameters.updateAudioParams(audioParams);
          await createSendTransport(
            CreateSendTransportOptions(
              option: 'audio',
              parameters: parameters,
              audioConstraints: options.audioConstraints,
            ),
          );
        } catch (error) {
          if (kDebugMode) {
            print(
                'Error in streamSuccessAudioSwitch createSendTransport: $error');
          }
        }
      } else {
        try {
          final optionsConnect = ConnectSendTransportAudioOptions(
            stream: localStream,
            audioConstraints: options.audioConstraints,
            parameters: parameters,
          );
          await connectSendTransportAudio(
            optionsConnect,
          );
        } catch (error) {
          if (kDebugMode) {
            print(
                'Error in streamSuccessAudioSwitch connectSendTransportAudio: $error');
          }
        }
      }

      // If audio is paused and not already on, pause the audioProducer and emit a pauseProducerMedia event
      if (audioPaused && !audioAlreadyOn) {
        if (audioProducer != null) {
          audioProducer.pause();
          updateAudioProducer(audioProducer);
        }
        socket.emit('pauseProducerMedia', {
          'mediaTag': 'audio',
          'roomName': roomName,
        });

        try {
          if (localSocket != null && localSocket.id != null) {
            if (localAudioProducer != null) {
              localAudioProducer.pause();
              if (updateLocalAudioProducer != null) {
                updateLocalAudioProducer(localAudioProducer);
              }
            }
            localSocket.emit('pauseProducerMedia', {
              'mediaTag': 'audio',
              'roomName': roomName,
            });
          }
        } catch (error) {
          if (kDebugMode) {
            print(
                'Error in streamSuccessAudioSwitch localSocket pauseProducerMedia:');
          }
        }
      }
    }

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
      print('MediaSFU - Error in streamSuccessAudioSwitch: $error');
    }
    // Optionally, handle errors further (e.g., show alert to the user)
  }
}
