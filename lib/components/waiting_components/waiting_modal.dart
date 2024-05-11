import 'package:flutter/material.dart';
import '../../methods/utils/get_modal_position.dart' show getModalPosition;
import '../../methods/waiting_methods/respond_to_waiting.dart'
    show respondToWaiting;

/// WaitingRoomModal is a StatelessWidget that displays a modal for managing participants in a waiting room.
///
/// `isWaitingModalVisible`: Flag to control the visibility of the modal.
/// `onWaitingRoomClose`: Callback function to close the modal.
/// `waitingRoomCounter`: Counter for the number of participants in the waiting room.
/// `onWaitingRoomFilterChange`: Callback function for filtering participants.
/// `waitingRoomList`: List of participants in the waiting room.
/// `updateWaitingList`: Function to update the list of participants.
/// `roomName`: The name of the room.
/// `socket`: Socket for communication.
/// `onWaitingRoomItemPress`: Function to handle pressing actions on a waiting room participant.
/// `position`: Position of the modal.
/// `backgroundColor`: Background color of the modal.
/// `parameters`: Additional parameters.

class WaitingRoomModal extends StatelessWidget {
  final bool isWaitingModalVisible;
  final Function() onWaitingRoomClose;
  final int waitingRoomCounter;
  final Function(String) onWaitingRoomFilterChange;
  final List<dynamic> waitingRoomList;
  final void Function(List<dynamic>) updateWaitingList;
  final String roomName;
  final dynamic socket;
  final Future<void> Function({required Map<String, dynamic> parameters})
      onWaitingRoomItemPress;
  final String position;
  final Color backgroundColor;
  final Map<String, dynamic> parameters;

  const WaitingRoomModal({
    super.key,
    required this.isWaitingModalVisible,
    required this.onWaitingRoomClose,
    required this.waitingRoomCounter,
    required this.onWaitingRoomFilterChange,
    required this.waitingRoomList,
    required this.updateWaitingList,
    required this.roomName,
    required this.socket,
    this.onWaitingRoomItemPress = respondToWaiting,
    this.position = 'topRight',
    this.backgroundColor = const Color(0xFF83C0E9),
    required this.parameters,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double modalWidth = 0.8 * screenWidth;
    if (modalWidth > 400) {
      modalWidth = 400;
    }

    final modalHeight = MediaQuery.of(context).size.height * 0.65;

    return Visibility(
      visible: isWaitingModalVisible,
      child: Stack(
        children: [
          Positioned(
            top: getModalPosition(
                position, context, modalWidth, modalHeight)['top'],
            right: getModalPosition(
                position, context, modalWidth, modalHeight)['right'],
            child: Container(
              width: modalWidth,
              height: modalHeight,
              color: backgroundColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        onPressed: onWaitingRoomClose,
                        icon: const Icon(Icons.close),
                        color: Colors.black,
                      ),
                    ],
                  ),
                  const Divider(
                    height: 1,
                    color: Colors.black,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search ...',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: onWaitingRoomFilterChange,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: waitingRoomList.length,
                      itemBuilder: (BuildContext context, int index) {
                        final participant = waitingRoomList[index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: Text(participant['name']),
                              ),
                              Expanded(
                                flex: 2,
                                child: IconButton(
                                  onPressed: () =>
                                      onWaitingRoomItemPress(parameters: {
                                    'participantId': participant['id'],
                                    'participantName': participant['name'],
                                    'waiting': participant,
                                    'updateWaitingList': updateWaitingList,
                                    'waitingList': waitingRoomList,
                                    'roomName': roomName,
                                    'type': true, //accepted
                                    'socket': socket,
                                  }),
                                  icon: const Icon(Icons.check,
                                      size: 24, color: Colors.green),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: IconButton(
                                  onPressed: () => onWaitingRoomItemPress(
                                    parameters: {
                                      'participantId': participant['id'],
                                      'participantName': participant['name'],
                                      'waiting': participant,
                                      'updateWaitingList': updateWaitingList,
                                      'waitingList': waitingRoomList,
                                      'roomName': roomName,
                                      'type': false, //rejected
                                      'socket': socket,
                                    },
                                  ),
                                  icon: const Icon(Icons.close,
                                      size: 24, color: Colors.red),
                                ),
                              ),
                              const Expanded(
                                  flex: 1, child: SizedBox()), // Spacer
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
