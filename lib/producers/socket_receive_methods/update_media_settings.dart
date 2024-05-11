/// Update media settings for all participants by the admin.
///
/// This function updates the media settings for all participants in a video conference.
/// It takes a list of settings and a map of parameters as input.
/// The list of settings contains the audio, video, screenshare, and chat settings in the specified order.
/// The map of parameters contains the update functions for each setting.
///
/// Example usage:
/// ```dart
/// updateMediaSettings(
///   settings: ['allow', 'allow', 'allow', 'allow'],
///   parameters: {
///     'updateAudioSetting': (item) {
///       // Update audio setting logic here
///     },
///     'updateVideoSetting': (item) {
///       // Update video setting logic here
///     },
///     'updateScreenshareSetting': (item) {
///       // Update screenshare setting logic here
///     },
///     'updateChatSetting': (item) {
///       // Update chat setting logic here
///     },
///   },
/// );
/// ```
///
/// Throws an error if any of the update functions fail.
typedef UpdateSettingsItem = void Function(String item);

void updateMediaSettings({
  required List settings,
  required Map<String, dynamic> parameters,
}) async {
  try {
    // Destructure parameters
    final UpdateSettingsItem updateAudioSetting =
        parameters['updateAudioSetting'];
    final UpdateSettingsItem updateVideoSetting =
        parameters['updateVideoSetting'];
    final UpdateSettingsItem updateScreenshareSetting =
        parameters['updateScreenshareSetting'];
    final UpdateSettingsItem updateChatSetting =
        parameters['updateChatSetting'];

    // Extract settings
    final String audioSetting = settings[0] ?? 'allow';
    final String videoSetting = settings[1] ?? 'allow';
    final String screenshareSetting = settings[2] ?? 'allow';
    final String chatSetting = settings[3] ?? 'allow';

    // Update audio setting
    updateAudioSetting(audioSetting);
    // Update video setting
    updateVideoSetting(videoSetting);
    // Update screenshare setting
    updateScreenshareSetting(screenshareSetting);
    // Update chat setting
    updateChatSetting(chatSetting);
  } catch (error) {
    // print("Error in updateMediaSettings: $error");
    // Handle error accordingly
  }
}
