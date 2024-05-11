import 'package:flutter/material.dart';
import '../menu_components/share_buttons_component.dart'
    show ShareButtonsComponent;
import '../../methods/utils/get_modal_position.dart' show getModalPosition;
import '../menu_components/meeting_passcode_component.dart'
    show MeetingPasscodeComponent;
import '../menu_components/meeting_id_component.dart' show MeetingIdComponent;

/// A modal widget that displays a share event dialog.
///
/// This widget is used to show a modal dialog that allows users to share an event.
/// It includes options to copy the meeting ID, meeting passcode, and share link.
/// The dialog can be customized with different background colors, position, and visibility.
///
/// Example usage:
/// ```dart
/// ShareEventModal(
///   isShareEventModalVisible: true,
///   onShareEventClose: () {
///     // Close the share event modal
///   },
///   onCopyMeetingId: () {
///     // Copy the meeting ID
///   },
///   onCopyMeetingPasscode: () {
///     // Copy the meeting passcode
///   },
///   onCopyShareLink: () {
///     // Copy the share link
///   },
///   roomName: 'Meeting Room',
///   adminPasscode: '123456',
///   islevel: '2',
/// )
/// ```

class ShareEventModal extends StatelessWidget {
  final Color backgroundColor;
  final bool isShareEventModalVisible;
  final VoidCallback onShareEventClose;
  final Function onCopyMeetingId;
  final Function onCopyMeetingPasscode;
  final Function onCopyShareLink;
  final bool shareButtons;
  final String position;
  final String roomName;
  final String adminPasscode;
  final String islevel;

  const ShareEventModal({
    super.key,
    this.backgroundColor = const Color.fromRGBO(131, 192, 233, 0.25),
    required this.isShareEventModalVisible,
    required this.onShareEventClose,
    required this.onCopyMeetingId,
    required this.onCopyMeetingPasscode,
    required this.onCopyShareLink,
    this.shareButtons = true,
    this.position = 'topRight',
    required this.roomName,
    required this.adminPasscode,
    required this.islevel,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double modalWidth = 0.8 * screenWidth;
    if (modalWidth > 400) {
      modalWidth = 400;
    }

    final modalHeight = MediaQuery.of(context).size.height * 0.6;

    return Visibility(
      visible: isShareEventModalVisible,
      child: Stack(
        children: [
          Positioned(
            top: getModalPosition(
                position, context, modalWidth, modalHeight)['top'],
            right: getModalPosition(
                position, context, modalWidth, modalHeight)['right'],
            child: Container(
              padding: const EdgeInsets.all(20), // Add padding here
              width: modalWidth,
              height: modalHeight,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: onShareEventClose,
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const Divider(
                    color: Colors.black,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          if (islevel == '2')
                            MeetingPasscodeComponent(
                              meetingPasscode: adminPasscode,
                            ),
                          MeetingIdComponent(
                            meetingID: roomName,
                          ),
                          const SizedBox(height: 20),
                          if (shareButtons)
                            ShareButtonsComponent(
                              meetingID: roomName,
                              eventType: 'webinar',
                            ),
                        ],
                      ),
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
