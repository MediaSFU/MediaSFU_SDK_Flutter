import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';
// ignore: implementation_imports
import 'package:mediasfu_mediasoup_client/src/common/enhanced_event_emitter.dart';
// ignore: implementation_imports
import 'package:mediasfu_mediasoup_client/src/handlers/handler_interface.dart'
    show RTCIceServer;
import 'package:mediasfu_sdk/consumers/relay_fallback.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

final servers = [
  {
    'urls': ['turns:turn-ca.mediasfu.com:443?transport=tcp'],
    'username': '1:x',
    'credential': 'c',
  }
];
final iceParameters = {'usernameFragment': 'n', 'password': 'p', 'iceLite': true};

/// Mirrors the mediasoup client: listeners get `{'connectionState': state}`.
class _Transport extends EnhancedEventEmitter implements Transport {
  @override
  String get id => 't1';
  @override
  bool closed = false;
  @override
  String connectionState = 'new';
  final EnhancedEventEmitter _observer = EnhancedEventEmitter();
  @override
  EnhancedEventEmitter get observer => _observer;
  final List<List<RTCIceServer>> iceServerUpdates = [];
  final List<IceParameters> restarts = [];
  final List<String> calls = [];

  @override
  void updateIceServers(List<RTCIceServer> iceServers) {
    calls.add('updateIceServers');
    iceServerUpdates.add(iceServers);
  }

  @override
  void restartIce(IceParameters iceParameters) {
    calls.add('restartIce');
    restarts.add(iceParameters);
  }

  @override
  Future<List<StatsReport>> getState() async => [
        StatsReport('T', 'transport', 0, {'selectedCandidatePairId': 'P'}),
        StatsReport('P', 'candidate-pair', 0, {'localCandidateId': 'L'}),
        StatsReport('L', 'local-candidate', 0,
            {'candidateType': 'relay', 'protocol': 'udp', 'relayProtocol': 'tls'}),
      ];

  void setState(String state) {
    connectionState = state;
    safeEmit('connectionstatechange', {'connectionState': state});
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Socket implements io.Socket {
  @override
  bool connected = true;
  @override
  String? id = 's';
  final reports = <Map>[];
  final restartRequests = <Map>[];
  dynamic Function(int attempt)? answer;
  final _handlers = <String, List<dynamic Function(dynamic)>>{};

  @override
  void emitWithAck(String event, dynamic data,
      {Function? ack, bool binary = false, bool withTimeout = false, int? timeout}) {
    if (event != 'transport-restart-ice') return;
    restartRequests.add(Map.from(data as Map));
    final reply = answer?.call(restartRequests.length);
    if (reply != null) ack?.call(reply);
  }

  @override
  void emit(String event, [dynamic data]) {
    if (event == 'transport-ice-report') reports.add(Map.from(data as Map));
  }

  @override
  void Function() on(String event, dynamic Function(dynamic) handler) {
    _handlers.putIfAbsent(event, () => []).add(handler);
    return () => off(event, handler);
  }

  @override
  void off(String event, [dynamic Function(dynamic)? handler]) {
    _handlers[event]?.remove(handler);
  }

  void fire(String event) {
    for (final h in List.of(_handlers[event] ?? const [])) {
      h(null);
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _Device implements Device {
  final calls = <Invocation>[];
  final Transport transport;
  _Device(this.transport);
  @override
  dynamic noSuchMethod(Invocation invocation) {
    calls.add(invocation);
    return transport;
  }
}

final transportMap = {
  'id': 't1',
  'iceParameters': iceParameters,
  'iceCandidates': [
    {
      'foundation': 'udpcandidate',
      'ip': '203.0.113.10',
      'port': 40001,
      'priority': 1076302079,
      'protocol': 'udp',
      'type': 'host',
    }
  ],
  'dtlsParameters': {
    'role': 'auto',
    'fingerprints': [
      {'algorithm': 'sha-256', 'value': 'AA:BB'}
    ],
  },
};

void main() {
  group('relay offer', () {
    test('reads the fields beside params, never from params', () {
      final offer = IceRelayOffer.fromAck({
        'params': transportMap,
        'iceServers': servers,
        'iceRelayMode': 'fallback',
        'iceRelayAfterMs': 8000,
      });
      expect(offer.hasServers, isTrue);
      expect(offer.mode, 'fallback');
      expect(offer.afterMs, 8000);
      expect(offer.always, isFalse);

      final inside = IceRelayOffer.fromAck({
        'params': {...transportMap, 'iceServers': servers, 'iceRelayMode': 'always'},
      });
      expect(inside.hasServers, isFalse);
      expect(inside.always, isFalse);
    });

    test('older servers without the fields give an empty offer', () {
      final offer = IceRelayOffer.fromAck({'params': transportMap});
      expect(offer.hasServers, isFalse);
      expect(offer.mode, isNull);
      expect(offer.afterMs, isNull);
      expect(IceRelayOffer.fromAck(null).hasServers, isFalse);
    });

    test('always mode passes iceServers to createSendTransport / createRecvTransport', () {
      final offer = IceRelayOffer.fromAck(
          {'params': transportMap, 'iceServers': servers, 'iceRelayMode': 'always'});
      final device = _Device(_Transport());
      createSendTransportWithRelay(device, transportMap, offer);
      createRecvTransportWithRelay(device, transportMap, offer);
      expect(device.calls.map((c) => c.memberName),
          [#createSendTransport, #createRecvTransport]);
      for (final call in device.calls) {
        final ice = call.namedArguments[#iceServers] as List<RTCIceServer>;
        expect(ice.single.urls, servers.first['urls']);
        expect(ice.single.username, '1:x');
        expect(ice.single.credential, 'c');
        expect(call.namedArguments[#id], 't1');
      }
    });

    test('fallback mode and older servers create transports exactly as before', () {
      for (final ack in [
        {'params': transportMap, 'iceServers': servers, 'iceRelayMode': 'fallback'},
        {'params': transportMap},
        {'params': transportMap, 'iceRelayMode': 'always'}, // no servers: nothing to add
      ]) {
        final offer = IceRelayOffer.fromAck(ack);
        final device = _Device(_Transport());
        createSendTransportWithRelay(device, transportMap, offer);
        createRecvTransportWithRelay(device, transportMap, offer);
        expect(device.calls.map((c) => c.memberName),
            [#createSendTransportFromMap, #createRecvTransportFromMap]);
      }
    });
  });

  group('relay watcher', () {
    IceRelayOffer fallback([int afterMs = 8000]) => IceRelayOffer.fromAck({
          'iceServers': servers,
          'iceRelayMode': 'fallback',
          'iceRelayAfterMs': afterMs,
        });

    test('does nothing when ICE connects in time', () {
      fakeAsync((async) {
        final transport = _Transport();
        final socket = _Socket()..answer = (_) => {'iceParameters': iceParameters};
        attachRelayFallback(transport, socket, fallback(), direction: 'send');
        transport.setState('connecting');
        async.elapse(const Duration(seconds: 3));
        transport.setState('connected');
        async.elapse(const Duration(seconds: 30));
        expect(socket.restartRequests, isEmpty);
        expect(socket.reports, isEmpty);
      });
    });

    test('restarts ICE once with the relay after 8 s stuck, then reports the relay candidate', () {
      fakeAsync((async) {
        final transport = _Transport();
        final socket = _Socket()
          ..answer = (_) => {'iceParameters': iceParameters, 'iceServers': servers};
        var blocked = 0;
        attachRelayFallback(transport, socket, fallback(8000),
            direction: 'send', onBlocked: () => blocked++);
        transport.setState('connecting');
        async.elapse(const Duration(milliseconds: 7999));
        expect(socket.restartRequests, isEmpty);
        async.elapse(const Duration(milliseconds: 1));
        async.flushMicrotasks();
        expect(socket.restartRequests, [
          {'transportId': 't1', 'relay': true}
        ]);
        expect(transport.calls, ['updateIceServers', 'restartIce']);
        expect(transport.iceServerUpdates.single.single.urls, servers.first['urls']);
        expect(transport.restarts.single.usernameFragment, 'n');
        transport.setState('connected');
        async.flushMicrotasks();
        expect(socket.reports, hasLength(1));
        expect(socket.reports.single, containsPair('phase', 'connected'));
        expect(socket.reports.single, containsPair('transportId', 't1'));
        expect(socket.reports.single, containsPair('direction', 'send'));
        expect(socket.reports.single, containsPair('candidateType', 'relay'));
        expect(socket.reports.single, containsPair('relayProtocol', 'tls'));
        expect(blocked, 0);
        transport.setState('disconnected');
        transport.setState('connecting');
        async.elapse(const Duration(seconds: 60));
        expect(socket.restartRequests, hasLength(1));
      });
    });

    test('tells the user the network is blocking when the relay restart does not connect in 12 s', () {
      fakeAsync((async) {
        final transport = _Transport();
        final socket = _Socket()
          ..answer = (_) => {'iceParameters': iceParameters, 'iceServers': servers};
        var blocked = 0;
        attachRelayFallback(transport, socket, fallback(),
            direction: 'recv', onBlocked: () => blocked++);
        transport.setState('connecting');
        async.elapse(const Duration(seconds: 8));
        async.flushMicrotasks();
        async.elapse(const Duration(milliseconds: 11999));
        expect(blocked, 0);
        async.elapse(const Duration(milliseconds: 1));
        async.flushMicrotasks();
        expect(blocked, 1);
        expect(socket.reports.map((r) => r['phase']), ['blocked']);
        expect(socket.reports.single['direction'], 'recv');
        async.elapse(const Duration(seconds: 60));
        expect(blocked, 1);
      });
    });

    test('retries once when the server throttles a restart the regular recovery just made', () {
      fakeAsync((async) {
        final transport = _Transport();
        final socket = _Socket()
          ..answer = (n) => n == 1
              ? {'error': 'Recovery already attempted; retry later'}
              : {'iceParameters': iceParameters};
        attachRelayFallback(transport, socket, fallback(), direction: 'send');
        transport.setState('connecting');
        async.elapse(const Duration(seconds: 8));
        async.flushMicrotasks();
        expect(socket.restartRequests, hasLength(1));
        expect(transport.calls, isEmpty);
        async.elapse(const Duration(milliseconds: 2100));
        async.flushMicrotasks();
        expect(socket.restartRequests, hasLength(2));
        // No fresh credentials in the answer: the offered ones are used.
        expect(transport.iceServerUpdates.single.single.urls, servers.first['urls']);
        expect(transport.calls, ['updateIceServers', 'restartIce']);
      });
    });

    test('says the network is blocking when the throttled retry is refused too', () {
      fakeAsync((async) {
        final transport = _Transport();
        final socket = _Socket()..answer = (_) => {'error': 'Recovery already attempted; retry later'};
        var blocked = 0;
        attachRelayFallback(transport, socket, fallback(),
            direction: 'send', onBlocked: () => blocked++);
        transport.setState('connecting');
        async.elapse(const Duration(seconds: 11));
        async.flushMicrotasks();
        expect(socket.restartRequests, hasLength(2));
        expect(transport.calls, isEmpty);
        expect(blocked, 1);
      });
    });

    test('without the relay fields, still says the network is blocking instead of staying silent', () {
      fakeAsync((async) {
        final transport = _Transport();
        final socket = _Socket();
        var blocked = 0;
        attachRelayFallback(transport, socket, IceRelayOffer.fromAck({'params': transportMap}),
            direction: 'send', onBlocked: () => blocked++);
        // ICE starts with the first produce, even before any state change.
        transport.safeEmit('connect', {'dtlsParameters': null, 'callback': () {}, 'errback': (_) {}});
        async.elapse(const Duration(seconds: 8));
        async.flushMicrotasks();
        expect(socket.restartRequests, isEmpty);
        async.elapse(const Duration(seconds: 12));
        async.flushMicrotasks();
        expect(blocked, 1);
        expect(socket.reports.map((r) => r['phase']), ['unavailable', 'blocked']);
        expect(transport.calls, isEmpty);
      });
    });

    test('without the relay fields, a late connection inside the wait shows nothing', () {
      fakeAsync((async) {
        final transport = _Transport();
        final socket = _Socket();
        var blocked = 0;
        attachRelayFallback(transport, socket, const IceRelayOffer(),
            direction: 'recv', onBlocked: () => blocked++);
        transport.setState('connecting');
        async.elapse(const Duration(seconds: 15));
        transport.setState('connected');
        async.elapse(const Duration(seconds: 30));
        expect(blocked, 0);
        expect(socket.reports, isEmpty);
      });
    });

    test('stops watching when the media socket disconnects', () {
      fakeAsync((async) {
        final transport = _Transport();
        final socket = _Socket()..answer = (_) => {'iceParameters': iceParameters};
        var blocked = 0;
        attachRelayFallback(transport, socket, fallback(),
            direction: 'send', onBlocked: () => blocked++);
        transport.setState('connecting');
        async.elapse(const Duration(seconds: 4));
        socket.fire('disconnect');
        async.elapse(const Duration(seconds: 30));
        expect(socket.restartRequests, isEmpty);
        expect(blocked, 0);
      });
    });

    test('keeps the server wait within 3-20 s', () {
      fakeAsync((async) {
        final transport = _Transport();
        final socket = _Socket()..answer = (_) => {'iceParameters': iceParameters};
        attachRelayFallback(transport, socket, fallback(500), direction: 'send');
        transport.setState('connecting');
        async.elapse(const Duration(milliseconds: 2999));
        expect(socket.restartRequests, isEmpty);
        async.elapse(const Duration(milliseconds: 1));
        async.flushMicrotasks();
        expect(socket.restartRequests, hasLength(1));
      });
    });
  });

  group('blocked message', () {
    test('is shown once per media socket with the exact text', () {
      final alerts = <Map<String, Object>>[];
      void showAlert({required String message, required String type, required int duration}) =>
          alerts.add({'message': message, 'type': type, 'duration': duration});
      final socket = _Socket();
      showNetworkBlocked(socket, showAlert);
      showNetworkBlocked(socket, showAlert);
      expect(alerts, [
        {
          'message':
              'Your network is blocking the call connection. Try another network (a phone hotspot works) or turn off your VPN, then rejoin.',
          'type': 'danger',
          'duration': 15000,
        }
      ]);
      showNetworkBlocked(_Socket(), showAlert);
      expect(alerts, hasLength(2));
    });

    test('reads the live showAlert from the parameters', () {
      void showAlert({required String message, required String type, required int duration}) {}
      final live = _Params(showAlert);
      expect(liveShowAlert(_Params(null, live)), same(live.showAlert));
      expect(liveShowAlert(Object()), isNull);
    });
  });
}

class _Params {
  _Params(this.showAlert, [this.updated]);
  final dynamic showAlert;
  final _Params? updated;
  _Params getUpdatedAllParams() => updated ?? this;
}
