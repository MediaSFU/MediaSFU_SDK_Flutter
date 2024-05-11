import 'package:flutter/material.dart';
import 'standard_panel_component.dart' show StandardPanelComponent;
import 'advanced_panel_component.dart' show AdvancedPanelComponent;
import '../../methods/utils/get_modal_position.dart' show getModalPosition;

/// RecordingModal is a StatelessWidget that represents a modal for recording settings.
///
/// `isRecordingModalVisible`: A boolean indicating whether the recording modal is visible.
///
/// `onClose`: A callback function invoked when closing the recording modal.
///
/// `backgroundColor`: The background color of the modal.
///
/// `position`: The position of the modal ('bottomRight' by default).
///
/// `confirmRecording`: A function to confirm recording settings.
///
/// `startRecording`: A function to start recording.
///
/// `parameters`: Additional parameters for recording settings.

class RecordingModal extends StatelessWidget {
  final bool isRecordingModalVisible;
  final Function onClose;
  final Color backgroundColor;
  final String position;
  final void Function({required Map<String, dynamic> parameters})
      confirmRecording;
  final Future<void> Function({required Map<String, dynamic> parameters})
      startRecording;
  final Map<String, dynamic> parameters;

  const RecordingModal({
    super.key,
    required this.isRecordingModalVisible,
    required this.onClose,
    this.backgroundColor = const Color(0xFF83C0E9),
    this.position = 'bottomRight',
    required this.confirmRecording,
    required this.startRecording,
    required this.parameters,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    double modalWidth = 0.75 * screenWidth;

    if (modalWidth > 400) {
      modalWidth = 400;
    }

    final modalHeight = MediaQuery.of(context).size.height * 0.75;

    return Visibility(
      visible: isRecordingModalVisible,
      child: Stack(
        children: [
          Positioned(
            top: getModalPosition(
                position, context, modalWidth, modalHeight)['top'],
            right: getModalPosition(
                position, context, modalWidth, modalHeight)['right'],
            child: GestureDetector(
              onTap: () {
                // if (isRecordingModalVisible) {
                //   onClose();
                // }
              },
              child: Container(
                width: modalWidth,
                height: modalHeight,
                decoration: BoxDecoration(
                  color: backgroundColor, // Change the color of the modal here
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
                          onTap: () {
                            if (isRecordingModalVisible) {
                              onClose();
                            }
                          },
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
                            StandardPanelComponent(parameters: parameters),
                            AdvancedPanelComponent(parameters: parameters),
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
                            confirmRecording(parameters: parameters);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            backgroundColor: const Color.fromARGB(255, 238, 25,
                                25), // Set background color to black
                          ),
                          child: const Text(
                            'Confirm',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (!parameters['recordPaused'])
                          ElevatedButton(
                            onPressed: () {
                              startRecording(parameters: parameters);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              backgroundColor: const Color.fromARGB(255, 60,
                                  203, 16), // Set background color to black
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
                                  color: Color.fromARGB(255, 239, 238, 238),
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
          ),
        ],
      ),
    );
  }
}
