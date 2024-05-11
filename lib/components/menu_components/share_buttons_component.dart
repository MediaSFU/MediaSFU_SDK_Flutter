import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:clipboard/clipboard.dart'; // Import the clipboard package
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// ShareButtonsComponent - A component for displaying share buttons.
///
/// This component displays a row of share buttons for various social media platforms
/// like email, Facebook, WhatsApp, and Telegram. It allows users to share the meeting
/// link through different channels.
///
/// The meeting ID to be shared.
/// final String meetingID;
///
/// The type of event, e.g., 'chat', 'broadcast', or 'meeting'.
/// final String eventType;
///
/// A list of custom share buttons to be displayed instead of the default ones.
/// final List<Map<String, dynamic>> shareButtons;

class ShareButtonsComponent extends StatelessWidget {
  final String meetingID;
  final String eventType;
  final List<Map<String, dynamic>> shareButtons;

  const ShareButtonsComponent({
    super.key,
    required this.meetingID,
    required this.eventType,
    this.shareButtons = const [],
  });

  @override
  Widget build(BuildContext context) {
    final shareName = eventType == 'chat'
        ? 'chat'
        : eventType == 'broadcast'
            ? 'broadcast'
            : 'meeting';

    final defaultShareButtons = [
      {
        'icon': Icons.copy,
        'action': () async {
          // Action for the copy button
          await FlutterClipboard.copy(
              'https://$shareName.mediasfu.com/$shareName/$meetingID');
        },
        'show': true,
      },
      {
        'icon': Icons.email,
        'action': () {
          // Action for the email button
          final emailUrl =
              'mailto:?subject=Join my meeting&body=Here\'s the link to the meeting: https://$shareName.mediasfu.com/$shareName/$meetingID';
          launchUrl(Uri.parse(emailUrl));
        },
        'show': true,
      },
      {
        'icon': Icons.facebook,
        'action': () {
          // Action for the Facebook button
          final facebookUrl =
              'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent('https://$shareName.mediasfu.com/$shareName/$meetingID')}';
          launchUrl(Uri.parse(facebookUrl));
        },
        'show': true,
      },
      {
        'icon': FontAwesomeIcons.whatsapp,
        'action': () {
          // Action for the WhatsApp button
          final whatsappUrl =
              'https://wa.me/?text=${Uri.encodeComponent('https://$shareName.mediasfu.com/$shareName/$meetingID')}';
          launchUrl(Uri.parse(whatsappUrl));
        },
        'show': true,
      },
      {
        'icon': Icons.send,
        'action': () {
          // Action for the Telegram button
          final telegramUrl =
              'https://t.me/share/url?url=${Uri.encodeComponent('https://$shareName.mediasfu.com/$shareName/$meetingID')}';
          launchUrl(Uri.parse(telegramUrl));
        },
        'show': true,
      },
    ];

    final filteredShareButtons = shareButtons.isNotEmpty
        ? shareButtons.where((button) => button['show']).toList()
        : defaultShareButtons
            .where((button) => button['show'] as bool)
            .toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: filteredShareButtons.map<Widget>((button) {
        Widget iconWidget;

        // Check if the icon is FontAwesomeIcon
        if (button['icon'] is IconData) {
          iconWidget = Icon(
            button['icon'],
            color: Colors.white,
            size: 24,
          );
        } else if (button['icon'] is IconData) {
          // Render Font Awesome icon
          iconWidget = FaIcon(
            button['icon'],
            color: Colors.white,
            size: 24,
          );
        } else {
          // Fallback to default icon
          iconWidget = const Icon(
            Icons.error_outline,
            color: Colors.white,
            size: 24,
          );
        }

        return GestureDetector(
          onTap: button['action'],
          child: Container(
            padding: const EdgeInsets.all(5),
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(5),
            ),
            child: iconWidget,
          ),
        );
      }).toList(),
    );
  }
}
