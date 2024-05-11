/// Launches the confirmation exit modal.
///
/// This function opens the confirmation exit modal by calling the [updateIsConfirmExitModalVisible]
/// callback function with the opposite value of [isConfirmExitModalVisible].
///
/// Parameters:
/// - [updateIsConfirmExitModalVisible]: A required callback function that takes a boolean parameter
///   to update the visibility of the confirmation exit modal.
/// - [isConfirmExitModalVisible]: A required boolean value indicating the current visibility state
///   of the confirmation exit modal.
///
library;

// Define the function to launch the confirmation exit modal
void launchConfirmExit({
  required void Function(bool) updateIsConfirmExitModalVisible,
  required bool isConfirmExitModalVisible,
}) {
  // Open the confirmation exit modal
  updateIsConfirmExitModalVisible(!isConfirmExitModalVisible);
}
