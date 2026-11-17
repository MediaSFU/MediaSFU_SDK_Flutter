import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';
// ignore: implementation_imports
import 'package:mediasfu_mediasoup_client/src/common/enhanced_event_emitter.dart';
import 'package:mediasfu_sdk/consumers/create_send_transport.dart';
import 'package:mediasfu_sdk/consumers/signal_new_consumer_transport.dart';
import 'package:mediasfu_sdk/types/types.dart'
    show
        ConnectRecvTransportOptions,
        ConnectSendTransportOptions,
        ReorderStreamsOptions;
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Emits exactly what the mediasoup client emits: `{'connectionState': state}`.
class _Transport extends EnhancedEventEmitter implements Transport {
  _Transport(this.id);
  @override
  final String id;
  @override
  bool closed = false;
  @override
  String connectionState = 'new';
  final EnhancedEventEmitter _observer = EnhancedEventEmitter();
  @override
  EnhancedEventEmitter get observer => _observer;

  @override
  Future<void> close() async {
    closed = true;
  }

  @override
  void restartIce(IceParameters iceParameters) {}

  void setState(String state) {
    connectionState = state;
    safeEmit('connectionstatechange', {'connectionState': state});
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Socket implements io.Socket {
  _Socket(this.id);
  @override
  bool connected = true;
  @override
  String? id;
  final restartRequests = <Map>[];

  @override
  void emitWithAck(String event, dynamic data,
      {Function? ack, bool binary = false, bool withTimeout = false, int? timeout}) {
    if (event == 'createWebRtcTransport') {
      ack?.call({'params': _transportMap});
    } else if (event == 'transport-restart-ice') {
      restartRequests.add(Map.from(data as Map));
      ack?.call({'error': 'test-refusal'});
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _Device implements Device {
  _Device(this.transports);
  final List<Transport> transports;
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #createSendTransportFromMap ||
        invocation.memberName == #createRecvTransportFromMap) {
      return transports.removeAt(0);
    }
    return super.noSuchMethod(invocation);
  }
}

final _transportMap = <String, dynamic>{
  'id': 'server-transport',
  'iceParameters': {'usernameFragment': 'n', 'password': 'p', 'iceLite': true},
  'iceCandidates': const [],
  'dtlsParameters': {'role': 'auto', 'fingerprints': const []},
};

class _SendParams implements CreateSendTransportParameters {
  _SendParams({required this.device, this.socket, this.localSocket});
  @override
  Device? device;
  @override
  final io.Socket? socket;
  @override
  final io.Socket? localSocket;
  @override
  String get islevel => '2';
  @override
  String get member => 'tester';
  @override
  bool transportCreated = false;
  @override
  bool? localTransportCreated = false;
  @override
  Transport? producerTransport;
  @override
  Transport? localProducerTransport;

  @override
  UpdateProducerTransport get updateProducerTransport =>
      (transport) => producerTransport = transport;
  @override
  UpdateProducerTransport? get updateLocalProducerTransport =>
      (transport) => localProducerTransport = transport;
  @override
  UpdateTransportCreated get updateTransportCreated =>
      (created) => transportCreated = created;
  @override
  UpdateTransportCreated? get updateLocalTransportCreated =>
      (created) => localTransportCreated = created;
  @override
  UpdateScreenProducer get updateScreenProducer => (_) {};
  @override
  UpdateAudioProducer get updateAudioProducer => (_) {};
  @override
  UpdateVideoProducer get updateVideoProducer => (_) {};
  @override
  void Function(Producer?)? get updateLocalScreenProducer => (_) {};
  @override
  void Function(Producer?)? get updateLocalAudioProducer => (_) {};
  @override
  void Function(Producer?)? get updateLocalVideoProducer => (_) {};
  @override
  Future<void> Function(ConnectSendTransportOptions) get connectSendTransport =>
      (_) async {};
  @override
  CreateSendTransportParameters Function() get getUpdatedAllParams => () => this;
  @override
  CreateSendTransportParameters Function() get getCurrentParams => () => this;
  @override
  void Function(bool) get updateTransportCreatedAudio => (_) {};
  @override
  void Function(bool) get updateAudioAlreadyOn => (_) {};
  @override
  void Function(double) get updateAudioLevel => (_) {};

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _RecvParams implements SignalNewConsumerTransportParameters {
  _RecvParams(this.device);
  @override
  final Device? device;
  @override
  List<String> consumingTransports = [];
  @override
  bool get lockScreen => false;
  int reorders = 0;
  @override
  void Function(List<String>) get updateConsumingTransports =>
      (value) => consumingTransports = value;
  @override
  Future<void> Function(ReorderStreamsOptions) get reorderStreams =>
      (_) async => reorders++;
  @override
  Future<void> Function(ConnectRecvTransportOptions) get connectRecvTransport =>
      (_) async {};
  @override
  SignalNewConsumerTransportParameters Function() get getUpdatedAllParams =>
      () => this;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// Creates the remote and local send transports through [createSendTransport].
({_Transport remote, _Transport local, _Socket socket, _Socket localSocket})
    _sendSetup(FakeAsync clock) {
  final local = _Transport('local'), remote = _Transport('remote');
  final socket = _Socket('remote-socket'), localSocket = _Socket('local-socket');
  final params = _SendParams(
      device: _Device([local, remote]), socket: socket, localSocket: localSocket);
  createSendTransport(CreateSendTransportOptions(option: 'audio', parameters: params));
  clock.flushMicrotasks();
  expect(params.localProducerTransport, same(local));
  expect(params.producerTransport, same(remote));
  return (remote: remote, local: local, socket: socket, localSocket: localSocket);
}

({_Transport transport, _Socket socket, _RecvParams params}) _recvSetup(
    FakeAsync clock) {
  final transport = _Transport('recv');
  final socket = _Socket('recv-socket');
  final params = _RecvParams(_Device([transport]));
  signalNewConsumerTransport(SignalNewConsumerTransportOptions(
    remoteProducerId: 'producer-1',
    islevel: '1',
    nsock: socket,
    parameters: params,
  ));
  clock.flushMicrotasks();
  return (transport: transport, socket: socket, params: params);
}

/// A disconnect that escalates: the grace ends once the state leaves
/// `disconnected`, without emitting a second event.
void _disconnect(FakeAsync clock, _Transport transport) {
  transport.setState('disconnected');
  clock.elapse(const Duration(milliseconds: 300));
  transport.connectionState = 'failed';
  clock.elapse(const Duration(milliseconds: 200));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('connectionstatechange map payload starts ICE recovery', () {
    test('remote send transport on failed', () {
      fakeAsync((clock) {
        final s = _sendSetup(clock);
        s.remote.setState('failed');
        clock.flushMicrotasks();
        expect(s.socket.restartRequests, [
          {'transportId': 'remote'}
        ]);
        expect(s.localSocket.restartRequests, isEmpty);
      });
    });

    test('remote send transport on disconnected', () {
      fakeAsync((clock) {
        final s = _sendSetup(clock);
        _disconnect(clock, s.remote);
        expect(s.socket.restartRequests, [
          {'transportId': 'remote'}
        ]);
      });
    });

    test('local send transport on failed', () {
      fakeAsync((clock) {
        final s = _sendSetup(clock);
        s.local.setState('failed');
        clock.flushMicrotasks();
        expect(s.localSocket.restartRequests, [
          {'transportId': 'local'}
        ]);
        expect(s.socket.restartRequests, isEmpty);
      });
    });

    test('local send transport on disconnected', () {
      fakeAsync((clock) {
        final s = _sendSetup(clock);
        _disconnect(clock, s.local);
        expect(s.localSocket.restartRequests, [
          {'transportId': 'local'}
        ]);
      });
    });

    test('receive transport on failed', () {
      fakeAsync((clock) {
        final r = _recvSetup(clock);
        r.transport.setState('failed');
        clock.flushMicrotasks();
        expect(r.socket.restartRequests, [
          {'transportId': 'recv'}
        ]);
      });
    });

    test('receive transport on disconnected', () {
      fakeAsync((clock) {
        final r = _recvSetup(clock);
        _disconnect(clock, r.transport);
        expect(r.socket.restartRequests, [
          {'transportId': 'recv'}
        ]);
      });
    });

    test('connecting and connected do not start recovery', () {
      fakeAsync((clock) {
        final r = _recvSetup(clock);
        r.transport.setState('connecting');
        r.transport.setState('connected');
        clock.elapse(const Duration(seconds: 5));
        expect(r.socket.restartRequests, isEmpty);
        expect(r.transport.closed, isFalse);
      });
    });
  });

  group('refused recovery closes and resets', () {
    test('receive transport closes and streams reorder', () {
      fakeAsync((clock) {
        final r = _recvSetup(clock);
        r.transport.setState('failed');
        clock.elapse(const Duration(seconds: 3));
        expect(r.socket.restartRequests, hasLength(2));
        expect(r.transport.closed, isTrue);
        expect(r.params.reorders, 1);
      });
    });

    test('remote send transport closes and clears the live transport', () {
      fakeAsync((clock) {
        final local = _Transport('local'), remote = _Transport('remote');
        final params = _SendParams(
            device: _Device([local, remote]),
            socket: _Socket('remote-socket'),
            localSocket: _Socket('local-socket'));
        createSendTransport(
            CreateSendTransportOptions(option: 'audio', parameters: params));
        clock.flushMicrotasks();
        remote.setState('failed');
        clock.elapse(const Duration(seconds: 3));
        expect(remote.closed, isTrue);
        expect(params.producerTransport, isNull);
        expect(params.transportCreated, isFalse);
        expect(local.closed, isFalse);
      });
    });
  });
}
