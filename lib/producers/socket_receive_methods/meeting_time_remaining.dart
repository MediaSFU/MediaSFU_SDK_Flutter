import 'dart:async';

/// A function that shows an alert with a specific message, type, and duration.
typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

/// Updates the meeting time remaining and shows an alert with the remaining time.
///
/// This function takes in the [timeRemaining] in milliseconds and [parameters] as a map
/// containing the options for showing the alert. The [parameters] map should contain
/// a [showAlert] function and an [eventType] string.
///
/// The function converts the [timeRemaining] from milliseconds to a readable format
/// of minutes and seconds. It then shows an alert with the time remaining, unless
/// the [eventType] is 'chat'. If the [showAlert] function is provided, it will be called
/// with the message, type, and duration parameters.
///
/// Example usage:
///
/// ```dart
/// await meetingTimeRemaining(
///   timeRemaining: 60000,
///   parameters: {
///     'showAlert': showAlertFunction,
///     'eventType': 'meeting',
///   },
/// );
/// ```
Future<void> meetingTimeRemaining({
  required int timeRemaining,
  required Map<String, dynamic> parameters,
}) async {
  // Destructure options
  ShowAlert? showAlert = parameters['showAlert'];
  String eventType = parameters['eventType'];

  // Update the meeting time remaining

  // Convert time from milliseconds to readable format of minutes and seconds
  int minutes = (timeRemaining / 60000).floor();
  int seconds = ((timeRemaining % 60000) / 1000).round();
  String timeRemainingString = '$minutes:${seconds < 10 ? '0' : ''}$seconds';

  // Show alert with time remaining
  if (eventType != 'chat') {
    if (showAlert != null) {
      showAlert(
        message: 'The event will end in $timeRemainingString minutes.',
        type: 'success',
        duration: 3000,
      );
    }
  }
}
