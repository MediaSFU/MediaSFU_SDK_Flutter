import 'dart:async';

/// Defines options for handling the "still there?" check in a meeting.
class MeetingStillThereOptions {
  final void Function(bool) updateIsConfirmHereModalVisible;

  MeetingStillThereOptions({
    required this.updateIsConfirmHereModalVisible,
  });
}

typedef MeetingStillThereType = Future<void> Function(
    MeetingStillThereOptions options);

/// Updates the visibility of the "still there?" modal in a meeting.
///
/// This function takes an instance of [MeetingStillThereOptions] containing
/// the [updateIsConfirmHereModalVisible] function, which updates the visibility of the confirmation modal.
///
/// Example usage:
/// ```dart
/// await meetingStillThere(
///   options: MeetingStillThereOptions(
///     updateIsConfirmHereModalVisible: (isVisible) => print("Modal visibility: $isVisible"),
///   ),
/// );
/// // Output:
/// // "Modal visibility: true"
/// ```
Future<void> meetingStillThere({
  required MeetingStillThereOptions options,
}) async {
  // Update the visibility of the "still there?" modal
  options.updateIsConfirmHereModalVisible(true);
}
