/// Callback function type for showing an alert message.
typedef ShowAlert = void Function(String message);

/// Callback function type for updating the waiting room participant list.
typedef UpdateWaitingRoomList = void Function(
    List<dynamic> waitingParticipants);

/// Callback function type for updating the total number of waiting room requests.
typedef UpdateTotalReqWait = void Function(int totalRequests);

/// Retrieves all waiting room members and performs necessary updates.
///
/// This function takes in a list of waiting room participants and a map of parameters.
/// It then calculates the total number of waiting room participants, updates the waiting room
/// participant list, and updates the total count of waiting room participants using the provided
/// callback functions.
///
/// Parameters:
/// - `waitingParticipants`: A list of waiting room participants.
/// - `parameters`: A map of parameters containing the callback functions for updating the waiting room list
///   and the total count of waiting room participants.
void allWaitingRoomMembers({
  required List<dynamic> waitingParticipants,
  required Map<String, dynamic> parameters,
}) {
  UpdateTotalReqWait updateTotalReqWait = parameters['updateTotalReqWait'];
  UpdateWaitingRoomList updateWaitingRoomList =
      parameters['updateWaitingRoomList'];

  // Calculate the total number of waiting room participants
  int totalReqs = waitingParticipants.length;

  // Update the waiting room participants list
  updateWaitingRoomList(waitingParticipants);

  // Update the total count of waiting room participants
  updateTotalReqWait(totalReqs);
}
