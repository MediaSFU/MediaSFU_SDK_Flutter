// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';
import '../../methods/utils/get_modal_position.dart' show getModalPosition;
import './participant_list.dart' show ParticipantList;
import './participant_list_others.dart' show ParticipantListOthers;
import '../../methods/participants_methods/mute_participants.dart'
    show muteParticipants;
import '../../methods/participants_methods/message_participants.dart'
    show messageParticipants;
import '../../methods/participants_methods/remove_participants.dart'
    show removeParticipants;
import '../../methods/utils/format_number.dart' show formatNumber;

/// ParticipantsModal - Displays a modal for managing participants.
///
/// isParticipantsModalVisible - A boolean indicating whether the participants modal is visible.
///
/// onParticipantsClose - A callback function invoked when closing the participants modal.
///
/// onParticipantsFilterChange - A function to handle filtering participants based on user input.
///
/// participantsCounter - An integer representing the number of participants.
///
/// onMuteParticipants - A function to handle muting/unmuting participants.
///
/// onMessageParticipants - A function to handle messaging participants.
///
/// onRemoveParticipants - A function to handle removing participants.
///
/// RenderParticipantList - A function that renders the participant list widget.
///
/// RenderParticipantListOthers - A function that renders the participant list for others widget.
///
/// formatBroadcastViews - A function to format the number of views for a broadcast event.
///
/// parameters - Additional parameters such as co-host responsibility, co-host, member, islevel, participants, and event type.
///
/// position - The position of the modal ('topRight' by default).
///
/// backgroundColor - The background color of the modal (default color: 0xFF83C0E9).

typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

class ParticipantsModal extends StatelessWidget {
  final bool isParticipantsModalVisible;
  final VoidCallback onParticipantsClose;
  final ValueChanged<String> onParticipantsFilterChange;
  final int participantsCounter;
  final Future<void> Function({required Map<String, dynamic> parameters})
      onMuteParticipants; // Adjusted function signature
  final void Function({
    required Map<String, dynamic> parameters,
  }) onMessageParticipants;
  final Future<void> Function({required Map<String, dynamic> parameters})
      onRemoveParticipants; // Adjusted function signature
  final Widget Function(Map<String, dynamic> parameters) RenderParticipantList;
  final Widget Function(Map<String, dynamic> parameters)
      RenderParticipantListOthers;
  final Function(int) formatBroadcastViews;
  final Map<String, dynamic> parameters;
  final String position;
  final Color backgroundColor;

  // ignore: prefer_const_constructors_in_immutables
  ParticipantsModal({
    super.key,
    required this.isParticipantsModalVisible,
    required this.onParticipantsClose,
    required this.onParticipantsFilterChange,
    required this.participantsCounter,
    this.onMuteParticipants = muteParticipants,
    this.onMessageParticipants = messageParticipants,
    this.onRemoveParticipants = removeParticipants,
    this.RenderParticipantList = defaultParticipantList,
    this.RenderParticipantListOthers = defaultParticipantListOthers,
    this.formatBroadcastViews = formatNumber,
    required this.parameters,
    this.position = 'topRight',
    this.backgroundColor = const Color(0xFF83C0E9),
  });

  // Default function for rendering participant list
  static Widget defaultParticipantList(Map<String, dynamic> parameters) {
    return ParticipantList(
      participants: parameters['participants'],
      isBroadcast: parameters['eventType'] == 'broadcast',
      onMuteParticipants: parameters['onMuteParticipants'],
      onMessageParticipants: parameters['onMessageParticipants'],
      onRemoveParticipants: parameters['onRemoveParticipants'],
      formatBroadcastViews: parameters['formatBroadcastViews'],
      parameters: parameters['parameters'],
    );
  }

  // Default function for rendering participant list others
  static Widget defaultParticipantListOthers(dynamic parameters) {
    return ParticipantListOthers(
      participants: parameters['participants'],
      parameters: parameters['parameters'],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Assign parameters here
    final coHostResponsibility = parameters['coHostResponsibility'] ?? [];
    final coHost = parameters['coHost'] ?? '';
    final member = parameters['member'] ?? '';
    final islevel = parameters['islevel'] ?? '1';
    final participants = parameters['participants'] ?? [];
    final eventType = parameters['eventType'] ?? '';

    final screenWidth = MediaQuery.of(context).size.width;
    var modalWidth = 0.8 * screenWidth;
    if (modalWidth > 400) {
      modalWidth = 400;
    }
    final modalHeight = MediaQuery.of(context).size.height * 0.65;

    bool participantsValue = false;
    try {
      var participantItem = coHostResponsibility.firstWhere(
          (item) => item['name'] == 'participants',
          orElse: () => null);

      if (participantItem != null) {
        participantsValue = participantItem['value'] ?? false;
      }
    } catch (error) {
      // Handle error if needed
    }

    return Visibility(
      visible: isParticipantsModalVisible,
      child: Stack(
        children: [
          Positioned(
            top: getModalPosition(
                position, context, modalWidth, modalHeight)['top'],
            right: getModalPosition(
                position, context, modalWidth, modalHeight)['right'],
            child: AnimatedContainer(
              width: modalWidth,
              height: modalHeight,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(milliseconds: 300),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Participants ($participantsCounter)',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: onParticipantsClose,
                        color: Colors.black,
                      ),
                    ],
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search ...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 10.0),
                      ),
                      onChanged: onParticipantsFilterChange,
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .stretch, // Ensure the children of the Column stretch horizontally
                        children: [
                          if (participants.isNotEmpty &&
                              (islevel == '2' ||
                                  (coHost == member &&
                                      participantsValue ==
                                          true))) // Check participantsValue
                            RenderParticipantList({
                              'participants': participants,
                              'eventType': eventType,
                              'onMuteParticipants': onMuteParticipants,
                              'onMessageParticipants': onMessageParticipants,
                              'onRemoveParticipants': onRemoveParticipants,
                              'formatBroadcastViews': formatBroadcastViews,
                              'parameters': parameters,
                            })
                          else if (parameters['participants'] != null)
                            RenderParticipantListOthers({
                              'participants': participants,
                              'parameters': parameters,
                            })
                          else
                            const Text('No participants'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
