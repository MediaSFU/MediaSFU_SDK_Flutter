import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../types/types.dart' show ShowAlert;

typedef UpdateSetting = void Function(String value);
typedef UpdateIsSettingsModalVisible = void Function(bool value);

/// Options for modifying room settings.
class ModifySettingsOptions {
  final ShowAlert? showAlert;
  final String roomName;
  final String audioSet;
  final String videoSet;
  final String screenshareSet;
  final String chatSet;
  final io.Socket? socket;
  final UpdateSetting updateAudioSetting;
  final UpdateSetting updateVideoSetting;
  final UpdateSetting updateScreenshareSetting;
  final UpdateSetting updateChatSetting;
  final UpdateIsSettingsModalVisible updateIsSettingsModalVisible;

  ModifySettingsOptions({
    this.showAlert,
    required this.roomName,
    required this.audioSet,
    required this.videoSet,
    required this.screenshareSet,
    required this.chatSet,
    this.socket,
    required this.updateAudioSetting,
    required this.updateVideoSetting,
    required this.updateScreenshareSetting,
    required this.updateChatSetting,
    required this.updateIsSettingsModalVisible,
  });
}

/// Type definition for the modifySettings function.
typedef ModifySettingsType = Future<void> Function(
    ModifySettingsOptions options);

/// Modifies settings for a given room and updates the state accordingly.
///
/// - `options`: Options for modifying settings, including:
///   - `showAlert`: Function to show alert messages (optional).
///   - `roomName`: The name of the room.
///   - `audioSet`: The audio setting to be applied.
///   - `videoSet`: The video setting to be applied.
///   - `screenshareSet`: The screenshare setting to be applied.
///   - `chatSet`: The chat setting to be applied.
///   - `socket`: The socket instance for emitting events.
///   - `updateAudioSetting`: Function to update the audio setting state.
///   - `updateVideoSetting`: Function to update the video setting state.
///   - `updateScreenshareSetting`: Function to update the screenshare setting state.
///   - `updateChatSetting`: Function to update the chat setting state.
///   - `updateIsSettingsModalVisible`: Function to update the visibility of the settings modal.
///
/// Throws an alert if any setting is set to "approval" in demo mode (room name starts with "d").
///
/// Example usage:
/// ```dart
/// modifySettings(
///   ModifySettingsOptions(
///     roomName: "d123",
///     audioSet: "allow",
///     videoSet: "allow",
///     screenshareSet: "deny",
///     chatSet: "allow",
///     socket: mySocketInstance,
///     updateAudioSetting: setAudioSetting,
///     updateVideoSetting: setVideoSetting,
///     updateScreenshareSetting: setScreenshareSetting,
///     updateChatSetting: setChatSetting,
///     updateIsSettingsModalVisible: setIsSettingsModalVisible,
///     showAlert: (options) => alertUser(options),
///   ),
/// );
/// ```
///

Future<void> modifySettings(ModifySettingsOptions options) async {
  if (options.roomName.toLowerCase().startsWith('d')) {
    // None of the settings should be set to 'approval' in demo mode
    if (options.audioSet == 'approval' ||
        options.videoSet == 'approval' ||
        options.screenshareSet == 'approval' ||
        options.chatSet == 'approval') {
      options.showAlert?.call(
        message: 'You cannot set approval for demo mode.',
        type: 'danger',
        duration: 3000,
      );
      return;
    }
  }

  // Update settings based on the provided options
  if (options.audioSet.isNotEmpty) options.updateAudioSetting(options.audioSet);
  if (options.videoSet.isNotEmpty) options.updateVideoSetting(options.videoSet);
  if (options.screenshareSet.isNotEmpty) {
    options.updateScreenshareSetting(options.screenshareSet);
  }
  if (options.chatSet.isNotEmpty) options.updateChatSetting(options.chatSet);

  // Emit updated settings
  final settings = [
    options.audioSet,
    options.videoSet,
    options.screenshareSet,
    options.chatSet
  ];
  options.socket!.emit('updateSettingsForRequests', {
    'settings': settings,
    'roomName': options.roomName,
  });

  // Close modal
  options.updateIsSettingsModalVisible(false);
}
