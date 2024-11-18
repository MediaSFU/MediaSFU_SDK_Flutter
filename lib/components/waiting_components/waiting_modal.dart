import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../methods/utils/get_modal_position.dart'
    show getModalPosition, GetModalPositionOptions;
import '../../methods/waiting_methods/respond_to_waiting.dart'
    show respondToWaiting, RespondToWaitingOptions;
import '../../types/types.dart'
    show WaitingRoomParticipant, RespondToWaitingType;

/// Additional parameters for the WaitingRoomModal.
abstract class WaitingRoomModalParameters {
  List<WaitingRoomParticipant> get filteredWaitingRoomList;

  /// Function to get updated parameters.
  WaitingRoomModalParameters Function() get getUpdatedAllParams;

  // dynamic operator [](String key);
}

/// Options for the WaitingRoomModal.
class WaitingRoomModalOptions {
  final bool isWaitingModalVisible;
  final VoidCallback onWaitingRoomClose;
  final int waitingRoomCounter;
  final Function(String) onWaitingRoomFilterChange;
  final List<WaitingRoomParticipant> waitingRoomList;
  final Function(List<WaitingRoomParticipant>) updateWaitingList;
  final String roomName;
  final io.Socket? socket;
  RespondToWaitingType onWaitingRoomItemPress;
  final String position; // e.g., "topRight"
  final Color backgroundColor;
  final WaitingRoomModalParameters parameters;

  WaitingRoomModalOptions({
    required this.isWaitingModalVisible,
    required this.onWaitingRoomClose,
    required this.waitingRoomCounter,
    required this.onWaitingRoomFilterChange,
    required this.waitingRoomList,
    required this.updateWaitingList,
    required this.roomName,
    this.socket,
    this.onWaitingRoomItemPress = respondToWaiting,
    this.position = "topRight",
    this.backgroundColor = const Color(0xFF83C0E9),
    required this.parameters,
  });
}

typedef WaitingRoomModalType = WaitingRoomModal Function({
  Key? key,
  required WaitingRoomModalOptions options,
});

/// A modal interface to manage participants in a waiting room, allowing hosts to accept or reject entries.
///
/// This modal displays a searchable list of participants in the waiting room.
/// Each participant can be accepted or rejected through corresponding buttons.
/// The modal also updates dynamically with any changes in the waiting room list.
///
/// ### Parameters:
/// - [options] (`WaitingRoomModalOptions`): Contains configurable properties such as the waiting room list, counter, visibility status,
///   and callback functions for accepting/rejecting participants and handling list changes.
///
/// ### Example usage:
/// ```dart
/// WaitingRoomModal(
///   options: WaitingRoomModalOptions(
///     waitingRoomList: [
///       WaitingRoomParticipant(id: '1', name: 'John Doe'),
///       WaitingRoomParticipant(id: '2', name: 'Jane Smith'),
///     ],
///     waitingRoomCounter: 2,
///     isWaitingModalVisible: true,
///     onWaitingRoomClose: () => print("Modal closed"),
///     onWaitingRoomItemPress: (parameters) async {
///       final participantId = parameters.participantId;
///       final accepted = parameters.type;
///       print("Participant $participantId ${accepted ? 'accepted' : 'rejected'}");
///     },
///     onWaitingRoomFilterChange: (query) => print("Filter changed: $query"),
///     roomName: 'MeetingRoom123',
///     socket: socket,
///     updateWaitingList: () => print("Waiting list updated"),
///   ),
/// )
/// ```
///
/// ### Functional Details:
/// - The `filterWaitingRoomList` method filters participants by a search query.
/// - `getModalTopPosition` and `getModalRightPosition` calculate positioning based on the `position` parameter in [options].
/// - Handles list updates dynamically and reflects changes in the counter displayed on the modal header.

class WaitingRoomModal extends StatefulWidget {
  final WaitingRoomModalOptions options;

  const WaitingRoomModal({super.key, required this.options});

  @override
  _WaitingRoomModalState createState() => _WaitingRoomModalState();
}

class _WaitingRoomModalState extends State<WaitingRoomModal> {
  late List<WaitingRoomParticipant> waitingRoomList;
  late int waitingRoomCounter;
  late bool isMessagesModalVisible;
  late String searchQuery;

  @override
  void initState() {
    super.initState();
    waitingRoomList = widget.options.waitingRoomList;
    waitingRoomCounter = widget.options.waitingRoomCounter;
    isMessagesModalVisible = widget.options.isWaitingModalVisible;
    searchQuery = '';
  }

  @override
  void didUpdateWidget(covariant WaitingRoomModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.options.waitingRoomList != widget.options.waitingRoomList) {
      setState(() {
        waitingRoomList = widget.options.waitingRoomList;
        waitingRoomCounter = waitingRoomList.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine modal width based on screen size
    double screenWidth = MediaQuery.of(context).size.width;
    double modalWidth = 0.8 * screenWidth;
    if (modalWidth > 350) {
      modalWidth = 350;
    }

    final modalHeight = MediaQuery.of(context).size.height * 0.65;

    return Visibility(
      visible: widget.options.isWaitingModalVisible,
      child: Stack(
        children: [
          // Modal Content
          Positioned(
            top: getModalPosition(GetModalPositionOptions(
                position: widget.options.position,
                context: context,
                modalWidth: modalWidth,
                modalHeight: modalHeight))['top'],
            right: getModalPosition(GetModalPositionOptions(
                position: widget.options.position,
                context: context,
                modalWidth: modalWidth,
                modalHeight: modalHeight))['right'],
            child: Container(
              width: modalWidth,
              height: modalHeight,
              decoration: BoxDecoration(
                color: widget.options.backgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.65,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Waiting $waitingRoomCounter',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: widget.options.onWaitingRoomClose,
                        icon: const Icon(Icons.close),
                        color: Colors.black,
                      ),
                    ],
                  ),
                  const Divider(
                    height: 1,
                    color: Colors.black,
                  ),
                  // Search Input
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search ...',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: widget.options.onWaitingRoomFilterChange,
                    ),
                  ),
                  // Participants List
                  Expanded(
                    child: ListView.builder(
                      itemCount: waitingRoomList.length,
                      itemBuilder: (BuildContext context, int index) {
                        final participant = waitingRoomList[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: Text(
                                  participant.name,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: IconButton(
                                  onPressed: () async {
                                    await widget.options.onWaitingRoomItemPress(
                                      options: RespondToWaitingOptions(
                                        participantId: participant.id,
                                        participantName: participant.name,
                                        updateWaitingList:
                                            widget.options.updateWaitingList,
                                        waitingList:
                                            widget.options.waitingRoomList,
                                        roomName: widget.options.roomName,
                                        socket: widget.options.socket,
                                        type: true, // accepted
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: IconButton(
                                  onPressed: () async {
                                    await widget.options.onWaitingRoomItemPress(
                                      options: RespondToWaitingOptions(
                                        participantId: participant.id,
                                        participantName: participant.name,
                                        updateWaitingList:
                                            widget.options.updateWaitingList,
                                        waitingList:
                                            widget.options.waitingRoomList,
                                        roomName: widget.options.roomName,
                                        socket: widget.options.socket,
                                        type: false, // rejected
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                              const Expanded(
                                flex: 1,
                                child: SizedBox(), // Spacer
                              ),
                            ],
                          ),
                        );
                      },
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
