import 'dart:async';

/// Type definition for updating the meeting progress time in HH:MM:SS format.
typedef UpdateMeetingProgressTime = void Function(String formattedTime);

/// Parameters for starting the meeting progress timer.
abstract class StartMeetingProgressTimerParameters {
  // Core properties as abstract getters
  UpdateMeetingProgressTime get updateMeetingProgressTime;
  bool get validated;
  String get roomName;

  // Method to retrieve updated parameters as an abstract getter
  StartMeetingProgressTimerParameters Function() get getUpdatedAllParams;

  // dynamic operator [](String key);
}

/// Options for starting the meeting progress timer.
class StartMeetingProgressTimerOptions {
  final int startTime;
  final StartMeetingProgressTimerParameters parameters;

  StartMeetingProgressTimerOptions({
    required this.startTime,
    required this.parameters,
  });
}

typedef StartMeetingProgressTimerType = void Function({
  required StartMeetingProgressTimerOptions options,
});

/// Starts a timer to track the progress of a meeting.
///
/// This function calculates the elapsed time from the provided start time,
/// updates the time every second, and formats it to `HH:MM:SS`.
///
/// - If the meeting is invalidated or the room name is empty, the timer stops.
///
/// ### Example Usage:
/// ```dart
/// startMeetingProgressTimer(
///   options: StartMeetingProgressTimerOptions(
///     startTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
///     parameters: StartMeetingProgressTimerParameters(
///       updateMeetingProgressTime: (time) => print("Meeting Time: $time"),
///       validated: true,
///       roomName: "room1",
///       getUpdatedAllParams: () => {
///         'validated': true,
///         'roomName': 'room1',
///       },
///     ),
///   ),
/// );
/// ```
void startMeetingProgressTimer({
  required StartMeetingProgressTimerOptions options,
}) {
  final startTime = options.startTime;
  var parameters = options.parameters;

  // Utility function to calculate elapsed time based on start time.
  int calculateElapsedTime(int startTime) {
    final currentTimeInSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return currentTimeInSeconds - startTime;
  }

  // Utility function to format time in HH:MM:SS format.
  String padNumber(int number) => number.toString().padLeft(2, '0');

  String formatTime(int timeInSeconds) {
    final hours = timeInSeconds ~/ 3600;
    final minutes = (timeInSeconds % 3600) ~/ 60;
    final seconds = timeInSeconds % 60;
    return '${padNumber(hours)}:${padNumber(minutes)}:${padNumber(seconds)}';
  }

  var elapsedTime = calculateElapsedTime(startTime);

  // Initialize and start the timer
  // ignore: unused_local_variable
  late Timer timer;
  timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    elapsedTime++;
    final formattedTime = formatTime(elapsedTime);
    parameters.updateMeetingProgressTime(formattedTime);

    // Get updated parameters
    final updatedParams = parameters.getUpdatedAllParams();
    final validated = updatedParams.validated;
    final roomName = updatedParams.roomName;

    // Stop the timer if the meeting is invalidated or room name is missing
    if (!validated || roomName.isEmpty) {
      timer.cancel();
    }
  });
}
