import 'package:flutter/material.dart';
import './participant_list_item.dart' show ParticipantListItem;

/// ParticipantList - Displays a list of participants in a scrollable view.
///
/// participants - A list of dynamic containing information about each participant.
///
/// isBroadcast - A boolean indicating whether the participant list is for a broadcast event.
///
/// onMuteParticipants - A function to handle muting/unmuting participants.
///
/// onMessageParticipants - A function to handle messaging participants.
///
/// onRemoveParticipants - A function to handle removing participants.
///
/// formatBroadcastViews - A function to format the number of views for a broadcast event.
///
/// parameters - Additional parameters such as member, co-host, and islevel for displaying participant details.

class ParticipantList extends StatelessWidget {
  final List<dynamic> participants;
  final bool isBroadcast;
  final Future<void> Function({required Map<String, dynamic> parameters})
      onMuteParticipants;
  final void Function({
    required Map<String, dynamic> parameters,
  }) onMessageParticipants;
  final Future<void> Function({
    required Map<String, dynamic> parameters,
  }) onRemoveParticipants;
  final Function(int) formatBroadcastViews;
  final Map<String, dynamic> parameters;

  const ParticipantList({
    super.key,
    required this.participants,
    required this.isBroadcast,
    required this.onMuteParticipants,
    required this.onMessageParticipants,
    required this.onRemoveParticipants,
    required this.formatBroadcastViews,
    required this.parameters,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: List.generate(
          participants.length,
          (index) {
            return Column(
              children: [
                ParticipantListItem(
                  participant: participants[index],
                  isBroadcast: isBroadcast,
                  onMuteParticipants: onMuteParticipants,
                  onMessageParticipants: onMessageParticipants,
                  onRemoveParticipants: onRemoveParticipants,
                  formatBroadcastViews: formatBroadcastViews,
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
