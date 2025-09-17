import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../methods/utils/get_modal_position.dart'
    show getModalPosition, GetModalPositionOptions;
import '../../types/types.dart'
    show
        HandleCreatePollType,
        HandleEndPollType,
        HandleVotePollType,
        ShowAlert,
        Poll,
        HandleCreatePollOptions,
        HandleEndPollOptions,
        HandleVotePollOptions;

class PollModalOptions {
  final bool isPollModalVisible;
  final VoidCallback onClose;
  final String position;
  final Color backgroundColor;
  final String member;
  final String islevel;
  final List<Poll> polls;
  final Poll? poll;
  final io.Socket? socket;
  final String roomName;
  final ShowAlert? showAlert;
  final ValueChanged<bool> updateIsPollModalVisible;

  final HandleCreatePollType handleCreatePoll;
  final HandleEndPollType handleEndPoll;
  final HandleVotePollType handleVotePoll;

  PollModalOptions({
    required this.isPollModalVisible,
    required this.onClose,
    this.position = 'topRight',
    this.backgroundColor = const Color(0xFFF5F5F5),
    required this.member,
    required this.islevel,
    required this.polls,
    this.poll,
    this.socket,
    required this.roomName,
    this.showAlert,
    required this.updateIsPollModalVisible,
    required this.handleCreatePoll,
    required this.handleEndPoll,
    required this.handleVotePoll,
  });
}

typedef PollModalType = PollModal Function({required PollModalOptions options});

/// `PollModal` is a modal widget that provides an interface for creating, viewing, and managing polls
/// in a real-time environment with socket-based communication.
///
/// This widget allows users to:
/// - View previous polls and their results (for authorized users only).
/// - Create a new poll with various types (e.g., True/False, Yes/No, or Custom).
/// - View and participate in the currently active poll by casting votes.
/// - End the current poll if the user has the appropriate permissions.
///
/// ### Parameters:
/// - [PollModalOptions] (`options`): Configuration options for the modal, including:
///   - `isPollModalVisible`: Whether the modal is visible.
///   - `onClose`: Callback when the modal is closed.
///   - `position`: Position of the modal on the screen (e.g., 'topRight').
///   - `backgroundColor`: Background color of the modal.
///   - `member`: Member identifier for tracking user interactions.
///   - `islevel`: Authorization level for access control.
///   - `polls`: List of available polls for viewing past results.
///   - `poll`: The currently active poll.
///   - `socket`: Socket instance for real-time communication.
///   - `roomName`: Name of the room associated with the polls.
///   - `showAlert`: Function to show alerts, if any.
///   - `updateIsPollModalVisible`: Callback to update the visibility of the poll modal.
///   - `handleCreatePoll`: Function to handle poll creation.
///   - `handleEndPoll`: Function to handle ending a poll.
///   - `handleVotePoll`: Function to handle voting on a poll.
///
/// ### Example Usage:
/// ```dart
/// PollModal(
///   options: PollModalOptions(
///     isPollModalVisible: true,
///     onClose: () => print("Modal closed"),
///     position: 'topRight',
///     member: 'user123',
///     islevel: '2',
///     polls: [
///       Poll(id: '1', question: 'Example Question?', options: ['Yes', 'No'], votes: [5, 3], status: 'active', voters: {} )
///     ],
///     poll: Poll(id: '2', question: 'Current Active Poll?', options: ['Option 1', 'Option 2'], votes: [0, 0], status: 'active', voters: {}),
///     socket: io.Socket(),
///     roomName: 'room_1',
///     updateIsPollModalVisible: (visible) => print("Poll modal visibility: $visible"),
///     handleCreatePoll: (options) => print("Poll created: ${options.poll}"),
///     handleEndPoll: (options) => print("Poll ended: ${options.pollId}"),
///     handleVotePoll: (options) => print("Vote cast on poll: ${options.pollId}"),
///   ),
/// );
/// ```
///
/// This example initializes the `PollModal` with mock data and handlers, enabling the user to view and interact with polls in the UI.

class PollModal extends StatefulWidget {
  final PollModalOptions options;

  const PollModal({super.key, required this.options});

  @override
  _PollModalState createState() => _PollModalState();
}

class _PollModalState extends State<PollModal> {
  Map<String, dynamic> newPoll = {
    'question': '',
    'type': 'Choose...',
    'options': []
  };

  @override
  void initState() {
    super.initState();
    if (widget.options.isPollModalVisible) {
      renderPolls();
    }
  }

  void renderPolls() {
    final polls = widget.options.polls;
    final poll = widget.options.poll;
    final islevel = widget.options.islevel;

    int activePollCount = 0;
    for (var polled in polls) {
      if (polled.status == 'active' && poll != null && polled.id == poll.id) {
        activePollCount++;
      }
    }

    if (islevel == '2' && activePollCount == 0) {
      if (poll != null && poll.status == 'active') {
        poll.status = 'inactive';
      }
    }
  }

  double calculatePercentage(List<int> votes, int optionIndex) {
    final totalVotes = votes.reduce((a, b) => a + b);
    return totalVotes > 0
        ? (votes[optionIndex] / totalVotes * 100).toDouble()
        : 0;
  }

  void handlePollTypeChange(String type) {
    List<String> options = [];
    switch (type) {
      case 'trueFalse':
        options = ['True', 'False'];
        break;
      case 'yesNo':
        options = ['Yes', 'No'];
        break;
      case 'custom':
        options = [];
        break;
    }
    if (mounted) {
      setState(() {
        newPoll['type'] = type;
        newPoll['options'] = options;
      });
    }
  }

  List<Widget> renderPollOptions() {
    switch (newPoll['type']) {
      case 'trueFalse':
      case 'yesNo':
        return [
          RadioGroup<String>(
            onChanged: (value) {}, // Disabled for preview
            child: Column(
              children: newPoll['options'].map<Widget>((option) {
                return Row(
                  children: [
                    Radio<String>(
                      value: option,
                    ),
                    Text(option),
                  ],
                );
              }).toList(),
            ),
          ),
        ];
      case 'custom':
        return [
          ...newPoll['options'].asMap().entries.map((entry) {
            int index = entry.key;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: TextField(
                decoration: InputDecoration(labelText: 'Option ${index + 1}'),
                maxLength: 50,
                onChanged: (text) {
                  if (mounted) {
                    setState(() {
                      newPoll['options'][index] = text;
                    });
                  }
                },
              ),
            );
          }).toList(),
          ...List.generate((5 - newPoll['options'].length).toInt(), (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: TextField(
                decoration: InputDecoration(
                    labelText:
                        'Option ${newPoll['options'].length + index + 1}'),
                maxLength: 50,
                onChanged: (text) {
                  if (mounted) {
                    setState(() {
                      newPoll['options'].add(text);
                    });
                  }
                },
              ),
            );
          }),
        ];
      default:
        return [];
    }
  }

  List<Widget> renderCurrentPollOptions() {
    final poll = widget.options.poll;
    final member = widget.options.member;
    final handleVotePoll = widget.options.handleVotePoll;

    return [
      RadioGroup<int>(
        onChanged: (int? value) {
          if (value != null) {
            handleVotePoll(
              HandleVotePollOptions(
                pollId: poll.id!,
                optionIndex: value,
                socket: widget.options.socket,
                showAlert: widget.options.showAlert,
                member: member,
                roomName: widget.options.roomName,
                updateIsPollModalVisible:
                    widget.options.updateIsPollModalVisible,
              ),
            );
          }
        },
        child: Column(
          children: poll!.options.asMap().entries.map<Widget>((entry) {
            int i = entry.key;
            String option = entry.value;
            return ListTile(
              title: Text(option),
              leading: Radio<int>(
                value: i,
              ),
            );
          }).toList(),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final double modalWidth = 0.7 * MediaQuery.of(context).size.width > 400
        ? 400
        : 0.7 * MediaQuery.of(context).size.width;
    final modalHeight = MediaQuery.of(context).size.height * 0.75;
    final polls = widget.options.polls;
    final poll = widget.options.poll;
    final islevel = widget.options.islevel;
    final handleCreatePoll = widget.options.handleCreatePoll;
    final handleEndPoll = widget.options.handleEndPoll;

    return Visibility(
      visible: widget.options.isPollModalVisible,
      child: Stack(
        children: [
          Positioned(
              top: getModalPosition(GetModalPositionOptions(
                  position: widget.options.position,
                  modalWidth: modalWidth,
                  modalHeight: modalHeight,
                  context: context))['top'],
              right: getModalPosition(GetModalPositionOptions(
                  position: widget.options.position,
                  modalWidth: modalWidth,
                  modalHeight: modalHeight,
                  context: context))['right'],
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
                    padding: const EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      color: widget.options.backgroundColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Polls',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const FaIcon(FontAwesomeIcons.xmark),
                              onPressed: widget.options.onClose,
                            ),
                          ],
                        ),
                        const Divider(color: Colors.black),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (islevel == '2') ...[
                                  const Text('Previous Polls',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  ...polls.map<Widget>((polled) {
                                    if (polled.id!.isEmpty ||
                                        (poll != null &&
                                            poll.status == 'active' &&
                                            polled.id == poll.id)) {
                                      return const SizedBox.shrink();
                                    }
                                    const SizedBox(height: 10);
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Question: ${polled.question}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        ...polled.options
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                          int i = entry.key;
                                          String option = entry.value;
                                          return Text(
                                            '$option: ${polled.votes![i]} votes (${calculatePercentage(polled.votes ?? [], i).toStringAsFixed(2)}%)',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          );
                                        }),
                                        if (polled.status == 'active')
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red),
                                            onPressed: () {
                                              handleEndPoll(
                                                  HandleEndPollOptions(
                                                pollId: polled.id!,
                                                socket: widget.options.socket,
                                                showAlert:
                                                    widget.options.showAlert,
                                                roomName:
                                                    widget.options.roomName,
                                                updateIsPollModalVisible: widget
                                                    .options
                                                    .updateIsPollModalVisible,
                                              ));
                                            },
                                            child: const Text('End Poll'),
                                          ),
                                        const Divider(color: Colors.black),
                                      ],
                                    );
                                  }),
                                  const Divider(color: Colors.black),
                                  const SizedBox(height: 10),
                                  const Text('Create a New Poll',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    child: TextField(
                                      decoration: InputDecoration(
                                        labelText: 'Poll Question',
                                        labelStyle: TextStyle(
                                          color: Colors.grey[800],
                                          fontWeight: FontWeight.bold,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      maxLength: 300,
                                      maxLines: 3,
                                      onChanged: (text) {
                                        if (mounted) {
                                          setState(() {
                                            newPoll['question'] = text;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                      'Select Poll Answer Type',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    child: DropdownButton<String>(
                                      value: newPoll['type'],
                                      onChanged: (String? newValue) {
                                        handlePollTypeChange(newValue!);
                                      },
                                      items: <String>[
                                        'Choose...',
                                        'trueFalse',
                                        'yesNo',
                                        'custom'
                                      ].map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  ...renderPollOptions(),
                                  ElevatedButton(
                                    onPressed: () {
                                      handleCreatePoll(HandleCreatePollOptions(
                                        poll: Poll.fromMap(newPoll),
                                        socket: widget.options.socket,
                                        showAlert: widget.options.showAlert,
                                        roomName: widget.options.roomName,
                                        updateIsPollModalVisible: widget
                                            .options.updateIsPollModalVisible,
                                      ));
                                    },
                                    child: const Text('Create Poll'),
                                  ),
                                  const Divider(color: Colors.black),
                                ],
                                const SizedBox(height: 10),
                                const Text('Current Poll',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                if (poll != null &&
                                    poll.status == 'active') ...[
                                  Text(
                                    'Question: ${poll.question}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  ...renderCurrentPollOptions(),
                                  if (islevel == '2')
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red),
                                      onPressed: () {
                                        handleEndPoll(HandleEndPollOptions(
                                          pollId: poll.id!,
                                          socket: widget.options.socket,
                                          showAlert: widget.options.showAlert,
                                          roomName: widget.options.roomName,
                                          updateIsPollModalVisible: widget
                                              .options.updateIsPollModalVisible,
                                        ));
                                      },
                                      child: const Text('End Poll'),
                                    ),
                                ] else ...[
                                  const Text('No active poll'),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
