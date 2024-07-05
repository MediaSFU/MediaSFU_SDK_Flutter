import 'package:flutter/foundation.dart';

typedef UpdateBreakoutRooms = void Function(List<dynamic>);
typedef UpdateBreakOutRoomStarted = void Function(bool);
typedef UpdateBreakOutRoomEnded = void Function(bool);
typedef UpdateHostNewRoom = void Function(int);
typedef UpdateMeetingDisplayType = void Function(String);
typedef UpdateParticipantsAll = void Function(List<dynamic>);
typedef UpdateParticipants = void Function(List<dynamic>);
typedef OnScreenChanges = Future<void> Function(
    {bool changed, required Map<String, dynamic> parameters});
typedef RePort = Future<void> Function(
    {bool restart, required Map<String, dynamic> parameters});
typedef ShowAlert = void Function(
    {required String message, required String type, required int duration});

Future<void> breakoutRoomUpdated({
  required Map<String, dynamic> data,
  required Map<String, dynamic> parameters,
}) async {
  try {
    bool breakOutRoomStarted = parameters['breakOutRoomStarted'] ?? false;
    bool breakOutRoomEnded = parameters['breakOutRoomEnded'] ?? false;
    String islevel = parameters['islevel'] ?? '1';
    OnScreenChanges onScreenChanges = parameters['onScreenChanges'];
    List<dynamic> participantsAll = parameters['participantsAll'] ?? [];
    List<dynamic> participants = parameters['participants'] ?? [];

    UpdateBreakoutRooms updateBreakoutRooms = parameters['updateBreakoutRooms'];
    UpdateBreakOutRoomStarted updateBreakOutRoomStarted =
        parameters['updateBreakOutRoomStarted'];
    UpdateBreakOutRoomEnded updateBreakOutRoomEnded =
        parameters['updateBreakOutRoomEnded'];
    UpdateHostNewRoom updateHostNewRoom = parameters['updateHostNewRoom'];
    UpdateMeetingDisplayType updateMeetingDisplayType =
        parameters['updateMeetingDisplayType'];
    String meetingDisplayType = parameters['meetingDisplayType'];
    String prevMeetingDisplayType = parameters['prevMeetingDisplayType'];
    UpdateParticipantsAll updateParticipantsAll =
        parameters['updateParticipantsAll'];
    UpdateParticipants updateParticipants = parameters['updateParticipants'];

    RePort rePort = parameters['rePort'];

    if (data['forHost']) {
      updateHostNewRoom(data['newRoom']);
      await onScreenChanges(changed: true, parameters: parameters);
      return;
    }

    if (islevel == '2' && data['members'] != null) {
      participantsAll = data['members']
          .map((participant) => {
                'isBanned': participant['isBanned'],
                'name': participant['name']
              })
          .toList();
      updateParticipantsAll(participantsAll);

      participants = data['members']
          .where((participant) => participant['isBanned'] == false)
          .toList();
      updateParticipants(participants);
    }

    updateBreakoutRooms(data['breakoutRooms']);

    if (data['status'] == 'started' &&
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
      await onScreenChanges(changed: true, parameters: parameters);
      if (islevel == '2') {
        await rePort(restart: true, parameters: parameters);
      }
    } else if (data['status'] == 'ended') {
      breakOutRoomEnded = true;
      updateBreakOutRoomEnded(true);
      if (meetingDisplayType != prevMeetingDisplayType) {
        updateMeetingDisplayType(prevMeetingDisplayType);
      }
      await onScreenChanges(changed: true, parameters: parameters);
      if (islevel == '2') {
        await rePort(restart: true, parameters: parameters);
      }
    } else if (data['status'] == 'started' && breakOutRoomStarted) {
      breakOutRoomStarted = true;
      breakOutRoomEnded = false;
      updateBreakOutRoomStarted(true);
      updateBreakOutRoomEnded(false);
      await onScreenChanges(changed: true, parameters: parameters);
      if (islevel == '2') {
        await rePort(restart: true, parameters: parameters);
      }
    }
  } catch (error) {
    if (kDebugMode) {
      print('Error in breakoutRoomUpdated: $error');
    }
  }
}
