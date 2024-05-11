typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

/// This function is used to control the recording timer by allowing pause and resume actions.
///
/// The [stop] parameter is optional and indicates whether the recording should be stopped.
/// The [parameters] parameter is a map that contains the required parameters for the function.
/// The [parameters] map should include a function named 'getUpdatedAllParams' that returns a map of updated parameters.
///
/// The function returns a boolean value indicating whether the timer can be paused or resumed.
///
/// If the timer is running and pause/resume actions are allowed, the function returns true.
/// Otherwise, if the [stop] parameter is true, an alert message is shown indicating that the recording can only be stopped after 15 seconds of starting or pausing or resuming.
/// If the [stop] parameter is false, an alert message is shown indicating that the recording can only be paused or resumed after 15 seconds of starting or pausing or resuming.
/// In both cases, the function returns false.
///
/// The [ShowAlert] typedef is used to define a function that shows an alert message.
/// The [GetUpdatedAllParams] typedef is used to define a function that returns a map of updated parameters.

typedef GetUpdatedAllParams = Map<String, dynamic> Function();

bool recordPauseTimer({
  bool stop = false,
  required Map<String, dynamic> parameters,
}) {
  GetUpdatedAllParams getUpdatedAllParams = parameters['getUpdatedAllParams'];
  parameters = getUpdatedAllParams();

  final bool isTimerRunning = parameters['isTimerRunning'] ?? false;
  final bool canPauseResume = parameters['canPauseResume'] ?? false;
  final ShowAlert? showAlert = parameters['showAlert'];

  void showAlertMessage(String message) {
    if (showAlert != null) {
      showAlert(
        message: message,
        type: 'danger',
        duration: 3000,
      );
    }
  }

  // Ensure the timer is running and pause/resume actions are allowed
  if (isTimerRunning && canPauseResume) {
    return true;
  } else {
    if (stop) {
      showAlertMessage(
          'Can only stop after 15 seconds of starting or pausing or resuming recording');
    } else {
      showAlertMessage(
          'Can only pause or resume after 15 seconds of starting or pausing or resuming recording');
    }
    return false;
  }
}
