import 'package:flutter/foundation.dart';
import '../../types/types.dart' show Settings;

/// Represents the options for updating media settings, including functions to update each setting.
class UpdateMediaSettingsOptions {
  final Settings settings;
  final void Function(String) updateAudioSetting;
  final void Function(String) updateVideoSetting;
  final void Function(String) updateScreenshareSetting;
  final void Function(String) updateChatSetting;

  UpdateMediaSettingsOptions({
    required this.settings,
    required this.updateAudioSetting,
    required this.updateVideoSetting,
    required this.updateScreenshareSetting,
    required this.updateChatSetting,
  });
}

/// Type definition for updating media settings.
typedef UpdateMediaSettingsType = void Function(
    UpdateMediaSettingsOptions options);

/// Updates media settings by calling the respective update functions for each setting type.
///
/// Example usage:
/// ```dart
/// updateMediaSettings(
///   UpdateMediaSettingsOptions(
///     settings: ['enabled', 'enabled', 'disabled', 'enabled'],
///     updateAudioSetting: (value) => print("Audio setting: $value"),
///     updateVideoSetting: (value) => print("Video setting: $value"),
///     updateScreenshareSetting: (value) => print("Screenshare setting: $value"),
///     updateChatSetting: (value) => print("Chat setting: $value"),
///   ),
/// );
/// ```
void updateMediaSettings(UpdateMediaSettingsOptions options) {
  try {
    // Get the settings
    String audioSetting;
    String videoSetting;
    String screenshareSetting;
    String chatSetting;

    audioSetting = options.settings.settings.isNotEmpty
        ? options.settings.settings[0]
        : 'allow';
    videoSetting = options.settings.settings.length > 1
        ? options.settings.settings[1]
        : 'allow';
    screenshareSetting = options.settings.settings.length > 2
        ? options.settings.settings[2]
        : 'allow';
    chatSetting = options.settings.settings.length > 3
        ? options.settings.settings[3]
        : 'allow';

    // Update each setting
    options.updateAudioSetting(audioSetting);
    options.updateVideoSetting(videoSetting);
    options.updateScreenshareSetting(screenshareSetting);
    options.updateChatSetting(chatSetting);
  } catch (error) {
    if (kDebugMode) {
      print("Error in updateMediaSettings: $error");
    }
  }
}
