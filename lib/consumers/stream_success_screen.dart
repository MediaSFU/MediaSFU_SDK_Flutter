// ignore_for_file: unused_local_variable

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../types/types.dart'
    show
        ShowAlert,
        EventType,
        SleepType,
        CreateSendTransportType,
        ConnectSendTransportScreenType,
        DisconnectSendTransportScreenType,
        StopShareScreenType,
        ReorderStreamsType,
        PrepopulateUserMediaType,
        RePortType,
        CreateSendTransportParameters,
        ConnectSendTransportScreenParameters,
        DisconnectSendTransportScreenParameters,
        StopShareScreenParameters,
        ReorderStreamsParameters,
        PrepopulateUserMediaParameters,
        CreateSendTransportOptions,
        ConnectSendTransportScreenOptions,
        DisconnectSendTransportScreenOptions,
        StopShareScreenOptions,
        ReorderStreamsOptions,
        PrepopulateUserMediaOptions,
        RePortOptions,
        SleepOptions;

abstract class StreamSuccessScreenParameters
    implements
        CreateSendTransportParameters,
        ConnectSendTransportScreenParameters,
        DisconnectSendTransportScreenParameters,
        StopShareScreenParameters,
        ReorderStreamsParameters,
        PrepopulateUserMediaParameters {
  // Core properties as abstract getters
  io.Socket? get socket;
  bool get transportCreated;
  MediaStream? get localStreamScreen;
  bool get screenAlreadyOn;
  bool get screenAction;
  bool get transportCreatedScreen;
  String get hostLabel;
  EventType get eventType;
  ShowAlert? get showAlert;
  bool get annotateScreenStream;
  bool get shared;

  // Callback functions as abstract getters
  void Function(bool transportCreatedScreen) get updateTransportCreatedScreen;
  void Function(bool screenAlreadyOn) get updateScreenAlreadyOn;
  void Function(bool screenAction) get updateScreenAction;
  void Function(bool transportCreated) get updateTransportCreated;
  void Function(MediaStream? localStreamScreen) get updateLocalStreamScreen;
  void Function(bool shared) get updateShared;
  void Function(bool isScreenboardModalVisible)
      get updateIsScreenboardModalVisible;

  // Mediasfu functions as abstract getters
  SleepType get sleep;
  CreateSendTransportType get createSendTransport;
  ConnectSendTransportScreenType get connectSendTransportScreen;
  DisconnectSendTransportScreenType get disconnectSendTransportScreen;
  StopShareScreenType get stopShareScreen;
  ReorderStreamsType get reorderStreams;
  PrepopulateUserMediaType get prepopulateUserMedia;
  RePortType get rePort;

  // Method to retrieve updated parameters as an abstract getter
  StreamSuccessScreenParameters Function() get getUpdatedAllParams;

  // Allow any other key-value pairs
  // dynamic operator [](String key);
  // void operator []=(String key, dynamic value);
}

class StreamSuccessScreenOptions {
  final MediaStream stream;
  final StreamSuccessScreenParameters parameters;

  StreamSuccessScreenOptions({
    required this.stream,
    required this.parameters,
  });
}

typedef StreamSuccessScreenType = Future<void> Function(
    StreamSuccessScreenOptions options);

/// Handles the successful initiation and management of screen sharing, including setting up necessary transports,
/// managing screen states, and updating the user interface accordingly.
///
/// ### Function Overview
/// - **Screen Sharing Setup**: Establishes screen transport, updates UI elements, and manages screen-sharing events.
/// - **Transport Management**: Creates or connects screen-sharing transport, handles screen disconnect events, and reorders streams.
/// - **UI Updates**: Updates screen-sharing state, reorders display streams based on the event type, and manages screen annotations if needed.
///
/// ### Parameters:
/// - `options` (`StreamSuccessScreenOptions`): Configuration for the screen-sharing setup, containing:
///   - `stream` (`MediaStream`): The new screen-sharing stream.
///   - `parameters` (`StreamSuccessScreenParameters`): Parameters for the screen-sharing setup, including:
///     - `socket`: (`io.Socket`): Socket instance for server communication.
///     - `transportCreated`, `transportCreatedScreen`: (`bool`): Flags indicating if transports have been created for the screen.
///     - `localStreamScreen`: (`MediaStream?`): The primary local screen-sharing stream.
///     - `screenAlreadyOn`, `screenAction`: (`bool`): Flags to track screen-sharing state and action status.
///     - `hostLabel`: (`String`): The identifier for the host user.
///     - `eventType`: (`EventType`): The type of current event (e.g., `conference`, `broadcast`).
///     - `annotateScreenStream`, `shared`: (`bool`): Flags for annotation and shared state.
///     - `showAlert`: (`ShowAlert?`): Optional function to display alerts to the user.
///
/// ### Steps:
/// 1. **Screen Transport Setup**:
///    - Assigns the `localStreamScreen` to the provided `stream`.
///    - Checks if the screen transport has been created; if not, creates a new screen transport.
///    - Emits a `startScreenShare` event to notify the server of the screen-sharing state.
///
/// 2. **UI and Stream Management**:
///    - Updates the `shared` state and prepopulates user media if required.
///    - Adjusts the screen-sharing state and reorders streams based on the event type.
///
/// 3. **Stream End Handling**:
///    - Sets up an `onEnded` event handler for `stream.getVideoTracks().first` to manage automatic or manual screen-sharing end events.
///    - Calls `disconnectSendTransportScreen` and `stopShareScreen` to handle cleanup and stop the screen share.
///
/// 4. **Error Handling**:
///    - Catches any errors during the screen-sharing process and displays an alert if `showAlert` is provided.
///
/// ### Example Usage:
/// ```dart
/// final parameters = StreamSuccessScreenParameters(
///   socket: io.Socket(),
///   transportCreated: false,
///   screenAlreadyOn: false,
///   screenAction: false,
///   localStreamScreen: null,
///   hostLabel: 'HostUser',
///   eventType: EventType.conference,
///   showAlert: (message, type, duration) {
///     print("Alert: $message");
///   },
///   // Additional parameters and functions for setup...
/// );
///
/// await streamSuccessScreen(
///   StreamSuccessScreenOptions(
///     stream: screenStream,
///     parameters: parameters,
///   ),
/// );
/// ```
///
/// ### Error Handling:
/// - Displays an alert if any issues arise during the screen-sharing process.
/// - Logs any errors encountered during the setup process for debugging.
///
/// ### Notes:
/// - This function also handles screen annotation by toggling visibility based on `annotateScreenStream`.
/// - Reorders streams based on `eventType`, managing different layouts for conferences, broadcasts, and other event types.

Future<void> streamSuccessScreen(
  StreamSuccessScreenOptions options,
) async {
  final MediaStream stream = options.stream;
  final StreamSuccessScreenParameters parameters = options.parameters;

  try {
    // Retrieve updated parameters
    StreamSuccessScreenParameters updatedParameters =
        parameters.getUpdatedAllParams();

    // Destructure parameters
    io.Socket? socket = updatedParameters.socket;
    bool transportCreated = updatedParameters.transportCreated;
    MediaStream? localStreamScreen = updatedParameters.localStreamScreen;
    bool screenAlreadyOn = updatedParameters.screenAlreadyOn;
    bool screenAction = updatedParameters.screenAction;
    bool transportCreatedScreen = updatedParameters.transportCreatedScreen;
    String hostLabel = updatedParameters.hostLabel;
    EventType eventType = updatedParameters.eventType;
    ShowAlert? showAlert = updatedParameters.showAlert;
    bool annotateScreenStream = updatedParameters.annotateScreenStream;
    bool shared = updatedParameters.shared;

    // Callback functions
    void Function(bool transportCreatedScreen) updateTransportCreatedScreen =
        updatedParameters.updateTransportCreatedScreen;
    void Function(bool screenAlreadyOn) updateScreenAlreadyOn =
        updatedParameters.updateScreenAlreadyOn;
    void Function(bool screenAction) updateScreenAction =
        updatedParameters.updateScreenAction;
    void Function(bool transportCreated) updateTransportCreated =
        updatedParameters.updateTransportCreated;
    void Function(MediaStream localStreamScreen) updateLocalStreamScreen =
        updatedParameters.updateLocalStreamScreen;
    void Function(bool shared) updateShared = updatedParameters.updateShared;
    void Function(bool isScreenboardModalVisible)
        updateIsScreenboardModalVisible =
        updatedParameters.updateIsScreenboardModalVisible;

    // Mediasfu functions
    SleepType sleep = updatedParameters.sleep;
    CreateSendTransportType createSendTransport =
        updatedParameters.createSendTransport;
    ConnectSendTransportScreenType connectSendTransportScreen =
        updatedParameters.connectSendTransportScreen;
    DisconnectSendTransportScreenType disconnectSendTransportScreen =
        updatedParameters.disconnectSendTransportScreen;
    StopShareScreenType stopShareScreen = updatedParameters.stopShareScreen;
    ReorderStreamsType reorderStreams = updatedParameters.reorderStreams;
    PrepopulateUserMediaType prepopulateUserMedia =
        updatedParameters.prepopulateUserMedia;
    RePortType rePort = updatedParameters.rePort;

    // Share screen on success
    localStreamScreen = stream;
    updateLocalStreamScreen(localStreamScreen);

    try {
      // Create transport if not created else connect transport
      if (!transportCreated) {
        updatedParameters.updateLocalStreamScreen(stream);
        final optionsCreate = CreateSendTransportOptions(
          option: 'screen',
          parameters: updatedParameters,
        );
        await createSendTransport(
          optionsCreate,
        );
      } else {
        updatedParameters.updateLocalStreamScreen(stream);
        final optionsConnect = ConnectSendTransportScreenOptions(
          stream: stream,
          parameters: updatedParameters,
        );
        await connectSendTransportScreen(
          optionsConnect,
        );
      }

      // Alert the socket that you are sharing the screen
      socket!.emit('startScreenShare');
    } catch (error) {
      showAlert?.call(
        message: 'Error sharing screen: $error',
        type: 'danger',
        duration: 3000,
      );
    }

    // Reupdate the screen display
    try {
      updateShared(true);
      updatedParameters.updateShared(true);
      updatedParameters.updateLocalStreamScreen(stream);
      final optionsPrepopulate = PrepopulateUserMediaOptions(
        name: hostLabel,
        parameters: updatedParameters,
      );
      await prepopulateUserMedia(
        optionsPrepopulate,
      );
    } catch (_) {}

    // Update the screen sharing state
    screenAlreadyOn = true;
    updateScreenAlreadyOn(screenAlreadyOn);

    // Reorder streams if required
    try {
      if (eventType == EventType.conference) {
        final optionsReorder = ReorderStreamsOptions(
          add: false,
          screenChanged: true,
          parameters: parameters,
        );
        await reorderStreams(
          optionsReorder,
        );
        updatedParameters.updateLocalStreamScreen(stream);
        updatedParameters.updateShared(true);
        final optionsPrepopulate = PrepopulateUserMediaOptions(
          name: hostLabel,
          parameters: updatedParameters,
        );
        await prepopulateUserMedia(
          optionsPrepopulate,
        );
      } else {
        final optionsReorder = ReorderStreamsOptions(
          parameters: parameters,
        );
        await reorderStreams(
          optionsReorder,
        );
      }
    } catch (error) {
      try {
        final optionsRePort = RePortOptions(
          parameters: updatedParameters,
        );
        await rePort(
          optionsRePort,
        );
      } catch (rePortError) {
        if (kDebugMode) {
          print('Error reinitializing ports: $rePortError');
        }
      }
    }

    // Handle screen share end
    stream.getVideoTracks().first.onEnded = () async {
      // Supports both manual and automatic screen share end
      final optionsDisconnect = DisconnectSendTransportScreenOptions(
        parameters: updatedParameters,
      );
      final optionsStop = StopShareScreenOptions(
        parameters: updatedParameters,
      );
      await disconnectSendTransportScreen(
        optionsDisconnect,
      );
      await stopShareScreen(
        optionsStop,
      );
    };

    // If user requested to share screen, update the screenAction state
    if (screenAction == true) {
      screenAction = false;
    }
    updateScreenAction(screenAction);

    // Update the transport created state
    transportCreatedScreen = true;
    updateTransportCreatedScreen(transportCreatedScreen);
    updateTransportCreated(
        transportCreatedScreen); // Assuming transportCreated corresponds to transportCreatedScreen

    // Handle screen annotation modal
    try {
      if (annotateScreenStream) {
        // Assuming annotateScreenStream is a flag to show/hide a modal
        annotateScreenStream = false;
        updateIsScreenboardModalVisible(true);
        await sleep(
          SleepOptions(ms: 1000),
        );
        updateIsScreenboardModalVisible(false);
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error handling screen annotation: $error');
      }
    }
  } catch (error) {
    if (kDebugMode) {
      print('streamSuccessScreen error: $error');
    }

    try {
      // Display an alert if an error occurs
      final ShowAlert? showAlert = parameters.showAlert;
      showAlert!(
        message: 'Error sharing screen - check and try again',
        type: 'danger',
        duration: 3000,
      );
    } catch (alertError) {
      if (kDebugMode) {
        print('Error showing alert: $alertError');
      }
    }

    rethrow;
  }
}
