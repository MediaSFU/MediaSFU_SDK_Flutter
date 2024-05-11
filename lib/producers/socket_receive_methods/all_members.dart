// ignore_for_file: empty_catches

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// This file contains various typedefs and functions related to handling members in a meeting.
/// It includes callback functions, methods for joining and consuming rooms, and functions for updating UI.
/// The [allMembers] function is the main function that handles the logic for updating participants, connecting to sockets, and updating UI based on the received data.
/// It takes in various parameters including lists of members, requests, co-hosts, and consume sockets, as well as API credentials.
/// The function extracts callback functions and other parameters from the provided map and performs the necessary operations.
/// It updates the participantsAll and participants arrays with the received member data, checks for active names, connects to sockets, and updates UI based on the received data.
/// The function also handles the case when the screen is shared and updates the shareScreenStarted flag accordingly.
/// It uses the provided callback functions to update the UI and performs additional operations related to Mediasfu.
/// The function is asynchronous and returns a Future<void>.

typedef UpdateParticipantsAll = void Function(List<Map<String, dynamic>>);
typedef UpdateParticipants = void Function(List<Map<String, dynamic>>);
typedef UpdateRequestList = void Function(List<dynamic>);
typedef UpdateCoHost = void Function(String);
typedef UpdateCoHostResponsibility = void Function(List<Map<String, dynamic>>);
typedef UpdateFirstAll = void Function(bool);
typedef UpdateMembersReceived = void Function(bool);
typedef UpdateDeferScreenReceived = void Function(bool);
typedef UpdateShareScreenStarted = void Function(bool);
typedef UpdateHostFirstSwitch = void Function(bool);
typedef UpdateMeetingDisplayType = void Function(String);
typedef UpdateAudioSetting = void Function(String?);
typedef UpdateVideoSetting = void Function(String?);
typedef UpdateScreenshareSetting = void Function(String?);
typedef UpdateChatSetting = void Function(String?);
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

Future<void> allMembers({
  required List<dynamic> members,
  required List<dynamic> requestss,
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
    String coHost = parameters['coHost'] ?? '';
    bool lockScreen = parameters['lockScreen'] ?? false;
    bool firstAll = parameters['firstAll'] ?? false;
    bool membersReceived = parameters['membersReceived'] ?? false;
    List<dynamic> roomRecvIPs = parameters['roomRecvIPs'] ?? [];
    bool deferScreenReceived = parameters['deferScreenReceived'] ?? false;
    bool shareScreenStarted = parameters['shareScreenStarted'] ?? false;
    String? screenId = parameters['screenId'] ?? '';
    String? meetingDisplayType = parameters['meetingDisplayType'] ?? '';
    bool hostFirstSwitch = parameters['hostFirstSwitch'] ?? false;
    List<dynamic> waitingRoomList = parameters['waitingRoomList'] ?? [];
    String? islevel = parameters['islevel'] ?? '1';

    Function(List<dynamic>) updateParticipantsAll =
        parameters['updateParticipantsAll'];
    parameters['updateParticipantsAll'];
    Function(List<dynamic>) updateParticipants =
        parameters['updateParticipants'];
    Function(List<dynamic>) updateRequestList = parameters['updateRequestList'];
    Function(String) updateCoHost = parameters['updateCoHost'];
    Function(List<dynamic>) updateCoHostResponsibility =
        parameters['updateCoHostResponsibility'];
    Function(bool) updateFirstAll = parameters['updateFirstAll'];
    Function(bool) updateMembersReceived = parameters['updateMembersReceived'];

    Function(bool) updateDeferScreenReceived =
        parameters['updateDeferScreenReceived'];
    Function(bool) updateShareScreenStarted =
        parameters['updateShareScreenStarted'];
    Function(bool) updateHostFirstSwitch = parameters['updateHostFirstSwitch'];
    UpdateConsumeSockets updateConsumeSockets =
        parameters['updateConsumeSockets'];
    Function(List<dynamic>) updateRoomRecvIPs = parameters['updateRoomRecvIPs'];
    Function(bool) updateIsLoadingModalVisible =
        parameters['updateIsLoadingModalVisible'];
    Function(int) updateTotalReqWait = parameters['updateTotalReqWait'];

    // Mediasfu functions
    OnScreenChanges onScreenChanges = parameters['onScreenChanges'];
    ConnectIps connectIps = parameters['connectIps'];
    Future<void> Function({
      bool add,
      bool screenChanged,
      required Map<String, dynamic> parameters,
    }) reorderStreams = parameters['reorderStreams'];

    try {
      // Update the participantsAll array with the name, isBanned, and isSuspended values
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

      // Return requests for only ids that are in the participants array and update the count badge
      List<dynamic> updatedRequestList = requestss
          .where((request) => participants
              .any((participant) => participant['id'] == request['id']))
          .toList();
      updateRequestList(updatedRequestList);
      updateTotalReqWait(updatedRequestList.length + waitingRoomList.length);

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
        } else {
          if (islevel == '2') {
            if (!hostFirstSwitch) {
              await onScreenChanges(parameters: parameters);
              hostFirstSwitch = true;
              updateHostFirstSwitch(hostFirstSwitch);
            }
          }
        }
      } catch (error) {}
    } catch (error) {
      rethrow;
    }
  } catch (error) {
    if (kDebugMode) {
      print('Errors in allMembers: $error');
    }
    rethrow;
  }
}
