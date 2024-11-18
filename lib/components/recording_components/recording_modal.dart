import 'package:flutter/material.dart';
import 'standard_panel_component.dart'
    show
        StandardPanelComponent,
        StandardPanelComponentOptions,
        StandardPanelComponentParameters;
import 'advanced_panel_component.dart'
    show
        AdvancedPanelComponent,
        AdvancedPanelComponentOptions,
        AdvancedPanelComponentParameters;
import '../../methods/utils/get_modal_position.dart'
    show getModalPosition, GetModalPositionOptions;
import '../../types/types.dart'
    show
        ConfirmRecordingType,
        StartRecordingType,
        StartRecordingOptions,
        ConfirmRecordingOptions,
        ConfirmRecordingParameters,
        StartRecordingParameters,
        EventType;

/// Abstract class `RecordingModalParameters` defines recording configuration parameters
/// and provides abstract getters for settings like video type, display type, background color,
/// and additional properties for recording customization.
///
/// The class also provides update functions for each setting, enabling real-time updates
/// and customization of recording behavior within the modal.
abstract class RecordingModalParameters
    implements
        ConfirmRecordingParameters,
        StartRecordingParameters,
        StandardPanelComponentParameters,
        AdvancedPanelComponentParameters {
  bool get recordPaused;
  String get recordingVideoType;
  String get recordingDisplayType;
  String get recordingBackgroundColor;
  String get recordingNameTagsColor;
  String get recordingOrientationVideo;
  bool get recordingNameTags;
  bool get recordingAddText;
  String get recordingCustomText;
  String get recordingCustomTextPosition;
  String get recordingCustomTextColor;
  String get recordingMediaOptions;
  String get recordingAudioOptions;
  String get recordingVideoOptions;
  bool get recordingAddHLS;
  EventType get eventType;

  // Update functions as abstract getters returning functions
  void Function(String) get updateRecordingVideoType;
  void Function(String) get updateRecordingDisplayType;
  void Function(String) get updateRecordingBackgroundColor;
  void Function(String) get updateRecordingNameTagsColor;
  void Function(String) get updateRecordingOrientationVideo;
  void Function(bool) get updateRecordingNameTags;
  void Function(bool) get updateRecordingAddText;
  void Function(String) get updateRecordingCustomText;
  void Function(String) get updateRecordingCustomTextPosition;
  void Function(String) get updateRecordingCustomTextColor;
  void Function(String) get updateRecordingMediaOptions;
  void Function(String) get updateRecordingAudioOptions;
  void Function(String) get updateRecordingVideoOptions;
  void Function(bool) get updateRecordingAddHLS;

  // Method to retrieve updated parameters as an abstract getter
  RecordingModalParameters Function() get getUpdatedAllParams;

  // dynamic operator [](String key);
}

/// Configuration options for displaying and managing the `RecordingModal`.
/// The options include visibility, position, background color, and functions for
/// confirming and starting recordings.
/// The options also include parameters for recording customization and settings.
/// The `RecordingModal` widget uses these options to display the modal and manage
/// recording actions and settings.
///
/// ### Parameters:
/// - `isRecordingModalVisible`: Visibility of the recording modal.
/// - `onClose`: Callback function to close the recording modal.
/// - `backgroundColor`: Background color of the recording modal.
/// - `position`: Position of the recording modal on the screen.
/// - `confirmRecording`: Function to confirm recording settings.
///
///  ```dart
/// void confirmRecordingFunction(ConfirmRecordingOptions options) {
///  // Confirm recording settings
/// }
/// ```
/// - `startRecording`: Function to start recording.
///
/// ```dart
/// void startRecordingFunction(StartRecordingOptions options) {
/// // Start recording
/// }
/// ```
/// - `parameters`: Recording modal parameters for customization.
///
/// ### Example:
/// ```dart
/// RecordingModalOptions(
///  isRecordingModalVisible: true,
/// onClose: () => print('Modal closed'),
/// confirmRecording: confirmRecordingFunction,
/// startRecording: startRecordingFunction,
/// parameters: recordingParameters,
/// );
/// ```
///
class RecordingModalOptions {
  final bool isRecordingModalVisible;
  final VoidCallback onClose;
  final Color backgroundColor;
  final String position;
  final ConfirmRecordingType confirmRecording;
  final StartRecordingType startRecording;
  final RecordingModalParameters parameters;

  RecordingModalOptions({
    required this.isRecordingModalVisible,
    required this.onClose,
    this.backgroundColor = const Color(0xFF83C0E9),
    this.position = 'bottomRight',
    required this.confirmRecording,
    required this.startRecording,
    required this.parameters,
  });
}

typedef RecordingModalType = Widget Function(
    {required RecordingModalOptions options});

/// `RecordingModal` widget is used to display recording options, enabling users to confirm,
/// customize, and start recordings with interactive controls and settings panels.
///
/// ### Parameters:
/// - `options`: `RecordingModalOptions` containing configuration for visibility, position,
///   background color, and recording functions.
///
/// ### Example Usage:
/// ```dart
/// RecordingModal(
///   options: RecordingModalOptions(
///     isRecordingModalVisible: true,
///     onClose: () => print('Modal closed'),
///     confirmRecording: confirmRecordingFunction,
///     startRecording: startRecordingFunction,
///     parameters: recordingParameters,
///   ),
/// );
/// ```
///
/// ### Widget Structure
/// - **StandardPanelComponent**: Displays standard recording settings.
/// - **AdvancedPanelComponent**: Displays advanced recording settings.
///
/// Both components are customizable based on parameters defined in
/// `RecordingModalParameters`.
class RecordingModal extends StatelessWidget {
  final RecordingModalOptions options;

  const RecordingModal({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double modalWidth = 0.75 * screenWidth;
    if (modalWidth > 400) modalWidth = 400;

    final modalHeight = MediaQuery.of(context).size.height * 0.75;

    return Visibility(
      visible: options.isRecordingModalVisible,
      child: Stack(
        children: [
          Positioned(
            top: getModalPosition(GetModalPositionOptions(
                position: options.position,
                modalWidth: modalWidth,
                modalHeight: modalHeight,
                context: context))['top'],
            right: getModalPosition(GetModalPositionOptions(
                position: options.position,
                modalWidth: modalWidth,
                modalHeight: modalHeight,
                context: context))['right'],
            child: Container(
              width: modalWidth,
              height: modalHeight,
              decoration: BoxDecoration(
                color: options.backgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recording Settings',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: options.onClose,
                        child: const Icon(
                          Icons.close,
                          size: 20,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Divider(
                    height: 1,
                    color: Colors.black,
                    thickness: 1,
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StandardPanelComponent(
                              options: StandardPanelComponentOptions(
                                  parameters: options.parameters)),
                          AdvancedPanelComponent(
                              options: AdvancedPanelComponentOptions(
                                  parameters: options.parameters)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          options.confirmRecording(ConfirmRecordingOptions(
                              parameters: options.parameters));
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          backgroundColor: Colors.red, // Confirm button color
                        ),
                        child: const Text(
                          'Confirm',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (!options.parameters.recordPaused)
                        ElevatedButton(
                          onPressed: () {
                            options.startRecording(StartRecordingOptions(
                                parameters: options.parameters));
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            backgroundColor: Colors.green, // Start button color
                          ),
                          child: const Row(
                            children: [
                              Text(
                                'Start ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
