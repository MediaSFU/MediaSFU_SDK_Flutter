/// Signature for a function that updates the visibility of the waiting modal.
typedef UpdateIsWaitingModalVisible = void Function(bool isVisible);

/// Launches the waiting modal and updates its visibility.
///
/// The [updateIsWaitingModalVisible] function is used to update the visibility
/// of the waiting modal. The [isWaitingModalVisible] parameter indicates the
/// current visibility state of the modal.
void launchWaiting({
  required UpdateIsWaitingModalVisible updateIsWaitingModalVisible,
  required bool isWaitingModalVisible,
}) {
  // Toggles the visibility of the waiting modal
  updateIsWaitingModalVisible(!isWaitingModalVisible);
}
