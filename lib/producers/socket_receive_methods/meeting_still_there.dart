/// A function that updates the visibility of the "still there?" modal.
///
/// This function takes in the [timeRemaining] and [parameters] as required
/// parameters. The [timeRemaining] represents the remaining time for the meeting,
/// while the [parameters] is a map containing additional parameters.
///
/// The function destructures the [parameters] map to get the
/// [updateIsConfirmHereModalVisible] function. It then calls the
/// [updateIsConfirmHereModalVisible] function with the value `true` to update
/// the visibility of the "still there?" modal.
Future<void> meetingStillThere(
    {required int timeRemaining,
    required Map<String, dynamic> parameters}) async {
  // Destructure options
  Function updateIsConfirmHereModalVisible =
      parameters['updateIsConfirmHereModalVisible'];

  // Update the visibility of the "still there?" modal
  updateIsConfirmHereModalVisible(true);
}
