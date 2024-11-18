import 'dart:async';
import '../../types/types.dart' show ShowAlert, Request, RequestResponse;

/// Defines options for handling a host's response to a participant request.
class HostRequestResponseOptions {
  final RequestResponse requestResponse;
  final ShowAlert? showAlert;
  final List<Request> requestList;
  final void Function(List<Request>) updateRequestList;
  final void Function(bool) updateMicAction;
  final void Function(bool) updateVideoAction;
  final void Function(bool) updateScreenAction;
  final void Function(bool) updateChatAction;
  final void Function(String) updateAudioRequestState;
  final void Function(String) updateVideoRequestState;
  final void Function(String) updateScreenRequestState;
  final void Function(String) updateChatRequestState;
  final void Function(int?) updateAudioRequestTime;
  final void Function(int?) updateVideoRequestTime;
  final void Function(int?) updateScreenRequestTime;
  final void Function(int?) updateChatRequestTime;
  final int updateRequestIntervalSeconds;

  HostRequestResponseOptions({
    required this.requestResponse,
    this.showAlert,
    required this.requestList,
    required this.updateRequestList,
    required this.updateMicAction,
    required this.updateVideoAction,
    required this.updateScreenAction,
    required this.updateChatAction,
    required this.updateAudioRequestState,
    required this.updateVideoRequestState,
    required this.updateScreenRequestState,
    required this.updateChatRequestState,
    required this.updateAudioRequestTime,
    required this.updateVideoRequestTime,
    required this.updateScreenRequestTime,
    required this.updateChatRequestTime,
    required this.updateRequestIntervalSeconds,
  });
}

typedef HostRequestResponseType = Future<void> Function(
    HostRequestResponseOptions options);

/// Handles the response of a host to a participant's request.
///
/// This function processes the host's response to a participant request for
/// various actions (e.g., microphone, video, screenshare, chat) and updates
/// the corresponding action states, request statuses, and times.
///
/// - [options] The options used to handle the host's response.
///   - `requestResponse`: A map containing details of the request and the host's response.
///     - `type`: The type of the request, such as `fa-microphone`, `fa-video`, `fa-desktop`, or `fa-comments`.
///     - `action`: The response of the host, such as `accepted` or `rejected`.
///   - `showAlert`: A callback function to display an alert message to the user.
///   - `requestList`: The current list of active requests made by participants.
///   - `updateRequestList`: Callback function to update the request list.
///   - `updateMicAction`, `updateVideoAction`, `updateScreenAction`, `updateChatAction`: Functions to update the state of the actions.
///   - `updateAudioRequestState`, `updateVideoRequestState`, `updateScreenRequestState`, `updateChatRequestState`: Functions to update the request states.
///   - `updateAudioRequestTime`, `updateVideoRequestTime`, `updateScreenRequestTime`, `updateChatRequestTime`: Functions to update the time of each request.
///   - `updateRequestIntervalSeconds`: The interval in seconds to delay further requests after a rejection.
///
/// If the request is accepted, it updates the respective action's state to `true`,
/// updates the request state to `'accepted'`, and calls an alert to inform the user.
/// If the request is rejected, it sets the request state to `'rejected'`, displays an alert,
/// and sets a cooldown time for retrying based on the `updateRequestIntervalSeconds`.
///
/// ### Example Usage:
/// ```dart
/// final options = HostRequestResponseOptions(
///   requestResponse: {
///     'id': 'request123',
///     'type': 'fa-microphone',
///     'action': 'accepted',
///   },
///   showAlert: (message, type, duration) {
///     print('$type: $message for $duration ms');
///   },
///   requestList: [
///     {'id': 'request123', 'type': 'fa-microphone', 'name': 'Participant1'},
///   ],
///   updateRequestList: (updatedList) {
///     print('Updated request list: $updatedList');
///   },
///   updateMicAction: (status) {
///     print('Mic action updated: $status');
///   },
///   updateVideoAction: (status) {},
///   updateScreenAction: (status) {},
///   updateChatAction: (status) {},
///   updateAudioRequestState: (state) {
///     print('Audio request state updated: $state');
///   },
///   updateVideoRequestState: (state) {},
///   updateScreenRequestState: (state) {},
///   updateChatRequestState: (state) {},
///   updateAudioRequestTime: (time) {
///     print('Audio request time updated to: $time');
///   },
///   updateVideoRequestTime: (time) {},
///   updateScreenRequestTime: (time) {},
///   updateChatRequestTime: (time) {},
///   updateRequestIntervalSeconds: 240,
/// );
///
/// await hostRequestResponse(options);
/// ```
///
/// In this example, the host accepts a microphone request. The function updates
/// the microphone action state, sets the audio request state to `'accepted'`,
/// and calls `showAlert` to notify the user. If the request had been rejected,
/// it would set the audio request state to `'rejected'`, show an alert, and set
/// a cooldown time before the next request.
///

/// Display names for the request types.
const requestDisplayNames = {
  'fa-microphone': 'Audio',
  'fa-video': 'Video',
  'fa-desktop': 'Screen share',
  'fa-comments': 'Chat',
};

Future<void> hostRequestResponse(HostRequestResponseOptions options) async {
  // Extract parameters
  final showAlert = options.showAlert;
  var requestList = options.requestList;
  final requestResponse = options.requestResponse;
  final requestType = requestResponse.type;
  final isAccepted = requestResponse.action == 'accepted';
  const int alertDuration = 10000;

  // Filter out the request from the list
  requestList =
      requestList.where((request) => request.id != requestResponse.id).toList();
  options.updateRequestList(requestList);

  void showRequestAlert(String action, String message) {
    showAlert?.call(
      message: '$action $message',
      type: isAccepted ? 'success' : 'danger',
      duration: alertDuration,
    );
  }

  final requestTypeMap = {
    'fa-microphone': {
      'action': options.updateMicAction,
      'state': options.updateAudioRequestState,
      'time': options.updateAudioRequestTime,
    },
    'fa-video': {
      'action': options.updateVideoAction,
      'state': options.updateVideoRequestState,
      'time': options.updateVideoRequestTime,
    },
    'fa-desktop': {
      'action': options.updateScreenAction,
      'state': options.updateScreenRequestState,
      'time': options.updateScreenRequestTime,
    },
    'fa-comments': {
      'action': options.updateChatAction,
      'state': options.updateChatRequestState,
      'time': options.updateChatRequestTime,
    }
  };

  if (requestTypeMap.containsKey(requestType)) {
    final requestActions = requestTypeMap[requestType]!;
    final requestName = requestDisplayNames[requestType]!;

    if (isAccepted) {
      showRequestAlert(requestName,
          'request was accepted; click the button again to begin.');
      (requestActions['action'] as void Function(bool))(true);
      (requestActions['state'] as void Function(String))('accepted');
    } else {
      showRequestAlert(requestName, 'request was not accepted');
      (requestActions['state'] as void Function(String))('rejected');

      final nextRequestTime = DateTime.now().add(
        Duration(seconds: options.updateRequestIntervalSeconds),
      );
      (requestActions['time'] as void Function(
          int?))(nextRequestTime.millisecondsSinceEpoch);
    }
  }
}
