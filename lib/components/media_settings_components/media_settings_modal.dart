import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../methods/utils/get_modal_position.dart' show getModalPosition;
import '../../methods/stream_methods/switch_video.dart' show switchVideo;
import '../../methods/stream_methods/switch_audio.dart' show switchAudio;
import '../../methods/stream_methods/switch_video_alt.dart' show switchVideoAlt;

/// MediaSettingsModal - A modal widget for adjusting media settings.
///
/// This widget provides options to select cameras and microphones, and switch between them.
///
/// Whether the media settings modal is visible.
/// final bool isMediaSettingsModalVisible;
///
/// A callback function called when the media settings modal is closed.
/// final Function() onMediaSettingsClose;
///
/// The function to switch cameras when the switch camera button is pressed.
/// final SwitchVideoAlt switchCameraOnPress;
///
/// The function to switch video preferences.
/// final Future<void> Function({required String videoPreference, required Map<String, dynamic> parameters}) switchVideoOnPress;
///
/// The function to switch audio preferences.
/// final void Function({required String audioPreference, required Map<String, dynamic> parameters}) switchAudioOnPress;
///
/// The parameters associated with the media settings modal.
/// final Map<String, dynamic> parameters;
///
/// The position of the modal.
/// final String position;
///
/// The background color of the modal.
/// final Color backgroundColor;

typedef SwitchVideoAlt = Future<void> Function({
  required Map<String, dynamic> parameters,
});

typedef GetUpdatedAllParams = Map<String, dynamic> Function();

class MediaSettingsModal extends StatelessWidget {
  final bool isMediaSettingsModalVisible;
  final Function() onMediaSettingsClose;
  final SwitchVideoAlt switchCameraOnPress; // Adjusted type
  final Future<void> Function(
          {required String videoPreference,
          required Map<String, dynamic> parameters})
      switchVideoOnPress; // Adjusted type
  final void Function(
      {required String audioPreference,
      required Map<String, dynamic> parameters}) switchAudioOnPress;
  final Map<String, dynamic> parameters;
  final String position;
  final Color backgroundColor;

  const MediaSettingsModal({
    super.key,
    required this.isMediaSettingsModalVisible,
    required this.onMediaSettingsClose,
    this.switchCameraOnPress = switchVideoAlt,
    this.switchVideoOnPress = switchVideo,
    this.switchAudioOnPress = switchAudio,
    required this.parameters,
    this.position = 'topRight',
    this.backgroundColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    var modalWidth = 0.80 * screenWidth;
    if (modalWidth > 400) {
      modalWidth = 400;
    }
    final modalHeight = MediaQuery.of(context).size.height * 0.65;

    GetUpdatedAllParams getUpdatedAllParams = parameters['getUpdatedAllParams'];

    final List<MediaDeviceInfo> videoInputs =
        getUpdatedAllParams()['videoInputs'];
    final List<MediaDeviceInfo> audioInputs =
        getUpdatedAllParams()['audioInputs'];
    String? selectedVideoInput =
        getUpdatedAllParams()['userDefaultVideoInputDevice'];
    String? selectedAudioInput =
        getUpdatedAllParams()['userDefaultAudioInputDevice'];

    if ((selectedVideoInput == null || selectedVideoInput.isEmpty) &&
        videoInputs.isNotEmpty) {
      selectedVideoInput = videoInputs[0].deviceId;
    }
    if ((selectedAudioInput == null || selectedAudioInput.isEmpty) &&
        audioInputs.isNotEmpty) {
      selectedAudioInput = audioInputs[0].deviceId;
    }

    handleSwitchCamera() {
      // Handle switching camera logic
      switchCameraOnPress(parameters: parameters);
    }

    return Visibility(
      visible: isMediaSettingsModalVisible,
      child: Stack(
        children: [
          Positioned(
            top: getModalPosition(
                position, context, modalWidth, modalHeight)['top'],
            right: getModalPosition(
                position, context, modalWidth, modalHeight)['right'],
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                padding: const EdgeInsets.all(10),
                color: backgroundColor,
                width: modalWidth, // Adjust the width as needed
                height: modalHeight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Text(
                          'Media Settings',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => onMediaSettingsClose(),
                        ),
                      ],
                    ),
                    const Divider(
                        height: 10, thickness: 1, color: Colors.black),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Camera:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SingleChildScrollView(
                          // Wrap DropdownButton with SingleChildScrollView
                          scrollDirection: Axis.horizontal,
                          child: DropdownButton<String>(
                            value: selectedVideoInput,
                            onChanged: (String? newValue) async {
                              await switchVideoOnPress(
                                videoPreference: newValue!,
                                parameters: parameters,
                              );
                              selectedVideoInput = newValue;
                            },
                            items: videoInputs
                                .map<DropdownMenuItem<String>>((input) {
                              return DropdownMenuItem<String>(
                                value: input.deviceId,
                                child: Text(input.label),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Microphone:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SingleChildScrollView(
                          // Wrap DropdownButton with SingleChildScrollView
                          scrollDirection: Axis.horizontal,
                          child: DropdownButton<String>(
                            value: selectedAudioInput,
                            onChanged: (String? newValue) {
                              switchAudioOnPress(
                                audioPreference: newValue!,
                                parameters: parameters,
                              );
                              selectedAudioInput = newValue;
                            },
                            items: audioInputs
                                .map<DropdownMenuItem<String>>((input) {
                              return DropdownMenuItem<String>(
                                value: input.deviceId,
                                child: Text(input.label),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => handleSwitchCamera(),
                      child: const Text('Switch Camera'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
