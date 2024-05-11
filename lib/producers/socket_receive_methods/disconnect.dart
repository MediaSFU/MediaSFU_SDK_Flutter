typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

/// Disconnects the user from the session, updating the necessary state and triggering alerts if needed.
///
/// The [disconnect] function takes a map of parameters as input. The parameters include:
/// - [showAlert]: A function that displays an alert to the user. It takes a [message] (required), [type] (required), and [duration] (required) as arguments.
/// - [redirectURL]: A string representing the URL to redirect to on the web. Defaults to an empty string if not provided.
/// - [onWeb]: A boolean indicating whether the user is on the web. Defaults to false if not provided.
/// - [updateValidated]: A function that updates the validated state.
///
/// If the user is on the web and a [redirectURL] is provided, the function redirects the user to the specified URL.
/// Otherwise, it displays an alert to the user with a message indicating that they have been disconnected from the session.
/// After a delay of 2 seconds, it calls the [updateValidated] function with a value of false to update the validated state.
void disconnect({required Map<String, dynamic> parameters}) {
  final ShowAlert? showAlert = parameters['showAlert'];
  final String? redirectURL = parameters['redirectURL'] ?? '';
  final bool onWeb = parameters['onWeb'] ?? false;
  final Function updateValidated = parameters['updateValidated'];

  if (onWeb && (redirectURL != null && redirectURL.isNotEmpty)) {
    // Redirect to the specified URL on the web
  } else {
    if (showAlert != null) {
      showAlert(
        message: 'You have been disconnected from the session.',
        type: 'danger',
        duration: 3000,
      );
    }

    Future.delayed(const Duration(seconds: 2), () {
      updateValidated(false);
    });
  }
}
