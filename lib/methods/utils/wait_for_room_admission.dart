import 'dart:convert';

import 'package:http/http.dart' as http;

/// Waiting room for guests who join through the REST API (wait-room-api-v1, Oct 2026).
///
/// When a room was created with `waitRoom: true`, a join answers `{ waiting: true, secret, link: null }`: the guest has
/// a room credential but no media server yet. The guest asks the same rooms endpoint (`action: "waitStatus"`) until the
/// host admits or declines them; an admitted answer carries the normal join fields (`link`, `secret`, `roomName`), so the
/// join continues unchanged. Clients only talk to the rooms API and media servers.

const String waitingRoomMessage = 'Waiting for the host to let you in.';
const String waitingRoomDeclinedMessage = "The host didn't let you in.";
const String waitingRoomEndedMessage = 'This room has ended.';
const String waitingRoomUnsupportedMessage =
    'This server does not support waiting rooms for API guests yet.';

enum WaitingRoomStatus { waiting, admitted, declined, ended, timeout, cancelled, error }

class WaitingRoomAdmission {
  final WaitingRoomStatus status;
  final String? roomName;
  final String? secret;
  final String? link;
  final String? publicURL;
  final String? error;

  const WaitingRoomAdmission({
    required this.status,
    this.roomName,
    this.secret,
    this.link,
    this.publicURL,
    this.error,
  });
}

/// Listeners can follow progress (show "Waiting for the host to let you in", hide it when done).
typedef WaitingRoomStatusListener = void Function(WaitingRoomStatus status, String roomName);

final List<WaitingRoomStatusListener> _waitingRoomListeners = [];
bool _cancelRequested = false;

/// Follow waiting-room progress for every join made by the SDK.
void addWaitingRoomListener(WaitingRoomStatusListener listener) => _waitingRoomListeners.add(listener);

void removeWaitingRoomListener(WaitingRoomStatusListener listener) => _waitingRoomListeners.remove(listener);

/// Stop the current wait (the join then fails with "Stopped waiting for the host.").
void cancelWaitingRoom() => _cancelRequested = true;

Future<WaitingRoomAdmission> waitForRoomAdmission({
  required String roomName,
  required String userName,
  required String secret,
  required String apiUserName,
  required String apiKey,
  required String endpoint,
  Duration interval = const Duration(seconds: 3),
  Duration timeout = const Duration(minutes: 30),
  http.Client? client,
  Future<void> Function(Duration)? sleep,
  DateTime Function()? now,
}) async {
  final clock = now ?? DateTime.now;
  final pause = sleep ?? (Duration d) => Future<void>.delayed(d);
  final step = interval < const Duration(seconds: 1) ? const Duration(seconds: 1) : interval;
  final deadline = clock().add(timeout);
  final owned = client == null;
  final http.Client httpClient = client ?? http.Client();
  _cancelRequested = false;

  void report(WaitingRoomStatus status) {
    for (final listener in List<WaitingRoomStatusListener>.from(_waitingRoomListeners)) {
      try {
        listener(status, roomName);
      } catch (_) {}
    }
  }

  WaitingRoomAdmission finish(WaitingRoomAdmission result) {
    if (owned) httpClient.close();
    report(result.status);
    return result;
  }

  report(WaitingRoomStatus.waiting);
  var failures = 0;
  while (clock().isBefore(deadline)) {
    if (_cancelRequested) {
      return finish(const WaitingRoomAdmission(status: WaitingRoomStatus.cancelled, error: 'Stopped waiting for the host.'));
    }
    await pause(step);
    if (_cancelRequested) {
      return finish(const WaitingRoomAdmission(status: WaitingRoomStatus.cancelled, error: 'Stopped waiting for the host.'));
    }
    int code;
    Map<String, dynamic> body = const {};
    try {
      final response = await httpClient.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiUserName:$apiKey',
        },
        body: jsonEncode({'action': 'waitStatus', 'meetingID': roomName, 'userName': userName, 'secret': secret}),
      );
      code = response.statusCode;
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) body = decoded;
      } catch (_) {}
    } catch (_) {
      failures += 1;
      if (failures >= 10) {
        return finish(const WaitingRoomAdmission(
            status: WaitingRoomStatus.error, error: 'Lost contact with the server while waiting for the host.'));
      }
      continue;
    }
    final status = (body['status'] ?? '').toString();
    final link = body['link'];
    if (status == 'admitted' && link is String && link.isNotEmpty) {
      return finish(WaitingRoomAdmission(
        status: WaitingRoomStatus.admitted,
        roomName: (body['roomName'] ?? roomName).toString(),
        secret: (body['secret'] ?? secret).toString(),
        link: link,
        publicURL: (body['publicURL'] ?? '').toString(),
      ));
    }
    if (status == 'declined' || code == 403) {
      return finish(const WaitingRoomAdmission(status: WaitingRoomStatus.declined, error: waitingRoomDeclinedMessage));
    }
    if (status == 'ended' || code == 410) {
      return finish(const WaitingRoomAdmission(status: WaitingRoomStatus.ended, error: waitingRoomEndedMessage));
    }
    if (code == 400) {
      return finish(const WaitingRoomAdmission(status: WaitingRoomStatus.error, error: waitingRoomUnsupportedMessage));
    }
    if (code == 401) {
      return finish(WaitingRoomAdmission(
          status: WaitingRoomStatus.error,
          error: (body['error'] ?? 'These room credentials are no longer valid.').toString()));
    }
    if (status == 'waiting' && code >= 200 && code < 300) {
      failures = 0;
      continue;
    }
    failures += 1; // 404/5xx/504: transient while the room settles
    if (failures >= 10) {
      return finish(WaitingRoomAdmission(
          status: WaitingRoomStatus.error,
          error: (body['error'] ?? 'The server could not tell whether the host let you in.').toString()));
    }
  }
  return finish(const WaitingRoomAdmission(
      status: WaitingRoomStatus.timeout, error: 'The host did not let you in within 30 minutes.'));
}
