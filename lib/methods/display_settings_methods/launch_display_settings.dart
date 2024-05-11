typedef UpdateIsDisplaySettingsModalVisible = void Function(bool);
typedef IsDisplaySettingsModalVisible = bool;

/// Launches the display settings modal and toggles its visibility.
///
/// This function takes two required parameters:
/// - [updateIsDisplaySettingsModalVisible]: A callback function that updates the visibility of the display settings modal.
/// - [isDisplaySettingsModalVisible]: A getter function that returns the current visibility of the display settings modal.
///
/// When called, this function will toggle the visibility of the display settings modal by calling the [updateIsDisplaySettingsModalVisible] function
/// with the negation of the current visibility value obtained from [isDisplaySettingsModalVisible].

void launchDisplaySettings({
  required UpdateIsDisplaySettingsModalVisible
      updateIsDisplaySettingsModalVisible,
  required IsDisplaySettingsModalVisible isDisplaySettingsModalVisible,
}) {
  // Toggle the visibility of the display settings modal.
  updateIsDisplaySettingsModalVisible(!isDisplaySettingsModalVisible);
}
