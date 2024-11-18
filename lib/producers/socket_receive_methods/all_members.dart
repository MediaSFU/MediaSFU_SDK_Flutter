import 'dart:async';
import '../../types/types.dart'
    show
        Participant,
        Request,
        ReorderStreamsType,
        ReorderStreamsParameters,
        SleepType,
        ConnectIpsParameters,
        OnScreenChangesParameters,
        OnScreenChangesType,
        ConnectIpsType,
        ConsumeSocket,
        CoHostResponsibility,
        WaitingRoomParticipant,
        ReorderStreamsOptions,
        OnScreenChangesOptions,
        ConnectIpsOptions,
        SleepOptions;

/// Callback function type for updating participant data.
typedef UpdateParticipants = void Function(List<Participant>);
typedef UpdateRequestList = void Function(List<Request>);
typedef UpdateCoHost = void Function(String);
typedef UpdateCoHostResponsibility = void Function(List<CoHostResponsibility>);
typedef UpdateBoolean = void Function(bool);
typedef UpdateSockets = void Function(List<ConsumeSocket>);
typedef UpdateIPs = void Function(List<String>);
typedef UpdateTotalReqWait = void Function(int);
typedef UpdateHostFirstSwitch = void Function(bool);
typedef UpdateParticipantsAll = void Function(List<Participant>);

/// Defines parameters for managing all members.
abstract class AllMembersParameters
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
  bool get hostFirstSwitch;
  List<WaitingRoomParticipant> get waitingRoomList;
  String get islevel;

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
  UpdateSockets get updateConsumeSockets;
  UpdateIPs get updateRoomRecvIPs;
  UpdateBoolean get updateIsLoadingModalVisible;
  UpdateTotalReqWait get updateTotalReqWait;
  UpdateHostFirstSwitch get updateHostFirstSwitch;

  // Mediasfu functions as abstract getters
  OnScreenChangesType get onScreenChanges;
  ConnectIpsType get connectIps;
  SleepType get sleep;
  ReorderStreamsType get reorderStreams;

  // dynamic operator [](String key);
}

/// Options for managing all members.
class AllMembersOptions {
  final List<Participant> members;
  final List<Request> requests;
  final String coHost;
  final List<CoHostResponsibility> coHostRes;
  final AllMembersParameters parameters;
  final List<ConsumeSocket> consumeSockets;
  final String apiUserName;
  final String apiKey;
  final String apiToken;

  AllMembersOptions({
    required this.members,
    required this.requests,
    required this.coHost,
    required this.coHostRes,
    required this.parameters,
    required this.consumeSockets,
    required this.apiUserName,
    required this.apiKey,
    required this.apiToken,
  });
}

typedef AllMembersType = Future<void> Function(AllMembersOptions options);

/// Manages all members and updates the UI.
///
/// This function updates the participants list by filtering out banned or suspended members,
/// updates request lists, manages connections, and reorders streams if necessary. It also handles
/// waiting room participants, sets up connections for active participants, and updates UI states
/// like screen share and host switches as needed.
///
/// ### Example Usage:
/// ```dart
/// final options = AllMembersOptions(
///   members: [
///     Participant(name: 'Alice', audioID: 'audio1', videoID: 'video1', isBanned: false, isSuspended: false),
///     Participant(name: 'Bob', audioID: 'audio2', videoID: 'video2', isBanned: false, isSuspended: false),
///   ],
///   requests: [Request(id: 'req1', name: 'Alice'), Request(id: 'req2', name: 'Bob')],
///   coHost: 'Alice',
///   coHostRes: [CoHostResponsibility(id: 'res1', task: 'manage')],
///   parameters: AllMembersParameters(
///     participantsAll: [],
///     participants: [],
///     dispActiveNames: ['Alice', 'Bob'],
///     requestList: [],
///     coHost: 'Alice',
///     coHostResponsibility: [],
///     lockScreen: false,
///     firstAll: false,
///     membersReceived: false,
///     roomRecvIPs: ['192.000.1.1'],
///     deferScreenReceived: true,
///     screenId: 'screen123',
///     shareScreenStarted: false,
///     meetingDisplayType: 'all',
///     hostFirstSwitch: false,
///     waitingRoomList: [WaitingRoomParticipant(name: 'Charlie')],
///     islevel: '2',
///     updateParticipantsAll: (updatedList) => print('Participants all updated: $updatedList'),
///     updateParticipants: (filteredList) => print('Filtered participants updated: $filteredList'),
///     updateRequestList: (updatedRequests) => print('Requests updated: $updatedRequests'),
///     updateCoHost: (newCoHost) => print('Co-host updated: $newCoHost'),
///     updateCoHostResponsibility: (responsibilities) => print('Co-host responsibilities updated: $responsibilities'),
///     updateFirstAll: (isFirstAll) => print('First all updated: $isFirstAll'),
///     updateMembersReceived: (received) => print('Members received updated: $received'),
///     updateDeferScreenReceived: (defer) => print('Defer screen received updated: $defer'),
///     updateShareScreenStarted: (started) => print('Share screen started updated: $started'),
///     updateHostFirstSwitch: (switched) => print('Host first switch updated: $switched'),
///     updateConsumeSockets: (sockets) => print('Consume sockets updated: $sockets'),
///     updateRoomRecvIPs: (ips) => print('Room receive IPs updated: $ips'),
///     updateIsLoadingModalVisible: (visible) => print('Loading modal visibility updated: $visible'),
///     updateTotalReqWait: (total) => print('Total request wait count updated: $total'),
///     onScreenChanges: (params) async => print('Screen changes detected'),
///     connectIps: (connectOptions) async => print('Connected to IPs with options: $connectOptions'),
///     sleep: (ms) async => print('Sleeping for $ms milliseconds'),
///     reorderStreams: (options) async => print('Reordered streams with options: $options'),
///   ),
///   consumeSockets: [ConsumeSocket(id: 'socket1')],
///   apiUserName: 'user123',
///   apiKey: 'key123',
///   apiToken: 'token123',
/// );
///
/// await allMembers(options);
/// ```
///
/// In this example:
/// - The function processes members like `Alice` and `Bob`, filtering them, managing requests,
///   and updating the list based on ban or suspend status.
/// - It configures waiting room participants, manages co-host assignments, and handles IP
///   connections with `connectIps`, updating relevant states in the UI.
Future<void> allMembers(AllMembersOptions options) async {
  final params = options.parameters;

  params.updateParticipantsAll(
    options.members
        .map((member) => Participant(
            name: member.name,
            isBanned: member.isBanned,
            isSuspended: member.isSuspended,
            audioID: member.audioID,
            videoID: member.videoID))
        .toList(),
  );

  params.updateParticipants(
    options.members
        .where((participant) =>
            !participant.isBanned! && !participant.isSuspended!)
        .toList(),
  );

  if (params.dispActiveNames.isNotEmpty) {
    final missingNames = params.dispActiveNames
        .where((name) => !params.participants.any((p) => p.name == name))
        .toList();
    if (missingNames.isNotEmpty) {
      final optionsReorder = ReorderStreamsOptions(
        screenChanged: true,
        parameters: params,
      );
      await params.reorderStreams(
        optionsReorder,
      );
    }
  }

  if (!params.membersReceived) {
    if (params.roomRecvIPs.isEmpty) {
      Timer.periodic(const Duration(milliseconds: 10), (timer) async {
        if (params.roomRecvIPs.isNotEmpty) {
          timer.cancel();
          await _handleConnections(options, params);
        }
      });
    } else {
      await _handleConnections(options, params);
    }
  }

  final updatedRequests = options.requests
      .where((req) => params.participants.any((p) => p.id == req.id))
      .toList();
  params.updateRequestList(updatedRequests);
  params.updateTotalReqWait(
      updatedRequests.length + params.waitingRoomList.length);
  params.updateCoHost(options.coHost);
  params.updateCoHostResponsibility(options.coHostRes);

  if (!params.lockScreen && !params.firstAll) {
    final optionsChanges = OnScreenChangesOptions(
      parameters: params,
    );
    await params.onScreenChanges(
      optionsChanges,
    );
    if (params.meetingDisplayType != 'all') params.updateFirstAll(true);
  } else if (params.islevel == '2' && !params.hostFirstSwitch) {
    final optionsChanges = OnScreenChangesOptions(
      parameters: params,
    );
    await params.onScreenChanges(
      optionsChanges,
    );
    params.updateHostFirstSwitch(true);
  }
}

Future<void> _handleConnections(
    AllMembersOptions options, AllMembersParameters params) async {
  if (params.deferScreenReceived && params.screenId.isNotEmpty) {
    params.updateShareScreenStarted(true);
  }

  final optionsConnect = ConnectIpsOptions(
    consumeSockets: options.consumeSockets,
    remIP: params.roomRecvIPs,
    parameters: params,
    apiUserName: options.apiUserName,
    apiKey: options.apiKey,
    apiToken: options.apiToken,
  );
  final [sockets, ips] = await params.connectIps(
    optionsConnect,
  );

  params.updateConsumeSockets(sockets);
  params.updateRoomRecvIPs(ips);

  params.updateMembersReceived(true);
  await params.sleep(SleepOptions(ms: 250));
  params.updateIsLoadingModalVisible(false);
  params.updateDeferScreenReceived(false);
}
