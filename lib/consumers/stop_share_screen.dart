import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../types/types.dart'
    show
        EventType,
        DisconnectSendTransportScreenParameters,
        PrepopulateUserMediaParameters,
        ReorderStreamsParameters,
        DisconnectSendTransportScreenType,
        PrepopulateUserMediaType,
        ReorderStreamsType,
        GetVideosType,
        GetVideosOptions,
        PrepopulateUserMediaOptions,
        ReorderStreamsOptions,
        Stream,
        DisconnectSendTransportScreenOptions;

/// Parameters required for stopping screen sharing.
/// Extends multiple parameter interfaces from your TypeScript definitions.
abstract class StopShareScreenParameters
    implements
        DisconnectSendTransportScreenParameters,
        PrepopulateUserMediaParameters,
        ReorderStreamsParameters {
  // Inherited properties from the interfaces will be defined by the implementing class

  // Additional properties as abstract getters
  bool get shared;
  bool get shareScreenStarted;
  bool get shareEnded;
  bool get updateMainWindow;
  bool get deferReceive;
  String get hostLabel;
  bool get lockScreen;
  bool get forceFullDisplay;
  bool get firstAll;
  bool get firstRound;
  MediaStream? get localStreamScreen;
  EventType get eventType;
  bool get prevForceFullDisplay;
  bool get annotateScreenStream;

  // Update functions as abstract getters
  void Function(bool) get updateShared;
  void Function(bool) get updateShareScreenStarted;
  void Function(bool) get updateShareEnded;
  void Function(bool) get updateUpdateMainWindow;
  void Function(bool) get updateDeferReceive;
  void Function(bool) get updateLockScreen;
  void Function(bool) get updateForceFullDisplay;
  void Function(bool) get updateFirstAll;
  void Function(bool) get updateFirstRound;
  void Function(MediaStream?) get updateLocalStreamScreen;
  void Function(double) get updateMainHeightWidth;
  void Function(bool) get updateAnnotateScreenStream;
  void Function(bool) get updateIsScreenboardModalVisible;
  void Function(List<Stream>) get updateAllVideoStreams;
  void Function(List<Stream>) get updateOldAllStreams;

  // Mediasfu functions as abstract getters
  DisconnectSendTransportScreenType get disconnectSendTransportScreen;
  PrepopulateUserMediaType get prepopulateUserMedia;
  ReorderStreamsType get reorderStreams;
  GetVideosType get getVideos;

  // Method to retrieve updated parameters
  StopShareScreenParameters Function() get getUpdatedAllParams;

  // Dynamic key-value support
  // dynamic operator [](String key);
}

/// Options for the stopShareScreen function.
class StopShareScreenOptions {
  StopShareScreenParameters parameters;

  StopShareScreenOptions({required this.parameters});
}

/// Function type definition for stopping screen sharing.
typedef StopShareScreenType = Future<void> Function(
    StopShareScreenOptions options);

/// Stops the screen sharing process and updates various states and UI elements accordingly.
///
/// This function is designed to stop the screen sharing session and reset related states. It performs
/// several key actions:
/// 1. Resets screen sharing states (`shared`, `shareScreenStarted`, `shareEnded`) and updates main UI flags.
/// 2. Stops the local screen stream and disconnects the transport for screen sharing.
/// 3. Manages screen annotation states by toggling the annotation overlay as needed.
/// 4. Prepopulates user media and triggers a reordering of video streams if layout changes are necessary.
///
/// ### Parameters:
/// - `options` (`StopShareScreenOptions`): Configuration options that include:
///   - `parameters`: (`StopShareScreenParameters`) - This includes necessary configurations and functions:
///     - `shared` (bool): Whether screen sharing is active.
///     - `shareScreenStarted` (bool): Indicates if screen sharing has started.
///     - `shareEnded` (bool): Marks the end of screen sharing.
///     - `updateMainWindow` (bool): Controls UI main window updates.
///     - `deferReceive` (bool): Delays receiving streams if needed.
///     - `hostLabel` (String): Host label for UI updates.
///     - `lockScreen` (bool): Locks screen if true.
///     - `forceFullDisplay` (bool): Enforces full display settings.
///     - `firstAll` (bool): Indicates if this is the first display round.
///     - `firstRound` (bool): Tracks the first round of screen sharing.
///     - `localStreamScreen` (MediaStream?): Local screen media stream.
///     - `eventType` (EventType): The type of event (e.g., conference, chat, etc.).
///     - `prevForceFullDisplay` (bool): Previous full display state.
///     - `annotateScreenStream` (bool): Whether screen annotation is enabled.
///
/// - **Update Functions**: Various callbacks to update states:
///     - `updateShared`, `updateShareScreenStarted`, `updateShareEnded`, etc.,
///       which update specific flags and settings as the sharing state changes.
///
/// - **MediaSFU Functions**:
///     - `disconnectSendTransportScreen` (DisconnectSendTransportScreenType): Disconnects the transport.
///     - `prepopulateUserMedia` (PrepopulateUserMediaType): Prepopulates user media in the UI.
///     - `reorderStreams` (ReorderStreamsType): Reorders the streams to adapt to new layout changes.
///     - `getVideos` (GetVideosType): Retrieves video streams.
///
/// ### Example Usage:
/// ```dart
/// final parameters = StopShareScreenParameters(
///   shared: true,
///   shareScreenStarted: true,
///   shareEnded: false,
///   updateMainWindow: true,
///   deferReceive: false,
///   hostLabel: "Host",
///   lockScreen: false,
///   forceFullDisplay: false,
///   firstAll: false,
///   firstRound: false,
///   localStreamScreen: localStream,
///   eventType: EventType.conference,
///   prevForceFullDisplay: false,
///   annotateScreenStream: false,
///   updateShared: (value) => print("Shared: $value"),
///   // Additional update functions...
/// );
///
/// final options = StopShareScreenOptions(parameters: parameters);
///
/// await stopShareScreen(options);
/// ```
///
/// ### Error Handling:
/// - Errors encountered during actions like stopping streams, disconnecting transport,
///   or prepopulating media are logged for debugging purposes.

Future<void> stopShareScreen(StopShareScreenOptions options) async {
  // Retrieve updated parameters
  StopShareScreenParameters parameters =
      options.parameters.getUpdatedAllParams();

  // Destructure necessary properties
  bool shared = parameters.shared;
  bool shareScreenStarted = parameters.shareScreenStarted;
  bool shareEnded = parameters.shareEnded;
  bool updateMainWindow = parameters.updateMainWindow;
  bool deferReceive = parameters.deferReceive;
  String hostLabel = parameters.hostLabel;
  bool lockScreen = parameters.lockScreen;
  bool forceFullDisplay = parameters.forceFullDisplay;
  bool firstAll = parameters.firstAll;
  bool firstRound = parameters.firstRound;
  MediaStream? localStreamScreen = parameters.localStreamScreen;
  EventType eventType = parameters.eventType;
  bool prevForceFullDisplay = parameters.prevForceFullDisplay;
  bool annotateScreenStream = parameters.annotateScreenStream;

  // Update functions
  void Function(bool) updateShared = parameters.updateShared;
  void Function(bool) updateShareScreenStarted =
      parameters.updateShareScreenStarted;
  void Function(bool) updateShareEnded = parameters.updateShareEnded;
  void Function(bool) updateUpdateMainWindow =
      parameters.updateUpdateMainWindow;
  void Function(bool) updateDeferReceive = parameters.updateDeferReceive;
  void Function(bool) updateLockScreen = parameters.updateLockScreen;
  void Function(bool) updateForceFullDisplay =
      parameters.updateForceFullDisplay;
  void Function(bool) updateFirstAll = parameters.updateFirstAll;
  void Function(bool) updateFirstRound = parameters.updateFirstRound;
  void Function(MediaStream?) updateLocalStreamScreen =
      parameters.updateLocalStreamScreen;
  void Function(double) updateMainHeightWidth =
      parameters.updateMainHeightWidth;
  void Function(bool) updateAnnotateScreenStream =
      parameters.updateAnnotateScreenStream;
  void Function(bool) updateIsScreenboardModalVisible =
      parameters.updateIsScreenboardModalVisible;

  // mediasfu functions
  DisconnectSendTransportScreenType disconnectSendTransportScreen =
      parameters.disconnectSendTransportScreen;
  PrepopulateUserMediaType prepopulateUserMedia =
      parameters.prepopulateUserMedia;
  ReorderStreamsType reorderStreams = parameters.reorderStreams;
  GetVideosType getVideos = parameters.getVideos;

  // Begin updating states
  shared = false;
  updateShared(shared);
  shareScreenStarted = false;
  updateShareScreenStarted(shareScreenStarted);
  shareEnded = true;
  updateShareEnded(shareEnded);
  updateMainWindow = true;
  updateUpdateMainWindow(updateMainWindow);

  // Handle deferReceive
  if (deferReceive) {
    deferReceive = false;
    updateDeferReceive(deferReceive);
    final optionsGet = GetVideosOptions(
        participants: parameters.participants,
        allVideoStreams: parameters.allVideoStreams,
        oldAllStreams: parameters.oldAllStreams,
        adminVidID: parameters.adminVidID,
        updateAllVideoStreams: parameters.updateAllVideoStreams,
        updateOldAllStreams: parameters.updateOldAllStreams);

    await getVideos(options: optionsGet);
  }

  // Stop all tracks in the local screen stream
  if (localStreamScreen != null) {
    try {
      await Future.wait(localStreamScreen.getTracks().map((track) async {
        await track.stop();
      }));
      updateLocalStreamScreen(null);
    } catch (error) {
      if (kDebugMode) {
        print("Error stopping localStreamScreen tracks: $error");
      }
    }
  }

  // Disconnect send transport screen
  try {
    final optionsDisconnect =
        DisconnectSendTransportScreenOptions(parameters: parameters);
    await disconnectSendTransportScreen(optionsDisconnect);
  } catch (error) {
    if (kDebugMode) {
      print("Error disconnecting send transport screen: $error");
    }
  }

  // Handle screen annotation
  if (annotateScreenStream) {
    annotateScreenStream = false;
    updateAnnotateScreenStream(annotateScreenStream);
    updateIsScreenboardModalVisible(true);
    await Future.delayed(const Duration(milliseconds: 500));
    updateIsScreenboardModalVisible(false);
  }

  // Update mainHeightWidth if event type is conference
  if (eventType == EventType.conference) {
    updateMainHeightWidth(0);
  }

  // Prepopulate user media
  try {
    final optionsPrepopulate =
        PrepopulateUserMediaOptions(name: hostLabel, parameters: parameters);
    prepopulateUserMedia(optionsPrepopulate);
  } catch (error) {
    if (kDebugMode) {
      print("Error in prepopulateUserMedia: $error");
    }
  }

  // Reorder streams
  try {
    final optionsReorder =
        ReorderStreamsOptions(screenChanged: true, parameters: parameters);
    await reorderStreams(
      optionsReorder,
    );
  } catch (error) {
    if (kDebugMode) {
      print("Error in reorderStreams: $error");
    }
  }

  // Reset UI states
  lockScreen = false;
  updateLockScreen(lockScreen);
  forceFullDisplay = prevForceFullDisplay;
  updateForceFullDisplay(forceFullDisplay);
  firstAll = false;
  updateFirstAll(firstAll);
  firstRound = false;
  updateFirstRound(firstRound);
}
