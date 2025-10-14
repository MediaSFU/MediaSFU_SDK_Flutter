import 'dart:math' as math;

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
import '../../types/modal_style_options.dart' show PollModalStyleOptions;

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
  final PollModalStyleOptions? styles;
  final Widget? previousPollsHeader;
  final Widget? createPollHeader;
  final Widget? currentPollHeader;
  final Widget? emptyPreviousPollsPlaceholder;
  final Widget? emptyCurrentPollPlaceholder;

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
    this.styles,
    this.previousPollsHeader,
    this.createPollHeader,
    this.currentPollHeader,
    this.emptyPreviousPollsPlaceholder,
    this.emptyCurrentPollPlaceholder,
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

  PollModalStyleOptions get _styles =>
      widget.options.styles ?? const PollModalStyleOptions();

  String _optionLabel(int index) {
    return _styles.optionLabelBuilder?.call(index) ?? 'Option ${index + 1}';
  }

  InputDecoration _buildQuestionDecoration() {
    final override = _styles.questionInputDecoration;
    final baseLabel = _styles.questionLabelText ?? override?.labelText;
    final base = InputDecoration(
      labelText: baseLabel ?? 'Poll Question',
      border: override?.border ??
          OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: override?.enabledBorder,
      focusedBorder: override?.focusedBorder,
      hintText: override?.hintText,
      prefixIcon: override?.prefixIcon,
      suffixIcon: override?.suffixIcon,
      helperText: override?.helperText,
      contentPadding: override?.contentPadding,
      labelStyle: override?.labelStyle ??
          const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
    );

    if (override == null) {
      return base;
    }

    return base.copyWith(
      labelText: baseLabel ?? base.labelText,
      prefixIcon: override.prefixIcon ?? base.prefixIcon,
      suffixIcon: override.suffixIcon ?? base.suffixIcon,
      helperText: override.helperText ?? base.helperText,
      hintText: override.hintText ?? base.hintText,
      contentPadding: override.contentPadding ?? base.contentPadding,
      labelStyle: override.labelStyle ?? base.labelStyle,
      enabledBorder: override.enabledBorder ?? base.enabledBorder,
      focusedBorder: override.focusedBorder ?? base.focusedBorder,
      border: override.border ?? base.border,
    );
  }

  InputDecoration _buildOptionDecoration(int index) {
    final override = _styles.optionInputDecoration;
    final label = _optionLabel(index);
    final base = InputDecoration(
      labelText: label,
      border: override?.border ??
          OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: override?.enabledBorder,
      focusedBorder: override?.focusedBorder,
      hintText: override?.hintText,
      prefixIcon: override?.prefixIcon,
      suffixIcon: override?.suffixIcon,
      helperText: override?.helperText,
      contentPadding: override?.contentPadding,
      labelStyle: override?.labelStyle ??
          const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
    );

    if (override == null) {
      return base;
    }

    return base.copyWith(
      labelText: label,
      labelStyle: override.labelStyle ?? base.labelStyle,
      hintText: override.hintText ?? base.hintText,
      helperText: override.helperText ?? base.helperText,
      contentPadding: override.contentPadding ?? base.contentPadding,
      prefixIcon: override.prefixIcon ?? base.prefixIcon,
      suffixIcon: override.suffixIcon ?? base.suffixIcon,
      enabledBorder: override.enabledBorder ?? base.enabledBorder,
      focusedBorder: override.focusedBorder ?? base.focusedBorder,
      border: override.border ?? base.border,
    );
  }

  ButtonStyle? get _createButtonStyle =>
      _styles.createButtonStyle ?? _styles.primaryButtonStyle;

  ButtonStyle? get _endButtonStyle =>
      _styles.endButtonStyle ?? _styles.destructiveButtonStyle;


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
    final options = List<String>.from(newPoll['options'] ?? []);
    final optionTextStyle =
        _styles.pollOptionPreviewTextStyle ?? _styles.bodyTextStyle;

    switch (newPoll['type']) {
      case 'trueFalse':
      case 'yesNo':
        return [
          Column(
            children: options.map<Widget>((option) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: Radio<String>(
                  value: option,
                  enabled: false,
                ),
                title: Text(
                  option,
                  style: optionTextStyle,
                ),
              );
            }).toList(),
          ),
        ];
      case 'custom':
        return [
          ...options.asMap().entries.map((entry) {
            final index = entry.key;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: TextField(
                decoration: _buildOptionDecoration(index),
                maxLength: 50,
                style: _styles.optionInputTextStyle,
                onChanged: (text) {
                  if (mounted) {
                    setState(() {
                      newPoll['options'][index] = text;
                    });
                  }
                },
              ),
            );
          }),
          ...List.generate(math.max(0, 5 - options.length), (index) {
            final optionIndex = options.length + index;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: TextField(
                decoration: _buildOptionDecoration(optionIndex),
                maxLength: 50,
                style: _styles.optionInputTextStyle,
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
    final dynamic rawSelection = poll?.voters?[member];
    final int? selectedOption = rawSelection is int ? rawSelection : null;
    final optionTextStyle =
        _styles.currentPollOptionTextStyle ?? _styles.bodyTextStyle;

    return [
      RadioGroup<int>(
        groupValue: selectedOption,
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
            final int index = entry.key;
            final String option = entry.value;
            return Builder(
              builder: (context) {
                final registry = RadioGroup.maybeOf<int>(context);
                return ListTile(
                  title: Text(
                    option,
                    style: optionTextStyle,
                  ),
                  leading: Radio<int>(
                    value: index,
                  ),
                  onTap: registry == null
                      ? null
                      : () => registry.onChanged(index),
                );
              },
            );
          }).toList(),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final style = _styles;
    final mediaSize = MediaQuery.of(context).size;
    final defaultModalWidth = math.min(mediaSize.width * 0.7, 400.0);
    double modalWidth = style.width ?? defaultModalWidth;
    if (style.maxWidth != null) {
      modalWidth = math.min(modalWidth, style.maxWidth!);
    }

    final defaultModalHeight = mediaSize.height * 0.75;
    double modalHeight = style.height ?? defaultModalHeight;
    if (style.maxHeight != null) {
      modalHeight = math.min(modalHeight, style.maxHeight!);
    }

    final polls = widget.options.polls;
    final poll = widget.options.poll;
    final islevel = widget.options.islevel;
    final handleCreatePoll = widget.options.handleCreatePoll;
    final handleEndPoll = widget.options.handleEndPoll;
    final positionData = getModalPosition(GetModalPositionOptions(
      position: widget.options.position,
      modalWidth: modalWidth,
      modalHeight: modalHeight,
      context: context,
    ));

    final filteredPreviousPolls = polls.where((polled) {
      final matchesCurrentActive = poll != null &&
          poll.status == 'active' &&
          polled.id != null &&
          polled.id == poll.id;
      final hasId = polled.id != null && polled.id!.isNotEmpty;
      return hasId && !matchesCurrentActive;
    }).toList();

    final outerDecoration = style.outerContainerDecoration ??
        BoxDecoration(
          color: widget.options.backgroundColor,
          borderRadius: BorderRadius.circular(10),
        );

    final contentDecoration = style.contentDecoration ??
        BoxDecoration(
          color: widget.options.backgroundColor,
          borderRadius: BorderRadius.circular(10),
        );

    final divider = Divider(
      color: style.dividerColor ?? Colors.black,
      thickness: style.dividerThickness,
      height: style.dividerHeight,
      indent: style.dividerIndent,
      endIndent: style.dividerEndIndent,
    );

    final sectionTitleStyle = style.sectionTitleTextStyle ??
        const TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
    final pollQuestionTitleStyle = style.pollItemQuestionTextStyle ??
        const TextStyle(fontSize: 12, fontWeight: FontWeight.bold);
    final pollResultStyle = style.pollResultTextStyle ??
        const TextStyle(fontSize: 12, color: Colors.grey);
    final emptyStateStyle =
        style.emptyStateTextStyle ?? style.bodyTextStyle ?? const TextStyle();

    return Visibility(
      visible: widget.options.isPollModalVisible,
      child: Stack(
        children: [
          Positioned(
              top: positionData['top'],
              right: positionData['right'],
              child: Container(
                width: modalWidth,
                height: modalHeight,
                decoration: outerDecoration,
                padding: style.outerPadding ?? EdgeInsets.zero,
                child: Container(
                  padding: style.contentPadding ?? const EdgeInsets.all(20),
                  decoration: contentDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Polls',
                            style: style.titleTextStyle ??
                                const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: style.closeIcon ??
                                const FaIcon(FontAwesomeIcons.xmark),
                            style: style.closeButtonStyle,
                            onPressed: widget.options.onClose,
                          ),
                        ],
                      ),
                      divider,
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (islevel == '2') ...[
                                widget.options.previousPollsHeader ??
                                    Text('Previous Polls',
                                        style: sectionTitleStyle),
                                if (filteredPreviousPolls.isEmpty)
                                  widget.options
                                          .emptyPreviousPollsPlaceholder ??
                                      Text('No polls available',
                                          style: emptyStateStyle)
                                else
                                  ...filteredPreviousPolls.map((polled) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Question: ${polled.question}',
                                            style: pollQuestionTitleStyle,
                                          ),
                                          ...polled.options
                                              .asMap()
                                              .entries
                                              .map((entry) {
                                            final i = entry.key;
                                            final option = entry.value;
                                            final baseVotes = polled.votes ?? [];
                                            final safeVotes = List<int>.generate(
                                              polled.options.length,
                                              (voteIndex) =>
                                                  voteIndex < baseVotes.length
                                                      ? baseVotes[voteIndex]
                                                      : 0,
                                            );
                                            return Text(
                                              '$option: '
                                              '${safeVotes[i]} '
                                              'votes (${calculatePercentage(safeVotes, i).toStringAsFixed(2)}%)',
                                              style: pollResultStyle,
                                            );
                                          }),
                                          if (polled.status == 'active')
                                            ElevatedButton(
                                              style: _endButtonStyle ??
                                                  ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.red),
                                              onPressed: () {
                                                handleEndPoll(
                                                    HandleEndPollOptions(
                                                  pollId: polled.id!,
                                                  socket:
                                                      widget.options.socket,
                                                  showAlert: widget
                                                      .options.showAlert,
                                                  roomName:
                                                      widget.options.roomName,
                                                  updateIsPollModalVisible:
                                                      widget.options
                                                          .updateIsPollModalVisible,
                                                ));
                                              },
                                              child: const Text('End Poll'),
                                            ),
                                          divider,
                                        ],
                                      ),
                                    );
                                  }),
                                divider,
                                const SizedBox(height: 10),
                                widget.options.createPollHeader ??
                                    Text('Create a New Poll',
                                        style: sectionTitleStyle),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5),
                                  child: TextField(
                                    decoration: _buildQuestionDecoration(),
                                    maxLength: 300,
                                    maxLines: 3,
                                    style: _styles.questionInputTextStyle,
                                    onChanged: (text) {
                                      if (mounted) {
                                        setState(() {
                                          newPoll['question'] = text;
                                        });
                                      }
                                    },
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Text(
                                    'Select Poll Answer Type',
                                    style: style.bodyTextStyle ??
                                        const TextStyle(
                                            fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5),
                                  child: DropdownButton<String>(
                                    value: newPoll['type'],
                                    style: _styles.dropdownTextStyle ??
                                        style.bodyTextStyle,
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        handlePollTypeChange(newValue);
                                      }
                                    },
                                    items: <String>[
                                      'Choose...',
                                      'trueFalse',
                                      'yesNo',
                                      'custom'
                                    ].map((value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: _styles.dropdownTextStyle ??
                                              style.bodyTextStyle,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                ...renderPollOptions(),
                                ElevatedButton(
                                  style: _createButtonStyle,
                                  onPressed: () {
                                    handleCreatePoll(HandleCreatePollOptions(
                                      poll: Poll.fromMap(newPoll),
                                      socket: widget.options.socket,
                                      showAlert: widget.options.showAlert,
                                      roomName: widget.options.roomName,
                                      updateIsPollModalVisible: widget.options
                                          .updateIsPollModalVisible,
                                    ));
                                  },
                                  child: const Text('Create Poll'),
                                ),
                                divider,
                              ],
                              const SizedBox(height: 10),
                              widget.options.currentPollHeader ??
                                  Text('Current Poll',
                                      style: sectionTitleStyle),
                              if (poll != null &&
                                  poll.status == 'active') ...[
                                Text(
                                  'Question: ${poll.question}',
                                  style: pollQuestionTitleStyle,
                                ),
                                ...renderCurrentPollOptions(),
                                if (islevel == '2')
                                  ElevatedButton(
                                    style: _endButtonStyle ??
                                        ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red),
                                    onPressed: () {
                                      handleEndPoll(HandleEndPollOptions(
                                        pollId: poll.id!,
                                        socket: widget.options.socket,
                                        showAlert: widget.options.showAlert,
                                        roomName: widget.options.roomName,
                                        updateIsPollModalVisible: widget.options
                                            .updateIsPollModalVisible,
                                      ));
                                    },
                                    child: const Text('End Poll'),
                                  ),
                              ] else ...[
                                widget.options.emptyCurrentPollPlaceholder ??
                                    Text('No active poll',
                                        style: emptyStateStyle),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
