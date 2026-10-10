import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';
import 'package:mediasfu_sdk/consumers/create_send_transport.dart';
import 'package:mediasfu_sdk/consumers/send_transport_guard.dart';
import 'package:mediasfu_sdk/types/types.dart'
    show ConnectSendTransportOptions, ConnectSendTransportType;
import 'package:socket_io_client/socket_io_client.dart' as io;

// Oct 10 2026 incident: a second send transport per socket silenced the device's microphone
// ("connect() already called" on the server).

class _FakeSocket implements io.Socket {
  final List<Function> pendingAcks = [];
  int createRequests = 0;

  @override
  String? get id => 'socket-1';

  @override
  void emitWithAck(String event, dynamic data,
      {Function? ack, bool binary = false, bool withTimeout = false, int? timeout}) {
    if (event == 'createWebRtcTransport') {
      createRequests += 1;
      if (ack != null) pendingAcks.add(ack);
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeTransport implements Transport {
  @override
  bool get closed => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeDevice implements Device {
  int transports = 0;

  @override
  Transport createSendTransportFromMap(Map data,
      {Function? producerCallback, Function? dataProducerCallback}) {
    transports += 1;
    return _FakeTransport();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeParams implements CreateSendTransportParameters {
  _FakeParams(this.socket, this.device);

  @override
  final io.Socket? socket;
  @override
  final Device? device;

  @override
  bool transportCreated = false;
  @override
  Transport? producerTransport;
  @override
  Producer? audioProducer;
  @override
  Producer? videoProducer;
  @override
  Producer? screenProducer;

  final List<ConnectSendTransportOptions> connects = [];

  @override
  String get islevel => '1';
  @override
  String get member => 'alice';
  @override
  io.Socket? get localSocket => null;

  @override
  UpdateProducerTransport get updateProducerTransport =>
      (transport) => producerTransport = transport;
  @override
  UpdateTransportCreated get updateTransportCreated =>
      (created) => transportCreated = created;
  @override
  UpdateAudioProducer get updateAudioProducer => (p) => audioProducer = p;
  @override
  UpdateVideoProducer get updateVideoProducer => (p) => videoProducer = p;
  @override
  UpdateScreenProducer get updateScreenProducer => (p) => screenProducer = p;

  @override
  ConnectSendTransportType get connectSendTransport => (options) async {
        connects.add(options);
      };

  @override
  CreateSendTransportParameters Function() get getUpdatedAllParams =>
      () => this;

  dynamic Function() get getCurrentParams => () => this;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  group('createSendTransport', () {
    test('two concurrent calls create one transport and both media use it', () async {
      final socket = _FakeSocket();
      final device = _FakeDevice();
      final params = _FakeParams(socket, device);

      final microphone = createSendTransport(
          CreateSendTransportOptions(option: 'audio', parameters: params));
      final camera = createSendTransport(
          CreateSendTransportOptions(option: 'video', parameters: params));
      await Future<void>.delayed(Duration.zero);

      expect(socket.createRequests, 1); // the camera waits for the microphone's creation
      final ack = socket.pendingAcks.single;
      await ack({'params': {'id': 'transport-1'}});
      await Future.wait([microphone, camera]);

      expect(device.transports, 1);
      expect(socket.createRequests, 1);
      expect(params.transportCreated, isTrue);
      expect(params.connects.map((c) => c.option), ['audio', 'video']);
      expect(params.connects.first.targetOption, 'remote'); // produced by the creation itself
      expect(params.connects.last.targetOption, 'all'); // produced on the existing transport
    });

    test('a call after the transport exists does not create another', () async {
      final socket = _FakeSocket();
      final params = _FakeParams(socket, _FakeDevice())
        ..transportCreated = true
        ..producerTransport = _FakeTransport();
      await createSendTransport(
          CreateSendTransportOptions(option: 'screen', parameters: params));
      expect(socket.createRequests, 0);
      expect(params.connects.single.option, 'screen');
    });
  });

  group('SendTransportGuard', () {
    test('later callers wait for the creation in flight for the same socket', () async {
      final socket = Object();
      final gate = Completer<void>();
      var creations = 0;
      final first = SendTransportGuard.trackCreation(socket, () async {
        creations += 1;
        await gate.future;
      });
      final pending = SendTransportGuard.pendingCreation(socket);
      expect(pending, isNotNull);
      expect(SendTransportGuard.pendingCreation(Object()), isNull); // other sockets are independent

      var waited = false;
      final second = pending!.then((_) => waited = true);
      await Future<void>.delayed(Duration.zero);
      expect(waited, isFalse);
      gate.complete();
      await Future.wait([first, second]);
      expect(waited, isTrue);
      expect(creations, 1);
      expect(SendTransportGuard.pendingCreation(socket), isNull); // released once settled
    });

    test('a failed creation releases the socket', () async {
      final socket = Object();
      await SendTransportGuard.trackCreation(socket, () async => throw StateError('no ack'))
          .catchError((_) {});
      expect(SendTransportGuard.pendingCreation(socket), isNull);
    });

    test('a same-source produce runs once until its producer arrives', () {
      final transport = Object();
      final t0 = DateTime(2026, 10, 10, 12);
      expect(SendTransportGuard.beginProduce(transport, 'mic', now: t0), isTrue);
      expect(SendTransportGuard.beginProduce(transport, 'mic', now: t0.add(const Duration(seconds: 1))), isFalse);
      expect(SendTransportGuard.beginProduce(transport, 'webcam', now: t0), isTrue); // other kinds proceed
      SendTransportGuard.finishProduce(transport, 'mic');
      expect(SendTransportGuard.beginProduce(transport, 'mic', now: t0.add(const Duration(seconds: 2))), isTrue);
    });

    test('a produce that never reports back stops blocking after the timeout', () {
      final transport = Object();
      final t0 = DateTime(2026, 10, 10, 12);
      expect(SendTransportGuard.beginProduce(transport, 'screen', now: t0), isTrue);
      expect(
        SendTransportGuard.beginProduce(transport, 'screen',
            now: t0.add(SendTransportGuard.produceTimeout)),
        isTrue,
      );
    });
  });
}
