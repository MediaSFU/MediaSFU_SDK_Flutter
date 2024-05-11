// ignore_for_file: empty_catches

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// This function handles the logic for updating members and settings in a video conferencing application.
/// It takes in various parameters including the list of members, settings, co-host information, and API credentials.
/// The function performs operations such as extracting callback functions, updating participants, connecting to the server,
/// and updating UI based on the received data.
///
/// The function also includes typedefs for different callback functions and Mediasfu functions.
///
/// Example usage:
/// ```dart
/// await allMembersRest(
///   members: [...],
///   settings: [...],
///   coHoste: '...',
///   coHostRes: [...],
///   parameters: {...},
///   consumeSockets: [...],
///   apiUserName: '...',
///   apiKey: '...',
///   apiToken: '...',
/// );
///

typedef UpdateParticipantsAll = void Function(List<dynamic>);
typedef UpdateParticipants = void Function(List<dynamic>);
typedef UpdateRequestList = void Function(List<dynamic>);
typedef UpdateCoHost = void Function(String);
typedef UpdateCoHostResponsibility = void Function(List<dynamic>);
typedef UpdateFirstAll = void Function(bool);
typedef UpdateMembersReceived = void Function(bool);
typedef UpdateDeferScreenReceived = void Function(bool);
typedef UpdateShareScreenStarted = void Function(bool);
typedef UpdateHostFirstSwitch = void Function(bool);
typedef UpdateMeetingDisplayType = void Function(String);
typedef UpdateAudioSetting = void Function(String);
typedef UpdateVideoSetting = void Function(String);
typedef UpdateScreenshareSetting = void Function(String);
typedef UpdateChatSetting = void Function(String);
typedef UpdateConsumeSockets = void Function(List<Map<String, io.Socket>>);
typedef UpdateRoomRecvIPs = void Function(List<dynamic>);
typedef UpdateIsLoadingModalVisible = void Function(bool);

typedef NewProducerMethod = Future<void> Function({
  required String producerId,
  required String islevel,
  required io.Socket nsock,
  required Map<String, dynamic> parameters,
});

typedef ClosedProducerMethod = Future<void> Function({
  required String remoteProducerId,
  required Map<String, dynamic> parameters,
});

typedef JoinConsumeRoomMethod = Future<Map<String, dynamic>> Function({
  required io.Socket remoteSock,
  required String apiToken,
  required String apiUserName,
  required Map<String, dynamic> parameters,
});

typedef ConnectIps = Future<List<dynamic>> Function({
  required List<Map<String, io.Socket>> consumeSockets,
  required List<dynamic> remIP,
  required String apiUserName,
  String? apiKey,
  String? apiToken,
  NewProducerMethod? newProducerMethod,
  ClosedProducerMethod? closedProducerMethod,
  JoinConsumeRoomMethod? joinConsumeRoomMethod,
  required Map<String, dynamic> parameters,
});

// Mediasfu functions
typedef OnScreenChanges = Future<void> Function(
    {bool changed, required Map<String, dynamic> parameters});
typedef FormatNumber = String Function(int);
typedef Sleep = Future<void> Function(int);
typedef ReorderStreams = Future<void> Function({
  bool add,
  bool screenChanged,
  required Map<String, dynamic> parameters,
});
Future<void> allMembersRest({
  required List<dynamic> members,
  required List<dynamic> settings,
  required String coHoste,
  required List<dynamic> coHostRes,
  required Map<String, dynamic> parameters,
  required List<Map<String, io.Socket>> consumeSockets,
  required String apiUserName,
  required String apiKey,
  required String apiToken,
}) async {
  // Extracting callback functions from parameters
  try {
    List<dynamic> participantsAll = parameters['participantsAll'] ?? [];
    List<dynamic> participants = parameters['participants'] ?? [];
    List<String> dispActiveNames = parameters['dispActiveNames'] ?? [];
    List<dynamic> requestList = parameters['requestList'] ?? [];
    String coHost = parameters['coHost'] ?? '';
    bool lockScreen = parameters['lockScreen'] ?? false;
    bool firstAll = parameters['firstAll'] ?? false;
    bool membersReceived = parameters['membersReceived'] ?? false;
    List<dynamic> roomRecvIPs = parameters['roomRecvIPs'] ?? [];
    bool deferScreenReceived = parameters['deferScreenReceived'] ?? false;
    bool shareScreenStarted = parameters['shareScreenStarted'] ?? false;
    String? screenId = parameters['screenId'] ?? '';
    String? meetingDisplayType = parameters['meetingDisplayType'] ?? '';
    String? audioSetting = parameters['audioSetting'] ?? 'allow';
    String? videoSetting = parameters['videoSetting'] ?? 'allow';
    String? screenshareSetting = parameters['screenshareSetting'] ?? 'allow';
    String? chatSetting = parameters['chatSetting'] ?? 'allow';

    // Update functions
    void Function(List<dynamic>) updateParticipantsAll =
        parameters['updateParticipantsAll'];
    parameters['updateParticipantsAll'];
    void Function(List<dynamic>) updateParticipants =
        parameters['updateParticipants'];
    void Function(List<dynamic>) updateRequestList =
        parameters['updateRequestList'];
    void Function(String) updateCoHost = parameters['updateCoHost'];
    void Function(List<dynamic>) updateCoHostResponsibility =
        parameters['updateCoHostResponsibility'];
    void Function(bool) updateFirstAll = parameters['updateFirstAll'];
    void Function(bool) updateMembersReceived =
        parameters['updateMembersReceived'];

    void Function(bool) updateDeferScreenReceived =
        parameters['updateDeferScreenReceived'];
    void Function(bool) updateShareScreenStarted =
        parameters['updateShareScreenStarted'];
    UpdateAudioSetting updateAudioSetting = parameters['updateAudioSetting'];
    UpdateVideoSetting updateVideoSetting = parameters['updateVideoSetting'];
    UpdateScreenshareSetting updateScreenshareSetting =
        parameters['updateScreenshareSetting'];
    UpdateChatSetting updateChatSetting = parameters['updateChatSetting'];
    UpdateConsumeSockets updateConsumeSockets =
        parameters['updateConsumeSockets'];
    void Function(List<dynamic>) updateRoomRecvIPs =
        parameters['updateRoomRecvIPs'];
    void Function(bool) updateIsLoadingModalVisible =
        parameters['updateIsLoadingModalVisible'];

// Mediasfu functions
    OnScreenChanges onScreenChanges = parameters['onScreenChanges'];
    ConnectIps connectIps = parameters['connectIps'];
    Future<void> Function({
      bool add,
      bool screenChanged,
      required Map<String, dynamic> parameters,
    }) reorderStreams = parameters['reorderStreams'];

    participantsAll = members
        .map((participant) => {
              'isBanned': participant['isBanned'],
              'isSuspended': participant['isSuspended'],
              'name': participant['name'],
            })
        .toList();
    updateParticipantsAll(participantsAll);

    participants = members
        .where((participant) =>
            !participant['isBanned'] && !participant['isSuspended'])
        .toList();
    updateParticipants(participants);

    // Check if dispActiveNames is not empty and contains the name of the participant that is not in the participants array
    if (dispActiveNames.isNotEmpty) {
      // Check if the participant that is not in the participants array is in the dispActiveNames array
      List<dynamic> dispActiveNames_ = dispActiveNames
          .where((name) =>
              !participants.any((participant) => participant['name'] == name))
          .toList();
      if (dispActiveNames_.isNotEmpty) {
        // Remove the participant that is not in the participants array from the dispActiveNames array
        await reorderStreams(
            add: false, screenChanged: true, parameters: parameters);
      }
    }

    // Operations to update the UI; make sure we are connected to the server before updating the UI
    if (!membersReceived) {
      if (roomRecvIPs.isEmpty) {
        // Keep checking every 0.005s
        Timer.periodic(const Duration(milliseconds: 5), (timer) async {
          if (roomRecvIPs.isNotEmpty) {
            timer.cancel();

            if (deferScreenReceived && screenId != null) {
              shareScreenStarted = true;
              updateShareScreenStarted(shareScreenStarted);
            }

            var socketsAndIps = await connectIps(
                consumeSockets: consumeSockets,
                parameters: parameters,
                apiUserName: apiUserName,
                apiKey: apiKey,
                apiToken: apiToken,
                remIP: roomRecvIPs);

            if (socketsAndIps.isNotEmpty) {
              updateConsumeSockets(socketsAndIps[0]);
              updateRoomRecvIPs(socketsAndIps[1]);
            }

            membersReceived = true;
            updateMembersReceived(membersReceived);

            await Future.delayed(const Duration(milliseconds: 250));
            updateIsLoadingModalVisible(false);
            deferScreenReceived = false;
            updateDeferScreenReceived(deferScreenReceived);
          }
        });
      } else {
        var socketsAndIps = await connectIps(
            consumeSockets: consumeSockets,
            parameters: parameters,
            apiUserName: apiUserName,
            apiKey: apiKey,
            apiToken: apiToken,
            remIP: roomRecvIPs);
        if (socketsAndIps.isNotEmpty) {
          updateConsumeSockets(socketsAndIps[0]);
          updateRoomRecvIPs(socketsAndIps[1]);
        }

        membersReceived = true;
        updateMembersReceived(membersReceived);

        if (deferScreenReceived && screenId != null) {
          shareScreenStarted = true;
          updateShareScreenStarted(shareScreenStarted);
        }

        await Future.delayed(const Duration(milliseconds: 250));
        updateIsLoadingModalVisible(false);
        deferScreenReceived = false;
        updateDeferScreenReceived(deferScreenReceived);
      }
    } else {
      if (screenId != null && screenId.isNotEmpty) {
        var host = participants.firstWhere(
            (participant) =>
                participant['ScreenID'] == screenId &&
                participant['ScreenOn'] == true,
            orElse: () => <String, dynamic>{});
        if (deferScreenReceived &&
            host != null &&
            host.isNotEmpty &&
            screenId.isNotEmpty) {
          shareScreenStarted = true;
          updateShareScreenStarted(shareScreenStarted);
        }
      }
    }

    List<dynamic> updatedRequestList = requestList
        .where((request) => participants
            .any((participant) => participant['id'] == request['id']))
        .toList();
    updateRequestList(updatedRequestList);

    coHost = coHoste;
    updateCoHost(coHost);
    updateCoHostResponsibility(coHostRes);

    try {
      if (!lockScreen && !firstAll) {
        await onScreenChanges(parameters: parameters);
        if (meetingDisplayType != 'all') {
          firstAll = true;
          updateFirstAll(firstAll);
        }
      }
    } catch (error) {}

    try {
      if (membersReceived) {
        audioSetting = settings[0];
        videoSetting = settings[1];
        screenshareSetting = settings[2];
        chatSetting = settings[3];
        updateAudioSetting(audioSetting!);
        updateVideoSetting(videoSetting!);
        updateScreenshareSetting(screenshareSetting!);
        updateChatSetting(chatSetting!);
      }
    } catch (error) {
      rethrow;
    }
  } catch (error) {
    if (kDebugMode) {
      print('Errors in allMembersRest: $error');
    }
    rethrow;
  }
}
