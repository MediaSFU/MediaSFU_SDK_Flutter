/// Callback function type for updating the visibility of the participants modal.
///
/// The [UpdateIsParticipantsModalVisible] function takes a boolean parameter
/// indicating whether the participants modal should be visible or not.
typedef UpdateIsParticipantsModalVisible = void Function(bool);

/// Launches the participants modal and updates its visibility.
///
/// The [updateIsParticipantsModalVisible] parameter is a required callback function
/// that updates the visibility of the participants modal. It takes a boolean parameter
/// indicating whether the participants modal should be visible or not.
///
/// The [isParticipantsModalVisible] parameter is a required boolean value that
/// indicates the current visibility state of the participants modal.
///
/// This function toggles the visibility of the participants modal by calling the
/// [updateIsParticipantsModalVisible] callback function with the negation of the
/// [isParticipantsModalVisible] parameter.
void launchParticipants({
  required UpdateIsParticipantsModalVisible updateIsParticipantsModalVisible,
  required bool isParticipantsModalVisible,
}) {
  updateIsParticipantsModalVisible(!isParticipantsModalVisible);
}
