/// Defines options for launching the display settings modal, including the function to
/// update visibility and the current modal visibility state.
class LaunchDisplaySettingsOptions {
  final void Function(bool isVisible) updateIsDisplaySettingsModalVisible;
  final bool isDisplaySettingsModalVisible;

  LaunchDisplaySettingsOptions({
    required this.updateIsDisplaySettingsModalVisible,
    required this.isDisplaySettingsModalVisible,
  });
}

/// Type definition for the function that launches the display settings modal.
typedef LaunchDisplaySettingsType = void Function(
    LaunchDisplaySettingsOptions options);

/// Toggles the visibility of the display settings modal.
///
/// This function calls `updateIsDisplaySettingsModalVisible` with the negated value of
/// `isDisplaySettingsModalVisible` to toggle the modal's visibility.
///
/// Example:
/// ```dart
/// final options = LaunchDisplaySettingsOptions(
///   updateIsDisplaySettingsModalVisible: (bool isVisible) {
///     // Update visibility here
///   },
///   isDisplaySettingsModalVisible: false,
/// );
///
/// launchDisplaySettings(options);
/// // This will open the display settings modal if it's currently closed, or close it if it's open.
/// ```
void launchDisplaySettings(LaunchDisplaySettingsOptions options) {
  options.updateIsDisplaySettingsModalVisible(
      !options.isDisplaySettingsModalVisible);
}
