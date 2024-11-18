import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../../types/types.dart'
    show
        Participant,
        MuteParticipantsType,
        MessageParticipantsType,
        RemoveParticipantsType,
        CoHostResponsibility,
        ShowAlert;
import './participant_list_item.dart'
    show ParticipantListItem, ParticipantListItemOptions;

/// `ParticipantListOptions` defines the configuration options for the `ParticipantList` widget,
/// including participant data, actions, and session details.
///
/// Parameters:
/// - `participants`: The list of participants to display.
/// - `isBroadcast`: Indicates if this is a broadcast session.
/// - `onMuteParticipants`, `onMessageParticipants`, `onRemoveParticipants`: Callbacks for participant actions.
/// - `socket`: The socket for real-time interaction.
/// - `coHostResponsibility`, `member`, `islevel`, `coHost`, `roomName`: Session-specific details.
/// - `showAlert`, `updateIsMessagesModalVisible`, `updateDirectMessageDetails`, `updateStartDirectMessage`, `updateParticipants`: Functions for updating state and providing feedback.

class ParticipantListOptions {
  final List<Participant> participants;
  final bool isBroadcast;
  final MuteParticipantsType onMuteParticipants;
  final MessageParticipantsType onMessageParticipants;
  final RemoveParticipantsType onRemoveParticipants;
  final io.Socket? socket;
  final List<CoHostResponsibility> coHostResponsibility;
  final String member;
  final String islevel;
  final ShowAlert? showAlert;
  final String coHost;
  final String roomName;
  final void Function(bool) updateIsMessagesModalVisible;
  final void Function(Participant?) updateDirectMessageDetails;
  final void Function(bool) updateStartDirectMessage;
  final void Function(List<Participant>) updateParticipants;

  ParticipantListOptions({
    required this.participants,
    required this.isBroadcast,
    required this.onMuteParticipants,
    required this.onMessageParticipants,
    required this.onRemoveParticipants,
    this.socket,
    required this.coHostResponsibility,
    required this.member,
    required this.islevel,
    this.showAlert,
    required this.coHost,
    required this.roomName,
    required this.updateIsMessagesModalVisible,
    required this.updateDirectMessageDetails,
    required this.updateStartDirectMessage,
    required this.updateParticipants,
  });
}

typedef ParticipantListType = Widget Function(
    {required ParticipantListOptions options});

/// `ParticipantList` renders a scrollable list of participant items, each with controls
/// for muting, messaging, and removing, based on `ParticipantListOptions`.
///
/// This widget facilitates participant interaction for different session types (e.g., broadcast).
///
/// Example Usage:
/// ```dart
/// ParticipantList(
///   options: ParticipantListOptions(
///     participants: [
///       Participant(name: 'John Doe', muted: false, islevel: '1'),
///       Participant(name: 'Jane Smith', muted: true, islevel: '2')
///     ],
///     isBroadcast: false,
///     onMuteParticipants: (options) => print("Mute participant: ${options.participant.name}"),
///     onMessageParticipants: (options) => print("Message participant: ${options.participant.name}"),
///     onRemoveParticipants: (options) => print("Remove participant: ${options.participant.name}"),
///     socket: io.Socket(),
///     coHostResponsibility: [CoHostResponsibility(name: 'host')],
///     member: 'JohnDoe123',
///     islevel: '1',
///     showAlert: (message) => print("Alert: $message"),
///     coHost: 'JaneSmith123',
///     roomName: 'Room A',
///     updateIsMessagesModalVisible: (isVisible) => print("Message modal visible: $isVisible"),
///     updateDirectMessageDetails: (details) => print("Direct message details updated"),
///     updateStartDirectMessage: (start) => print("Direct messaging started: $start"),
///     updateParticipants: (newList) => print("Participants updated: $newList"),
///   ),
/// );
/// ```

class ParticipantList extends StatelessWidget {
  final ParticipantListOptions options;

  const ParticipantList({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: List.generate(
          options.participants.length,
          (index) {
            final participant = options.participants[index];
            return Column(
              children: [
                ParticipantListItem(
                  options: ParticipantListItemOptions(
                    participant: participant,
                    isBroadcast: options.isBroadcast,
                    onMuteParticipants: options.onMuteParticipants,
                    onMessageParticipants: options.onMessageParticipants,
                    onRemoveParticipants: options.onRemoveParticipants,
                    socket: options.socket,
                    coHostResponsibility: options.coHostResponsibility,
                    member: options.member,
                    islevel: options.islevel,
                    showAlert: options.showAlert,
                    coHost: options.coHost,
                    roomName: options.roomName,
                    updateIsMessagesModalVisible:
                        options.updateIsMessagesModalVisible,
                    updateDirectMessageDetails:
                        options.updateDirectMessageDetails,
                    updateStartDirectMessage: options.updateStartDirectMessage,
                    participants: options.participants,
                    updateParticipants: options.updateParticipants,
                  ),
                ),
                if (index < options.participants.length - 1)
                  const Divider(
                    color: Colors.grey,
                    height: 1,
                    thickness: 1,
                    indent: 0,
                    endIndent: 0,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
