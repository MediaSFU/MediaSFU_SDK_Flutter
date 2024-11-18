import 'dart:async';
import '../../types/types.dart' show ShowAlert;

/// Options for disconnecting the user from the session.
class DisconnectOptions {
  final ShowAlert? showAlert;
  final String? redirectURL;
  final bool onWeb;
  final void Function(bool)? updateValidated;

  DisconnectOptions({
    this.showAlert,
    this.redirectURL,
    required this.onWeb,
    this.updateValidated,
  });
}

typedef DisconnectType = void Function(DisconnectOptions options);

/// Disconnects the user from the session, updating the necessary state and triggering alerts if needed.
///
/// If [onWeb] is true and [redirectURL] is provided, the function performs a redirect.
/// Otherwise, it shows an alert indicating the user has been disconnected, and after a delay,
/// updates the validation state to false if [updateValidated] is provided.
///
/// Example:
/// ```dart
/// disconnect(DisconnectOptions(
///   showAlert: (message, type, duration) => print('$message ($type) for $duration ms'),
///   redirectURL: 'https://example.com',
///   onWeb: true,
///   updateValidated: (isValid) => print('Validated: $isValid'),
/// ));
/// ```
void disconnect(DisconnectOptions options) {
  if (options.onWeb &&
      options.redirectURL != null &&
      options.redirectURL!.isNotEmpty) {
    // Redirect to the specified URL on the web
    // Replace with your web navigation logic as needed
  } else {
    // Display an alert if `showAlert` is provided
    options.showAlert?.call(
      message: 'You have been disconnected from the session.',
      type: 'danger',
      duration: 3000,
    );

    // Delay and update the validation state if `updateValidated` is provided
    if (options.updateValidated != null) {
      Future.delayed(const Duration(seconds: 2), () {
        options.updateValidated!(false);
      });
    }
  }
}
