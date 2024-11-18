import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Options for the SoundPlayer, encapsulating the sound URL.
class SoundPlayerOptions {
  final String soundUrl;

  SoundPlayerOptions({required this.soundUrl});
}

typedef SoundPlayerType = Future<void> Function(SoundPlayerOptions options);

/// A sound player that plays audio from a given URL.
///
/// Example usage:
/// ```dart
/// SoundPlayer.play(SoundPlayerOptions(soundUrl: 'https://example.com/sound.mp3'));
/// ```
class SoundPlayer {
  static final AudioPlayer _audioPlayer = AudioPlayer();

  /// Plays the sound from the provided [options].
  static Future<void> play(SoundPlayerOptions options) async {
    try {
      await _audioPlayer.play(UrlSource(options.soundUrl));
    } catch (e) {
      if (kDebugMode) {
        print('Failed to play sound: $e');
      }
    }
  }
}
