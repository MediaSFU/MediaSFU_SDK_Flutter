/// Handles the participant request to join the event.
///
/// This function takes in two required parameters: [parameters] and [userRequest].
/// The [parameters] parameter is a map that contains the following keys:
///   - 'requestList': A list of dynamic objects representing the current request list.
///   - 'waitingRoomList': A list of dynamic objects representing the current waiting room list.
///   - 'updateTotalReqWait': A function used to update the total count of requests and waiting room participants.
///   - 'updateRequestList': A function used to update the request list.
///
/// The [userRequest] parameter is a map that represents the user's request to join the event.
///
/// This function adds the [userRequest] to the [requestList] and updates the [requestList] using the [updateRequestList] function.
/// It also calculates the total count of requests and waiting room participants and updates it using the [updateTotalReqWait] function.
void participantRequested({
  required Map<String, dynamic> parameters,
  required Map<String, dynamic> userRequest,
}) {
  // Handle participant request to join the event

  List<dynamic> requestList = parameters['requestList'];
  List<dynamic> waitingRoomList = parameters['waitingRoomList'];
  Function updateTotalReqWait = parameters['updateTotalReqWait'];
  Function updateRequestList = parameters['updateRequestList'];

  // Add the user request to the request list

  requestList.add(userRequest);
  updateRequestList(requestList);

  // Update the total count of requests and waiting room participants
  int reqCount = requestList.length + waitingRoomList.length;
  updateTotalReqWait(reqCount);
}
