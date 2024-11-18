import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../methods/utils/get_modal_position.dart'
    show getModalPosition, GetModalPositionOptions;
import '../../types/types.dart'
    show BreakoutParticipant, Participant, ShowAlert;

typedef BreakoutRoom = List<BreakoutParticipant>;

/// Configuration options for managing a room's participant list, edit, and delete actions.
///
/// ### Example Usage:
/// ```dart
/// final roomOptions = RoomOptions(
///   rooms: rooms,
///   handleEditRoom: (index) => editRoom(index),
///   handleDeleteRoom: (index) => deleteRoom(index),
///   handleRemoveParticipant: (index, participant) => removeParticipant(index, participant),
/// );
/// ```
class RoomOptions {
  /// List of breakout participants in the room.
  final List<List<BreakoutParticipant>> rooms;

  /// Callback to handle editing a room.
  final void Function(int roomIndex) handleEditRoom;

  /// Callback to handle deleting a room.
  final void Function(int roomIndex) handleDeleteRoom;

  /// Callback to handle removing a participant from a room.
  final void Function(int roomIndex, BreakoutParticipant participant)
      handleRemoveParticipant;

  RoomOptions({
    required this.rooms,
    required this.handleEditRoom,
    required this.handleDeleteRoom,
    required this.handleRemoveParticipant,
  });
}

/// Options for configuring the `EditRoomModal` widget.
///
/// This allows control over the modal's visibility, current room index,
/// assigned/unassigned participants, and room participant management.
///
/// ### Example Usage:
/// ```dart
/// final options = EditRoomModalOptions(
///   editRoomModalVisible: ValueNotifier(false),
///   updateEditRoomModalVisible: (visible) => toggleEditModal(visible),
///   currentRoom: currentRoomParticipants,
///   participantsRef: participantsList,
///   handleAddParticipant: addParticipant,
///   handleRemoveParticipant: removeParticipant,
///   currentRoomIndex: 1,
/// );
/// ```
class EditRoomModalOptions {
  /// Controls the visibility of the EditRoomModal.
  final ValueNotifier<bool> editRoomModalVisible;

  /// Callback to update the visibility state of the EditRoomModal.
  final void Function(bool visible) updateEditRoomModalVisible;

  /// The current breakout room being edited. Null if no room is selected.
  final List<BreakoutParticipant>? currentRoom;

  /// Reference to all participants for assigning to rooms.
  final List<Participant> participantsRef;

  /// Callback to handle adding a participant to a room.
  final void Function(int roomIndex, BreakoutParticipant participant)
      handleAddParticipant;

  /// Callback to handle removing a participant from a room.
  final void Function(int roomIndex, BreakoutParticipant participant)
      handleRemoveParticipant;

  /// Index of the current room being edited. Null if no room is selected.
  final int? currentRoomIndex;

  /// Background color of the modal.
  final Color backgroundColor;

  EditRoomModalOptions({
    required this.editRoomModalVisible,
    required this.updateEditRoomModalVisible,
    required this.currentRoom,
    required this.participantsRef,
    required this.handleAddParticipant,
    required this.handleRemoveParticipant,
    required this.currentRoomIndex,
    this.backgroundColor = const Color.fromARGB(255, 136, 171, 194),
  });
}

/// Parameters for managing breakout rooms within a meeting.
abstract class BreakoutRoomsModalParameters {
  // Core properties as abstract getters
  List<Participant> get participants;
  ShowAlert? get showAlert;
  io.Socket? get socket;
  int get itemPageLimit;
  String get meetingDisplayType;
  String get prevMeetingDisplayType;
  String get roomName;
  bool get shareScreenStarted;
  bool get shared;
  bool get breakOutRoomStarted;
  bool get breakOutRoomEnded;
  bool get canStartBreakout;
  List<List<BreakoutParticipant>> get breakoutRooms;

  // Update functions as abstract getters returning functions
  void Function(bool) get updateBreakOutRoomStarted;
  void Function(bool) get updateBreakOutRoomEnded;
  void Function(int) get updateCurrentRoomIndex;
  void Function(bool) get updateCanStartBreakout;
  void Function(List<List<BreakoutParticipant>>) get updateBreakoutRooms;
  void Function(String) get updateMeetingDisplayType;

  BreakoutRoomsModalParameters Function() get getUpdatedAllParams;

  // dynamic operator [](String key);
}

/// Options for configuring the `BreakoutRoomsModal` widget.
///
/// This modal manages breakout rooms, allowing for creating, editing, and deleting rooms.
///
/// ### Example Usage:
/// ```dart
/// final breakoutOptions = BreakoutRoomsModalOptions(
///   isVisible: true,
///   onBreakoutRoomsClose: closeModal,
///   parameters: breakoutRoomParams,
/// );
/// ```
class BreakoutRoomsModalOptions {
  /// Determines if the modal is visible.
  final bool isVisible;

  /// Callback function to close the modal.
  final VoidCallback onBreakoutRoomsClose;

  /// Parameters for managing breakout rooms.
  final BreakoutRoomsModalParameters parameters;

  /// Position of the modal on the screen.
  final String position;

  /// Background color of the modal.
  final Color backgroundColor;

  BreakoutRoomsModalOptions({
    required this.isVisible,
    required this.onBreakoutRoomsClose,
    required this.parameters,
    this.position = 'topRight',
    this.backgroundColor = const Color(0xFF83C0E9),
  });
}

/// Typedef for the BreakoutRoomsModal function.
typedef BreakoutRoomsModalType = Widget Function(
    {required BreakoutRoomsModalOptions options});

/// A widget for displaying a list of breakout rooms and managing participants.
///
/// Displays each room with options to edit, delete, and manage participants.
///
/// ### Example Usage:
/// ```dart
/// RoomList(
///   options: RoomOptions(
///     rooms: breakoutRooms,
///     handleEditRoom: editRoomCallback,
///     handleDeleteRoom: deleteRoomCallback,
///     handleRemoveParticipant: removeParticipantCallback,
///   ),
/// );
/// ```
class RoomList extends StatelessWidget {
  final RoomOptions options;

  const RoomList({
    super.key,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: options.rooms.length,
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
                      onPressed: () => options.handleEditRoom(roomIndex),
                      iconSize: 16,
                    ),
                    IconButton(
                      icon: const Icon(FontAwesomeIcons.xmark),
                      onPressed: () => options.handleDeleteRoom(roomIndex),
                      iconSize: 16,
                    ),
                  ],
                ),
              ),
              const Divider(height: 2, thickness: 2, color: Colors.black),
              ...options.rooms[roomIndex].map((participant) {
                return ListTile(
                  title: Text(participant.name),
                  trailing: IconButton(
                    icon: const Icon(FontAwesomeIcons.xmark),
                    onPressed: () =>
                        options.handleRemoveParticipant(roomIndex, participant),
                    iconSize: 16,
                  ),
                );
              }),
              if (options.rooms[roomIndex].isEmpty)
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

/// Modal widget for editing breakout room participants.
///
/// Allows users to view and manage assigned and unassigned participants within the room.
///
/// ### Example Usage:
/// ```dart
/// EditRoomModal(
///   options: EditRoomModalOptions(
///     editRoomModalVisible: ValueNotifier(false),
///     updateEditRoomModalVisible: toggleModalVisibility,
///     currentRoom: currentParticipants,
///     participantsRef: allParticipants,
///     handleAddParticipant: addParticipantCallback,
///     handleRemoveParticipant: removeParticipantCallback,
///     currentRoomIndex: 0,
///   ),
/// );
/// ```
class EditRoomModal extends StatelessWidget {
  final EditRoomModalOptions options;

  const EditRoomModal({
    super.key,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    final double modalWidth = 0.8 * MediaQuery.of(context).size.width > 500
        ? 500
        : 0.8 * MediaQuery.of(context).size.width;
    final modalHeight = MediaQuery.of(context).size.height * 0.7;

    return ValueListenableBuilder<bool>(
      valueListenable: options.editRoomModalVisible,
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
                    color: options.backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title:
                            Text('Edit Room ${options.currentRoomIndex! + 1}'),
                        trailing: IconButton(
                          icon: const Icon(FontAwesomeIcons.xmark),
                          onPressed: () =>
                              options.updateEditRoomModalVisible(false),
                          iconSize: 16,
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
                              ...options.currentRoom!.map((participant) {
                                return ListTile(
                                  title: Row(
                                    children: [
                                      const Icon(FontAwesomeIcons.user),
                                      const SizedBox(width: 10),
                                      Text(participant.name),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(FontAwesomeIcons.xmark),
                                    onPressed: () =>
                                        options.handleRemoveParticipant(
                                            options.currentRoomIndex!,
                                            participant),
                                    iconSize: 16,
                                  ),
                                );
                              }),
                              if (options.currentRoom!.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'None Assigned',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Color.fromARGB(255, 249, 247, 247),
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
                              ...options.participantsRef
                                  .where((participant) =>
                                      participant.breakRoom == null)
                                  .map((participant) {
                                return ListTile(
                                  title: Row(
                                    children: [
                                      const Icon(FontAwesomeIcons.user),
                                      const SizedBox(width: 10),
                                      Text(participant.name),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(FontAwesomeIcons.plus),
                                    onPressed: () =>
                                        options.handleAddParticipant(
                                            options.currentRoomIndex!,
                                            BreakoutParticipant(
                                                name: participant.name)),
                                    iconSize: 16,
                                  ),
                                );
                              }),
                              if (options.participantsRef
                                  .where((participant) =>
                                      participant.breakRoom == null)
                                  .isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'None Pending',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Color.fromARGB(255, 249, 247, 247),
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

/// A modal widget for managing breakout rooms within a meeting.
/// Allows users to create, edit, and delete rooms, assign participants, and start breakout rooms.
/// ### Example Usage:
/// ```dart
/// BreakoutRoomsModal(
///  options: BreakoutRoomsModalOptions(
///   isVisible: true,
///   onBreakoutRoomsClose: closeModal,
///  parameters: breakoutRoomParams,
/// ),
/// );
/// ```
///
class BreakoutRoomsModal extends StatefulWidget {
  final BreakoutRoomsModalOptions options;

  const BreakoutRoomsModal({
    super.key,
    required this.options,
  });

  @override
  _BreakoutRoomsModalState createState() => _BreakoutRoomsModalState();
}

class _BreakoutRoomsModalState extends State<BreakoutRoomsModal> {
  late List<Participant> participants;
  late List<BreakoutRoom> breakoutRooms;
  late int currentRoomIndex;
  final ValueNotifier<bool> editRoomModalVisible = ValueNotifier(false);
  late BreakoutRoom currentRoom;
  late TextEditingController numRoomsController;
  late ShowAlert? showAlert;
  bool breakOutRoomStarted = false;
  bool breakOutRoomEnded = false;
  bool canStartBreakout = false;
  String newParticipantAction = 'autoAssignNewRoom';

  @override
  void initState() {
    super.initState();
    participants = widget.options.parameters.participants
        .where((participant) => participant.islevel != '2')
        .toList();
    breakoutRooms = widget.options.parameters.breakoutRooms;
    showAlert = widget.options.parameters.showAlert!;
    breakOutRoomStarted = widget.options.parameters.breakOutRoomStarted;
    breakOutRoomEnded = widget.options.parameters.breakOutRoomEnded;
    canStartBreakout = widget.options.parameters.canStartBreakout;
    currentRoomIndex = 0;
    currentRoom = [];
    numRoomsController = TextEditingController();
  }

  /// Updates the visibility of the edit room modal.
  void updateEditRoomModalVisible(bool value) {
    editRoomModalVisible.value = value;
  }

  /// Handles editing a specific room.
  void handleEditRoom(int roomIndex) {
    setState(() {
      currentRoomIndex = roomIndex;
      currentRoom = breakoutRooms[roomIndex];
      editRoomModalVisible.value = true;
      canStartBreakout = false;
    });
  }

  /// Handles deleting a specific room.
  void handleDeleteRoom(int roomIndex) {
    setState(() {
      // Remove room and reset breakRoom assignments.
      breakoutRooms.removeAt(roomIndex);
      for (int i = 0; i < breakoutRooms.length; i++) {
        for (var participant in breakoutRooms[i]) {
          participant.breakRoom = i;
        }
      }
      _checkCanStartBreakout();
    });
    widget.options.parameters.updateBreakoutRooms(breakoutRooms);
    showAlert!(
      message: 'Room ${roomIndex + 1} deleted successfully.',
      type: 'success',
      duration: 3000,
    );
  }

  /// Handles adding a participant to a specific room.
  void handleAddParticipant(int roomIndex, BreakoutParticipant participant) {
    setState(() {
      if (breakoutRooms[roomIndex].length >=
          widget.options.parameters.itemPageLimit) {
        showAlert!(
          message: 'Room ${roomIndex + 1} is full.',
          type: 'danger',
          duration: 3000,
        );
        return;
      }
      breakoutRooms[roomIndex].add(participant);
      participants.firstWhere((p) => p.name == participant.name).breakRoom =
          roomIndex;
      participant.breakRoom = roomIndex;
      _checkCanStartBreakout();
    });
    widget.options.parameters.updateBreakoutRooms(breakoutRooms);
    showAlert!(
      message: '${participant.name} added to Room ${roomIndex + 1}.',
      type: 'success',
      duration: 2000,
    );
  }

  /// Handles removing a participant from a specific room.
  void handleRemoveParticipant(int roomIndex, BreakoutParticipant participant) {
    setState(() {
      breakoutRooms[roomIndex].remove(participant);
      participants.firstWhere((p) => p.name == participant.name).breakRoom =
          null;
      participant.breakRoom = null;
      _checkCanStartBreakout();
    });
    widget.options.parameters.updateBreakoutRooms(breakoutRooms);
    showAlert!(
      message: '${participant.name} removed from Room ${roomIndex + 1}.',
      type: 'success',
      duration: 2000,
    );
  }

  /// Handles random assignment of participants to rooms.
  void handleRandomAssign() {
    final int numRooms = int.tryParse(numRoomsController.text) ?? 0;
    if (numRooms <= 0) {
      showAlert!(
        message: 'Please enter a valid number of rooms',
        type: 'danger',
        duration: 3000,
      );
      return;
    }

    setState(() {
      List<List<BreakoutParticipant>> newBreakoutRooms =
          List.generate(numRooms, (_) => []);
      List<Participant> shuffledParticipants = List.from(participants)
        ..shuffle();

      for (int i = 0; i < shuffledParticipants.length; i++) {
        int roomIndex = i % numRooms;
        newBreakoutRooms[roomIndex].add(BreakoutParticipant(
            name: shuffledParticipants[i].name, breakRoom: roomIndex));
        shuffledParticipants[i].breakRoom = roomIndex;
      }
      breakoutRooms = newBreakoutRooms;
      _checkCanStartBreakout();
    });

    widget.options.parameters.updateBreakoutRooms(breakoutRooms);
    showAlert!(
      message: 'Participants assigned randomly to rooms',
      type: 'success',
      duration: 2000,
    );
  }

  /// Handles manual assignment of participants to rooms.
  void handleManualAssign() {
    final int numRooms = int.tryParse(numRoomsController.text) ?? 0;
    if (numRooms <= 0) {
      showAlert!(
        message: 'Please enter a valid number of rooms',
        type: 'danger',
        duration: 3000,
      );
      return;
    }

    setState(() {
      breakoutRooms = List.generate(numRooms, (_) => []);
      _checkCanStartBreakout();
    });

    widget.options.parameters.updateBreakoutRooms(breakoutRooms);
    showAlert!(
      message: 'Rooms created for manual assignment',
      type: 'success',
      duration: 2000,
    );
  }

  /// Handles adding a new room.
  void handleAddRoom() {
    setState(() {
      breakoutRooms.add([]);
      _checkCanStartBreakout();
    });
    widget.options.parameters.updateBreakoutRooms(breakoutRooms);
    showAlert!(
      message: 'New room added',
      type: 'success',
      duration: 3000,
    );
  }

  /// Validates the breakout rooms before starting.
  bool validateRooms() {
    if (breakoutRooms.isEmpty) {
      showAlert!(
        message: 'There must be at least one room',
        type: 'danger',
        duration: 3000,
      );
      return false;
    }

    for (final room in breakoutRooms) {
      if (room.isEmpty) {
        showAlert!(
          message: 'Rooms must not be empty',
          type: 'danger',
          duration: 3000,
        );
        return false;
      }

      final participantNames = room.map((p) => p.name).toList();
      final uniqueNames = Set.from(participantNames);
      if (participantNames.length != uniqueNames.length) {
        showAlert!(
          message: 'Duplicate participant names in a room',
          type: 'danger',
          duration: 3000,
        );
        return false;
      }

      if (room.length > widget.options.parameters.itemPageLimit) {
        showAlert!(
          message: 'A room exceeds the participant limit',
          type: 'danger',
          duration: 3000,
        );
        return false;
      }
    }

    return true;
  }

  /// Checks if breakout rooms can be started based on current assignments.
  void _checkCanStartBreakout() {
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

  /// Handles saving the current room assignments.
  void handleSaveRooms() {
    if (validateRooms()) {
      widget.options.parameters.updateBreakoutRooms(breakoutRooms);
      setState(() {
        canStartBreakout = true;
        widget.options.parameters.updateCanStartBreakout(true);
      });
      showAlert!(
        message: 'Rooms saved successfully',
        type: 'success',
        duration: 3000,
      );
    }
  }

  /// Handles starting or updating breakout rooms.
  void handleStartBreakout() {
    if (widget.options.parameters.shareScreenStarted ||
        widget.options.parameters.shared) {
      showAlert!(
        message:
            'You cannot start breakout rooms while screen sharing is active',
        type: 'danger',
        duration: 3000,
      );
      return;
    }

    if (canStartBreakout) {
      final String emitName = (breakOutRoomStarted && !breakOutRoomEnded)
          ? 'updateBreakout'
          : 'startBreakout';
      final List<BreakoutRoom> filteredBreakoutRooms = breakoutRooms
          .map((room) => room
              .map((p) => BreakoutParticipant(
                  name: p.name, breakRoom: p.breakRoom ?? -1))
              .toList())
          .toList();

      final List<List<Map<String, dynamic>>> filteredBreakoutRoomsMap =
          filteredBreakoutRooms
              .map((innerList) => innerList.map((p) => p.toMap()).toList())
              .toList();

      widget.options.parameters.socket!.emitWithAck(emitName, {
        'breakoutRooms': filteredBreakoutRoomsMap,
        'newParticipantAction': newParticipantAction,
        'roomName': widget.options.parameters.roomName,
      }, ack: (response) {
        if (response['success']) {
          showAlert!(
            message: 'Breakout rooms active',
            type: 'success',
            duration: 3000,
          );
          widget.options.parameters.updateBreakOutRoomStarted(true);
          widget.options.parameters.updateBreakOutRoomEnded(false);
          widget.options.parameters.updateMeetingDisplayType('all');
          widget.options.onBreakoutRoomsClose();
        } else {
          showAlert!(
            message: response['reason'],
            type: 'danger',
            duration: 3000,
          );
        }
      });
    }
  }

  /// Handles stopping the breakout rooms.
  void handleStopBreakout() {
    widget.options.parameters.socket!.emitWithAck('stopBreakout', {
      'roomName': widget.options.parameters.roomName,
    }, ack: (response) {
      if (response['success']) {
        showAlert!(
          message: 'Breakout rooms stopped',
          type: 'success',
          duration: 3000,
        );
        widget.options.parameters.updateBreakOutRoomStarted(false);
        widget.options.parameters.updateBreakOutRoomEnded(true);
        widget.options.parameters.updateMeetingDisplayType(
            widget.options.parameters.prevMeetingDisplayType);
        widget.options.onBreakoutRoomsClose();
      } else {
        showAlert!(
          message: response['reason'],
          type: 'danger',
          duration: 3000,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double modalWidth = MediaQuery.of(context).size.width * 0.9 > 600
        ? 600
        : MediaQuery.of(context).size.width * 0.9;
    final double modalHeight = MediaQuery.of(context).size.height * 0.7;

    return Visibility(
      visible: widget.options.isVisible,
      child: Stack(
        children: [
          Positioned(
            top: getModalPosition(GetModalPositionOptions(
              position: widget.options.position,
              context: context,
              modalWidth: modalWidth,
              modalHeight: modalHeight,
            ))['top']!,
            right: getModalPosition(GetModalPositionOptions(
              position: widget.options.position,
              context: context,
              modalWidth: modalWidth,
              modalHeight: modalHeight,
            ))['right']!,
            child: Container(
              width: modalWidth,
              height: modalHeight,
              decoration: BoxDecoration(
                color: widget.options.backgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Dialog(
                insetPadding: const EdgeInsets.all(20),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.8,
                  decoration: BoxDecoration(
                    color: widget.options.backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      ListTile(
                        title: const Text(
                          'Breakout Rooms',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const FaIcon(FontAwesomeIcons.xmark),
                          onPressed: widget.options.onBreakoutRoomsClose,
                          tooltip: 'Close',
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
                                    horizontal: 10.0, vertical: 5.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Number of Rooms Input
                                    const Text(
                                      'Number of Rooms',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
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
                                    horizontal: 20.0, vertical: 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'New Participant Action',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
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
                              EditRoomModal(
                                  options: EditRoomModalOptions(
                                editRoomModalVisible: editRoomModalVisible,
                                updateEditRoomModalVisible:
                                    updateEditRoomModalVisible,
                                currentRoom: currentRoom,
                                participantsRef: participants,
                                handleAddParticipant: handleAddParticipant,
                                handleRemoveParticipant:
                                    handleRemoveParticipant,
                                currentRoomIndex: currentRoomIndex,
                              )),
                              const SizedBox(height: 10),
                              // Room List

                              RoomList(
                                  options: RoomOptions(
                                rooms: breakoutRooms,
                                handleEditRoom: handleEditRoom,
                                handleDeleteRoom: handleDeleteRoom,
                                handleRemoveParticipant:
                                    handleRemoveParticipant,
                              )),

                              // Control Buttons
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
