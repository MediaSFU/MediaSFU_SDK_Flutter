import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android example declares WebRTC capture and network permissions', () {
    final manifest = File(
      'example/android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    for (final permission in [
      'INTERNET',
      'CAMERA',
      'RECORD_AUDIO',
      'ACCESS_NETWORK_STATE',
      'CHANGE_NETWORK_STATE',
      'MODIFY_AUDIO_SETTINGS',
      'WAKE_LOCK',
      'BLUETOOTH',
      'BLUETOOTH_ADMIN',
      'BLUETOOTH_CONNECT',
      'FOREGROUND_SERVICE',
      'FOREGROUND_SERVICE_MEDIA_PROJECTION',
    ]) {
      expect(manifest, contains('android.permission.$permission'));
    }
  });

  test('Android screen sharing stops when host service cannot start', () {
    final source = File(
      'lib/consumers/start_share_screen.dart',
    ).readAsStringSync();
    expect(
      source,
      contains(
        'Screen sharing requires the Android host screen-capture service.',
      ),
    );
    expect(
      source,
      contains(
        "await _screenCaptureChannel.invokeMethod('startForegroundService');",
      ),
    );
  });
}
