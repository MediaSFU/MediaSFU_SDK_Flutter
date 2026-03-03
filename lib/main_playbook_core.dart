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
import 'types/custom_builders.dart'
    show AudioCardType, CustomComponentType, MiniCardType, VideoCardType;
import 'types/types.dart'
    show
        CreateMediaSFURoomOptions,
        EventType,
        JoinMediaSFURoomOptions,
        MediasfuParameters,
        Participant,
        Stream;
import 'types/ui_overrides.dart'
    show ComponentOverride, ContainerStyleOptions, MediasfuUICustomOverrides;

import 'methods/utils/create_room_on_media_sfu.dart'
    show CreateRoomOnMediaSFUType, createRoomOnMediaSFU;
import 'methods/utils/join_room_on_media_sfu.dart'
    show JoinRoomOnMediaSFUType, joinRoomOnMediaSFU;

/// Toggle these booleans or swap enum values to try different configurations.
/// There is no additional UI; modify and hot-reload just like the React App.tsx sample.

enum ConnectionScenario { cloudOnly, hybrid, ceOnly }

enum ExperienceKey { generic, broadcast, webinar, conference, chat }

const ConnectionScenario connectionScenario = ConnectionScenario.cloudOnly;
const ExperienceKey selectedExperience = ExperienceKey.generic;

const bool returnUI = true;
const bool enableCustomWorkspace = false;
const bool provideCardBuilders = true;
const bool applyContainerStyle = false;
const bool applyUIOverrides = true;
const bool applyModalOverrides = true;
const bool useCustomPreJoin = false;
const bool configureNoUIPreJoin = false;
const bool overrideBackendHooks = false;

// Provide credentials per scenario.
final Credentials cloudCredentials = Credentials(
  apiUserName: 'dummyUsr',
  apiKey: '1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
);

final Credentials dummyCredentials = Credentials(
  apiUserName: 'dummyUsr',
  apiKey: '1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
);

final Credentials ceCredentials = Credentials(
  apiUserName: '',
  apiKey: '',
);

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

final Map<ConnectionScenario, ConnectionPreset> connectionPresets = {
  ConnectionScenario.cloudOnly: ConnectionPreset(
    credentials: cloudCredentials,
    localLink: '',
    connectMediaSFU: true,
  ),
  ConnectionScenario.hybrid: ConnectionPreset(
    credentials: dummyCredentials,
    localLink: 'http://localhost:3000',
    connectMediaSFU: true,
  ),
  ConnectionScenario.ceOnly: ConnectionPreset(
    credentials: ceCredentials,
    localLink: 'http://localhost:3000',
    connectMediaSFU: false,
  ),
};

void main() {
  runApp(const _CorePlaybookApp());
}

class _CorePlaybookApp extends StatefulWidget {
  const _CorePlaybookApp();

  @override
  State<_CorePlaybookApp> createState() => _CorePlaybookAppState();
}

class _CorePlaybookAppState extends State<_CorePlaybookApp> {
  final ValueNotifier<MediasfuParameters?> _parameters =
      ValueNotifier<MediasfuParameters?>(null);

  ConnectionPreset get preset =>
      connectionPresets[connectionScenario] ?? connectionPresets.values.first;

  CustomComponentType? get customWorkspace =>
      enableCustomWorkspace ? _buildCustomWorkspace : null;

  VideoCardType? get customVideoCard =>
      provideCardBuilders ? _customVideoCard : null;

  AudioCardType? get customAudioCard =>
      provideCardBuilders ? _customAudioCard : null;

  MiniCardType? get customMiniCard =>
      provideCardBuilders ? _customMiniCard : null;

  ContainerStyleOptions? get containerStyle => applyContainerStyle
      ? const ContainerStyleOptions(
          margin: EdgeInsets.all(0),
          padding: EdgeInsets.all(0),
        )
      : null;

  /// Aggregates the UI override surface showcased in the README's inline
  /// example. Flip the feature flags at the top of the file to explore how
  /// `MediasfuUICustomOverrides` can restyle container chrome, pagination,
  /// alert banners, or modal shells without rewriting an entire experience.
  ///
  /// When both [applyUIOverrides] and [applyModalOverrides] are `false` this
  /// getter returns `null`, allowing the experiences to fall back to stock UI.
  MediasfuUICustomOverrides? get uiOverrides {
    if (!applyUIOverrides && !applyModalOverrides) {
      return null;
    }

    return MediasfuUICustomOverrides(
      mainContainer: applyUIOverrides
          ? ComponentOverride<MainContainerComponentOptions>(
              render: (context, options, defaultBuilder) {
                final child = defaultBuilder(context, options);
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x16000000),
                        blurRadius: 18,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: child,
                );
              },
            )
          : null,
      pagination: applyUIOverrides
          ? ComponentOverride<PaginationOptions>(
              render: (context, options, defaultBuilder) {
                final widget = defaultBuilder(context, options);
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0ea5e9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: widget,
                );
              },
            )
          : null,
      alert: applyUIOverrides
          ? ComponentOverride<AlertComponentOptions>(
              render: (context, options, defaultBuilder) {
                final widget = defaultBuilder(context, options);
                return DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366f1), Color(0xFF14b8a6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: widget,
                );
              },
            )
          : null,
      menuModal: applyModalOverrides
          ? ComponentOverride<MenuModalOptions>(
              render: (context, options, defaultBuilder) {
                final widget = defaultBuilder(context, options);
                return Theme(
                  data: Theme.of(context).copyWith(
                    dialogTheme: const DialogThemeData(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                      ),
                    ),
                  ),
                  child: widget,
                );
              },
            )
          : null,
      shareEventModal: applyModalOverrides
          ? ComponentOverride<ShareEventModalOptions>(
              render: (context, options, defaultBuilder) {
                final widget = defaultBuilder(context, options);
                return Container(
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x1C2563EB),
                        blurRadius: 28,
                        offset: Offset(0, 18),
                      ),
                    ],
                  ),
                  child: widget,
                );
              },
            )
          : null,
      participantsModal: applyModalOverrides
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
    );
  }

  CreateMediaSFURoomOptions? get noUIRoomCreateOptions => configureNoUIPreJoin
      ? CreateMediaSFURoomOptions(
          action: 'create',
          duration: 15,
          capacity: 12,
          userName: 'Playbook Host',
          eventType: EventType.broadcast,
        )
      : null;

  JoinMediaSFURoomOptions? get noUIRoomJoinOptions => configureNoUIPreJoin
      ? JoinMediaSFURoomOptions(
          action: 'join',
          meetingID: 'YOUR_MEETING_ID',
          userName: 'Guest',
        )
      : null;

  JoinRoomOnMediaSFUType get joinProxy => overrideBackendHooks
      ? (options) {
          debugPrint(
              '[Core Playbook] join payload: ${options.payload.meetingID}');
          return joinRoomOnMediaSFU(options);
        }
      : joinRoomOnMediaSFU;

  CreateRoomOnMediaSFUType get createProxy => overrideBackendHooks
      ? (options) {
          debugPrint(
              '[Core Playbook] create payload: ${options.payload.userName}');
          return createRoomOnMediaSFU(options);
        }
      : createRoomOnMediaSFU;

  PreJoinPageType? get customPreJoin => useCustomPreJoin
      ? ({PreJoinPageOptions? options}) => Center(
            child: ElevatedButton(
              onPressed: () => options?.parameters.updateValidated(true),
              child: const Text('Continue to room'),
            ),
          )
      : null;

  @override
  void dispose() {
    _parameters.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: _buildExperience(),
      ),
    );
  }

  Widget _buildExperience() {
    switch (selectedExperience) {
      case ExperienceKey.generic:
        return MediasfuGeneric(
          options: MediasfuGenericOptions(
            preJoinPageWidget: customPreJoin,
            localLink: preset.localLink,
            connectMediaSFU: preset.connectMediaSFU,
            credentials: preset.credentials,
            returnUI: returnUI,
            // sourceParameters: _parameters.value,
            // updateSourceParameters: (value) => _parameters.value = value,
            // customComponent: customWorkspace,
            customVideoCard: customVideoCard,
            customAudioCard: customAudioCard,
            customMiniCard: customMiniCard,
            // containerStyle: containerStyle,
            uiOverrides: uiOverrides,
            // noUIPreJoinOptionsCreate: noUIRoomCreateOptions,
            // noUIPreJoinOptionsJoin: noUIRoomJoinOptions,
            // joinMediaSFURoom: joinProxy,
            // createMediaSFURoom: createProxy,
          ),
        );
      case ExperienceKey.broadcast:
        return MediasfuBroadcast(
          options: MediasfuBroadcastOptions(
            preJoinPageWidget: customPreJoin,
            localLink: preset.localLink,
            connectMediaSFU: preset.connectMediaSFU,
            credentials: preset.credentials,
            returnUI: returnUI,
            sourceParameters: _parameters.value,
            updateSourceParameters: (value) => _parameters.value = value,
            customComponent: customWorkspace,
            customVideoCard: customVideoCard,
            customAudioCard: customAudioCard,
            customMiniCard: customMiniCard,
            containerStyle: containerStyle,
            uiOverrides: uiOverrides,
            noUIPreJoinOptionsCreate: noUIRoomCreateOptions,
            noUIPreJoinOptionsJoin: noUIRoomJoinOptions,
            joinMediaSFURoom: joinProxy,
            createMediaSFURoom: createProxy,
          ),
        );
      case ExperienceKey.webinar:
        return MediasfuWebinar(
          options: MediasfuWebinarOptions(
            preJoinPageWidget: customPreJoin,
            localLink: preset.localLink,
            connectMediaSFU: preset.connectMediaSFU,
            credentials: preset.credentials,
            returnUI: returnUI,
            sourceParameters: _parameters.value,
            updateSourceParameters: (value) => _parameters.value = value,
            customComponent: customWorkspace,
            customVideoCard: customVideoCard,
            customAudioCard: customAudioCard,
            customMiniCard: customMiniCard,
            containerStyle: containerStyle,
            uiOverrides: uiOverrides,
            noUIPreJoinOptionsCreate: noUIRoomCreateOptions,
            noUIPreJoinOptionsJoin: noUIRoomJoinOptions,
            joinMediaSFURoom: joinProxy,
            createMediaSFURoom: createProxy,
          ),
        );
      case ExperienceKey.conference:
        return MediasfuConference(
          options: MediasfuConferenceOptions(
            preJoinPageWidget: customPreJoin,
            localLink: preset.localLink,
            connectMediaSFU: preset.connectMediaSFU,
            credentials: preset.credentials,
            returnUI: returnUI,
            sourceParameters: _parameters.value,
            updateSourceParameters: (value) => _parameters.value = value,
            customComponent: customWorkspace,
            customVideoCard: customVideoCard,
            customAudioCard: customAudioCard,
            customMiniCard: customMiniCard,
            containerStyle: containerStyle,
            uiOverrides: uiOverrides,
            noUIPreJoinOptionsCreate: noUIRoomCreateOptions,
            noUIPreJoinOptionsJoin: noUIRoomJoinOptions,
            joinMediaSFURoom: joinProxy,
            createMediaSFURoom: createProxy,
          ),
        );
      case ExperienceKey.chat:
        return MediasfuChat(
          options: MediasfuChatOptions(
            preJoinPageWidget: customPreJoin,
            localLink: preset.localLink,
            connectMediaSFU: preset.connectMediaSFU,
            credentials: preset.credentials,
            returnUI: returnUI,
            sourceParameters: _parameters.value,
            updateSourceParameters: (value) => _parameters.value = value,
            customComponent: customWorkspace,
            customVideoCard: customVideoCard,
            customAudioCard: customAudioCard,
            customMiniCard: customMiniCard,
            containerStyle: containerStyle,
            uiOverrides: uiOverrides,
            noUIPreJoinOptionsCreate: noUIRoomCreateOptions,
            noUIPreJoinOptionsJoin: noUIRoomJoinOptions,
            joinMediaSFURoom: joinProxy,
            createMediaSFURoom: createProxy,
          ),
        );
    }
  }

  Widget _buildCustomWorkspace({required MediasfuParameters parameters}) {
    return Column(
      children: [
        Text('Custom workspace active for room: ${parameters.roomName}'),
        ElevatedButton(
          onPressed: () => parameters.showAlert(
            message: 'Custom workspace interacting with helpers',
            type: 'success',
            duration: 3000,
          ),
          child: const Text('Trigger helper alert'),
        ),
      ],
    );
  }

  /// Rich sample video-card override that mirrors the React `AppUnique.tsx`
  /// playground. It renders the production [VideoCard] when MediaSFU helper
  /// parameters are available and gracefully falls back to a branded tile
  /// otherwise. Width and height are provided by the SDK to ensure the card
  /// fits within the responsive grids.
  Widget _customVideoCard({
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

    final Widget content = params != null
        ? VideoCard(
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
          )
        : _videoFallback(name ?? participant.name);

    final Widget expandedContent = SizedBox.expand(
      child: onVideoPress != null
          ? GestureDetector(onTap: onVideoPress, child: content)
          : content,
    );

    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF312e81), Color(0xFF2563eb)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x332563eb),
            blurRadius: 24,
            offset: Offset(0, 16),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFc4b5fd),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: expandedContent,
      ),
    );
  }

  /// Custom audio-card builder used to demonstrate how bar colour and metadata
  /// can map to your own gradients or iconography. The `barColor` boolean
  /// supplied by MediaSFU indicates whether the participant is actively
  /// speaking.
  Widget _customAudioCard({
    required String name,
    required bool barColor,
    required Color textColor,
    required String imageSource,
    required double roundedImage,
    required Color imageStyle,
    dynamic parameters,
  }) {
    final bool active = barColor;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: active
              ? const [Color(0xFF14532d), Color(0xFF22c55e)]
              : const [Color(0xFF1f2937), Color(0xFF4b5563)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2214b8a6),
            blurRadius: 18,
            offset: Offset(0, 12),
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
                    color: Colors.white.withOpacity(0.74),
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

  /// Branded mini-card override that emphasises participant initials and media
  /// status icons. MediaSFU passes `fontSize` as a string for parity with the
  /// web SDK; we convert it to a `double` and provide defaults that avoid
  /// overflow in compact grids.
  Widget _customMiniCard({
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
    final double parsed = double.tryParse(fontSize) ?? 18;
    final String displayInitials = initials.isNotEmpty
        ? initials
        : name.characters.take(2).join().toUpperCase();

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            displayInitials,
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
                  if (showVideoIcon && showAudioIcon) const SizedBox(width: 6),
                  if (showAudioIcon)
                    const Icon(Icons.mic, size: 14, color: Color(0xFFF97316)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Fallback tile shown while the underlying MediaSFU `parameters` bundle is
  /// still loading. Keeps the layout stable, mirrors the video-card styling,
  /// and surfaces the participant name.
  Widget _videoFallback(String name) {
    return Container(
      color: const Color(0xFF0f172a),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.videocam_off, color: Colors.white70, size: 40),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(color: Colors.white70),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
