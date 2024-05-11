// ignore_for_file: empty_catches

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'dart:async';

/// This function stops sharing the screen and performs various updates and actions based on the provided parameters.
///
/// The [parameters] map contains the following keys:
/// - 'shared': A boolean value indicating whether the screen is currently being shared. Defaults to `false`.
/// - 'shareScreenStarted': A boolean value indicating whether the screen sharing has started. Defaults to `false`.
/// - 'shareEnded': A boolean value indicating whether the screen sharing has ended. Defaults to `true`.
/// - 'updateMainWindow': A boolean value indicating whether to update the main window. Defaults to `true`.
/// - 'deferReceive': A boolean value indicating whether to defer receiving video streams. Defaults to `false`.
/// - 'hostLabel': A string representing the host label. Defaults to an empty string.
/// - 'lockScreen': A boolean value indicating whether the screen is locked. Defaults to `false`.
/// - 'forceFullDisplay': A boolean value indicating whether to force full display. Defaults to `false`.
/// - 'firstAll': A boolean value indicating whether it's the first time for all participants. Defaults to `false`.
/// - 'firstRound': A boolean value indicating whether it's the first round of sharing. Defaults to `false`.
/// - 'localStreamScreen': A [MediaStream] object representing the local screen stream.
/// - 'eventType': A string representing the event type.
/// - 'prevForceFullDisplay': A boolean value indicating the previous force full display value.
/// - 'updateShared': A callback function to update the shared value.
/// - 'updateShareScreenStarted': A callback function to update the shareScreenStarted value.
/// - 'updateShareEnded': A callback function to update the shareEnded value.
/// - 'updateUpdateMainWindow': A callback function to update the updateMainWindow value.
/// - 'updateDeferReceive': A callback function to update the deferReceive value.
/// - 'updateLockScreen': A callback function to update the lockScreen value.
/// - 'updateForceFullDisplay': A callback function to update the forceFullDisplay value.
/// - 'updateFirstAll': A callback function to update the firstAll value.
/// - 'updateFirstRound': A callback function to update the firstRound value.
/// - 'updateLocalStreamScreen': A callback function to update the localStreamScreen value.
/// - 'updateMainHeightWidth': A callback function to update the mainHeightWidth value.
/// - 'disconnectSendTransportScreen': A function to disconnect the send transport for screen sharing.
/// - 'prepopulateUserMedia': A function to prepopulate user media.
/// - 'reorderStreams': A function to reorder streams.
/// - 'getVideos': A function to get videos.
///
/// This function performs the following actions:
/// - Updates the shared, shareScreenStarted, shareEnded, and updateMainWindow values based on the provided parameters.
/// - If deferReceive is true, sets deferReceive to false, updates the deferReceive value, and calls the getVideos function.
/// - Stops all tracks in the localStreamScreen and updates the localStreamScreen value.
/// - Disconnects the send transport for screen sharing.
/// - If the eventType is 'conference', updates the mainHeightWidth value to 0.
/// - Prepopulates user media with the hostLabel and the provided parameters.
/// - Reorders the streams by removing the screen stream and updating the screenChanged value.
/// - Updates the lockScreen, forceFullDisplay, firstAll, and firstRound values based on the provided parameters.
///
/// Throws an error if any of the above actions fail.

typedef OnScreenChanges = Future<void> Function(
    {bool changed, required Map<String, dynamic> parameters});
typedef StopShareScreen = Future<void> Function(
    {required Map<String, dynamic> parameters});
typedef DisconnectSendTransportVideo = Future<void> Function(
    {required Map<String, dynamic> parameters});
typedef DisconnectSendTransportAudio = Future<void> Function(
    {required Map<String, dynamic> parameters});
typedef DisconnectSendTransportScreen = Future<void> Function(
    {required Map<String, dynamic> parameters});

typedef PrepopulateUserMedia = List<dynamic> Function({
  required String name,
  required Map<String, dynamic> parameters,
});

typedef ReorderStreams = Future<void> Function({
  bool add,
  bool screenChanged,
  required Map<String, dynamic> parameters,
});

typedef GetVideos = Future<void> Function({
  required Map<String, dynamic> parameters,
});

typedef UpdateMainWindowFunction = void Function(bool);
typedef UpdateActiveNamesFunction = void Function(List<String>);
typedef UpdateAllAudioStreamsFunction = void Function(List<dynamic>);
typedef UpdateAllVideoStreamsFunction = void Function(List<dynamic>);
typedef UpdateSharedFunction = void Function(bool);
typedef UpdateShareScreenStartedFunction = void Function(bool);
typedef UpdateUpdateMainWindowFunction = void Function(bool);
typedef UpdateNewLimitedStreamsFunction = void Function(List<dynamic>);
typedef UpdateDeferReceiveFunction = void Function(bool);
typedef UpdateHostLabelFunction = void Function(String);
typedef UpdateLockScreenFunction = void Function(bool);
typedef UpdateForceFullDisplayFunction = void Function(bool);
typedef UpdateFirstAllFunction = void Function(bool);
typedef UpdateFirstRoundFunction = void Function(bool);
typedef UpdateLocalStreamScreenFunction = void Function(MediaStream);
typedef UpdateMainHeightWidthFunction = void Function(int);
typedef UpdateShareEndedFunction = void Function(bool);
typedef UpdateGotAllVidsFunction = void Function(bool);
typedef UpdateEventTypeFunction = void Function(String);
typedef UpdateShared = void Function(bool);
typedef UpdateShareScreenStarted = void Function(bool);
typedef UpdateShareEnded = void Function(bool);

Future<void> stopShareScreen({required Map<String, dynamic> parameters}) async {
  // Destructure parameters
  // Access values from the parameters map directly

  bool shared = parameters['shared'] ?? false;
  bool shareScreenStarted = parameters['shareScreenStarted'] ?? false;
  bool shareEnded = parameters['shareEnded'] ?? true;
  bool updateMainWindow = parameters['updateMainWindow'] ?? true;
  bool deferReceive = parameters['deferReceive'] ?? false;
  String hostLabel = parameters['hostLabel'] ?? '';
  bool lockScreen = parameters['lockScreen'] ?? false;
  bool forceFullDisplay = parameters['forceFullDisplay'] ?? false;
  bool firstAll = parameters['firstAll'] ?? false;
  bool firstRound = parameters['firstRound'] ?? false;
  MediaStream? localStreamScreen = parameters['localStreamScreen'];
  String eventType = parameters['eventType'];
  bool prevForceFullDisplay = parameters['prevForceFullDisplay'];
  // Updates for the above
  UpdateShared updateShared = parameters['updateShared'];
  UpdateShareScreenStarted updateShareScreenStarted =
      parameters['updateShareScreenStarted'];
  UpdateShareEnded updateShareEnded = parameters['updateShareEnded'];
  UpdateUpdateMainWindowFunction updateUpdateMainWindow =
      parameters['updateUpdateMainWindow'];
  UpdateDeferReceiveFunction updateDeferReceive =
      parameters['updateDeferReceive'];
  UpdateLockScreenFunction updateLockScreen = parameters['updateLockScreen'];
  UpdateForceFullDisplayFunction updateForceFullDisplay =
      parameters['updateForceFullDisplay'];
  UpdateFirstAllFunction updateFirstAll = parameters['updateFirstAll'];
  UpdateFirstRoundFunction updateFirstRound = parameters['updateFirstRound'];
  UpdateLocalStreamScreenFunction updateLocalStreamScreen =
      parameters['updateLocalStreamScreen'];
  UpdateMainHeightWidthFunction updateMainHeightWidth =
      parameters['updateMainHeightWidth'];

  // Mediasfu functions
  DisconnectSendTransportScreen disconnectSendTransportScreen =
      parameters['disconnectSendTransportScreen'];
  PrepopulateUserMedia prepopulateUserMedia =
      parameters['prepopulateUserMedia'];
  ReorderStreams reorderStreams = parameters['reorderStreams'];
  GetVideos getVideos = parameters['getVideos'];

  shared = false;
  updateShared(shared);
  shareScreenStarted = false;
  updateShareScreenStarted(shareScreenStarted);
  shareEnded = true;
  updateShareEnded(shareEnded);
  updateMainWindow = true;
  updateUpdateMainWindow(updateMainWindow);

  if (deferReceive) {
    deferReceive = false;
    updateDeferReceive(deferReceive);
    await getVideos(parameters: parameters);
  }

  try {
    localStreamScreen!.getTracks().forEach((track) async => await track.stop());
    updateLocalStreamScreen(localStreamScreen);
  } catch (error) {}

  try {
    await disconnectSendTransportScreen(parameters: parameters);
  } catch (error) {}

  if (eventType == 'conference') {
    updateMainHeightWidth(0);
  }

  try {
    prepopulateUserMedia(name: hostLabel, parameters: parameters);
  } catch (error) {}

  try {
    await reorderStreams(
        add: false, screenChanged: true, parameters: parameters);
  } catch (error) {}

  lockScreen = false;
  updateLockScreen(lockScreen);
  forceFullDisplay = prevForceFullDisplay;
  updateForceFullDisplay(forceFullDisplay);
  firstAll = false;
  updateFirstAll(firstAll);
  firstRound = false;
  updateFirstRound(firstRound);
}
