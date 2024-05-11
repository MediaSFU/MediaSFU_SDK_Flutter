typedef UpdateIsSettingsModalVisible = void Function(bool isVisible);

/// Launches the settings modal and updates its visibility.
///
/// The [updateIsSettingsModalVisible] parameter is a required callback function
/// that updates the visibility of the settings modal. It takes a boolean value
/// [isVisible] as a parameter, indicating whether the modal should be visible or not.
///
/// The [isSettingsModalVisible] parameter is a required boolean value that
/// represents the current visibility state of the settings modal.

void launchSettings(
    {required UpdateIsSettingsModalVisible updateIsSettingsModalVisible,
    required bool isSettingsModalVisible}) {
  // Toggles the visibility of the settings modal
  updateIsSettingsModalVisible(!isSettingsModalVisible);
}
