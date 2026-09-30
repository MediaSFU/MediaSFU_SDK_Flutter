import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';
import 'package:mediasfu_sdk/consumers/connect_send_transport_video.dart';
import 'package:mediasfu_sdk/methods/utils/producer/room_video_params.dart';
import 'package:mediasfu_sdk/methods/utils/producer/v_params.dart';
import 'package:mediasfu_sdk/types/types.dart' show ProducerOptionsType;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('FlutterWebRTC.Method');
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'getUserMedia') {
            return {
              'streamId': 'test-camera',
              'audioTracks': [],
              'videoTracks': [
                {
                  'id': 'test-track',
                  'label': 'Camera',
                  'kind': 'video',
                  'enabled': true,
                },
              ],
            };
          }
          return null;
        });
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test(
    'legacy single encoding without scalability mode remains valid',
    () async {
      final params = _CameraParameters();
      final video = ProducerOptionsType(
        encodings: [
          RtpEncodingParameters(maxBitrate: 800000, maxFramerate: 15),
        ],
      );
      await connectSendTransportVideo(
        ConnectSendTransportVideoOptions(
          videoParams: video,
          parameters: params,
        ),
      );
      for (final transport in [
        params.producerTransport,
        params.localProducerTransport,
      ]) {
        final captured = transport as _Transport;
        expect(captured.calls.single.single.maxBitrate, 800000);
        expect(captured.calls.single.single.scalabilityMode, 'L1T3');
      }
      expect(video.encodings.single.scalabilityMode, isNull);
    },
  );

  for (final capacity in [2, 8]) {
    test(
      'camera options reach both transports at capacity $capacity',
      () async {
        final params = _CameraParameters();
        final video = roomVideoParams(
          vParams,
          targetResolution: 'hd',
          isChat: false,
          capacity: capacity,
        );
        video.encodings.last.maxFramerate = 15;
        await connectSendTransportVideo(
          ConnectSendTransportVideoOptions(
            videoParams: video,
            parameters: params,
          ),
        );
        for (final transport in [
          params.producerTransport,
          params.localProducerTransport,
        ]) {
          final captured = transport as _Transport;
          expect(captured.calls, hasLength(1));
          final encodings = captured.calls.single;
          expect(
            encodings.map((e) => e.toMap()).toList(),
            video.encodings.map((e) => e.toMap()).toList(),
          );
          expect(encodings, hasLength(capacity == 2 ? 1 : 3));
          expect(encodings.last.maxFramerate, 15);
          expect(identical(encodings.last, video.encodings.last), isFalse);
        }
      },
    );
  }
}

class _Transport implements Transport {
  final calls = <List<RtpEncodingParameters>>[];
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #produce) {
      calls.add(
        invocation.namedArguments[#encodings] as List<RtpEncodingParameters>,
      );
      return null;
    }
    return super.noSuchMethod(invocation);
  }
}

class _CameraParameters implements ConnectSendTransportVideoParameters {
  @override
  final producerTransport = _Transport();
  @override
  final localProducerTransport = _Transport();
  @override
  Producer? get videoProducer => null;
  @override
  Producer? get localVideoProducer => null;
  @override
  MediaStream? get localStream => null;
  @override
  MediaStream? get localStreamVideo => null;
  @override
  String get islevel => '1';
  @override
  bool get updateMainWindow => false;
  @override
  ConnectSendTransportVideoParameters Function() get getUpdatedAllParams =>
      () => this;
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.isGetter &&
        invocation.memberName.toString().contains('update')) {
      return (dynamic value) {};
    }
    return super.noSuchMethod(invocation);
  }
}
