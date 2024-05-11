// ignore_for_file: library_prefixes, non_constant_identifier_names, empty_catches

import 'package:flutter/foundation.dart';
import '../../methods/utils/producer/video_capture_constraints.dart'
    as constraints;
import '../../methods/utils/producer/h_params.dart' as hostParams_;
import '../../methods/utils/producer/v_params.dart' as videoParams_;
import '../../methods/utils/producer/screen_params.dart' as screenParams_;
import '../../methods/utils/producer/a_params.dart' as audioParams_;

///
/// This file contains the definition of the `updateRoomParametersClient` function and various typedefs used as parameters.
///
/// The `updateRoomParametersClient` function is responsible for updating the room parameters based on the provided `parameters` map.
/// It takes in a `parameters` map that contains various update functions as values.
/// The function extracts the required data from the `parameters` map and calls the corresponding update functions to update the room parameters.
///
/// The typedefs defined in this file represent the various update functions used by the `updateRoomParametersClient` function.
/// Each typedef represents a specific type of update function and is used to define the type of the corresponding value in the `parameters` map.
/// These update functions are responsible for updating specific room parameters based on the provided values.
///
/// Note: This file also imports various utility files and defines a `ShowAlert` typedef used for showing alerts.

typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

typedef UpdateRtpCapabilities = void Function(Map<String, dynamic>);
typedef UpdateRoomRecvIPs = void Function(List<dynamic>);
typedef UpdateMeetingRoomParams = void Function(Map<String, dynamic>);
typedef UpdateItemPageLimit = void Function(int);
typedef UpdateAudioOnlyRoom = void Function(bool);
typedef UpdateAddForBasic = void Function(bool);
typedef UpdateScreenPageLimit = void Function(int);
typedef UpdateShareScreenStarted = void Function(bool);
typedef UpdateShared = void Function(bool);
typedef UpdateTargetOrientation = void Function(String);
typedef UpdateVidCons = void Function(Map<String, dynamic>);
typedef UpdateFrameRate = void Function(int);
typedef UpdateAdminPasscode = void Function(String);
typedef UpdateEventType = void Function(String);
typedef UpdateYouAreCoHost = void Function(bool);
typedef UpdateAutoWave = void Function(bool);
typedef UpdateForceFullDisplay = void Function(bool);
typedef UpdateChatSetting = void Function(String);
typedef UpdateMeetingDisplayType = void Function(String);
typedef UpdateAudioSetting = void Function(String);
typedef UpdateVideoSetting = void Function(String);
typedef UpdateScreenshareSetting = void Function(String);
typedef UpdateHParams = void Function(Map<String, dynamic>);
typedef UpdateVParams = void Function(Map<String, dynamic>);
typedef UpdateScreenParams = void Function(Map<String, dynamic>);
typedef UpdateAParams = void Function(Map<String, dynamic>);
typedef UpdateRecordingAudioPausesLimit = void Function(int);
typedef UpdateRecordingAudioPausesCount = void Function(int);
typedef UpdateRecordingAudioSupport = void Function(bool);
typedef UpdateRecordingAudioPeopleLimit = void Function(int);
typedef UpdateRecordingAudioParticipantsTimeLimit = void Function(int);
typedef UpdateRecordingVideoPausesCount = void Function(int);
typedef UpdateRecordingVideoPausesLimit = void Function(int);
typedef UpdateRecordingVideoSupport = void Function(bool);
typedef UpdateRecordingVideoPeopleLimit = void Function(int);
typedef UpdateRecordingVideoParticipantsTimeLimit = void Function(int);
typedef UpdateRecordingAllParticipantsSupport = void Function(bool);
typedef UpdateRecordingVideoParticipantsSupport = void Function(bool);
typedef UpdateRecordingAllParticipantsFullRoomSupport = void Function(bool);
typedef UpdateRecordingVideoParticipantsFullRoomSupport = void Function(bool);
typedef UpdateRecordingPreferredOrientation = void Function(String);
typedef UpdateRecordingSupportForOtherOrientation = void Function(bool);
typedef UpdateRecordingMultiFormatsSupport = void Function(bool);
typedef UpdateMainHeightWidth = void Function(int);

void updateRoomParametersClient({
  required Map<String, dynamic> parameters,
}) {
  try {
    final Map<String, dynamic> data = parameters['data'];
    final UpdateRtpCapabilities updateRtpCapabilities =
        parameters['updateRtpCapabilities'];
    final UpdateAdminPasscode updateAdminPasscode =
        parameters['updateAdminPasscode'];
    final UpdateRoomRecvIPs updateRoomRecvIPs = parameters['updateRoomRecvIPs'];
    final UpdateMeetingRoomParams updateMeetingRoomParams =
        parameters['updateMeetingRoomParams'];
    final UpdateRecordingAudioPausesLimit updateRecordingAudioPausesLimit =
        parameters['updateRecordingAudioPausesLimit'];
    final UpdateRecordingAudioPausesCount updateRecordingAudioPausesCount =
        parameters['updateRecordingAudioPausesCount'];
    final UpdateRecordingAudioSupport updateRecordingAudioSupport =
        parameters['updateRecordingAudioSupport'];
    final UpdateRecordingAudioPeopleLimit updateRecordingAudioPeopleLimit =
        parameters['updateRecordingAudioPeopleLimit'];
    final UpdateRecordingAudioParticipantsTimeLimit
        updateRecordingAudioParticipantsTimeLimit =
        parameters['updateRecordingAudioParticipantsTimeLimit'];
    final UpdateRecordingVideoPausesCount updateRecordingVideoPausesCount =
        parameters['updateRecordingVideoPausesCount'];
    final UpdateRecordingVideoPausesLimit updateRecordingVideoPausesLimit =
        parameters['updateRecordingVideoPausesLimit'];
    final UpdateRecordingVideoSupport updateRecordingVideoSupport =
        parameters['updateRecordingVideoSupport'];
    final UpdateRecordingVideoPeopleLimit updateRecordingVideoPeopleLimit =
        parameters['updateRecordingVideoPeopleLimit'];
    final UpdateRecordingVideoParticipantsTimeLimit
        updateRecordingVideoParticipantsTimeLimit =
        parameters['updateRecordingVideoParticipantsTimeLimit'];
    final UpdateRecordingAllParticipantsSupport
        updateRecordingAllParticipantsSupport =
        parameters['updateRecordingAllParticipantsSupport'];
    final UpdateRecordingVideoParticipantsSupport
        updateRecordingVideoParticipantsSupport =
        parameters['updateRecordingVideoParticipantsSupport'];
    final UpdateRecordingAllParticipantsFullRoomSupport
        updateRecordingAllParticipantsFullRoomSupport =
        parameters['updateRecordingAllParticipantsFullRoomSupport'];
    final UpdateRecordingVideoParticipantsFullRoomSupport
        updateRecordingVideoParticipantsFullRoomSupport =
        parameters['updateRecordingVideoParticipantsFullRoomSupport'];
    final UpdateRecordingPreferredOrientation
        updateRecordingPreferredOrientation =
        parameters['updateRecordingPreferredOrientation'];
    final UpdateRecordingSupportForOtherOrientation
        updateRecordingSupportForOtherOrientation =
        parameters['updateRecordingSupportForOtherOrientation'];
    final UpdateRecordingMultiFormatsSupport
        updateRecordingMultiFormatsSupport =
        parameters['updateRecordingMultiFormatsSupport'];

    final UpdateMainHeightWidth updateMainHeightWidth =
        parameters['updateMainHeightWidth'];

    final UpdateItemPageLimit updateItemPageLimit =
        parameters['updateItemPageLimit'];
    final UpdateEventType updateEventType = parameters['updateEventType'];
    final UpdateYouAreCoHost updateYouAreCoHost =
        parameters['updateYouAreCoHost'];
    final UpdateAutoWave updateAutoWave = parameters['updateAutoWave'];
    final UpdateForceFullDisplay updateForceFullDisplay =
        parameters['updateForceFullDisplay'];
    final UpdateChatSetting updateChatSetting = parameters['updateChatSetting'];
    final UpdateMeetingDisplayType updateMeetingDisplayType =
        parameters['updateMeetingDisplayType'];
    final UpdateAudioSetting updateAudioSetting =
        parameters['updateAudioSetting'];
    final UpdateVideoSetting updateVideoSetting =
        parameters['updateVideoSetting'];
    final UpdateScreenshareSetting updateScreenshareSetting =
        parameters['updateScreenshareSetting'];
    final UpdateAudioOnlyRoom updateAudioOnlyRoom =
        parameters['updateAudioOnlyRoom'];
    final UpdateAddForBasic updateAddForBasic = parameters['updateAddForBasic'];
    final UpdateScreenPageLimit updateScreenPageLimit =
        parameters['updateScreenPageLimit'];
    final UpdateVidCons updateVidCons = parameters['updateVidCons'];
    final UpdateFrameRate updateFrameRate = parameters['updateFrameRate'];
    final UpdateHParams updateHParams = parameters['updateHParams'];
    final UpdateVParams updateVParams = parameters['updateVParams'];
    final UpdateScreenParams updateScreenParams =
        parameters['updateScreenParams'];
    final UpdateAParams updateAParams = parameters['updateAParams'];

    if (data['rtpCapabilities'] == null) {
      final ShowAlert? showAlert = parameters['showAlert'];
      if (showAlert != null) {
        showAlert(
          message:
              'Sorry, you are not allowed to join this room. ${data['reason']}',
          type: 'danger',
          duration: 3000,
        );
      }
    } else {
      updateRtpCapabilities(data['rtpCapabilities']);
      updateAdminPasscode(data['secureCode']);
      updateRoomRecvIPs(data['roomRecvIPs']);
      updateMeetingRoomParams(data['meetingRoomParams']);

      // Update recording values
      updateRecordingAudioPausesLimit(
          data['recordingParams']['recordingAudioPausesLimit']);
      updateRecordingAudioPausesCount(
          data['recordingParams']['recordingAudioPausesCount'] ?? 0);
      updateRecordingAudioSupport(
          data['recordingParams']['recordingAudioSupport']);
      updateRecordingAudioPeopleLimit(
          data['recordingParams']['recordingAudioPeopleLimit']);
      updateRecordingAudioParticipantsTimeLimit(
          data['recordingParams']['recordingAudioParticipantsTimeLimit']);
      updateRecordingVideoPausesCount(
          data['recordingParams']['recordingVideoPausesCount'] ?? 0);
      updateRecordingVideoPausesLimit(
          data['recordingParams']['recordingVideoPausesLimit']);
      updateRecordingVideoSupport(
          data['recordingParams']['recordingVideoSupport']);
      updateRecordingVideoPeopleLimit(
          data['recordingParams']['recordingVideoPeopleLimit']);
      updateRecordingVideoParticipantsTimeLimit(
          data['recordingParams']['recordingVideoParticipantsTimeLimit']);
      updateRecordingAllParticipantsSupport(
          data['recordingParams']['recordingAllParticipantsSupport']);
      updateRecordingVideoParticipantsSupport(
          data['recordingParams']['recordingVideoParticipantsSupport']);
      updateRecordingAllParticipantsFullRoomSupport(
          data['recordingParams']['recordingAllParticipantsFullRoomSupport']);
      updateRecordingVideoParticipantsFullRoomSupport(
          data['recordingParams']['recordingVideoParticipantsFullRoomSupport']);
      updateRecordingPreferredOrientation(
          data['recordingParams']['recordingPreferredOrientation']);
      updateRecordingSupportForOtherOrientation(
          data['recordingParams']['recordingSupportForOtherOrientation']);
      updateRecordingMultiFormatsSupport(
          data['recordingParams']['recordingMultiFormatsSupport']);

      // Update other values
      updateItemPageLimit(data['meetingRoomParams']['itemPageLimit']);
      updateEventType(data['meetingRoomParams']['type']);

      if (data['meetingRoomParams']['type'] == 'chat' &&
          parameters['islevel'] != '2') {
        updateYouAreCoHost(true);
      }

      if (data['meetingRoomParams']['type'] == 'chat' ||
          data['meetingRoomParams']['type'] == 'broadcast') {
        updateAutoWave(false);
        updateMeetingDisplayType('all');
        updateForceFullDisplay(true);
        updateChatSetting(data['meetingRoomParams']['chatSetting']);
      }

      updateAudioSetting(data['meetingRoomParams']['audioSetting']);
      updateVideoSetting(data['meetingRoomParams']['videoSetting']);
      updateScreenshareSetting(data['meetingRoomParams']['screenshareSetting']);
      updateChatSetting(data['meetingRoomParams']['chatSetting']);

      if (data['meetingRoomParams']['mediaType'] == 'video') {
        updateAudioOnlyRoom(false);
      } else {
        updateAudioOnlyRoom(true);
      }

      if (data['meetingRoomParams']['type'] == 'chat' ||
          data['meetingRoomParams']['type'] == 'broadcast') {
        if (data['meetingRoomParams']['type'] == 'broadcast') {
          updateAddForBasic(true);
          updateItemPageLimit(1);
        } else {
          updateAddForBasic(false);
          updateItemPageLimit(2);
        }
      } else if (data['meetingRoomParams']['type'] == 'conference') {
        if (parameters['shared'] || parameters['shareScreenStarted']) {
          updateMainHeightWidth(100);
        } else {
          updateMainHeightWidth(0);
        }
      }

      updateScreenPageLimit(data['meetingRoomParams']['itemPageLimit']);

      // Assign resolution and orientation
      String targetOrientation;
      String targetResolution;
      if (parameters['islevel'] == '2') {
        targetOrientation = data['meetingRoomParams']['targetOrientationHost'];
        targetResolution = data['meetingRoomParams']['targetResolutionHost'];
      } else {
        targetOrientation = data['meetingRoomParams']['targetOrientation'];
        targetResolution = data['meetingRoomParams']['targetResolution'];
      }

      Map<String, int> QnHDCons = constraints.qnHDCons;
      Map<String, int> sdCons = constraints.sdCons;
      Map<String, int> hdCons = constraints.hdCons;
      Map<String, int> QnHDConsPort = constraints.qnHDConsPort;
      Map<String, int> sdConsPort = constraints.sdConsPort;
      Map<String, int> hdConsPort = constraints.hdConsPort;
      Map<String, int> QnHDConsNeu = constraints.qnHDConsNeu;
      Map<String, int> sdConsNeu = constraints.sdConsNeu;
      Map<String, int> hdConsNeu = constraints.hdConsNeu;
      int QnHDFrameRate = constraints.qnHDFrameRate;
      int sdFrameRate = constraints.sdFrameRate;
      int hdFrameRate = constraints.hdFrameRate;

      Map<String, dynamic> hostParams = hostParams_.hParams;
      Map<String, dynamic> videoParams = videoParams_.vParams;
      Map<String, dynamic> screenParams = screenParams_.screenParams;
      Map<String, dynamic> audioParams = audioParams_.aParams;

      // Assign media capture constraints
      Map<String, int> vdCons;
      if (targetOrientation == 'landscape') {
        if (targetResolution == 'hd') {
          vdCons = hdCons;
        } else if (targetResolution == 'QnHD') {
          vdCons = QnHDCons;
        } else {
          vdCons = sdCons;
        }
      } else if (targetOrientation == 'neutral') {
        if (targetResolution == 'hd') {
          vdCons = hdConsNeu;
        } else if (targetResolution == 'QnHD') {
          vdCons = QnHDConsNeu;
        } else {
          vdCons = sdConsNeu;
        }
      } else {
        if (targetResolution == 'hd') {
          vdCons = hdConsPort;
        } else if (targetResolution == 'QnHD') {
          vdCons = QnHDConsPort;
        } else {
          vdCons = sdConsPort;
        }
      }

      // Assign frame rate
      int frameRate = sdFrameRate;
      Map<String, dynamic> hParams =
          Map.of(parameters['hParams'] ?? hostParams);
      Map<String, dynamic> vParams =
          Map.of(parameters['vParams'] ?? videoParams);
      screenParams = Map.of(parameters['screenParams'] ?? screenParams);
      Map<String, dynamic> aParams =
          Map.of(parameters['aParams'] ?? audioParams);

      Map<String, dynamic> tempHParam = {};
      Map<String, dynamic> tempVParam = {};

      if (targetResolution == 'hd') {
        frameRate = hdFrameRate;

        // Create a new list to hold updated encodings
        List<Map<String, dynamic>> updatedHEncodings = [];

        hParams['encodings'].forEach((encoding) {
          tempVParam = {...encoding};
          if (encoding['maxBitrate'] != null) {
            tempVParam = {
              ...tempVParam,
              'maxBitrate': encoding['maxBitrate'] * 4,
              'initialAvailableBitrate':
                  encoding['initialAvailableBitrate'] * 4,
            };
          }

          // Add updated encoding to the new list
          updatedHEncodings.add(tempVParam);
        });

        // Update hParams with the new list of encodings
        hParams['encodings'] = updatedHEncodings;

        // Similarly update vParams
        List<Map<String, dynamic>> updatedVEncodings = [];
        vParams['encodings'].forEach((encoding) {
          tempVParam = {...encoding};
          if (encoding['maxBitrate'] != null) {
            tempVParam = {
              ...tempVParam,
              'maxBitrate': encoding['maxBitrate'] * 4,
              'initialAvailableBitrate':
                  encoding['initialAvailableBitrate'] * 4,
            };
          }
          updatedVEncodings.add(tempVParam);
        });
        vParams['encodings'] = updatedVEncodings;
      } else if (targetResolution == 'QnHD') {
        frameRate = QnHDFrameRate;

        List<Map<String, dynamic>> updatedVEncodings = [];
        vParams['encodings'].forEach((encoding) {
          tempVParam = {...encoding};
          if (encoding['maxBitrate'] != null) {
            tempVParam = {
              ...tempVParam,
              'maxBitrate': (encoding['maxBitrate'] * 0.25).floorToDouble(),
              'minBitrate': (encoding['minBitrate'] * 0.25).floorToDouble(),
              'initialAvailableBitrate':
                  (encoding['initialAvailableBitrate'] * 0.25).floorToDouble(),
            };
          }
          updatedVEncodings.add(tempVParam);
        });
        vParams['encodings'] = updatedVEncodings;

        List<Map<String, dynamic>> updatedHEncodings = [];
        hParams['encodings'].forEach((encoding) {
          tempHParam = {...encoding};
          if (encoding['maxBitrate'] != null) {
            tempHParam = {
              ...tempHParam,
              'maxBitrate': (encoding['maxBitrate'] * 0.25).floorToDouble(),
              'minBitrate': (encoding['minBitrate'] * 0.25).floorToDouble(),
              'initialAvailableBitrate':
                  (encoding['initialAvailableBitrate'] * 0.25).floorToDouble(),
            };
          }
          updatedHEncodings.add(tempHParam);
        });
        hParams['encodings'] = updatedHEncodings;

        // Update codecOptions directly since it's a single map
        hParams['codecOptions'] = {
          ...hParams['codecOptions'],
          'videoGoogleStartBitrate':
              (hParams['codecOptions']['videoGoogleStartBitrate'] * 0.25)
                  .floorToDouble(),
        };
        vParams['codecOptions'] = {
          ...vParams['codecOptions'],
          'videoGoogleStartBitrate':
              vParams['codecOptions']['videoGoogleStartBitrate'] * 0.25,
        };
      }

      Map<String, dynamic> tempVParams = {};
      Map<String, dynamic> tempHParams = {};

      if (data['recordingParams']['recordingVideoSupport']) {
        List<Map<String, dynamic>> updatedVEncodings = [];
        vParams['encodings'].forEach((encoding) {
          tempVParams = {...encoding};
          if (encoding['maxBitrate'] != null) {
            tempVParams = {
              ...tempVParams,
              'maxBitrate': encoding['maxBitrate'] * 1.2,
              'minBitrate': encoding['minBitrate'] * 1.2,
              'initialAvailableBitrate':
                  encoding['initialAvailableBitrate'] * 1.2,
            };
          }
          updatedVEncodings.add(tempVParams);
        });
        vParams['encodings'] = updatedVEncodings;

        List<Map<String, dynamic>> updatedHEncodings = [];
        hParams['encodings'].forEach((encoding) {
          tempHParams = {...encoding};
          if (encoding['maxBitrate'] != null) {
            tempHParams = {
              ...tempHParams,
              'maxBitrate': (encoding['maxBitrate'] * 1.2).floorToDouble(),
              'minBitrate': (encoding['minBitrate'] * 1.2).floorToDouble(),
              'initialAvailableBitrate':
                  (encoding['initialAvailableBitrate'] * 1.2).floorToDouble(),
            };
          }
          updatedHEncodings.add(tempHParams);
        });
        hParams['encodings'] = updatedHEncodings;

        // Update codecOptions directly since it's a single map
        hParams['codecOptions'] = {
          ...hParams['codecOptions'],
          'videoGoogleStartBitrate':
              (hParams['codecOptions']['videoGoogleStartBitrate'] * 1.2)
                  .floorToDouble(),
        };
        vParams['codecOptions'] = {
          ...vParams['codecOptions'],
          'videoGoogleStartBitrate':
              vParams['codecOptions']['videoGoogleStartBitrate'] * 1.2,
        };
      }

      // Update the new parameters
      updateVidCons(vdCons);
      updateFrameRate(frameRate);
      updateHParams(hParams);
      updateVParams(vParams);
      updateScreenParams(screenParams);
      updateAParams(aParams);
    }
  } catch (error) {
    // Print the error along with the stack trace
    if (kDebugMode) {
      // print('Update room parameters error: $error');
    }
    // print('Stack trace: $stackTrace');
    try {
      final ShowAlert? showAlert = parameters['showAlert'];
      if (showAlert != null) {
        showAlert(
          message: error.toString(),
          type: 'danger',
          duration: 3000,
        );
      }
    } catch (error) {}
  }
}
