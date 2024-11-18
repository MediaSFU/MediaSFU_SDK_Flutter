/// Represents the recording parameters to be updated.
abstract class RecordParams {
  int get recordingAudioPausesLimit;
  int get recordingAudioPausesCount;
  bool get recordingAudioSupport;
  int get recordingAudioPeopleLimit;
  int get recordingAudioParticipantsTimeLimit;
  int get recordingVideoPausesCount;
  int get recordingVideoPausesLimit;
  bool get recordingVideoSupport;
  int get recordingVideoPeopleLimit;
  int get recordingVideoParticipantsTimeLimit;
  bool get recordingAllParticipantsSupport;
  bool get recordingVideoParticipantsSupport;
  bool get recordingAllParticipantsFullRoomSupport;
  bool get recordingVideoParticipantsFullRoomSupport;
  String get recordingPreferredOrientation;
  bool get recordingSupportForOtherOrientation;
  bool get recordingMultiFormatsSupport;
}

/// Defines update functions for each recording parameter.
abstract class RoomRecordParamsParameters {
  // Update functions as abstract getters returning function types
  void Function(int) get updateRecordingAudioPausesLimit;
  void Function(int) get updateRecordingAudioPausesCount;
  void Function(bool) get updateRecordingAudioSupport;
  void Function(int) get updateRecordingAudioPeopleLimit;
  void Function(int) get updateRecordingAudioParticipantsTimeLimit;
  void Function(int) get updateRecordingVideoPausesCount;
  void Function(int) get updateRecordingVideoPausesLimit;
  void Function(bool) get updateRecordingVideoSupport;
  void Function(int) get updateRecordingVideoPeopleLimit;
  void Function(int) get updateRecordingVideoParticipantsTimeLimit;
  void Function(bool) get updateRecordingAllParticipantsSupport;
  void Function(bool) get updateRecordingVideoParticipantsSupport;
  void Function(bool) get updateRecordingAllParticipantsFullRoomSupport;
  void Function(bool) get updateRecordingVideoParticipantsFullRoomSupport;
  void Function(String) get updateRecordingPreferredOrientation;
  void Function(bool) get updateRecordingSupportForOtherOrientation;
  void Function(bool) get updateRecordingMultiFormatsSupport;
}

/// Options to configure the recording parameter updates.
class RoomRecordParamsOptions {
  final RecordParams recordParams;
  final RoomRecordParamsParameters parameters;

  RoomRecordParamsOptions({
    required this.recordParams,
    required this.parameters,
  });
}

typedef RoomRecordParamsType = void Function(RoomRecordParamsOptions options);

/// Updates various recording parameters based on the provided [recordParams].
///
/// Example usage:
/// ```dart
/// final recordParams = RecordParams(
///   recordingAudioPausesLimit: 3,
///   recordingAudioPausesCount: 1,
///   recordingAudioSupport: true,
///   recordingAudioPeopleLimit: 10,
///   recordingAudioParticipantsTimeLimit: 60,
///   recordingVideoPausesCount: 1,
///   recordingVideoPausesLimit: 3,
///   recordingVideoSupport: true,
///   recordingVideoPeopleLimit: 10,
///   recordingVideoParticipantsTimeLimit: 60,
///   recordingAllParticipantsSupport: true,
///   recordingVideoParticipantsSupport: false,
///   recordingAllParticipantsFullRoomSupport: true,
///   recordingVideoParticipantsFullRoomSupport: false,
///   recordingPreferredOrientation: "landscape",
///   recordingSupportForOtherOrientation: true,
///   recordingMultiFormatsSupport: false,
/// );
///
/// final parameters = RoomRecordParamsParameters(
///   updateRecordingAudioPausesLimit: (value) => print("Audio Pauses Limit: $value"),
///   updateRecordingAudioPausesCount: (value) => print("Audio Pauses Count: $value"),
///   updateRecordingAudioSupport: (value) => print("Audio Support: $value"),
///   // Other parameters...
/// );
///
/// roomRecordParams(RoomRecordParamsOptions(
///   recordParams: recordParams,
///   parameters: parameters,
/// ));
/// ```
void roomRecordParams(RoomRecordParamsOptions options) {
  final recordParams = options.recordParams;
  final params = options.parameters;

  params
      .updateRecordingAudioPausesLimit(recordParams.recordingAudioPausesLimit);
  params
      .updateRecordingAudioPausesCount(recordParams.recordingAudioPausesCount);
  params.updateRecordingAudioSupport(recordParams.recordingAudioSupport);
  params
      .updateRecordingAudioPeopleLimit(recordParams.recordingAudioPeopleLimit);
  params.updateRecordingAudioParticipantsTimeLimit(
    recordParams.recordingAudioParticipantsTimeLimit,
  );
  params
      .updateRecordingVideoPausesCount(recordParams.recordingVideoPausesCount);
  params
      .updateRecordingVideoPausesLimit(recordParams.recordingVideoPausesLimit);
  params.updateRecordingVideoSupport(recordParams.recordingVideoSupport);
  params
      .updateRecordingVideoPeopleLimit(recordParams.recordingVideoPeopleLimit);
  params.updateRecordingVideoParticipantsTimeLimit(
    recordParams.recordingVideoParticipantsTimeLimit,
  );
  params.updateRecordingAllParticipantsSupport(
    recordParams.recordingAllParticipantsSupport,
  );
  params.updateRecordingVideoParticipantsSupport(
    recordParams.recordingVideoParticipantsSupport,
  );
  params.updateRecordingAllParticipantsFullRoomSupport(
    recordParams.recordingAllParticipantsFullRoomSupport,
  );
  params.updateRecordingVideoParticipantsFullRoomSupport(
    recordParams.recordingVideoParticipantsFullRoomSupport,
  );
  params.updateRecordingPreferredOrientation(
      recordParams.recordingPreferredOrientation);
  params.updateRecordingSupportForOtherOrientation(
    recordParams.recordingSupportForOtherOrientation,
  );
  params.updateRecordingMultiFormatsSupport(
      recordParams.recordingMultiFormatsSupport);
}
