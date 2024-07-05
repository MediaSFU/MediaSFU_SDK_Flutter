import 'package:flutter/foundation.dart';

/// Confirms the recording based on the provided parameters.
///
/// The [parameters] map contains various options and settings related to the recording.
/// The function performs validation checks on the parameters and displays appropriate alerts if any invalid options are selected.
/// It also updates the recording display type and other related settings based on the meeting display type.
///
/// The function uses the following callback functions to display alerts and update recording settings:
/// - [showAlert]: A function that displays an alert with the specified message, type, and duration.
/// - [updateRecordingDisplayType]: A function that updates the recording display type.
/// - [updateRecordingVideoOptimized]: A function that updates the recording video optimization setting.
/// - [updateRecordingVideoParticipantsFullRoomSupport]: A function that updates the recording video participants full room support setting.
/// - [updateRecordingAllParticipantsSupport]: A function that updates the recording all participants support setting.
/// - [updateRecordingVideoParticipantsSupport]: A function that updates the recording video participants support setting.
/// - [updateRecordingSupportForOtherOrientation]: A function that updates the recording support for other orientation setting.
/// - [updateRecordingPreferredOrientation]: A function that updates the recording preferred orientation setting.
/// - [updateRecordingMultiFormatsSupport]: A function that updates the recording multi formats support setting.
/// - [updateUserRecordingParams]: A function that updates the user recording parameters.
/// - [updateConfirmedToRecord]: A function that updates the confirmed to record setting.
///
/// The function returns void.

typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

typedef UpdateRecordingDisplayType = void Function(String displayType);
typedef UpdateRecordingVideoOptimized = void Function(bool optimized);
typedef UpdateRecordingVideoParticipantsFullRoomSupport = void Function(
    bool support);
typedef UpdateRecordingAllParticipantsSupport = void Function(bool support);
typedef UpdateRecordingVideoParticipantsSupport = void Function(bool support);
typedef UpdateRecordingSupportForOtherOrientation = void Function(bool support);
typedef UpdateRecordingPreferredOrientation = void Function(String orientation);
typedef UpdateRecordingMultiFormatsSupport = void Function(bool support);
typedef UpdateUserRecordingParams = void Function(Map<String, dynamic> params);
typedef UpdateConfirmedToRecord = void Function(bool confirmed);
typedef UpdateIsRecordingModalVisible = void Function(bool visible);

void confirmRecording({required Map<String, dynamic> parameters}) {
  try {
    // Extract variables from the parameters object
    String recordingMediaOptions = parameters['recordingMediaOptions'];
    String recordingAudioOptions = parameters['recordingAudioOptions'];
    String recordingVideoOptions = parameters['recordingVideoOptions'];
    String recordingVideoType = parameters['recordingVideoType'];
    String recordingDisplayType = parameters['recordingDisplayType'];
    bool recordingNameTags = parameters['recordingNameTags'];
    String recordingBackgroundColor = parameters['recordingBackgroundColor'];
    String recordingNameTagsColor = parameters['recordingNameTagsColor'];
    String recordingOrientationVideo = parameters['recordingOrientationVideo'];
    bool recordingAddHLS = parameters['recordingAddHLS'];
    bool recordingAddText = parameters['recordingAddText'];
    String recordingCustomText = parameters['recordingCustomText'];
    String recordingCustomTextPosition =
        parameters['recordingCustomTextPosition'];
    String recordingCustomTextColor = parameters['recordingCustomTextColor'];

    String meetingDisplayType = parameters['meetingDisplayType'];
    bool recordingVideoParticipantsFullRoomSupport =
        parameters['recordingVideoParticipantsFullRoomSupport'];
    bool recordingAllParticipantsSupport =
        parameters['recordingAllParticipantsSupport'];
    bool recordingVideoParticipantsSupport =
        parameters['recordingVideoParticipantsSupport'];
    bool recordingSupportForOtherOrientation =
        parameters['recordingSupportForOtherOrientation'];
    String recordingPreferredOrientation =
        parameters['recordingPreferredOrientation'];
    bool recordingMultiFormatsSupport =
        parameters['recordingMultiFormatsSupport'];
    bool recordingVideoOptimized = parameters['recordingVideoOptimized'];
    bool recordingAllParticipantsFullRoomSupport =
        parameters['recordingAllParticipantsFullRoomSupport'];
    bool meetingVideoOptimized = parameters['meetingVideoOptimized'];
    String eventType = parameters['eventType'];
    bool breakOutRoomStarted = parameters['breakOutRoomStarted'] ?? false;
    bool breakOutRoomEnded = parameters['breakOutRoomEnded'] ?? false;

    // Extract variables from the parameters object
    final ShowAlert? showAlert = parameters['showAlert'];
    final UpdateRecordingDisplayType updateRecordingDisplayType =
        parameters['updateRecordingDisplayType'];
    final UpdateRecordingVideoOptimized updateRecordingVideoOptimized =
        parameters['updateRecordingVideoOptimized'];
    final UpdateRecordingVideoParticipantsFullRoomSupport
        updateRecordingVideoParticipantsFullRoomSupport =
        parameters['updateRecordingVideoParticipantsFullRoomSupport'];
    final UpdateRecordingAllParticipantsSupport
        updateRecordingAllParticipantsSupport =
        parameters['updateRecordingAllParticipantsSupport'];
    final UpdateRecordingVideoParticipantsSupport
        updateRecordingVideoParticipantsSupport =
        parameters['updateRecordingVideoParticipantsSupport'];
    final UpdateRecordingSupportForOtherOrientation
        updateRecordingSupportForOtherOrientation =
        parameters['updateRecordingSupportForOtherOrientation'];
    final UpdateRecordingPreferredOrientation
        updateRecordingPreferredOrientation =
        parameters['updateRecordingPreferredOrientation'];
    final UpdateRecordingMultiFormatsSupport
        updateRecordingMultiFormatsSupport =
        parameters['updateRecordingMultiFormatsSupport'];
    final UpdateUserRecordingParams updateUserRecordingParams =
        parameters['updateUserRecordingParams'];
    final UpdateConfirmedToRecord updateConfirmedToRecord =
        parameters['updateConfirmedToRecord'];

    final String mediaOptions = recordingMediaOptions;

// Other variables not provided in the guide
    final String selectedRecordOption = recordingDisplayType;

// Additional logic similar to the provided guide
// recordingVideoParticipantsFullRoomSupport = minigrid and main video
    if (eventType != 'broadcast') {
      if (!recordingVideoParticipantsFullRoomSupport &&
          recordingVideoOptions == 'all' &&
          mediaOptions == 'video') {
        if (meetingDisplayType == 'all') {
          if (breakOutRoomStarted && !breakOutRoomEnded) {
          } else {
            if (showAlert != null) {
              showAlert(
                message:
                    'You are not allowed to record videos of all participants; change the meeting display type to video or video optimized.',
                type: 'danger',
                duration: 3000,
              );
            }
            return;
          }
        }
      }

      // recordingAllParticipantsSupport  = others other than host screen (video + audio)
      if (!recordingAllParticipantsSupport && recordingVideoOptions == 'all') {
        if (showAlert != null) {
          showAlert(
            message: 'You are only allowed to record yourself.',
            type: 'danger',
            duration: 3000,
          );
        }
        return;
      }

      // recordingVideoParticipantsSupport (maingrid + non-host screenshare person)
      if (!recordingVideoParticipantsSupport &&
          recordingDisplayType == 'video') {
        if (showAlert != null) {
          showAlert(
            message: 'You are not allowed to record other video participants.',
            type: 'danger',
            duration: 3000,
          );
        }
        return;
      }
    }

    if (!recordingSupportForOtherOrientation &&
        recordingOrientationVideo == 'all') {
      if (showAlert != null) {
        showAlert(
          message: 'You are not allowed to record all orientations.',
          type: 'danger',
          duration: 3000,
        );
      }
      return;
    }

    if (recordingPreferredOrientation == 'landscape' &&
        recordingOrientationVideo == 'portrait' &&
        !recordingSupportForOtherOrientation) {
      if (showAlert != null) {
        showAlert(
          message: 'You are not allowed to record portrait orientation.',
          type: 'danger',
          duration: 3000,
        );
      }
      return;
    } else if (recordingPreferredOrientation == 'portrait' &&
        recordingOrientationVideo == 'landscape' &&
        !recordingSupportForOtherOrientation) {
      if (showAlert != null) {
        showAlert(
          message: 'You are not allowed to record landscape orientation.',
          type: 'danger',
          duration: 3000,
        );
      }
      return;
    }

    if (!recordingMultiFormatsSupport && recordingVideoType == 'all') {
      if (showAlert != null) {
        showAlert(
          message: 'You are not allowed to record all formats.',
          type: 'danger',
          duration: 3000,
        );
      }
      return;
    }

    if (eventType != 'broadcast') {
      if (recordingMediaOptions == 'video') {
        if (meetingDisplayType == 'media') {
          if (recordingDisplayType == 'all') {
            if (showAlert != null) {
              showAlert(
                message:
                    'Recording display type can be either video, video optimized, or media when meeting display type is media.',
                type: 'danger',
                duration: 3000,
              );
            }
            recordingDisplayType = meetingDisplayType;
            return;
          }
        } else if (meetingDisplayType == 'video') {
          if (recordingDisplayType == 'all' ||
              recordingDisplayType == 'media') {
            if (showAlert != null) {
              showAlert(
                message:
                    'Recording display type can be either video or video optimized when meeting display type is video.',
                type: 'danger',
                duration: 3000,
              );
            }
            recordingDisplayType = meetingDisplayType;
            return;
          }

          if (meetingVideoOptimized && !recordingVideoOptimized) {
            if (showAlert != null) {
              showAlert(
                message:
                    'Recording display type can be only video optimized when meeting display type is video optimized.',
                type: 'danger',
                duration: 3000,
              );
            }
            recordingVideoOptimized = meetingVideoOptimized;
            return;
          }
        }
      } else {
        if (recordingDisplayType == 'all' || recordingDisplayType == 'media') {
        } else {
          recordingDisplayType = 'media';
        }
        recordingVideoOptimized = false;
      }
    }

    if (recordingDisplayType == 'all' &&
        !recordingAllParticipantsFullRoomSupport) {
      if (showAlert != null) {
        showAlert(
          message: 'You can only record all participants with media.',
          type: 'danger',
          duration: 3000,
        );
      }
      return;
    }

    // Additional logic similar to the provided guide
    // Construct userRecordingParams object
    final Map<String, dynamic> userRecordingParams = {
      'mainSpecs': {
        'mediaOptions': recordingMediaOptions,
        'audioOptions': recordingAudioOptions,
        'videoOptions': recordingVideoOptions,
        'videoType': recordingVideoType,
        'videoOptimized': recordingVideoOptimized,
        'recordingDisplayType': recordingDisplayType,
        'addHLS': recordingAddHLS,
      },
      'dispSpecs': {
        'nameTags': recordingNameTags,
        'backgroundColor': recordingBackgroundColor,
        'nameTagsColor': recordingNameTagsColor,
        'orientationVideo': recordingOrientationVideo,
      },
      'textSpecs': {
        'addText': recordingAddText,
        'customText': recordingCustomText,
        'customTextPosition': recordingCustomTextPosition,
        'customTextColor': recordingCustomTextColor,
      },
    };

    // Update state variables based on the logic
    updateUserRecordingParams(userRecordingParams);
    updateConfirmedToRecord(true);
    updateRecordingDisplayType(selectedRecordOption);
    updateRecordingVideoOptimized(recordingVideoOptimized);
    updateRecordingVideoParticipantsFullRoomSupport(
        recordingVideoParticipantsFullRoomSupport);
    updateRecordingAllParticipantsSupport(recordingAllParticipantsSupport);
    updateRecordingVideoParticipantsSupport(recordingVideoParticipantsSupport);
    updateRecordingSupportForOtherOrientation(
        recordingSupportForOtherOrientation);
    updateRecordingPreferredOrientation(recordingPreferredOrientation);
    updateRecordingMultiFormatsSupport(recordingMultiFormatsSupport);
  } catch (error) {
    if (kDebugMode) {
      print('Error in confirmRecording: $error');
    }
  }
}
