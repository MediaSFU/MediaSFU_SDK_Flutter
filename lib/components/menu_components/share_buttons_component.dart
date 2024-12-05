import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:clipboard/clipboard.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../types/types.dart' show EventType;

/// ShareButtonOptions - Defines options for each share button in the ShareButtonsComponent widget.
class ShareButtonOptions {
  final IconData? icon;
  final VoidCallback action;
  final bool show;
  final Color? backgroundColor;
  final Color? iconColor;

  ShareButtonOptions({
    required this.action,
    this.icon,
    this.show = true,
    this.backgroundColor = Colors.blue,
    this.iconColor = Colors.white,
  });
}

/// ShareButtonsComponentOptions - Configures the ShareButtonsComponent with meeting details and custom buttons.
class ShareButtonsComponentOptions {
  final String meetingID;
  final EventType eventType;
  final List<ShareButtonOptions>? customButtons;
  final String? localLink;

  ShareButtonsComponentOptions({
    required this.meetingID,
    required this.eventType,
    this.customButtons,
    this.localLink,
  });
}

/// ShareButtonsComponent - A widget that displays a row of customizable share buttons for sharing a meeting link.
///
/// This component provides default share buttons for copying to clipboard, email, Facebook, WhatsApp, and Telegram,
/// and allows additional custom buttons to be provided.
///
/// ### Parameters:
/// - `options`: An instance of `ShareButtonsComponentOptions` containing meeting details and optional custom buttons.
///
/// ### Example Usage:
/// ```dart
/// ShareButtonsComponent(
///   options: ShareButtonsComponentOptions(
///     meetingID: "123456",
///     eventType: EventType.webinar,
///     localLink: "https://example.com",
///     customButtons: [
///       ShareButtonOptions(
///         icon: FontAwesomeIcons.twitter,
///         action: () => print("Sharing to Twitter"),
///         backgroundColor: Colors.blue,
///         iconColor: Colors.white,
///       ),
///     ],
///   ),
/// );
/// ```
class ShareButtonsComponent extends StatelessWidget {
  final ShareButtonsComponentOptions options;

  const ShareButtonsComponent({super.key, required this.options});

  String getShareUrl() {
    if (options.localLink != null &&
        options.localLink!.isNotEmpty &&
        !options.localLink!.contains('mediasfu.com')) {
      return '${options.localLink}/meeting/${options.meetingID}';
    }
    final shareName = options.eventType == EventType.chat
        ? 'chat'
        : options.eventType == EventType.broadcast
            ? 'broadcast'
            : 'meeting';
    return 'https://$shareName.mediasfu.com/$shareName/${options.meetingID}';
  }

  @override
  Widget build(BuildContext context) {
    final defaultButtons = [
      ShareButtonOptions(
        icon: Icons.copy,
        action: () async {
          await FlutterClipboard.copy(getShareUrl());
        },
      ),
      ShareButtonOptions(
        icon: Icons.email,
        action: () {
          final emailUrl =
              'mailto:?subject=Join my meeting&body=Here\'s the link: ${getShareUrl()}';
          launchUrl(Uri.parse(emailUrl));
        },
      ),
      ShareButtonOptions(
        icon: Icons.facebook,
        action: () {
          final facebookUrl =
              'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(getShareUrl())}';
          launchUrl(Uri.parse(facebookUrl));
        },
      ),
      ShareButtonOptions(
        icon: FontAwesomeIcons.whatsapp,
        action: () {
          final whatsappUrl =
              'https://wa.me/?text=${Uri.encodeComponent(getShareUrl())}';
          launchUrl(Uri.parse(whatsappUrl));
        },
      ),
      ShareButtonOptions(
        icon: FontAwesomeIcons.telegram,
        action: () {
          final telegramUrl =
              'https://t.me/share/url?url=${Uri.encodeComponent(getShareUrl())}';
          launchUrl(Uri.parse(telegramUrl));
        },
      ),
    ];

    final buttonsToShow = options.customButtons ?? defaultButtons;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: buttonsToShow
          .where((button) => button.show)
          .map<Widget>(
            (button) => GestureDetector(
              onTap: button.action,
              child: Container(
                padding: const EdgeInsets.all(5),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: button.backgroundColor ?? Colors.blue,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(
                  button.icon ?? Icons.error_outline,
                  color: button.iconColor ?? Colors.white,
                  size: 24,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
