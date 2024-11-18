import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../types/types.dart'
    show
        ConnectSendTransportVideoParameters,
        Participant,
        ShowAlert,
        CreateSendTransportParameters,
        ReorderStreamsParameters,
        SleepType,
        CreateSendTransportType,
        ConnectSendTransportVideoType,
        ReorderStreamsType,
        ProducerOptionsType,
        CreateSendTransportOptions,
        ConnectSendTransportVideoOptions,
        ReorderStreamsOptions,
        SleepOptions;

abstract class StreamSuccessVideoParameters
    implements
        CreateSendTransportParameters,
        ConnectSendTransportVideoParameters,
        ReorderStreamsParameters {
  // Core properties as abstract getters
  io.Socket? get socket;
  List<Participant> get participants;
  MediaStream? get localStream;
  bool get transportCreated;
  bool get transportCreatedVideo;
  bool get videoAlreadyOn;
  bool get videoAction;
  ProducerOptionsType? get videoParams;
  MediaStream? get localStreamVideo;
  String get defVideoID;
  String get userDefaultVideoInputDevice;
  ProducerOptionsType? get params;
  String get islevel;
  String get member;
  bool get updateMainWindow;
  bool get lockScreen;
  bool get shared;
  bool get shareScreenStarted;
  ProducerOptionsType? get vParams;
  ProducerOptionsType? get hParams;
  bool get allowed;
  String get currentFacingMode;
  Device? get device;
  bool get keepBackground;
  bool get appliedBackground;
  Producer? get videoProducer;

  // Update functions as abstract getters
  void Function(bool created) get updateTransportCreatedVideo;
  void Function(bool videoOn) get updateVideoAlreadyOn;
  void Function(bool videoAction) get updateVideoAction;
  void Function(MediaStream? stream) get updateLocalStream;
  void Function(MediaStream? stream) get updateLocalStreamVideo;
  void Function(String id) get updateDefVideoID;
  void Function(String device) get updateUserDefaultVideoInputDevice;
  void Function(String mode) get updateCurrentFacingMode;
  void Function(bool allowed) get updateAllowed;
  void Function(bool updateMainWindow) get updateUpdateMainWindow;
  void Function(List<Participant> participants) get updateParticipants;
  void Function(ProducerOptionsType params) get updateVideoParams;
  void Function(bool isVisible) get updateIsBackgroundModalVisible;
  void Function(bool autoClick) get updateAutoClickBackground;

  // Media functions as abstract getters
  CreateSendTransportType get createSendTransport;
  ConnectSendTransportVideoType get connectSendTransportVideo;
  ReorderStreamsType get reorderStreams;
  SleepType get sleep;

  ShowAlert? get showAlert;

  // Method to retrieve updated parameters as an abstract getter
  StreamSuccessVideoParameters Function() get getUpdatedAllParams;

  // Allow any other key-value pairs
  // dynamic operator [](String key);
  // void operator []=(String key, dynamic value);
}

class StreamSuccessVideoOptions {
  final MediaStream stream;
  final StreamSuccessVideoParameters parameters;
  final Map<String, dynamic>? videoConstraints;

  StreamSuccessVideoOptions({
    required this.stream,
    required this.parameters,
    this.videoConstraints,
  });
}

typedef StreamSuccessVideoType = Future<void> Function(
    StreamSuccessVideoOptions options);

/// Handles successful video streaming setup by initializing video transports, managing UI states, and updating
/// participant information to reflect the video status.
///
/// ### Function Overview
/// - **Video Transport Management**: Creates or connects the video transport, ensuring the user can stream video successfully.
/// - **UI and Participant Updates**: Updates local and remote participants' view, adjusts display modes, and reorders streams if necessary.
/// - **Device Management**: Configures device settings, codec, and constraints based on the user's device and environment.
///
/// ### Parameters:
/// - `options` (`StreamSuccessVideoOptions`): Contains:
///   - `stream` (`MediaStream`): The new video stream.
///   - `videoConstraints` (`Map<String, dynamic>?`): Optional constraints for video streaming.
///   - `parameters` (`StreamSuccessVideoParameters`): Configuration for setting up video streaming, including:
///     - `socket`: (`io.Socket`): Socket instance for server communication.
///     - `participants`: (`List<Participant>`): List of participants to update the video state.
///     - `transportCreated`, `transportCreatedVideo`: (`bool`): Flags indicating if the transports have been created.
///     - `localStreamVideo`: (`MediaStream?`): Local stream used for video streaming.
///     - `videoParams`: (`ProducerOptionsType`): Options for the video producer, including encoding and codec settings.
///     - `showAlert`: (`ShowAlert?`): Optional function to display alerts to the user.
///
/// ### Steps:
/// 1. **Stream Initialization**:
///    - Sets `localStreamVideo` to the provided `stream` and updates the main `localStream` to include the video track.
///    - Retrieves video track settings, such as device ID and facing mode, and updates state accordingly.
///
/// 2. **Transport Management**:
///    - Checks if a video transport exists; if not, creates a new transport. Otherwise, connects the existing transport with the stream.
///    - Removes VP9 codec for optimal compatibility, supporting only VP8 and H264.
///
/// 3. **Participant and UI Updates**:
///    - Updates participant list to mark the current participant's video as "on."
///    - Modifies `videoAction` and `videoAlreadyOn` states to reflect successful video streaming.
///    - Adjusts the display for the main window if the user is a host.
///
/// 4. **Error Handling**:
///    - Displays an alert if any issues arise during setup, such as missing camera access, and logs errors for debugging.
///
/// ### Example Usage:
/// ```dart
/// final parameters = StreamSuccessVideoParameters(
///   socket: io.Socket(),
///   participants: [],
///   transportCreated: false,
///   videoAlreadyOn: false,
///   videoAction: false,
///   localStreamVideo: null,
///   videoParams: ProducerOptionsType(),
///   // Additional parameters and functions for setup...
/// );
///
/// await streamSuccessVideo(
///   StreamSuccessVideoOptions(
///     stream: videoStream,
///     videoConstraints: videoConstraints,
///     parameters: parameters,
///   ),
/// );
/// ```
///
/// ### Error Handling:
/// - Logs any errors encountered during the setup process for debugging.
/// - Displays an alert with `showAlert` if provided, detailing issues like camera access failure.
///
/// ### Notes:
/// - This function reorders streams and configures video parameters based on the user's level, device capabilities, and event type.

Future<void> streamSuccessVideo(
  StreamSuccessVideoOptions options,
) async {
  final MediaStream stream = options.stream;
  final StreamSuccessVideoParameters parameters = options.parameters;

  try {
    // Destructure parameters
    io.Socket? socket = parameters.socket;
    List<Participant> participants = parameters.participants;
    MediaStream? localStream = parameters.localStream;
    bool transportCreated = parameters.transportCreated;
    bool transportCreatedVideo = parameters.transportCreatedVideo;
    bool videoAlreadyOn = parameters.videoAlreadyOn;
    bool videoAction = parameters.videoAction;
    ProducerOptionsType? videoParams = parameters.videoParams;
    MediaStream? localStreamVideo = parameters.localStreamVideo;
    String defVideoID = parameters.defVideoID;
    String userDefaultVideoInputDevice = parameters.userDefaultVideoInputDevice;
    ProducerOptionsType? params = parameters.params;
    String islevel = parameters.islevel;
    String member = parameters.member;
    bool updateMainWindow = parameters.updateMainWindow;
    bool lockScreen = parameters.lockScreen;
    bool shared = parameters.shared;
    bool shareScreenStarted = parameters.shareScreenStarted;
    ProducerOptionsType? vParams = parameters.vParams;
    ProducerOptionsType? hParams = parameters.hParams;
    bool allowed = parameters.allowed;
    String currentFacingMode = parameters.currentFacingMode;
    Device? device = parameters.device;

    // Update functions
    void Function(bool created) updateTransportCreatedVideo =
        parameters.updateTransportCreatedVideo;
    void Function(bool videoOn) updateVideoAlreadyOn =
        parameters.updateVideoAlreadyOn;
    void Function(bool videoAction) updateVideoAction =
        parameters.updateVideoAction;
    void Function(MediaStream? stream) updateLocalStream =
        parameters.updateLocalStream;
    void Function(MediaStream? stream) updateLocalStreamVideo =
        parameters.updateLocalStreamVideo;
    void Function(String id) updateDefVideoID = parameters.updateDefVideoID;
    void Function(String device) updateUserDefaultVideoInputDevice =
        parameters.updateUserDefaultVideoInputDevice;
    void Function(String mode) updateCurrentFacingMode =
        parameters.updateCurrentFacingMode;
    void Function(bool allowed) updateAllowed = parameters.updateAllowed;
    void Function(bool updateMainWindow) updateUpdateMainWindow =
        parameters.updateUpdateMainWindow;
    void Function(List<Participant> participants) updateParticipants =
        parameters.updateParticipants;
    void Function(ProducerOptionsType params) updateVideoParams =
        parameters.updateVideoParams;

    // Media functions
    CreateSendTransportType createSendTransport =
        parameters.createSendTransport;
    ConnectSendTransportVideoType connectSendTransportVideo =
        parameters.connectSendTransportVideo;
    ReorderStreamsType reorderStreams = parameters.reorderStreams;
    SleepType sleep = parameters.sleep;

    ShowAlert? showAlert = parameters.showAlert;

    // Update the local video stream
    localStreamVideo = stream;
    updateLocalStreamVideo(localStreamVideo);

    if (localStream == null) {
      localStream = stream;
      updateLocalStream(localStream);
    } else {
      // Remove existing video tracks from localStream
      for (MediaStreamTrack track
          in List<MediaStreamTrack>.from(localStream.getVideoTracks())) {
        try {
          await localStream.removeTrack(track);
        } catch (_) {}
      }

      // Add the new video track to the localStream
      localStream.addTrack(stream.getVideoTracks().first);
      updateLocalStream(localStream);
    }

    // Get video track settings
    MediaStreamTrack videoTracked = localStream.getVideoTracks().first;
    try {
      defVideoID = videoTracked.getSettings()['deviceId'] ?? '';
      userDefaultVideoInputDevice = defVideoID;
      currentFacingMode = videoTracked.getSettings()['facingMode'] ?? 'user';

      if (defVideoID.isNotEmpty) {
        updateDefVideoID(defVideoID);
      }
      if (userDefaultVideoInputDevice.isNotEmpty) {
        updateUserDefaultVideoInputDevice(userDefaultVideoInputDevice);
      }
      if (currentFacingMode.isNotEmpty) {
        updateCurrentFacingMode(currentFacingMode);
      }
    } catch (_) {}

    // Update allowed state
    allowed = true;
    updateAllowed(allowed);

    try {
      // Apply video constraints
      if (islevel == '2') {
        if (!shared || !shareScreenStarted) {
          params = hParams;
        } else {
          params = vParams;
        }
      } else {
        params = vParams;
      }

      // Remove VP9 codec from the video codecs; support only VP8 and H264
      RtpCodecCapability? codec = device?.rtpCapabilities.codecs.firstWhere(
        (codec) =>
            codec.mimeType.toLowerCase() != 'video/vp9' &&
            codec.kind == RTCRtpMediaType.RTCRtpMediaTypeVideo,
        orElse: () => RtpCodecCapability(
          mimeType: 'video/vp8',
          kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
          clockRate: 90000,
          parameters: {},
        ),
      );

      // Create videoParams
      params!.codec = codec;
      params.stream = stream;
      videoParams = params;
      updateVideoParams(videoParams);

      // Create or connect transport
      if (!transportCreated) {
        parameters.updateVideoParams(videoParams);
        final optionsCreate = CreateSendTransportOptions(
          option: 'video',
          parameters: parameters,
          videoConstraints: options.videoConstraints,
        );
        await createSendTransport(
          optionsCreate,
        );
      } else {
        // Close existing producer if any
        if (parameters.videoProducer != null) {
          parameters.videoProducer!.close();
          await sleep(SleepOptions(
            ms: 1000,
          ));
        }
        parameters.updateVideoParams(videoParams);
        final optionsConnect = ConnectSendTransportVideoOptions(
          videoParams: videoParams,
          videoConstraints: options.videoConstraints,
          parameters: parameters,
        );
        await connectSendTransportVideo(
          optionsConnect,
        );
      }
    } catch (error) {
      showAlert!(
        message: 'Error sharing video: make sure you have a camera connected',
        type: 'danger',
        duration: 3000,
      );
      if (kDebugMode) {
        print("Error in video streaming setup: $error");
      }
    }

    // Update videoAlreadyOn state
    videoAlreadyOn = true;
    updateVideoAlreadyOn(videoAlreadyOn);

    // Update video action state
    if (videoAction == true) {
      videoAction = false;
      updateVideoAction(videoAction);
    }

    // Update display screen if host
    if (islevel == '2') {
      updateMainWindow = true;
      updateUpdateMainWindow(updateMainWindow);
    }

    // Update participants array to reflect the change
    for (var participant in participants) {
      if (participant['socketId'] == socket!.id && participant.name == member) {
        participant.videoOn = true;
      }
    }
    updateParticipants(participants);

    // Update transport created state
    transportCreatedVideo = true;
    updateTransportCreatedVideo(transportCreatedVideo);

    // Reupdate the screen display
    if (lockScreen) {
      parameters.updateVideoAlreadyOn(videoAlreadyOn);
      final optionsReorder = ReorderStreamsOptions(
        add: true,
        screenChanged: true,
        parameters: parameters,
      );
      await reorderStreams(
        optionsReorder,
      );
      if (!kIsWeb) {
        await Future.delayed(const Duration(milliseconds: 1500));
        await reorderStreams(
          optionsReorder,
        );
      }
    } else {
      parameters.updateVideoAlreadyOn(videoAlreadyOn);
      final optionsReorder = ReorderStreamsOptions(
        add: false,
        screenChanged: true,
        parameters: parameters,
      );
      await reorderStreams(
        optionsReorder,
      );
      if (!kIsWeb) {
        await Future.delayed(const Duration(milliseconds: 1500));
        await reorderStreams(
          optionsReorder,
        );
      }
    }
  } catch (error) {
    if (kDebugMode) {
      print('MediaSFU - streamSuccessVideo error: $error');
    }
    // Optionally retshrow or handle the error further
    // throw error;
  }
}
