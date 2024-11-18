import '../../types/types.dart' show ShowAlert;

/// Type definition for updating the chat modal's visibility.
typedef UpdateIsMessagesModalVisible = void Function(bool isVisible);

/// Parameters for the `clickChat` function.
class ClickChatOptions {
  final bool isMessagesModalVisible;
  final UpdateIsMessagesModalVisible updateIsMessagesModalVisible;
  final String chatSetting;
  final String islevel;
  final ShowAlert? showAlert;

  ClickChatOptions({
    required this.isMessagesModalVisible,
    required this.updateIsMessagesModalVisible,
    required this.chatSetting,
    required this.islevel,
    this.showAlert,
  });
}

typedef ClickChatType = void Function({required ClickChatOptions options});

/// Toggles the visibility of the chat modal based on the current state and event settings.
///
/// - If the modal is already visible, it will be closed.
/// - If the modal is not visible, it checks whether chat is allowed based on the event settings and participant level.
/// - If chat is not allowed, an alert will be shown.
///
/// ### Example Usage:
/// ```dart
/// clickChat(
///   options: ClickChatOptions(
///     isMessagesModalVisible: false,
///     updateIsMessagesModalVisible: (isVisible) => setIsMessagesModalVisible(isVisible),
///     chatSetting: 'allow',
///     islevel: '1',
///     showAlert: (message, type, duration) => showAlertFunction(message, type, duration),
///   ),
/// );
/// ```
void clickChat({required ClickChatOptions options}) {
  final isMessagesModalVisible = options.isMessagesModalVisible;
  final updateIsMessagesModalVisible = options.updateIsMessagesModalVisible;
  final chatSetting = options.chatSetting;
  final islevel = options.islevel;
  final showAlert = options.showAlert;

  if (isMessagesModalVisible) {
    // Close the chat modal if it's currently visible
    updateIsMessagesModalVisible(false);
  } else {
    // Check if chat is allowed based on the chat setting and participant level
    if (chatSetting != 'allow' && islevel != '2') {
      updateIsMessagesModalVisible(false);
      showAlert?.call(
        message: 'Chat is disabled for this event.',
        type: 'danger',
        duration: 3000,
      );
    } else {
      updateIsMessagesModalVisible(true);
    }
  }
}
