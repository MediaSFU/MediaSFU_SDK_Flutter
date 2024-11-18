typedef UpdateIsSettingsModalVisible = void Function(bool isVisible);

/// Options for launching the settings modal.
class LaunchSettingsOptions {
  final UpdateIsSettingsModalVisible updateIsSettingsModalVisible;
  final bool isSettingsModalVisible;

  LaunchSettingsOptions({
    required this.updateIsSettingsModalVisible,
    required this.isSettingsModalVisible,
  });
}

/// Type definition for the launchSettings function.
typedef LaunchSettingsType = void Function(LaunchSettingsOptions options);

/// Toggles the visibility state of the settings modal.
///
/// The [options] parameter should include:
/// - `updateIsSettingsModalVisible`: A function to update the visibility state of the settings modal.
/// - `isSettingsModalVisible`: The current visibility state of the settings modal.
///
/// Example usage:
/// ```dart
/// launchSettings(
///   LaunchSettingsOptions(
///     updateIsSettingsModalVisible: (visible) => setModalVisible(visible),
///     isSettingsModalVisible: false,
///   ),
/// );
/// ```

void launchSettings(LaunchSettingsOptions options) {
  // Toggle the visibility of the settings modal
  options.updateIsSettingsModalVisible(!options.isSettingsModalVisible);
}
