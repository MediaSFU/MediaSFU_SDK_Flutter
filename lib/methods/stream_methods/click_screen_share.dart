import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Handles the logic for initiating screen sharing in a Flutter application.
///
/// The [clickScreenShare] function takes a map of parameters as input and performs the following tasks:
/// - Extracts the required parameters from the map.
/// - Checks if the room is audio-only and displays an alert if camera is turned on.
/// - Checks if the room is a demo room and displays an alert if screen sharing is attempted.
/// - Toggles screen sharing based on the current status.
/// - Checks if screen sharing is restricted by the host and displays an alert if access is denied.
/// - Checks the permission for screen sharing and handles different responses accordingly.
/// - Sends a request to the host for screen sharing approval.
/// - Handles error cases and prints the error message in debug mode.
///
/// The [parameters] map should contain the following keys:
/// - 'showAlert': A function that displays an alert message.
/// - 'roomName': The name of the room.
/// - 'member': The name of the member initiating screen sharing.
/// - 'socket': The socket for communication.
/// - 'islevel': The level of the user.
/// - 'youAreCoHost': A boolean indicating if the user is a co-host.
/// - 'adminRestrictSetting': A boolean indicating if screen sharing is restricted by the host.
/// - 'audioSetting': The audio setting for the room.
/// - 'videoSetting': The video setting for the room.
/// - 'screenshareSetting': The screen sharing setting for the room.
/// - 'chatSetting': The chat setting for the room.
/// - 'screenAction': A boolean indicating if screen sharing action is performed.
/// - 'screenAlreadyOn': A boolean indicating if screen sharing is already on.
/// - 'screenRequestState': The state of the screen sharing request.
/// - 'screenRequestTime': The time of the screen sharing request.
/// - 'audioOnlyRoom': A boolean indicating if the room is audio-only.
/// - 'requestIntervalSeconds': The interval between screen sharing requests.
/// - 'transportCreated': A boolean indicating if the transport is created.
/// - 'updateScreenRequestState': A function to update the screen sharing request state.
/// - 'updateScreenAlreadyOn': A function to update the screen sharing already on state.
/// - 'checkPermission': A function to check the permission for screen sharing.
/// - 'checkScreenShare': A function to check the screen sharing status.
/// - 'stopShareScreen': A function to stop screen sharing.
///
/// Example usage:
/// ```dart
/// clickScreenShare(parameters: {
///   'showAlert': showAlertFunction,
///   'roomName': 'room123',
///   'member': 'John Doe',
///   'socket': socket,
///   'islevel': '1',
///   'youAreCoHost': false,
///   'adminRestrictSetting': false,
///   'audioSetting': 'allow',
///   'videoSetting': 'allow',
///   'screenshareSetting': 'allow',
///   'chatSetting': 'allow',
///   'screenAction': false,
///   'screenAlreadyOn': false,
///   'screenRequestState': '',
///   'screenRequestTime': 0,
///   'audioOnlyRoom': false,
///   'requestIntervalSeconds': 0,
///   'transportCreated': false,
///   'updateScreenRequestState': updateScreenRequestStateFunction,
///   'updateScreenAlreadyOn': updateScreenAlreadyOnFunction,
///   'checkPermission': checkPermissionFunction,
///   'checkScreenShare': checkScreenShareFunction,
///   'stopShareScreen': stopShareScreenFunction,
/// });
/// ```
///
/// Note: The actual implementation of the functions and their parameters may vary based on the application's requirements.

typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

typedef UpdateScreenRequestState = void Function(String state);
typedef UpdateScreenAlreadyOn = void Function(bool isOn);
typedef UpdateScreenAction = void Function(bool action);
typedef UpdateScreenRequestTime = void Function(int time);

typedef CheckPermission = Future<int> Function({
  required String permissionType,
  required Map<String, dynamic> parameters,
});
typedef CheckScreenShare = void Function(
    {required Map<String, dynamic> parameters});
typedef StopShareScreen = Future<void> Function(
    {required Map<String, dynamic> parameters});

void clickScreenShare({required Map<String, dynamic> parameters}) async {
  try {
    // Extracting parameters from the map
    ShowAlert? showAlert = parameters['showAlert'];
    String roomName = parameters['roomName'] ?? '';
    String member = parameters['member'] ?? '';
    io.Socket socket = parameters['socket'];
    String islevel = parameters['islevel'] ?? '1';
    bool youAreCoHost = parameters['youAreCoHost'] ?? false;
    bool adminRestrictSetting = parameters['adminRestrictSetting'] ?? false;
    String audioSetting = parameters['audioSetting'] ?? 'allow';
    String videoSetting = parameters['videoSetting'] ?? 'allow';
    String screenshareSetting = parameters['screenshareSetting'] ?? 'allow';
    String chatSetting = parameters['chatSetting'] ?? 'allow';
    bool screenAction = parameters['screenAction'] ?? false;
    bool screenAlreadyOn = parameters['screenAlreadyOn'] ?? false;
    String screenRequestState = parameters['screenRequestState'] ?? '';
    int screenRequestTime = parameters['screenRequestTime'] ?? 0;
    bool audioOnlyRoom = parameters['audioOnlyRoom'] ?? false;
    int requestIntervalSeconds = parameters['requestIntervalSeconds'] ?? 0;
    bool transportCreated = parameters['transportCreated'] ?? false;

    UpdateScreenRequestState updateScreenRequestState =
        parameters['updateScreenRequestState'];
    UpdateScreenAlreadyOn updateScreenAlreadyOn =
        parameters['updateScreenAlreadyOn'];

    // mediasfu functions
    CheckPermission checkPermission = parameters['checkPermission'];
    CheckScreenShare checkScreenShare = parameters['checkScreenShare'];
    StopShareScreen stopShareScreen = parameters['stopShareScreen'];

    // Check if the room is audio-only
    if (audioOnlyRoom) {
      if (showAlert != null) {
        showAlert(
          message: 'You cannot turn on your camera in an audio-only event.',
          type: 'danger',
          duration: 3000,
        );
      }
      return;
    }

    // Check if the room is a demo room
    if (roomName.startsWith('d')) {
      if (showAlert != null) {
        showAlert(
          message: 'You cannot start screen share in a demo room.',
          type: 'danger',
          duration: 3000,
        );
      }
      return;
    }

    // Toggle screen sharing based on current status
    if (screenAlreadyOn) {
      screenAlreadyOn = false;
      updateScreenAlreadyOn(screenAlreadyOn);
      await stopShareScreen(parameters: parameters);
    } else {
      // Check if screen sharing is restricted by the host
      if (adminRestrictSetting) {
        if (showAlert != null) {
          showAlert(
            message: 'You cannot start screen share. Access denied by host.',
            type: 'danger',
            duration: 3000,
          );
        }
        return;
      }

      int response = 2;
      // Check and turn on screen sharing
      if (!screenAction && islevel != '2' && !youAreCoHost) {
        response = await checkPermission(
            permissionType: 'screenshareSetting',
            parameters: {
              'audioSetting': audioSetting,
              'videoSetting': videoSetting,
              'screenshareSetting': screenshareSetting,
              'chatSetting': chatSetting,
            });
      } else {
        response = 0;
      }

      // Handle different responses
      switch (response) {
        case 0:
          // Allow screen sharing
          if (!transportCreated) {
            if (showAlert != null) {
              showAlert(
                message:
                    'Please start your media (audio/video) before starting screen share.',
                type: 'danger',
                duration: 3000,
              );
            }
            return;
          }
          checkScreenShare(parameters: parameters);
          break;
        case 1:
          // Approval required
          // Check if a request is already pending
          if (screenRequestState == 'pending') {
            if (showAlert != null) {
              showAlert(
                message:
                    'A request is already pending. Please wait for the host to respond.',
                type: 'danger',
                duration: 3000,
              );
            }
            return;
          }

          // Check if rejected and current time is less than requestIntervalSeconds
          if (screenRequestState == 'rejected' &&
              DateTime.now().millisecondsSinceEpoch - screenRequestTime <
                  requestIntervalSeconds) {
            if (showAlert != null) {
              showAlert(
                message: 'You cannot send another request at this time.',
                type: 'danger',
                duration: 3000,
              );
            }
            return;
          }

          // Send request to host
          if (showAlert != null) {
            showAlert(
              message: 'Your request has been sent to the host.',
              type: 'success',
              duration: 3000,
            );
          }
          screenRequestState = 'pending';
          updateScreenRequestState(screenRequestState);

          // Create a request and add it to the request list, then send it to the host
          Map<String, dynamic> userRequest = {
            'id': socket.id,
            'name': member,
            'icon': 'fa-desktop'
          };
          socket.emit('participantRequest',
              {'userRequest': userRequest, 'roomName': roomName});
          break;
        case 2:
          // Disallow screen sharing
          if (showAlert != null) {
            showAlert(
              message: 'You are not allowed to start screen share.',
              type: 'danger',
              duration: 3000,
            );
          }
          break;
        default:
      }
    }
  } catch (error) {
    if (kDebugMode) {
      print("Error during requesting screen share: $error");
    }
  }
}
