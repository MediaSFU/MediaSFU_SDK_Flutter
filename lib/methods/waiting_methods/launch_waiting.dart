/// Options for launching the waiting modal
class LaunchWaitingOptions {
  final void Function(bool) updateIsWaitingModalVisible;
  final bool isWaitingModalVisible;

  LaunchWaitingOptions({
    required this.updateIsWaitingModalVisible,
    required this.isWaitingModalVisible,
  });
}

/// Signature for a function that updates the visibility of the waiting modal.
typedef LaunchWaitingType = void Function(LaunchWaitingOptions options);

/// Launches the waiting modal and toggles its visibility state.
///
/// This function uses `LaunchWaitingOptions` to update the visibility of a waiting modal.
/// It toggles the visibility by calling the `updateIsWaitingModalVisible` function with the
/// opposite of the current `isWaitingModalVisible` state.
///
/// ## Parameters:
/// - [options] - An instance of `LaunchWaitingOptions` containing:
///   - `updateIsWaitingModalVisible`: A function to update the visibility of the waiting modal.
///   - `isWaitingModalVisible`: A boolean indicating the current visibility state of the modal.
///
/// ## Example Usage:
///
/// ```dart
/// // Define a function to handle the visibility update
/// void updateVisibility(bool isVisible) {
///   print('Waiting modal is now: ${isVisible ? "Visible" : "Hidden"}');
/// }
///
/// // Initialize LaunchWaitingOptions with the current visibility state and the update function
/// final waitingOptions = LaunchWaitingOptions(
///   updateIsWaitingModalVisible: updateVisibility,
///   isWaitingModalVisible: false, // Initial state: hidden
/// );
///
/// // Call the launchWaiting function to toggle visibility
/// launchWaiting(waitingOptions); // Output: "Waiting modal is now: Visible"
/// ```

void launchWaiting(
  LaunchWaitingOptions options,
) {
  // Toggle the visibility of the waiting modal
  options.updateIsWaitingModalVisible(!options.isWaitingModalVisible);
}
