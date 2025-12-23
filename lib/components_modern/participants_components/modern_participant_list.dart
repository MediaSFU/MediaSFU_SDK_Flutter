import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../types/types.dart'
    show
        Participant,
        MuteParticipantsType,
        MessageParticipantsType,
        RemoveParticipantsType,
        CoHostResponsibility,
        ShowAlert,
        MuteParticipantsOptions,
        MessageParticipantsOptions,
        RemoveParticipantsOptions;
import '../core/theme/mediasfu_colors.dart';
import '../core/theme/mediasfu_spacing.dart';

/// Configuration options for ModernParticipantList
class ModernParticipantListOptions {
  final List<Participant> participants;
  final bool isBroadcast;
  final MuteParticipantsType onMuteParticipants;
  final MessageParticipantsType onMessageParticipants;
  final RemoveParticipantsType onRemoveParticipants;
  final io.Socket? socket;
  final List<CoHostResponsibility> coHostResponsibility;
  final String member;
  final String islevel;
  final ShowAlert? showAlert;
  final String coHost;
  final String roomName;
  final void Function(bool) updateIsMessagesModalVisible;
  final void Function(Participant?) updateDirectMessageDetails;
  final void Function(bool) updateStartDirectMessage;
  final void Function(List<Participant>) updateParticipants;

  // Modern styling options
  final bool enableGlassmorphism;
  final bool isDarkMode;
  final bool showDividers;

  ModernParticipantListOptions({
    required this.participants,
    required this.isBroadcast,
    required this.onMuteParticipants,
    required this.onMessageParticipants,
    required this.onRemoveParticipants,
    this.socket,
    required this.coHostResponsibility,
    required this.member,
    required this.islevel,
    this.showAlert,
    required this.coHost,
    required this.roomName,
    required this.updateIsMessagesModalVisible,
    required this.updateDirectMessageDetails,
    required this.updateStartDirectMessage,
    required this.updateParticipants,
    // Modern defaults
    this.enableGlassmorphism = true,
    this.isDarkMode = true,
    this.showDividers = false,
  });
}

typedef ModernParticipantListType = Widget Function({
  required ModernParticipantListOptions options,
});

/// A modern participant list with glassmorphic styling.
///
/// Features:
/// - Glassmorphic participant cards
/// - Animated action buttons
/// - Status indicators with gradients
/// - Dark/light mode support
class ModernParticipantList extends StatelessWidget {
  final ModernParticipantListOptions options;

  const ModernParticipantList({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: MediasfuSpacing.sm),
      itemCount: options.participants.length,
      separatorBuilder: (context, index) => options.showDividers
          ? Divider(
              color: (options.isDarkMode ? Colors.white : Colors.black)
                  .withValues(alpha: 0.1),
              height: 1,
            )
          : const SizedBox(height: MediasfuSpacing.xs),
      itemBuilder: (context, index) {
        final participant = options.participants[index];
        return _ModernParticipantListItem(
          participant: participant,
          options: options,
        );
      },
    );
  }
}

/// Modern participant list item with glassmorphic design
class _ModernParticipantListItem extends StatefulWidget {
  final Participant participant;
  final ModernParticipantListOptions options;

  const _ModernParticipantListItem({
    required this.participant,
    required this.options,
  });

  @override
  State<_ModernParticipantListItem> createState() =>
      _ModernParticipantListItemState();
}

class _ModernParticipantListItemState extends State<_ModernParticipantListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.options.isDarkMode;
    final isHost = widget.participant.islevel == '2';
    final isMuted = widget.participant.muted ?? true;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(
          horizontal: MediasfuSpacing.sm,
          vertical: MediasfuSpacing.xs / 2,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: _isHovered
              ? (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08)
              : Colors.transparent,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: widget.options.enableGlassmorphism
              ? BackdropFilter(
                  filter: _isHovered
                      ? ImageFilter.blur(sigmaX: 5, sigmaY: 5)
                      : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                  child: _buildContent(isDark, isHost, isMuted),
                )
              : _buildContent(isDark, isHost, isMuted),
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark, bool isHost, bool isMuted) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: MediasfuSpacing.md,
        vertical: MediasfuSpacing.sm,
      ),
      child: Row(
        children: [
          // Avatar with status
          _buildAvatar(isDark, isHost, isMuted),
          const SizedBox(width: MediasfuSpacing.md),

          // Name and status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.participant.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isHost) ...[
                      const SizedBox(width: MediasfuSpacing.xs),
                      _buildHostBadge(),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                _buildStatusRow(isDark, isMuted),
              ],
            ),
          ),

          // Action buttons
          if (!widget.options.isBroadcast) ...[
            _buildActionButtons(isDark),
          ] else ...[
            _buildRemoveButton(isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isDark, bool isHost, bool isMuted) {
    final initials = widget.participant.name.isNotEmpty
        ? widget.participant.name.substring(0, 1).toUpperCase()
        : '?';

    return Stack(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: isHost
                ? MediasfuColors.brandGradient(darkMode: isDark)
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      isDark
                          ? const Color(0xFF3D3D5C)
                          : const Color(0xFFE0E0E0),
                      isDark
                          ? const Color(0xFF2D2D44)
                          : const Color(0xFFD0D0D0),
                    ],
                  ),
            shape: BoxShape.circle,
            border: Border.all(
              color: isHost
                  ? MediasfuColors.primary.withValues(alpha: 0.5)
                  : (isDark ? Colors.white : Colors.black)
                      .withValues(alpha: 0.1),
              width: isHost ? 2 : 1.5,
            ),
            boxShadow: isHost
                ? MediasfuColors.glowShadow(
                    MediasfuColors.primary,
                    intensity: 0.25,
                  )
                : null,
          ),
          child: Center(
            child: Text(
              initials,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isHost
                    ? Colors.white
                    : (isDark ? Colors.white : Colors.black87),
              ),
            ),
          ),
        ),
        // Mute status indicator with glow
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: isMuted ? MediasfuColors.danger : MediasfuColors.success,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      (isMuted ? MediasfuColors.danger : MediasfuColors.success)
                          .withValues(alpha: 0.4),
                  blurRadius: 6,
                  spreadRadius: 0,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHostBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        gradient: MediasfuColors.brandGradient(darkMode: true),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: MediasfuColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Text(
        'HOST',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildStatusRow(bool isDark, bool isMuted) {
    return Row(
      children: [
        Icon(
          isMuted ? Icons.mic_off_outlined : Icons.mic_outlined,
          size: 14,
          color: isMuted
              ? Colors.red.withValues(alpha: 0.7)
              : MediasfuColors.success.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 4),
        Text(
          isMuted ? 'Muted' : 'Speaking',
          style: TextStyle(
            fontSize: 12,
            color:
                (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isDark) {
    final isMuted = widget.participant.muted ?? true;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIconButton(
          icon: isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
          color: MediasfuColors.primary,
          isDark: isDark,
          tooltip: isMuted
              ? 'Unmute ${widget.participant.name} - Allow them to speak'
              : 'Mute ${widget.participant.name} - Disable their microphone',
          onPressed: () => widget.options.onMuteParticipants(
            MuteParticipantsOptions(
              participant: widget.participant,
              socket: widget.options.socket,
              coHostResponsibility: widget.options.coHostResponsibility,
              member: widget.options.member,
              islevel: widget.options.islevel,
              showAlert: widget.options.showAlert,
              coHost: widget.options.coHost,
              roomName: widget.options.roomName,
            ),
          ),
        ),
        const SizedBox(width: MediasfuSpacing.xs),
        _buildIconButton(
          icon: Icons.message_rounded,
          color: MediasfuColors.secondary,
          isDark: isDark,
          tooltip:
              'Send message to ${widget.participant.name} - Start a private chat',
          onPressed: () => widget.options.onMessageParticipants(
            MessageParticipantsOptions(
              participant: widget.participant,
              coHostResponsibility: widget.options.coHostResponsibility,
              member: widget.options.member,
              islevel: widget.options.islevel,
              showAlert: widget.options.showAlert,
              coHost: widget.options.coHost,
              updateIsMessagesModalVisible:
                  widget.options.updateIsMessagesModalVisible,
              updateDirectMessageDetails:
                  widget.options.updateDirectMessageDetails,
              updateStartDirectMessage: widget.options.updateStartDirectMessage,
            ),
          ),
        ),
        const SizedBox(width: MediasfuSpacing.xs),
        _buildIconButton(
          icon: Icons.person_remove_rounded,
          color: Colors.red,
          isDark: isDark,
          tooltip:
              'Remove ${widget.participant.name} from meeting - They will be disconnected',
          onPressed: () => widget.options.onRemoveParticipants(
            RemoveParticipantsOptions(
              participant: widget.participant,
              socket: widget.options.socket,
              coHostResponsibility: widget.options.coHostResponsibility,
              member: widget.options.member,
              islevel: widget.options.islevel,
              showAlert: widget.options.showAlert,
              coHost: widget.options.coHost,
              roomName: widget.options.roomName,
              participants: widget.options.participants,
              updateParticipants: widget.options.updateParticipants,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRemoveButton(bool isDark) {
    return _buildIconButton(
      icon: Icons.person_remove_rounded,
      color: Colors.red,
      isDark: isDark,
      tooltip:
          'Remove ${widget.participant.name} from meeting - They will be disconnected',
      onPressed: () => widget.options.onRemoveParticipants(
        RemoveParticipantsOptions(
          participant: widget.participant,
          socket: widget.options.socket,
          coHostResponsibility: widget.options.coHostResponsibility,
          member: widget.options.member,
          islevel: widget.options.islevel,
          showAlert: widget.options.showAlert,
          coHost: widget.options.coHost,
          roomName: widget.options.roomName,
          participants: widget.options.participants,
          updateParticipants: widget.options.updateParticipants,
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      decoration: MediasfuColors.tooltipDecoration(darkMode: isDark),
      textStyle: TextStyle(
        color: MediasfuColors.tooltipText(darkMode: isDark),
        fontSize: 12,
      ),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 18,
            color: color,
          ),
        ),
      ),
    );
  }
}

/// Configuration options for ModernParticipantListOthers
class ModernParticipantListOthersOptions {
  final List<Participant> participants;
  final String coHost;
  final String member;

  // Modern styling options
  final bool enableGlassmorphism;
  final bool isDarkMode;
  final bool showDividers;

  ModernParticipantListOthersOptions({
    required this.participants,
    required this.coHost,
    required this.member,
    this.enableGlassmorphism = true,
    this.isDarkMode = true,
    this.showDividers = false,
  });
}

typedef ModernParticipantListOthersType = Widget Function({
  required ModernParticipantListOthersOptions options,
});

/// A modern read-only participant list for viewing other participants.
///
/// Features simplified display without action buttons.
class ModernParticipantListOthers extends StatelessWidget {
  final ModernParticipantListOthersOptions options;

  const ModernParticipantListOthers({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: MediasfuSpacing.sm),
      itemCount: options.participants.length,
      separatorBuilder: (context, index) => options.showDividers
          ? Divider(
              color: (options.isDarkMode ? Colors.white : Colors.black)
                  .withValues(alpha: 0.1),
              height: 1,
            )
          : const SizedBox(height: MediasfuSpacing.xs),
      itemBuilder: (context, index) {
        final participant = options.participants[index];
        return _ModernParticipantListOthersItem(
          participant: participant,
          options: options,
        );
      },
    );
  }
}

/// Modern read-only participant item
class _ModernParticipantListOthersItem extends StatelessWidget {
  final Participant participant;
  final ModernParticipantListOthersOptions options;

  const _ModernParticipantListOthersItem({
    required this.participant,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = options.isDarkMode;
    final isHost = participant.islevel == '2';
    final isCoHost = participant.name == options.coHost;
    final isMuted = participant.muted ?? true;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: MediasfuSpacing.sm,
        vertical: MediasfuSpacing.xs / 2,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: MediasfuSpacing.md,
        vertical: MediasfuSpacing.sm,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          _buildAvatar(isDark, isHost || isCoHost, isMuted),
          const SizedBox(width: MediasfuSpacing.md),

          // Name and role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        participant.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isHost) ...[
                      const SizedBox(width: MediasfuSpacing.xs),
                      _buildRoleBadge('HOST', MediasfuColors.primary),
                    ] else if (isCoHost) ...[
                      const SizedBox(width: MediasfuSpacing.xs),
                      _buildRoleBadge('CO-HOST', MediasfuColors.secondary),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      isMuted ? Icons.mic_off_outlined : Icons.mic_outlined,
                      size: 14,
                      color: isMuted
                          ? Colors.red.withValues(alpha: 0.7)
                          : MediasfuColors.success.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isMuted ? 'Muted' : 'Active',
                      style: TextStyle(
                        fontSize: 12,
                        color: (isDark ? Colors.white : Colors.black)
                            .withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isDark, bool isSpecial, bool isMuted) {
    final initials = participant.name.isNotEmpty
        ? participant.name.substring(0, 1).toUpperCase()
        : '?';

    return Stack(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: isSpecial
                ? LinearGradient(
                    colors: [MediasfuColors.primary, MediasfuColors.secondary],
                  )
                : null,
            color: isSpecial
                ? null
                : (isDark ? const Color(0xFF3D3D5C) : const Color(0xFFE0E0E0)),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              initials,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSpecial
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black54),
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isMuted ? Colors.red : MediasfuColors.success,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MediasfuSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
