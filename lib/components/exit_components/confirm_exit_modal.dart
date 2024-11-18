import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../methods/exit_methods/confirm_exit.dart'
    show confirmExit, ConfirmExitType, ConfirmExitOptions;
import '../../methods/utils/get_modal_position.dart'
    show getModalPosition, GetModalPositionOptions;

/// ConfirmExitModalOptions - Defines configuration options for the `ConfirmExitModal`.
class ConfirmExitModalOptions {
  final bool isVisible;
  final VoidCallback onClose;
  final String position;
  final Color backgroundColor;
  final ConfirmExitType exitEventOnConfirm;
  final String member;
  final bool ban;
  final String roomName;
  final io.Socket? socket;
  final String islevel;

  ConfirmExitModalOptions({
    required this.isVisible,
    required this.onClose,
    this.position = 'topRight',
    this.backgroundColor = const Color(0xFF83C0E9),
    this.exitEventOnConfirm = confirmExit,
    required this.member,
    this.ban = false,
    required this.roomName,
    this.socket,
    required this.islevel,
  });
}

typedef ConfirmExitModalType = ConfirmExitModal Function({
  required ConfirmExitModalOptions options,
});

/// `ConfirmExitModalOptions` - Configuration options for `ConfirmExitModal`.
///
/// ### Properties:
/// - `isVisible`: Boolean indicating the modal's visibility.
/// - `onClose`: Callback to close the modal.
/// - `position`: Position of the modal on the screen (default is 'topRight').
/// - `backgroundColor`: Background color of the modal (default is `Color(0xFF83C0E9)`).
/// - `exitEventOnConfirm`: Function to execute on confirming the exit.
/// - `member`: Identifier for the exiting user.
/// - `ban`: Boolean indicating if the user should be banned on exit.
/// - `roomName`: Name of the room or event.
/// - `socket`: Socket connection for sending exit commands.
/// - `islevel`: User’s permission level, where '2' indicates admin rights.
///
/// ### Example Usage:
/// ```dart
/// ConfirmExitModal(
///   options: ConfirmExitModalOptions(
///     isVisible: true,
///     onClose: () => print("Modal closed"),
///     islevel: '1',
///     member: 'user123',
///     roomName: 'eventRoom',
///     socket: socket,
///     islevel: '2',
///   ),
/// );
/// ```

/// `ConfirmExitModal` - A modal widget that displays an exit confirmation dialog.
///
/// This widget is useful for confirming an exit action, such as ending an event
/// or allowing a user to leave. For users with an admin role (indicated by `islevel` '2'),
/// a warning appears, noting that the action will end the event for all participants.
///
/// ### Parameters:
/// - `options` (`ConfirmExitModalOptions`): Configuration options for the modal.
///
/// ### Structure:
/// - Header with title ("Confirm Exit") and close icon.
/// - Message indicating the impact of the exit, based on user level (`islevel`).
/// - Buttons for "Cancel" and "Confirm":
///   - The "Confirm" button ends the event if `islevel` is '2' or allows the user to exit otherwise.
///
/// ### Example Usage:
/// ```dart
/// ConfirmExitModal(
///   options: ConfirmExitModalOptions(
///     isVisible: true,
///     onClose: () => print("Modal closed"),
///     member: 'user123',
///     roomName: 'eventRoom',
///     socket: socket,
///     islevel: '2',
///   ),
/// );
/// ```

class ConfirmExitModal extends StatelessWidget {
  final ConfirmExitModalOptions options;

  const ConfirmExitModal({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    final islevel = options.islevel;
    final screenWidth = MediaQuery.of(context).size.width;
    final double modalWidth = screenWidth * 0.7 > 400 ? 400 : screenWidth * 0.7;
    final double modalHeight = MediaQuery.of(context).size.height * 0.5;

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
                context: context))['right'],
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  width: modalWidth,
                  padding: const EdgeInsets.all(20),
                  margin:
                      const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
                  decoration: BoxDecoration(
                    color: options.backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Confirm Exit',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          IconButton(
                            onPressed: options.onClose,
                            icon: const Icon(Icons.close),
                            color: Colors.black,
                          ),
                        ],
                      ),
                      const Divider(
                        color: Colors.black,
                        thickness: 1,
                        height: 20,
                      ),
                      Text(
                        islevel == '2'
                            ? 'This will end the event for all. Confirm exit.'
                            : 'Are you sure you want to exit?',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: options.onClose,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[700],
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const VerticalDivider(
                            color: Colors.black,
                            thickness: 1,
                            width: 10,
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              final optionsExit = ConfirmExitOptions(
                                member: options.member,
                                ban: options.ban,
                                socket: options.socket,
                                roomName: options.roomName,
                              );
                              await options.exitEventOnConfirm(
                                optionsExit,
                              );
                              options.onClose();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: Text(
                              islevel == '2' ? 'End Event' : 'Exit',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
