import 'package:flutter/material.dart';

/// ParticipantListItem - Represents a single participant item in a participant list.
///
/// This widget displays information about a participant and provides actions
/// such as muting, messaging, and removing participants.
///
/// participant - A map containing information about the participant.
///
/// isBroadcast - A boolean indicating whether the meeting is a broadcast.
///
/// onMuteParticipants - A function to mute participants.
///
/// onMessageParticipants - A function to message participants.
///
/// onRemoveParticipants - A function to remove participants.
///
/// formatBroadcastViews - A function to format the number of broadcast views.
///
/// parameters - Additional parameters for handling participant actions.
///
/// _buildIconButton - Builds a customized IconButton for participant actions.

class ParticipantListItem extends StatelessWidget {
  final Map<String, dynamic> participant;
  final bool isBroadcast;
  final Future<void> Function({
    required Map<String, dynamic> parameters,
  }) onMuteParticipants;
  final void Function({
    required Map<String, dynamic> parameters,
  }) onMessageParticipants;
  final Future<void> Function({
    required Map<String, dynamic> parameters,
  }) onRemoveParticipants;
  final Function(int) formatBroadcastViews;
  final Map<String, dynamic> parameters;

  const ParticipantListItem({
    super.key,
    required this.participant,
    required this.isBroadcast,
    required this.onMuteParticipants,
    required this.onMessageParticipants,
    required this.onRemoveParticipants,
    required this.formatBroadcastViews,
    required this.parameters,
  });

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
                participant['islevel'] == '2'
                    ? '${participant['name']} (host)'
                    : participant['name'],
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            if (!isBroadcast) ...[
              const SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: Icon(
                  participant['muted'] ? Icons.circle : Icons.circle,
                  color: participant['muted'] ? Colors.red : Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 20),
              _buildIconButton(
                onPressed: () => onMuteParticipants(parameters: {
                  ...parameters,
                  'participant': participant,
                }),
                icon: participant['muted'] ? Icons.mic_off : Icons.mic,
                backgroundColor: Colors.blue,
              ),
              const SizedBox(width: 20),
              _buildIconButton(
                onPressed: () => onMessageParticipants(parameters: {
                  ...parameters,
                  'participant': participant,
                }),
                icon: Icons.message,
                backgroundColor: Colors.blue,
              ),
            ],
            const SizedBox(width: 20),
            _buildIconButton(
              onPressed: () => onRemoveParticipants(parameters: {
                ...parameters,
                'participant': participant,
              }),
              icon: Icons.delete,
              backgroundColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required VoidCallback onPressed,
    required IconData icon,
    required Color backgroundColor,
  }) {
    return Expanded(
      flex: 2,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(5),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}
