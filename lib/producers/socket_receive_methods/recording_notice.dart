import 'dart:async';
import 'package:flutter/foundation.dart';

/// This function handles the recording notice logic.
///
/// It takes in several parameters and updates the state of various variables
/// based on the provided parameters. The function also triggers callbacks
/// to update the UI with the updated values.
///
/// Parameters:
/// - `parameters`: A map containing various parameters related to recording.
/// - `timeDone`: An optional integer representing the time elapsed during recording.
/// - `pauseCount`: An optional integer representing the number of times recording was paused.
/// - `state`: An optional string representing the current state of recording.
/// - `userRecordingParam`: An optional map containing user-specific recording parameters.
///
/// Returns: A Future that completes when the recording notice logic is executed.

typedef UpdateUserRecordingParams = void Function(Map<String, dynamic> value);
typedef UpdateBooleanState = void Function(bool value);
typedef UpdateStringState = void Function(String value);
typedef UpdateIntState = void Function(int value);
// ignore: non_constant_identifier_names
Future<void> RecordingNotice({
  required Map<String, dynamic> parameters,
  int? timeDone = 0,
  int? pauseCount = 0,
  String? state = 'pause',
  Map<String, dynamic>? userRecordingParam,
}) async {
  try {
    String islevel = parameters['islevel'];
    Map<String, dynamic> userRecordingParams =
        parameters['userRecordingParams'];
    String recordingMediaOptions = parameters['recordingMediaOptions'];
    String recordingAudioOptions = parameters['recordingAudioOptions'];
    String recordingVideoOptions = parameters['recordingVideoOptions'];
    String recordingVideoType = parameters['recordingVideoType'];
    bool recordingVideoOptimized = parameters['recordingVideoOptimized'];
    String recordingDisplayType = parameters['recordingDisplayType'];
    bool recordingAddHLS = parameters['recordingAddHLS'];
    bool recordingNameTags = parameters['recordingNameTags'];
    String recordingBackgroundColor = parameters['recordingBackgroundColor'];
    String recordingNameTagsColor = parameters['recordingNameTagsColor'];
    String recordingOrientationVideo = parameters['recordingOrientationVideo'];
    bool recordingAddText = parameters['recordingAddText'];
    String recordingCustomText = parameters['recordingCustomText'];
    String recordingCustomTextPosition =
        parameters['recordingCustomTextPosition'];
    String recordingCustomTextColor = parameters['recordingCustomTextColor'];
    int pauseRecordCount = parameters['pauseRecordCount'];
    int recordElapsedTime = parameters['recordElapsedTime'];
    bool recordStarted = parameters['recordStarted'];
    bool recordPaused = parameters['recordPaused'];
    bool canLaunchRecord = parameters['canLaunchRecord'];
    bool recordStopped = parameters['recordStopped'] ?? false;
    bool isTimerRunning = parameters['isTimerRunning'] ?? false;
    bool canPauseResume = parameters['canPauseResume'] ?? false;
    int recordStartTime = parameters['recordStartTime'] ?? 0;

    UpdateStringState updateRecordingProgressTime =
        parameters['updateRecordingProgressTime'];
    UpdateBooleanState updateShowRecordButtons =
        parameters['updateShowRecordButtons'];
    UpdateUserRecordingParams updateUserRecordingParams =
        parameters['updateUserRecordingParams'];
    UpdateStringState updateRecordingMediaOptions =
        parameters['updateRecordingMediaOptions'];
    UpdateStringState updateRecordingAudioOptions =
        parameters['updateRecordingAudioOptions'];
    UpdateStringState updateRecordingVideoOptions =
        parameters['updateRecordingVideoOptions'];
    UpdateStringState updateRecordingVideoType =
        parameters['updateRecordingVideoType'];
    UpdateBooleanState updateRecordingVideoOptimized =
        parameters['updateRecordingVideoOptimized'];
    UpdateStringState updateRecordingDisplayType =
        parameters['updateRecordingDisplayType'];
    UpdateBooleanState updateRecordingAddHLS =
        parameters['updateRecordingAddHLS'];
    UpdateStringState updateRecordingBackgroundColor =
        parameters['updateRecordingBackgroundColor'];
    UpdateStringState updateRecordingNameTagsColor =
        parameters['updateRecordingNameTagsColor'];
    UpdateStringState updateRecordingOrientationVideo =
        parameters['updateRecordingOrientationVideo'];
    UpdateBooleanState updateRecordingAddText =
        parameters['updateRecordingAddText'];
    UpdateStringState updateRecordingCustomText =
        parameters['updateRecordingCustomText'];
    UpdateStringState updateRecordingCustomTextPosition =
        parameters['updateRecordingCustomTextPosition'];
    UpdateStringState updateRecordingCustomTextColor =
        parameters['updateRecordingCustomTextColor'];
    UpdateIntState updatePauseRecordCount =
        parameters['updatePauseRecordCount'];
    UpdateIntState updateRecordElapsedTime =
        parameters['updateRecordElapsedTime'];
    UpdateBooleanState updateRecordStarted = parameters['updateRecordStarted'];
    UpdateBooleanState updateRecordPaused = parameters['updateRecordPaused'];
    UpdateBooleanState updateCanLaunchRecord =
        parameters['updateCanLaunchRecord'];
    UpdateBooleanState updateRecordStopped = parameters['updateRecordStopped'];
    UpdateBooleanState updateIsTimerRunning =
        parameters['updateIsTimerRunning'];
    UpdateBooleanState updateCanPauseResume =
        parameters['updateCanPauseResume'];
    UpdateIntState updateRecordStartTime = parameters['updateRecordStartTime'];
    UpdateStringState updateRecordState = parameters['updateRecordState'];
    UpdateBooleanState updateRecordingNameTags =
        parameters['updateRecordingNameTags'];

    if (islevel != '2') {
      if (state == 'pause') {
        updateRecordStarted(true);
        updateRecordPaused(true);
        updateRecordState('yellow');
      } else if (state == 'stop') {
        updateRecordStarted(true);
        updateRecordStopped(true);
        updateRecordState('green');
      } else {
        updateRecordStarted(true);
        updateRecordPaused(false);
        updateRecordState('red');
      }
    } else {
      if (state == 'pause') {
        updateRecordState('yellow');
        if (userRecordingParam != null) {
          userRecordingParams = userRecordingParam;

          recordingMediaOptions =
              userRecordingParams['mainSpecs']['mediaOptions'];
          recordingAudioOptions =
              userRecordingParams['mainSpecs']['audioOptions'];
          recordingVideoOptions =
              userRecordingParams['mainSpecs']['videoOptions'];
          recordingVideoType = userRecordingParams['mainSpecs']['videoType'];
          recordingVideoOptimized =
              userRecordingParams['mainSpecs']['videoOptimized'];
          recordingDisplayType =
              userRecordingParams['mainSpecs']['recordingDisplayType'];
          recordingAddHLS = userRecordingParams['mainSpecs']['addHLS'];
          recordingNameTags = userRecordingParams['dispSpecs']['nameTags'];
          recordingBackgroundColor =
              userRecordingParams['dispSpecs']['backgroundColor'];
          recordingNameTagsColor =
              userRecordingParams['dispSpecs']['nameTagsColor'];
          recordingOrientationVideo =
              userRecordingParams['dispSpecs']['orientationVideo'];
          recordingAddText = userRecordingParams['textSpecs']['addText'];
          recordingCustomText = userRecordingParams['textSpecs']['customText'];
          recordingCustomTextPosition =
              userRecordingParams['textSpecs']['customTextPosition'];
          recordingCustomTextColor =
              userRecordingParams['textSpecs']['customTextColor'];

          updateUserRecordingParams(userRecordingParams);
          updateRecordingMediaOptions(recordingMediaOptions);
          updateRecordingAudioOptions(recordingAudioOptions);
          updateRecordingVideoOptions(recordingVideoOptions);
          updateRecordingVideoType(recordingVideoType);
          updateRecordingVideoOptimized(recordingVideoOptimized);
          updateRecordingDisplayType(recordingDisplayType);
          updateRecordingAddHLS(recordingAddHLS);
          updateRecordingNameTags(recordingNameTags);
          updateRecordingBackgroundColor(recordingBackgroundColor);
          updateRecordingNameTagsColor(recordingNameTagsColor);
          updateRecordingOrientationVideo(recordingOrientationVideo);
          updateRecordingAddText(recordingAddText);
          updateRecordingCustomText(recordingCustomText);
          updateRecordingCustomTextPosition(recordingCustomTextPosition);
          updateRecordingCustomTextColor(recordingCustomTextColor);

          pauseRecordCount = pauseCount!;
          updatePauseRecordCount(pauseRecordCount);

          recordElapsedTime = timeDone!;
          updateRecordElapsedTime(recordElapsedTime);

          recordStarted = true;
          recordPaused = true;
          canLaunchRecord = false;
          recordStopped = false;

          updateRecordStarted(recordStarted);
          updateRecordPaused(recordPaused);
          updateCanLaunchRecord(canLaunchRecord);
          updateRecordStopped(recordStopped);
          updateShowRecordButtons(true);

          isTimerRunning = false;
          canPauseResume = true;

          updateIsTimerRunning(isTimerRunning);
          updateCanPauseResume(canPauseResume);

          recordElapsedTime = (recordElapsedTime / 1000).floor();
          recordStartTime = (DateTime.now().millisecondsSinceEpoch ~/ 1000) -
              recordElapsedTime;
          updateRecordElapsedTime(recordElapsedTime);
          updateRecordStartTime(recordStartTime);

          String padNumber(int number) {
            return number.toString().padLeft(2, '0');
          }

          int hours = (recordElapsedTime / 3600).floor();
          int minutes = ((recordElapsedTime % 3600) / 60).floor();
          int seconds = recordElapsedTime % 60;
          String formattedTime =
              '${padNumber(hours)}:${padNumber(minutes)}:${padNumber(seconds)}';

          updateRecordingProgressTime(formattedTime);
        }
      } else if (state == 'stop') {
        recordStarted = true;
        recordStopped = true;
        canLaunchRecord = false;
        updateRecordStarted(recordStarted);
        updateRecordStopped(recordStopped);
        updateCanLaunchRecord(canLaunchRecord);
        updateShowRecordButtons(false);
        updateRecordState('green');
      } else {
        updateRecordState('red');
        updateRecordStarted(true);
        updateRecordPaused(false);
      }
    }
  } catch (error) {
    if (kDebugMode) {
      print("Error in recordingNotice: $error");
    }

    // throw Error("Failed to handle recording state and status.");
  }
}
