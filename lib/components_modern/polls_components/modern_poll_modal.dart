import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../components/polls_components/poll_modal.dart'
    show PollModalOptions;
import '../../methods/utils/get_modal_position.dart'
    show getModalPosition, GetModalPositionOptions;
import '../../types/modal_style_options.dart'
    show ModalRenderMode, PollModalStyleOptions;
import '../../types/types.dart'
    show
        HandleCreatePollOptions,
        HandleEndPollOptions,
        HandleVotePollOptions,
        Poll;
import '../core/theme/mediasfu_colors.dart';
import '../core/theme/mediasfu_spacing.dart';

typedef ModernPollModalType = ModernPollModal Function(
    {required PollModalOptions options});

/// Modern poll modal with glassmorphic design.
/// Uses the same [PollModalOptions] as the original component.
class ModernPollModal extends StatefulWidget {
  final PollModalOptions options;

  const ModernPollModal({super.key, required this.options});

  @override
  State<ModernPollModal> createState() => _ModernPollModalState();
}

class _ModernPollModalState extends State<ModernPollModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  int _selectedTabIndex = 0;
  int? _selectedOption;

  // New poll state
  String _pollQuestion = '';
  // Store canonical poll type values to stay aligned with the classic widget
  // (`trueFalse`, `yesNo`, `custom`). UI labels are mapped from this value.
  String _pollType = 'choose';
  List<String> _customOptions = ['', ''];

  PollModalStyleOptions get _styles =>
      widget.options.styles ?? const PollModalStyleOptions();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();

    // Set initial tab based on user level
    if (widget.options.islevel == '2') {
      _selectedTabIndex = 1; // New Poll tab for hosts
    } else {
      _selectedTabIndex = 2; // Current Poll tab for participants
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleClose() {
    _animationController.reverse().then((_) {
      widget.options.onClose();
    });
  }

  bool get _isHost => widget.options.islevel == '2';

  @override
  Widget build(BuildContext context) {
    // For sidebar or inline mode, render content directly without modal wrapper
    if (widget.options.renderMode == ModalRenderMode.sidebar ||
        widget.options.renderMode == ModalRenderMode.inline) {
      return _buildSidebarContent();
    }

    final mediaSize = MediaQuery.of(context).size;
    final defaultModalWidth = math.min(mediaSize.width * 0.9, 500.0);
    final defaultModalHeight = mediaSize.height * 0.8;

    double modalWidth = _styles.width ?? defaultModalWidth;
    if (_styles.maxWidth != null) {
      modalWidth = math.min(modalWidth, _styles.maxWidth!);
    }

    double modalHeight = _styles.height ?? defaultModalHeight;
    if (_styles.maxHeight != null) {
      modalHeight = math.min(modalHeight, _styles.maxHeight!);
    }

    final screenWidth = mediaSize.width;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final isWide = screenWidth >= 1200;
    final shouldUseSidebar = isLandscape && isWide;
    final useHighTransparency = !shouldUseSidebar;

    final positionData = getModalPosition(GetModalPositionOptions(
      position: widget.options.position,
      modalWidth: modalWidth,
      modalHeight: modalHeight,
      context: context,
    ));

    final outerDecoration = _styles.outerContainerDecoration ??
        BoxDecoration(
          color: useHighTransparency
              ? (widget.options.isDarkMode
                  ? Colors.black.withOpacity(0.05)
                  : Colors.white.withOpacity(0.08))
              : (widget.options.isDarkMode
                  ? Colors.black.withOpacity(0.7)
                  : Colors.white.withOpacity(0.9)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.options.isDarkMode
                ? Colors.white.withOpacity(useHighTransparency ? 0.08 : 0.1)
                : Colors.black.withOpacity(useHighTransparency ? 0.05 : 0.1),
          ),
          boxShadow: useHighTransparency
              ? []
              : [
                  BoxShadow(
                    color: MediasfuColors.secondary.withOpacity(0.2),
                    blurRadius: 40,
                    spreadRadius: 8,
                  ),
                ],
        );

    return Visibility(
      visible: widget.options.isPollModalVisible,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Backdrop
            Positioned.fill(
              child: GestureDetector(
                onTap: _handleClose,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    color: Colors.black.withOpacity(0.05),
                  ),
                ),
              ),
            ),

            // Modal
            Positioned(
              top: positionData['top'],
              right: positionData['right'],
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: widget.options.enableGlassmorphism
                          ? ImageFilter.blur(sigmaX: 20, sigmaY: 20)
                          : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                      child: Container(
                        width: modalWidth,
                        height: modalHeight,
                        decoration: outerDecoration,
                        child: Column(
                          children: [
                            _buildHeader(),
                            if (_isHost) _buildTabBar(),
                            Expanded(child: _buildContent()),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds sidebar-optimized content for embedding in sidebar panel.
  Widget _buildSidebarContent() {
    return Column(
      children: [
        _buildHeader(),
        if (_isHost) _buildTabBar(),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildHeader() {
    final closeIcon = _styles.closeIcon;
    final closeButtonStyle = _styles.closeButtonStyle;
    final titleStyle = _styles.titleTextStyle;

    return Container(
      padding: const EdgeInsets.all(MediasfuSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: widget.options.isDarkMode
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(MediasfuSpacing.sm),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  MediasfuColors.secondary,
                  MediasfuColors.primary,
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.poll_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: MediasfuSpacing.sm),
          Text(
            'Polls',
            style: titleStyle ??
                TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:
                      widget.options.isDarkMode ? Colors.white : Colors.black87,
                ),
          ),
          const Spacer(),
          if (closeIcon != null || closeButtonStyle != null)
            IconButton(
              icon: closeIcon ?? const Icon(Icons.close_rounded),
              style: closeButtonStyle,
              onPressed: _handleClose,
            )
          else
            Tooltip(
              message: 'Close polls',
              child: GestureDetector(
                onTap: _handleClose,
                child: Container(
                  padding: const EdgeInsets.all(MediasfuSpacing.sm),
                  decoration: BoxDecoration(
                    color: widget.options.isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: widget.options.isDarkMode
                        ? Colors.white70
                        : Colors.black54,
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MediasfuSpacing.md,
        vertical: MediasfuSpacing.sm,
      ),
      child: Row(
        children: [
          _buildTab('Previous', 0),
          const SizedBox(width: MediasfuSpacing.sm),
          _buildTab('New Poll', 1),
          const SizedBox(width: MediasfuSpacing.sm),
          _buildTab('Current', 2),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: MediasfuSpacing.md,
          vertical: MediasfuSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    MediasfuColors.secondary,
                    MediasfuColors.primary,
                  ],
                )
              : null,
          color: isSelected
              ? null
              : (widget.options.isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: isSelected
                ? Colors.white
                : (widget.options.isDarkMode ? Colors.white70 : Colors.black54),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (!_isHost) {
      return _buildCurrentPollContent();
    }

    switch (_selectedTabIndex) {
      case 0:
        return _buildPreviousPollsContent();
      case 1:
        return _buildNewPollContent();
      case 2:
        return _buildCurrentPollContent();
      default:
        return const SizedBox();
    }
  }

  Widget _buildPreviousPollsContent() {
    if (widget.options.polls.isEmpty) {
      return widget.options.emptyPreviousPollsPlaceholder ??
          _buildEmptyState('No previous polls', Icons.history_rounded);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(MediasfuSpacing.md),
      itemCount: widget.options.polls.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return widget.options.previousPollsHeader ??
              Padding(
                padding: const EdgeInsets.only(bottom: MediasfuSpacing.sm),
                child: _buildSectionTitle('Previous Polls'),
              );
        }
        final poll = widget.options.polls[index - 1];
        return _buildPollCard(poll, isCompleted: true, showResults: true);
      },
    );
  }

  Widget _buildNewPollContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(MediasfuSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.options.createPollHeader ??
              _buildSectionTitle('Create a New Poll'),
          _buildSectionTitle('Poll Type'),
          _buildPollTypeDropdown(),
          const SizedBox(height: MediasfuSpacing.md),
          _buildSectionTitle('Question'),
          _buildTextField(
            hintText: 'Enter your poll question...',
            onChanged: (value) => _pollQuestion = value,
            decorationOverride: _questionInputDecoration(),
            textStyle: _styles.questionInputTextStyle,
          ),
          if (_pollType == 'custom') ...[
            const SizedBox(height: MediasfuSpacing.md),
            _buildSectionTitle('Options'),
            ..._buildCustomOptions(),
            const SizedBox(height: MediasfuSpacing.sm),
            _buildAddOptionButton(),
          ],
          const SizedBox(height: MediasfuSpacing.lg),
          _buildLaunchButton(),
        ],
      ),
    );
  }

  Widget _buildCurrentPollContent() {
    final poll = widget.options.poll;
    if (poll == null) {
      return widget.options.emptyCurrentPollPlaceholder ??
          _buildEmptyState('No active poll', Icons.poll_outlined);
    }

    final hasVoted = poll.voters?.containsKey(widget.options.member) ?? false;
    final totalVotes = poll.votes?.fold<int>(0, (sum, vote) => sum + vote) ?? 0;
    final selectedFromPoll = poll.voters?[widget.options.member];
    final effectiveSelected =
        _selectedOption ?? (selectedFromPoll is int ? selectedFromPoll : null);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(MediasfuSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPollCard(poll, isCompleted: false),
          const SizedBox(height: MediasfuSpacing.md),
          widget.options.currentPollHeader ??
              _buildSectionTitle('Cast Your Vote'),
          const SizedBox(height: MediasfuSpacing.sm),
          ...List.generate(poll.options.length, (index) {
            final option = poll.options[index];
            final votes = poll.votes != null && index < poll.votes!.length
                ? poll.votes![index]
                : 0;
            final percentage =
                totalVotes > 0 ? (votes / totalVotes * 100).toInt() : 0;

            return _buildVoteOption(
              option: option,
              index: index,
              votes: votes,
              percentage: percentage,
              isSelected: effectiveSelected == index,
              hasVoted: hasVoted,
            );
          }),
          const SizedBox(height: MediasfuSpacing.lg),
          if (!hasVoted) _buildSubmitVoteButton(),
          if (_isHost) ...[
            const SizedBox(height: MediasfuSpacing.md),
            _buildEndPollButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    final emptyStyle = _styles.emptyStateTextStyle;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: widget.options.isDarkMode ? Colors.white30 : Colors.black26,
          ),
          const SizedBox(height: MediasfuSpacing.md),
          Text(
            message,
            style: emptyStyle ??
                TextStyle(
                  fontSize: 16,
                  color: widget.options.isDarkMode
                      ? Colors.white54
                      : Colors.black45,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: MediasfuSpacing.sm),
      child: Text(
        title,
        style: _styles.sectionTitleTextStyle ??
            TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color:
                  widget.options.isDarkMode ? Colors.white70 : Colors.black54,
            ),
      ),
    );
  }

  Widget _buildPollTypeDropdown() {
    const pollTypes = [
      {'label': 'Choose...', 'value': 'choose'},
      {'label': 'True/False', 'value': 'trueFalse'},
      {'label': 'Yes/No', 'value': 'yesNo'},
      {'label': 'Custom', 'value': 'custom'},
    ];

    return Tooltip(
      message: 'Select the type of poll to create',
      decoration:
          MediasfuColors.tooltipDecoration(darkMode: widget.options.isDarkMode),
      textStyle: TextStyle(
        color: MediasfuColors.tooltipText(darkMode: widget.options.isDarkMode),
        fontSize: 12,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: MediasfuSpacing.md),
        decoration: MediasfuColors.dropdownDecoration(
            darkMode: widget.options.isDarkMode),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _pollType,
            isExpanded: true,
            dropdownColor: MediasfuColors.dropdownBackground(
                darkMode: widget.options.isDarkMode),
            style: _styles.dropdownTextStyle ??
                MediasfuColors.dropdownTextStyle(
                    darkMode: widget.options.isDarkMode),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: widget.options.isDarkMode
                  ? MediasfuColors.primaryDark
                  : MediasfuColors.primary,
            ),
            items: pollTypes
                .map((type) => DropdownMenuItem(
                      value: type['value']!,
                      child: Text(
                        type['label']!,
                        style: _styles.dropdownTextStyle ??
                            MediasfuColors.dropdownTextStyle(
                                darkMode: widget.options.isDarkMode),
                      ),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _pollType = value ?? 'choose';
                if (_pollType != 'custom') {
                  _customOptions = ['', ''];
                }
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required ValueChanged<String> onChanged,
    String? initialValue,
    InputDecoration? decorationOverride,
    TextStyle? textStyle,
  }) {
    final baseDecoration = decorationOverride ??
        InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: widget.options.isDarkMode ? Colors.white54 : Colors.black38,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.all(MediasfuSpacing.md),
          filled: true,
          fillColor: widget.options.isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
        );

    final decoration = baseDecoration.copyWith(
      hintText: decorationOverride?.hintText ?? hintText,
      labelText: decorationOverride?.labelText ?? baseDecoration.labelText,
    );

    return TextField(
      onChanged: onChanged,
      controller: initialValue != null
          ? TextEditingController(text: initialValue)
          : null,
      style: textStyle ??
          TextStyle(
            color: widget.options.isDarkMode ? Colors.white : Colors.black87,
          ),
      decoration: decoration,
    );
  }

  List<Widget> _buildCustomOptions() {
    return List.generate(_customOptions.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: MediasfuSpacing.sm),
        child: _buildTextField(
          hintText: 'Option ${index + 1}',
          initialValue: _customOptions[index],
          onChanged: (value) => _customOptions[index] = value,
          decorationOverride: _optionInputDecoration(index),
          textStyle: _styles.optionInputTextStyle,
        ),
      );
    });
  }

  Widget _buildAddOptionButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _customOptions.add('');
        });
      },
      child: Container(
        padding: const EdgeInsets.all(MediasfuSpacing.sm),
        decoration: BoxDecoration(
          color: MediasfuColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: MediasfuColors.primary.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_rounded,
              color: MediasfuColors.primary,
              size: 18,
            ),
            const SizedBox(width: MediasfuSpacing.xs),
            Text(
              'Add Option',
              style: TextStyle(
                color: MediasfuColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLaunchButton() {
    void launch() {
      List<String> options;
      switch (_pollType) {
        case 'trueFalse':
          options = ['True', 'False'];
          break;
        case 'yesNo':
          options = ['Yes', 'No'];
          break;
        case 'custom':
          options = _customOptions.where((o) => o.isNotEmpty).toList();
          break;
        default:
          widget.options.showAlert?.call(
            message: 'Please select a poll type',
            type: 'danger',
            duration: 3000,
          );
          return;
      }

      if (_pollQuestion.isEmpty || options.length < 2) {
        widget.options.showAlert?.call(
          message: 'Please fill in all fields',
          type: 'danger',
          duration: 3000,
        );
        return;
      }

      widget.options.handleCreatePoll(
        HandleCreatePollOptions(
          poll: Poll(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            question: _pollQuestion,
            type: _pollType,
            options: options,
            votes: List.filled(options.length, 0),
            voters: {},
            status: 'active',
          ),
          socket: widget.options.socket,
          roomName: widget.options.roomName,
          showAlert: widget.options.showAlert,
          updateIsPollModalVisible: widget.options.updateIsPollModalVisible,
        ),
      );
    }

    final createStyle = _styles.createButtonStyle ?? _styles.primaryButtonStyle;

    if (createStyle != null) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: createStyle,
          onPressed: launch,
          child: const Text('Launch Poll'),
        ),
      );
    }

    return GestureDetector(
      onTap: launch,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: MediasfuSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              MediasfuColors.secondary,
              MediasfuColors.primary,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rocket_launch_rounded, color: Colors.white),
            SizedBox(width: MediasfuSpacing.sm),
            Text(
              'Launch Poll',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPollCard(Poll poll,
      {required bool isCompleted, bool showResults = false}) {
    return Container(
      padding: const EdgeInsets.all(MediasfuSpacing.md),
      decoration: BoxDecoration(
        color: widget.options.isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.options.isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: MediasfuSpacing.sm,
                  vertical: MediasfuSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.grey.withOpacity(0.2)
                      : MediasfuColors.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isCompleted ? 'Completed' : 'Active',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? Colors.grey : MediasfuColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: MediasfuSpacing.sm),
          Text(
            poll.question,
            style: _styles.pollItemQuestionTextStyle ??
                TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color:
                      widget.options.isDarkMode ? Colors.white : Colors.black87,
                ),
          ),
          if (showResults && poll.options.isNotEmpty) ...[
            const SizedBox(height: MediasfuSpacing.md),
            ...poll.options.asMap().entries.map((entry) {
              final idx = entry.key;
              final option = entry.value;
              final baseVotes = poll.votes ?? [];
              final safeVotes = List<int>.generate(
                poll.options.length,
                (voteIndex) =>
                    voteIndex < baseVotes.length ? baseVotes[voteIndex] : 0,
              );
              final totalVotes =
                  safeVotes.isEmpty ? 0 : safeVotes.reduce((a, b) => a + b);
              final pct = totalVotes > 0
                  ? (safeVotes[idx] / totalVotes * 100).toStringAsFixed(2)
                  : '0.00';

              return Padding(
                padding: const EdgeInsets.only(bottom: MediasfuSpacing.xs),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          color: widget.options.isDarkMode
                              ? Colors.white70
                              : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      '${safeVotes[idx]} votes ($pct%)',
                      style: _styles.pollResultTextStyle ??
                          TextStyle(
                            color: widget.options.isDarkMode
                                ? Colors.white54
                                : Colors.black54,
                            fontSize: 12,
                          ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildVoteOption({
    required String option,
    required int index,
    required int votes,
    required int percentage,
    required bool isSelected,
    required bool hasVoted,
  }) {
    return GestureDetector(
      onTap: hasVoted ? null : () => setState(() => _selectedOption = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: MediasfuSpacing.sm),
        padding: const EdgeInsets.all(MediasfuSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? MediasfuColors.primary.withOpacity(0.2)
              : (widget.options.isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.03)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? MediasfuColors.primary
                : (widget.options.isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1)),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? MediasfuColors.primary
                      : (widget.options.isDarkMode
                          ? Colors.white30
                          : Colors.black26),
                  width: 2,
                ),
                color: isSelected ? MediasfuColors.primary : null,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: MediasfuSpacing.md),
            Expanded(
              child: Text(
                option,
                style: _styles.currentPollOptionTextStyle ??
                    TextStyle(
                      color: widget.options.isDarkMode
                          ? Colors.white
                          : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            if (hasVoted) ...[
              Text(
                '$votes votes ($percentage%)',
                style: _styles.pollResultTextStyle ??
                    TextStyle(
                      color: widget.options.isDarkMode
                          ? Colors.white54
                          : Colors.black45,
                      fontSize: 12,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitVoteButton() {
    final voteStyle = _styles.voteButtonStyle ?? _styles.primaryButtonStyle;

    if (voteStyle != null) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: voteStyle,
          onPressed: _selectedOption != null
              ? () {
                  widget.options.handleVotePoll(
                    HandleVotePollOptions(
                      pollId: widget.options.poll?.id ?? '',
                      optionIndex: _selectedOption!,
                      socket: widget.options.socket,
                      roomName: widget.options.roomName,
                      showAlert: widget.options.showAlert,
                      member: widget.options.member,
                      updateIsPollModalVisible:
                          widget.options.updateIsPollModalVisible,
                    ),
                  );
                }
              : null,
          child: const Text('Submit Vote'),
        ),
      );
    }

    return GestureDetector(
      onTap: _selectedOption != null
          ? () {
              widget.options.handleVotePoll(
                HandleVotePollOptions(
                  pollId: widget.options.poll?.id ?? '',
                  optionIndex: _selectedOption!,
                  socket: widget.options.socket,
                  roomName: widget.options.roomName,
                  showAlert: widget.options.showAlert,
                  member: widget.options.member,
                  updateIsPollModalVisible:
                      widget.options.updateIsPollModalVisible,
                ),
              );
            }
          : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: MediasfuSpacing.md),
        decoration: BoxDecoration(
          gradient: _selectedOption != null
              ? LinearGradient(
                  colors: [
                    MediasfuColors.primary,
                    MediasfuColors.secondary,
                  ],
                )
              : null,
          color: _selectedOption == null ? Colors.grey.withOpacity(0.3) : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Submit Vote',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _selectedOption != null ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildEndPollButton() {
    final endStyle = _styles.endButtonStyle ?? _styles.destructiveButtonStyle;

    if (endStyle != null) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: endStyle,
          onPressed: () {
            widget.options.handleEndPoll(
              HandleEndPollOptions(
                pollId: widget.options.poll?.id ?? '',
                socket: widget.options.socket,
                roomName: widget.options.roomName,
                showAlert: widget.options.showAlert,
                updateIsPollModalVisible:
                    widget.options.updateIsPollModalVisible,
              ),
            );
          },
          child: const Text('End Poll'),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        widget.options.handleEndPoll(
          HandleEndPollOptions(
            pollId: widget.options.poll?.id ?? '',
            socket: widget.options.socket,
            roomName: widget.options.roomName,
            showAlert: widget.options.showAlert,
            updateIsPollModalVisible: widget.options.updateIsPollModalVisible,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: MediasfuSpacing.md),
        decoration: BoxDecoration(
          color: MediasfuColors.danger.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: MediasfuColors.danger.withOpacity(0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.stop_rounded, color: MediasfuColors.danger),
            const SizedBox(width: MediasfuSpacing.sm),
            Text(
              'End Poll',
              style: TextStyle(
                color: MediasfuColors.danger,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration? _questionInputDecoration() {
    final override = _styles.questionInputDecoration;
    if (override == null) return null;
    final label = override.labelText ?? _styles.questionLabelText;
    return override.copyWith(labelText: label);
  }

  InputDecoration? _optionInputDecoration(int index) {
    final override = _styles.optionInputDecoration;
    if (override == null) return null;
    final label = override.labelText ??
        (_styles.optionLabelBuilder?.call(index) ?? 'Option ${index + 1}');
    return override.copyWith(labelText: label);
  }
}
