import '../../types/types.dart'
    show
        ShowAlert,
        MainSpecs,
        DispSpecs,
        TextSpecs,
        EventType,
        UserRecordingParams;

/// Class for recording parameters used in confirming recording settings.
abstract class ConfirmRecordingParameters {
  // Core properties as abstract getters
  ShowAlert? get showAlert;
  String get recordingMediaOptions;
  String get recordingAudioOptions;
  String get recordingVideoOptions;
  String get recordingVideoType;
  String get recordingDisplayType;
  bool get recordingNameTags;
  String get recordingBackgroundColor;
  String get recordingNameTagsColor;
  String get recordingOrientationVideo;
  bool get recordingAddHLS;
  bool get recordingAddText;
  String get recordingCustomText;
  String get recordingCustomTextPosition;
  String get recordingCustomTextColor;
  String get meetingDisplayType;
  bool get recordingVideoParticipantsFullRoomSupport;
  bool get recordingAllParticipantsSupport;
  bool get recordingVideoParticipantsSupport;
  bool get recordingSupportForOtherOrientation;
  String get recordingPreferredOrientation;
  bool get recordingMultiFormatsSupport;
  bool get recordingVideoOptimized;
  bool get recordingAllParticipantsFullRoomSupport;
  bool get meetingVideoOptimized;
  EventType get eventType;
  bool get breakOutRoomStarted;
  bool get breakOutRoomEnded;

  // Update functions as abstract getters returning functions
  void Function(String displayType) get updateRecordingDisplayType;
  void Function(bool optimized) get updateRecordingVideoOptimized;
  void Function(UserRecordingParams params) get updateUserRecordingParams;
  void Function(bool confirmed) get updateConfirmedToRecord;

  // Mediasfu function to get updated parameters as an abstract getter
  ConfirmRecordingParameters Function() get getUpdatedAllParams;

  // dynamic operator [](String key);
}

/// Class encapsulating options for confirming recording.
class ConfirmRecordingOptions {
  final ConfirmRecordingParameters parameters;

  ConfirmRecordingOptions({
    required this.parameters,
  });
}

/// Type alias for confirm recording function.
typedef ConfirmRecordingType = Future<void> Function(
    ConfirmRecordingOptions options);

/// Confirms the recording based on the provided parameters.
///
/// The [options] parameter contains various settings and callbacks related to the recording.
/// The function performs validation checks on the parameters and displays appropriate alerts if any invalid options are selected.
/// It also updates the recording display type and other related settings based on the meeting display type.
///
/// The function uses the following callback functions to display alerts and update recording settings:
/// - [showAlert]: A function that displays an alert with the specified message, type, and duration.
/// - [updateRecordingDisplayType]: A function that updates the recording display type.
/// - [updateRecordingVideoOptimized]: A function that updates the recording video optimization setting.
/// - [updateUserRecordingParams]: A function that updates the user recording parameters.
/// - [updateConfirmedToRecord]: A function that updates the confirmed to record setting.
///
/// The function returns void.
///
/// Example usage:
/// ```dart
/// confirmRecording(ConfirmRecordingOptions(
///   parameters: ConfirmRecordingParameters(
///     showAlert: ({required String message, required String type, required int duration}) {
///       print(message);
///     },
///     recordingMediaOptions: 'video',
///     recordingAudioOptions: 'high',
///     recordingVideoOptions: 'all',
///     recordingVideoType: 'HD',
///     recordingDisplayType: 'video',
///     recordingNameTags: true,
///     recordingBackgroundColor: '#000000',
///     recordingNameTagsColor: '#ffffff',
///     recordingOrientationVideo: 'landscape',
///     recordingAddHLS: true,
///     recordingAddText: true,
///     recordingCustomText: 'Meeting',
///     recordingCustomTextPosition: 'top-right',
///     recordingCustomTextColor: '#ffffff',
///     meetingDisplayType: 'video',
///     recordingVideoParticipantsFullRoomSupport: true,
///     recordingAllParticipantsSupport: true,
///     recordingVideoParticipantsSupport: true,
///     recordingSupportForOtherOrientation: true,
///     recordingPreferredOrientation: 'landscape',
///     recordingMultiFormatsSupport: true,
///     recordingVideoOptimized: true,
///     recordingAllParticipantsFullRoomSupport: true,
///     meetingVideoOptimized: false,
///     eventType: EventType.broadcast,
///     breakOutRoomStarted: false,
///     breakOutRoomEnded: true,
///     updateRecordingDisplayType: (displayType) {
///       print('Updated display type: $displayType');
///     },
///     updateRecordingVideoOptimized: (optimized) {
///       print('Updated video optimized: $optimized');
///     },
///     updateUserRecordingParams: (params) {
///       print('Updated recording params: $params');
///     },
///     updateConfirmedToRecord: (confirmed) {
///       print('Confirmed to record: $confirmed');
///     },
///     getUpdatedAllParams: () => updatedParameters, // Define how to get updated parameters
///   ),
/// ));
/// ```

Future<void> confirmRecording(ConfirmRecordingOptions options) async {
  // Retrieve the latest parameters if needed
  ConfirmRecordingParameters parameters =
      options.parameters.getUpdatedAllParams();

  // Destructure parameters
  final showAlert = parameters.showAlert;
  final recordingMediaOptions = parameters.recordingMediaOptions;
  final recordingAudioOptions = parameters.recordingAudioOptions;
  final recordingVideoOptions = parameters.recordingVideoOptions;
  final recordingVideoType = parameters.recordingVideoType;
  final recordingDisplayType = parameters.recordingDisplayType;
  final recordingNameTags = parameters.recordingNameTags;
  final recordingBackgroundColor = parameters.recordingBackgroundColor;
  final recordingNameTagsColor = parameters.recordingNameTagsColor;
  final recordingOrientationVideo = parameters.recordingOrientationVideo;
  final recordingAddHLS = parameters.recordingAddHLS;
  final recordingAddText = parameters.recordingAddText;
  final recordingCustomText = parameters.recordingCustomText;
  final recordingCustomTextPosition = parameters.recordingCustomTextPosition;
  final recordingCustomTextColor = parameters.recordingCustomTextColor;
  final meetingDisplayType = parameters.meetingDisplayType;
  final recordingVideoParticipantsFullRoomSupport =
      parameters.recordingVideoParticipantsFullRoomSupport;
  final recordingAllParticipantsSupport =
      parameters.recordingAllParticipantsSupport;
  final recordingVideoParticipantsSupport =
      parameters.recordingVideoParticipantsSupport;
  final recordingSupportForOtherOrientation =
      parameters.recordingSupportForOtherOrientation;
  final recordingPreferredOrientation =
      parameters.recordingPreferredOrientation;
  final recordingMultiFormatsSupport = parameters.recordingMultiFormatsSupport;
  final recordingVideoOptimized = parameters.recordingVideoOptimized;
  final recordingAllParticipantsFullRoomSupport =
      parameters.recordingAllParticipantsFullRoomSupport;
  final meetingVideoOptimized = parameters.meetingVideoOptimized;
  final eventType = parameters.eventType;
  final breakOutRoomStarted = parameters.breakOutRoomStarted;
  final breakOutRoomEnded = parameters.breakOutRoomEnded;

  // Callback functions for updating recording settings
  final updateRecordingDisplayType = parameters.updateRecordingDisplayType;
  final updateRecordingVideoOptimized =
      parameters.updateRecordingVideoOptimized;
  final updateUserRecordingParams = parameters.updateUserRecordingParams;
  final updateConfirmedToRecord = parameters.updateConfirmedToRecord;

  // Perform validation checks similar to TypeScript logic
  if (!recordingVideoParticipantsFullRoomSupport &&
      recordingVideoOptions == 'all' &&
      recordingMediaOptions == 'video') {
    if (meetingDisplayType == 'all' &&
        !(breakOutRoomStarted && !breakOutRoomEnded)) {
      showAlert?.call(
        message:
            'You are not allowed to record videos of all participants; change the meeting display type to video or video optimized.',
        type: 'danger',
        duration: 3000,
      );
      return;
    }
  }

  if (!recordingAllParticipantsSupport && recordingVideoOptions == 'all') {
    showAlert?.call(
      message: 'You are only allowed to record yourself.',
      type: 'danger',
      duration: 3000,
    );
    return;
  }

  if (!recordingVideoParticipantsSupport && recordingDisplayType == 'video') {
    showAlert?.call(
      message: 'You are not allowed to record other video participants.',
      type: 'danger',
      duration: 3000,
    );
    return;
  }

  if (!recordingSupportForOtherOrientation &&
      recordingOrientationVideo == 'all') {
    showAlert?.call(
      message: 'You are not allowed to record all orientations.',
      type: 'danger',
      duration: 3000,
    );
    return;
  }

  if ((recordingPreferredOrientation == 'landscape' &&
          recordingOrientationVideo == 'portrait') ||
      (recordingPreferredOrientation == 'portrait' &&
          recordingOrientationVideo == 'landscape')) {
    if (!recordingSupportForOtherOrientation) {
      showAlert?.call(
        message: 'You are not allowed to record this orientation.',
        type: 'danger',
        duration: 3000,
      );
      return;
    }
  }

  if (!recordingMultiFormatsSupport && recordingVideoType == 'all') {
    showAlert?.call(
      message: 'You are not allowed to record all formats.',
      type: 'danger',
      duration: 3000,
    );
    return;
  }

  if (eventType != EventType.broadcast) {
    if (recordingMediaOptions == 'video') {
      if (meetingDisplayType == 'media' && recordingDisplayType == 'all') {
        showAlert?.call(
          message:
              'Recording display type can be either video, video optimized, or media when meeting display type is media.',
          type: 'danger',
          duration: 3000,
        );
        updateRecordingDisplayType(meetingDisplayType);
        return;
      }

      if (meetingDisplayType == 'video' &&
          (recordingDisplayType == 'all' || recordingDisplayType == 'media')) {
        showAlert?.call(
          message:
              'Recording display type can be either video or video optimized when meeting display type is video.',
          type: 'danger',
          duration: 3000,
        );
        updateRecordingDisplayType(meetingDisplayType);
        return;
      }

      if (meetingVideoOptimized && !recordingVideoOptimized) {
        showAlert?.call(
          message:
              'Recording display type can only be video optimized when meeting display type is video optimized.',
          type: 'danger',
          duration: 3000,
        );
        updateRecordingVideoOptimized(meetingVideoOptimized);
        return;
      }
    } else {
      updateRecordingDisplayType('media');
      updateRecordingVideoOptimized(false);
    }
  }

  if (recordingDisplayType == 'all' &&
      !recordingAllParticipantsFullRoomSupport) {
    showAlert?.call(
      message: 'You can only record all participants with media.',
      type: 'danger',
      duration: 3000,
    );
    return;
  }

  // Build recording parameter specs and update state
  final mainSpecs = MainSpecs(
    mediaOptions: recordingMediaOptions,
    audioOptions: recordingAudioOptions,
    videoOptions: recordingVideoOptions,
    videoType: recordingVideoType,
    videoOptimized: recordingVideoOptimized,
    recordingDisplayType: recordingDisplayType,
    addHLS: recordingAddHLS,
  );

  final dispSpecs = DispSpecs(
    nameTags: recordingNameTags,
    backgroundColor: recordingBackgroundColor,
    nameTagsColor: recordingNameTagsColor,
    orientationVideo: recordingOrientationVideo,
  );

  final textSpecs = TextSpecs(
    addText: recordingAddText,
    customText: recordingCustomText,
    customTextPosition: recordingCustomTextPosition,
    customTextColor: recordingCustomTextColor,
  );

  final userRecordingParams = UserRecordingParams(
    mainSpecs: mainSpecs,
    dispSpecs: dispSpecs,
    textSpecs: textSpecs,
  );

  updateUserRecordingParams(userRecordingParams);
  updateConfirmedToRecord(true);
}
