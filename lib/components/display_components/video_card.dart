import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart'
    show MediaStream;
import 'package:socket_io_client/socket_io_client.dart' as io;
import './card_video_display.dart'
    show CardVideoDisplay, CardVideoDisplayOptions;
import './audio_decibel_check.dart'
    show
        AudioDecibelCheck,
        AudioDecibelCheckOptions,
        AudioDecibelCheckParameters;
import '../../consumers/control_media.dart'
    show controlMedia, ControlMediaOptions, ControlMediaType;
import '../../types/types.dart'
    show
        AudioDecibels,
        Participant,
        CoHostResponsibility,
        ShowAlert,
        EventType,
        LiveSubtitle;

class VideoCardWrapperContext {
  final BuildContext buildContext;
  final VideoCardOptions options;
  final List<Widget> stackChildren;
  final Widget defaultWrapper;

  const VideoCardWrapperContext({
    required this.buildContext,
    required this.options,
    required this.stackChildren,
    required this.defaultWrapper,
  });
}

class VideoCardContainerContext {
  final BuildContext buildContext;
  final VideoCardOptions options;
  final Widget child;
  final Widget defaultContainer;

  const VideoCardContainerContext({
    required this.buildContext,
    required this.options,
    required this.child,
    required this.defaultContainer,
  });
}

class VideoCardInfoContext {
  final BuildContext buildContext;
  final VideoCardOptions options;
  final Widget nameBadge;
  final Widget waveform;
  final Widget defaultInfo;

  const VideoCardInfoContext({
    required this.buildContext,
    required this.options,
    required this.nameBadge,
    required this.waveform,
    required this.defaultInfo,
  });
}

class VideoCardOverlayContext {
  final BuildContext buildContext;
  final VideoCardOptions options;
  final bool showWaveform;
  final Widget waveform;
  final Widget defaultOverlay;

  const VideoCardOverlayContext({
    required this.buildContext,
    required this.options,
    required this.showWaveform,
    required this.waveform,
    required this.defaultOverlay,
  });
}

class VideoCardWaveformContext {
  final BuildContext buildContext;
  final VideoCardOptions options;
  final bool showWaveform;
  final List<AnimationController> animationControllers;
  final Color barColor;
  final Widget defaultWaveform;

  const VideoCardWaveformContext({
    required this.buildContext,
    required this.options,
    required this.showWaveform,
    required this.animationControllers,
    required this.barColor,
    required this.defaultWaveform,
  });
}

typedef VideoCardWrapperBuilder = Widget Function(
  VideoCardWrapperContext context,
);

typedef VideoCardContainerBuilder = Widget Function(
  VideoCardContainerContext context,
);

typedef VideoCardInfoBuilder = Widget Function(
  VideoCardInfoContext context,
);

typedef VideoCardOverlayBuilder = Widget Function(
  VideoCardOverlayContext context,
);

typedef VideoCardWaveformBuilder = Widget Function(
  VideoCardWaveformContext context,
);

/// VideoCardParameters - Defines the parameters required for the `VideoCard` widget.
abstract class VideoCardParameters implements AudioDecibelCheckParameters {
  io.Socket? get socket;
  String get roomName;
  List<CoHostResponsibility> get coHostResponsibility;
  ShowAlert? get showAlert;
  String get coHost;
  List<Participant> get participants;
  String get member;
  String get islevel;
  List<AudioDecibels> get audioDecibels;

  /// Whether a virtual background has been applied
  bool get appliedBackground;

  /// The local video stream (needed for BackgroundVideoDisplay)
  MediaStream? get localStreamVideo;

  VideoCardParameters Function() get getUpdatedAllParams;

  // dynamic operator [](String key);
}

/// Configuration options for the `VideoCard` widget.
///
/// Provides properties to customize the video participant card display,
/// including video stream rendering, name badge, animated waveform, video/audio controls,
/// and mirror mode for local camera.
///
/// **Core Display Properties:**
/// - `name`: Participant display name
/// - `participant`: Participant model (used for mute state, audio level, permissions)
/// - `parameters`: VideoCardParameters providing runtime state (audioDecibels, socket, etc.)
/// - `videoStream`: MediaStream containing video track; if null, renders audio-only fallback
/// - `remoteProducerId`: Producer ID for video stream (used for track identification)
/// - `eventType`: Meeting type (video/broadcast/chat/conference/webinar) affecting controls visibility
///
/// **Video Rendering:**
/// - `forceFullDisplay`: If true, forces video fill entire card (ignores aspect ratio)
/// - `doMirror`: If true, applies horizontal flip (CSS scaleX(-1)) for local camera
/// - `backgroundColor`: Fallback background color when no video (default: #2c678f blue)
///
/// **Audio Visualization:**
/// - `barColor`: Waveform bar color (default: red); animated based on audio levels
/// - Waveform displays when: video paused/off + participant unmuted + audio detected
///
/// **Controls/Info Overlays:**
/// - `showControls`: If true, displays audio/video toggle buttons (default: true)
/// - `showInfo`: If true, displays participant name badge (default: true)
/// - `controlsPosition`: Button placement: 'topLeft', 'topRight', 'bottomLeft', 'bottomRight' (default: 'topLeft')
/// - `infoPosition`: Name badge placement: same options (default: 'topRight')
/// - `videoInfoComponent`: Custom widget override for info area (replaces name badge)
/// - `videoControlsComponent`: Custom widget override for controls area (replaces buttons)
///
/// **Avatar/Image (for audio-only fallback):**
/// - `imageSource`: Participant image URL for MiniCard avatar
/// - `roundedImage`: If true, renders circular avatar (default: false)
/// - `imageStyle`: Map styling for avatar container
/// - `textColor`: Name badge text color (default: black)
///
/// **Media Control:**
/// - `controlUserMedia`: Function handling mute/video toggle actions; default=`controlMedia`
///   - Checks host/coHost permissions via `coHostResponsibility`
///   - Sends socket events to control remote participants
///   - Only host/coHost with `media` permission can control others
///
/// **Builder Hooks (5):**
/// - `customBuilder`: Full widget replacement; receives VideoCardOptions
/// - `wrapperBuilder`: Override Stack wrapper; receives stackChildren + default
/// - `containerBuilder`: Override Container; receives child + default
/// - `infoBuilder`: Override name badge/waveform overlay; receives nameBadge + waveform + default
/// - `overlayBuilder`: Override waveform overlay; receives waveform + default
/// - `waveformBuilder`: Override animated bars; receives animationControllers + default
///
/// **Styling Properties:**
/// - `containerPadding`/`containerMargin`/`containerAlignment`/`containerDecoration`: Outer container layout
/// - `overlayDecoration`: BoxDecoration for waveform overlay layer
/// - `overlayPadding`: Padding for overlay content
/// - `nameContainerDecoration`: BoxDecoration for name badge container
/// - `nameContainerPadding`: Padding for name badge text
/// - `nameTextStyle`: TextStyle override for name text
///
/// **Usage Patterns:**
/// 1. **Basic Video Card:**
///    ```dart
///    VideoCard(
///      options: VideoCardOptions(
///        parameters: parameters,
///        name: 'John Doe',
///        remoteProducerId: 'producer-123',
///        eventType: EventType.conference,
///        videoStream: mediaStream,
///        participant: participant,
///      ),
///    )
///    ```
///
/// 2. **Local Camera (Mirrored):**
///    ```dart
///    VideoCard(
///      options: VideoCardOptions(
///        parameters: parameters,
///        name: 'You',
///        remoteProducerId: 'local-producer',
///        eventType: EventType.conference,
///        videoStream: localStream,
///        participant: localParticipant,
///        doMirror: true,
///      ),
///    )
///    ```
///
/// 3. **Hide Controls (View-Only):**
///    ```dart
///    VideoCard(
///      options: VideoCardOptions(
///        parameters: parameters,
///        name: 'John Doe',
///        remoteProducerId: 'producer-123',
///        eventType: EventType.broadcast,
///        videoStream: mediaStream,
///        participant: participant,
///        showControls: false,
///      ),
///    )
///    ```
///
/// 4. **Custom Controls Overlay:**
///    ```dart
///    VideoCard(
///      options: VideoCardOptions(
///        parameters: parameters,
///        name: 'John Doe',
///        remoteProducerId: 'producer-123',
///        eventType: EventType.conference,
///        videoStream: mediaStream,
///        participant: participant,
///        videoControlsComponent: Row(
///          children: [
///            IconButton(icon: Icon(Icons.mic_off), onPressed: muteAction),
///            IconButton(icon: Icon(Icons.videocam_off), onPressed: videoOffAction),
///            IconButton(icon: Icon(Icons.pin), onPressed: pinAction),
///          ],
///        ),
///      ),
///    )
///    ```
///
/// 5. **Builder Hook Override:**
///    ```dart
///    VideoCard(
///      options: VideoCardOptions(
///        parameters: parameters,
///        name: 'John Doe',
///        remoteProducerId: 'producer-123',
///        eventType: EventType.conference,
///        videoStream: mediaStream,
///        participant: participant,
///        containerBuilder: (context, child, defaultContainer) {
///          return Stack(
///            children: [
///              defaultContainer,
///              Positioned(
///                bottom: 8,
///                right: 8,
///                child: Icon(Icons.verified, color: Colors.blue),
///              ),
///            ],
///          );
///        },
///      ),
///    )
///    ```
///
/// **Override Integration:**
/// Integrates with `MediasfuUICustomOverrides` for global styling:
/// ```dart
/// overrides: MediasfuUICustomOverrides(
///   videoCardOptions: ComponentOverride<VideoCardOptions>(
///     builder: (existingOptions) => VideoCardOptions(
///       parameters: existingOptions.parameters,
///       name: existingOptions.name,
///       remoteProducerId: existingOptions.remoteProducerId,
///       eventType: existingOptions.eventType,
///       videoStream: existingOptions.videoStream,
///       participant: existingOptions.participant,
///       containerDecoration: BoxDecoration(
///         border: Border.all(color: Colors.gold, width: 2),
///         borderRadius: BorderRadius.circular(12),
///       ),
///       barColor: Colors.cyan,
///     ),
///   ),
/// ),
/// ```
///
/// **Waveform Display Logic:**
/// - Waveform visible when: `!forceFullDisplay && participant.muted == false && audioDetected`
/// - Displays 9 animated bars representing audio levels
/// - Bar heights animate based on `audioDecibels` from `parameters.audioDecibels`
/// - Hidden when video active or participant muted
///
/// **Permission-Based Controls:**
/// - Host (islevel='2') can always control others
/// - CoHost (islevel='1') can control if `coHostResponsibility` includes `media` permission
/// - Participants (islevel='0') can only control themselves
/// - Socket event `'controlMedia'` emitted when controlling remote participants
///
/// **Audio Decibel Integration:**
/// - Uses `AudioDecibelCheck` component to monitor real-time audio levels
/// - Polls `parameters.audioDecibels` list every 2 seconds
/// - Matches by `participant.name` against `audioDecibels[i].name`
/// - Updates waveform animation controllers based on detected level
class VideoCardOptions {
  final VideoCardParameters parameters;
  final String name;
  final Color barColor;
  final Color textColor;
  final String imageSource;
  final bool roundedImage;
  final Map<String, dynamic> imageStyle;
  final String remoteProducerId;
  final EventType eventType;
  final bool forceFullDisplay;
  final MediaStream? videoStream;
  final bool showControls;
  final bool showInfo;
  final Widget? videoInfoComponent;
  final Widget? videoControlsComponent;
  final String controlsPosition;
  final String infoPosition;
  final Participant participant;
  final Color backgroundColor;
  final bool doMirror;
  final ControlMediaType controlUserMedia;
  final VideoCardType? customBuilder;
  final EdgeInsetsGeometry? containerPadding;
  final EdgeInsetsGeometry? containerMargin;
  final AlignmentGeometry? containerAlignment;
  final BoxDecoration? containerDecoration;
  final BoxDecoration? overlayDecoration;
  final EdgeInsetsGeometry? overlayPadding;
  final BoxDecoration? nameContainerDecoration;
  final EdgeInsetsGeometry? nameContainerPadding;
  final TextStyle? nameTextStyle;
  final VideoCardWrapperBuilder? wrapperBuilder;
  final VideoCardContainerBuilder? containerBuilder;
  final VideoCardInfoBuilder? infoBuilder;
  final VideoCardOverlayBuilder? overlayBuilder;
  final VideoCardWaveformBuilder? waveformBuilder;

  /// Border radius for the video card.
  /// Used by modern styling for rounded corners.
  final double borderRadius;

  /// Enable glassmorphism effects.
  /// Used by modern styling for blur effects.
  final bool enableGlassmorphism;

  /// Whether to show status indicator.
  /// Used by modern styling for status overlays.
  final bool showStatusIndicator;

  /// Dark mode toggle.
  /// Used by modern styling for theme.
  final bool isDarkMode;

  /// Optional callback to toggle self-view display mode.
  /// When provided, allows user to switch between cropped (fill) and full view
  /// for their own video preview only.
  final VoidCallback? onToggleSelfViewFit;

  /// Live subtitle to display on this video card.
  /// When not null and showSubtitles is true, displays the translated/transcribed text.
  final ValueListenable<LiveSubtitle?>? liveSubtitle;

  /// Whether to show subtitles on this video card (static boolean).
  /// For reactive updates, use `showSubtitlesNotifier` instead.
  final bool showSubtitles;

  /// Reactive notifier for whether to show subtitles on this card.
  /// Takes precedence over `showSubtitles` if provided.
  final ValueListenable<bool>? showSubtitlesNotifier;

  VideoCardOptions({
    required this.parameters,
    required this.name,
    this.barColor = const Color.fromARGB(255, 232, 46, 46),
    this.textColor = const Color.fromARGB(255, 25, 25, 25),
    this.imageSource = '',
    this.roundedImage = false,
    this.imageStyle = const {},
    required this.remoteProducerId,
    required this.eventType,
    this.forceFullDisplay = false,
    required this.videoStream,
    this.showControls = true,
    this.showInfo = true,
    this.videoInfoComponent,
    this.videoControlsComponent,
    this.controlsPosition = 'topLeft',
    this.infoPosition = 'topRight',
    required this.participant,
    this.backgroundColor = const Color(0xFF2c678f),
    this.doMirror = false,
    this.controlUserMedia = controlMedia,
    this.customBuilder,
    this.containerPadding,
    this.containerMargin,
    this.containerAlignment,
    this.containerDecoration,
    this.overlayDecoration,
    this.overlayPadding,
    this.nameContainerDecoration,
    this.nameContainerPadding,
    this.nameTextStyle,
    this.wrapperBuilder,
    this.containerBuilder,
    this.infoBuilder,
    this.overlayBuilder,
    this.waveformBuilder,
    this.borderRadius = 0.0,
    this.enableGlassmorphism = false,
    this.showStatusIndicator = false,
    this.isDarkMode = false,
    this.onToggleSelfViewFit,
    this.liveSubtitle,
    this.showSubtitles = false,
    this.showSubtitlesNotifier,
  });
}

typedef VideoCardType = Widget Function({required VideoCardOptions options});

/// A stateful widget displaying video participant card with stream rendering, controls, and waveform.
///
/// Renders a participant tile showing:
/// - Video stream via CardVideoDisplay (or MiniCard fallback if no stream)
/// - Name badge overlay (top-right by default)
/// - Audio/video toggle buttons (top-left by default)
/// - Animated waveform bars (9 bars, visible when video off + audio detected)
/// - Optional mirror mode for local camera
///
/// **Rendering Logic:**
/// 1. If `customBuilder` provided → delegates full rendering
/// 2. Else builds Stack with:
///    - Background Container (containerBuilder)
///    - Video display via CardVideoDisplay or MiniCard fallback
///    - AudioDecibelCheck (monitors audio levels)
///    - Waveform overlay (overlayBuilder → waveformBuilder)
///    - Name badge (infoBuilder)
///    - Control buttons (audio/video toggles)
///
/// **Layout Structure:**
/// ```
/// Stack (wrapperBuilder)
///   ├─ Positioned.fill → Container (containerBuilder)
///   │  └─ IF videoStream != null:
///   │     └─ CardVideoDisplay (video stream)
///   │     ELSE:
///   │     └─ MiniCard (avatar fallback)
///   ├─ AudioDecibelCheck (monitors audio, updates waveform state)
///   ├─ IF showWaveform:
///   │  └─ Positioned.fill → Container (overlayBuilder)
///   │     └─ Row (waveformBuilder)
///   │        └─ 9 × AnimatedContainer (bars)
///   ├─ Positioned (infoPosition) → Container (infoBuilder)
///   │  └─ Row (nameBadge + waveform indicator)
///   └─ Positioned (controlsPosition) → Row
///      ├─ GestureDetector (audio toggle)
///      └─ GestureDetector (video toggle)
/// ```
///
/// **Video Stream Rendering:**
/// - Uses `CardVideoDisplay` to render MediaStream via WebRTC RTCVideoRenderer
/// - Applies mirror mode if `doMirror=true` (CSS scaleX(-1))
/// - Falls back to MiniCard avatar if `videoStream` null or video track unavailable
/// - Respects `forceFullDisplay` for aspect ratio handling
///
/// **Audio Level Detection:**
/// - `AudioDecibelCheck` component polls `parameters.audioDecibels` every 2 seconds
/// - Matches by `participant.name` against `audioDecibels[i].name`
/// - Updates `showWaveform` state based on:
///   - Participant unmuted (`participant.muted == false`)
///   - Audio detected (avgAudioDecibels > threshold)
///   - Video off or `!forceFullDisplay`
/// - Triggers waveform animation via AnimationControllers
///
/// **Control Button Workflow:**
/// 1. **Audio Toggle (Mute/Unmute):**
///    - Taps mute icon in controls overlay
///    - Calls `toggleAudio()` → `controlUserMedia`
///    - Parameters: `{ participantId, participantName, type: 'audio' }`
///    - Checks permissions (host/coHost with 'media' permission)
///    - Emits socket event `'controlMedia'` to server
///
/// 2. **Video Toggle (On/Off):**
///    - Taps video icon in controls overlay
///    - Calls `toggleVideo()` → `controlUserMedia`
///    - Parameters: `{ participantId, participantName, type: 'video' }`
///    - Checks permissions (host/coHost with 'media' permission)
///    - Emits socket event `'controlMedia'` to server
///
/// **Waveform Animation:**
/// - State creates 9 AnimationControllers (1 per bar)
/// - `animateWaveform()` starts repeat(reverse: true) animation
/// - `resetWaveform()` stops/resets all controllers
/// - Bar heights scale from 1px (silent) to 40px (loud)
/// - Bars hidden if participant muted or no audio detected
/// - Disposed on widget unmount
///
/// **Builder Hook Priorities:**
/// - `customBuilder` → full widget replacement (ignores all other props)
/// - `wrapperBuilder` → wraps Stack; receives stackChildren + default
/// - `containerBuilder` → wraps video/avatar container; receives child + default
/// - `infoBuilder` → wraps name badge/waveform; receives nameBadge + waveform + default
/// - `overlayBuilder` → wraps waveform overlay; receives waveform + default
/// - `waveformBuilder` → wraps bars; receives animationControllers + default
///
/// **Common Use Cases:**
/// 1. **Grid View with Videos:**
///    ```dart
///    GridView.builder(
///      itemCount: videoParticipants.length,
///      itemBuilder: (context, index) {
///        final participant = videoParticipants[index];
///        return VideoCard(
///          options: VideoCardOptions(
///            parameters: parameters,
///            name: participant.name,
///            remoteProducerId: participant.videoID,
///            eventType: EventType.conference,
///            videoStream: participant.stream,
///            participant: participant,
///          ),
///        );
///      },
///    )
///    ```
///
/// 2. **Local Camera Preview:**
///    ```dart
///    VideoCard(
///      options: VideoCardOptions(
///        parameters: parameters,
///        name: 'You',
///        remoteProducerId: 'local',
///        eventType: EventType.conference,
///        videoStream: localStream,
///        participant: localParticipant,
///        doMirror: true,
///        controlsPosition: 'bottomRight',
///      ),
///    )
///    ```
///
/// 3. **Host-Only Controls:**
///    ```dart
///    VideoCard(
///      options: VideoCardOptions(
///        parameters: parameters,
///        name: 'John Doe',
///        remoteProducerId: 'producer-123',
///        eventType: EventType.conference,
///        videoStream: mediaStream,
///        participant: participant,
///        showControls: isHost,
///        videoControlsComponent: isHost ? hostControls : null,
///      ),
///    )
///    ```
///
/// 4. **Custom Name Badge with Status:**
///    ```dart
///    VideoCard(
///      options: VideoCardOptions(
///        parameters: parameters,
///        name: 'John Doe',
///        remoteProducerId: 'producer-123',
///        eventType: EventType.conference,
///        videoStream: mediaStream,
///        participant: participant,
///        infoBuilder: (context, nameBadge, waveform, defaultInfo) {
///          return Stack(
///            children: [
///              defaultInfo,
///              Positioned(
///                bottom: 0,
///                right: 0,
///                child: Icon(Icons.fiber_manual_record, color: Colors.green, size: 12),
///              ),
///            ],
///          );
///        },
///      ),
///    )
///    ```
///
/// **Override Integration:**
/// Integrates with `MediasfuUICustomOverrides` for global styling:
/// ```dart
/// overrides: MediasfuUICustomOverrides(
///   videoCardOptions: ComponentOverride<VideoCardOptions>(
///     builder: (existingOptions) => VideoCardOptions(
///       parameters: existingOptions.parameters,
///       name: existingOptions.name,
///       remoteProducerId: existingOptions.remoteProducerId,
///       eventType: existingOptions.eventType,
///       videoStream: existingOptions.videoStream,
///       participant: existingOptions.participant,
///       containerDecoration: BoxDecoration(
///         gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
///         borderRadius: BorderRadius.circular(16),
///       ),
///       barColor: Colors.yellow,
///       nameTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
///     ),
///   ),
/// ),
/// ```
///
/// **Performance Notes:**
/// - Animation controllers created once in initState (9 controllers)
/// - Audio level polling every 2 seconds (not every frame)
/// - Waveform hidden when video active (skips rendering 9 bars)
/// - Video rendering delegated to CardVideoDisplay (uses RTCVideoRenderer)
/// - Disposed controllers + video renderer cleaned up in dispose()
///
/// **Permission Requirements:**
/// - Controlling others requires host or coHost with 'media' permission
/// - Self-control always allowed
/// - Socket connection required for remote control actions
///
/// **Mirror Mode:**
/// - Applied via CSS transform: scaleX(-1) on video element
/// - Typically used for local camera to match user expectation
/// - Does not affect stream data, only display
class VideoCard extends StatefulWidget {
  final VideoCardOptions options;

  const VideoCard({super.key, required this.options});

  @override
  _VideoCardState createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> with TickerProviderStateMixin {
  late List<AnimationController> waveformAnimations;
  ValueNotifier<bool> showWaveform = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    waveformAnimations = List.generate(
      9,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(seconds: 1),
      ),
    );
    animateWaveform();
  }

  void animateWaveform() {
    for (var controller in waveformAnimations) {
      controller.repeat(reverse: true);
    }
  }

  void resetWaveform() {
    for (var controller in waveformAnimations) {
      controller.reset();
    }
  }

  void updateShowWaveform(bool value) {
    showWaveform.value = value;
  }

  @override
  void dispose() {
    for (var controller in waveformAnimations) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget renderControls() {
    if (!widget.options.showControls) {
      return const SizedBox();
    }

    final controlsComponent = widget.options.videoControlsComponent ??
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: toggleAudio,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.25 * 255).toInt()),
                  borderRadius: BorderRadius.circular(0),
                ),
                child: Icon(
                  widget.options.participant.muted!
                      ? Icons.mic_off
                      : Icons.mic_none,
                  color: widget.options.participant.muted!
                      ? Colors.red
                      : Colors.green,
                  size: 14,
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: toggleVideo,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.25 * 255).toInt()),
                  borderRadius: BorderRadius.circular(0),
                ),
                child: Icon(
                  widget.options.participant.videoOn ?? true
                      ? Icons.videocam
                      : Icons.videocam_off,
                  color: widget.options.participant.videoOn ?? true
                      ? Colors.green
                      : Colors.red,
                  size: 14,
                ),
              ),
            ),
          ],
        );

    return controlsComponent;
  }

  Future<void> toggleAudio() async {
    if (widget.options.participant.muted!) {
      // Handle unmuting logic if applicable
    } else {
      final optionsControl = ControlMediaOptions(
        participantId: widget.options.participant.id!,
        participantName: widget.options.participant.name,
        type: 'audio',
        socket: widget.options.parameters.socket,
        roomName: widget.options.parameters.roomName,
        coHostResponsibility: widget.options.parameters.coHostResponsibility,
        showAlert: widget.options.parameters.showAlert,
        coHost: widget.options.parameters.coHost,
        participants: widget.options.parameters.participants,
        member: widget.options.parameters.member,
        islevel: widget.options.parameters.islevel,
      );
      await widget.options.controlUserMedia(
        optionsControl,
      );
    }
  }

  Future<void> toggleVideo() async {
    if (widget.options.participant.videoOn ?? false) {
      final optionsControl = ControlMediaOptions(
        participantId: widget.options.participant.id!,
        participantName: widget.options.participant.name,
        type: 'video',
        socket: widget.options.parameters.socket,
        roomName: widget.options.parameters.roomName,
        coHostResponsibility: widget.options.parameters.coHostResponsibility,
        showAlert: widget.options.parameters.showAlert,
        coHost: widget.options.parameters.coHost,
        participants: widget.options.parameters.participants,
        member: widget.options.parameters.member,
        islevel: widget.options.parameters.islevel,
      );
      await widget.options.controlUserMedia(
        optionsControl,
      );
    } else {
      // Handle video off logic if applicable
    }
  }

  @override
  Widget build(BuildContext context) {
    // If a custom builder is provided, use it
    if (widget.options.customBuilder != null) {
      return widget.options.customBuilder!(
        options: widget.options,
      );
    }

    animateWaveform();
    try {
      // Build subtitle overlay with reactive support if notifier is available
      Widget? subtitleOverlay;
      if (widget.options.liveSubtitle != null) {
        if (widget.options.showSubtitlesNotifier != null) {
          subtitleOverlay = ValueListenableBuilder<bool>(
            valueListenable: widget.options.showSubtitlesNotifier!,
            builder: (context, showSubtitles, _) {
              if (showSubtitles) {
                return _buildSubtitleOverlay();
              }
              return const SizedBox.shrink();
            },
          );
        } else if (widget.options.showSubtitles) {
          subtitleOverlay = _buildSubtitleOverlay();
        }
      }

      final stackChildren = <Widget>[
        Positioned.fill(child: _buildVideoDisplay()),
        _buildOverlayPositioned(context),
        if (widget.options.showControls) _buildControlsPositioned(),
        _buildAudioDecibelCheck(),
        if (subtitleOverlay != null) subtitleOverlay,
      ];

      final defaultWrapper = Stack(children: stackChildren);

      final wrapper = widget.options.wrapperBuilder?.call(
            VideoCardWrapperContext(
              buildContext: context,
              options: widget.options,
              stackChildren: stackChildren,
              defaultWrapper: defaultWrapper,
            ),
          ) ??
          defaultWrapper;

      final defaultContainer = Container(
        padding: widget.options.containerPadding,
        margin: widget.options.containerMargin,
        alignment: widget.options.containerAlignment,
        decoration: widget.options.containerDecoration ??
            BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              color: widget.options.backgroundColor,
            ),
        child: wrapper,
      );

      final container = widget.options.containerBuilder?.call(
            VideoCardContainerContext(
              buildContext: context,
              options: widget.options,
              child: wrapper,
              defaultContainer: defaultContainer,
            ),
          ) ??
          defaultContainer;

      return container;
    } catch (error) {
      if (kDebugMode) {
        print('Error adding widget: $error');
      }
      return ErrorWidget(error.toString());
    }
  }

  Widget _buildVideoDisplay() {
    return CardVideoDisplay(
      options: CardVideoDisplayOptions(
        remoteProducerId: widget.options.remoteProducerId,
        eventType: widget.options.eventType,
        forceFullDisplay: widget.options.forceFullDisplay,
        videoStream: widget.options.videoStream!,
        backgroundColor: widget.options.backgroundColor,
        doMirror: widget.options.doMirror,
      ),
    );
  }

  Widget _buildOverlayPositioned(BuildContext context) {
    final position = widget.options.infoPosition.toLowerCase();
    return Positioned(
      top: position.contains('top') ? 0 : null,
      left: position.contains('left') ? 0 : null,
      bottom: position.contains('bottom') ? 0 : null,
      right: position.contains('right') ? 0 : null,
      child: _buildOverlay(context),
    );
  }

  Widget _buildControlsPositioned() {
    final position = widget.options.controlsPosition.toLowerCase();
    return Positioned(
      top: position.contains('top') ? 0 : null,
      left: position.contains('left') ? 0 : null,
      bottom: position.contains('bottom') ? 0 : null,
      right: position.contains('right') ? 0 : null,
      child: renderControls(),
    );
  }

  Widget _buildAudioDecibelCheck() {
    return AudioDecibelCheck(
      options: AudioDecibelCheckOptions(
        animateWaveform: animateWaveform,
        resetWaveform: resetWaveform,
        name: widget.options.name,
        participant: widget.options.participant,
        parameters: widget.options.parameters,
        onShowWaveformChanged: updateShowWaveform,
      ),
    );
  }

  Widget _buildSubtitleOverlay() {
    return ValueListenableBuilder<LiveSubtitle?>(
      valueListenable: widget.options.liveSubtitle!,
      builder: (context, subtitle, child) {
        if (subtitle == null || subtitle.text.isEmpty) {
          return const SizedBox.shrink();
        }
        return Positioned(
          bottom: 8,
          left: 8,
          right: 8,
          child: IgnorePointer(
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha((0.75 * 255).toInt()),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  subtitle.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverlay(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: showWaveform,
      builder: (context, isVisible, child) {
        final waveform = _buildWaveform(context, isVisible);
        final info = _buildInfo(context, waveform);

        Widget defaultOverlay = info;

        final hasOverlayStyling = widget.options.overlayDecoration != null ||
            widget.options.overlayPadding != null;

        if (hasOverlayStyling) {
          defaultOverlay = Container(
            padding: widget.options.overlayPadding,
            decoration: widget.options.overlayDecoration,
            child: info,
          );
        }

        return widget.options.overlayBuilder?.call(
              VideoCardOverlayContext(
                buildContext: context,
                options: widget.options,
                showWaveform: isVisible,
                waveform: waveform,
                defaultOverlay: defaultOverlay,
              ),
            ) ??
            defaultOverlay;
      },
    );
  }

  Widget _buildInfo(BuildContext context, Widget waveform) {
    final nameBadge = _buildNameBadge();

    final defaultInfo = widget.options.videoInfoComponent ??
        (widget.options.showInfo
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  nameBadge,
                  const SizedBox(width: 5),
                  waveform,
                ],
              )
            : const SizedBox());

    return widget.options.infoBuilder?.call(
          VideoCardInfoContext(
            buildContext: context,
            options: widget.options,
            nameBadge: nameBadge,
            waveform: waveform,
            defaultInfo: defaultInfo,
          ),
        ) ??
        defaultInfo;
  }

  Widget _buildNameBadge() {
    final defaultDecoration = BoxDecoration(
      color: Colors.white.withAlpha((0.25 * 255).toInt()),
      borderRadius: BorderRadius.circular(0),
    );

    final decoration =
        widget.options.nameContainerDecoration ?? defaultDecoration;
    final padding = widget.options.nameContainerPadding ??
        const EdgeInsets.symmetric(horizontal: 2, vertical: 3);
    final textStyle = widget.options.nameTextStyle ??
        TextStyle(
          color: widget.options.textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        );

    return Container(
      padding: padding,
      decoration: decoration,
      child: Text(
        widget.options.participant.name,
        style: textStyle,
      ),
    );
  }

  Widget _buildWaveform(BuildContext context, bool show) {
    final bars = List.generate(
      waveformAnimations.length,
      (index) => AnimatedBuilder(
        animation: waveformAnimations[index],
        builder: (context, child) {
          final randomHeight = Random().nextDouble() * 14;
          return Container(
            height: show ? randomHeight : 0,
            width: 5,
            color: widget.options.barColor,
            margin: const EdgeInsets.symmetric(horizontal: 1),
          );
        },
      ),
    );

    final Widget defaultWaveform = show
        ? Row(
            children: bars,
          )
        : const SizedBox();

    return widget.options.waveformBuilder?.call(
          VideoCardWaveformContext(
            buildContext: context,
            options: widget.options,
            showWaveform: show,
            animationControllers: waveformAnimations,
            barColor: widget.options.barColor,
            defaultWaveform: defaultWaveform,
          ),
        ) ??
        defaultWaveform;
  }
}
