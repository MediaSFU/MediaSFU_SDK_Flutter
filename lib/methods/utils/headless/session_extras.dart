import 'dart:async';

import 'package:flutter_webrtc/flutter_webrtc.dart' show MediaStream;

import '../../../types/types.dart'
    show BreakoutParticipant, ListenerTranslationPreferences, Participant;
import '../mediasfu_parameters.dart' show MediasfuParameters;
import 'room_actions.dart' show HeadlessActionResult;

class RecordingNoticeState {
  final String message;
  final String elapsed;
  final int elapsedSeconds;
  final bool canPauseResume;
  final int pausesUsed;
  final int pauseLimit;
  bool get pauseLimitReached => pauseLimit > 0 && pausesUsed >= pauseLimit;

  const RecordingNoticeState({
    required this.message,
    required this.elapsed,
    required this.elapsedSeconds,
    required this.canPauseResume,
    required this.pausesUsed,
    required this.pauseLimit,
  });
}

RecordingNoticeState getRecordingNotice(MediasfuParameters parameters) {
  final pauseLimit = parameters.recordingMediaOptions == 'audio'
      ? parameters.recordingAudioPausesLimit
      : parameters.recordingVideoPausesLimit;
  return RecordingNoticeState(
    // Flutter displays notices directly and does not retain the last notice in
    // its parameter bag, so only the observable timer/allowance can be exposed.
    message: '',
    elapsed: parameters.recordingProgressTime,
    elapsedSeconds: parameters.recordElapsedTime,
    canPauseResume: parameters.canPauseResume,
    pausesUsed: parameters.pauseRecordCount,
    pauseLimit: pauseLimit,
  );
}

class RecordingCapabilities {
  final bool audio;
  final bool video;
  final bool allParticipants;
  final bool videoParticipants;
  final bool hls;
  final int audioPeopleLimit;
  final int videoPeopleLimit;

  const RecordingCapabilities({
    required this.audio,
    required this.video,
    required this.allParticipants,
    required this.videoParticipants,
    required this.hls,
    required this.audioPeopleLimit,
    required this.videoPeopleLimit,
  });
}

RecordingCapabilities getRecordingCapabilities(MediasfuParameters parameters) =>
    RecordingCapabilities(
      audio: parameters.recordingAudioSupport,
      video: parameters.recordingVideoSupport,
      allParticipants: parameters.recordingAllParticipantsSupport,
      videoParticipants: parameters.recordingVideoParticipantsSupport,
      hls: parameters.recordingAddHLS,
      audioPeopleLimit: parameters.recordingAudioPeopleLimit,
      videoPeopleLimit: parameters.recordingVideoPeopleLimit,
    );

class TranslationPreference {
  final String speakerId;
  final String? language;
  final bool wantOriginal;

  const TranslationPreference({
    required this.speakerId,
    required this.language,
    required this.wantOriginal,
  });
}

class TranslationState {
  final String? globalLanguage;
  final List<TranslationPreference> perSpeaker;
  final bool active;
  final List<String> availableLanguages;

  const TranslationState({
    required this.globalLanguage,
    required this.perSpeaker,
    required this.active,
    required this.availableLanguages,
  });
}

TranslationState getTranslationState(MediasfuParameters parameters) {
  final preferences = parameters.listenerTranslationPreferences;
  final perSpeaker = (preferences?.perSpeaker ?? const <String, String>{})
      .entries
      .map((entry) => TranslationPreference(
            speakerId: entry.key,
            language: entry.value.isEmpty ? null : entry.value,
            wantOriginal: entry.value.isEmpty,
          ))
      .toList(growable: false);
  final languages = <String>{};
  final global = preferences?.globalLanguage;
  if (global != null && global.isNotEmpty) languages.add(global);
  for (final entry in perSpeaker) {
    if (entry.language != null) languages.add(entry.language!);
  }
  for (final value in parameters.speakerTranslationStates?.values ?? const []) {
    if (value is Map && value['language'] is String) {
      final language = value['language'] as String;
      if (language.isNotEmpty) languages.add(language);
    }
  }
  return TranslationState(
    globalLanguage: global,
    perSpeaker: perSpeaker,
    active: (global != null && global.isNotEmpty) ||
        perSpeaker.any((entry) => !entry.wantOriginal),
    availableLanguages: List<String>.unmodifiable(languages),
  );
}

HeadlessActionResult setTranslationPreference(
  MediasfuParameters parameters, {
  String? language,
  String? speakerId,
  bool wantOriginal = false,
}) {
  final update = parameters.updateListenerTranslationPreferences;
  if (update == null) {
    return const HeadlessActionResult.failure(
        'Translation is not available in this room.');
  }
  try {
    final current = parameters.listenerTranslationPreferences;
    final perSpeaker = Map<String, String>.from(
        current?.perSpeaker ?? const <String, String>{});
    if (speakerId != null && speakerId.isNotEmpty) {
      if (wantOriginal || language == null || language.isEmpty) {
        perSpeaker.remove(speakerId);
      } else {
        perSpeaker[speakerId] = language;
      }
      update(ListenerTranslationPreferences(
        perSpeaker: perSpeaker,
        globalLanguage: current?.globalLanguage,
      ));
    } else {
      update(ListenerTranslationPreferences(
        perSpeaker: perSpeaker,
        globalLanguage: language,
      ));
    }
    return const HeadlessActionResult.success();
  } catch (error) {
    return HeadlessActionResult.failure(
        'The translation preference could not be set: $error');
  }
}

class FocusModeState {
  final bool active;
  final List<Participant> panelists;
  final bool selfIsPanelist;
  final bool mutesMicrophones;
  final bool mutesCameras;

  const FocusModeState({
    required this.active,
    required this.panelists,
    required this.selfIsPanelist,
    required this.mutesMicrophones,
    required this.mutesCameras,
  });
}

FocusModeState getFocusModeState(MediasfuParameters parameters) =>
    FocusModeState(
      active: parameters.panelistsFocused,
      panelists: List<Participant>.unmodifiable(parameters.panelists),
      selfIsPanelist:
          parameters.panelists.any((entry) => entry.name == parameters.member),
      mutesMicrophones: parameters.muteOthersMic,
      mutesCameras: parameters.muteOthersCamera,
    );

class VirtualBackgroundState {
  final bool active;
  final MediaStream? stream;
  final bool applied;
  final String? selectedImage;

  const VirtualBackgroundState({
    required this.active,
    required this.stream,
    required this.applied,
    required this.selectedImage,
  });
}

VirtualBackgroundState getVirtualBackgroundState(
    MediasfuParameters parameters) {
  final stream = parameters.virtualStream ?? parameters.processedStream;
  return VirtualBackgroundState(
    active: parameters.keepBackground && stream != null,
    stream: stream,
    applied: parameters.appliedBackground,
    selectedImage: parameters.selectedImage,
  );
}

Future<Map<String, dynamic>> _emitAck(
  MediasfuParameters parameters,
  String event,
  Map<String, dynamic> payload,
) async {
  final socket = parameters.socket;
  if (socket == null) throw StateError('The room connection is not ready.');
  final completer = Completer<Map<String, dynamic>>();
  socket.emitWithAck(event, payload, ack: (dynamic response) {
    if (!completer.isCompleted) {
      completer.complete(response is Map
          ? Map<String, dynamic>.from(response)
          : <String, dynamic>{'success': false});
    }
  });
  return completer.future.timeout(const Duration(seconds: 10));
}

Future<HeadlessActionResult> setBreakoutRooms(
  MediasfuParameters parameters,
  List<List<BreakoutParticipant>> rooms, {
  String newParticipantAction = 'autoAssignNewRoom',
}) async {
  if (parameters.islevel != '2') {
    return const HeadlessActionResult.failure(
        'Only the host can change breakout rooms.');
  }
  if (parameters.socket == null || parameters.roomName.isEmpty) {
    return const HeadlessActionResult.failure(
        'The room connection is not ready.');
  }
  try {
    final running =
        parameters.breakOutRoomStarted && !parameters.breakOutRoomEnded;
    final normalized = rooms
        .asMap()
        .entries
        .map((room) => room.value
            .map((person) => BreakoutParticipant(
                  name: person.name,
                  breakRoom: room.key,
                ))
            .toList(growable: false))
        .toList(growable: false);
    final response = await _emitAck(
      parameters,
      running ? 'updateBreakout' : 'startBreakout',
      {
        'breakoutRooms': normalized
            .map((room) => room.map((person) => person.toMap()).toList())
            .toList(),
        'newParticipantAction': newParticipantAction,
        'roomName': parameters.roomName,
      },
    );
    if (response['success'] != true) {
      return HeadlessActionResult.failure(response['reason']?.toString() ??
          'The breakout rooms could not be updated.');
    }
    parameters.updateBreakoutRooms(normalized);
    parameters.updateBreakOutRoomStarted(true);
    parameters.updateBreakOutRoomEnded(false);
    return const HeadlessActionResult.success();
  } catch (error) {
    return HeadlessActionResult.failure(
        'The breakout rooms could not be updated: $error');
  }
}

Future<HeadlessActionResult> assignParticipantToBreakoutRoom(
  MediasfuParameters parameters, {
  required String name,
  int? room,
  String newParticipantAction = 'autoAssignNewRoom',
}) {
  if (name.isEmpty) {
    return Future.value(
        const HeadlessActionResult.failure('A participant name is required.'));
  }
  if (room != null && room < 0) {
    return Future.value(const HeadlessActionResult.failure(
        'The destination room must be a room index.'));
  }
  final next = parameters.breakoutRooms
      .map((entry) =>
          entry.where((person) => person.name != name).toList(growable: true))
      .toList(growable: true);
  if (room != null) {
    while (next.length <= room) {
      next.add(<BreakoutParticipant>[]);
    }
    next[room].add(BreakoutParticipant(name: name, breakRoom: room));
  }
  return setBreakoutRooms(parameters, next,
      newParticipantAction: newParticipantAction);
}

Future<HeadlessActionResult> stopBreakoutRooms(
    MediasfuParameters parameters) async {
  if (parameters.islevel != '2') {
    return const HeadlessActionResult.failure(
        'Only the host can stop breakout rooms.');
  }
  if (parameters.socket == null || parameters.roomName.isEmpty) {
    return const HeadlessActionResult.failure(
        'The room connection is not ready.');
  }
  try {
    final response = await _emitAck(
        parameters, 'stopBreakout', {'roomName': parameters.roomName});
    if (response['success'] != true) {
      return HeadlessActionResult.failure(response['reason']?.toString() ??
          'The breakout rooms could not be stopped.');
    }
    parameters.updateBreakOutRoomStarted(false);
    parameters.updateBreakOutRoomEnded(true);
    return const HeadlessActionResult.success();
  } catch (error) {
    return HeadlessActionResult.failure(
        'The breakout rooms could not be stopped: $error');
  }
}
