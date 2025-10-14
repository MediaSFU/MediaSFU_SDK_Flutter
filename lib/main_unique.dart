import 'package:flutter/material.dart';

import 'components/mediasfu_components/mediasfu_broadcast.dart'
    show MediasfuBroadcast, MediasfuBroadcastOptions;
import 'components/mediasfu_components/mediasfu_chat.dart'
    show MediasfuChat, MediasfuChatOptions;
import 'components/mediasfu_components/mediasfu_conference.dart'
    show MediasfuConference, MediasfuConferenceOptions;
import 'components/mediasfu_components/mediasfu_generic.dart'
    show MediasfuGeneric, MediasfuGenericOptions;
import 'components/mediasfu_components/mediasfu_webinar.dart'
    show MediasfuWebinar, MediasfuWebinarOptions;
import 'components/misc_components/prejoin_page.dart'
    show Credentials, PreJoinPageOptions, PreJoinPageType;
import 'components/display_components/video_card.dart'
    show VideoCard, VideoCardOptions;
import 'components/display_components/main_container_component.dart'
    show MainContainerComponentOptions;
import 'components/display_components/pagination.dart' show PaginationOptions;
import 'components/display_components/alert_component.dart'
    show AlertComponentOptions;
import 'components/menu_components/menu_modal.dart' show MenuModalOptions;
import 'components/misc_components/share_event_modal.dart'
    show ShareEventModalOptions;
import 'components/participants_components/participants_modal.dart'
    show ParticipantsModalOptions;
import 'consumers/consumer_resume.dart' show ConsumerResumeType;
import 'methods/utils/create_room_on_media_sfu.dart'
    show CreateRoomOnMediaSFUType, createRoomOnMediaSFU;
import 'methods/utils/join_room_on_media_sfu.dart'
    show JoinRoomOnMediaSFUType, joinRoomOnMediaSFU;
import 'types/custom_builders.dart'
    show AudioCardType, CustomComponentType, MiniCardType, VideoCardType;
import 'types/types.dart'
    show
        EventType,
        MediasfuParameters,
        Participant,
        Stream,
        CreateMediaSFURoomOptions,
        JoinMediaSFURoomOptions;
import 'types/ui_overrides.dart'
    show
        ComponentOverride,
        ContainerStyleOptions,
        FunctionOverride,
        MediasfuUICustomOverrides;

/// Toggle the scenarios and UI strategies below to explore MediaSFU's
/// customization layers.
enum ConnectionScenario { cloud, hybrid, ce }

enum ExperienceKey { generic, broadcast, webinar, conference, chat }

const ConnectionScenario connectionScenario = ConnectionScenario.cloud;
const ExperienceKey selectedExperience = ExperienceKey.generic;

const bool showPrebuiltUI = true;
const bool enableFullCustomUI = false;
const bool enableCardBuilders = true;
const bool enableUICoreOverrides = true;
const bool enableModalOverrides = true;
const bool enableContainerStyling = true;
const bool enableBackendProxyHooks = true;
const bool enableDebugPanel = true;
const bool enableCustomPreJoin = true;

class ConnectionPreset {
  final Credentials? credentials;
  final String localLink;
  final bool connectMediaSFU;

  const ConnectionPreset({
    required this.credentials,
    required this.localLink,
    required this.connectMediaSFU,
  });
}

final Map<ConnectionScenario, ConnectionPreset> _connectionPresets = {
  ConnectionScenario.cloud: ConnectionPreset(
    credentials: Credentials(
      apiUserName: 'yourDevUser',
      apiKey:
          'yourDevApiKey1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
    ),
    localLink: '',
    connectMediaSFU: true,
  ),
  ConnectionScenario.hybrid: ConnectionPreset(
    credentials: Credentials(
      apiUserName: 'dummyUsr',
      apiKey:
          '1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
    ),
    localLink: 'http://localhost:3000',
    connectMediaSFU: true,
  ),
  ConnectionScenario.ce: ConnectionPreset(
    credentials: null,
    localLink: 'http://localhost:3000',
    connectMediaSFU: false,
  ),
};

void main() {
  runApp(const MainUniqueApp());
}

class MainUniqueApp extends StatefulWidget {
  const MainUniqueApp({super.key});

  @override
  State<MainUniqueApp> createState() => _MainUniqueAppState();
}

class _MainUniqueAppState extends State<MainUniqueApp> {
  final ValueNotifier<MediasfuParameters?> _parameters =
      ValueNotifier<MediasfuParameters?>(null);

  ConnectionPreset get _preset =>
      _connectionPresets[connectionScenario] ?? _connectionPresets.values.first;

  bool get _returnPrebuiltUI => showPrebuiltUI && !enableFullCustomUI;

  bool get _useHeadlessPreJoin => !_returnPrebuiltUI;

  CustomComponentType? get _customWorkspaceBuilder {
    if (enableFullCustomUI) {
      return _playbookWorkspace;
    }
    if (_useHeadlessPreJoin) {
      return _headlessPlaceholder;
    }
    return null;
  }

  ContainerStyleOptions? get _containerStyle => enableContainerStyling
      ? const ContainerStyleOptions(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1e1b4b), Color(0xFF312e81)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.all(Radius.circular(28)),
          ),
        )
      : null;

  MediasfuUICustomOverrides? get _uiOverrides =>
      (!enableUICoreOverrides && !enableModalOverrides)
          ? null
          : MediasfuUICustomOverrides(
              mainContainer: enableUICoreOverrides
                  ? ComponentOverride<MainContainerComponentOptions>(
                      render: (context, options, defaultBuilder) {
                        final child = defaultBuilder(context, options);
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.82),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x332563eb),
                                blurRadius: 28,
                                offset: Offset(0, 16),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: child,
                        );
                      },
                    )
                  : null,
              pagination: enableUICoreOverrides
                  ? ComponentOverride<PaginationOptions>(
                      render: (context, options, defaultBuilder) {
                        final widget = defaultBuilder(context, options);
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0ea5e9),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: widget,
                        );
                      },
                    )
                  : null,
              alert: enableUICoreOverrides
                  ? ComponentOverride<AlertComponentOptions>(
                      render: (context, options, defaultBuilder) {
                        final widget = defaultBuilder(context, options);
                        return Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6d28d9), Color(0xFF2563eb)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: widget,
                        );
                      },
                    )
                  : null,
              menuModal: enableModalOverrides
                  ? ComponentOverride<MenuModalOptions>(
                      render: (context, options, defaultBuilder) {
                        final widget = defaultBuilder(context, options);
                        return Theme(
                          data: Theme.of(context).copyWith(
                            dialogTheme: const DialogThemeData(
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(24)),
                              ),
                            ),
                          ),
                          child: widget,
                        );
                      },
                    )
                  : null,
              shareEventModal: enableModalOverrides
                  ? ComponentOverride<ShareEventModalOptions>(
                      render: (context, options, defaultBuilder) {
                        final widget = defaultBuilder(context, options);
                        return Container(
                          decoration: BoxDecoration(
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x338b5cf6),
                                blurRadius: 36,
                                offset: Offset(0, 20),
                              ),
                            ],
                          ),
                          child: widget,
                        );
                      },
                    )
                  : null,
              participantsModal: enableModalOverrides
                  ? ComponentOverride<ParticipantsModalOptions>(
                      render: (context, options, defaultBuilder) {
                        final widget = defaultBuilder(context, options);
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: widget,
                        );
                      },
                    )
                  : null,
              consumerResume: enableUICoreOverrides
                  ? FunctionOverride<ConsumerResumeType>(
                      wrap: (original) => (params) async {
                        final started = DateTime.now();
                        final result = await original(params);
                        debugPrint(
                          '[MainUnique] consumerResume completed in '
                          '${DateTime.now().difference(started).inMilliseconds}ms',
                        );
                        return result;
                      },
                    )
                  : null,
            );

  CreateMediaSFURoomOptions? get _noUiPreJoinOptionsCreate =>
      _useHeadlessPreJoin
          ? CreateMediaSFURoomOptions(
              action: 'create',
              duration: 15,
              capacity: 12,
              eventType: EventType.broadcast,
              userName: 'Playbook Host',
            )
          : null;

  JoinMediaSFURoomOptions? get _noUiPreJoinOptionsJoin => null;

  JoinRoomOnMediaSFUType? get _joinRoomProxy => enableBackendProxyHooks
      ? (options) async {
          debugPrint('[MainUnique] joinRoomOnMediaSFU payload '
              '(${options.payload.meetingID})');
          return joinRoomOnMediaSFU(options);
        }
      : null;

  CreateRoomOnMediaSFUType? get _createRoomProxy => enableBackendProxyHooks
      ? (options) async {
          debugPrint('[MainUnique] createRoomOnMediaSFU payload '
              '(${options.payload.userName})');
          return createRoomOnMediaSFU(options);
        }
      : null;

  VideoCardType? get _customVideoCard => enableCardBuilders
      ? ({
          required Participant participant,
          required Stream stream,
          required double width,
          required double height,
          int? imageSize,
          String? doMirror,
          bool? showControls,
          bool? showInfo,
          String? name,
          Color? backgroundColor,
          VoidCallback? onVideoPress,
          dynamic parameters,
        }) {
          final params = parameters is MediasfuParameters ? parameters : null;
          if (params == null) {
            return _videoFallbackTile(name ?? participant.name);
          }

          final card = VideoCard(
            options: VideoCardOptions(
              parameters: params,
              name: name ?? participant.name,
              remoteProducerId: stream.producerId,
              eventType: params.eventType,
              videoStream: stream.stream,
              participant: participant,
              backgroundColor: backgroundColor ?? const Color(0xFF0f172a),
              showControls: showControls ?? true,
              showInfo: showInfo ?? true,
              forceFullDisplay: false,
              doMirror: doMirror == 'true',
            ),
          );

          return Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF312e81), Color(0xFF2563eb)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(26),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x442563eb),
                  blurRadius: 30,
                  offset: Offset(0, 22),
                ),
              ],
              border: Border.all(
                color: const Color(0xFFc4b5fd),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: card,
            ),
          );
        }
      : null;

  AudioCardType? get _customAudioCard => enableCardBuilders
      ? ({
          required String name,
          required bool barColor,
          required Color textColor,
          required String imageSource,
          required double roundedImage,
          required Color imageStyle,
          dynamic parameters,
        }) {
          final active = barColor;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF14532d), Color(0xFF22c55e)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x3322c55e),
                  blurRadius: 24,
                  offset: Offset(0, 16),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  active ? Icons.graphic_eq : Icons.hearing_disabled,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name.isEmpty ? 'Audio participant' : name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        active ? 'Microphone live' : 'Muted',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: active ? const Color(0xFFbbf7d0) : Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.volume_up,
                    size: 18,
                    color: Color(0xFF0f172a),
                  ),
                ),
              ],
            ),
          );
        }
      : null;

  MiniCardType? get _customMiniCard => enableCardBuilders
      ? ({
          required String initials,
          required String fontSize,
          bool? customStyle,
          required String name,
          required bool showVideoIcon,
          required bool showAudioIcon,
          required String imageSource,
          required double roundedImage,
          required Color imageStyle,
          dynamic parameters,
        }) {
          final parsed = double.tryParse(fontSize) ?? 18;
          return Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF59E0B), width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  initials.isEmpty
                      ? name.characters.take(2).join().toUpperCase()
                      : initials,
                  style: TextStyle(
                    color: const Color(0xFFB45309),
                    fontWeight: FontWeight.w700,
                    fontSize: parsed,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  name,
                  style: const TextStyle(
                    color: Color(0xFF92400E),
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (showVideoIcon || showAudioIcon)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (showVideoIcon)
                          const Icon(Icons.videocam,
                              size: 14, color: Color(0xFFFB923C)),
                        if (showVideoIcon && showAudioIcon)
                          const SizedBox(width: 6),
                        if (showAudioIcon)
                          const Icon(Icons.mic,
                              size: 14, color: Color(0xFFF97316)),
                      ],
                    ),
                  ),
              ],
            ),
          );
        }
      : null;

  PreJoinPageType? get _customPreJoin => enableCustomPreJoin
      ? ({PreJoinPageOptions? options}) {
          return Scaffold(
            backgroundColor: const Color(0xFF0f172a),
            body: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Welcome to the MediaSFU Playbook',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Adjust the toggles in lib/main_unique.dart to mimic your '
                      'deployment scenario, then tap below to continue with the live session.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () =>
                          options?.parameters.updateValidated(true),
                      icon: const Icon(Icons.rocket_launch_outlined),
                      label: const Text('Let\'s join the room'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      : null;

  @override
  void dispose() {
    _parameters.dispose();
    super.dispose();
  }

  void _handleParametersUpdate(MediasfuParameters? params) {
    _parameters.value = params;
    if (enableDebugPanel && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF312e81)),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('MediaSFU Flutter Playbook (main_unique.dart)'),
        ),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildSummaryBanner(),
                  const Divider(height: 1),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(24),
                      ),
                      child: _buildExperience(),
                    ),
                  ),
                ],
              ),
            ),
            if (enableDebugPanel)
              SizedBox(
                width: 320,
                child: _buildDebugPanel(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBanner() {
    final chips = <Widget>[
      _buildChip('Scenario: ${connectionScenario.name}'),
      _buildChip('Experience: ${selectedExperience.name}'),
      _buildChip(_returnPrebuiltUI ? 'Prebuilt UI' : 'Headless logic'),
    ];

    if (enableFullCustomUI) {
      chips.add(_buildChip('Custom workspace enabled'));
    }
    if (enableCardBuilders) {
      chips.add(_buildChip('Card builders active'));
    }
    if (enableUICoreOverrides || enableModalOverrides) {
      chips.add(_buildChip('uiOverrides in use'));
    }
    if (enableBackendProxyHooks) {
      chips.add(_buildChip('Proxying create/join hooks'));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      color: const Color(0xFFF1F5F9),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: chips,
      ),
    );
  }

  Widget _buildChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: const Color(0xFFE0E7FF),
    );
  }

  Widget _buildExperience() {
    switch (selectedExperience) {
      case ExperienceKey.generic:
        return MediasfuGeneric(
          options: MediasfuGenericOptions(
            preJoinPageWidget: _customPreJoin,
            localLink: _preset.localLink,
            connectMediaSFU: _preset.connectMediaSFU,
            credentials: _preset.credentials,
            returnUI: _returnPrebuiltUI,
            noUIPreJoinOptionsCreate: _noUiPreJoinOptionsCreate,
            noUIPreJoinOptionsJoin: _noUiPreJoinOptionsJoin,
            sourceParameters: _parameters.value,
            updateSourceParameters: _handleParametersUpdate,
            customVideoCard: _customVideoCard,
            customAudioCard: _customAudioCard,
            customMiniCard: _customMiniCard,
            customComponent: _customWorkspaceBuilder,
            containerStyle: _containerStyle,
            uiOverrides: _uiOverrides,
            joinMediaSFURoom: _joinRoomProxy,
            createMediaSFURoom: _createRoomProxy,
          ),
        );
      case ExperienceKey.broadcast:
        return MediasfuBroadcast(
          options: MediasfuBroadcastOptions(
            preJoinPageWidget: _customPreJoin,
            localLink: _preset.localLink,
            connectMediaSFU: _preset.connectMediaSFU,
            credentials: _preset.credentials,
            returnUI: _returnPrebuiltUI,
            noUIPreJoinOptionsCreate: _noUiPreJoinOptionsCreate,
            noUIPreJoinOptionsJoin: _noUiPreJoinOptionsJoin,
            sourceParameters: _parameters.value,
            updateSourceParameters: _handleParametersUpdate,
            customVideoCard: _customVideoCard,
            customAudioCard: _customAudioCard,
            customMiniCard: _customMiniCard,
            customComponent: _customWorkspaceBuilder,
            containerStyle: _containerStyle,
            uiOverrides: _uiOverrides,
            joinMediaSFURoom: _joinRoomProxy,
            createMediaSFURoom: _createRoomProxy,
          ),
        );
      case ExperienceKey.webinar:
        return MediasfuWebinar(
          options: MediasfuWebinarOptions(
            preJoinPageWidget: _customPreJoin,
            localLink: _preset.localLink,
            connectMediaSFU: _preset.connectMediaSFU,
            credentials: _preset.credentials,
            returnUI: _returnPrebuiltUI,
            noUIPreJoinOptionsCreate: _noUiPreJoinOptionsCreate,
            noUIPreJoinOptionsJoin: _noUiPreJoinOptionsJoin,
            sourceParameters: _parameters.value,
            updateSourceParameters: _handleParametersUpdate,
            customVideoCard: _customVideoCard,
            customAudioCard: _customAudioCard,
            customMiniCard: _customMiniCard,
            customComponent: _customWorkspaceBuilder,
            containerStyle: _containerStyle,
            uiOverrides: _uiOverrides,
            joinMediaSFURoom: _joinRoomProxy,
            createMediaSFURoom: _createRoomProxy,
          ),
        );
      case ExperienceKey.conference:
        return MediasfuConference(
          options: MediasfuConferenceOptions(
            preJoinPageWidget: _customPreJoin,
            localLink: _preset.localLink,
            connectMediaSFU: _preset.connectMediaSFU,
            credentials: _preset.credentials,
            returnUI: _returnPrebuiltUI,
            noUIPreJoinOptionsCreate: _noUiPreJoinOptionsCreate,
            noUIPreJoinOptionsJoin: _noUiPreJoinOptionsJoin,
            sourceParameters: _parameters.value,
            updateSourceParameters: _handleParametersUpdate,
            customVideoCard: _customVideoCard,
            customAudioCard: _customAudioCard,
            customMiniCard: _customMiniCard,
            customComponent: _customWorkspaceBuilder,
            containerStyle: _containerStyle,
            uiOverrides: _uiOverrides,
            joinMediaSFURoom: _joinRoomProxy,
            createMediaSFURoom: _createRoomProxy,
          ),
        );
      case ExperienceKey.chat:
        return MediasfuChat(
          options: MediasfuChatOptions(
            preJoinPageWidget: _customPreJoin,
            localLink: _preset.localLink,
            connectMediaSFU: _preset.connectMediaSFU,
            credentials: _preset.credentials,
            returnUI: _returnPrebuiltUI,
            noUIPreJoinOptionsCreate: _noUiPreJoinOptionsCreate,
            noUIPreJoinOptionsJoin: _noUiPreJoinOptionsJoin,
            sourceParameters: _parameters.value,
            updateSourceParameters: _handleParametersUpdate,
            customVideoCard: _customVideoCard,
            customAudioCard: _customAudioCard,
            customMiniCard: _customMiniCard,
            customComponent: _customWorkspaceBuilder,
            containerStyle: _containerStyle,
            uiOverrides: _uiOverrides,
            joinMediaSFURoom: _joinRoomProxy,
            createMediaSFURoom: _createRoomProxy,
          ),
        );
    }
  }

  Widget _buildDebugPanel() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFF0f172a),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Live Parameters',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            Expanded(
              child: ValueListenableBuilder<MediasfuParameters?>(
                valueListenable: _parameters,
                builder: (context, params, _) {
                  if (params == null) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Interact with the session to populate this panel. '
                          'When MediaSFU hands you the helper bundle it will '
                          'appear here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    );
                  }

                  final rows = <Widget>[
                    _debugLine('Room',
                        params.roomName.isEmpty ? 'pending' : params.roomName),
                    _debugLine(
                        'Member', params.member.isEmpty ? '—' : params.member),
                    _debugLine('Event type', params.eventType.name),
                    _debugLine(
                        'Participants', params.participants.length.toString()),
                  ];

                  if (params.participants.isNotEmpty) {
                    rows.add(const Padding(
                      padding: EdgeInsets.only(top: 12, left: 16, right: 16),
                      child: Text(
                        'Recently joined:',
                        style: TextStyle(color: Colors.white60),
                      ),
                    ));
                    rows.add(
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: params.participants
                              .take(5)
                              .map((participant) => Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      '• ${participant.name}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    children: rows,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _debugLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _videoFallbackTile(String? label) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF0f172a),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label ?? 'Participant',
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }

  Widget _playbookWorkspace({required MediasfuParameters parameters}) {
    return Material(
      color: const Color(0xFF0f172a),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Custom Workspace',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Room ${parameters.roomName.isEmpty ? 'pending' : parameters.roomName} · '
                  'Participants ${parameters.participants.length}',
                  style: const TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Host Toolbox',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                parameters.showAlert(
                                  message:
                                      'Custom workspace calling MediaSFU helpers!',
                                  type: 'success',
                                  duration: 4000,
                                );
                              },
                              icon: const Icon(Icons.celebration_outlined),
                              label: const Text('Trigger success toast'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () =>
                                  parameters.updateIsMenuModalVisible(true),
                              icon: const Icon(
                                  Icons.dashboard_customize_outlined),
                              label: const Text('Open menu modal'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Participants snapshot',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: ListView(
                              padding: const EdgeInsets.all(16),
                              children: parameters.participants
                                  .map(
                                    (participant) => ListTile(
                                      dense: true,
                                      contentPadding: EdgeInsets.zero,
                                      title: Text(
                                        participant.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Level ${participant.islevel ?? 'viewer'}',
                                        style: const TextStyle(
                                          color: Colors.white54,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
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
    );
  }

  Widget _headlessPlaceholder({required MediasfuParameters parameters}) {
    return const Material(
      color: Color(0xFF111827),
      child: Center(
        child: Text(
          'MediaSFU logic is running without the bundled UI. '
          'Provide a CustomComponentType to paint your own workspace.',
          style: TextStyle(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
