import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter/material.dart';
import '../../methods/utils/get_modal_position.dart'
    show getModalPosition, GetModalPositionOptions;

/// `ConfirmHereModalOptions` defines the configuration for `ConfirmHereModal`,
/// including visibility, callbacks, countdown, and socket settings.
///
/// - `isConfirmHereModalVisible`: Controls visibility.
/// - `onConfirmHereClose`: Callback to handle closing.
/// - `backgroundColor`: Modal background color.
/// - `countdownDuration`: Duration for countdown in seconds.
/// - `socket`: WebSocket connection.
/// - `localSocket`: Local WebSocket connection.
/// - `roomName`: Room name for session.
/// - `member`: Member ID for user.

class ConfirmHereModalOptions {
  final bool isConfirmHereModalVisible;
  final VoidCallback onConfirmHereClose;
  final io.Socket? socket;
  final io.Socket? localSocket;
  final String roomName;
  final String member;
  final Color backgroundColor;
  final Color displayColor;
  final int countdownDuration;

  ConfirmHereModalOptions({
    required this.isConfirmHereModalVisible,
    required this.onConfirmHereClose,
    this.socket,
    this.localSocket,
    required this.roomName,
    required this.member,
    this.backgroundColor = const Color(0xFF83c0e9),
    this.displayColor = Colors.black,
    this.countdownDuration = 120,
  });
}

typedef ConfirmHereModalType = Widget Function(
    {required ConfirmHereModalOptions options});

/// `ConfirmHereModal` prompts the user to confirm presence with a countdown timer and action button.
///
/// Example Usage:
/// ```dart
/// ConfirmHereModal(
///   options: ConfirmHereModalOptions(
///     isConfirmHereModalVisible: true,
///     onConfirmHereClose: () => print("Modal closed"),
///     socket: io.Socket(),
///     localSocket: io.Socket(),
///     roomName: "room1",
///     member: "user1",
///   ),
/// );
/// ```

class ConfirmHereModal extends StatefulWidget {
  final ConfirmHereModalOptions options;

  const ConfirmHereModal({super.key, required this.options});

  @override
  _ConfirmHereModalState createState() => _ConfirmHereModalState();
}

class _ConfirmHereModalState extends State<ConfirmHereModal> {
  late Timer countdownTimer;
  late int counter;

  @override
  void initState() {
    super.initState();
    counter = widget.options.countdownDuration;
    if (widget.options.isConfirmHereModalVisible) {
      startCountdown();
    }
  }

  @override
  void didUpdateWidget(covariant ConfirmHereModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.options.isConfirmHereModalVisible !=
        oldWidget.options.isConfirmHereModalVisible) {
      if (widget.options.isConfirmHereModalVisible) {
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
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        counter--;
      });
      if (counter <= 0) {
        stopCountdown();
        widget.options.onConfirmHereClose();
        widget.options.socket?.emit('disconnectUser', {
          'member': widget.options.member,
          'roomName': widget.options.roomName,
          'ban': false
        });

        try {
          if (widget.options.localSocket != null &&
              widget.options.localSocket!.id != null) {
            widget.options.localSocket?.emit('disconnectUser', {
              'member': widget.options.member,
              'roomName': widget.options.roomName,
              'ban': false
            });
          }
        } catch (e) {
          // Handle silently
        }
      }
    });
  }

  void stopCountdown() {
    counter = widget.options.countdownDuration;
    countdownTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double modalWidth = 0.8 * screenWidth > 400 ? 400 : 0.8 * screenWidth;
    final modalHeight = MediaQuery.of(context).size.height * 0.65;

    return Visibility(
      visible: widget.options.isConfirmHereModalVisible,
      child: Stack(
        children: [
          Positioned(
            top: getModalPosition(GetModalPositionOptions(
              position: 'center',
              modalWidth: modalWidth,
              modalHeight: modalHeight,
              context: context,
            ))['top'],
            right: getModalPosition(GetModalPositionOptions(
                position: 'center',
                modalWidth: modalWidth,
                modalHeight: modalHeight,
                context: context))['right'],
            child: Container(
              decoration: BoxDecoration(
                color: widget.options.backgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              width: modalWidth,
              height: modalHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        widget.options.displayColor),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Are you still there?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: widget.options.displayColor,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Please confirm if you are still present.',
                    style: TextStyle(
                      fontSize: 16,
                      color: widget.options.displayColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Time remaining: $counter',
                    style: TextStyle(
                      fontSize: 14,
                      color: widget.options.displayColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      stopCountdown();
                      widget.options.onConfirmHereClose();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
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
