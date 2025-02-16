import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../methods/utils/sound_player.dart'
    show SoundPlayer, SoundPlayerOptions;
import '../../../types/types.dart' show EventType, UserRecordingParams;

// RecordingNoticeParameters class for holding update functions and recording configurations
abstract class RecordingNoticeParameters {
  // Core properties as abstract getters
  String get islevel;
  UserRecordingParams get userRecordingParams;
  int get recordElapsedTime;
  int? get recordStartTime;
  bool get recordStarted;
  bool get recordPaused;
  bool get canLaunchRecord;
  bool get recordStopped;
  bool get isTimerRunning;
  bool get canPauseResume;
  EventType get eventType;

  // Update functions as abstract getters returning functions
  void Function(String) get updateRecordingProgressTime;
  void Function(bool) get updateShowRecordButtons;
  void Function(UserRecordingParams) get updateUserRecordingParams;
  void Function(String) get updateRecordingMediaOptions;
  void Function(String) get updateRecordingAudioOptions;
  void Function(String) get updateRecordingVideoOptions;
  void Function(String) get updateRecordingVideoType;
  void Function(bool) get updateRecordingVideoOptimized;
  void Function(String) get updateRecordingDisplayType;
  void Function(bool) get updateRecordingAddHLS;
  void Function(bool) get updateRecordingNameTags;
  void Function(String) get updateRecordingBackgroundColor;
  void Function(String) get updateRecordingNameTagsColor;
  void Function(String) get updateRecordingOrientationVideo;
  void Function(bool) get updateRecordingAddText;
  void Function(String) get updateRecordingCustomText;
  void Function(String) get updateRecordingCustomTextPosition;
  void Function(String) get updateRecordingCustomTextColor;
  void Function(int) get updatePauseRecordCount;
  void Function(int) get updateRecordElapsedTime;
  void Function(int?) get updateRecordStartTime;
  void Function(bool) get updateRecordStarted;
  void Function(bool) get updateRecordPaused;
  void Function(bool) get updateCanLaunchRecord;
  void Function(bool) get updateRecordStopped;
  void Function(bool) get updateIsTimerRunning;
  void Function(bool) get updateCanPauseResume;
  void Function(String) get updateRecordState;

  // dynamic operator [](String key);
}

// RecordingNoticeOptions class to hold function parameters
class RecordingNoticeOptions {
  final String state;
  final UserRecordingParams? userRecordingParam;
  final int pauseCount;
  final int timeDone;
  final RecordingNoticeParameters parameters;

  RecordingNoticeOptions({
    required this.state,
    this.userRecordingParam,
    required this.pauseCount,
    required this.timeDone,
    required this.parameters,
  });
}

typedef RecordingNoticeType = Future<void> Function(
    RecordingNoticeOptions options);

/// Handles recording state changes and updates recording settings accordingly.
///
/// This function manages the recording state (e.g., start, pause, stop) and updates various parameters related to recording.
/// It accepts several parameters to customize and track recording settings, such as elapsed time, recording start time,
/// user recording settings, and other configuration options. Based on the `state` value, the function will update UI states
/// and initiate specific behavior.
///
/// Parameters:
/// - [parameters] (`Map<String, dynamic>`): A dictionary of recording-related properties, containing:
///   - `islevel` (String): The recording level.
///   - `userRecordingParams` (`Map<String, dynamic>`): Parameters for the user recording settings.
///   - `recordElapsedTime` (int): Total time elapsed during recording.
///   - `recordStartTime` (int): Start time of the recording.
///   - `recordStarted` (bool): Whether recording has started.
///   - `recordPaused` (bool): Whether recording is currently paused.
///   - `canLaunchRecord` (bool): If recording can be initiated.
///   - `recordStopped` (bool): If recording has been stopped.
///   - `isTimerRunning` (bool): If the timer is active.
///   - `canPauseResume` (bool): If pausing and resuming recording is allowed.
/// - [state] (String): The current state of the recording (e.g., "pause", "stop").
/// - [pauseCount] (int): Number of pauses made during the recording.
/// - [timeDone] (int): Total recording time that has been completed.
/// - [userRecordingParam] (`Map<String, dynamic`>?): Optional parameter for user-specific recording configuration.
///
/// Example usage:
/// ```dart
/// final parameters = {
///   'islevel': '1',
///   'recordElapsedTime': 0,
///   'recordStartTime': 0,
///   'recordStarted': false,
///   'recordPaused': false,
///   'canLaunchRecord': true,
///   'recordStopped': false,
///   'isTimerRunning': false,
///   'canPauseResume': true,
///   'updateRecordingProgressTime': (String time) { print("Recording time: $time"); },
///   'updateRecordState': (String state) { print("Recording state: $state"); },
///   // Additional update functions
/// };
///
/// RecordingNotice(
///   parameters: parameters,
///   timeDone: 3600,
///   pauseCount: 2,
///   state: "pause",
///   userRecordingParam: {
///     'mainSpecs': {
///       'mediaOptions': 'option1',
///       'audioOptions': 'option2',
///       'videoOptions': 'option3',
///       'videoType': 'HD'
///     },
///     'dispSpecs': {
///       'nameTags': true,
///       'backgroundColor': 'blue',
///       'orientationVideo': 'landscape'
///     },
///     'textSpecs': {
///       'addText': true,
///       'customText': 'Recording',
///       'customTextPosition': 'top-right',
///       'customTextColor': 'white'
///     }
///   },
/// );
/// ```
///
/// Returns:
/// - A [Future<void>] that completes once the recording state has been processed.

Future<void> recordingNotice(RecordingNoticeOptions options) async {
  final parameters = options.parameters;
  final state = options.state;
  final pauseCount = options.pauseCount;
  final timeDone = options.timeDone;
  int recordElapsedTime = parameters.recordElapsedTime;
  int? recordStartTime = parameters.recordStartTime ?? 0;

  try {
    if (parameters.islevel != '2') {
      if (state == 'pause') {
        parameters.updateRecordStarted(true);
        parameters.updateRecordPaused(true);
        parameters.updateRecordState('yellow');
        if (parameters.eventType != EventType.broadcast) {
          final option = SoundPlayerOptions(
            soundUrl: 'https://www.mediasfu.com/sounds/record-paused.mp3',
          );
          SoundPlayer.play(option);
        }
      } else if (state == 'stop') {
        parameters.updateRecordStarted(true);
        parameters.updateRecordStopped(true);
        parameters.updateRecordState('green');
        if (parameters.eventType != EventType.broadcast) {
          final option = SoundPlayerOptions(
            soundUrl: 'https://www.mediasfu.com/sounds/record-stopped.mp3',
          );
          SoundPlayer.play(option);
        }
      } else {
        parameters.updateRecordState('red');
        parameters.updateRecordStarted(true);
        parameters.updateRecordPaused(false);
        if (parameters.eventType != EventType.broadcast) {
          final option = SoundPlayerOptions(
            soundUrl: 'https://www.mediasfu.com/sounds/record-progress.mp3',
          );
          SoundPlayer.play(option);
        }
      }
    } else {
      if (state == 'pause' && options.userRecordingParam != null) {
        parameters.updateRecordState('yellow');
        // Assuming userRecordingParam is a map with the relevant keys as shown below
        final userRecordingParam = options.userRecordingParam!;
        parameters.updateUserRecordingParams(userRecordingParam);

        parameters.updateRecordingMediaOptions(
            userRecordingParam.mainSpecs.mediaOptions);
        parameters.updateRecordingAudioOptions(
            userRecordingParam.mainSpecs.audioOptions);
        parameters.updateRecordingVideoOptions(
            userRecordingParam.mainSpecs.videoOptions);
        parameters
            .updateRecordingVideoType(userRecordingParam.mainSpecs.videoType);
        parameters.updateRecordingVideoOptimized(
            userRecordingParam.mainSpecs.videoOptimized);
        parameters.updateRecordingDisplayType(
            userRecordingParam.mainSpecs.recordingDisplayType);
        parameters.updateRecordingAddHLS(userRecordingParam.mainSpecs.addHLS);
        parameters
            .updateRecordingNameTags(userRecordingParam.dispSpecs.nameTags);
        parameters.updateRecordingBackgroundColor(
            userRecordingParam.dispSpecs.backgroundColor);
        parameters.updateRecordingNameTagsColor(
            userRecordingParam.dispSpecs.nameTagsColor);
        parameters.updateRecordingOrientationVideo(
            userRecordingParam.dispSpecs.orientationVideo);
        parameters
            .updateRecordingAddText(userRecordingParam.textSpecs!.addText);
        parameters.updateRecordingCustomText(
            userRecordingParam.textSpecs!.customText!);
        parameters.updateRecordingCustomTextPosition(
            userRecordingParam.textSpecs!.customTextPosition!);
        parameters.updateRecordingCustomTextColor(
            userRecordingParam.textSpecs!.customTextColor!);

        parameters.updatePauseRecordCount(pauseCount);

        if (timeDone != 0) {
          recordElapsedTime = timeDone;
          recordElapsedTime = (recordElapsedTime / 1000).floor();
          recordStartTime = (DateTime.now().millisecondsSinceEpoch ~/ 1000) -
              recordElapsedTime;

          parameters.updateRecordElapsedTime(recordElapsedTime);
          parameters.updateRecordStartTime(recordStartTime);
        }

        parameters.updateRecordStarted(true);
        parameters.updateRecordPaused(true);
        parameters.updateCanLaunchRecord(false);
        parameters.updateRecordStopped(false);

        parameters.updateShowRecordButtons(true);

        parameters.updateIsTimerRunning(false);
        parameters.updateCanPauseResume(true);

        if (timeDone != 0) {
          parameters.updateRecordingProgressTime(
              formatElapsedTime(recordElapsedTime));
          parameters.updateRecordState('yellow');
        }

        final option = SoundPlayerOptions(
          soundUrl: 'https://www.mediasfu.com/sounds/record-paused.mp3',
        );
        SoundPlayer.play(option);
      } else if (state == 'stop') {
        parameters.updateRecordStarted(true);
        parameters.updateRecordStopped(true);
        parameters.updateCanLaunchRecord(false);
        parameters.updateShowRecordButtons(false);
        parameters.updateRecordState('green');
        final option = SoundPlayerOptions(
          soundUrl: 'https://www.mediasfu.com/sounds/record-stopped.mp3',
        );
        SoundPlayer.play(option);
      } else {
        parameters.updateRecordState('red');
        parameters.updateRecordStarted(true);
        parameters.updateRecordPaused(false);
        final option = SoundPlayerOptions(
          soundUrl: 'https://www.mediasfu.com/sounds/record-progress.mp3',
        );
        SoundPlayer.play(option);
      }
    }
  } catch (error) {
    if (kDebugMode) {
      print("Error in recordingNotice: $error");
    }

    // throw Error("Failed to handle recording state and status.");
  }
}

// Helper function to format elapsed time
String formatElapsedTime(int recordElapsedTime) {
  int hours = (recordElapsedTime ~/ 3600);
  int minutes = ((recordElapsedTime % 3600) ~/ 60);
  int seconds = recordElapsedTime % 60;
  return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}
