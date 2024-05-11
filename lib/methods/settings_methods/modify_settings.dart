import 'package:socket_io_client/socket_io_client.dart' as io;

/// Modifies the settings based on the provided parameters.
///
/// The [parameters] map should contain the following keys:
/// - 'showAlert': A function to show an alert message.
/// - 'roomName': The name of the room.
/// - 'audioSet': The audio setting.
/// - 'videoSet': The video setting.
/// - 'screenshareSet': The screenshare setting.
/// - 'chatSet': The chat setting.
/// - 'socket': The socket for communication.
///
/// The [showAlert] function is used to display an alert message with the specified [message],
/// [type], and [duration].
///
/// The [updateAudioSetting], [updateVideoSetting], [updateScreenshareSetting], [updateChatSetting],
/// and [updateIsSettingsModalVisible] functions are used to update the corresponding settings and
/// visibility of the settings modal.
///
/// If the [roomName] starts with the letter 'd', none of the settings should be set to 'approval'.
///
/// The [updateAudioSetting], [updateVideoSetting], [updateScreenshareSetting], and [updateChatSetting]
/// functions are called to update the state variables based on the provided logic.
///
/// The [settings] list is created with the provided audio, video, screenshare, and chat settings.
///
/// The 'updateSettingsForRequests' event is emitted to the [socket] with the updated settings and room name.
///
/// Finally, the [updateIsSettingsModalVisible] function is called to close the settings modal.

typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

typedef UpdateSetting = void Function(String value);
typedef UpdateIsSettingsModalVisible = void Function(bool value);

void modifySettings({
  required Map<String, dynamic> parameters,
}) async {
  final ShowAlert? showAlert = parameters['showAlert'];
  final String roomName = parameters['roomName'];
  final String audioSet = parameters['audioSet'];
  final String videoSet = parameters['videoSet'];
  final String screenshareSet = parameters['screenshareSet'];
  final String chatSet = parameters['chatSet'];
  final io.Socket socket = parameters['socket'];

  final UpdateSetting updateAudioSetting = parameters['updateAudioSetting'];
  final UpdateSetting updateVideoSetting = parameters['updateVideoSetting'];
  final UpdateSetting updateScreenshareSetting =
      parameters['updateScreenshareSetting'];
  final UpdateSetting updateChatSetting = parameters['updateChatSetting'];
  final UpdateIsSettingsModalVisible updateIsSettingsModalVisible =
      parameters['updateIsSettingsModalVisible'];

  if (roomName.toLowerCase().startsWith('d')) {
    //none should be approval
    if (audioSet == 'approval' ||
        videoSet == 'approval' ||
        screenshareSet == 'approval' ||
        chatSet == 'approval') {
      if (showAlert != null) {
        showAlert(
          message: 'You cannot set approval for demo mode.',
          type: 'danger',
          duration: 3000,
        );
      }
      return;
    }
  }

  // Check and update state variables based on the provided logic
  if (audioSet.isNotEmpty) {
    updateAudioSetting(audioSet);
  }
  if (videoSet.isNotEmpty) {
    updateVideoSetting(videoSet);
  }
  if (screenshareSet.isNotEmpty) {
    updateScreenshareSetting(screenshareSet);
  }
  if (chatSet.isNotEmpty) {
    updateChatSetting(chatSet);
  }

  List<String?> settings = [audioSet, videoSet, screenshareSet, chatSet];

  socket.emit('updateSettingsForRequests',
      {'settings': settings, 'roomName': roomName});

  // Close modal
  updateIsSettingsModalVisible(false);
}
