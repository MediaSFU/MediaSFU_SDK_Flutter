/// Defines options for launching the co-host modal, including the function to
/// update visibility and the current modal visibility state.
class LaunchCoHostOptions {
  final void Function(bool isVisible) updateIsCoHostModalVisible;
  final bool isCoHostModalVisible;

  LaunchCoHostOptions({
    required this.updateIsCoHostModalVisible,
    required this.isCoHostModalVisible,
  });
}

/// Type definition for the function that launches the co-host modal.
typedef LaunchCoHostType = void Function(LaunchCoHostOptions options);

/// Toggles the visibility of the co-host modal.
///
/// This function calls `updateIsCoHostModalVisible` with the negated value of
/// `isCoHostModalVisible` to toggle the modal's visibility.
///
/// Example:
/// ```dart
/// final options = LaunchCoHostOptions(
///   updateIsCoHostModalVisible: (bool isVisible) {
///     // Update visibility here
///   },
///   isCoHostModalVisible: false,
/// );
///
/// launchCoHost(options);
/// // Toggles the co-host modal to visible.
/// ```
void launchCoHost(LaunchCoHostOptions options) {
  options.updateIsCoHostModalVisible(!options.isCoHostModalVisible);
}
