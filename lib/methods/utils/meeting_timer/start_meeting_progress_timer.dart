// ignore_for_file: unused_local_variable

import 'dart:async';

/// Starts a timer to track the progress of a meeting.
///
/// The [startTime] parameter specifies the start time of the meeting in seconds.
/// The [parameters] parameter is a map containing the callback functions for updating the meeting progress time and getting updated parameters.
///
/// The timer will update the meeting progress time every second by calling the [updateMeetingProgressTime] callback function.
/// It will also check for updated parameters by calling the [getUpdatedAllParams] callback function.
/// If the meeting is no longer validated or the room name is null or empty, the timer will be canceled.

typedef UpdateMeetingProgressTime = void Function(String time);
typedef GetUpdatedAllParams = Map<String, dynamic> Function();

void startMeetingProgressTimer(
    {required int startTime, required Map<String, dynamic> parameters}) {
  UpdateMeetingProgressTime updateMeetingProgressTime =
      parameters['updateMeetingProgressTime'];
  GetUpdatedAllParams getUpdatedAllParams = parameters['getUpdatedAllParams'];

  int calculateElapsedTime(int startTime) {
    int currentTimeInSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return currentTimeInSeconds - startTime;
  }

  String padNumber(int number) {
    return number.toString().padLeft(2, '0');
  }

  String formatTime(int timeInSeconds) {
    int hours = timeInSeconds ~/ 3600;
    int remainingSeconds = timeInSeconds % 3600;
    int minutes = remainingSeconds ~/ 60;
    int seconds = remainingSeconds % 60;
    return '${padNumber(hours)}:${padNumber(minutes)}:${padNumber(seconds)}';
  }

  int elapsedTime = calculateElapsedTime(startTime);

  late Timer timer;
  timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    elapsedTime++;
    String formattedTime = formatTime(elapsedTime);
    updateMeetingProgressTime(formattedTime);

    Map<String, dynamic> updatedParams = getUpdatedAllParams();
    bool validated = updatedParams['validated'];
    String? roomName = updatedParams['roomName'];

    if (!validated || roomName == null || roomName.isEmpty) {
      timer.cancel();
    }
  });
}
