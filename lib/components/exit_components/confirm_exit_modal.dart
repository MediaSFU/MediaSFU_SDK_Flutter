import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../methods/exit_methods/confirm_exit.dart'
    show confirmExit, ConfirmExitType, ConfirmExitOptions;
import '../../methods/utils/get_modal_position.dart'
    show getModalPosition, GetModalPositionOptions;

/// Configuration for the exit-confirmation modal enabling session termination or participant departure.
///
/// * **exitEventOnConfirm** - Override for `confirmExit`; receives {socket, member, ban, roomName}. Emits `disconnectUser` socket event (participant) or `endMeeting` (host).
/// * **member** - Current user's name; sent in socket event.
/// * **ban** - Boolean flag; if `true`, socket event includes `ban: true` to prevent rejoin.
/// * **roomName** - Session identifier for socket event.
/// * **socket** - Socket.IO client for emitting exit command.
/// * **islevel** - Privilege level; `'2'` = host (ending event for all), others = leaving session only.
/// * **position** - Modal placement via `getModalPosition` (e.g., 'topRight').
/// * **backgroundColor** - Background color for modal container.
///
/// ### Usage
/// 1. Modal displays warning text based on `islevel`: "Are you sure you want to exit the event?" (participant) or "Are you sure you want to end this event? (This will end it for all participants)" (host, `islevel == '2'`).
/// 2. "Confirm" button calls `exitEventOnConfirm`, which emits `disconnectUser` (participant) or `endMeeting` (host) socket event with `{member, ban, roomName}`.
/// 3. "Cancel" button closes modal via `onClose`.
/// 4. Override via `MediasfuUICustomOverrides.confirmExitModal` to inject custom exit workflows, analytics tracking, or feedback prompts.
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

/// Exit-confirmation modal prompting user to leave session or end event (host-only).
///
/// * Displays warning text based on `islevel`: "Are you sure you want to exit the
///   event?" (participant) or "Are you sure you want to end this event? (This will
///   end it for all participants)" (host, `islevel == '2'`).
/// * "Confirm" button invokes `exitEventOnConfirm` (defaults to `confirmExit`),
///   which emits `disconnectUser` socket event (participant) or `endMeeting` event
///   (host); event payload includes `{member, ban, roomName}`.
/// * "Cancel" button closes modal via `onClose`.
/// * Positions via `getModalPosition` using `options.position`.
///
/// Override via `MediasfuUICustomOverrides.confirmExitModal` to inject custom exit
/// workflows, analytics tracking, or feedback prompts before departure.
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
