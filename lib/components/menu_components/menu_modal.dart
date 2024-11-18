import 'package:flutter/material.dart';
import './meeting_id_component.dart'
    show MeetingIdComponent, MeetingIdComponentOptions;
import './meeting_passcode_component.dart'
    show MeetingPasscodeComponent, MeetingPasscodeComponentOptions;
import './share_buttons_component.dart'
    show ShareButtonsComponent, ShareButtonsComponentOptions;
import './custom_buttons.dart'
    show CustomButtons, CustomButtonsOptions, CustomButton;
import '../../methods/utils/get_modal_position.dart'
    show getModalPosition, GetModalPositionOptions;
import '../../types/types.dart' show EventType;

/// Options class for configuring the MenuModal widget.
class MenuModalOptions {
  final Color backgroundColor;
  final bool isVisible;
  final Function() onClose;
  final List<CustomButton> customButtons;
  final bool shareButtons;
  final String position;
  final String roomName;
  final String adminPasscode;
  final String islevel;
  final EventType eventType;

  MenuModalOptions({
    this.backgroundColor = const Color(0xFF83C0E9),
    required this.isVisible,
    required this.onClose,
    required this.customButtons,
    this.shareButtons = true,
    this.position = 'bottomRight',
    required this.roomName,
    required this.adminPasscode,
    required this.islevel,
    required this.eventType,
  });
}

typedef MenuModalType = Widget Function(MenuModalOptions options);

/// `MenuModalOptions` - Configuration options for the `MenuModal` widget.
/// - `backgroundColor`: Background color of the modal. Default is `Color(0xFF83C0E9)`.
/// - `isVisible`: Controls the modal's visibility.
/// - `onClose`: Callback function triggered when the close icon is tapped.
/// - `customButtons`: List of custom buttons configured with `CustomButtonsOptions`.
/// - `shareButtons`: Controls the visibility of share buttons. Default is `true`.
/// - `position`: Position of the modal on the screen (e.g., 'bottomRight').
/// - `roomName`: Meeting room name or ID.
/// - `adminPasscode`: Passcode for the meeting, visible only to admins.
/// - `islevel`: User level, with level `2` indicating an admin.
/// - `eventType`: Type of event (from `EventType`).
///
/// Example usage:
/// ```dart
/// MenuModal(
///   options: MenuModalOptions(
///     isVisible: true,
///     onClose: () => print("Modal closed"),
///     customButtons: [
///       CustomButtonsOptions(
///         action: () => print("Action 1"),
///         text: "First Button",
///         backgroundColor: Colors.blue,
///         icon: Icons.settings,
///       ),
///     ],
///     roomName: "123-456-789",
///     adminPasscode: "adminPass123",
///     islevel: "2",
///     eventType: EventType.conference,
///   ),
/// );
/// ```

/// `MenuModal` - Displays a modal with a configurable menu.
///
/// This widget can display various options in a modal, including custom buttons,
/// meeting ID and passcode information, and share buttons for social sharing.
///
/// ### Parameters:
/// - `options`: Instance of `MenuModalOptions` with configuration settings for the modal.
///
/// ### Widget Structure:
/// - The modal includes a header with a title and close icon.
/// - Below the header, it displays custom buttons, the meeting passcode (for admins), the meeting ID, and share buttons.
/// - Positioned on the screen based on the `position` parameter.
///
/// ### Customization:
/// - **Visibility**: Control modal visibility with `isVisible`.
/// - **Custom Buttons**: Add buttons by specifying `CustomButtonsOptions`.
/// - **Share Buttons**: Toggle share buttons with `shareButtons`.
/// - **Positioning**: Adjust modal position with `position` (e.g., 'bottomRight').

class MenuModal extends StatelessWidget {
  final MenuModalOptions options;

  const MenuModal({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    final double modalWidth = MediaQuery.of(context).size.width * 0.8 > 450
        ? 450
        : MediaQuery.of(context).size.width * 0.8;
    final double modalHeight = MediaQuery.of(context).size.height * 0.75;

    return Visibility(
      visible: options.isVisible,
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
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with title and close button
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
                        onTap: options.onClose,
                        child: const Icon(
                          Icons.close,
                          size: 20,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.black),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView(
                      children: [
                        // Custom buttons section
                        CustomButtons(
                          options: CustomButtonsOptions(
                            buttons: options.customButtons,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Meeting passcode for hosts
                        if (options.islevel == '2')
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: MeetingPasscodeComponent(
                              options: MeetingPasscodeComponentOptions(
                                meetingPasscode: options.adminPasscode,
                              ),
                            ),
                          ),

                        // Meeting ID
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: MeetingIdComponent(
                            options: MeetingIdComponentOptions(
                              meetingID: options.roomName,
                            ),
                          ),
                        ),

                        // Share buttons, if enabled
                        if (options.shareButtons) ...[
                          ShareButtonsComponent(
                            options: ShareButtonsComponentOptions(
                              meetingID: options.roomName,
                              eventType: options.eventType,
                            ),
                          ),
                        ],
                        const SizedBox(height: 25),
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
