import 'package:flutter_test/flutter_test.dart';
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart'
    show RtpEncodingParameters;
import 'package:mediasfu_sdk/methods/utils/producer/room_video_params.dart';
import 'package:mediasfu_sdk/methods/utils/producer/v_params.dart';

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
}
