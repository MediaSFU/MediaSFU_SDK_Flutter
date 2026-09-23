import 'package:flutter_test/flutter_test.dart';
import 'package:mediasfu_sdk/types/types.dart';

void main() {
  test('room denoise policy is optional and passes through unchanged', () {
    final base = MeetingRoomParams(
      itemPageLimit: 12,
      mediaType: 'audio',
      addCoHost: false,
      targetOrientation: 'landscape',
      targetOrientationHost: 'landscape',
      targetResolution: 'hd',
      targetResolutionHost: 'hd',
      type: 'conference',
      audioSetting: 'allow',
      videoSetting: 'allow',
      screenshareSetting: 'allow',
      chatSetting: 'allow',
    );
    expect(base.toMap().containsKey('backendAudioDenoise'), isFalse);

    final enabled = MeetingRoomParams.fromJson({
      ...base.toMap(),
      'backendAudioDenoise': {'enabled': true, 'profile': 'arnndn'},
    });
    expect(enabled.backendAudioDenoise, {'enabled': true, 'profile': 'arnndn'});
    expect(enabled.toMap()['backendAudioDenoise'], enabled.backendAudioDenoise);

    final disabled = CreateMediaSFURoomOptions(
      action: 'create',
      duration: 30,
      capacity: 2,
      userName: 'Host',
      backendAudioDenoise: {'enabled': false},
    );
    expect(disabled.toMap()['backendAudioDenoise'], {'enabled': false});
  });
}
