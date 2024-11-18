/// Defines the options for toggling the confirmation exit modal visibility.
class LaunchConfirmExitOptions {
  final void Function(bool isVisible) updateIsConfirmExitModalVisible;
  final bool isConfirmExitModalVisible;

  LaunchConfirmExitOptions({
    required this.updateIsConfirmExitModalVisible,
    required this.isConfirmExitModalVisible,
  });
}

/// Type definition for the function that toggles the confirmation exit modal.
typedef LaunchConfirmExitType = void Function(LaunchConfirmExitOptions options);

/// Toggles the visibility of the confirmation exit modal.
///
/// This function calls `updateIsConfirmExitModalVisible` with the negated value of
/// `isConfirmExitModalVisible` to toggle the modal's visibility.
///
/// Example:
/// ```dart
/// final options = LaunchConfirmExitOptions(
///   updateIsConfirmExitModalVisible: (bool isVisible) {
///     // Update visibility state here
///   },
///   isConfirmExitModalVisible: false,
/// );
///
/// launchConfirmExit(options);
/// // This will open the modal if it's currently closed, or close it if it's open.
/// ```
void launchConfirmExit(LaunchConfirmExitOptions options) {
  options.updateIsConfirmExitModalVisible(!options.isConfirmExitModalVisible);
}
