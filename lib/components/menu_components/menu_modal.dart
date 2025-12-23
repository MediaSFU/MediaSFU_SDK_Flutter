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
import '../../types/modal_style_options.dart' show ModalRenderMode;

/// Configuration payload for [MenuModal].
///
/// Powers the quick-action tray that surfaces meeting metadata and custom
/// buttons:
///
/// * `customButtons`: inject your own action list with icons, text, and
///   callbacks. Rendered via [CustomButtons], enabling branded styling or
///   dynamic visibility.
/// * `shareButtons`: toggle social-sharing controls that expose the meeting ID
///   and passcode to external channels.
/// * `roomName` / `adminPasscode`: meeting credentials displayed in the modal.
///   The passcode is only shown when `islevel == '2'` (admin).
/// * `position`: string (e.g., `'bottomRight'`, `'center'`) controlling modal
///   placement via `getModalPosition`.
/// * `localLink`: optional URL for Community Edition servers, displayed in
///   share components.
///
/// Override this component via `MediasfuUICustomOverrides.menuModal` to inject
/// custom branding, alternative share channels, or additional quick-action
/// buttons.
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
  String? localLink;

  /// Theme control - whether dark mode is active
  final bool isDarkMode;

  /// Callback to toggle the theme mode
  final void Function(bool)? onToggleTheme;

  /// Render mode: modal (default overlay), sidebar (inline for desktop), inline (no wrapper)
  final ModalRenderMode renderMode;

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
    this.localLink = '',
    this.isDarkMode = true,
    this.onToggleTheme,
    this.renderMode = ModalRenderMode.modal,
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
/// - `localLink`: Local link for Community Edition servers.
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
///     localLink: "http://localhost:3000",
///   ),
/// );
/// ```

/// Quick-action menu modal surfacing meeting metadata and custom commands.
///
/// * Displays `MeetingIdComponent` (shareable room name), optional
///   `MeetingPasscodeComponent` (admin-only when `islevel == '2'`), and
///   `ShareButtonsComponent` for social sharing.
/// * Renders `CustomButtons` from the options, enabling you to inject branded
///   actions, debug tools, or CRM shortcuts.
/// * Positions itself via `getModalPosition` using the `position` string.
/// * Hides gracefully when `isVisible` is false.
///
/// Override this component via `MediasfuUICustomOverrides.menuModal` to inject
/// alternative share channels, custom metadata displays, or additional quick
/// actions.
class MenuModal extends StatelessWidget {
  final MenuModalOptions options;

  const MenuModal({super.key, required this.options});

  /// Builds the main content of the menu (buttons, passcode, meeting ID, share)
  Widget _buildMenuContent(BuildContext context, {bool showHeader = true}) {
    final textColor = options.isDarkMode ? Colors.white : Colors.black;
    final dividerColor = options.isDarkMode ? Colors.white24 : Colors.black26;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with title and close button (only in modal mode)
        if (showHeader) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Menu',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              GestureDetector(
                onTap: options.onClose,
                child: Icon(
                  Icons.close,
                  size: 20,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: dividerColor),
          const SizedBox(height: 10),
        ],
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
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
                    localLink: options.localLink,
                  ),
                ),
              ],
              const SizedBox(height: 25),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Modal mode: full overlay with positioning
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
              child: _buildMenuContent(context, showHeader: true),
            ),
          ),
        ],
      ),
    );
  }
}
