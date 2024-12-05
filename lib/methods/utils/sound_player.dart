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
    if (!_isValidUrl(options.soundUrl)) {
      if (kDebugMode) {
        print('Invalid URL: ${options.soundUrl}');
      }
      return;
    }

    try {
      await _audioPlayer.play(UrlSource(options.soundUrl));
    } catch (e) {
      if (kDebugMode) {
        print('Failed to play sound: $e');
      }
    }
  }

  /// Stops the currently playing sound.
  static Future<void> stop() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to stop sound: $e');
      }
    }
  }

  /// Validates the sound URL.
  static bool _isValidUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && (uri.hasScheme && uri.hasAuthority);
  }

  /// Preloads the sound for faster playback.
  static Future<void> preload(SoundPlayerOptions options) async {
    try {
      await _audioPlayer.setSource(UrlSource(options.soundUrl));
    } catch (e) {
      if (kDebugMode) {
        print('Failed to preload sound: $e');
      }
    }
  }

  /// Stops and reinitializes the audio player.
  static Future<void> stopAndReinitialize() async {
    try {
      await _audioPlayer.stop();
      _audioPlayer.release();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to stop and reinitialize: $e');
      }
    }
  }

  /// Attaches listeners for playback events.
  static void attachListeners() {
    _audioPlayer.onPlayerComplete.listen((_) {
      if (kDebugMode) {
        print('Playback completed.');
      }
    });
  }
}
