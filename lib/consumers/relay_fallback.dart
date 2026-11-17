// TURN relay fallback (turn-relay-v1).
//
// Media servers accept ICE only on a high UDP/TCP port range, so a network
// that blocks those ports (corporate, hotel, some VPNs) used to leave a
// transport "connecting" forever with nothing sent. Servers that offer a relay
// answer createWebRtcTransport with short-lived TURN credentials beside
// `params`:
//
//   { params, iceServers: [{ urls, username, credential }],
//     iceRelayMode: 'fallback' | 'always', iceRelayAfterMs: 8000 }
//
// - 'always': the transport is created with the relay already allowed (ICE
//   uses it only when direct paths fail).
// - 'fallback': the transport starts direct; if it is still not connected
//   `iceRelayAfterMs` after ICE starts, ICE is restarted once with the relay
//   allowed (fresh credentials come with the restart answer).
// If that still does not connect, the user is told their network is blocking
// the call instead of a silent call. Every relay restart is reported to the
// server (`transport-ice-report`) so relay use can be counted.
//
// The relay mode and wait belong to the server; there is deliberately no
// option to force the relay or change the wait from an app.

import 'dart:async';

import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';
// RTCIceServer is not exported from the package barrel.
// ignore: implementation_imports
import 'package:mediasfu_mediasoup_client/src/handlers/handler_interface.dart'
    show RTCIceServer, RTCIceCredentialType;
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../types/types.dart' show ShowAlert;

/// Shown once per media socket when the call cannot connect through the
/// network, even with the relay.
const String networkBlockedMessage =
    'Your network is blocking the call connection. Try another network (a phone hotspot works) or turn off your VPN, then rejoin.';

/// The relay fields a server sends beside `params` in its createWebRtcTransport
/// answer. All fields are absent on servers without a relay.
class IceRelayOffer {
  final List<Map<String, dynamic>> iceServers;
  final String? mode;
  final int? afterMs;

  const IceRelayOffer({this.iceServers = const [], this.mode, this.afterMs});

  /// Reads `iceServers`, `iceRelayMode` and `iceRelayAfterMs` from the
  /// createWebRtcTransport acknowledgement (never from `params`).
  factory IceRelayOffer.fromAck(dynamic response) {
    if (response is! Map) return const IceRelayOffer();
    final after = response['iceRelayAfterMs'];
    final mode = response['iceRelayMode'];
    return IceRelayOffer(
      iceServers: parseIceServers(response['iceServers']),
      mode: mode is String ? mode : null,
      afterMs: after is num ? after.toInt() : int.tryParse('${after ?? ''}'),
    );
  }

  bool get hasServers => iceServers.isNotEmpty;

  /// Whether the transport must be created with the relay already allowed.
  bool get always => mode == 'always' && hasServers;
}

/// Keeps the ICE server entries that carry at least one URL.
List<Map<String, dynamic>> parseIceServers(dynamic value) {
  if (value is! List) return const [];
  final out = <Map<String, dynamic>>[];
  for (final entry in value) {
    if (entry is! Map) continue;
    final urls = entry['urls'] ?? entry['url'];
    final list = urls is String
        ? <String>[urls]
        : urls is List
            ? urls.whereType<String>().toList()
            : <String>[];
    if (list.isEmpty) continue;
    out.add({
      'urls': list,
      if (entry['username'] != null) 'username': '${entry['username']}',
      if (entry['credential'] != null) 'credential': entry['credential'],
    });
  }
  return out;
}

/// Converts parsed ICE server maps to the mediasoup client type.
List<RTCIceServer> toRtcIceServers(List<Map<String, dynamic>> servers) =>
    servers
        .map((s) => RTCIceServer(
              urls: List<String>.from(s['urls'] as List),
              username: (s['username'] ?? '') as String,
              credential: s['credential'],
              credentialType: RTCIceCredentialType.password,
            ))
        .toList();

// The same options createSendTransportFromMap / createRecvTransportFromMap use.
Map<String, dynamic> _proprietaryConstraints() => Map<String, dynamic>.from({
      'optional': [
        {'googDscp': true}
      ]
    });
Map<String, dynamic> _additionalSettings() => {'encodedInsertableStreams': false};

List<IceCandidate> _candidates(Map data) => List<IceCandidate>.from(
    (data['iceCandidates'] as List).map((c) => IceCandidate.fromMap(c)));

/// Creates the send transport. Only the 'always' mode adds the relay up front;
/// otherwise this is exactly `device.createSendTransportFromMap`.
Transport createSendTransportWithRelay(
  Device device,
  Map data,
  IceRelayOffer offer, {
  Function? producerCallback,
}) {
  if (!offer.always) {
    return device.createSendTransportFromMap(data,
        producerCallback: producerCallback);
  }
  return device.createSendTransport(
    id: data['id'],
    iceParameters: IceParameters.fromMap(data['iceParameters']),
    iceCandidates: _candidates(data),
    dtlsParameters: DtlsParameters.fromMap(data['dtlsParameters']),
    sctpParameters: data['sctpParameters'] != null
        ? SctpParameters.fromMap(data['sctpParameters'])
        : null,
    iceServers: toRtcIceServers(offer.iceServers),
    appData: data['appData'] ?? <String, dynamic>{},
    proprietaryConstraints: _proprietaryConstraints(),
    additionalSettings: _additionalSettings(),
    producerCallback: producerCallback,
  );
}

/// Creates the receive transport. Only the 'always' mode adds the relay up
/// front; otherwise this is exactly `device.createRecvTransportFromMap`.
Transport createRecvTransportWithRelay(
  Device device,
  Map data,
  IceRelayOffer offer, {
  Function? consumerCallback,
}) {
  if (!offer.always) {
    return device.createRecvTransportFromMap(data,
        consumerCallback: consumerCallback);
  }
  return device.createRecvTransport(
    id: data['id'],
    iceParameters: IceParameters.fromMap(data['iceParameters']),
    iceCandidates: _candidates(data),
    dtlsParameters: DtlsParameters.fromMap(data['dtlsParameters']),
    sctpParameters: data['sctpParameters'] != null
        ? SctpParameters.fromMap(data['sctpParameters'])
        : null,
    iceServers: toRtcIceServers(offer.iceServers),
    appData: data['appData'] ?? <String, dynamic>{},
    proprietaryConstraints: _proprietaryConstraints(),
    additionalSettings: _additionalSettings(),
    consumerCallback: consumerCallback,
  );
}

// Transport listeners receive `{'connectionState': state}`; accept a bare
// string too.
String _stateOf(dynamic data) {
  if (data is String) return data;
  if (data is Map) return '${data['connectionState'] ?? data['state'] ?? ''}';
  return '';
}

bool _hasIceParameters(dynamic answer) =>
    answer is Map && answer['error'] == null && answer['iceParameters'] is Map;

Future<dynamic> _ack(
    io.Socket socket, String event, Map<String, dynamic> payload, Duration timeout) {
  final completer = Completer<dynamic>();
  socket.emitWithAck(event, payload, ack: (dynamic response) {
    if (!completer.isCompleted) completer.complete(response);
  });
  return completer.future.timeout(timeout);
}

/// Which candidate the connected transport uses: host, srflx, prflx or relay
/// (and over what). Best effort: unknown values stay 'unknown'.
Future<Map<String, String>> selectedCandidate(Transport transport) async {
  final out = <String, String>{
    'candidateType': 'unknown',
    'protocol': 'unknown',
    'relayProtocol': 'unknown',
  };
  try {
    final stats = await transport.getState();
    Map? byId(dynamic id) {
      if (id == null) return null;
      for (final s in stats) {
        if (s.id == id) return s.values;
      }
      return null;
    }

    Map? pair;
    for (final s in stats) {
      if (s.type == 'transport' && s.values['selectedCandidatePairId'] != null) {
        pair = byId(s.values['selectedCandidatePairId']);
        break;
      }
    }
    if (pair == null) {
      for (final s in stats) {
        final v = s.values;
        if (s.type == 'candidate-pair' &&
            v['state'] == 'succeeded' &&
            (v['nominated'] == true || v['selected'] == true)) {
          pair = v;
          break;
        }
      }
    }
    final local = byId(pair?['localCandidateId']);
    if (local != null) {
      for (final key in out.keys.toList()) {
        if (local[key] != null) out[key] = '${local[key]}';
      }
    }
  } catch (_) {
    // Stats are best effort.
  }
  return out;
}

/// Watches one transport and, when it stays stuck, restarts ICE once with the
/// relay allowed. Returns a dispose function. Register it before the regular
/// ICE recovery (which handles disconnected/failed); the two run side by side.
void Function() attachRelayFallback(
  Transport transport,
  io.Socket socket,
  IceRelayOffer offer, {
  required String direction,
  void Function()? onBlocked,
  Duration connectWait = const Duration(seconds: 12),
}) {
  final requested = offer.afterMs;
  final afterMs = requested == null || requested <= 0
      ? 8000
      : requested.clamp(3000, 20000).toInt();
  final socketId = socket.id;
  var disposed = false;
  DateTime? startedAt;
  Timer? timer;
  var attempted = false;

  late void Function(dynamic) changed;
  late void Function(dynamic) onConnect;
  late dynamic Function(dynamic) onDisconnect;

  void dispose() {
    if (disposed) return;
    disposed = true;
    timer?.cancel();
    timer = null;
    try {
      transport.remove('connectionstatechange', changed);
      transport.remove('connect', onConnect);
    } catch (_) {}
    try {
      socket.off('disconnect', onDisconnect);
    } catch (_) {}
  }

  // Never let the watcher break a transport: read its state defensively.
  String stateNow() {
    try {
      return transport.connectionState;
    } catch (_) {
      return '';
    }
  }

  bool current() {
    try {
      return !disposed &&
          !transport.closed &&
          socket.connected &&
          socket.id == socketId;
    } catch (_) {
      return false;
    }
  }

  void report(String phase, [Map<String, String> extra = const {}]) {
    try {
      socket.emit('transport-ice-report', {
        'transportId': transport.id,
        'direction': direction,
        'phase': phase,
        'waitedMs': startedAt == null
            ? 0
            : DateTime.now().difference(startedAt!).inMilliseconds,
        ...extra,
      });
    } catch (_) {}
  }

  void blocked() {
    if (!current()) return;
    report('blocked');
    try {
      onBlocked?.call();
    } catch (_) {}
    dispose();
  }

  Future<bool> waitConnected(Duration wait) {
    if (stateNow() == 'connected') return Future.value(true);
    final completer = Completer<bool>();
    Timer? limit;
    late void Function(dynamic) on;
    void done(bool ok) {
      if (completer.isCompleted) return;
      limit?.cancel();
      try {
        transport.remove('connectionstatechange', on);
      } catch (_) {}
      completer.complete(ok);
    }

    on = (dynamic data) {
      final state = _stateOf(data);
      if (state == 'connected') {
        done(true);
      } else if (state == 'closed') {
        done(false);
      }
    };
    limit = Timer(wait, () => done(stateNow() == 'connected'));
    transport.on('connectionstatechange', on);
    return completer.future;
  }

  Future<void> relayRestart() async {
    timer = null;
    if (!current() || attempted || stateNow() == 'connected') {
      return;
    }
    attempted = true;
    if (!offer.hasServers) {
      // No relay on this server: give ICE a little longer, then say so
      // instead of staying silent.
      final connected = await waitConnected(connectWait);
      if (connected) return dispose();
      if (current()) {
        report('unavailable');
        blocked();
      }
      return;
    }
    dynamic answer;
    for (var i = 0; i < 2 && current() && !_hasIceParameters(answer); i++) {
      try {
        answer = await _ack(socket, 'transport-restart-ice',
            {'transportId': transport.id, 'relay': true}, const Duration(seconds: 8));
      } catch (_) {
        answer = null;
      }
      // The server throttles restarts to one per 2 s; the regular recovery
      // may have just used it.
      if (!_hasIceParameters(answer) && i == 0) {
        await Future<void>.delayed(const Duration(milliseconds: 2100));
      }
    }
    if (!current()) return;
    if (stateNow() == 'connected') return dispose();
    if (!_hasIceParameters(answer)) return blocked();
    try {
      final fresh = parseIceServers((answer as Map)['iceServers']);
      // Both calls are queued in order by the mediasoup client.
      transport.updateIceServers(
          toRtcIceServers(fresh.isNotEmpty ? fresh : offer.iceServers));
      transport.restartIce(IceParameters.fromMap(
          Map<String, dynamic>.from(answer['iceParameters'] as Map)));
    } catch (_) {
      return blocked();
    }
    if (await waitConnected(connectWait)) {
      if (!current()) return;
      report('connected', await selectedCandidate(transport));
      dispose();
    } else {
      blocked();
    }
  }

  void start() {
    if (startedAt != null || disposed) return;
    startedAt = DateTime.now();
    timer = Timer(Duration(milliseconds: afterMs), () {
      unawaited(relayRestart());
    });
  }

  changed = (dynamic data) {
    final state = _stateOf(data);
    if (state == 'connecting' || state == 'checking') {
      start();
    } else if (state == 'connected' && !attempted) {
      dispose();
    } else if (state == 'closed') {
      dispose();
    }
  };
  // 'connect' fires when the first producer/consumer needs the transport: ICE
  // starts then, even if no state change shows. Never answer its callback.
  onConnect = (dynamic _) => start();
  onDisconnect = (dynamic _) => dispose();

  try {
    transport.on('connectionstatechange', changed);
    transport.on('connect', onConnect);
  } catch (_) {
    dispose();
    return dispose;
  }
  try {
    socket.on('disconnect', onDisconnect);
  } catch (_) {}
  try {
    transport.observer.once('close', (dynamic _) => dispose());
  } catch (_) {}
  if (stateNow() == 'connecting') start();
  return dispose;
}

final Expando<bool> _warnedSockets = Expando<bool>('relayNetworkBlocked');

/// Shows the blocked-network message once per media socket, however many
/// transports hit it.
void showNetworkBlocked(io.Socket socket, ShowAlert? showAlert) {
  if (_warnedSockets[socket] == true) return;
  _warnedSockets[socket] = true;
  showAlert?.call(message: networkBlockedMessage, type: 'danger', duration: 15000);
}

/// Reads the live `showAlert` from a parameters object, when it has one.
ShowAlert? liveShowAlert(dynamic parameters) {
  final reads = <dynamic Function()>[
    () => parameters.getUpdatedAllParams().showAlert,
    () => parameters.showAlert,
  ];
  for (final read in reads) {
    try {
      final alert = read();
      if (alert is ShowAlert) return alert;
    } catch (_) {}
  }
  return null;
}
