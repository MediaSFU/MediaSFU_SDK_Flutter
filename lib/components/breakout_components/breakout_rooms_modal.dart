import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../methods/utils/get_modal_position.dart' show getModalPosition;

typedef ShowAlert = void Function({
  required String message,
  required String type,
  required int duration,
});

class RoomList extends StatelessWidget {
  final List<dynamic> rooms;
  final Function(int) handleEditRoom;
  final Function(int) handleDeleteRoom;
  final Function(int, dynamic) handleRemoveParticipant;
  final Function(int, dynamic) handleAddParticipant;
  final List<dynamic> participantsRef;

  const RoomList({
    super.key,
    required this.rooms,
    required this.handleEditRoom,
    required this.handleDeleteRoom,
    required this.handleRemoveParticipant,
    required this.handleAddParticipant,
    required this.participantsRef,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rooms.length,
      itemBuilder: (context, roomIndex) {
        return Card(
          child: Column(
            children: [
              ListTile(
                title: Text('Room ${roomIndex + 1}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(FontAwesomeIcons.pen),
                      onPressed: () => handleEditRoom(roomIndex),
                    ),
                    IconButton(
                      icon: const Icon(FontAwesomeIcons.xmark),
                      onPressed: () => handleDeleteRoom(roomIndex),
                    ),
                  ],
                ),
              ),
              ...rooms[roomIndex].map((participant) {
                return ListTile(
                  title: Text(participant['name']),
                  trailing: IconButton(
                    icon: const Icon(FontAwesomeIcons.xmark),
                    onPressed: () =>
                        handleRemoveParticipant(roomIndex, participant),
                  ),
                );
              }),
              if (rooms[roomIndex].isEmpty)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'None Assigned',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class EditRoomModal extends StatelessWidget {
  final ValueNotifier<bool> editRoomModalVisible;
  final Function(bool) updateEditRoomModalVisible;
  final List<dynamic> currentRoom;
  final List<dynamic> participantsRef;
  final Function(int, dynamic) handleAddParticipant;
  final Function(int, dynamic) handleRemoveParticipant;
  final int currentRoomIndex;
  final Color backgroundColor;

  const EditRoomModal({
    super.key,
    required this.editRoomModalVisible,
    required this.updateEditRoomModalVisible,
    required this.currentRoom,
    required this.participantsRef,
    required this.handleAddParticipant,
    required this.handleRemoveParticipant,
    required this.currentRoomIndex,
    this.backgroundColor = const Color.fromARGB(255, 187, 195, 199),
  });

  @override
  Widget build(BuildContext context) {
    final double modalWidth = 0.8 * MediaQuery.of(context).size.width > 500
        ? 500
        : 0.8 * MediaQuery.of(context).size.width;
    final modalHeight = MediaQuery.of(context).size.height * 0.7;

    return ValueListenableBuilder<bool>(
      valueListenable: editRoomModalVisible,
      builder: (context, value, child) {
        return Visibility(
          visible: value,
          child: Center(
            child: SizedBox(
              width: modalWidth,
              height: modalHeight,
              child: Dialog(
                child: Container(
                  width: modalWidth,
                  height: modalHeight,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: Text('Edit Room ${currentRoomIndex + 1}'),
                        trailing: IconButton(
                          icon: const Icon(FontAwesomeIcons.xmark),
                          onPressed: () => updateEditRoomModalVisible(false),
                        ),
                      ),
                      const Divider(),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              const ListTile(
                                title: Text(
                                  'Assigned Participants',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              ...currentRoom.map((participant) {
                                return ListTile(
                                  title: Row(
                                    children: [
                                      const Icon(FontAwesomeIcons.user),
                                      const SizedBox(width: 10),
                                      Text(participant['name']),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(FontAwesomeIcons.xmark),
                                    onPressed: () => handleRemoveParticipant(
                                        currentRoomIndex, participant),
                                  ),
                                );
                              }),
                              if (currentRoom.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'None Assigned',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              const Divider(),
                              const ListTile(
                                title: Text(
                                  'Unassigned Participants',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              ...participantsRef
                                  .where((participant) =>
                                      participant['breakRoom'] == null)
                                  .map((participant) {
                                return ListTile(
                                  title: Row(
                                    children: [
                                      const Icon(FontAwesomeIcons.user),
                                      const SizedBox(width: 10),
                                      Text(participant['name']),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(FontAwesomeIcons.plus),
                                    onPressed: () => handleAddParticipant(
                                        currentRoomIndex, participant),
                                  ),
                                );
                              }),
                              if (participantsRef
                                  .where((participant) =>
                                      participant['breakRoom'] == null)
                                  .isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'None Pending',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class BreakoutRoomsModal extends StatefulWidget {
  final bool isVisible;
  final VoidCallback onBreakoutRoomsClose;
  final Map<String, dynamic> parameters;
  final String position;
  final Color backgroundColor;

  const BreakoutRoomsModal({
    super.key,
    required this.isVisible,
    required this.onBreakoutRoomsClose,
    required this.parameters,
    this.position = 'topRight',
    this.backgroundColor = const Color(0xFF83C0E9),
  });

  @override
  // ignore: library_private_types_in_public_api
  _BreakoutRoomsModalState createState() => _BreakoutRoomsModalState();
}

class _BreakoutRoomsModalState extends State<BreakoutRoomsModal> {
  late List<dynamic> participants;
  late List<dynamic> breakoutRooms;
  late int currentRoomIndex;
  ValueNotifier<bool> editRoomModalVisible = ValueNotifier(false);
  late List<dynamic> currentRoom;
  late TextEditingController numRoomsController;
  late ShowAlert showAlert;
  bool breakOutRoomStarted = false;
  bool breakOutRoomEnded = false;
  bool canStartBreakout = false;
  String newParticipantAction = 'autoAssignNewRoom';

  updateEditRoomModalVisible(bool value) {
    editRoomModalVisible.value = value;
  }

  @override
  void initState() {
    super.initState();
    participants = widget.parameters['participants']
        .where((participant) => participant['islevel'] != '2')
        .toList();
    breakoutRooms = widget.parameters['breakoutRooms'];
    showAlert = widget.parameters['showAlert'];
    breakOutRoomStarted = widget.parameters['breakOutRoomStarted'];
    breakOutRoomEnded = widget.parameters['breakOutRoomEnded'];
    canStartBreakout = widget.parameters['canStartBreakout'];
    currentRoomIndex = 0;
    currentRoom = [];
    numRoomsController = TextEditingController();
  }

  void handleEditRoom(int roomIndex) {
    setState(() {
      currentRoomIndex = roomIndex;
      currentRoom = breakoutRooms[roomIndex];
      editRoomModalVisible.value = true;
    });
  }

  void handleDeleteRoom(int roomIndex) {
    setState(() {
      breakoutRooms.removeAt(roomIndex);
      checkCanStartBreakout();
    });
  }

  void handleAddParticipant(int roomIndex, dynamic participant) {
    setState(() {
      breakoutRooms[roomIndex].add(participant);
      participants.firstWhere(
          (p) => p['name'] == participant['name'])['breakRoom'] = roomIndex;
      checkCanStartBreakout();
    });
  }

  void handleRemoveParticipant(int roomIndex, dynamic participant) {
    setState(() {
      breakoutRooms[roomIndex].remove(participant);
      participants.firstWhere(
          (p) => p['name'] == participant['name'])['breakRoom'] = null;
      checkCanStartBreakout();
    });
  }

  void handleRandomAssign() {
    int numRooms = int.tryParse(numRoomsController.text) ?? 0;
    if (numRooms <= 0) {
      showAlert(
        message: 'Please enter a valid number of rooms',
        type: 'danger',
        duration: 3000,
      );
      return;
    }

    List<dynamic> newBreakoutRooms = List.generate(numRooms, (_) => []);
    List<dynamic> shuffledParticipants = List.from(participants)..shuffle();

    for (int i = 0; i < shuffledParticipants.length; i++) {
      int roomIndex = i % numRooms;
      newBreakoutRooms[roomIndex].add(shuffledParticipants[i]);
      shuffledParticipants[i]['breakRoom'] = roomIndex;
    }

    setState(() {
      breakoutRooms = newBreakoutRooms;
    });

    showAlert(
      message: 'Participants assigned randomly to rooms',
      type: 'success',
      duration: 2000,
    );
    checkCanStartBreakout();
  }

  void handleManualAssign() {
    int numRooms = int.tryParse(numRoomsController.text) ?? 0;
    if (numRooms <= 0) {
      showAlert(
        message: 'Please enter a valid number of rooms',
        type: 'danger',
        duration: 3000,
      );
      return;
    }

    setState(() {
      breakoutRooms = List.generate(numRooms, (_) => []);
      checkCanStartBreakout();
    });

    showAlert(
      message: 'Rooms created for manual assignment',
      type: 'success',
      duration: 2000,
    );
  }

  void handleAddRoom() {
    setState(() {
      breakoutRooms.add([]);
      checkCanStartBreakout();
    });

    showAlert(
      message: 'New room added',
      type: 'success',
      duration: 3000,
    );
  }

  void handleSaveRooms() {
    if (validateRooms()) {
      widget.parameters['updateBreakoutRooms'](breakoutRooms);
      setState(() {
        canStartBreakout = true;
        widget.parameters['updateCanStartBreakout'](true);
      });
      showAlert(
        message: 'Rooms saved successfully',
        type: 'success',
        duration: 3000,
      );
    } else {
      // showAlert(
      //   message: 'Rooms validation failed',
      //   type: 'danger',
      //   duration: 3000,
      // );
    }
  }

  bool validateRooms() {
    if (breakoutRooms.isEmpty) {
      showAlert(
        message: 'There must be at least one room',
        type: 'danger',
        duration: 3000,
      );
      return false;
    }

    for (var room in breakoutRooms) {
      if (room.isEmpty) {
        showAlert(
          message: 'Rooms must not be empty',
          type: 'danger',
          duration: 3000,
        );
        return false;
      }

      final participantNames = room.map((p) => p['name']).toList();
      final uniqueNames = Set.from(participantNames);
      if (participantNames.length != uniqueNames.length) {
        showAlert(
          message: 'Duplicate participant names in a room',
          type: 'danger',
          duration: 3000,
        );
        return false;
      }

      if (room.length > widget.parameters['itemPageLimit']) {
        showAlert(
          message: 'A room exceeds the participant limit',
          type: 'danger',
          duration: 3000,
        );
        return false;
      }
    }

    return true;
  }

  void checkCanStartBreakout() {
    if (validateRooms()) {
      setState(() {
        canStartBreakout = true;
      });
    } else {
      setState(() {
        canStartBreakout = false;
      });
    }
  }

  void handleStartBreakout() {
    if (widget.parameters['shareScreenStarted'] ||
        widget.parameters['shared']) {
      showAlert(
        message:
            'You cannot start breakout rooms while screen sharing is active',
        type: 'danger',
        duration: 3000,
      );
      return;
    }

    if (canStartBreakout) {
      final emitName = breakOutRoomStarted && !breakOutRoomEnded
          ? 'updateBreakout'
          : 'startBreakout';
      final filteredBreakoutRooms = breakoutRooms
          .map((room) => room
              .map((p) => {'name': p['name'], 'breakRoom': p['breakRoom']})
              .toList())
          .toList();
      widget.parameters['socket'].emitWithAck(emitName, {
        'breakoutRooms': filteredBreakoutRooms,
        'newParticipantAction': newParticipantAction,
        'roomName': widget.parameters['roomName'],
      }, ack: (response) {
        if (response['success']) {
          showAlert(
            message: 'Breakout rooms active',
            type: 'success',
            duration: 3000,
          );
          widget.parameters['updateBreakOutRoomStarted'](true);
          widget.parameters['updateBreakOutRoomEnded'](false);
          widget.onBreakoutRoomsClose();
        } else {
          showAlert(
            message: response['reason'],
            type: 'danger',
            duration: 3000,
          );
        }
      });
    }
  }

  void handleStopBreakout() {
    widget.parameters['socket'].emitWithAck('stopBreakout', {
      'roomName': widget.parameters['roomName'],
    }, ack: (response) {
      if (response['success']) {
        showAlert(
          message: 'Breakout rooms stopped',
          type: 'success',
          duration: 3000,
        );
        widget.parameters['updateBreakOutRoomStarted'](false);
        widget.parameters['updateBreakOutRoomEnded'](true);
        widget.onBreakoutRoomsClose();
      } else {
        showAlert(
          message: response['reason'],
          type: 'danger',
          duration: 3000,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double modalWidth = 0.9 * MediaQuery.of(context).size.width > 600
        ? 600
        : 0.9 * MediaQuery.of(context).size.width;
    final modalHeight = MediaQuery.of(context).size.height * 0.7;
    return Visibility(
      visible: widget.isVisible,
      child: Stack(
        children: [
          Positioned(
            top: getModalPosition(
                widget.position, context, modalWidth, modalHeight)['top'],
            right: getModalPosition(
                widget.position, context, modalWidth, modalHeight)['right'],
            child: Container(
              width: modalWidth,
              height: modalHeight,
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Dialog(
                insetPadding: const EdgeInsets.all(20),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.8,
                  decoration: BoxDecoration(
                    color: widget.backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: const Text(
                          'Breakout Rooms',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        trailing: IconButton(
                          icon: const FaIcon(FontAwesomeIcons.xmark),
                          onPressed: widget.onBreakoutRoomsClose,
                        ),
                      ),
                      const Divider(),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Number of Rooms',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextField(
                                      controller: numRoomsController,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: 'Enter number of rooms',
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      ElevatedButton(
                                        onPressed: handleRandomAssign,
                                        child: const Row(
                                          children: [
                                            Icon(FontAwesomeIcons.shuffle),
                                            SizedBox(width: 2),
                                            Text('Random'),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      ElevatedButton(
                                        onPressed: handleManualAssign,
                                        child: const Row(
                                          children: [
                                            Icon(FontAwesomeIcons.handPointer),
                                            SizedBox(width: 5),
                                            Text('Manual'),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      ElevatedButton(
                                        onPressed: handleAddRoom,
                                        child: const Row(
                                          children: [
                                            Icon(FontAwesomeIcons.plus),
                                            SizedBox(width: 2),
                                            Text('Add Room'),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      ElevatedButton(
                                        onPressed: handleSaveRooms,
                                        child: const Row(
                                          children: [
                                            Icon(FontAwesomeIcons.floppyDisk),
                                            SizedBox(width: 2),
                                            Text('Save Rooms'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'New Participant Action',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    DropdownButton<String>(
                                      value: newParticipantAction,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          newParticipantAction = newValue!;
                                        });
                                      },
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'autoAssignNewRoom',
                                          child: Text('Add to new room'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'autoAssignAvailableRoom',
                                          child: Text('Add to open room'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'manualAssign',
                                          child: Text('No action'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Divider(),
                              // Adding the EditRoomModal here
                              EditRoomModal(
                                editRoomModalVisible: editRoomModalVisible,
                                updateEditRoomModalVisible:
                                    updateEditRoomModalVisible,
                                currentRoom: currentRoom,
                                participantsRef: participants,
                                handleAddParticipant: handleAddParticipant,
                                handleRemoveParticipant:
                                    handleRemoveParticipant,
                                currentRoomIndex: currentRoomIndex,
                              ),

                              const SizedBox(height: 10),
                              RoomList(
                                rooms: breakoutRooms,
                                handleEditRoom: handleEditRoom,
                                handleDeleteRoom: handleDeleteRoom,
                                handleRemoveParticipant:
                                    handleRemoveParticipant,
                                handleAddParticipant: handleAddParticipant,
                                participantsRef: participants,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    if ((!breakOutRoomStarted ||
                                            breakOutRoomEnded) &&
                                        canStartBreakout)
                                      ElevatedButton(
                                        onPressed: handleStartBreakout,
                                        child: const Row(
                                          children: [
                                            Icon(FontAwesomeIcons.play),
                                            SizedBox(width: 5),
                                            Text('Start Breakout'),
                                          ],
                                        ),
                                      ),
                                    if (breakOutRoomStarted &&
                                        !breakOutRoomEnded &&
                                        canStartBreakout)
                                      ElevatedButton(
                                        onPressed: handleStartBreakout,
                                        child: const Row(
                                          children: [
                                            Icon(FontAwesomeIcons.arrowsRotate),
                                            SizedBox(width: 5),
                                            Text('Update Breakout'),
                                          ],
                                        ),
                                      ),
                                    if (breakOutRoomStarted &&
                                        !breakOutRoomEnded)
                                      ElevatedButton(
                                        onPressed: handleStopBreakout,
                                        child: const Row(
                                          children: [
                                            Icon(FontAwesomeIcons.stop),
                                            SizedBox(width: 5),
                                            Text('Stop Breakout'),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
