/// Type definition for a function that shows an alert/notification.
typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

/// Function that handles a person joining an event.
///
/// This function displays an alert/notification about the person joining the event.
/// It takes in the person's name and a map of parameters, which should include a [ShowAlert] function
/// to display the alert/notification.
void personJoined(
    {required String name, required Map<String, dynamic> parameters}) async {
  ShowAlert? showAlert = parameters['showAlert'];

  if (showAlert != null) {
    showAlert(
      message: '$name has joined the event.',
      type: 'success',
      duration: 2000,
    );
  }
}
