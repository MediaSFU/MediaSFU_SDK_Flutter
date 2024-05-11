// ignore_for_file: empty_catches

typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

/// A function that sends a message to participants based on certain parameters.
///
/// The [parameters] parameter is a map that contains the following keys:
/// - coHostResponsibility: A list of dynamic values representing co-host responsibilities.
/// - participant: A dynamic value representing the participant.
/// - member: A string representing the member.
/// - islevel: A string representing the level.
/// - coHost: A string representing the co-host.
/// - showAlert: A function that shows an alert with the specified message, type, and duration.
/// - updateIsMessagesModalVisible: A function that updates the visibility of the messages modal.
/// - updateDirectMessageDetails: A function that updates the details of the direct message.
/// - updateStartDirectMessage: A function that updates the start of the direct message.
///
/// The function checks if the user is allowed to send a message based on the given parameters.
/// If the user is allowed, it updates the direct message details, starts the direct message,
/// and shows the messages modal. Otherwise, it shows an alert indicating that the user is not allowed
/// to send the message.

void messageParticipants({required Map<String, dynamic> parameters}) {
  final List<dynamic> coHostResponsibility =
      parameters['coHostResponsibility'] ?? [];
  final dynamic participant = parameters['participant'];
  final String member = parameters['member'] ?? '';
  final String islevel = parameters['islevel'] ?? '1';
  final String coHost = parameters['coHost'] ?? '';
  final ShowAlert? showAlert = parameters['showAlert'];

  final void Function(bool) updateIsMessagesModalVisible =
      parameters['updateIsMessagesModalVisible'] as void Function(bool);
  final void Function(Map<String, dynamic>) updateDirectMessageDetails =
      parameters['updateDirectMessageDetails'] as void Function(
          Map<String, dynamic>);
  final void Function(bool) updateStartDirectMessage =
      parameters['updateStartDirectMessage'] as void Function(bool);

  bool chatValue = false;

  try {
    chatValue = coHostResponsibility
        .firstWhere((item) => item['name'] == 'chat')['value'];
  } catch (error) {}

  if (islevel == '2' || (coHost == member && chatValue == true)) {
    if (participant['islevel'] != '2') {
      updateDirectMessageDetails(participant);
      updateStartDirectMessage(true);
      updateIsMessagesModalVisible(true);
    }
  } else {
    if (showAlert != null) {
      showAlert(
        message: 'You are not allowed to send this message',
        type: 'danger',
        duration: 3000,
      );
    }
  }
}
