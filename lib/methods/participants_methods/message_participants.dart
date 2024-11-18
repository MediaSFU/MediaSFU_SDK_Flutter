import '../../types/types.dart'
    show Participant, CoHostResponsibility, ShowAlert;

/// Defines options for messaging a participant.
class MessageParticipantsOptions {
  final List<CoHostResponsibility> coHostResponsibility;
  final Participant participant;
  final String member;
  final String islevel;
  final ShowAlert? showAlert;
  final String coHost;
  final void Function(bool) updateIsMessagesModalVisible;
  final void Function(Participant?) updateDirectMessageDetails;
  final void Function(bool) updateStartDirectMessage;

  MessageParticipantsOptions({
    required this.coHostResponsibility,
    required this.participant,
    required this.member,
    required this.islevel,
    this.showAlert,
    required this.coHost,
    required this.updateIsMessagesModalVisible,
    required this.updateDirectMessageDetails,
    required this.updateStartDirectMessage,
  });
}

/// Type definition for the function that sends a message to participants.
typedef MessageParticipantsType = void Function(
    MessageParticipantsOptions options);

/// Sends a direct message to a participant if the current member has the necessary permissions.
///
/// This function checks if the current member has the required permissions based on their level
/// and co-host responsibilities. If authorized, it initiates a direct message.
///
/// Example:
/// ```dart
/// final options = MessageParticipantsOptions(
///   coHostResponsibility: [CoHostResponsibility(name: 'chat', value: true)],
///   participant: Participant(name: 'John Doe', islevel: '1'),
///   member: 'currentMember',
///   islevel: '2',
///   showAlert: (alert) => print(alert.message),
///   coHost: 'coHostMember',
///   updateIsMessagesModalVisible: (isVisible) => print('Modal visibility: $isVisible'),
///   updateDirectMessageDetails: (participant) => print('Direct message details: $participant'),
///   updateStartDirectMessage: (start) => print('Start direct message: $start'),
/// );
///
/// messageParticipants(options);
/// ```
void messageParticipants(MessageParticipantsOptions options) {
  bool chatValue = false;

  try {
    chatValue = options.coHostResponsibility
        .firstWhere((item) => item.name == 'chat',
            orElse: () => CoHostResponsibility(
                name: 'chat', value: false, dedicated: false))
        .value;
  } catch (_) {
    chatValue = false;
  }

  if (options.islevel == '2' ||
      (options.coHost == options.member && chatValue)) {
    if (options.participant.islevel != '2') {
      options.updateDirectMessageDetails(options.participant);
      options.updateStartDirectMessage(true);
      options.updateIsMessagesModalVisible(true);
    }
  } else {
    options.showAlert?.call(
      message: 'You are not allowed to send this message',
      type: 'danger',
      duration: 3000,
    );
  }
}
