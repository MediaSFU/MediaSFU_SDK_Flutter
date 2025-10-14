import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:clipboard/clipboard.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../types/types.dart' show EventType;

/// Configuration options for a single share button in `ShareButtonsComponent`.
///
/// Defines the appearance and action for one social sharing button,
/// allowing customization of icon, colors, visibility, and tap behavior.
///
/// **Properties:**
/// - `action`: Callback invoked when button is tapped (required)
/// - `icon`: IconData for button (null shows error_outline icon)
/// - `show`: Visibility flag (true = show button, false = hide). Defaults to true
/// - `backgroundColor`: Button background color. Defaults to Colors.blue
/// - `iconColor`: Icon color. Defaults to Colors.white
///
/// **Common Configurations:**
/// ```dart
/// // 1. Twitter share button
/// ShareButtonOptions(
///   icon: FontAwesomeIcons.twitter,
///   action: () => launchUrl(Uri.parse('https://twitter.com/...')),
///   backgroundColor: Colors.lightBlue,
/// )
///
/// // 2. Custom action button
/// ShareButtonOptions(
///   icon: Icons.link,
///   action: () => showLinkDialog(),
///   backgroundColor: Colors.green,
///   show: hasPermission,
/// )
/// ```
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

/// Configuration options for the `ShareButtonsComponent` widget.
///
/// Defines meeting details for generating share URLs and allows custom
/// share button configurations to replace or supplement default buttons.
///
/// **Properties:**
/// - `meetingID`: The meeting/event ID to share (required)
/// - `eventType`: Type of event (chat, broadcast, conference, webinar) - affects URL generation (required)
/// - `customButtons`: Optional custom share buttons (if provided, replaces default buttons)
/// - `localLink`: Optional custom domain for share URLs (e.g., "https://mycorp.com"). If null, uses mediasfu.com
///
/// **Share URL Generation Logic:**
/// ```
/// if (localLink provided && !contains('mediasfu.com')) {
///   URL = "{localLink}/meeting/{meetingID}"
/// } else {
///   if (eventType == chat) prefix = 'chat'
///   else if (eventType == broadcast) prefix = 'broadcast'
///   else prefix = 'meeting'
///   URL = "https://{prefix}.mediasfu.com/{prefix}/{meetingID}"
/// }
/// ```
///
/// **Default Share Buttons (if customButtons not provided):**
/// 1. Copy to clipboard (Icons.copy)
/// 2. Email (Icons.email)
/// 3. Facebook (Icons.facebook)
/// 4. WhatsApp (FontAwesomeIcons.whatsapp)
/// 5. Telegram (FontAwesomeIcons.telegram)
///
/// **Common Configurations:**
/// ```dart
/// // 1. Default buttons with MediaSFU domain
/// ShareButtonsComponentOptions(
///   meetingID: "ABC123",
///   eventType: EventType.conference,
/// )
/// // Result URLs: https://meeting.mediasfu.com/meeting/ABC123
///
/// // 2. Custom domain
/// ShareButtonsComponentOptions(
///   meetingID: "XYZ789",
///   eventType: EventType.webinar,
///   localLink: "https://meetings.mycorp.com",
/// )
/// // Result URLs: https://meetings.mycorp.com/meeting/XYZ789
///
/// // 3. Custom buttons only
/// ShareButtonsComponentOptions(
///   meetingID: "123456",
///   eventType: EventType.chat,
///   customButtons: [
///     ShareButtonOptions(
///       icon: FontAwesomeIcons.twitter,
///       action: () => shareToTwitter(),
///     ),
///     ShareButtonOptions(
///       icon: FontAwesomeIcons.linkedin,
///       action: () => shareToLinkedIn(),
///     ),
///   ],
/// )
/// ```
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

/// A stateless widget rendering a horizontal row of social share buttons.
///
/// Displays configurable share buttons for distributing meeting links via various channels.
/// Provides 5 default share buttons (copy, email, Facebook, WhatsApp, Telegram) or
/// accepts custom button configurations for brand-specific sharing options.
///
/// **Default Share Actions:**
/// 1. **Copy (Icons.copy):** Copies URL to clipboard using FlutterClipboard
/// 2. **Email (Icons.email):** Opens mailto: link with pre-filled subject/body
/// 3. **Facebook (Icons.facebook):** Opens Facebook sharer with encoded URL
/// 4. **WhatsApp (FontAwesomeIcons.whatsapp):** Opens WhatsApp share dialog
/// 5. **Telegram (FontAwesomeIcons.telegram):** Opens Telegram share URL dialog
///
/// **Share URL Generation (getShareUrl):**
/// ```dart
/// if (localLink && !localLink.contains('mediasfu.com')) {
///   return '{localLink}/meeting/{meetingID}';
/// } else {
///   shareName = eventType == chat ? 'chat' :
///               eventType == broadcast ? 'broadcast' : 'meeting';
///   return 'https://{shareName}.mediasfu.com/{shareName}/{meetingID}';
/// }
/// ```
///
/// **Rendering Structure:**
/// ```
/// Row (mainAxisAlignment: center)
///   ├─ GestureDetector (onTap: button.action)
///   │  └─ Container
///   │     ├─ padding: 5px all
///   │     ├─ margin: 8px horizontal
///   │     ├─ backgroundColor: button.backgroundColor
///   │     ├─ borderRadius: 5px
///   │     └─ Icon (24px, button.icon, button.iconColor)
///   └─ ... (repeated for each visible button)
/// ```
///
/// **Common Use Cases:**
/// 1. **Default Share Buttons:**
///    ```dart
///    ShareButtonsComponent(
///      options: ShareButtonsComponentOptions(
///        meetingID: parameters.meetingID,
///        eventType: EventType.conference,
///      ),
///    )
///    // Shows: Copy, Email, Facebook, WhatsApp, Telegram
///    ```
///
/// 2. **Custom Domain Sharing:**
///    ```dart
///    ShareButtonsComponent(
///      options: ShareButtonsComponentOptions(
///        meetingID: "XYZ123",
///        eventType: EventType.webinar,
///        localLink: "https://webinars.company.com",
///      ),
///    )
///    // Share URL: https://webinars.company.com/meeting/XYZ123
///    ```
///
/// 3. **Custom Buttons Only:**
///    ```dart
///    ShareButtonsComponent(
///      options: ShareButtonsComponentOptions(
///        meetingID: "ABC456",
///        eventType: EventType.broadcast,
///        customButtons: [
///          ShareButtonOptions(
///            icon: FontAwesomeIcons.twitter,
///            action: () {
///              final twitterUrl = 'https://twitter.com/intent/tweet?url=${Uri.encodeComponent(url)}';
///              launchUrl(Uri.parse(twitterUrl));
///            },
///            backgroundColor: Color(0xFF1DA1F2),
///          ),
///          ShareButtonOptions(
///            icon: FontAwesomeIcons.linkedin,
///            action: () {
///              final linkedInUrl = 'https://www.linkedin.com/sharing/share-offsite/?url=${Uri.encodeComponent(url)}';
///              launchUrl(Uri.parse(linkedInUrl));
///            },
///            backgroundColor: Color(0xFF0A66C2),
///          ),
///          ShareButtonOptions(
///            icon: Icons.message,
///            action: () => shareViaSMS(url),
///            backgroundColor: Colors.green,
///          ),
///        ],
///      ),
///    )
///    ```
///
/// 4. **Conditional Button Display:**
///    ```dart
///    ShareButtonsComponent(
///      options: ShareButtonsComponentOptions(
///        meetingID: meetingId,
///        eventType: EventType.conference,
///        customButtons: [
///          ShareButtonOptions(
///            icon: Icons.copy,
///            action: () => copyToClipboard(url),
///            show: true, // always show
///          ),
///          ShareButtonOptions(
///            icon: FontAwesomeIcons.twitter,
///            action: () => shareToTwitter(url),
///            show: enableTwitter, // conditional
///          ),
///          ShareButtonOptions(
///            icon: FontAwesomeIcons.slack,
///            action: () => shareToSlack(url),
///            show: userHasSlackIntegration, // conditional
///          ),
///        ],
///      ),
///    )
///    ```
///
/// **Button Filtering:**
/// - Only buttons with `show: true` are rendered
/// - `.where((button) => button.show)` filters visible buttons
/// - Allows dynamic button visibility based on permissions, features, or settings
///
/// **URL Encoding:**
/// - All share URLs are properly encoded using `Uri.encodeComponent()`
/// - Handles special characters in meeting IDs and custom domains
/// - Prevents URL injection or malformed links
///
/// **External Dependencies:**
/// - `url_launcher`: Opens email, social media URLs in external apps/browsers
/// - `clipboard`: Copies URLs to system clipboard
/// - `font_awesome_flutter`: Provides social media icons (WhatsApp, Telegram)
///
/// **Styling:**
/// - Button size: 24px icon + 5px padding + 8px margin = ~42px total width
/// - Default colors: Blue background, white icon
/// - Rounded corners: 5px border radius
/// - Center-aligned row with even spacing
///
/// **Typical Usage Context:**
/// - ShareEventModal share section
/// - MenuModal quick share actions
/// - Post-meeting feedback/invite screen
/// - Meeting lobby "Invite Others" section
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
