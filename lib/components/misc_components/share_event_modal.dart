import 'package:flutter/material.dart';
import '../menu_components/share_buttons_component.dart'
    show ShareButtonsComponent, ShareButtonsComponentOptions;
import '../../methods/utils/get_modal_position.dart'
    show getModalPosition, GetModalPositionOptions;
import '../menu_components/meeting_passcode_component.dart'
    show MeetingPasscodeComponent, MeetingPasscodeComponentOptions;
import '../menu_components/meeting_id_component.dart'
    show MeetingIdComponent, MeetingIdComponentOptions;
import '../../types/types.dart' show EventType;

/// `ShareEventModalOptions` defines the properties for the `ShareEventModal`,
/// including visibility, callbacks, and event data.
///
/// - `backgroundColor`: The background color of the modal.
/// - `isShareEventModalVisible`: Controls the modal's visibility.
/// - `onShareEventClose`: Callback for closing the modal.
/// - `shareButtons`: Controls visibility of share buttons.
/// - `position`: Position of the modal on the screen.
/// - `roomName`: Meeting or room name.
/// - `adminPasscode`: Admin passcode for the event.
/// - `islevel`: User level for displaying certain fields.
/// - `eventType`: Type of the event.

class ShareEventModalOptions {
  final Color backgroundColor;
  final bool isShareEventModalVisible;
  final VoidCallback onShareEventClose;
  final bool shareButtons;
  final String position;
  final String roomName;
  final String adminPasscode;
  final String islevel;
  final EventType eventType;
  String? localLink;

  ShareEventModalOptions({
    this.backgroundColor = const Color.fromRGBO(131, 192, 233, 0.25),
    required this.isShareEventModalVisible,
    required this.onShareEventClose,
    this.shareButtons = true,
    this.position = 'topRight',
    required this.roomName,
    required this.adminPasscode,
    required this.islevel,
    this.eventType = EventType.webinar,
    this.localLink = '',
  });
}

typedef ShareEventModalType = Widget Function(
    {required ShareEventModalOptions options});

/// `ShareEventModal` is a modal widget that allows users to share event details,
/// copy meeting ID and passcode, and interact with sharing buttons.
///
/// Example usage:
/// ```dart
/// ShareEventModal(
///   options: ShareEventModalOptions(
///     isShareEventModalVisible: true,
///     onShareEventClose: () => print("Modal closed"),
///     roomName: "Room 1",
///     adminPasscode: "123456",
///     islevel: "2",
///     eventType: "webinar",
///     localLink: "https://example.com",
///   ),
/// );
/// ```

class ShareEventModal extends StatelessWidget {
  final ShareEventModalOptions options;

  const ShareEventModal({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double modalWidth = 0.8 * screenWidth;
    if (modalWidth > 400) {
      modalWidth = 400;
    }

    final modalHeight = MediaQuery.of(context).size.height * 0.6;

    return Visibility(
      visible: options.isShareEventModalVisible,
      child: Stack(
        children: [
          Positioned(
            top: getModalPosition(
              GetModalPositionOptions(
                position: options.position,
                modalWidth: modalWidth,
                modalHeight: modalHeight,
                context: context,
              ),
            )['top'],
            right: getModalPosition(
              GetModalPositionOptions(
                position: options.position,
                modalWidth: modalWidth,
                modalHeight: modalHeight,
                context: context,
              ),
            )['right'],
            child: Container(
              padding: const EdgeInsets.all(10),
              width: modalWidth,
              height: modalHeight,
              decoration: BoxDecoration(
                color: options.backgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: options.onShareEventClose,
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.black),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          if (options.islevel == '2')
                            MeetingPasscodeComponent(
                              options: MeetingPasscodeComponentOptions(
                                meetingPasscode: options.adminPasscode,
                              ),
                            ),
                          MeetingIdComponent(
                            options: MeetingIdComponentOptions(
                              meetingID: options.roomName,
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (options.shareButtons)
                            ShareButtonsComponent(
                                options: ShareButtonsComponentOptions(
                              meetingID: options.roomName,
                              eventType: options.eventType,
                              localLink: options.localLink,
                            )),
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
