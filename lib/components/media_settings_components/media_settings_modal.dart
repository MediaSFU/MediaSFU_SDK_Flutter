import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../methods/utils/get_modal_position.dart'
    show getModalPosition, GetModalPositionOptions;
import '../../methods/stream_methods/switch_video.dart'
    show
        switchVideo,
        SwitchVideoOptions,
        SwitchVideoParameters,
        SwitchVideoType;
import '../../methods/stream_methods/switch_audio.dart'
    show
        switchAudio,
        SwitchAudioOptions,
        SwitchAudioParameters,
        SwitchAudioType;
import '../../methods/stream_methods/switch_video_alt.dart'
    show
        switchVideoAlt,
        SwitchVideoAltOptions,
        SwitchVideoAltParameters,
        SwitchVideoAltType;

/// `MediaSettingsModalParameters` - Abstract class defining required parameters
/// for configuring media settings.
///
/// ### Abstract Getters:
/// - `userDefaultVideoInputDevice`: Default video input device ID.
/// - `userDefaultAudioInputDevice`: Default audio input device ID.
/// - `videoInputs`: List of available video input devices.
/// - `audioInputs`: List of available audio input devices.
/// - `isMediaSettingsModalVisible`: Boolean for media settings modal visibility.
/// - `updateIsMediaSettingsModalVisible`: Function to update visibility.
///
/// ### Example Usage:
/// ```dart
/// class CustomMediaSettingsModalParameters implements MediaSettingsModalParameters {
///   @override
///   String get userDefaultVideoInputDevice => 'default_video';
///   @override
///   String get userDefaultAudioInputDevice => 'default_audio';
///   // ... other implementations
/// }
/// ```
abstract class MediaSettingsModalParameters
    implements
        SwitchVideoParameters,
        SwitchAudioParameters,
        SwitchVideoAltParameters {
  String get userDefaultVideoInputDevice;
  String get userDefaultAudioInputDevice;
  List<MediaDeviceInfo> get videoInputs;
  List<MediaDeviceInfo> get audioInputs;
  bool get isMediaSettingsModalVisible;
  void Function(bool) get updateIsMediaSettingsModalVisible;

  MediaSettingsModalParameters Function() get getUpdatedAllParams;

  // dynamic operator [](String key);
}

/// MediaSettingsModalOptions - Defines configuration options for the `MediaSettingsModal`.
class MediaSettingsModalOptions {
  final bool isVisible;
  final VoidCallback onClose;
  final SwitchVideoAltType switchCameraOnPress;
  final SwitchVideoType switchVideoOnPress;
  final SwitchAudioType switchAudioOnPress;
  final MediaSettingsModalParameters parameters;
  final String position;
  final Color backgroundColor;

  MediaSettingsModalOptions({
    required this.isVisible,
    required this.onClose,
    this.switchCameraOnPress = switchVideoAlt,
    this.switchVideoOnPress = switchVideo,
    this.switchAudioOnPress = switchAudio,
    required this.parameters,
    this.position = 'topRight',
    this.backgroundColor = Colors.blue,
  });
}

typedef MediaSettingsModalType = MediaSettingsModal Function({
  required MediaSettingsModalOptions options,
});

/// `MediaSettingsModalOptions` - Configuration options for the `MediaSettingsModal`.
/// - `isVisible`: Boolean to control modal visibility.
/// - `onClose`: Callback function to handle modal close.
/// - `switchCameraOnPress`: Function to handle camera switch action.
/// - `switchVideoOnPress`: Function to handle video switch action.
/// - `switchAudioOnPress`: Function to handle audio switch action.
/// - `parameters`: Instance of `MediaSettingsModalParameters`.
/// - `position`: Modal position on the screen (e.g., 'topRight').
/// - `backgroundColor`: Background color of the modal.
///
/// ### Example Usage:
/// ```dart
/// MediaSettingsModal(
///   options: MediaSettingsModalOptions(
///     isVisible: true,
///     onClose: () => print("Modal closed"),
///     parameters: CustomMediaSettingsModalParameters(),
///     backgroundColor: Colors.blue,
///   ),
/// );
/// ```

/// `MediaSettingsModal` - A modal widget to configure media settings.
///
/// This widget provides dropdowns to select video and audio devices, and a button to switch the camera.
///
/// ### Parameters:
/// - `options` (MediaSettingsModalOptions): Configuration options for the modal.
///
/// ### Widget Structure:
/// - Header with a title and close icon.
/// - Dropdowns for selecting camera and microphone devices.
/// - Button to switch the camera.
///
/// ### Customization:
/// - Use the `MediaSettingsModalOptions` to control appearance and behavior.
/// - Options include custom background color, modal position, and device selection handlers.
///
/// ### Example Usage:
/// ```dart
/// MediaSettingsModal(
///   options: MediaSettingsModalOptions(
///     isVisible: true,
///     onClose: () => print("Modal closed"),
///     parameters: CustomMediaSettingsModalParameters(),
///   ),
/// );
/// ```
///
class MediaSettingsModal extends StatelessWidget {
  final MediaSettingsModalOptions options;

  const MediaSettingsModal({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double modalWidth = screenWidth * 0.8 > 400 ? 400 : screenWidth * 0.8;
    final double modalHeight = MediaQuery.of(context).size.height * 0.65;

    final MediaSettingsModalParameters parameters =
        options.parameters.getUpdatedAllParams();

    final List<MediaDeviceInfo> videoInputs = parameters.videoInputs;
    final List<MediaDeviceInfo> audioInputs = parameters.audioInputs;
    String? selectedVideoInput = parameters.userDefaultVideoInputDevice;
    String? selectedAudioInput = parameters.userDefaultAudioInputDevice;

    if ((selectedVideoInput.isEmpty) && videoInputs.isNotEmpty) {
      selectedVideoInput = videoInputs[0].deviceId;
    } else {
      // if selectedVideoInput is not in the list of videoInputs, set it to the first videoInput
      if (!videoInputs
          .any((element) => element.deviceId == selectedVideoInput)) {
        selectedVideoInput = videoInputs.isNotEmpty
            ? videoInputs[0].deviceId
            : 'No Video Devices';
      }
    }

    if ((selectedAudioInput.isEmpty) && audioInputs.isNotEmpty) {
      selectedAudioInput = audioInputs[0].deviceId;
    } else {
      // if selectedAudioInput is not in the list of audioInputs, set it to the first audioInput
      if (!audioInputs
          .any((element) => element.deviceId == selectedAudioInput)) {
        selectedAudioInput = audioInputs.isNotEmpty
            ? audioInputs[0].deviceId
            : 'No Audio Devices';
      }
    }

    void handleSwitchCamera() {
      final optionsSwitch = SwitchVideoAltOptions(
        parameters: parameters,
      );
      options.switchCameraOnPress(
        optionsSwitch,
      );
    }

    return Visibility(
      visible: options.isVisible,
      child: Stack(
        children: [
          Positioned(
            top: getModalPosition(GetModalPositionOptions(
              position: options.position,
              modalWidth: modalWidth,
              modalHeight: modalHeight,
              context: context,
            ))['top'],
            right: getModalPosition(GetModalPositionOptions(
              position: options.position,
              modalWidth: modalWidth,
              modalHeight: modalHeight,
              context: context,
            ))['right'],
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                padding: const EdgeInsets.all(10),
                color: options.backgroundColor,
                width: modalWidth,
                height: modalHeight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          onPressed: options.onClose,
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
                          scrollDirection: Axis.horizontal,
                          child: DropdownButton<String>(
                            value: selectedVideoInput,
                            onChanged: (String? newValue) async {
                              final optionsSwitch = SwitchVideoOptions(
                                videoPreference: newValue!,
                                parameters: parameters,
                              );
                              await options.switchVideoOnPress(
                                optionsSwitch,
                              );
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
                          scrollDirection: Axis.horizontal,
                          child: DropdownButton<String>(
                            value: selectedAudioInput,
                            onChanged: (String? newValue) {
                              final optionsSwitch = SwitchAudioOptions(
                                audioPreference: newValue!,
                                parameters: parameters,
                              );
                              options.switchAudioOnPress(
                                optionsSwitch,
                              );
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
                      onPressed: handleSwitchCamera,
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
