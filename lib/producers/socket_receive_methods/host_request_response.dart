typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

/// Handles the response of a host to a request made by a participant.
///
/// The [requestResponse] parameter is the response of the host to the request of the participant.
/// The [parameters] parameter is a map containing various parameters used in the function.
/// The [showAlert] function is used to show an alert to the user.
/// The [requestList] is a list of requests made by participants.
/// The [updateRequestList] function is used to update the request list.
/// The [micAction], [videoAction], [screenAction], and [chatAction] parameters indicate whether the corresponding actions are enabled or not.
/// The [updateMicAction], [updateVideoAction], [updateScreenAction], and [updateChatAction] functions are used to update the action states.
/// The [audioRequestState], [videoRequestState], [screenRequestState], and [chatRequestState] parameters indicate the state of the corresponding requests.
/// The [updateAudioRequestState], [updateVideoRequestState], [updateScreenRequestState], and [updateChatRequestState] functions are used to update the request states.
/// The [audioRequestTime], [videoRequestTime], [screenRequestTime], and [chatRequestTime] parameters indicate the time when the corresponding requests were made.
/// The [updateAudioRequestTime], [updateVideoRequestTime], [updateScreenRequestTime], and [updateChatRequestTime] functions are used to update the request times.
/// The [updateRequestIntervalSeconds] parameter specifies the interval in seconds for updating the requests.

void hostRequestResponse(
    {required Map<String, dynamic> requestResponse,
    required Map<String, dynamic> parameters}) async {
  // Extracting parameters from the map
  ShowAlert? showAlert = parameters['showAlert'];
  List<dynamic> requestList = parameters['requestList'] ?? [];
  void Function(List<dynamic>) updateRequestList =
      parameters['updateRequestList'];
  bool micAction = parameters['micAction'] ?? false;
  void Function(bool) updateMicAction = parameters['updateMicAction'];
  bool videoAction = parameters['videoAction'] ?? false;
  void Function(bool) updateVideoAction = parameters['updateVideoAction'];
  bool screenAction = parameters['screenAction'] ?? false;
  void Function(bool) updateScreenAction = parameters['updateScreenAction'];
  bool chatAction = parameters['chatAction'] ?? false;
  void Function(bool) updateChatAction = parameters['updateChatAction'];
  String audioRequestState = parameters['audioRequestState'] ?? '';
  void Function(String) updateAudioRequestState =
      parameters['updateAudioRequestState'];
  String videoRequestState = parameters['videoRequestState'] ?? '';
  void Function(String) updateVideoRequestState =
      parameters['updateVideoRequestState'];
  String screenRequestState = parameters['screenRequestState'] ?? '';
  void Function(String) updateScreenRequestState =
      parameters['updateScreenRequestState'];
  String chatRequestState = parameters['chatRequestState'] ?? '';
  void Function(String) updateChatRequestState =
      parameters['updateChatRequestState'];
  DateTime? audioRequestTime = parameters['audioRequestTime'];
  void Function(DateTime) updateAudioRequestTime =
      parameters['updateAudioRequestTime'];
  DateTime? videoRequestTime = parameters['videoRequestTime'];
  void Function(DateTime) updateVideoRequestTime =
      parameters['updateVideoRequestTime'];
  DateTime? screenRequestTime = parameters['screenRequestTime'];
  void Function(DateTime) updateScreenRequestTime =
      parameters['updateScreenRequestTime'];
  DateTime? chatRequestTime = parameters['chatRequestTime'];
  void Function(DateTime) updateChatRequestTime =
      parameters['updateChatRequestTime'];
  int updateRequestIntervalSeconds =
      parameters['updateRequestIntervalSeconds'] ?? 240;

  // requestResponse is the response of the host to the request of the participant

  // Check the action of the admin and if accept, allow the action
  // Notify the user if the action was accepted or not
  List<dynamic> requests = requestList;
  requestList = requests
      .where((request) =>
          request['id'] != requestResponse['id'] &&
          request['icon'] != requestResponse['type'] &&
          request['name'] != requestResponse['name'] &&
          request['username'] != requestResponse['username'])
      .toList();
  updateRequestList(requestList);
  String requestType = requestResponse['type'];

  if (requestResponse['action'] == 'accepted') {
    if (requestType == 'fa-microphone') {
      // Tell the user that the unmute request was accepted
      if (showAlert != null) {
        showAlert(
          message:
              'Unmute request was accepted; click the mic button again to begin.',
          type: 'success',
          duration: 10000,
        );
      }

      micAction = true;
      updateMicAction(micAction);
      audioRequestState = 'accepted';
      updateAudioRequestState(audioRequestState);
    } else if (requestType == 'fa-video') {
      // Tell the user that the video request was accepted
      if (showAlert != null) {
        showAlert(
          message:
              'Video request was accepted; click the video button again to begin.',
          type: 'success',
          duration: 10000,
        );
      }

      videoAction = true;
      updateVideoAction(videoAction);
      videoRequestState = 'accepted';
      updateVideoRequestState(videoRequestState);
    } else if (requestType == 'fa-desktop') {
      // Tell the user that the screenshare request was accepted
      if (showAlert != null) {
        showAlert(
          message:
              'Screenshare request was accepted; click the screen button again to begin.',
          type: 'success',
          duration: 10000,
        );
      }

      screenAction = true;
      updateScreenAction(screenAction);
      screenRequestState = 'accepted';
      updateScreenRequestState(screenRequestState);
    } else if (requestType == 'fa-comments') {
      // Tell the user that the chat request was accepted
      if (showAlert != null) {
        showAlert(
          message:
              'Chat request was accepted; click the chat button again to begin.',
          type: 'success',
          duration: 10000,
        );
      }

      chatAction = true;
      updateChatAction(chatAction);
      chatRequestState = 'accepted';
      updateChatRequestState(chatRequestState);
    }
  } else {
    // Notify the user that the action was not accepted, get the type of request and tell the user that the action was not accepted
    requestType = requestResponse['type'];
    if (requestType == 'fa-microphone') {
      // Tell the user that the unmute request was not accepted
      if (showAlert != null) {
        showAlert(
          message: 'Unmute request was not accepted',
          type: 'danger',
          duration: 10000,
        );
      }

      audioRequestState = 'rejected';
      updateAudioRequestState(audioRequestState);
      // Set audioRequestTimer to make user wait for updateRequestIntervalSeconds seconds before requesting again
      int audioRequestTimer = updateRequestIntervalSeconds;
      // Set datetimenow to current time
      DateTime audioRequestTimeNow = DateTime.now();
      // Add updateRequestIntervalSeconds seconds to datetimenow
      audioRequestTimeNow =
          audioRequestTimeNow.add(Duration(seconds: audioRequestTimer));
      // Set audioRequestTime to the new time
      audioRequestTime = audioRequestTimeNow;
      updateAudioRequestTime(audioRequestTime);
    } else if (requestType == 'fa-video') {
      // Tell the user that the video request was not accepted
      if (showAlert != null) {
        showAlert(
          message: 'Video request was not accepted',
          type: 'danger',
          duration: 10000,
        );
      }

      videoRequestState = 'rejected';
      updateVideoRequestState(videoRequestState);
      // Set videoRequestTimer to make user wait for updateRequestIntervalSeconds seconds before requesting again from UTC time now
      int videoRequestTimer = updateRequestIntervalSeconds;
      // Set datetimenow to current time
      DateTime videoRequestTimeNow = DateTime.now();
      // Add updateRequestIntervalSeconds seconds to datetimenow
      videoRequestTimeNow =
          videoRequestTimeNow.add(Duration(seconds: videoRequestTimer));
      // Set videoRequestTime to the new time
      videoRequestTime = videoRequestTimeNow;
      updateVideoRequestTime(videoRequestTime);
    } else if (requestType == 'fa-desktop') {
      // Tell the user that the screenshare request was not accepted
      if (showAlert != null) {
        showAlert(
          message: 'Screenshare request was not accepted',
          type: 'danger',
          duration: 10000,
        );
      }

      screenRequestState = 'rejected';
      updateScreenRequestState(screenRequestState);
      // Set screenRequestTimer to make user wait for updateRequestIntervalSeconds seconds before requesting again
      int screenRequestTimer = updateRequestIntervalSeconds;
      // Set datetimenow to current time
      DateTime screenRequestTimeNow = DateTime.now();
      // Add updateRequestIntervalSeconds seconds to datetimenow
      screenRequestTimeNow =
          screenRequestTimeNow.add(Duration(seconds: screenRequestTimer));
      // Set screenRequestTime to the new time
      screenRequestTime = screenRequestTimeNow;
      updateScreenRequestTime(screenRequestTime);
    } else if (requestType == 'fa-comments') {
      // Tell the user that the chat request was not accepted
      if (showAlert != null) {
        showAlert(
          message: 'Chat request was not accepted',
          type: 'danger',
          duration: 10000,
        );
      }

      chatRequestState = 'rejected';
      updateChatRequestState(chatRequestState);
      // Set chatRequestTimer to make user wait for updateRequestIntervalSeconds seconds before requesting again
      int chatRequestTimer = updateRequestIntervalSeconds;
      // Set datetimenow to current time
      DateTime chatRequestTimeNow = DateTime.now();
      // Add updateRequestIntervalSeconds seconds to datetimenow
      chatRequestTimeNow =
          chatRequestTimeNow.add(Duration(seconds: chatRequestTimer));
      // Set chatRequestTime to the new time
      chatRequestTime = chatRequestTimeNow;
      updateChatRequestTime(chatRequestTime);
    }
  }
}
