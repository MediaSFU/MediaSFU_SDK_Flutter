// ignore_for_file: library_prefixes, non_constant_identifier_names, empty_catches

import 'package:flutter/foundation.dart';
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';
import '../../methods/utils/producer/video_capture_constraints.dart'
    as constraints;
import '../../methods/utils/producer/h_params.dart' as hostParams_;
import '../../methods/utils/producer/v_params.dart' as videoParams_;
import '../../methods/utils/producer/screen_params.dart' as screenParams_;
import '../../methods/utils/producer/a_params.dart' as audioParams_;
import '../../types/types.dart'
    show
        MeetingRoomParams,
        VidCons,
        ShowAlert,
        ResponseJoinRoom,
        EventType,
        ProducerOptionsType;

/// Type definitions for update functions
typedef UpdateRtpCapabilities = void Function(RtpCapabilities?);
typedef UpdateRoomRecvIPs = void Function(List<String>);
typedef UpdateMeetingRoomParams = void Function(MeetingRoomParams?);
typedef UpdateItemPageLimit = void Function(int);
typedef UpdateAudioOnlyRoom = void Function(bool);
typedef UpdateAddForBasic = void Function(bool);
typedef UpdateScreenPageLimit = void Function(int);
typedef UpdateVidCons = void Function(VidCons);
typedef UpdateFrameRate = void Function(int);
typedef UpdateAdminPasscode = void Function(String);
typedef UpdateEventType = void Function(EventType);
typedef UpdateYouAreCoHost = void Function(bool);
typedef UpdateAutoWave = void Function(bool);
typedef UpdateForceFullDisplay = void Function(bool);
typedef UpdateChatSetting = void Function(String);
typedef UpdateMeetingDisplayType = void Function(String);
typedef UpdateAudioSetting = void Function(String);
typedef UpdateVideoSetting = void Function(String);
typedef UpdateScreenshareSetting = void Function(String);
typedef UpdateHParams = void Function(ProducerOptionsType);
typedef UpdateVParams = void Function(ProducerOptionsType);
typedef UpdateScreenParams = void Function(ProducerOptionsType);
typedef UpdateAParams = void Function(ProducerOptionsType);
typedef UpdateMainHeightWidth = void Function(double);
typedef UpdateTargetResolution = void Function(String);
typedef UpdateTargetResolutionHost = void Function(String);

// Recording-related update function typedefs
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
typedef UpdateRecordingVideoOptions = void Function(String);
typedef UpdateRecordingAudioOptions = void Function(String);

/// Parameters for updating room configuration
abstract class UpdateRoomParametersClientParameters {
  // Core properties as abstract getters
  RtpCapabilities? get rtpCapabilities;
  List<String> get roomRecvIPs;
  MeetingRoomParams? get meetingRoomParams;
  int get itemPageLimit;
  bool get audioOnlyRoom;
  bool get addForBasic;
  int get screenPageLimit;
  bool get shareScreenStarted;
  bool get shared;
  String get targetOrientation;
  VidCons get vidCons;
  bool get recordingVideoSupport;
  int get frameRate;
  String get adminPasscode;
  EventType get eventType;
  bool get youAreCoHost;
  bool get autoWave;
  bool get forceFullDisplay;
  String get chatSetting;
  String get meetingDisplayType;
  String get audioSetting;
  String get videoSetting;
  String get screenshareSetting;
  ProducerOptionsType? get hParams;
  ProducerOptionsType? get vParams;
  ProducerOptionsType? get screenParams;
  ProducerOptionsType? get aParams;
  String get islevel;
  ShowAlert? get showAlert;
  ResponseJoinRoom get roomData;

  // Update function callbacks as abstract getters
  UpdateRtpCapabilities get updateRtpCapabilities;
  UpdateRoomRecvIPs get updateRoomRecvIPs;
  UpdateMeetingRoomParams get updateMeetingRoomParams;
  UpdateItemPageLimit get updateItemPageLimit;
  UpdateAudioOnlyRoom get updateAudioOnlyRoom;
  UpdateAddForBasic get updateAddForBasic;
  UpdateScreenPageLimit get updateScreenPageLimit;
  UpdateVidCons get updateVidCons;
  UpdateFrameRate get updateFrameRate;
  UpdateAdminPasscode get updateAdminPasscode;
  UpdateEventType get updateEventType;
  UpdateYouAreCoHost get updateYouAreCoHost;
  UpdateAutoWave get updateAutoWave;
  UpdateForceFullDisplay get updateForceFullDisplay;
  UpdateChatSetting get updateChatSetting;
  UpdateMeetingDisplayType get updateMeetingDisplayType;
  UpdateAudioSetting get updateAudioSetting;
  UpdateVideoSetting get updateVideoSetting;
  UpdateScreenshareSetting get updateScreenshareSetting;
  UpdateHParams get updateHParams;
  UpdateVParams get updateVParams;
  UpdateScreenParams get updateScreenParams;
  UpdateAParams get updateAParams;
  UpdateMainHeightWidth get updateMainHeightWidth;
  UpdateTargetResolution get updateTargetResolution;
  UpdateTargetResolutionHost get updateTargetResolutionHost;

  // Recording-related update functions as abstract getters
  UpdateRecordingAudioPausesLimit get updateRecordingAudioPausesLimit;
  UpdateRecordingAudioPausesCount get updateRecordingAudioPausesCount;
  UpdateRecordingAudioSupport get updateRecordingAudioSupport;
  UpdateRecordingAudioPeopleLimit get updateRecordingAudioPeopleLimit;
  UpdateRecordingAudioParticipantsTimeLimit
      get updateRecordingAudioParticipantsTimeLimit;
  UpdateRecordingVideoPausesCount get updateRecordingVideoPausesCount;
  UpdateRecordingVideoPausesLimit get updateRecordingVideoPausesLimit;
  UpdateRecordingVideoSupport get updateRecordingVideoSupport;
  UpdateRecordingVideoPeopleLimit get updateRecordingVideoPeopleLimit;
  UpdateRecordingVideoParticipantsTimeLimit
      get updateRecordingVideoParticipantsTimeLimit;
  UpdateRecordingAllParticipantsSupport
      get updateRecordingAllParticipantsSupport;
  UpdateRecordingVideoParticipantsSupport
      get updateRecordingVideoParticipantsSupport;
  UpdateRecordingAllParticipantsFullRoomSupport
      get updateRecordingAllParticipantsFullRoomSupport;
  UpdateRecordingVideoParticipantsFullRoomSupport
      get updateRecordingVideoParticipantsFullRoomSupport;
  UpdateRecordingPreferredOrientation get updateRecordingPreferredOrientation;
  UpdateRecordingSupportForOtherOrientation
      get updateRecordingSupportForOtherOrientation;
  UpdateRecordingMultiFormatsSupport get updateRecordingMultiFormatsSupport;
  UpdateRecordingVideoOptions get updateRecordingVideoOptions;
  UpdateRecordingAudioOptions get updateRecordingAudioOptions;

  UpdateRoomParametersClientParameters Function() get getUpdatedAllParams;
  //dynamic operator [](String key);
}

/// Options class for updating room parameters
class UpdateRoomParametersClientOptions {
  final UpdateRoomParametersClientParameters parameters;

  UpdateRoomParametersClientOptions({
    required this.parameters,
  });
}

typedef UpdateRoomParametersClientType = void Function(
  UpdateRoomParametersClientOptions options,
);

/// Updates the room configuration parameters based on provided options.
///
/// The `updateRoomParametersClient` function allows for the flexible and dynamic
/// updating of room parameters such as video, audio, and screen sharing configurations.
/// It takes in an `UpdateRoomParametersClientOptions` object that contains the room parameters,
/// along with multiple update functions used to apply changes to these parameters.
///
/// Key configurable parameters include:
/// - **Video Encoding Parameters**: Bitrate, resolution, and scalability settings for video encodings.
/// - **Audio and Video Settings**: Controls for media type (audio-only or video) and individual codec settings.
/// - **Recording Parameters**: Settings for audio and video recording limitations, support, and orientation.
/// - **Screen Sharing and Frame Rate**: Adjustments for screen-sharing constraints and display frame rates.
///
/// The function will update each parameter according to the current room configuration
/// and level, ensuring appropriate values are applied for different event types and device constraints.
///
/// ## Example Usage:
///
/// ```dart
/// final options = UpdateRoomParametersClientOptions(
///   parameters: UpdateRoomParametersClientParameters(
///     rtpCapabilities: myRtpCapabilities,
///     roomRecvIPs: ['100.000.1.1', '100.000.1.2'],
///     meetingRoomParams: myMeetingRoomParams,
///     itemPageLimit: 5,
///     audioOnlyRoom: false,
///     addForBasic: true,
///     screenPageLimit: 3,
///     shareScreenStarted: false,
///     shared: true,
///     targetOrientation: 'landscape',
///     vidCons: VidCons(width: 1280, height: 720),
///     recordingVideoSupport: true,
///     frameRate: 30,
///     adminPasscode: 'secure123',
///     eventType: EventType.conference,
///     youAreCoHost: true,
///     autoWave: true,
///     forceFullDisplay: true,
///     chatSetting: 'enabled',
///     meetingDisplayType: 'gallery',
///     audioSetting: 'allow',
///     videoSetting: 'allow',
///     screenshareSetting: 'approval',
///     hParams: hostParams_.hParams,
///     vParams: videoParams_.vParams,
///     screenParams: screenParams_.screenParams,
///     aParams: audioParams_.aParams,
///     islevel: '1',
///     showAlert: (message, type, duration) {
///       print('$type Alert: $message (Duration: $duration ms)');
///     },
///     roomData: myResponseJoinRoom,
///     updateRtpCapabilities: (capabilities) => print('Updated RTP Capabilities'),
///     updateRoomRecvIPs: (ips) => print('Updated Room Recv IPs'),
///     updateMeetingRoomParams: (params) => print('Updated Meeting Room Params'),
///     updateItemPageLimit: (limit) => print('Updated Item Page Limit: $limit'),
///     updateAudioOnlyRoom: (isAudioOnly) => print('Updated Audio Only Room: $isAudioOnly'),
///     updateAddForBasic: (addForBasic) => print('Updated Add for Basic: $addForBasic'),
///     updateScreenPageLimit: (limit) => print('Updated Screen Page Limit: $limit'),
///     updateVidCons: (vidCons) => print('Updated VidCons: $vidCons'),
///     updateFrameRate: (rate) => print('Updated Frame Rate: $rate'),
///     updateAdminPasscode: (code) => print('Updated Admin Passcode: $code'),
///     updateEventType: (type) => print('Updated Event Type: $type'),
///     updateYouAreCoHost: (isCoHost) => print('Updated Co-Host Status: $isCoHost'),
///     updateAutoWave: (autoWave) => print('Updated AutoWave: $autoWave'),
///     updateForceFullDisplay: (fullDisplay) => print('Updated Full Display: $fullDisplay'),
///     updateChatSetting: (chatSetting) => print('Updated Chat Setting: $chatSetting'),
///     updateMeetingDisplayType: (displayType) => print('Updated Meeting Display Type: $displayType'),
///     updateAudioSetting: (setting) => print('Updated Audio Setting: $setting'),
///     updateVideoSetting: (setting) => print('Updated Video Setting: $setting'),
///     updateScreenshareSetting: (setting) => print('Updated Screenshare Setting: $setting'),
///     updateHParams: (params) => print('Updated Host Params: $params'),
///     updateVParams: (params) => print('Updated Video Params: $params'),
///     updateScreenParams: (params) => print('Updated Screen Params: $params'),
///     updateAParams: (params) => print('Updated Audio Params: $params'),
///     updateMainHeightWidth: (heightWidth) => print('Updated Main Height/Width: $heightWidth'),
///     updateTargetResolution: (resolution) => print('Updated Target Resolution: $resolution'),
///     updateTargetResolutionHost: (resolution) => print('Updated Host Target Resolution: $resolution'),
///     updateRecordingAudioPausesLimit: (limit) => print('Updated Audio Pauses Limit: $limit'),
///     updateRecordingAudioPausesCount: (count) => print('Updated Audio Pauses Count: $count'),
///     updateRecordingAudioSupport: (support) => print('Updated Recording Audio Support: $support'),
///     updateRecordingAudioPeopleLimit: (limit) => print('Updated Audio People Limit: $limit'),
///     updateRecordingAudioParticipantsTimeLimit: (timeLimit) => print('Updated Audio Participants Time Limit: $timeLimit'),
///     updateRecordingVideoPausesCount: (count) => print('Updated Video Pauses Count: $count'),
///     updateRecordingVideoPausesLimit: (limit) => print('Updated Video Pauses Limit: $limit'),
///     updateRecordingVideoSupport: (support) => print('Updated Recording Video Support: $support'),
///     updateRecordingVideoPeopleLimit: (limit) => print('Updated Video People Limit: $limit'),
///     updateRecordingVideoParticipantsTimeLimit: (timeLimit) => print('Updated Video Participants Time Limit: $timeLimit'),
///     updateRecordingAllParticipantsSupport: (support) => print('Updated All Participants Recording Support: $support'),
///     updateRecordingVideoParticipantsSupport: (support) => print('Updated Video Participants Support: $support'),
///     updateRecordingAllParticipantsFullRoomSupport: (support) => print('Updated Full Room Recording Support for All Participants: $support'),
///     updateRecordingVideoParticipantsFullRoomSupport: (support) => print('Updated Full Room Recording Support for Video Participants: $support'),
///     updateRecordingPreferredOrientation: (orientation) => print('Updated Preferred Orientation: $orientation'),
///     updateRecordingSupportForOtherOrientation: (support) => print('Updated Support for Other Orientations: $support'),
///     updateRecordingMultiFormatsSupport: (support) => print('Updated Multi-Formats Support: $support'),
///     updateRecordingVideoOptions: (options) => print('Updated Video Recording Options: $options'),
///     updateRecordingAudioOptions: (options) => print('Updated Audio Recording Options: $options'),
///   ),
/// );
///
/// updateRoomParametersClient(options: options);
/// ```

void updateRoomParametersClient({
  required UpdateRoomParametersClientOptions options,
}) {
  try {
    final params = options.parameters.getUpdatedAllParams();

    if (params.roomData.rtpCapabilities == null) {
      params.showAlert?.call(
        message:
            'Sorry, you are not allowed to join this room. ${params.roomData.reason ?? ''}',
        type: 'danger',
        duration: 3000,
      );
      return;
    }

    params.updateRtpCapabilities(params.roomData.rtpCapabilities);
    params.updateAdminPasscode(params.roomData.secureCode ?? '');
    params.updateRoomRecvIPs(params.roomData.roomRecvIPs ?? []);
    params.updateMeetingRoomParams(params.roomData.meetingRoomParams);

    final recordingParams = params.roomData.recordingParams;
    params.updateRecordingAudioPausesLimit(
        recordingParams?.recordingAudioPausesLimit ?? 0);
    params.updateRecordingAudioPausesCount(
        recordingParams?.recordingAudioPausesCount ?? 0);
    params.updateRecordingAudioSupport(
        recordingParams?.recordingAudioSupport ?? false);
    params.updateRecordingAudioPeopleLimit(
        recordingParams?.recordingAudioPeopleLimit ?? 0);
    params.updateRecordingAudioParticipantsTimeLimit(
        recordingParams?.recordingAudioParticipantsTimeLimit ?? 0);
    params.updateRecordingVideoPausesCount(
        recordingParams?.recordingVideoPausesCount ?? 0);
    params.updateRecordingVideoPausesLimit(
        recordingParams?.recordingVideoPausesLimit ?? 0);
    params.updateRecordingVideoSupport(
        recordingParams?.recordingVideoSupport ?? false);
    params.updateRecordingVideoPeopleLimit(
        recordingParams?.recordingVideoPeopleLimit ?? 0);
    params.updateRecordingVideoParticipantsTimeLimit(
        recordingParams?.recordingVideoParticipantsTimeLimit ?? 0);
    params.updateRecordingAllParticipantsSupport(
        recordingParams?.recordingAllParticipantsSupport ?? false);
    params.updateRecordingVideoParticipantsSupport(
        recordingParams?.recordingVideoParticipantsSupport ?? false);
    params.updateRecordingAllParticipantsFullRoomSupport(
        recordingParams?.recordingAllParticipantsFullRoomSupport ?? false);
    params.updateRecordingVideoParticipantsFullRoomSupport(
        recordingParams?.recordingVideoParticipantsFullRoomSupport ?? false);
    params.updateRecordingPreferredOrientation(
        recordingParams?.recordingPreferredOrientation ?? '');
    params.updateRecordingSupportForOtherOrientation(
        recordingParams?.recordingSupportForOtherOrientation ?? false);
    params.updateRecordingMultiFormatsSupport(
        recordingParams?.recordingMultiFormatsSupport ?? false);

    final meetingParams = params.roomData.meetingRoomParams;
    params.updateItemPageLimit(meetingParams?.itemPageLimit ?? 0);
    final eventType_ = meetingParams?.type == 'conference'
        ? EventType.conference
        : meetingParams?.type == 'webinar'
            ? EventType.webinar
            : meetingParams?.type == 'broadcast'
                ? EventType.broadcast
                : EventType.chat;
    meetingParams?.type = eventType_;
    params.updateEventType(eventType_);
    if (meetingParams?.type == EventType.chat && params.islevel != '2') {
      params.updateYouAreCoHost(true);
    }
    if (meetingParams?.type == EventType.chat ||
        meetingParams?.type == EventType.broadcast) {
      params.updateAutoWave(false);
      params.updateMeetingDisplayType('all');
      params.updateForceFullDisplay(true);
      params.updateChatSetting(meetingParams?.chatSetting ?? 'allow');

      if (meetingParams?.type == EventType.broadcast) {
        params.updateRecordingVideoOptions('mainScreen');
        params.updateRecordingAudioOptions('host');
        params.updateItemPageLimit(1);
      }
    }
    params.updateAudioSetting(meetingParams?.audioSetting ?? 'allow');
    params.updateVideoSetting(meetingParams?.videoSetting ?? 'allow');
    params
        .updateScreenshareSetting(meetingParams?.screenshareSetting ?? 'allow');
    params.updateChatSetting(meetingParams?.chatSetting ?? 'allow');

    params.updateAudioOnlyRoom(meetingParams?.mediaType != 'video');

    if (meetingParams?.type == EventType.conference) {
      if (params.shared || params.shareScreenStarted) {
        params.updateMainHeightWidth(100);
      } else {
        params.updateMainHeightWidth(0);
      }
    }

    params.updateScreenPageLimit(meetingParams?.itemPageLimit ?? 2);

    String targetOrientation = params.islevel == '2'
        ? meetingParams?.targetOrientationHost ?? 'neutral'
        : meetingParams?.targetOrientation ?? 'neutral';
    String targetResolution = params.islevel == '2'
        ? meetingParams?.targetResolutionHost ?? 'sd'
        : meetingParams?.targetResolution ?? 'sd';

    int frameRate;
    VidCons vdCons;
    if (targetOrientation == 'landscape') {
      switch (targetResolution) {
        case 'hd':
          vdCons = constraints.hdCons;
          frameRate = constraints.hdFrameRate;
          break;
        case 'fhd':
          vdCons = constraints.fhdCons;
          frameRate = constraints.fhdFrameRate;
          break;
        case 'qhd':
          vdCons = constraints.qhdCons;
          frameRate = constraints.qhdFrameRate;
          break;
        case 'QnHD':
          vdCons = constraints.qnHDCons;
          frameRate = constraints.qnHDFrameRate;
          break;
        default:
          vdCons = constraints.sdCons;
          frameRate = constraints.sdFrameRate;
      }
    } else if (targetOrientation == 'neutral') {
      switch (targetResolution) {
        case 'hd':
          vdCons = constraints.hdConsNeu;
          frameRate = constraints.hdFrameRate;
          break;
        case 'fhd':
          vdCons = constraints.fhdConsNeu;
          frameRate = constraints.fhdFrameRate;
          break;
        case 'qhd':
          vdCons = constraints.qhdConsNeu;
          frameRate = constraints.qhdFrameRate;
          break;
        case 'QnHD':
          vdCons = constraints.qnHDConsNeu;
          frameRate = constraints.qnHDFrameRate;
          break;
        default:
          vdCons = constraints.sdConsNeu;
          frameRate = constraints.sdFrameRate;
      }
    } else {
      switch (targetResolution) {
        case 'hd':
          vdCons = constraints.hdConsPort;
          frameRate = constraints.hdFrameRate;
          break;
        case 'fhd':
          vdCons = constraints.fhdConsPort;
          frameRate = constraints.fhdFrameRate;
          break;
        case 'qhd':
          vdCons = constraints.qhdConsPort;
          frameRate = constraints.qhdFrameRate;
          break;
        case 'QnHD':
          vdCons = constraints.qnHDConsPort;
          frameRate = constraints.qnHDFrameRate;
          break;
        default:
          vdCons = constraints.sdConsPort;
          frameRate = constraints.sdFrameRate;
      }
    }

    final hParams = hostParams_.hParams;
    final vParams = videoParams_.vParams;

    switch (targetResolution) {
      case 'hd':
        hParams.encodings = _updateEncodingBitrates(hParams.encodings, 4)
            as List<RtpEncodingParameters>;
        vParams.encodings = _updateEncodingBitrates(vParams.encodings, 4)
            as List<RtpEncodingParameters>;
        break;
      case 'fhd':
        hParams.encodings = _updateEncodingBitrates(hParams.encodings, 8)
            as List<RtpEncodingParameters>;
        vParams.encodings = _updateEncodingBitrates(vParams.encodings, 8)
            as List<RtpEncodingParameters>;
        break;
      case 'qhd':
        hParams.encodings = _updateEncodingBitrates(hParams.encodings, 16)
            as List<RtpEncodingParameters>;
        vParams.encodings = _updateEncodingBitrates(vParams.encodings, 16)
            as List<RtpEncodingParameters>;
        break;
      case 'QnHD':
        hParams.encodings = _updateEncodingBitrates(hParams.encodings, 0.25)
            as List<RtpEncodingParameters>;
        vParams.encodings = _updateEncodingBitrates(vParams.encodings, 0.25)
            as List<RtpEncodingParameters>;
        break;
    }

    if (recordingParams?.recordingVideoSupport == true) {
      if (vParams.encodings.length > 1) {
        vParams.encodings = vParams.encodings.sublist(0, 1);
      }
      if (hParams.encodings.length > 1) {
        hParams.encodings = hParams.encodings.sublist(0, 1);
      }
    }

    params.updateVidCons(vdCons);
    params.updateFrameRate(frameRate);
    params.updateHParams(hParams);
    params.updateVParams(vParams);
    params
        .updateScreenParams(params.screenParams ?? screenParams_.screenParams);
    params.updateAParams(params.aParams ?? audioParams_.aParams);
  } catch (error) {
    // Print the error along with the stack trace
    if (kDebugMode) {
      print('Update room parameters error: $error');
    }
    // print('Stack trace: $stackTrace');
    try {
      final ShowAlert? showAlert = options.parameters.showAlert;
      showAlert?.call(
        message: error.toString(),
        type: 'danger',
        duration: 3000,
      );
    } catch (error) {}
  }
}

/// Helper function to adjust bitrate for encoding configurations.
List<Map<String, dynamic>> _updateEncodingBitrates(
    List encodings, double factor) {
  return encodings.map((encoding) {
    final updatedEncoding = Map<String, dynamic>.from(encoding);
    if (updatedEncoding['maxBitrate'] != null) {
      updatedEncoding['maxBitrate'] =
          (updatedEncoding['maxBitrate'] * factor).toInt();
      updatedEncoding['initialAvailableBitrate'] =
          (updatedEncoding['initialAvailableBitrate'] * factor).toInt();
    }
    return updatedEncoding;
  }).toList();
}
