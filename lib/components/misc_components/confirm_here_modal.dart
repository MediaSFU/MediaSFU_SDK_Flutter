import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter/material.dart';
import '../../methods/utils/get_modal_position.dart' show getModalPosition;

/// A modal widget that displays a confirmation message and countdown timer.
///
/// This widget is used to prompt the user to confirm their presence within a certain time limit.
/// It displays a circular progress indicator, a message asking the user if they are still there,
/// and a countdown timer showing the remaining time.
///
/// The modal can be customized with different background and display colors, and can be positioned
/// at the center or at a specific position on the screen.
///
/// To use this widget, provide the following parameters:
/// - [isConfirmHereModalVisible]: A boolean value indicating whether the modal is visible or not.
/// - [onConfirmHereClose]: A callback function that will be called when the modal is closed.
/// - [parameters]: A map of additional parameters that can be used by the widget.
/// - [position]: The position of the modal on the screen. Defaults to 'center'.
/// - [backgroundColor]: The background color of the modal. Defaults to Color(0xFF83c0e9).
/// - [displayColor]: The color of the text and progress indicator. Defaults to Colors.black.

class ConfirmHereModal extends StatefulWidget {
  final bool isConfirmHereModalVisible;
  final Function() onConfirmHereClose;
  final Map<String, dynamic> parameters;
  final String position;
  final Color backgroundColor;
  final Color displayColor;

  const ConfirmHereModal({
    super.key,
    required this.isConfirmHereModalVisible,
    required this.onConfirmHereClose,
    required this.parameters,
    this.position = 'center',
    this.backgroundColor = const Color(0xFF83c0e9),
    this.displayColor = Colors.black,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ConfirmHereModalState createState() => _ConfirmHereModalState();
}

class _ConfirmHereModalState extends State<ConfirmHereModal> {
  late Timer countdownTimer;
  late int counter;

  @override
  void initState() {
    super.initState();
    counter = widget.parameters['countdownDuration'] ?? 120;
    if (widget.isConfirmHereModalVisible) {
      startCountdown();
    }
  }

  @override
  void didUpdateWidget(covariant ConfirmHereModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isConfirmHereModalVisible !=
        oldWidget.isConfirmHereModalVisible) {
      if (widget.isConfirmHereModalVisible) {
        startCountdown();
      } else {
        stopCountdown();
      }
    }
  }

  @override
  void dispose() {
    stopCountdown();
    super.dispose();
  }

  void startCountdown() {
    final Map<String, dynamic> parameters = widget.parameters;
    final io.Socket socket = parameters['socket'] as io.Socket;
    final roomName = parameters['roomName'];
    final member = parameters['member'];

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        counter--;
      });
      if (counter <= 0) {
        stopCountdown();
        widget.onConfirmHereClose();
        // Emit the event to disconnect the user
        socket.emit('disconnectUser',
            {'member': member, 'roomName': roomName, 'ban': false});
      }
    });
  }

  void stopCountdown() {
    counter = widget.parameters['countdownDuration'] ?? 120;
    countdownTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    var modalWidth = 0.8 * screenWidth;
    if (modalWidth > 400) {
      modalWidth = 400;
    }

    final modalHeight = MediaQuery.of(context).size.height * 0.65;

    return Visibility(
      visible: widget.isConfirmHereModalVisible,
      child: Stack(
        children: [
          Positioned(
            top: getModalPosition(
                widget.position, context, modalWidth, modalHeight)['top'],
            right: getModalPosition(
                widget.position, context, modalWidth, modalHeight)['right'],
            child: Container(
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              width: modalWidth,
              height: modalHeight,
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center vertically
                children: [
                  CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(widget.displayColor),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Are you still there?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: widget.displayColor,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Please confirm if you are still present.',
                    style: TextStyle(
                      fontSize: 16,
                      color: widget.displayColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Time remaining: $counter',
                    style: TextStyle(
                      fontSize: 14,
                      color: widget.displayColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      stopCountdown();
                      widget
                          .onConfirmHereClose(); // Close the modal after confirming
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.red),
                      padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      shape: MaterialStateProperty.all<OutlinedBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    child: const Text(
                      'Yes',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
