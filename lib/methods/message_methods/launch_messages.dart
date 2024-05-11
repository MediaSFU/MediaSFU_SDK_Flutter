/// Opens or closes the messages modal based on the current visibility state.
///
/// This function takes two parameters:
/// - `updateIsMessagesModalVisible`: A required function that takes a boolean parameter and updates the visibility state of the messages modal.
/// - `isMessagesModalVisible`: A required boolean parameter that represents the current visibility state of the messages modal.
///
/// If the `isMessagesModalVisible` parameter is `true`, the function will close the messages modal by calling `updateIsMessagesModalVisible(false)`.
/// If the `isMessagesModalVisible` parameter is `false`, the function will open the messages modal by calling `updateIsMessagesModalVisible(true)`.
library;

void launchMessages({
  required Function(bool) updateIsMessagesModalVisible,
  required bool isMessagesModalVisible,
}) {
  // Toggles the visibility state of the messages modal.
  // If the modal is currently visible, it will be closed.
  // If it's hidden, it will be opened.
  updateIsMessagesModalVisible(!isMessagesModalVisible);
}
