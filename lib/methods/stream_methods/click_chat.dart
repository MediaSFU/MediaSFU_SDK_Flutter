typedef UpdateIsMessagesModalVisible = void Function(bool isVisible);
typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

/// Handles the click event on the chat button.
///
/// This function takes a map of parameters and performs the following actions:
/// - Extracts the necessary parameters from the map.
/// - Toggles the visibility of the messages modal based on the current state.
/// - Checks if chat is allowed based on event settings and participant level.
/// - Shows an alert if chat is not allowed.
///
/// Parameters:
/// - `parameters`: A map containing the necessary parameters for the function.

void clickChat({required Map<String, dynamic> parameters}) {
  // Extracting parameters from the map
  bool isMessagesModalVisible = parameters['isMessagesModalVisible'];
  UpdateIsMessagesModalVisible updateIsMessagesModalVisible =
      parameters['updateIsMessagesModalVisible'];
  String chatSetting = parameters['chatSetting'];
  String islevel = parameters['islevel'];
  ShowAlert showAlert = parameters['showAlert'];

  // Toggle chat modal visibility
  if (isMessagesModalVisible) {
    updateIsMessagesModalVisible(false);
  } else {
    // Check if chat is allowed based on event settings and participant level
    if (chatSetting != 'allow' && islevel != '2') {
      updateIsMessagesModalVisible(false);
      showAlert(
        message: 'Chat is disabled for this event.',
        type: 'error',
        duration: 3000,
      );
    } else {
      updateIsMessagesModalVisible(true);
    }
  }
}
