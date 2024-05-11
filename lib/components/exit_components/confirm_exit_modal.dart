import 'package:flutter/material.dart';
import '../../methods/exit_methods/confirm_exit.dart' show confirmExit;
import '../../methods/utils/get_modal_position.dart' show getModalPosition;
import 'package:socket_io_client/socket_io_client.dart' as io;

/// ConfirmExitModal - A modal widget for confirming exit actions.
///
/// This widget provides a confirmation dialog for exiting an event or ending it.
///
/// Whether the confirm exit modal is visible.
///final bool isConfirmExitModalVisible;
///
/// A callback function called when the confirm exit modal is closed.
///final Function onConfirmExitClose;
///
/// The parameters associated with the confirm exit modal.
///final Map<String, dynamic> parameters;
///
/// The position of the modal.
///final String position;
///
/// The background color of the modal.
///final Color backgroundColor;
///
/// The function to execute when the exit action is confirmed.
///final ConfirmExit exitEventOnConfirm;

typedef ConfirmExit = Future<void> Function({
  required io.Socket socket,
  required String member,
  required String roomName,
  bool ban,
});

class ConfirmExitModal extends StatelessWidget {
  final bool isConfirmExitModalVisible;
  final Function onConfirmExitClose;
  final Map<String, dynamic> parameters;
  final String position;
  final Color backgroundColor;
  final ConfirmExit exitEventOnConfirm;

  const ConfirmExitModal({
    super.key,
    required this.isConfirmExitModalVisible,
    required this.onConfirmExitClose,
    required this.parameters,
    this.position = 'topRight',
    this.backgroundColor = const Color(0xFF83C0E9),
    this.exitEventOnConfirm = confirmExit,
  });

  @override
  Widget build(BuildContext context) {
    final islevel = parameters['islevel'];

    final screenWidth = MediaQuery.of(context).size.width;
    var modalWidth = 0.7 * screenWidth;
    if (modalWidth > 400) {
      modalWidth = 400;
    }

    final modalHeight = MediaQuery.of(context).size.height * 0.5;

    return Visibility(
      visible: isConfirmExitModalVisible,
      child: Stack(
        children: [
          Positioned(
            top: getModalPosition(
                position, context, modalWidth, modalHeight)['top'],
            right: getModalPosition(
                position, context, modalWidth, modalHeight)['right'],
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  width: modalWidth,
                  padding: const EdgeInsets.all(20),
                  margin:
                      const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
                  decoration: BoxDecoration(
                    color: backgroundColor,
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
                            onPressed: onConfirmExitClose as void Function()?,
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
                            onPressed: onConfirmExitClose as void Function()?,
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.grey[700]!),
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
                            onPressed: () {
                              exitEventOnConfirm(
                                socket: parameters['socket'],
                                member: parameters['member'],
                                roomName: parameters['roomName'],
                                ban: false,
                              );
                              onConfirmExitClose();
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.red),
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
