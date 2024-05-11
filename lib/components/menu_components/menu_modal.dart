import 'package:flutter/material.dart';
import './meeting_id_component.dart' show MeetingIdComponent;
import './meeting_passcode_component.dart' show MeetingPasscodeComponent;
import './share_buttons_component.dart' show ShareButtonsComponent;
import './custom_buttons.dart' show CustomButtons;
import '../../methods/utils/get_modal_position.dart' show getModalPosition;

/// MenuModal - A modal component for displaying a menu with various options.
///
/// This modal displays a menu with options like custom buttons, meeting ID, passcode,
/// and share buttons. It can be customized with different colors, visibility, and position.
///
/// The background color of the modal.
/// final Color backgroundColor;
///
/// Whether the modal is currently visible.
/// final bool isVisible;
///
/// A function to update the visibility state of the menu modal.
/// final Function(bool) updateIsMenuModalVisible;
///
/// A function to be executed when the modal is closed.
/// final Function onClose;
///
/// A list of custom buttons to be displayed in the menu.
/// final List<Map<String, dynamic>> customButtons;
///
/// A function to be executed when the "Copy Meeting ID" button is pressed.
/// final Function()? onCopyMeetingId;
///
/// A function to be executed when the "Copy Meeting Passcode" button is pressed.
/// final Function()? onCopyMeetingPasscode;
///
/// A function to be executed when the "Copy Share Link" button is pressed.
/// final Function()? onCopyShareLink;
///
/// A boolean indicating whether the share buttons should be displayed.
/// final bool shareButtons;
///
/// The position of the modal, e.g., 'bottomRight'.
/// final String position;
///
/// The room name of the meeting.
/// final String roomName;
///
/// The admin passcode of the meeting.
/// final String adminPasscode;
///
/// The level of access for the user, e.g., '2' for host.
/// final String islevel;

class MenuModal extends StatelessWidget {
  final Color backgroundColor;
  final bool isVisible;
  final Function(bool) updateIsMenuModalVisible;
  final Function onClose;
  final List<Map<String, dynamic>> customButtons;
  final Function()? onCopyMeetingId;
  final Function()? onCopyMeetingPasscode;
  final Function()? onCopyShareLink;
  final bool shareButtons;
  final String position;
  final String roomName;
  final String adminPasscode;
  final String islevel;

  const MenuModal({
    super.key,
    this.backgroundColor = const Color(0xFF83C0E9),
    required this.isVisible,
    required this.onClose,
    required this.updateIsMenuModalVisible,
    required this.customButtons,
    this.onCopyMeetingId,
    this.onCopyMeetingPasscode,
    this.onCopyShareLink,
    this.shareButtons = true,
    this.position = 'bottomRight',
    required this.roomName,
    required this.adminPasscode,
    required this.islevel,
  });

  @override
  Widget build(BuildContext context) {
    final double modalWidth = 0.8 * MediaQuery.of(context).size.width > 450
        ? 450
        : 0.8 * MediaQuery.of(context).size.width;
    final modalHeight = MediaQuery.of(context).size.height * 0.75;

    return Visibility(
      visible: isVisible,
      child: Stack(
        children: [
          Positioned(
            top: getModalPosition(
                position, context, modalWidth, modalHeight)['top'],
            right: getModalPosition(
                position, context, modalWidth, modalHeight)['right'],
            child: Container(
              width: modalWidth,
              height: modalHeight,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Menu',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (isVisible) {
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
                  const SizedBox(height: 10),
                  const Divider(color: Color.fromARGB(255, 23, 22, 22)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView(
                      children: [
                        CustomButtons(buttons: customButtons),
                        if (islevel == '2') ...[
                          MeetingPasscodeComponent(
                            meetingPasscode: adminPasscode,
                          ),
                          const SizedBox(height: 10),
                        ],
                        MeetingIdComponent(meetingID: roomName),
                        const SizedBox(height: 10),
                        if (shareButtons) ...[
                          ShareButtonsComponent(
                            meetingID: roomName,
                            eventType: 'webinar',
                          ),
                        ],
                        const SizedBox(height: 10),
                      ],
                    ),
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
