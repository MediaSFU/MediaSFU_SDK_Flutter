import 'package:flutter/material.dart';
import '../../../types/types.dart' show Participant;
import './participant_list_others_item.dart'
    show ParticipantListOthersItem, ParticipantListOthersItemOptions;

/// `ParticipantListOthersOptions` defines the configuration options for the `ParticipantListOthers` widget,
/// including a list of participants, co-host, and member identifiers.
///
/// Parameters:
/// - `participants`: The list of other participants to display.
/// - `coHost`: The identifier of the co-host.
/// - `member`: The identifier of the current user.

class ParticipantListOthersOptions {
  final List<Participant> participants;
  final String coHost;
  final String member;

  ParticipantListOthersOptions({
    required this.participants,
    required this.coHost,
    required this.member,
  });
}

typedef ParticipantListOthersType = Widget Function(
    {required ParticipantListOthersOptions options});

/// `ParticipantListOthers` renders a scrollable list of participants not including the current user.
/// Each participant is represented using `ParticipantListOthersItem`.
///
/// Example Usage:
/// ```dart
/// ParticipantListOthers(
///   options: ParticipantListOthersOptions(
///     participants: [
///       Participant(name: 'Jane Doe', muted: true, id: '1', islevel: '1'),
///       Participant(name: 'John Smith', muted: false, id: '2', islevel: '2')
///     ],
///     coHost: 'host123',
///     member: 'member123',
///   ),
/// );
/// ```

class ParticipantListOthers extends StatelessWidget {
  final ParticipantListOthersOptions options;

  const ParticipantListOthers({super.key, required this.options});

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
                ParticipantListOthersItem(
                  options: ParticipantListOthersItemOptions(
                    participant: participant,
                    coHost: options.coHost,
                    member: options.member,
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
