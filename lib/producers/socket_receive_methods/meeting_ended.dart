import 'dart:async';
import 'package:flutter/foundation.dart';

/// Handles the logic when a meeting has ended.
///
/// This function takes a map of parameters and performs the following tasks:
/// - Extracts the required parameters from the map.
/// - Shows an alert message if the meeting has ended, with an optional redirect URL.
/// - Waits for 2 seconds before redirecting to the home page or updating the validated state.
///
/// The [parameters] map should contain the following keys:
/// - 'showAlert': A function that shows an alert message.
/// - 'redirectURL': A string representing the URL to redirect to (optional).
/// - 'onWeb': A boolean indicating if the app is running on the web (default is false).
/// - 'eventType': A string representing the type of event that triggered the meeting end.
/// - 'updateValidated': A function to update the validated state.
///
/// Throws an error if any exception occurs during the execution.

typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

Future<void> meetingEnded({required Map<String, dynamic> parameters}) async {
  try {
    // Extracting parameters from the map
    ShowAlert? showAlert = parameters['showAlert'];
    String? redirectURL = parameters['redirectURL'];
    bool onWeb = parameters['onWeb'] ?? false;
    String eventType = parameters['eventType'];
    Function updateValidated = parameters['updateValidated'];

    // Show an alert that the meeting has ended and wait for 2 seconds before redirecting to the home page
    if (eventType != 'chat') {
      if (showAlert != null) {
        showAlert(
          message: 'The meeting has ended. Redirecting to the home page...',
          type: 'danger',
          duration: 2000,
        );
      }

      if (onWeb && redirectURL != null && redirectURL.isNotEmpty) {
        await Future.delayed(const Duration(seconds: 2)); // Wait for 2 seconds
        // Redirect to the specified URL
        // Replace this with your actual navigation logic
        // For example, you can use Navigator.pushReplacementNamed(context, redirectURL);
      } else {
        await Future.delayed(const Duration(seconds: 2)); // Wait for 2 seconds
        // Update the validated state
        updateValidated(false);
      }
    }
  } catch (error) {
    if (kDebugMode) {
      // print("Error in meetingEnded: $error");
    }

    // Handle error accordingly
    rethrow;
  }
}
