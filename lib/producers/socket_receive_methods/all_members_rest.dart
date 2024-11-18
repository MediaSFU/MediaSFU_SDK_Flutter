import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../types/types.dart'
    show
        Participant,
        CoHostResponsibility,
        OnScreenChangesType,
        Request,
        ConnectIpsType,
        ReorderStreamsType,
        Settings,
        ConsumeSocket,
        ReorderStreamsOptions,
        SleepType,
        OnScreenChangesParameters,
        ConnectIpsParameters,
        ReorderStreamsParameters,
        OnScreenChangesOptions,
        SleepOptions,
        ConnectIpsOptions;

/// Callback function type definitions
typedef UpdateParticipantsAll = void Function(List<Participant>);
typedef UpdateParticipants = void Function(List<Participant>);
typedef UpdateRequestList = void Function(List<Request>);
typedef UpdateCoHost = void Function(String);
typedef UpdateCoHostResponsibility = void Function(List<CoHostResponsibility>);
typedef UpdateBoolean = void Function(bool);
typedef UpdateSetting = void Function(String);
typedef UpdateSockets = void Function(List<ConsumeSocket>);
typedef UpdateIPs = void Function(List<String>);

/// Contains all parameters required for handling member updates and configurations in the room.
abstract class AllMembersRestParameters
    implements
        OnScreenChangesParameters,
        ConnectIpsParameters,
        ReorderStreamsParameters {
  // Core properties as abstract getters
  List<Participant> get participantsAll;
  List<Participant> get participants;
  List<String> get dispActiveNames;
  List<Request> get requestList;
  String get coHost;
  List<CoHostResponsibility> get coHostResponsibility;
  bool get lockScreen;
  bool get firstAll;
  bool get membersReceived;
  List<String> get roomRecvIPs;
  bool get deferScreenReceived;
  String get screenId;
  bool get shareScreenStarted;
  String get meetingDisplayType;
  String get audioSetting;
  String get videoSetting;
  String get screenshareSetting;
  String get chatSetting;

  // Update functions as abstract getters
  UpdateParticipantsAll get updateParticipantsAll;
  UpdateParticipants get updateParticipants;
  UpdateRequestList get updateRequestList;
  UpdateCoHost get updateCoHost;
  UpdateCoHostResponsibility get updateCoHostResponsibility;
  UpdateBoolean get updateFirstAll;
  UpdateBoolean get updateMembersReceived;
  UpdateBoolean get updateDeferScreenReceived;
  UpdateBoolean get updateShareScreenStarted;
  UpdateSetting get updateAudioSetting;
  UpdateSetting get updateVideoSetting;
  UpdateSetting get updateScreenshareSetting;
  UpdateSetting get updateChatSetting;
  UpdateSockets get updateConsumeSockets;
  UpdateIPs get updateRoomRecvIPs;
  UpdateBoolean get updateIsLoadingModalVisible;

  // Mediasfu functions as abstract getters
  OnScreenChangesType get onScreenChanges;
  ConnectIpsType get connectIps;
  SleepType get sleep;
  ReorderStreamsType get reorderStreams;

  AllMembersRestParameters Function() get getUpdatedAllParams;

  // dynamic operator [](String key);
}

/// Options required for handling all members in the room.
class AllMembersRestOptions {
  List<Participant> members;
  Settings settings;
  String coHost;
  List<CoHostResponsibility> coHostRes;
  AllMembersRestParameters parameters;
  List<ConsumeSocket> consumeSockets;
  String apiUserName;
  String apiKey;
  String apiToken;

  AllMembersRestOptions({
    required this.members,
    required this.settings,
    required this.coHost,
    required this.coHostRes,
    required this.parameters,
    required this.consumeSockets,
    required this.apiUserName,
    required this.apiKey,
    required this.apiToken,
  });
}

typedef AllMembersRestType = Future<void> Function(
    AllMembersRestOptions options);

/// Main function to handle participant updates, settings, and server connections in the room.
///
/// This function processes participant lists, handles co-host responsibilities, filters requests,
/// manages settings, and establishes server connections for active members in the room. It updates
/// necessary UI states, such as screen share and connection settings, and processes actions
/// based on current participants and meeting configurations.
///
/// ### Example Usage:
/// ```dart
/// final parameters = AllMembersParameters(
///   participantsAll: [],
///   participants: [],
///   dispActiveNames: ['Alice', 'Bob'],
///   requestList: [Request(id: 'req1', name: 'Alice')],
///   coHost: 'Alice',
///   coHostResponsibility: [CoHostResponsibility(id: 'manage')],
///   lockScreen: false,
///   firstAll: false,
///   membersReceived: false,
///   roomRecvIPs: ['192.000.1.1'],
///   deferScreenReceived: true,
///   screenId: 'screen123',
///   shareScreenStarted: false,
///   meetingDisplayType: 'all',
///   audioSetting: 'allow',
///   videoSetting: 'allow',
///   screenshareSetting: 'allow',
///   chatSetting: 'allow',
///   updateParticipantsAll: (list) => print('Participants all updated: $list'),
///   updateParticipants: (list) => print('Filtered participants updated: $list'),
///   updateRequestList: (list) => print('Request list updated: $list'),
///   updateCoHost: (newCoHost) => print('Co-host updated: $newCoHost'),
///   updateCoHostResponsibility: (list) => print('Co-host responsibilities updated: $list'),
///   updateFirstAll: (value) => print('First all updated: $value'),
///   updateMembersReceived: (value) => print('Members received updated: $value'),
///   updateDeferScreenReceived: (value) => print('Defer screen received updated: $value'),
///   updateShareScreenStarted: (value) => print('Share screen started updated: $value'),
///   updateAudioSetting: (setting) => print('Audio setting updated: $setting'),
///   updateVideoSetting: (setting) => print('Video setting updated: $setting'),
///   updateScreenshareSetting: (setting) => print('Screenshare setting updated: $setting'),
///   updateChatSetting: (setting) => print('Chat setting updated: $setting'),
///   updateConsumeSockets: (sockets) => print('Consume sockets updated: $sockets'),
///   updateRoomRecvIPs: (ips) => print('Room receive IPs updated: $ips'),
///   updateIsLoadingModalVisible: (visible) => print('Loading modal visibility updated: $visible'),
///   onScreenChanges: (params) async => print('Screen changes detected'),
///   connectIps: (connectOptions) async => print('Connected to IPs with options: $connectOptions'),
///   sleep: (ms) async => print('Sleeping for $ms milliseconds'),
///   reorderStreams: (options) async => print('Reordered streams with options: $options'),
/// );
///
/// final options = AllMembersOptions(
///   members: [
///     Participant(name: 'Alice', audioID: 'audio1', videoID: 'video1', isBanned: false, isSuspended: false),
///     Participant(name: 'Bob', audioID: 'audio2', videoID: 'video2', isBanned: false, isSuspended: false),
///   ],
///   settings: ['allow', 'allow', 'allow', 'allow'],
///   coHost: 'Alice',
///   coHostRes: [CoHostResponsibility(id: 'manage')],
///   parameters: parameters,
///   consumeSockets: [
///     {'socket1': io.Socket()},
///     {'socket2': io.Socket()},
///   ],
///   apiUserName: 'user123',
///   apiKey: 'key123',
///   apiToken: 'token123',
/// );
///
/// await allMembersRest(options: options);
/// ```
///
/// In this example:
/// - The function updates participant lists, filters requests, and sets up co-host responsibilities.
/// - It handles connection settings by checking `roomRecvIPs`, updating consume sockets, and
///   handling screen share configurations as participants are processed.

Future<void> allMembersRest(
  AllMembersRestOptions options,
) async {
  final members = options.members;
  final settings = options.settings;
  final coHost = options.coHost;
  final coHostRes = options.coHostRes;
  final parameters = options.parameters;
  final consumeSockets = options.consumeSockets;
  final apiUserName = options.apiUserName;
  final apiKey = options.apiKey;
  final apiToken = options.apiToken;

  try {
    // Extract and initialize required variables
    var participantsAll = parameters.participantsAll;
    var participants = parameters.participants;
    final dispActiveNames = parameters.dispActiveNames;
    var requestList = parameters.requestList;
    final lockScreen = parameters.lockScreen;
    var firstAll = parameters.firstAll;
    var membersReceived = parameters.membersReceived;
    final roomRecvIPs = parameters.roomRecvIPs;
    final deferScreenReceived = parameters.deferScreenReceived;
    final screenId = parameters.screenId;
    final meetingDisplayType = parameters.meetingDisplayType;

    // Processing participants
    participantsAll =
        members.where((m) => !m.isBanned! && !m.isSuspended!).toList();
    parameters.updateParticipantsAll(participantsAll);

    participants =
        members.where((m) => !m.isBanned! && !m.isSuspended!).toList();
    parameters.updateParticipants(participants);

    // Handle dispActiveNames if not empty
    if (dispActiveNames.isNotEmpty) {
      final dispActiveNames_ = dispActiveNames
          .where((name) => !participants.any((p) => p.name == name))
          .toList();
      if (dispActiveNames_.isNotEmpty && membersReceived) {
        final optionsReorder = ReorderStreamsOptions(
          add: false,
          screenChanged: true,
          parameters: parameters,
        );
        await parameters.reorderStreams(
          optionsReorder,
        );
      }
    }

    // Checking roomRecvIPs and connecting to the server if not yet received
    if (!membersReceived) {
      if (roomRecvIPs.isEmpty) {
        Timer.periodic(const Duration(milliseconds: 10), (timer) async {
          if (roomRecvIPs.isNotEmpty) {
            timer.cancel();
            await _handleServerConnection(
              deferScreenReceived: deferScreenReceived,
              screenId: screenId,
              consumeSockets: consumeSockets,
              roomRecvIPs: roomRecvIPs,
              apiUserName: apiUserName,
              apiKey: apiKey,
              apiToken: apiToken,
              parameters: parameters,
              connectIps: parameters.connectIps,
            );
            parameters.updateIsLoadingModalVisible(false);
          }
        });
      } else {
        await _handleServerConnection(
          deferScreenReceived: deferScreenReceived,
          screenId: screenId,
          consumeSockets: consumeSockets,
          roomRecvIPs: roomRecvIPs,
          apiUserName: apiUserName,
          apiKey: apiKey,
          apiToken: apiToken,
          parameters: parameters,
          connectIps: parameters.connectIps,
        );
        parameters.updateIsLoadingModalVisible(false);
      }
    } else if (screenId.isNotEmpty && deferScreenReceived) {
      parameters.updateShareScreenStarted(true);
    }

    // Filtering requests based on current participants
    final filteredRequests = requestList
        .where((req) => participants.any((p) => p.id == req.id))
        .toList();
    parameters.updateRequestList(filteredRequests);

    // Update coHost and coHostResponsibility
    parameters.updateCoHost(coHost);
    parameters.updateCoHostResponsibility(coHostRes);

    // Screen changes if necessary
    if (!lockScreen && !firstAll) {
      final optionsChanges = OnScreenChangesOptions(
        parameters: parameters,
      );
      await parameters.onScreenChanges(
        optionsChanges,
      );
      if (meetingDisplayType != 'all') {
        parameters.updateFirstAll(true);
      }
    }

    // Updating settings if members received
    bool newMembersReceived = parameters.getUpdatedAllParams().membersReceived;
    if (newMembersReceived) {
      parameters.updateAudioSetting(settings.settings[0]);
      parameters.updateVideoSetting(settings.settings[1]);
      parameters.updateScreenshareSetting(settings.settings[2]);
      parameters.updateChatSetting(settings.settings[3]);
    }
  } catch (error) {
    if (kDebugMode) {
      print('Errors in allMembersRest: $error');
    }
    rethrow;
  }
}

/// Helper function to handle server connection logic
Future<void> _handleServerConnection({
  required bool deferScreenReceived,
  required String? screenId,
  required List<Map<String, io.Socket>> consumeSockets,
  required List<String> roomRecvIPs,
  required String apiUserName,
  required String apiKey,
  required String apiToken,
  required AllMembersRestParameters parameters,
  required ConnectIpsType connectIps,
}) async {
  if (deferScreenReceived && screenId != null) {
    parameters.updateShareScreenStarted(true);
  }

  final optionsConnect = ConnectIpsOptions(
    consumeSockets: consumeSockets,
    remIP: roomRecvIPs,
    parameters: parameters,
    apiUserName: apiUserName,
    apiKey: apiKey,
    apiToken: apiToken,
  );
  final result = await connectIps(
    optionsConnect,
  );

  parameters.updateConsumeSockets(result[0] as List<ConsumeSocket>);
  parameters.updateRoomRecvIPs(result[1] as List<String>);
  parameters.updateMembersReceived(true);

  await parameters.sleep(SleepOptions(ms: 250));
}
