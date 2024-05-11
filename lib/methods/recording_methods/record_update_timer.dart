typedef UpdateRecordElapsedTime = void Function(int elapsedTime);
typedef UpdateRecordingProgressTime = void Function(String formattedTime);

/// Updates the record elapsed time and recording progress time.
///
/// This function takes a map of parameters, including the record elapsed time,
/// record start time, and callback functions for updating the elapsed time and
/// progress time. It calculates the elapsed time since the record start time,
/// updates the elapsed time using the provided callback function, and formats
/// the time in HH:MM:SS format using the provided callback function.

void recordUpdateTimer({required Map<String, dynamic> parameters}) {
  int recordElapsedTime = parameters['recordElapsedTime'];
  int recordStartTime = parameters['recordStartTime'];
  UpdateRecordElapsedTime updateRecordElapsedTime =
      parameters['updateRecordElapsedTime'];
  UpdateRecordingProgressTime updateRecordingProgressTime =
      parameters['updateRecordingProgressTime'];

  // Utility function to pad single-digit numbers with leading zeros.
  String padNumber(int number) {
    return number.toString().padLeft(2, '0');
  }

  int currentTime =
      DateTime.now().millisecondsSinceEpoch; // Get the current timestamp
  recordElapsedTime = ((currentTime - recordStartTime) / 1000)
      .floor(); // Calculate the elapsed time in seconds
  updateRecordElapsedTime(recordElapsedTime);

  // Format the time in HH:MM:SS format
  int hours = recordElapsedTime ~/ 3600;
  int minutes = (recordElapsedTime % 3600) ~/ 60;
  int seconds = recordElapsedTime % 60;
  String formattedTime =
      '${padNumber(hours)}:${padNumber(minutes)}:${padNumber(seconds)}';

  updateRecordingProgressTime(formattedTime);
}
