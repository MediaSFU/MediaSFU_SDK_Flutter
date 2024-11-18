import 'dart:async';
import '../../types/types.dart' show EventType, ShowAlert;

/// Defines options for handling meeting time remaining.
class MeetingTimeRemainingOptions {
  final int timeRemaining;
  final ShowAlert? showAlert;
  final EventType eventType;

  MeetingTimeRemainingOptions({
    required this.timeRemaining,
    required this.eventType,
    this.showAlert,
  });
}

typedef MeetingTimeRemainingType = Future<void> Function(
    MeetingTimeRemainingOptions options);

/// Updates the meeting time remaining and shows an alert if the event type is not 'chat'.
///
/// This function takes in [MeetingTimeRemainingOptions] which contains the remaining time in
/// milliseconds, an optional [showAlert] function to display the alert, and the [eventType].
///
/// Converts [timeRemaining] to minutes and seconds and, if [eventType] is not 'chat', shows an alert with
/// the formatted time.
///
/// Example usage:
/// ```dart
/// await meetingTimeRemaining(
///   options: MeetingTimeRemainingOptions(
///     timeRemaining: 450000, // 7 minutes and 30 seconds
///     eventType: 'meeting',
///     showAlert: (message, type, duration) => print(message),
///   ),
/// );
/// // Output:
/// // "The event will end in 7:30 minutes."
/// ```
Future<void> meetingTimeRemaining({
  required MeetingTimeRemainingOptions options,
}) async {
  final int minutes = options.timeRemaining ~/ 60000;
  final int seconds = (options.timeRemaining % 60000) ~/ 1000;
  final String timeRemainingString =
      '$minutes:${seconds.toString().padLeft(2, '0')}';

  // Show alert with time remaining if eventType is not 'chat'
  if (options.eventType != EventType.chat) {
    options.showAlert!(
      message: 'The event will end in $timeRemainingString minutes.',
      type: 'success',
      duration: 3000,
    );
  }
}
