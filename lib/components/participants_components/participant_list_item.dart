import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../../types/types.dart'
    show
        Participant,
        MuteParticipantsType,
        MessageParticipantsType,
        RemoveParticipantsType,
        ShowAlert,
        CoHostResponsibility,
        MuteParticipantsOptions,
        MessageParticipantsOptions,
        RemoveParticipantsOptions;

class ParticipantListItemOptions {
  final Participant participant;
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
  final List<Participant> participants;
  final void Function(List<Participant>) updateParticipants;

  ParticipantListItemOptions({
    required this.participant,
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
    required this.participants,
    required this.updateParticipants,
  });
}

typedef ParticipantListItemType = Widget Function(
    {required ParticipantListItemOptions options});

/// `ParticipantListItem` is a widget that represents an individual participant in a list,
/// allowing actions like muting/unmuting, messaging, and removing the participant.
///
/// This component enables various participant management features based on the `isBroadcast` state.
/// It provides controls for muting, messaging, and removing participants, which can be triggered
/// by icons within each list item.
///
/// ### Parameters:
/// - [ParticipantListItemOptions] (`options`): Configuration options for the participant item, including:
///   - `participant`: The participant data object.
///   - `isBroadcast`: Boolean indicating if the broadcast is active, affecting the visibility of certain controls.
///   - `onMuteParticipants`: Callback for muting/unmuting the participant.
///   - `onMessageParticipants`: Callback for sending a direct message to the participant.
///   - `onRemoveParticipants`: Callback for removing the participant.
///   - `socket`: The socket instance for real-time communication.
///   - `coHostResponsibility`, `member`, `islevel`, `coHost`, `roomName`: Additional settings for control access and room data.
///   - `updateIsMessagesModalVisible`, `updateDirectMessageDetails`, `updateStartDirectMessage`: Callbacks to update message modal and details.
///   - `participants`, `updateParticipants`: List of all participants and the function to update it.
///
/// ### Example Usage:
/// ```dart
/// ParticipantListItem(
///   options: ParticipantListItemOptions(
///     participant: Participant(id: '1', name: 'John Doe', muted: false, islevel: '1'),
///     isBroadcast: false,
///     onMuteParticipants: (options) => print("Mute participant: ${options.participant.name}"),
///     onMessageParticipants: (options) => print("Message participant: ${options.participant.name}"),
///     onRemoveParticipants: (options) => print("Remove participant: ${options.participant.name}"),
///     socket: io.Socket(),
///     coHostResponsibility: [CoHostResponsibility()],
///     member: 'user123',
///     islevel: '1',
///     showAlert: (message) => print("Alert: $message"),
///     coHost: 'user456',
///     roomName: 'Room A',
///     updateIsMessagesModalVisible: (visible) => print("Messages modal visible: $visible"),
///     updateDirectMessageDetails: (details) => print("Direct message details updated"),
///     updateStartDirectMessage: (start) => print("Start direct message: $start"),
///     participants: [Participant(id: '1', name: 'John Doe', muted: false, islevel: '1')],
///     updateParticipants: (newList) => print("Participants updated: $newList"),
///   ),
/// );
/// ```

class ParticipantListItem extends StatelessWidget {
  final ParticipantListItemOptions options;

  const ParticipantListItem({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Text(
                options.participant.islevel == '2'
                    ? '${options.participant.name} (host)'
                    : options.participant.name,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            if (!options.isBroadcast) ...[
              const SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: Icon(
                  options.participant.muted! ? Icons.circle : Icons.circle,
                  color: options.participant.muted! ? Colors.red : Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 20),
              _buildIconButton(
                icon: options.participant.muted! ? Icons.mic_off : Icons.mic,
                color: Colors.blue,
                onPressed: () => options.onMuteParticipants(
                  MuteParticipantsOptions(
                    participant: options.participant,
                    socket: options.socket,
                    coHostResponsibility: options.coHostResponsibility,
                    member: options.member,
                    islevel: options.islevel,
                    showAlert: options.showAlert,
                    coHost: options.coHost,
                    roomName: options.roomName,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              _buildIconButton(
                icon: Icons.message,
                color: Colors.blue,
                onPressed: () =>
                    options.onMessageParticipants(MessageParticipantsOptions(
                  participant: options.participant,
                  coHostResponsibility: options.coHostResponsibility,
                  member: options.member,
                  islevel: options.islevel,
                  showAlert: options.showAlert,
                  coHost: options.coHost,
                  updateIsMessagesModalVisible:
                      options.updateIsMessagesModalVisible,
                  updateDirectMessageDetails:
                      options.updateDirectMessageDetails,
                  updateStartDirectMessage: options.updateStartDirectMessage,
                )),
              ),
            ],
            const SizedBox(width: 20),
            _buildIconButton(
              icon: Icons.delete,
              color: Colors.red,
              onPressed: () =>
                  options.onRemoveParticipants(RemoveParticipantsOptions(
                participant: options.participant,
                socket: options.socket,
                coHostResponsibility: options.coHostResponsibility,
                member: options.member,
                islevel: options.islevel,
                showAlert: options.showAlert,
                coHost: options.coHost,
                roomName: options.roomName,
                participants: options.participants,
                updateParticipants: options.updateParticipants,
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required VoidCallback onPressed,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      flex: 2,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}
