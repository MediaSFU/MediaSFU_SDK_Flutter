import 'package:flutter/material.dart';

/// ParticipantListOthersItem - Represents a single participant item in a participant list for other participants (not the current user).
///
/// This widget displays information about a participant and indicates whether they are muted.
///
/// participant - A map containing information about the participant.
///
/// parameters - Additional parameters such as member, co-host, and islevel for displaying participant details.

class ParticipantListOthersItem extends StatelessWidget {
  final Map<String, dynamic> participant;
  final Map<String, dynamic> parameters;

  const ParticipantListOthersItem(
      {super.key, required this.participant, required this.parameters});

  @override
  Widget build(BuildContext context) {
    final String member = parameters['member'];
    final String coHost = parameters['coHost'];
    final String islevel = parameters['islevel'];

    String displayName = participant['name'];

    if (islevel == '2') {
      if (participant['name'] == member) {
        displayName = '$displayName (you)';
      } else if (participant['name'] == coHost) {
        displayName = '$displayName (co-host)';
      } else {
        displayName = '$displayName (host)';
      }
    } else {
      if (participant['name'] == member) {
        displayName = '$displayName (you)';
      }
    }

    return Padding(
      padding: const EdgeInsets.only(left: 15), // Adjust the value as needed
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Expanded(
              flex: 8,
              child: Text(
                displayName,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Expanded(
              flex: 4,
              child: Icon(
                // Add the dot icon here
                participant['muted'] ? Icons.circle : Icons.circle,
                color: participant['muted'] ? Colors.red : Colors.green,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
