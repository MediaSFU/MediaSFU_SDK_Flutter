import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../types/types.dart'
    show
        CheckPermissionType,
        CheckScreenShareParameters,
        CheckScreenShareType,
        ShowAlert,
        StopShareScreenParameters,
        StopShareScreenType,
        CheckPermissionOptions,
        CheckScreenShareOptions,
        StopShareScreenOptions;

abstract class ClickScreenShareParameters
    implements CheckScreenShareParameters, StopShareScreenParameters {
  // Core properties as abstract getters
  ShowAlert? get showAlert;
  String get roomName;
  String get member;
  io.Socket? get socket;
  String get islevel;
  bool get youAreCoHost;
  bool get adminRestrictSetting;
  String get audioSetting;
  String get videoSetting;
  String get screenshareSetting;
  String get chatSetting;
  bool get screenAction;
  bool get screenAlreadyOn;
  String? get screenRequestState;
  int? get screenRequestTime;
  bool get audioOnlyRoom;
  int get updateRequestIntervalSeconds;
  bool get transportCreated;

  // Update functions as abstract getters
  void Function(String?) get updateScreenRequestState;
  void Function(bool) get updateScreenAlreadyOn;

  // Mediasfu functions as abstract getters
  CheckPermissionType get checkPermission;
  CheckScreenShareType get checkScreenShare;
  StopShareScreenType get stopShareScreen;

  // Method to retrieve updated parameters as an abstract getter
  ClickScreenShareParameters Function() get getUpdatedAllParams;
}

/// Options for handling screen share actions.
class ClickScreenShareOptions {
  final ClickScreenShareParameters parameters;

  ClickScreenShareOptions({required this.parameters});
}

/// Type definition for the clickScreenShare function.
typedef ClickScreenShareType = Future<void> Function(
    ClickScreenShareOptions options);

/// Handles the action for the screen button, including starting and stopping screen sharing.
///
/// This function performs the following actions:
/// - Checks if the room is audio-only or a demo room and shows alerts accordingly.
/// - Toggles screen sharing based on the current status.
/// - Checks for admin restrictions and permissions before starting screen sharing.
/// - Sends requests to the host for screen sharing approval if necessary.
/// - Updates the UI and state based on the action taken.
///
/// Example:
/// ```dart
/// final options = ClickScreenShareOptions(
///   parameters: ClickScreenShareParameters(
///     showAlert: showAlertFunction,
///     roomName: 'room123',
///     member: 'John Doe',
///     socket: socketInstance,
///     islevel: '1',
///     youAreCoHost: false,
///     adminRestrictSetting: false,
///     audioSetting: 'allow',
///     videoSetting: 'allow',
///     screenshareSetting: 'allow',
///     chatSetting: 'allow',
///     screenAction: false,
///     screenAlreadyOn: false,
///     screenRequestState: null,
///     screenRequestTime: DateTime.now().millisecondsSinceEpoch,
///     audioOnlyRoom: false,
///     updateRequestIntervalSeconds: 60,
///     updateScreenRequestState: setScreenRequestState,
///     updateScreenAlreadyOn: setScreenAlreadyOn,
///     checkPermission: checkPermissionFunction,
///     checkScreenShare: checkScreenShareFunction,
///     stopShareScreen: stopShareScreenFunction,
///   ),
/// );
///
/// await clickScreenShare(options);
/// ```

Future<void> clickScreenShare(ClickScreenShareOptions options) async {
  final parameters = options.parameters;

  try {
    // Destructure parameters for easier access
    final ShowAlert? showAlert = parameters.showAlert;
    String roomName = parameters.roomName;
    String member = parameters.member;
    io.Socket? socket = parameters.socket;
    String islevel = parameters.islevel;
    bool youAreCoHost = parameters.youAreCoHost;
    bool adminRestrictSetting = parameters.adminRestrictSetting;
    String audioSetting = parameters.audioSetting;
    String videoSetting = parameters.videoSetting;
    String screenshareSetting = parameters.screenshareSetting;
    String chatSetting = parameters.chatSetting;
    bool screenAction = parameters.screenAction;
    bool screenAlreadyOn = parameters.screenAlreadyOn;
    String? screenRequestState = parameters.screenRequestState;
    int? screenRequestTime = parameters.screenRequestTime;
    bool audioOnlyRoom = parameters.audioOnlyRoom;
    int updateRequestIntervalSeconds = parameters.updateRequestIntervalSeconds;
    void Function(String?) updateScreenRequestState =
        parameters.updateScreenRequestState;
    void Function(bool) updateScreenAlreadyOn =
        parameters.updateScreenAlreadyOn;

    // mediasfu functions
    final CheckPermissionType checkPermission = parameters.checkPermission;
    final CheckScreenShareType checkScreenShare = parameters.checkScreenShare;
    final StopShareScreenType stopShareScreen = parameters.stopShareScreen;

    // Check if the room is audio-only
    if (audioOnlyRoom) {
      showAlert?.call(
        message: "You cannot turn on your camera in an audio-only event.",
        type: "danger",
        duration: 3000,
      );
      return;
    }

    // Check if the room is a demo room
    if (roomName.toLowerCase().startsWith('d')) {
      showAlert?.call(
        message: "You cannot start screen share in a demo room.",
        type: "danger",
        duration: 3000,
      );
      return;
    }

    // Toggle screen sharing based on current status
    if (screenAlreadyOn) {
      screenAlreadyOn = false;
      updateScreenAlreadyOn(screenAlreadyOn);
      final optionsStop = StopShareScreenOptions(
        parameters: parameters,
      );
      await stopShareScreen(optionsStop);
    } else {
      // Check if screen sharing is restricted by the host
      if (adminRestrictSetting) {
        showAlert?.call(
          message: "You cannot start screen share. Access denied by host.",
          type: "danger",
          duration: 3000,
        );
        return;
      }

      int response = 2;
      // Check and turn on screen sharing
      if (!screenAction && islevel != '2' && !youAreCoHost) {
        final optionsCheck = CheckPermissionOptions(
          permissionType: 'screenshareSetting',
          audioSetting: audioSetting,
          videoSetting: videoSetting,
          screenshareSetting: screenshareSetting,
          chatSetting: chatSetting,
        );
        response = await checkPermission(
          optionsCheck,
        );
      } else {
        response = 0;
      }

      // Handle different responses
      switch (response) {
        case 0:
          // Allow screen sharing
          if (!parameters.transportCreated) {
            showAlert?.call(
              message:
                  'Please start your media (audio/video) before starting screen share.',
              type: "danger",
              duration: 3000,
            );
            return;
          }
          final optionsCheck = CheckScreenShareOptions(
            parameters: parameters,
          );
          checkScreenShare(optionsCheck);
          break;
        case 1:
          // Approval required
          // Check if a request is already pending
          if (screenRequestState == 'pending') {
            showAlert?.call(
              message:
                  'A request is already pending. Please wait for the host to respond.',
              type: "danger",
              duration: 3000,
            );
            return;
          }

          // Check if rejected and current time is less than requestIntervalSeconds
          if (screenRequestState == 'rejected' &&
              DateTime.now().millisecondsSinceEpoch - screenRequestTime! <
                  updateRequestIntervalSeconds) {
            showAlert?.call(
              message: 'You cannot send another request at this time.',
              type: "danger",
              duration: 3000,
            );
            return;
          }

          // Send request to host
          showAlert?.call(
            message: 'Your request has been sent to the host.',
            type: "success",
            duration: 3000,
          );
          screenRequestState = 'pending';
          updateScreenRequestState(screenRequestState);

          // Create a request and send it to the host
          Map<String, dynamic> userRequest = {
            'id': socket!.id,
            'name': member,
            'icon': 'fa-desktop',
          };
          socket.emit('participantRequest',
              {'userRequest': userRequest, 'roomName': roomName});
          break;
        case 2:
          // Disallow screen sharing
          showAlert?.call(
            message: 'You are not allowed to start screen share.',
            type: "danger",
            duration: 3000,
          );
          break;
        default:
          break;
      }
    }
  } catch (error) {
    if (kDebugMode) {
      print("Error during screen share action: $error");
    }
  }
}
