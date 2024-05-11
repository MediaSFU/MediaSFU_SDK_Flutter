/// Updates the screen producer ID and related UI states.
///
/// This function takes in a [producerId] and a [parameters] map, which contains
/// various parameters related to the screen producer. The [parameters] map should
/// include the following keys:
///   - 'screenId': The ID of the screen.
///   - 'membersReceived': A boolean indicating whether members data has been received.
///   - 'shareScreenStarted': A boolean indicating whether screen sharing has started.
///   - 'deferScreenReceived': A boolean indicating whether screen deferment has been received.
///   - 'participants': A list of participants.
///   - 'updateScreenId': A function to update the screen ID.
///   - 'updateShareScreenStarted': A function to update the screen sharing status.
///   - 'updateDeferScreenReceived': A function to update the screen deferment status.
///
/// The function checks if the members data has been received with the screenId participant
/// in it. If so, it updates the screen ID, sets the screen sharing status to true, and
/// sets the screen deferment status to false. It then calls the appropriate update functions
/// to reflect these changes in the UI.
///
/// If the members data has not been received or the screenId participant is not found,
/// it sets the screen deferment status to true and updates the screen ID accordingly.
///
/// Example usage:
/// ```dart
/// screenProducerId(
///   producerId: '12345',
///   parameters: {
///     'screenId': 'screen123',
///     'membersReceived': true,
///     'shareScreenStarted': false,
///     'deferScreenReceived': false,
///     'participants': [
///       {'ScreenID': 'screen123', 'ScreenOn': true},
///       {'ScreenID': 'screen456', 'ScreenOn': false},
///     ],
///     'updateScreenId': (String screenId) {
///       // Update screen ID in UI
///     },
///     'updateShareScreenStarted': (bool shareScreenStarted) {
///       // Update screen sharing status in UI
///     },
///     'updateDeferScreenReceived': (bool deferScreenReceived) {
///       // Update screen deferment status in UI
///     },
///   },
/// );
///
void screenProducerId({
  required String producerId,
  required Map<String, dynamic> parameters,
}) {
  // Update screen producer ID and related UI states
  String? screenId = parameters['screenId'];
  bool membersReceived = parameters['membersReceived'] ?? false;
  bool shareScreenStarted = parameters['shareScreenStarted'] ?? false;
  bool deferScreenReceived = parameters['deferScreenReceived'] ?? false;
  List<dynamic> participants = parameters['participants'];
  Function(String)? updateScreenId = parameters['updateScreenId'];
  Function(bool)? updateShareScreenStarted =
      parameters['updateShareScreenStarted'];
  Function(bool)? updateDeferScreenReceived =
      parameters['updateDeferScreenReceived'];

  // Check if members data has been received with the screenId participant in it
  dynamic host = participants.firstWhere(
    (participant) =>
        participant['ScreenID'] == screenId && participant['ScreenOn'] == true,
    orElse: () => null,
  );

  // Operations to update the UI
  if (host != null && membersReceived) {
    screenId = producerId;
    shareScreenStarted = true;
    deferScreenReceived = false;

    updateScreenId?.call(screenId);
    updateShareScreenStarted?.call(shareScreenStarted);
    updateDeferScreenReceived?.call(deferScreenReceived);
  } else {
    deferScreenReceived = true;
    screenId = producerId;

    updateScreenId?.call(screenId);
    updateDeferScreenReceived?.call(deferScreenReceived);
  }
}
