import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../methods/utils/get_modal_position.dart' show getModalPosition;

typedef HandleCreatePoll = Future<void> Function({
  required Map<String, dynamic> poll,
  required Map<String, dynamic> parameters,
});

typedef HandleEndPoll = Future<void> Function({
  required String pollId,
  required Map<String, dynamic> parameters,
});

typedef HandleVotePoll = Future<void> Function({
  required String pollId,
  required int optionIndex,
  required Map<String, dynamic> parameters,
});

class PollModal extends StatefulWidget {
  final bool isPollModalVisible;
  final VoidCallback onClose;
  final Map<String, dynamic> parameters;
  final String position;
  final Color backgroundColor;

  const PollModal({
    super.key,
    required this.isPollModalVisible,
    required this.onClose,
    required this.parameters,
    this.position = 'topRight',
    this.backgroundColor = const Color(0xFFF5F5F5),
  });

  @override
  // ignore: library_private_types_in_public_api
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
    if (widget.isPollModalVisible) {
      renderPolls();
    }
  }

  void renderPolls() {
    final polls = widget.parameters['polls'];
    final poll = widget.parameters['poll'];
    final islevel = widget.parameters['islevel'];

    int activePollCount = 0;

    for (var polled in polls) {
      if (polled['status'] == 'active' &&
          poll != null &&
          polled['id'] == poll['id']) {
        activePollCount++;
      }
    }

    if (islevel == '2' && activePollCount == 0) {
      if (poll != null && poll['status'] == 'active') {
        poll['status'] = 'inactive';
      }
    }
  }

  double calculatePercentage(List<dynamic> votes, int optionIndex) {
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
    setState(() {
      newPoll['type'] = type;
      newPoll['options'] = options;
    });
  }

  List<Widget> renderPollOptions() {
    switch (newPoll['type']) {
      case 'trueFalse':
      case 'yesNo':
        return newPoll['options'].map<Widget>((option) {
          return Row(
            children: [
              Radio(
                  value: option,
                  groupValue: newPoll['type'],
                  onChanged: (_) {}),
              Text(option),
            ],
          );
        }).toList();
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
                  setState(() {
                    newPoll['options'][index] = text;
                  });
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
                  setState(() {
                    newPoll['options'].add(text);
                  });
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
    final poll = widget.parameters['poll'];
    final member = widget.parameters['member'];
    final handleVotePoll =
        widget.parameters['handleVotePoll'] as HandleVotePoll;

    return poll['options'].asMap().entries.map<Widget>((entry) {
      int i = entry.key;
      String option = entry.value;
      return ListTile(
        title: Text(option),
        leading: Radio(
          value: i,
          groupValue: poll['voters']?[member],
          onChanged: (_) {
            handleVotePoll(
              pollId: poll['id'],
              optionIndex: i,
              parameters: widget.parameters,
            );
          },
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final double modalWidth = 0.7 * MediaQuery.of(context).size.width > 400
        ? 400
        : 0.7 * MediaQuery.of(context).size.width;
    final modalHeight = MediaQuery.of(context).size.height * 0.75;

    final poll = widget.parameters['poll'];
    final islevel = widget.parameters['islevel'];
    final polls = widget.parameters['polls'] ?? [];
    final handleCreatePoll =
        widget.parameters['handleCreatePoll'] as HandleCreatePoll;
    final handleEndPoll = widget.parameters['handleEndPoll'] as HandleEndPoll;

    return Visibility(
      visible: widget.isPollModalVisible,
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
                    padding: const EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      color: widget.backgroundColor,
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
                              onPressed: widget.onClose,
                            ),
                          ],
                        ),
                        const Divider(),
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
                                    if (polled == null ||
                                        (poll != null &&
                                            poll['status'] == 'active' &&
                                            polled['id'] == poll['id'])) {
                                      return const SizedBox.shrink();
                                    }
                                    const SizedBox(height: 10);
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Question: ${polled['question']}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        ...polled['options']
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                          int i = entry.key;
                                          String option = entry.value;
                                          return Text(
                                            '$option: ${polled['votes'][i]} votes (${calculatePercentage(polled['votes'], i).toStringAsFixed(2)}%)',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          );
                                        }).toList(),
                                        if (polled['status'] == 'active')
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red),
                                            onPressed: () {
                                              handleEndPoll(
                                                pollId: polled['id'],
                                                parameters: widget.parameters,
                                              );
                                            },
                                            child: const Text('End Poll'),
                                          ),
                                        const Divider(),
                                      ],
                                    );
                                  }).toList(),
                                  const Divider(),
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
                                        setState(() {
                                          newPoll['question'] = text;
                                        });
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
                                      handleCreatePoll(
                                        poll: newPoll,
                                        parameters: widget.parameters,
                                      );
                                    },
                                    child: const Text('Create Poll'),
                                  ),
                                  const Divider(),
                                ],
                                const SizedBox(height: 10),
                                const Text('Current Poll',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                if (poll != null &&
                                    poll['status'] == 'active') ...[
                                  Text(
                                    'Question: ${poll['question']}',
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
                                        handleEndPoll(
                                          pollId: poll['id'],
                                          parameters: widget.parameters,
                                        );
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
