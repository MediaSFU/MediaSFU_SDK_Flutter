import 'package:flutter/material.dart';
import '../../../types/types.dart' show Participant;

/// `ParticipantListOthersItemOptions` represents the options for configuring the display of a participant item.
///
/// Parameters:
/// - `participant`: The participant object.
/// - `member`: The name of the current user.
/// - `coHost`: The name of the co-host.
class ParticipantListOthersItemOptions {
  final Participant participant;
  final String member;
  final String coHost;

  ParticipantListOthersItemOptions({
    required this.participant,
    required this.member,
    required this.coHost,
  });
}

typedef ParticipantListOthersItemType = Widget Function(
    {required ParticipantListOthersItemOptions options});

/// `ParticipantListOthersItem` displays a single participant in a list, including their role and muted status.
///
/// This widget differentiates between the participant roles (`host`, `co-host`, `you`) based on their level and status.
///
/// Example Usage:
/// ```dart
/// ParticipantListOthersItem(
///   options: ParticipantListOthersItemOptions(
///     participant: Participant(name: 'John Doe', islevel: '2', muted: false),
///     member: 'Jane Doe',
///     coHost: 'John Doe',
///   ),
/// );
/// ```
class ParticipantListOthersItem extends StatelessWidget {
  final ParticipantListOthersItemOptions options;

  const ParticipantListOthersItem({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    final participant = options.participant;
    String displayName = participant.name;

    // Determine display name with role
    if (participant.islevel == '2') {
      if (participant.name == options.member) {
        displayName = '$displayName (you)';
      } else if (participant.name == options.coHost) {
        displayName = '$displayName (host)';
      } else {
        displayName = '$displayName (host)';
      }
    } else if (options.coHost == participant.name) {
      displayName = '$displayName (co-host)';
    } else if (participant.name == options.member) {
      displayName = '$displayName (you)';
    }

    return Padding(
      padding: const EdgeInsets.only(left: 15),
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
                Icons.circle,
                color: participant.muted! ? Colors.red : Colors.green,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
