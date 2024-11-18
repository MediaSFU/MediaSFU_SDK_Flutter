// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../methods/utils/get_modal_position.dart'
    show getModalPosition, GetModalPositionOptions;
import './participant_list.dart'
    show ParticipantList, ParticipantListOptions, ParticipantListType;
import './participant_list_others.dart'
    show
        ParticipantListOthers,
        ParticipantListOthersOptions,
        ParticipantListOthersType;
import '../../methods/participants_methods/mute_participants.dart'
    show muteParticipants;
import '../../methods/participants_methods/message_participants.dart'
    show messageParticipants;
import '../../methods/participants_methods/remove_participants.dart'
    show removeParticipants;
import '../../types/types.dart'
    show
        ShowAlert,
        CoHostResponsibility,
        Participant,
        MuteParticipantsType,
        MessageParticipantsType,
        RemoveParticipantsType,
        EventType;

abstract class ParticipantsModalParameters {
  // Core properties as abstract getters
  List<CoHostResponsibility> get coHostResponsibility;
  String get coHost;
  String get member;
  String get islevel;
  List<Participant> get participants;
  EventType get eventType;
  io.Socket? get socket;
  ShowAlert? get showAlert;
  String get roomName;

  // Update functions as abstract getters returning functions
  void Function(bool) get updateIsMessagesModalVisible;
  void Function(Participant?) get updateDirectMessageDetails;
  void Function(bool) get updateStartDirectMessage;
  void Function(List<Participant>) get updateParticipants;

  // Method to retrieve updated parameters as an abstract getter
  ParticipantsModalParameters Function() get getUpdatedAllParams;

  // dynamic operator [](String key);
}

class ParticipantsModalOptions {
  final bool isParticipantsModalVisible;
  final VoidCallback onParticipantsClose;
  final ValueChanged<String> onParticipantsFilterChange;
  final int participantsCounter;
  final MuteParticipantsType onMuteParticipants;
  final MessageParticipantsType onMessageParticipants;
  final RemoveParticipantsType onRemoveParticipants;
  final ParticipantListType RenderParticipantList;
  final ParticipantListOthersType RenderParticipantListOthers;
  final Color backgroundColor;
  final String position;
  final ParticipantsModalParameters parameters;

  ParticipantsModalOptions({
    required this.isParticipantsModalVisible,
    required this.onParticipantsClose,
    required this.onParticipantsFilterChange,
    required this.participantsCounter,
    this.onMuteParticipants = muteParticipants,
    this.onMessageParticipants = messageParticipants,
    this.onRemoveParticipants = removeParticipants,
    this.RenderParticipantList = defaultParticipantList,
    this.RenderParticipantListOthers = defaultParticipantListOthers,
    this.backgroundColor = const Color(0xFF83C0E9),
    this.position = 'topRight',
    required this.parameters,
  });

  // Default function for rendering participant list
  static Widget defaultParticipantList(
      {required ParticipantListOptions options}) {
    return ParticipantList(options: options);
  }

  // Default function for rendering participant list for others
  static Widget defaultParticipantListOthers(
      {required ParticipantListOthersOptions options}) {
    return ParticipantListOthers(options: options);
  }
}

typedef ParticipantsModalType = Widget Function(
    {required ParticipantsModalOptions options});

/// `ParticipantsModal` is a widget that displays a modal for managing participants in an event.
/// It allows users to filter, mute, message, or remove participants depending on their permissions.
///
/// ### Parameters:
/// - `options` (`ParticipantsModalOptions`): Configuration options for the modal, including visibility, filtering, and action callbacks.
///
/// ### Example Usage:
/// ```dart
/// ParticipantsModal(
///   options: ParticipantsModalOptions(
///     isParticipantsModalVisible: true,
///     onParticipantsClose: () => print("Modal closed"),
///     onParticipantsFilterChange: (filter) => print("Filter: $filter"),
///     participantsCounter: 10,
///     parameters: myParticipantsModalParameters,
///   ),
/// );
/// ```
///
/// The modal adjusts its width based on screen size, displays a search field for participant filtering,
/// and uses different components to render participants based on their roles and access levels.

class ParticipantsModal extends StatelessWidget {
  final ParticipantsModalOptions options;

  const ParticipantsModal({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double modalWidth = 0.8 * screenWidth;
    if (modalWidth > 400) {
      modalWidth = 400;
    }
    final modalHeight = MediaQuery.of(context).size.height * 0.75;
    final participants = options.parameters.participants;
    final islevel = options.parameters.islevel;
    final coHost = options.parameters.coHost;
    final member = options.parameters.member;
    final participantsValue = options.parameters.coHostResponsibility
        .any((item) => item.name == 'participants' && item.value);

    return Visibility(
      visible: options.isParticipantsModalVisible,
      child: Stack(
        children: [
          Positioned(
            top: getModalPosition(GetModalPositionOptions(
              position: options.position,
              modalWidth: modalWidth,
              modalHeight: modalHeight,
              context: context,
            ))['top'],
            right: getModalPosition(GetModalPositionOptions(
              position: options.position,
              modalWidth: modalWidth,
              modalHeight: modalHeight,
              context: context,
            ))['right'],
            child: Container(
              width: modalWidth,
              height: modalHeight,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: options.backgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Participants (${options.participantsCounter})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: options.onParticipantsClose,
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
                      onChanged: options.onParticipantsFilterChange,
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
                                  (coHost == member && participantsValue)))
                            options.RenderParticipantList(
                              options: ParticipantListOptions(
                                participants: participants,
                                isBroadcast: options.parameters.eventType ==
                                    EventType.broadcast,
                                onMuteParticipants: options.onMuteParticipants,
                                onMessageParticipants:
                                    options.onMessageParticipants,
                                onRemoveParticipants:
                                    options.onRemoveParticipants,
                                socket: options.parameters.socket,
                                coHostResponsibility:
                                    options.parameters.coHostResponsibility,
                                member: options.parameters.member,
                                islevel: options.parameters.islevel,
                                showAlert: options.parameters.showAlert,
                                coHost: options.parameters.coHost,
                                roomName: options.parameters.roomName,
                                updateIsMessagesModalVisible: options
                                    .parameters.updateIsMessagesModalVisible,
                                updateDirectMessageDetails: options
                                    .parameters.updateDirectMessageDetails,
                                updateStartDirectMessage:
                                    options.parameters.updateStartDirectMessage,
                                updateParticipants:
                                    options.parameters.updateParticipants,
                              ),
                            )
                          else if (participants.isNotEmpty)
                            options.RenderParticipantListOthers(
                                options: ParticipantListOthersOptions(
                                    participants: participants,
                                    coHost: coHost,
                                    member: member))
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
