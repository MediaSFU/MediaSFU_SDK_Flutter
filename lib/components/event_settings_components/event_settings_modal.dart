import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../methods/utils/get_modal_position.dart'
    show getModalPosition, GetModalPositionOptions;
import '../../methods/settings_methods/modify_settings.dart'
    show modifySettings, ModifySettingsType, ModifySettingsOptions;
import '../../types/types.dart' show ShowAlert;

/// EventSettingsModalOptions - Defines configuration options for the `EventSettingsModal`.
class EventSettingsModalOptions {
  final bool isVisible;
  final VoidCallback onClose;
  final ModifySettingsType onModifySettings;
  final String position;
  final Color backgroundColor;
  final String audioSetting;
  final String videoSetting;
  final String screenshareSetting;
  final String chatSetting;
  final String roomName;
  final io.Socket? socket;
  final ShowAlert? showAlert;
  final void Function(String) updateAudioSetting;
  final void Function(String) updateVideoSetting;
  final void Function(String) updateScreenshareSetting;
  final void Function(String) updateChatSetting;
  final void Function(bool) updateIsSettingsModalVisible;

  EventSettingsModalOptions({
    required this.isVisible,
    required this.onClose,
    this.onModifySettings = modifySettings,
    this.position = 'topRight',
    this.backgroundColor = const Color(0xFF83C0E9),
    required this.audioSetting,
    required this.videoSetting,
    required this.screenshareSetting,
    required this.chatSetting,
    required this.roomName,
    this.socket,
    required this.showAlert,
    required this.updateAudioSetting,
    required this.updateVideoSetting,
    required this.updateScreenshareSetting,
    required this.updateChatSetting,
    required this.updateIsSettingsModalVisible,
  });
}

typedef EventSettingsModalType = Widget Function({
  required EventSettingsModalOptions options,
});

/// `EventSettingsModalOptions` - Configuration options for `EventSettingsModal`.
///
/// ### Properties:
/// - `isVisible`: Boolean indicating the modal's visibility.
/// - `onClose`: Callback to close the modal.
/// - `onModifySettings`: Callback for modifying the settings, with `modifySettings` as the default function.
/// - `position`: Position of the modal on the screen (default is 'topRight').
/// - `backgroundColor`: Background color of the modal (default is `Color(0xFF83C0E9)`).
/// - `audioSetting`, `videoSetting`, `screenshareSetting`, `chatSetting`: Initial settings for each media type.
/// - `roomName`: Name of the room or event.
/// - `socket`: Socket connection for sending settings updates.
/// - `showAlert`: Function to display alert messages.
/// - `updateAudioSetting`, `updateVideoSetting`, `updateScreenshareSetting`, `updateChatSetting`: Functions to update individual settings.
/// - `updateIsSettingsModalVisible`: Function to update the visibility of the modal.
///
/// ### Example Usage:
/// ```dart
/// EventSettingsModal(
///   options: EventSettingsModalOptions(
///     isVisible: true,
///     onClose: () => print("Modal closed"),
///     audioSetting: 'allow',
///     videoSetting: 'approval',
///     screenshareSetting: 'disallow',
///     chatSetting: 'allow',
///     roomName: 'eventRoom',
///     socket: socket,
///     showAlert: (msg, type, duration) => print(msg),
///     updateAudioSetting: (val) => print("Audio setting: $val"),
///     updateVideoSetting: (val) => print("Video setting: $val"),
///     updateScreenshareSetting: (val) => print("Screenshare setting: $val"),
///     updateChatSetting: (val) => print("Chat setting: $val"),
///     updateIsSettingsModalVisible: (val) => print("Settings modal visible: $val"),
///   ),
/// );
/// ```

/// `EventSettingsModal` - A modal widget for configuring event-specific media settings.
///
/// This widget provides options to control participant permissions for audio, video, screenshare, and chat.
/// The settings are saved and applied using the `onModifySettings` callback, which updates the settings on the server.
///
/// ### Parameters:
/// - `options` (`EventSettingsModalOptions`): Configuration options for the modal.
///
/// ### Structure:
/// - Header with title ("Event Settings") and close icon.
/// - Dropdown selectors for each setting (audio, video, screenshare, and chat).
/// - Save button to confirm and apply the settings.
///
/// ### Example Usage:
/// ```dart
/// EventSettingsModal(
///   options: EventSettingsModalOptions(
///     isVisible: true,
///     onClose: () => print("Modal closed"),
///     audioSetting: 'allow',
///     videoSetting: 'approval',
///     screenshareSetting: 'disallow',
///     chatSetting: 'allow',
///     roomName: 'eventRoom',
///     socket: socket,
///   ),
/// );
/// ```

class EventSettingsModal extends StatefulWidget {
  final EventSettingsModalOptions options;

  const EventSettingsModal({super.key, required this.options});

  @override
  _EventSettingsModalState createState() => _EventSettingsModalState();
}

class _EventSettingsModalState extends State<EventSettingsModal> {
  late String _audioState;
  late String _videoState;
  late String _screenshareState;
  late String _chatState;

  @override
  void initState() {
    super.initState();
    _audioState = widget.options.audioSetting;
    _videoState = widget.options.videoSetting;
    _screenshareState = widget.options.screenshareSetting;
    _chatState = widget.options.chatSetting;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double modalWidth = screenWidth * 0.8 > 400 ? 400 : screenWidth * 0.8;
    final modalHeight = MediaQuery.of(context).size.height * 0.6;

    return Visibility(
      visible: widget.options.isVisible,
      child: Stack(
        children: [
          Positioned(
            top: getModalPosition(GetModalPositionOptions(
              position: widget.options.position,
              modalWidth: modalWidth,
              modalHeight: modalHeight,
              context: context,
            ))['top'],
            right: getModalPosition(GetModalPositionOptions(
                position: widget.options.position,
                modalWidth: modalWidth,
                modalHeight: modalHeight,
                context: context))['right'],
            child: AnimatedOpacity(
              opacity: widget.options.isVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                width: modalWidth,
                height: modalHeight,
                padding: const EdgeInsets.all(20.0),
                color: widget.options.backgroundColor,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Event Settings',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: widget.options.onClose,
                            color: Colors.black,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(
                        color: Colors.black,
                        height: 1,
                      ),
                      const SizedBox(height: 10),
                      _buildSettingDropdown(
                        'User audio:',
                        _audioState,
                        (value) => setState(() => _audioState = value),
                      ),
                      const SizedBox(height: 10),
                      _buildSettingDropdown(
                        'User video:',
                        _videoState,
                        (value) => setState(() => _videoState = value),
                      ),
                      const SizedBox(height: 10),
                      _buildSettingDropdown(
                        'User screenshare:',
                        _screenshareState,
                        (value) => setState(() => _screenshareState = value),
                      ),
                      const SizedBox(height: 10),
                      _buildSettingDropdown(
                        'User chat:',
                        _chatState,
                        (value) => setState(() => _chatState = value),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          final optionsModify = ModifySettingsOptions(
                            audioSet: _audioState,
                            videoSet: _videoState,
                            screenshareSet: _screenshareState,
                            chatSet: _chatState,
                            updateAudioSetting:
                                widget.options.updateAudioSetting,
                            updateVideoSetting:
                                widget.options.updateVideoSetting,
                            updateScreenshareSetting:
                                widget.options.updateScreenshareSetting,
                            updateChatSetting: widget.options.updateChatSetting,
                            updateIsSettingsModalVisible:
                                widget.options.updateIsSettingsModalVisible,
                            roomName: widget.options.roomName,
                            socket: widget.options.socket,
                            showAlert: widget.options.showAlert,
                          );
                          widget.options.onModifySettings(
                            optionsModify,
                          );
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingDropdown(
    String label,
    String value,
    void Function(String) onChanged,
  ) {
    List<DropdownMenuItem<String>> dropdownItems = [
      const DropdownMenuItem(
        value: 'disallow',
        child: Text('Disallow', style: TextStyle(fontSize: 14)),
      ),
      if (label != 'User chat:')
        const DropdownMenuItem(
          value: 'approval',
          child: Text('Approval', style: TextStyle(fontSize: 14)),
        ),
      const DropdownMenuItem(
        value: 'allow',
        child: Text('Allow', style: TextStyle(fontSize: 14)),
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            flex: 2, // Decrease flex here if needed
            child: DropdownButton<String>(
              value: value,
              onChanged: (String? newValue) {
                onChanged(newValue!);
              },
              items: dropdownItems,
            ),
          ),
        ],
      ),
    );
  }
}
