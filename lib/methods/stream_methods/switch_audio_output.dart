import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// Options for switching audio output device
class SwitchAudioOutputOptions {
  /// Whether to enable speakerphone
  final bool speakerOn;

  /// Whether to prefer Bluetooth when available
  final bool preferBluetooth;

  SwitchAudioOutputOptions({
    required this.speakerOn,
    this.preferBluetooth = true,
  });
}

typedef SwitchAudioOutputType = Future<bool> Function(
    SwitchAudioOutputOptions options);

/// Switches audio output between speaker and earpiece/default.
///
/// On mobile:
/// - `speakerOn = true` → Routes audio to loud speaker
/// - `speakerOn = false` → Routes audio to earpiece (or Bluetooth if connected)
///
/// ### Platform Support:
/// - **Android**: Uses `AudioManager.setSpeakerphoneOn()`
/// - **iOS**: Uses `AVAudioSession.overrideOutputAudioPort()`
/// - **Web**: Has no effect (browsers use system default audio output)
///
/// ### Example:
/// ```dart
/// await switchAudioOutput(SwitchAudioOutputOptions(
///   speakerOn: true,
///   preferBluetooth: true,
/// ));
/// ```
Future<bool> switchAudioOutput(SwitchAudioOutputOptions options) async {
  // Web browsers don't support audio output switching
  if (kIsWeb) {
    return false;
  }

  try {
    if (options.preferBluetooth && options.speakerOn) {
      // Use speaker but prefer Bluetooth if available
      await Helper.setSpeakerphoneOnButPreferBluetooth();
    } else {
      // Force speaker or earpiece
      await Helper.setSpeakerphoneOn(options.speakerOn);
    }
    return true;
  } catch (e) {
    // Silently fail - some platforms may not support this
    return false;
  }
}
