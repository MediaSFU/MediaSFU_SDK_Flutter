/// Updates the recording parameters for the room based on the provided recordParams.
///
/// This function updates the recording parameters for the room based on the provided recordParams.
///
/// Parameters:
/// - [recordParams]: Object containing recording parameters for the room.
/// - [parameters]: Object containing various update functions for recording parameters.
/// - [parameters.updateRecordingAudioPausesLimit]: Function to update recording audio pauses limit.
/// - [parameters.updateRecordingAudioPausesCount]: Function to update recording audio pauses count.
/// - [parameters.updateRecordingAudioSupport]: Function to update recording audio support.
/// - [parameters.updateRecordingAudioPeopleLimit]: Function to update recording audio people limit.
/// - [parameters.updateRecordingAudioParticipantsTimeLimit]: Function to update recording audio participants time limit.
/// - [parameters.updateRecordingVideoPausesCount]: Function to update recording video pauses count.
/// - [parameters.updateRecordingVideoPausesLimit]: Function to update recording video pauses limit.
/// - [parameters.updateRecordingVideoSupport]: Function to update recording video support.
/// - [parameters.updateRecordingVideoPeopleLimit]: Function to update recording video people limit.
/// - [parameters.updateRecordingVideoParticipantsTimeLimit]: Function to update recording video participants time limit.
/// - [parameters.updateRecordingAllParticipantsSupport]: Function to update recording support for all participants.
/// - [parameters.updateRecordingVideoParticipantsSupport]: Function to update recording support for video participants.
/// - [parameters.updateRecordingAllParticipantsFullRoomSupport]: Function to update recording full room support for all participants.
/// - [parameters.updateRecordingVideoParticipantsFullRoomSupport]: Function to update recording full room support for video participants.
/// - [parameters.updateRecordingPreferredOrientation]: Function to update recording preferred orientation.
/// - [parameters.updateRecordingSupportForOtherOrientation]: Function to update recording support for other orientations.
/// - [parameters.updateRecordingMultiFormatsSupport]: Function to update recording multi-formats support.
///
/// Returns:
/// void
void roomRecordParams({
  required Map<String, dynamic> recordParams,
  required Map<String, Function(dynamic)> parameters,
}) {
  void Function(dynamic)? updateRecordingAudioPausesLimit =
      parameters['updateRecordingAudioPausesLimit'];
  void Function(dynamic)? updateRecordingAudioPausesCount =
      parameters['updateRecordingAudioPausesCount'];
  void Function(dynamic)? updateRecordingAudioSupport =
      parameters['updateRecordingAudioSupport'];
  void Function(dynamic)? updateRecordingAudioPeopleLimit =
      parameters['updateRecordingAudioPeopleLimit'];
  void Function(dynamic)? updateRecordingAudioParticipantsTimeLimit =
      parameters['updateRecordingAudioParticipantsTimeLimit'];
  void Function(dynamic)? updateRecordingVideoPausesCount =
      parameters['updateRecordingVideoPausesCount'];
  void Function(dynamic)? updateRecordingVideoPausesLimit =
      parameters['updateRecordingVideoPausesLimit'];
  void Function(dynamic)? updateRecordingVideoSupport =
      parameters['updateRecordingVideoSupport'];
  void Function(dynamic)? updateRecordingVideoPeopleLimit =
      parameters['updateRecordingVideoPeopleLimit'];
  void Function(dynamic)? updateRecordingVideoParticipantsTimeLimit =
      parameters['updateRecordingVideoParticipantsTimeLimit'];
  void Function(dynamic)? updateRecordingAllParticipantsSupport =
      parameters['updateRecordingAllParticipantsSupport'];
  void Function(dynamic)? updateRecordingVideoParticipantsSupport =
      parameters['updateRecordingVideoParticipantsSupport'];
  void Function(dynamic)? updateRecordingAllParticipantsFullRoomSupport =
      parameters['updateRecordingAllParticipantsFullRoomSupport'];
  void Function(dynamic)? updateRecordingVideoParticipantsFullRoomSupport =
      parameters['updateRecordingVideoParticipantsFullRoomSupport'];
  void Function(dynamic)? updateRecordingPreferredOrientation =
      parameters['updateRecordingPreferredOrientation'];
  void Function(dynamic)? updateRecordingSupportForOtherOrientation =
      parameters['updateRecordingSupportForOtherOrientation'];
  void Function(dynamic)? updateRecordingMultiFormatsSupport =
      parameters['updateRecordingMultiFormatsSupport'];

  updateRecordingAudioPausesLimit
      ?.call(recordParams['recordingAudioPausesLimit']);
  updateRecordingAudioPausesCount
      ?.call(recordParams['recordingAudioPausesCount']);
  updateRecordingAudioSupport?.call(recordParams['recordingAudioSupport']);
  updateRecordingAudioPeopleLimit
      ?.call(recordParams['recordingAudioPeopleLimit']);
  updateRecordingAudioParticipantsTimeLimit
      ?.call(recordParams['recordingAudioParticipantsTimeLimit']);
  updateRecordingVideoPausesCount
      ?.call(recordParams['recordingVideoPausesCount']);
  updateRecordingVideoPausesLimit
      ?.call(recordParams['recordingVideoPausesLimit']);
  updateRecordingVideoSupport?.call(recordParams['recordingVideoSupport']);
  updateRecordingVideoPeopleLimit
      ?.call(recordParams['recordingVideoPeopleLimit']);
  updateRecordingVideoParticipantsTimeLimit
      ?.call(recordParams['recordingVideoParticipantsTimeLimit']);
  updateRecordingAllParticipantsSupport
      ?.call(recordParams['recordingAllParticipantsSupport']);
  updateRecordingVideoParticipantsSupport
      ?.call(recordParams['recordingVideoParticipantsSupport']);
  updateRecordingAllParticipantsFullRoomSupport
      ?.call(recordParams['recordingAllParticipantsFullRoomSupport']);
  updateRecordingVideoParticipantsFullRoomSupport
      ?.call(recordParams['recordingVideoParticipantsFullRoomSupport']);
  updateRecordingPreferredOrientation
      ?.call(recordParams['recordingPreferredOrientation']);
  updateRecordingSupportForOtherOrientation
      ?.call(recordParams['recordingSupportForOtherOrientation']);
  updateRecordingMultiFormatsSupport
      ?.call(recordParams['recordingMultiFormatsSupport']);
}
