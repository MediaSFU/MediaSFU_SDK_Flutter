import 'package:flutter/material.dart';
import './participant_list_others_item.dart' show ParticipantListOthersItem;

/// ParticipantListOthers - Displays a list of other participants (not the current user) in a scrollable view.
///
/// participants - A list of dynamic containing information about each participant.
///
/// parameters - Additional parameters such as member, co-host, and islevel for displaying participant details.

class ParticipantListOthers extends StatelessWidget {
  final List<dynamic> participants;
  final Map<String, dynamic> parameters;

  const ParticipantListOthers(
      {super.key, required this.participants, required this.parameters});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: List.generate(
          participants.length,
          (index) {
            return Column(
              children: [
                ParticipantListOthersItem(
                  participant: participants[index],
                  parameters: parameters,
                ),
                if (index < participants.length - 1)
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
