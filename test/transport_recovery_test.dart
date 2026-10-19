import 'package:fake_async/fake_async.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';
import 'package:mediasfu_sdk/consumers/transport_ice_recovery.dart';
import 'package:mediasfu_sdk/methods/stream_methods/click_audio.dart';
import 'package:mediasfu_sdk/types/types.dart' show Participant;
import 'package:socket_io_client/socket_io_client.dart' as io;

class _Transport implements Transport {
  @override
  bool closed = false;
  @override
  String connectionState = 'failed';
  int restarts = 0;
  @override
  String get id => 'test-transport';
  @override
  void restartIce(IceParameters parameters) {
    restarts++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _Socket implements io.Socket {
  @override
  bool connected = true;
  @override
  String? id = 'test-socket';
  int requests = 0;
  final List<Function> acknowledgements = [];
  bool reject = true;
  @override
  void emitWithAck(
    String event,
    dynamic data, {
    Function? ack,
    bool binary = false,
    bool withTimeout = false,
    int? timeout,
  }) {
    if (event != 'transport-restart-ice') return;
    requests++;
    if (ack != null) {
      acknowledgements.add(ack);
      if (reject) ack({'error': 'test-refusal'});
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _Producer implements Producer {
  _Producer({this.closed = false});
  @override
  final bool closed;
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _Microphone implements ClickAudioParameters {
  _Microphone({
    this.audioProducer,
    this.producerTransport,
    this.restricted = false,
  });
  final bool restricted;
  MediaStream? stream;
  @override
  MediaStream? get localStream => stream;
  @override
  io.Socket get socket => _Socket();
  @override
  Producer? audioProducer;
  @override
  Transport? producerTransport;
  @override
  bool audioPaused = true;
  @override
  bool audioAlreadyOn = false;
  int resumes = 0;
  int capturesAccepted = 0;
  bool? transportAtCapture;
  bool? audioAtCapture;
  Producer? producerAtCapture;
  final alerts = <String>[];
  @override
  String get islevel => '2';
  @override
  String get member => 'Asha748';
  @override
  String get roomName => 'smurecovery01';
  @override
  bool get checkMediaPermission => false;
  @override
  bool get hasAudioPermission => true;
  @override
  bool get recordStarted => false;
  @override
  bool get recordResumed => false;
  @override
  bool get recordPaused => false;
  @override
  bool get recordStopped => false;
  @override
  bool get adminRestrictSetting => restricted;
  @override
  bool get youAreCoHost => false;
  @override
  bool get panellistFocused => false;
  @override
  bool get muteOthersMic => false;
  @override
  bool get muteOthersCamera => false;
  @override
  bool get micAction => false;
  @override
  bool transportCreated = true;
  @override
  bool transportCreatedAudio = true;
  @override
  String? get audioRequestState => null;
  @override
  int? get audioRequestTime => null;
  @override
  String get recordingMediaOptions => 'video';
  @override
  String get userDefaultAudioInputDevice => '';
  @override
  String get audioSetting => 'allow';
  @override
  String get videoSetting => 'allow';
  @override
  String get screenshareSetting => 'allow';
  @override
  String get chatSetting => 'allow';
  @override
  int get updateRequestIntervalSeconds => 120;
  @override
  List<Participant> get participants => [];
  @override
  List<Participant> get panelists => [];
  @override
  get showAlert =>
      ({
        required String message,
        required String type,
        required int duration,
      }) => alerts.add(message);
  @override
  get updateAudioPaused =>
      (bool value) => audioPaused = value;
  @override
  get updateAudioAlreadyOn =>
      (bool value) => audioAlreadyOn = value;
  @override
  get updateAudioRequestState => (String? value) {};
  @override
  get updateLocalStream => (MediaStream? value) {};
  @override
  get updateParticipants => (List<Participant> value) {};
  @override
  get updateTransportCreated =>
      (bool value) => transportCreated = value;
  @override
  get updateTransportCreatedAudio =>
      (bool value) => transportCreatedAudio = value;
  @override
  get updateAudioProducer =>
      (Producer? value) => audioProducer = value;
  @override
  get updateProducerTransport =>
      (Transport? value) => producerTransport = value;
  @override
  get updateMicAction => (bool value) {};
  @override
  get checkPermission =>
      (options) async => 0;
  @override
  get requestPermissionAudio =>
      () async => true;
  @override
  get disconnectSendTransportAudio => (options) async {};
  @override
  get streamSuccessAudio => (options) async {
    capturesAccepted++;
    transportAtCapture = transportCreated;
    audioAtCapture = transportCreatedAudio;
    producerAtCapture = audioProducer;
  };
  @override
  get resumeSendTransportAudio => ({required options}) async {
    resumes++;
  };
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('recovery during retry backoff cancels an obsolete second request', () {
    fakeAsync((clock) {
      final transport = _Transport(), socket = _Socket();
      bool? result;
      recoverTransportIce(transport, socket).then((value) => result = value);
      clock.flushMicrotasks();
      expect(socket.requests, 1);
      clock.elapse(const Duration(milliseconds: 600));
      transport.connectionState = 'connected';
      clock.elapse(const Duration(seconds: 3));
      expect(result, isTrue);
      expect(socket.requests, 1);
      expect(transport.restarts, 0);
    });
  });
  test('duplicate failure indications share one bounded recovery sequence', () {
    fakeAsync((clock) {
      final transport = _Transport(), socket = _Socket();
      final first = recoverTransportIce(transport, socket);
      expect(identical(first, recoverTransportIce(transport, socket)), isTrue);
      bool? result;
      first.then((value) => result = value);
      clock.elapse(const Duration(seconds: 3));
      expect(result, isFalse);
      expect(socket.requests, 2);
      expect(transport.closed, isFalse);
    });
  });
  test('transient disconnect gets its existing grace without a restart', () {
    fakeAsync((clock) {
      final transport = _Transport()..connectionState = 'disconnected';
      final socket = _Socket();
      bool? result;
      recoverTransportIce(transport, socket).then((value) => result = value);
      clock.elapse(const Duration(milliseconds: 400));
      transport.connectionState = 'connected';
      clock.elapse(const Duration(milliseconds: 200));
      expect(result, isTrue);
      expect(socket.requests, 0);
    });
  });
  test(
    'already requested ICE parameters are still applied after connectivity returns',
    () {
      fakeAsync((clock) {
        final transport = _Transport(), socket = _Socket()..reject = false;
        bool? result;
        recoverTransportIce(transport, socket).then((value) => result = value);
        transport.connectionState = 'connected';
        socket.acknowledgements.single({
          'iceParameters': {
            'usernameFragment': 'test',
            'password': 'test-only',
            'iceLite': true,
          },
        });
        clock.elapse(const Duration(seconds: 1));
        expect(result, isTrue);
        expect(transport.restarts, 1);
      });
    },
  );
  for (final changedSocket in [false, true]) {
    test(
      'obsolete socket/closed transport cancels recovery ($changedSocket)',
      () {
        fakeAsync((clock) {
          final transport = _Transport(), socket = _Socket();
          bool? result;
          recoverTransportIce(
            transport,
            socket,
          ).then((value) => result = value);
          clock.flushMicrotasks();
          if (changedSocket) {
            socket.id = 'replacement';
          } else {
            transport.closed = true;
          }
          clock.elapse(const Duration(seconds: 3));
          expect(result, isFalse);
          expect(socket.requests, 1);
        });
      },
    );
  }
  for (final healthyTransport in [false, true]) {
    for (final closedProducer in [false, true]) {
      test(
        'explicit microphone retry captures after missing/closed paused producer ($closedProducer, healthy transport $healthyTransport)',
        () async {
          var captureRequests = 0;
          const channel = MethodChannel('FlutterWebRTC.Method');
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(channel, (call) async {
                if (call.method == 'getUserMedia') {
                  captureRequests++;
                  return {
                    'streamId': 'fresh-capture',
                    'audioTracks': [
                      {
                        'id': 'fresh-track',
                        'label': 'Test',
                        'kind': 'audio',
                        'enabled': true,
                      },
                    ],
                    'videoTracks': [],
                  };
                }
                return null;
              });
          addTearDown(
            () => TestDefaultBinaryMessengerBinding
                .instance
                .defaultBinaryMessenger
                .setMockMethodCallHandler(channel, null),
          );
          final parameters = _Microphone(
            audioProducer: closedProducer ? _Producer(closed: true) : null,
            producerTransport: healthyTransport
                ? (_Transport()..connectionState = 'connected')
                : closedProducer
                ? (_Transport()..closed = true)
                : null,
          );
          expect(captureRequests, 0);
          expect(parameters.audioAlreadyOn, isFalse);
          await clickAudio(ClickAudioOptions(parameters: parameters));
          expect(parameters.audioPaused, isFalse);
          expect(parameters.resumes, 0);
          expect(captureRequests, 1);
          expect(parameters.capturesAccepted, 1);
          expect(parameters.transportAtCapture, healthyTransport);
          expect(parameters.audioAtCapture, isFalse);
          expect(parameters.producerAtCapture, isNull);
        },
      );
    }
  }
  test('host restriction still blocks stale paused-state capture', () async {
    final parameters = _Microphone(restricted: true);
    await clickAudio(ClickAudioOptions(parameters: parameters));
    expect(parameters.audioPaused, isTrue);
    expect(parameters.audioAlreadyOn, isFalse);
    expect(parameters.capturesAccepted, 0);
    expect(parameters.alerts.single, contains('Access denied by host'));
  });
  test('a live muted producer resumes without new capture', () async {
    var captures = 0;
    const channel = MethodChannel('FlutterWebRTC.Method');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'getUserMedia') {
            captures++;
            return {
              'streamId': 'muted-capture',
              'audioTracks': [
                {
                  'id': 'muted-track',
                  'label': 'Test',
                  'kind': 'audio',
                  'enabled': false,
                },
              ],
              'videoTracks': [],
            };
          }
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );
    final parameters = _Microphone(
      audioProducer: _Producer(),
      producerTransport: _Transport(),
    );
    parameters.stream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': false,
    });
    expect(captures, 1);
    await clickAudio(ClickAudioOptions(parameters: parameters));
    expect(parameters.resumes, 1);
    expect(parameters.capturesAccepted, 0);
    expect(captures, 1);
    expect(parameters.audioAlreadyOn, isTrue);
    await parameters.stream!.dispose();
  });
}
