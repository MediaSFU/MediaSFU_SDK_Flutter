import 'dart:async';

import '../../../types/types.dart' show Poll, WhiteboardUser;
import '../../recording_methods/confirm_recording.dart';
import '../../recording_methods/start_recording.dart';
import '../../recording_methods/stop_recording.dart';
import '../../recording_methods/update_recording.dart';
import '../mediasfu_parameters.dart' show MediasfuParameters;
import 'room_actions.dart' show HeadlessActionResult;

enum RecordingStatus { unavailable, idle, recording, paused, stopped }

class RecordingState {
  final RecordingStatus status;
  final bool active;
  final bool canRecord;
  final String mediaOptions;
  final int elapsedSeconds;

  const RecordingState({
    required this.status,
    required this.active,
    required this.canRecord,
    required this.mediaOptions,
    required this.elapsedSeconds,
  });
}

RecordingState getRecordingState(MediasfuParameters parameters) {
  var status = RecordingStatus.idle;
  if (!parameters.canRecord && !parameters.recordStarted) {
    status = RecordingStatus.unavailable;
  } else if (parameters.recordStopped) {
    status = RecordingStatus.stopped;
  } else if (parameters.recordStarted && parameters.recordPaused) {
    status = RecordingStatus.paused;
  } else if (parameters.recordStarted) {
    status = RecordingStatus.recording;
  }
  return RecordingState(
    status: status,
    active: status == RecordingStatus.recording,
    canRecord: parameters.canRecord,
    mediaOptions: parameters.recordingMediaOptions,
    elapsedSeconds: parameters.recordElapsedTime,
  );
}

Future<HeadlessActionResult> startRoomRecording(
    MediasfuParameters parameters) async {
  if (!parameters.canRecord) {
    return const HeadlessActionResult.failure(
        'Recording is not available in this room.');
  }
  if (parameters.recordStarted && !parameters.recordStopped) {
    return const HeadlessActionResult.failure('Recording has already started.');
  }
  try {
    await confirmRecording(ConfirmRecordingOptions(parameters: parameters));
    final started =
        await startRecording(StartRecordingOptions(parameters: parameters));
    return started == false
        ? const HeadlessActionResult.failure('Recording could not be started.')
        : const HeadlessActionResult.success();
  } catch (error) {
    return HeadlessActionResult.failure(
        'Recording could not be started: $error');
  }
}

Future<HeadlessActionResult> _toggleRecordingPause(
  MediasfuParameters parameters,
  bool pause,
) async {
  final state = getRecordingState(parameters);
  final expected = pause ? RecordingStatus.recording : RecordingStatus.paused;
  if (state.status != expected) {
    return HeadlessActionResult.failure(pause
        ? 'There is no active recording to pause.'
        : 'There is no paused recording to resume.');
  }
  try {
    await updateRecording(UpdateRecordingOptions(parameters: parameters));
    return const HeadlessActionResult.success();
  } catch (error) {
    return HeadlessActionResult.failure(
        'The recording state could not be changed: $error');
  }
}

Future<HeadlessActionResult> pauseRoomRecording(
        MediasfuParameters parameters) =>
    _toggleRecordingPause(parameters, true);

Future<HeadlessActionResult> resumeRoomRecording(
        MediasfuParameters parameters) =>
    _toggleRecordingPause(parameters, false);

Future<HeadlessActionResult> stopRoomRecording(
    MediasfuParameters parameters) async {
  if (!parameters.recordStarted || parameters.recordStopped) {
    return const HeadlessActionResult.failure(
        'There is no active recording to stop.');
  }
  try {
    await stopRecording(StopRecordingOptions(parameters: parameters));
    return const HeadlessActionResult.success();
  } catch (error) {
    return HeadlessActionResult.failure(
        'Recording could not be stopped: $error');
  }
}

class WhiteboardState {
  final bool active;
  final bool canStart;
  final List<WhiteboardUser> users;
  final int limit;
  final dynamic canvas;

  const WhiteboardState({
    required this.active,
    required this.canStart,
    required this.users,
    required this.limit,
    this.canvas,
  });
}

WhiteboardState getWhiteboardState(MediasfuParameters parameters) =>
    WhiteboardState(
      active: parameters.whiteboardStarted && !parameters.whiteboardEnded,
      canStart: parameters.canStartWhiteboard,
      users: List<WhiteboardUser>.unmodifiable(parameters.whiteboardUsers),
      limit: parameters.whiteboardLimit,
      canvas: parameters.canvasWhiteboard,
    );

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

Future<HeadlessActionResult> startWhiteboard(
  MediasfuParameters parameters, {
  List<WhiteboardUser>? users,
}) async {
  if (parameters.breakOutRoomStarted && !parameters.breakOutRoomEnded) {
    return const HeadlessActionResult.failure(
        'The whiteboard cannot start while breakout rooms are active.');
  }
  final state = getWhiteboardState(parameters);
  if (!state.active && !state.canStart) {
    return const HeadlessActionResult.failure(
        'You are not allowed to start the whiteboard.');
  }
  final selected = users ?? state.users;
  if (state.limit > 0 && selected.length > state.limit) {
    return HeadlessActionResult.failure(
        'The whiteboard allows at most ${state.limit} participants.');
  }
  try {
    final response = await _emitAck(
      parameters,
      state.active ? 'updateWhiteboard' : 'startWhiteboard',
      {
        'whiteboardUsers': selected.map((entry) => entry.toMap()).toList(),
        'roomName': parameters.roomName,
      },
    );
    if (response['success'] != true) {
      return HeadlessActionResult.failure(response['reason']?.toString() ??
          'The whiteboard could not be started.');
    }
    parameters.updateWhiteboardStarted(true);
    parameters.updateWhiteboardEnded(false);
    parameters.updateWhiteboardUsers(selected);
    parameters.updateCanStartWhiteboard(false);
    return const HeadlessActionResult.success();
  } catch (error) {
    return HeadlessActionResult.failure(
        'The whiteboard could not be started: $error');
  }
}

Future<HeadlessActionResult> stopWhiteboard(
    MediasfuParameters parameters) async {
  if (!getWhiteboardState(parameters).active) {
    return const HeadlessActionResult.failure('The whiteboard is not running.');
  }
  try {
    final response = await _emitAck(
        parameters, 'stopWhiteboard', {'roomName': parameters.roomName});
    if (response['success'] != true) {
      return HeadlessActionResult.failure(response['reason']?.toString() ??
          'The whiteboard could not be stopped.');
    }
    parameters.updateWhiteboardStarted(false);
    parameters.updateWhiteboardEnded(true);
    return const HeadlessActionResult.success();
  } catch (error) {
    return HeadlessActionResult.failure(
        'The whiteboard could not be stopped: $error');
  }
}

class PollState {
  final List<Poll> polls;
  final Poll? active;

  const PollState({required this.polls, this.active});
}

PollState getPollState(MediasfuParameters parameters) {
  Poll? active;
  if (parameters.poll?.status == 'active') {
    active = parameters.poll;
  } else {
    for (final item in parameters.polls) {
      if (item.status == 'active') {
        active = item;
        break;
      }
    }
  }
  return PollState(
      polls: List<Poll>.unmodifiable(parameters.polls), active: active);
}

Future<HeadlessActionResult> createRoomPoll(
  MediasfuParameters parameters, {
  required String question,
  required List<String> options,
  String type = 'custom',
}) async {
  if (question.trim().isEmpty) {
    return const HeadlessActionResult.failure('The poll needs a question.');
  }
  if (options.length < 2) {
    return const HeadlessActionResult.failure(
        'The poll needs at least two options.');
  }
  try {
    final response = await _emitAck(parameters, 'createPoll', {
      'roomName': parameters.roomName,
      'poll': {'question': question, 'options': options, 'type': type},
    });
    return response['success'] == true
        ? const HeadlessActionResult.success()
        : HeadlessActionResult.failure(
            response['reason']?.toString() ?? 'The poll could not be created.');
  } catch (error) {
    return HeadlessActionResult.failure(
        'The poll could not be created: $error');
  }
}

Future<HeadlessActionResult> voteInRoomPoll(
  MediasfuParameters parameters, {
  required String pollId,
  required int optionIndex,
}) async {
  try {
    final response = await _emitAck(parameters, 'votePoll', {
      'roomName': parameters.roomName,
      'poll_id': pollId,
      'member': parameters.member,
      'choice': optionIndex,
    });
    return response['success'] == true
        ? const HeadlessActionResult.success()
        : HeadlessActionResult.failure(
            response['reason']?.toString() ?? 'The vote could not be cast.');
  } catch (error) {
    return HeadlessActionResult.failure('The vote could not be cast: $error');
  }
}

Future<HeadlessActionResult> endRoomPoll(
  MediasfuParameters parameters, {
  required String pollId,
}) async {
  if (parameters.islevel != '2') {
    return const HeadlessActionResult.failure('Only the host can end a poll.');
  }
  try {
    final response = await _emitAck(parameters, 'endPoll', {
      'roomName': parameters.roomName,
      'poll_id': pollId,
    });
    return response['success'] == true
        ? const HeadlessActionResult.success()
        : HeadlessActionResult.failure(
            response['reason']?.toString() ?? 'The poll could not be ended.');
  } catch (error) {
    return HeadlessActionResult.failure('The poll could not be ended: $error');
  }
}

class BreakoutState {
  final bool active;
  final bool canStart;
  final List<List<dynamic>> rooms;
  final int currentRoom;

  const BreakoutState({
    required this.active,
    required this.canStart,
    required this.rooms,
    required this.currentRoom,
  });
}

BreakoutState getBreakoutState(MediasfuParameters parameters) => BreakoutState(
      active: parameters.breakOutRoomStarted && !parameters.breakOutRoomEnded,
      canStart: parameters.canStartBreakout,
      rooms: parameters.breakoutRooms
          .map<List<dynamic>>((room) => List<dynamic>.unmodifiable(room))
          .toList(growable: false),
      currentRoom: parameters.hostNewRoom,
    );
