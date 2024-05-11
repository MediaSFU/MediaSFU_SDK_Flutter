import 'package:flutter/material.dart';
import '../../methods/utils/get_modal_position.dart' show getModalPosition;
import '../../methods/settings_methods/modify_settings.dart'
    show modifySettings;

/// EventSettingsModal - A modal widget for configuring event settings.
///
/// This widget allows users to modify event settings such as audio, video, screenshare, and chat settings.
///
/// Whether the event settings modal is visible.
///final bool isEventSettingsModalVisible;
///
/// A callback function called when the event settings modal is closed.
///final EventSettingsCloseCallback onEventSettingsClose;
///
/// A function for modifying event settings.
///final ModifySettings onModifyEventSettings;
///
/// The parameters associated with the event settings.
///final Map<String, dynamic> parameters;
///
/// The position of the modal.
///final String position;
///
/// The background color of the modal.
///final Color backgroundColor;

typedef ModifySettings = void Function({
  required Map<String, dynamic> parameters,
});

typedef EventSettingsCloseCallback = void Function();

class EventSettingsModal extends StatefulWidget {
  final bool isEventSettingsModalVisible;
  final EventSettingsCloseCallback onEventSettingsClose;
  final ModifySettings onModifyEventSettings;
  final Map<String, dynamic> parameters;
  final String position;
  final Color backgroundColor;

  const EventSettingsModal({
    super.key,
    required this.isEventSettingsModalVisible,
    required this.onEventSettingsClose,
    this.onModifyEventSettings = modifySettings,
    required this.parameters,
    this.position = 'topRight',
    this.backgroundColor = const Color(0xFF83C0E9),
  });

  @override
  // ignore: library_private_types_in_public_api
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
    _audioState = widget.parameters['audioSetting'];
    _videoState = widget.parameters['videoSetting'];
    _screenshareState = widget.parameters['screenshareSetting'];
    _chatState = widget.parameters['chatSetting'];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    var modalWidth = 0.8 * screenWidth;
    if (modalWidth > 400) {
      modalWidth = 400;
    }
    final modalHeight = MediaQuery.of(context).size.height * 0.6;

    return Visibility(
      visible: widget.isEventSettingsModalVisible,
      child: Stack(
        children: [
          Positioned(
            top: getModalPosition(
                widget.position, context, modalWidth, modalHeight)['top'],
            right: getModalPosition(
                widget.position, context, modalWidth, modalHeight)['right'],
            child: AnimatedOpacity(
              opacity: widget.isEventSettingsModalVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                width: modalWidth,
                height: modalHeight,
                padding: const EdgeInsets.all(20.0),
                color: widget.backgroundColor,
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
                            onPressed: widget.onEventSettingsClose,
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
                          widget.onModifyEventSettings(
                            parameters: {
                              ...widget.parameters,
                              'audioSet': _audioState,
                              'videoSet': _videoState,
                              'screenshareSet': _screenshareState,
                              'chatSet': _chatState,
                            },
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

  Widget _buildSettingDropdown(String label, String value, Function onChanged) {
    List<DropdownMenuItem<String>> dropdownItems = [
      const DropdownMenuItem(
        value: 'disallow',
        child: Text('Disallow', style: TextStyle(fontSize: 14)),
      ),
      //if not chat add approval
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
            flex: 1,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: DropdownButton<String>(
              value: value,
              onChanged: (String? newValue) {
                onChanged(newValue);
              },
              items: dropdownItems,
            ),
          ),
        ],
      ),
    );
  }
}
