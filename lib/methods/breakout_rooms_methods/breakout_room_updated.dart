import 'package:flutter/foundation.dart';
import '../../types/types.dart'
    show
        BreakoutParticipant,
        BreakoutRoomUpdatedData,
        OnScreenChangesParameters,
        OnScreenChangesType,
        Participant,
        RePortParameters,
        RePortType,
        OnScreenChangesOptions,
        RePortOptions;

// Type definitions
typedef UpdateBreakoutRooms = void Function(
    List<List<BreakoutParticipant>> rooms);
typedef UpdateBreakOutRoomStarted = void Function(bool started);
typedef UpdateBreakOutRoomEnded = void Function(bool ended);
typedef UpdateHostNewRoom = void Function(int room);
typedef UpdateMeetingDisplayType = void Function(String type);
typedef UpdateParticipantsAll = void Function(List<Participant> participants);
typedef UpdateParticipants = void Function(List<Participant> participants);

// Abstract class for parameters
abstract class BreakoutRoomUpdatedParameters
    implements OnScreenChangesParameters, RePortParameters {
  bool get breakOutRoomStarted;
  bool get breakOutRoomEnded;
  List<List<BreakoutParticipant>> get breakoutRooms;
  int get hostNewRoom;
  String get islevel;
  List<Participant> get participantsAll;
  List<Participant> get participants;
  String get meetingDisplayType;
  String get prevMeetingDisplayType;

  UpdateBreakoutRooms get updateBreakoutRooms;
  UpdateBreakOutRoomStarted get updateBreakOutRoomStarted;
  UpdateBreakOutRoomEnded get updateBreakOutRoomEnded;
  UpdateHostNewRoom get updateHostNewRoom;
  UpdateMeetingDisplayType get updateMeetingDisplayType;
  UpdateParticipantsAll get updateParticipantsAll;
  UpdateParticipants get updateParticipants;

  OnScreenChangesType get onScreenChanges;
  RePortType get rePort;

  BreakoutRoomUpdatedParameters Function() get getUpdatedAllParams;
}

class BreakoutRoomUpdatedOptions {
  final BreakoutRoomUpdatedData data;
  final BreakoutRoomUpdatedParameters parameters;

  BreakoutRoomUpdatedOptions({
    required this.data,
    required this.parameters,
  });
}

typedef BreakoutRoomUpdatedType = Future<void> Function(
    BreakoutRoomUpdatedOptions options);

/// Handles breakout room updates based on the received data and parameters.
///
/// ### Parameters:
/// - `options` (`BreakoutRoomUpdatedOptions`): Contains:
///   - `data`: Breakout room update data with information like room status and participants.
///   - `parameters`: Provides access to state and update functions, including:
///     - `breakOutRoomStarted`, `breakOutRoomEnded`: Track breakout room states.
///     - `islevel`: Indicates the user’s permission level (e.g., host, participant).
///     - `participantsAll`, `participants`: Lists of all and active participants in the room.
///     - Update functions to change room states, participants, and meeting display type.
///
/// ### Workflow:
/// 1. **Host Room Update**:
///    - If the data is for the host (`data.forHost`), it updates the host's room and triggers a screen update.
///
/// 2. **Participant Updates for Level 2 (Host/Moderator)**:
///    - Updates the participant list if the user has a level 2 role and data for members is available.
///
/// 3. **Room Status Change**:
///    - If the room `status` is "started":
///      - Sets `breakOutRoomStarted` to true and updates display to show all participants.
///      - Triggers a port restart for level 2 users.
///    - If the room `status` is "ended":
///      - Sets `breakOutRoomEnded` to true and restores the previous meeting display type.
///
/// ### Example Usage:
/// ```dart
/// final data = BreakoutRoomUpdatedData(
///   forHost: true,
///   newRoom: 1,
///   status: 'started',
///   breakoutRooms: [],
///   members: [
///     Participant(name: 'John', audioID: 'a1', videoID: 'v1', isBanned: false)
///   ],
/// );
///
/// final parameters = BreakoutRoomUpdatedParameters(
///   breakOutRoomStarted: false,
///   breakOutRoomEnded: false,
///   meetingDisplayType: 'individual',
///   updateBreakOutRoomStarted: (started) => print('Breakout started: $started'),
///   // Additional required updates and properties...
/// );
///
/// final options = BreakoutRoomUpdatedOptions(data: data, parameters: parameters);
///
/// await breakoutRoomUpdated(options);
/// ```
///
/// ### Error Handling:
/// - If an error occurs during the update process, it prints the error message in debug mode.

Future<void> breakoutRoomUpdated(BreakoutRoomUpdatedOptions options) async {
  final parameters = options.parameters.getUpdatedAllParams();

  bool breakOutRoomStarted = parameters.breakOutRoomStarted;
  bool breakOutRoomEnded = parameters.breakOutRoomEnded;
  String islevel = parameters.islevel;
  List<Participant> participantsAll = parameters.participantsAll;
  List<Participant> participants = parameters.participants;
  String meetingDisplayType = parameters.meetingDisplayType;
  String prevMeetingDisplayType = parameters.prevMeetingDisplayType;

  final updateBreakoutRooms = parameters.updateBreakoutRooms;
  final updateBreakOutRoomStarted = parameters.updateBreakOutRoomStarted;
  final updateBreakOutRoomEnded = parameters.updateBreakOutRoomEnded;
  final updateHostNewRoom = parameters.updateHostNewRoom;
  final updateMeetingDisplayType = parameters.updateMeetingDisplayType;
  final updateParticipantsAll = parameters.updateParticipantsAll;
  final updateParticipants = parameters.updateParticipants;
  final onScreenChanges = parameters.onScreenChanges;
  final rePort = parameters.rePort;

  final data = options.data;

  try {
    if (data.forHost != null && data.forHost!) {
      if (data.newRoom != null) {
        updateHostNewRoom(data.newRoom ?? -1);
      }
      await onScreenChanges(OnScreenChangesOptions(
        changed: true,
        parameters: parameters,
      ));
      return;
    }

    if (islevel == '2' && data.members != null) {
      participantsAll = data.members!
          .map((participant) => Participant(
                isBanned: participant.isBanned,
                name: participant.name,
                audioID: participant.audioID,
                videoID: participant.videoID,
              ))
          .toList();
      updateParticipantsAll(participantsAll);

      participants =
          data.members!.where((participant) => !participant.isBanned!).toList();
      updateParticipants(participants);
    }

    updateBreakoutRooms(data.breakoutRooms!);

    if (data.status == 'started' &&
        (breakOutRoomStarted || !breakOutRoomEnded)) {
      breakOutRoomStarted = true;
      breakOutRoomEnded = false;
      updateBreakOutRoomStarted(true);
      updateBreakOutRoomEnded(false);

      prevMeetingDisplayType = meetingDisplayType;
      if (meetingDisplayType != 'all') {
        meetingDisplayType = 'all';
        updateMeetingDisplayType('all');
      }
      await onScreenChanges(OnScreenChangesOptions(
        changed: true,
        parameters: parameters,
      ));
      if (islevel == '2') {
        await rePort(RePortOptions(restart: true, parameters: parameters));
      }
    } else if (data.status == 'ended') {
      breakOutRoomEnded = true;
      updateBreakOutRoomEnded(true);

      if (meetingDisplayType != prevMeetingDisplayType) {
        updateMeetingDisplayType(prevMeetingDisplayType);
      }
      await onScreenChanges(OnScreenChangesOptions(
        changed: true,
        parameters: parameters,
      ));
      if (islevel == '2') {
        await rePort(RePortOptions(restart: true, parameters: parameters));
      }
    } else if (data.status == 'started' && breakOutRoomStarted) {
      breakOutRoomStarted = true;
      breakOutRoomEnded = false;
      updateBreakOutRoomStarted(true);
      updateBreakOutRoomEnded(false);
      await onScreenChanges(OnScreenChangesOptions(
        changed: true,
        parameters: parameters,
      ));
      if (islevel == '2') {
        await rePort(RePortOptions(restart: true, parameters: parameters));
      }
    }
  } catch (error) {
    if (kDebugMode) {
      print('Error in breakoutRoomUpdated: $error');
    }
  }
}
