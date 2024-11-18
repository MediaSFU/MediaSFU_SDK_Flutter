/// Callback function type for updating the visibility of the participants modal.
typedef UpdateIsParticipantsModalVisible = void Function(bool);

/// Defines options for launching the participants modal.
class LaunchParticipantsOptions {
  final UpdateIsParticipantsModalVisible updateIsParticipantsModalVisible;
  final bool isParticipantsModalVisible;

  LaunchParticipantsOptions({
    required this.updateIsParticipantsModalVisible,
    required this.isParticipantsModalVisible,
  });
}

/// Type definition for the function that launches the participants modal.
typedef LaunchParticipantsType = void Function(
    LaunchParticipantsOptions options);

/// Toggles the visibility of the participants modal.
///
/// This function takes an [options] parameter of type [LaunchParticipantsOptions],
/// which includes:
/// - `updateIsParticipantsModalVisible`: A callback function to update the visibility state of the participants modal.
/// - `isParticipantsModalVisible`: The current visibility state of the participants modal.
///
/// Example:
/// ```dart
/// final options = LaunchParticipantsOptions(
///   updateIsParticipantsModalVisible: (isVisible) => print("Participants modal visible: $isVisible"),
///   isParticipantsModalVisible: true,
/// );
///
/// launchParticipants(options);
/// // This will toggle the visibility state of the participants modal.
/// ```
void launchParticipants(LaunchParticipantsOptions options) {
  options.updateIsParticipantsModalVisible(!options.isParticipantsModalVisible);
}
