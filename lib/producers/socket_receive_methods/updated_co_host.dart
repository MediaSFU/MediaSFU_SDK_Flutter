import 'package:flutter/foundation.dart';

/// Updates the co-host information, co-host responsibility, and user's co-host status.
///
/// This function is responsible for updating the co-host information, co-host responsibility,
/// and user's co-host status based on the provided parameters. It takes in the following parameters:
///
/// - `coHost`: The new co-host information.
/// - `coHostResponsibility`: The new co-host responsibility.
/// - `parameters`: A map containing additional parameters:
///   - `showAlert`: A function to show an alert message.
///   - `eventType`: The type of event.
///   - `islevel`: The level of the event (default is '1').
///   - `member`: The member information (default is an empty string).
///   - `youAreCoHost`: The user's co-host status (default is false).
///   - `updateCoHost`: A function to update the co-host information.
///   - `updateCoHostResponsibility`: A function to update the co-host responsibility.
///   - `updateYouAreCoHost`: A function to update the user's co-host status.
///
/// The function performs the following steps:
///
/// 1. Destructures the parameters.
/// 2. Checks if the event type is not 'broadcast' or 'chat'.
///    - If true, updates the co-host information and co-host responsibility.
///    - If the member is the co-host and the user is not already a co-host, updates the user's co-host status and shows an alert message.
///    - If the member is not the co-host, updates the user's co-host status.
/// 3. Checks if the event type is not 'broadcast' or 'chat' and the level is not '2'.
///    - If true, updates the user's co-host status.
/// 4. Handles any errors that occur during the process.
///

typedef UpdateCoHostResponsibility = void Function(List<dynamic>);

typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

void updatedCoHost({
  required String coHost,
  required List<dynamic> coHostResponsibility,
  required Map<String, dynamic> parameters,
}) async {
  try {
    // Destructure parameters
    final ShowAlert? showAlert = parameters['showAlert'];
    final String eventType = parameters['eventType'];
    final String islevel = parameters['islevel'] ?? '1';
    final String member = parameters['member'] ?? '';
    bool youAreCoHost = parameters['youAreCoHost'] ?? false;
    final void Function(String) updateCoHost = parameters['updateCoHost'];
    final UpdateCoHostResponsibility updateCoHostResponsibility =
        parameters['updateCoHostResponsibility'];
    final void Function(bool) updateYouAreCoHost =
        parameters['updateYouAreCoHost'];

    if (eventType != 'broadcast' && eventType != 'chat') {
      // Only update the co-host if the event type is not broadcast or chat
      updateCoHost(coHost);
      updateCoHostResponsibility(coHostResponsibility);

      if (member == coHost) {
        if (!youAreCoHost) {
          youAreCoHost = true;
          updateYouAreCoHost(youAreCoHost);

          if (showAlert != null) {
            showAlert(
              message: 'You are now a co-host',
              type: 'success',
              duration: 3000,
            );
          }
        }
      } else {
        youAreCoHost = false;
        updateYouAreCoHost(youAreCoHost);
      }
    } else {
      if (islevel != '2') {
        youAreCoHost = true;
        updateYouAreCoHost(youAreCoHost);
      }
    }
  } catch (error) {
    if (kDebugMode) {
      // print("Error in updatedCoHost: $error");
    }
    // Handle error accordingly
  }
}
