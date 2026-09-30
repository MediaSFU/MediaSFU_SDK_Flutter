import 'package:flutter_test/flutter_test.dart';
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart'
    show RtpEncodingParameters, RtpCapabilities;
import 'package:mediasfu_sdk/methods/utils/producer/room_video_params.dart';
import 'package:mediasfu_sdk/methods/utils/producer/v_params.dart';
import 'package:mediasfu_sdk/methods/utils/producer/h_params.dart';
import 'package:mediasfu_sdk/methods/utils/producer/screen_params.dart';
import 'package:mediasfu_sdk/producer_client/producer_client_emits/update_room_parameters_client.dart';
import 'package:mediasfu_sdk/types/types.dart'
    show
        EventType,
        MeetingRoomParams,
        ProducerOptionsType,
        RecordingParams,
        ResponseJoinRoom,
        ResponseJoinLocalRoom;
import 'package:mediasfu_sdk/methods/utils/create_response_join_room.dart';

void main() {
  test('room quality options never scale the shared preset twice', () {
    final baseBitrate = vParams.encodings.first.maxBitrate!;
    final hd = freshRoomVideoParams(vParams);
    hd.encodings[0] = RtpEncodingParameters(maxBitrate: baseBitrate * 4);
    final nextRoom = freshRoomVideoParams(vParams);

    expect(vParams.encodings.first.maxBitrate, baseBitrate);
    expect(nextRoom.encodings.first.maxBitrate, baseBitrate);
    expect(identical(hd.encodings.first, nextRoom.encodings.first), isFalse);
    expect(identical(hd.codecOptions, nextRoom.codecOptions), isFalse);
  });

  for (final preset in [vParams, hParams]) {
    for (final resolution in ['sd', 'hd', 'fhd', 'qhd', 'QnHD']) {
      test('capacity two preserves full resolution at $resolution for '
          '${identical(preset, hParams) ? 'host' : 'participant'}', () {
        final multi = roomVideoParams(
          preset,
          targetResolution: resolution,
          isChat: false,
          capacity: 8,
        );
        final single = roomVideoParams(
          preset,
          targetResolution: resolution,
          isChat: false,
          capacity: 2,
        );
        expect(multi.encodings, hasLength(3));
        expect(single.encodings, hasLength(1));
        expect(single.encodings.single.scaleResolutionDownBy, 1.0);
        expect(single.encodings.single.rid, isNull);
        expect(
          single.encodings.single.maxBitrate,
          multi.encodings.last.maxBitrate,
        );
        expect(
          single.encodings.single.minBitrate,
          multi.encodings.last.minBitrate,
        );
        expect(single.encodings.single.scalabilityMode, 'L1T3');
      });
    }
  }

  test('explicit off and chat independently disable simulcast', () {
    for (final isChat in [false, true]) {
      final params = roomVideoParams(
        vParams,
        targetResolution: 'sd',
        isChat: isChat,
        capacity: 8,
        simulcastOff: !isChat,
      );
      expect(params.encodings, hasLength(1));
    }
    expect(
      roomVideoParams(
        vParams,
        targetResolution: 'sd',
        isChat: true,
        simulcastOff: false,
      ).encodings,
      hasLength(1),
    );
  });

  test('unknown capacity does not assume a two-person room', () {
    expect(
      roomVideoParams(vParams, targetResolution: 'sd', isChat: false).encodings,
      hasLength(3),
    );
  });

  test('single stream selection cannot mutate the preset or later rooms', () {
    final single = roomVideoParams(
      vParams,
      targetResolution: 'hd',
      isChat: false,
      capacity: 2,
    );
    single.encodings.single.maxBitrate = 1;
    expect(vParams.encodings, hasLength(3));
    expect(vParams.encodings.last.maxBitrate, 800000);
    expect(
      roomVideoParams(
        vParams,
        targetResolution: 'hd',
        isChat: false,
        capacity: 8,
      ).encodings.last.maxBitrate,
      3200000,
    );
  });

  test('single encoding selects highest resolution regardless of ordering', () {
    final shuffled = ProducerOptionsType(
      encodings: [
        RtpEncodingParameters(maxBitrate: 800000, maxFramerate: 15),
        RtpEncodingParameters(maxBitrate: 200000, scaleResolutionDownBy: 4),
      ],
    );
    final single = roomVideoParams(
      shuffled,
      targetResolution: 'sd',
      isChat: false,
      simulcastOff: true,
    );
    expect(single.encodings.single.maxBitrate, 800000);
    expect(single.encodings.single.maxFramerate, 15);
  });

  test(
    'join responses preserve optional capacity without breaking old servers',
    () async {
      expect(ResponseJoinRoom.fromJson({}).capacity, isNull);
      expect(ResponseJoinRoom.fromJson({'capacity': '2'}).capacity, 2);
      expect(ResponseJoinRoom.fromJson({'capacity': 8}).toMap()['capacity'], 8);
      expect(
        ResponseJoinLocalRoom.fromJson({'capacity': 2}).toMap()['capacity'],
        2,
      );
      final converted = await createResponseJoinRoom(
        CreateResponseJoinRoomOptions(
          localRoom: ResponseJoinLocalRoom(capacity: 2, isBanned: false),
        ),
      );
      expect(converted.capacity, 2);
    },
  );

  test(
    'updater applies capacity rule and preserves screen-sharing options',
    () {
      final params = _RoomParameters(capacity: 2);
      _update(params);
      expect(params.video!.encodings, hasLength(1));
      expect(params.host!.encodings, hasLength(1));
      expect(identical(params.screen, screenParams), isTrue);
      expect(params.failures, isEmpty);
    },
  );

  test('recording never increases camera encoding or codec rates', () {
    for (final capacity in [2, 8]) {
      for (final resolution in ['sd', 'hd', 'fhd', 'qhd', 'QnHD']) {
        final plain = _RoomParameters(
          capacity: capacity,
          resolution: resolution,
        );
        final recorded = _RoomParameters(
          capacity: capacity,
          resolution: resolution,
          recording: true,
        );
        _update(plain);
        _update(recorded);
        expect(
          recorded.video!.encodings.map((e) => e.toMap()).toList(),
          plain.video!.encodings.map((e) => e.toMap()).toList(),
        );
        expect(
          recorded.host!.encodings.map((e) => e.toMap()).toList(),
          plain.host!.encodings.map((e) => e.toMap()).toList(),
        );
        expect(
          recorded.video!.codecOptions!.videoGoogleStartBitrate,
          plain.video!.codecOptions!.videoGoogleStartBitrate,
        );
        expect(
          recorded.host!.codecOptions!.videoGoogleStartBitrate,
          plain.host!.codecOptions!.videoGoogleStartBitrate,
        );
        expect(recorded.failures, isEmpty);
        expect(plain.failures, isEmpty);
      }
    }
  });

  test('server capacity takes precedence over a stale caller hint', () {
    final params = _RoomParameters(capacity: 8);
    _update(params, capacityHint: 2);
    expect(params.video!.encodings, hasLength(3));
    _update(params, simulcastOff: true);
    expect(params.video!.encodings, hasLength(1));
  });

  test('capacity hints support older servers without overriding chat', () {
    final params = _RoomParameters();
    _update(params, capacityHint: 2);
    expect(params.video!.encodings, hasLength(1));
    params.roomData.meetingRoomParams!.type = EventType.chat;
    _update(params, capacityHint: 8);
    expect(params.video!.encodings, hasLength(1));
    // A second updater call receives the normalized enum, not a raw string.
    _update(params, capacityHint: 8);
    expect(params.video!.encodings, hasLength(1));
    expect(params.failures, isEmpty);
  });
}

void _update(
  _RoomParameters params, {
  int? capacityHint,
  bool simulcastOff = false,
}) {
  updateRoomParametersClient(
    options: UpdateRoomParametersClientOptions(
      parameters: params,
      roomCapacity: capacityHint,
      simulcastOff: simulcastOff,
    ),
  );
}

class _RoomParameters extends UpdateRoomParametersClientParameters {
  _RoomParameters({
    int? capacity,
    String resolution = 'sd',
    bool recording = false,
  }) : roomData = ResponseJoinRoom(
         capacity: capacity,
         rtpCapabilities: RtpCapabilities(),
         meetingRoomParams: MeetingRoomParams(
           itemPageLimit: 2,
           mediaType: 'video',
           addCoHost: false,
           targetOrientation: 'landscape',
           targetOrientationHost: 'landscape',
           targetResolution: resolution,
           targetResolutionHost: resolution,
           type: 'conference',
           audioSetting: 'allow',
           videoSetting: 'allow',
           screenshareSetting: 'allow',
           chatSetting: 'allow',
         ),
         recordingParams: RecordingParams(
           recordingAudioPausesLimit: 0,
           recordingAudioSupport: recording,
           recordingAudioPeopleLimit: 8,
           recordingAudioParticipantsTimeLimit: 60,
           recordingVideoPausesLimit: 0,
           recordingVideoSupport: recording,
           recordingVideoPeopleLimit: 8,
           recordingVideoParticipantsTimeLimit: 60,
           recordingAllParticipantsSupport: recording,
           recordingVideoParticipantsSupport: recording,
           recordingAllParticipantsFullRoomSupport: recording,
           recordingVideoParticipantsFullRoomSupport: recording,
           recordingPreferredOrientation: 'landscape',
           recordingSupportForOtherOrientation: false,
           recordingMultiFormatsSupport: false,
           recordingHLSSupport: false,
         ),
       );

  @override
  final ResponseJoinRoom roomData;
  ProducerOptionsType? video;
  ProducerOptionsType? host;
  ProducerOptionsType? screen;
  final failures = <String>[];
  @override
  String get islevel => '1';
  @override
  bool get shared => false;
  @override
  bool get shareScreenStarted => false;
  @override
  bool get whiteboardStarted => false;
  @override
  bool get whiteboardEnded => false;
  @override
  ProducerOptionsType? get screenParams => null;
  @override
  ProducerOptionsType? get aParams => null;
  @override
  UpdateRoomParametersClientParameters Function() get getUpdatedAllParams =>
      () => this;
  @override
  void Function(ProducerOptionsType) get updateVParams =>
      (value) => video = value;
  @override
  void Function(ProducerOptionsType) get updateHParams =>
      (value) => host = value;
  @override
  void Function(ProducerOptionsType) get updateScreenParams =>
      (value) => screen = value;
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #showAlert) {
      return ({
        required String message,
        required String type,
        required int duration,
      }) {
        failures.add(message);
      };
    }
    if (invocation.isGetter &&
        invocation.memberName.toString().contains('update')) {
      return (dynamic value) {};
    }
    return super.noSuchMethod(invocation);
  }
}
