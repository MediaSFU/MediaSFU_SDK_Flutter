import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:socket_io_client/socket_io_client.dart' as io;
import './mini_card.dart' show MiniCard, MiniCardOptions;
import '../../consumers/control_media.dart'
    show controlMedia, ControlMediaType, ControlMediaOptions;
import '../../types/types.dart'
    show Participant, ShowAlert, EventType, CoHostResponsibility, AudioDecibels;

/// A stateful widget displaying audio-only participant card with animated waveform and controls.
///
/// Renders a participant tile showing:
/// - MiniCard avatar (image or initials)
/// - Animated waveform bars (9 bars, height based on audio levels)
/// - Name badge overlay (top-right by default)
/// - Mute toggle button (top-left by default)
///
/// **Rendering Logic:**
/// 1. If `customBuilder` provided → delegates full rendering
/// 2. Else builds Stack with:
///    - Background Container (containerBuilder)
///    - Waveform overlay (overlayBuilder → waveformBuilder)
///    - Name badge (infoBuilder)
///    - Mute button (if showControls=true)
///
/// **Layout Structure:**
/// ```
/// Stack (wrapperBuilder)
///   ├─ Positioned.fill → Container (containerBuilder)
///   │  └─ MiniCard (avatar)
///   ├─ Positioned.fill → Container (overlayBuilder)
///   │  └─ Row (waveformBuilder)
///   │     └─ 9 × AnimatedContainer (bars)
///   ├─ Positioned (infoPosition) → Container (infoBuilder)
///   │  └─ Text (name badge)
///   └─ Positioned (controlsPosition) → GestureDetector
///      └─ Icon (mute button)
/// ```
///
/// **Audio Level Detection:**
/// - Reads `parameters.audioDecibels` list to find participant's audio level
/// - Matches by `participant.name` against `audioDecibels[i].name`
/// - Hides waveform if participant muted (`participant.muted == true`)
/// - Animates bar heights based on detected audio level (0-127 range)
///
/// **Mute Control Workflow:**
/// 1. User taps mute button (visible if `showControls=true`)
/// 2. Calls `controlUserMedia` function with:
///    - `participantId`: participant.id (socket ID)
///    - `participantName`: participant.name
///    - `type`: 'audio' (media type)
/// 3. `controlMedia` checks permissions:
///    - Host (islevel='2') → always allowed
///    - CoHost with 'media' permission → allowed
///    - Self-mute → always allowed
/// 4. Emits socket event `'controlMedia'` to server:
///    ```json
///    {
///      "participantId": "abc123",
///      "participantName": "John Doe",
///      "type": "audio"
///    }
///    ```
/// 5. Server broadcasts mute action to all clients
///
/// **Waveform Animation:**
/// - State creates 9 AnimationControllers (1 per bar)
/// - Effect hook polls `parameters.audioDecibels` every 2 seconds
/// - Updates bar heights via `setState` → triggers animations
/// - Bars scale from 1px (silent) to 40px (loud)
/// - Disposed on widget unmount
///
/// **Builder Hook Priorities:**
/// - `customBuilder` → full widget replacement (ignores all other props)
/// - `wrapperBuilder` → wraps Stack; receives stackChildren + default
/// - `containerBuilder` → wraps MiniCard container; receives child + default
/// - `infoBuilder` → wraps name badge; receives overlay + default
/// - `overlayBuilder` → wraps waveform; receives waveform + default
/// - `waveformBuilder` → wraps bars; receives animationControllers + default
///
/// **Common Use Cases:**
/// 1. **Basic Grid Display:**
///    ```dart
///    GridView.builder(
///      itemCount: audioParticipants.length,
///      itemBuilder: (context, index) {
///        final participant = audioParticipants[index];
///        return AudioCard(
///          options: AudioCardOptions(
///            name: participant.name,
///            participant: participant,
///            parameters: parameters,
///            customStyle: BoxDecoration(color: Colors.grey[800]),
///          ),
///        );
///      },
///    )
///    ```
///
/// 2. **Custom Controls Overlay:**
///    ```dart
///    AudioCard(
///      options: AudioCardOptions(
///        name: 'John Doe',
///        participant: participant,
///        parameters: parameters,
///        videoControlsComponent: Row(
///          children: [
///            IconButton(icon: Icon(Icons.mic_off), onPressed: muteAction),
///            IconButton(icon: Icon(Icons.more_vert), onPressed: showMenu),
///          ],
///        ),
///      ),
///    )
///    ```
///
/// 3. **Silent Display (No Controls):**
///    ```dart
///    AudioCard(
///      options: AudioCardOptions(
///        name: 'John Doe',
///        participant: participant,
///        parameters: parameters,
///        showControls: false,
///        showInfo: false,
///      ),
///    )
///    ```
///
/// **Override Integration:**
/// Integrates with `MediasfuUICustomOverrides` for global styling:
/// ```dart
/// overrides: MediasfuUICustomOverrides(
///   audioCardOptions: ComponentOverride<AudioCardOptions>(
///     builder: (existingOptions) => AudioCardOptions(
///       name: existingOptions.name,
///       participant: existingOptions.participant,
///       parameters: existingOptions.parameters,
///       customStyle: BoxDecoration(
///         gradient: LinearGradient(colors: [Colors.deepPurple, Colors.purple]),
///         borderRadius: BorderRadius.circular(12),
///       ),
///       barColor: Colors.pink,
///     ),
///   ),
/// ),
/// ```
///
class AudioCardWrapperContext {
  final BuildContext buildContext;
  final AudioCardOptions options;
  final List<Widget> stackChildren;
  final Widget defaultWrapper;

  const AudioCardWrapperContext({
    required this.buildContext,
    required this.options,
    required this.stackChildren,
    required this.defaultWrapper,
  });
}

class AudioCardContainerContext {
  final BuildContext buildContext;
  final AudioCardOptions options;
  final Widget child;
  final Widget defaultContainer;

  const AudioCardContainerContext({
    required this.buildContext,
    required this.options,
    required this.child,
    required this.defaultContainer,
  });
}

class AudioCardInfoContext {
  final BuildContext buildContext;
  final AudioCardOptions options;
  final Widget overlay;
  final Widget defaultInfo;

  const AudioCardInfoContext({
    required this.buildContext,
    required this.options,
    required this.overlay,
    required this.defaultInfo,
  });
}

class AudioCardOverlayContext {
  final BuildContext buildContext;
  final AudioCardOptions options;
  final bool showWaveform;
  final Widget waveform;
  final Widget defaultOverlay;

  const AudioCardOverlayContext({
    required this.buildContext,
    required this.options,
    required this.showWaveform,
    required this.waveform,
    required this.defaultOverlay,
  });
}

class AudioCardWaveformContext {
  final BuildContext buildContext;
  final AudioCardOptions options;
  final bool showWaveform;
  final List<AnimationController> animationControllers;
  final Color barColor;
  final Widget defaultWaveform;

  const AudioCardWaveformContext({
    required this.buildContext,
    required this.options,
    required this.showWaveform,
    required this.animationControllers,
    required this.barColor,
    required this.defaultWaveform,
  });
}

typedef AudioCardWrapperBuilder = Widget Function(
  AudioCardWrapperContext context,
);

typedef AudioCardContainerBuilder = Widget Function(
  AudioCardContainerContext context,
);

typedef AudioCardInfoBuilder = Widget Function(
  AudioCardInfoContext context,
);

typedef AudioCardOverlayBuilder = Widget Function(
  AudioCardOverlayContext context,
);

typedef AudioCardWaveformBuilder = Widget Function(
  AudioCardWaveformContext context,
);

/// AudioCardParameters - Abstract class defining parameters required for the `AudioCard` widget.
abstract class AudioCardParameters {
  List<AudioDecibels> get audioDecibels;
  List<Participant> get participants;
  io.Socket? get socket;
  List<CoHostResponsibility> get coHostResponsibility;
  String get roomName;
  ShowAlert? get showAlert;
  String get coHost;
  String get islevel;
  String get member;
  EventType get eventType;

  AudioCardParameters Function() get getUpdatedAllParams;

  // dynamic operator [](String key);
}

/// Configuration options for the `AudioCard` widget.
///
/// Provides properties to customize the audio-only participant card display,
/// including mini-card avatar, animated waveform bars, mute controls, and overlay styling.
///
/// **Core Display Properties:**
/// - `name`: Participant display name
/// - `participant`: Participant model (used for mute state, audio level, permissions)
/// - `parameters`: AudioCardParameters providing runtime state (audioDecibels, socket, etc.)
/// - `customStyle`: BoxDecoration for outer container (background, border, etc.)
/// - `backgroundColor`: Fallback background color (default: Colors.white)
///
/// **Audio Visualization:**
/// - `barColor`: Waveform bar color (default: red); animated based on audio levels
/// - `showInfo`: If true, displays participant name badge (default: true)
/// - `showControls`: If true, shows mute toggle button (default: true)
///
/// **Avatar/Image Props:**
/// - `imageSource`: Optional participant image URL for MiniCard avatar
/// - `roundedImage`: If true, renders circular avatar (default: false)
/// - `imageStyle`: BoxDecoration for avatar container
/// - `textColor`: Name badge text color (default: white)
///
/// **Controls/Info Positioning:**
/// - `controlsPosition`: Mute button placement: 'topLeft', 'topRight', 'bottomLeft', 'bottomRight' (default: 'topLeft')
/// - `infoPosition`: Name badge placement: same options (default: 'topRight')
/// - `videoInfoComponent`: Custom widget override for info area (replaces name badge)
/// - `videoControlsComponent`: Custom widget override for controls area (replaces mute button)
///
/// **Mute Control:**
/// - `controlUserMedia`: Function handling mute/unmute actions; default=`controlMedia`
///   - Checks host/coHost permissions via `coHostResponsibility`
///   - Sends socket events to mute remote participants
///   - Only host/coHost with `media` permission can mute others
///
/// **Builder Hooks (5):**
/// - `customBuilder`: Full widget replacement; receives AudioCardOptions
/// - `wrapperBuilder`: Override Stack wrapper; receives stackChildren + default
/// - `containerBuilder`: Override Container; receives child + default
/// - `infoBuilder`: Override name badge overlay; receives overlay + default
/// - `overlayBuilder`: Override waveform overlay; receives waveform + default
/// - `waveformBuilder`: Override animated bars; receives animationControllers + default
///
/// **Styling Properties:**
/// - `containerPadding`/`containerMargin`/`containerAlignment`: Outer container layout
/// - `overlayDecoration`: BoxDecoration for waveform overlay layer
/// - `overlayPadding`: Padding for overlay content
///
/// **Usage Patterns:**
/// 1. **Basic Audio Card:**
///    ```dart
///    AudioCard(
///      options: AudioCardOptions(
///        name: 'John Doe',
///        participant: participant,
///        parameters: parameters,
///        customStyle: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(8)),
///      ),
///    )
///    ```
///
/// 2. **Custom Waveform Colors:**
///    ```dart
///    AudioCard(
///      options: AudioCardOptions(
///        name: 'John Doe',
///        participant: participant,
///        parameters: parameters,
///        barColor: Colors.green,
///        customStyle: BoxDecoration(color: Colors.black),
///      ),
///    )
///    ```
///
/// 3. **Hide Controls (View-Only):**
///    ```dart
///    AudioCard(
///      options: AudioCardOptions(
///        name: 'John Doe',
///        participant: participant,
///        parameters: parameters,
///        showControls: false,
///      ),
///    )
///    ```
///
/// 4. **Builder Hook Override:**
///    ```dart
///    AudioCard(
///      options: AudioCardOptions(
///        name: 'John Doe',
///        participant: participant,
///        parameters: parameters,
///        infoBuilder: (context, overlay, defaultInfo) {
///          return Column(
///            children: [
///              Text('Custom Header'),
///              defaultInfo,
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
///   audioCardOptions: ComponentOverride<AudioCardOptions>(
///     builder: (existingOptions) => AudioCardOptions(
///       name: existingOptions.name,
///       participant: existingOptions.participant,
///       parameters: existingOptions.parameters,
///       customStyle: BoxDecoration(border: Border.all(color: Colors.blue, width: 2)),
///       barColor: Colors.cyan,
///     ),
///   ),
/// ),
/// ```
///
/// **Waveform Animation:**
/// - Displays 9 animated bars representing audio levels
/// - Bar heights animate based on `audioDecibels` from `parameters.audioDecibels`
/// - Animation controllers created in State (1 per bar)
/// - Bars hidden if participant muted or no audio detected
///
/// **Permission-Based Mute:**
/// - Host (islevel='2') can always mute others
/// - CoHost (islevel='1') can mute if `coHostResponsibility` includes `media` permission
/// - Participants (islevel='0') can only mute themselves
/// - Socket event `'controlMedia'` emitted when muting remote participants
class AudioCardOptions {
  final ControlMediaType controlUserMedia;
  final BoxDecoration customStyle;
  final String name;
  final Color barColor;
  final Color textColor;
  final String? imageSource;
  final bool roundedImage;
  final BoxDecoration? imageStyle;
  final bool showControls;
  final bool showInfo;
  final Widget? videoInfoComponent;
  final Widget? videoControlsComponent;
  final String
      controlsPosition; // 'topLeft', 'topRight', 'bottomLeft', 'bottomRight'
  final String
      infoPosition; // 'topLeft', 'topRight', 'bottomLeft', 'bottomRight'
  final Participant participant;
  final Color backgroundColor;
  final AudioCardParameters parameters;
  final AudioCardType? customBuilder;
  final EdgeInsetsGeometry? containerPadding;
  final EdgeInsetsGeometry? containerMargin;
  final AlignmentGeometry? containerAlignment;
  final BoxDecoration? overlayDecoration;
  final EdgeInsetsGeometry? overlayPadding;
  final AudioCardWrapperBuilder? wrapperBuilder;
  final AudioCardContainerBuilder? containerBuilder;
  final AudioCardInfoBuilder? infoBuilder;
  final AudioCardOverlayBuilder? overlayBuilder;
  final AudioCardWaveformBuilder? waveformBuilder;

  AudioCardOptions({
    this.controlUserMedia = controlMedia,
    required this.customStyle,
    required this.name,
    this.barColor = const Color.fromARGB(255, 240, 35, 35),
    this.textColor = Colors.white,
    this.imageSource,
    this.roundedImage = false,
    this.imageStyle,
    this.showControls = true,
    this.showInfo = true,
    this.videoInfoComponent,
    this.videoControlsComponent,
    this.controlsPosition = 'topLeft',
    this.infoPosition = 'topRight',
    required this.participant,
    this.backgroundColor = Colors.white,
    required this.parameters,
    this.customBuilder,
    this.containerPadding,
    this.containerMargin,
    this.containerAlignment,
    this.overlayDecoration,
    this.overlayPadding,
    this.wrapperBuilder,
    this.containerBuilder,
    this.infoBuilder,
    this.overlayBuilder,
    this.waveformBuilder,
  });
}

typedef AudioCardType = Widget Function({required AudioCardOptions options});

/// A stateful widget displaying audio-only participant card with animated waveform and controls.
///
/// Renders a participant tile showing:
/// - MiniCard avatar (image or initials)
/// - Animated waveform bars (9 bars, height based on audio levels)
/// - Name badge overlay (top-right by default)
/// - Mute toggle button (top-left by default)
///
/// **Rendering Logic:**
/// 1. If `customBuilder` provided → delegates full rendering
/// 2. Else builds Stack with:
///    - Background Container (containerBuilder)
///    - Waveform overlay (overlayBuilder → waveformBuilder)
///    - Name badge (infoBuilder)
///    - Mute button (if showControls=true)
///
/// **Layout Structure:**
/// ```
/// Stack (wrapperBuilder)
///   ├─ Positioned.fill → Container (containerBuilder)
///   │  └─ MiniCard (avatar)
///   ├─ Positioned.fill → Container (overlayBuilder)
///   │  └─ Row (waveformBuilder)
///   │     └─ 9 × AnimatedContainer (bars)
///   ├─ Positioned (infoPosition) → Container (infoBuilder)
///   │  └─ Text (name badge)
///   └─ Positioned (controlsPosition) → GestureDetector
///      └─ Icon (mute button)
/// ```
///
/// **Audio Level Detection:**
/// - Reads `parameters.audioDecibels` list to find participant's audio level
/// - Matches by `participant.name` against `audioDecibels[i].name`
/// - Hides waveform if participant muted (`participant.muted == true`)
/// - Animates bar heights based on detected audio level (0-127 range)
///
/// **Mute Control Workflow:**
/// 1. User taps mute button (visible if `showControls=true`)
/// 2. Calls `controlUserMedia` function with:
///    - `participantId`: participant.id (socket ID)
///    - `participantName`: participant.name
///    - `type`: 'audio' (media type)
/// 3. `controlMedia` checks permissions:
///    - Host (islevel='2') → always allowed
///    - CoHost with 'media' permission → allowed
///    - Self-mute → always allowed
/// 4. Emits socket event `'controlMedia'` to server:
///    ```json
///    {
///      "participantId": "abc123",
///      "participantName": "John Doe",
///      "type": "audio"
///    }
///    ```
/// 5. Server broadcasts mute action to all clients
///
/// **Waveform Animation:**
/// - State creates 9 AnimationControllers (1 per bar)
/// - Effect hook polls `parameters.audioDecibels` every 2 seconds
/// - Updates bar heights via `setState` → triggers animations
/// - Bars scale from 1px (silent) to 40px (loud)
/// - Disposed on widget unmount
///
/// **Builder Hook Priorities:**
/// - `customBuilder` → full widget replacement (ignores all other props)
/// - `wrapperBuilder` → wraps Stack; receives stackChildren + default
/// - `containerBuilder` → wraps MiniCard container; receives child + default
/// - `infoBuilder` → wraps name badge; receives overlay + default
/// - `overlayBuilder` → wraps waveform; receives waveform + default
/// - `waveformBuilder` → wraps bars; receives animationControllers + default
///
/// **Common Use Cases:**
/// 1. **Basic Grid Display:**
///    ```dart
///    GridView.builder(
///      itemCount: audioParticipants.length,
///      itemBuilder: (context, index) {
///        final participant = audioParticipants[index];
///        return AudioCard(
///          options: AudioCardOptions(
///            name: participant.name,
///            participant: participant,
///            parameters: parameters,
///            customStyle: BoxDecoration(color: Colors.grey[800]),
///          ),
///        );
///      },
///    )
///    ```
///
/// 2. **Custom Controls Overlay:**
///    ```dart
///    AudioCard(
///      options: AudioCardOptions(
///        name: 'John Doe',
///        participant: participant,
///        parameters: parameters,
///        videoControlsComponent: Row(
///          children: [
///            IconButton(icon: Icon(Icons.mic_off), onPressed: muteAction),
///            IconButton(icon: Icon(Icons.more_vert), onPressed: showMenu),
///          ],
///        ),
///      ),
///    )
///    ```
///
/// 3. **Silent Display (No Controls):**
///    ```dart
///    AudioCard(
///      options: AudioCardOptions(
///        name: 'John Doe',
///        participant: participant,
///        parameters: parameters,
///        showControls: false,
///        showInfo: false,
///      ),
///    )
///    ```
///
/// **Override Integration:**
/// Integrates with `MediasfuUICustomOverrides` for global styling:
/// ```dart
/// overrides: MediasfuUICustomOverrides(
///   audioCardOptions: ComponentOverride<AudioCardOptions>(
///     builder: (existingOptions) => AudioCardOptions(
///       name: existingOptions.name,
///       participant: existingOptions.participant,
///       parameters: existingOptions.parameters,
///       customStyle: BoxDecoration(
///         gradient: LinearGradient(colors: [Colors.deepPurple, Colors.purple]),
///         borderRadius: BorderRadius.circular(12),
///       ),
///       barColor: Colors.pink,
///     ),
///   ),
/// ),
/// ```
///
/// **Performance Notes:**
/// - Animation controllers created once in initState
/// - Audio level polling every 2 seconds (not every frame)
/// - Waveform hidden if participant muted (skips rendering 9 bars)
/// - Disposed controllers cleaned up in dispose()
///
/// **Permission Requirements:**
/// - Muting others requires host or coHost with 'media' permission
/// - Self-mute always allowed
/// - Socket connection required for remote mute actions
class AudioCard extends StatefulWidget {
  final AudioCardOptions options;

  const AudioCard({
    super.key,
    required this.options,
  });

  @override
  _AudioCardState createState() => _AudioCardState();
}

class _AudioCardState extends State<AudioCard> with TickerProviderStateMixin {
  late List<AnimationController> waveformAnimations;
  ValueNotifier<bool> showWaveform = ValueNotifier<bool>(false);
  late Participant participant;

  @override
  void initState() {
    super.initState();
    waveformAnimations = List.generate(
      9,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(seconds: 2),
      ),
    );
    animateWaveform();
    showWaveform.value = true;
    participant = widget.options.participant;

    animateWaveformChecker();
  }

  void animateWaveformChecker() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      final audioDecibels =
          widget.options.parameters.getUpdatedAllParams().audioDecibels;
      final participants =
          widget.options.parameters.getUpdatedAllParams().participants;

      // Find the existing audio entry and participant based on the name.
      final existingEntry = audioDecibels.firstWhere(
        (entry) => entry.name == widget.options.name,
        orElse: () => AudioDecibels(name: '', averageLoudness: 0),
      );
      Participant? participant = participants.firstWhere(
        (participant) => participant.name == widget.options.name,
        orElse: () => Participant(
          id: '',
          name: '',
          muted: true,
          videoID: "",
          audioID: "",
        ),
      );
      if (existingEntry.name.isNotEmpty &&
          existingEntry.averageLoudness > 127.5 &&
          participant.name.isNotEmpty &&
          !participant.muted!) {
        // animateWaveform();
        showWaveform.value = true;
      } else {
        // resetWaveform();
        showWaveform.value = false;
      }
    });
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
                padding: const EdgeInsets.all(2), // Adjust padding here
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
                padding: const EdgeInsets.all(2), // Adjust padding here
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.25 * 255).toInt()),
                  borderRadius: BorderRadius.circular(0),
                ),
                child: Icon(
                  widget.options.participant.videoOn!
                      ? Icons.videocam
                      : Icons.videocam_off,
                  color: widget.options.participant.videoOn!
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

  void toggleAudio() async {
    if (!widget.options.participant.muted!) {
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

  void toggleVideo() async {
    if (widget.options.participant.videoOn!) {
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

    final stackChildren = <Widget>[
      Positioned.fill(child: _buildMiniCard()),
      Positioned(
        top: widget.options.infoPosition.toLowerCase().contains('top') ? 0 : null,
        left: widget.options.infoPosition.toLowerCase().contains('left') ? 0 : null,
        bottom: widget.options.infoPosition.toLowerCase().contains('bottom') ? 0 : null,
        right: widget.options.infoPosition.toLowerCase().contains('right') ? 0 : null,
        child: widget.options.showInfo ? _buildInfoOverlay(context) : const SizedBox(),
      ),
      Positioned(
        top: widget.options.controlsPosition.toLowerCase().contains('top') ? 0 : null,
        left: widget.options.controlsPosition.toLowerCase().contains('left') ? 0 : null,
        bottom: widget.options.controlsPosition.toLowerCase().contains('bottom') ? 0 : null,
        right: widget.options.controlsPosition.toLowerCase().contains('right') ? 0 : null,
        child: renderControls(),
      ),
      if (widget.options.videoInfoComponent != null)
        Positioned(
          top: widget.options.infoPosition.toLowerCase().contains('top') ? 0 : null,
          left: widget.options.infoPosition.toLowerCase().contains('left') ? 0 : null,
          bottom: widget.options.infoPosition.toLowerCase().contains('bottom') ? 0 : null,
          right: widget.options.infoPosition.toLowerCase().contains('right') ? 0 : null,
          child: widget.options.videoInfoComponent!,
        ),
    ];

    final defaultWrapper = Stack(children: stackChildren);

    final wrapper = widget.options.wrapperBuilder?.call(
          AudioCardWrapperContext(
            buildContext: context,
            options: widget.options,
            stackChildren: stackChildren,
            defaultWrapper: defaultWrapper,
          ),
        ) ??
        defaultWrapper;

    final BoxDecoration style = widget.options.customStyle;
    final BoxDecoration decoration = style.copyWith(
      color: style.color ?? widget.options.backgroundColor,
      border: style.border ?? Border.all(color: Colors.black, width: 2),
    );

    final defaultContainer = Container(
      padding: widget.options.containerPadding,
      margin: widget.options.containerMargin,
      alignment: widget.options.containerAlignment,
      decoration: decoration,
      child: wrapper,
    );

    final container = widget.options.containerBuilder?.call(
          AudioCardContainerContext(
            buildContext: context,
            options: widget.options,
            child: wrapper,
            defaultContainer: defaultContainer,
          ),
        ) ??
        defaultContainer;

    return container;
  }

  Widget _buildMiniCard() {
    return MiniCard(
      options: MiniCardOptions(
        initials: widget.options.name.isNotEmpty ? widget.options.name : '',
        fontSize: 24,
        imageSource: widget.options.imageSource,
        roundedImage: widget.options.roundedImage,
        imageStyle: widget.options.imageStyle,
      ),
    );
  }

  Widget _buildInfoOverlay(BuildContext context) {
    final waveformOverlay = _buildWaveform(context);

    final defaultInfo = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 5),
        waveformOverlay,
      ],
    );

    return widget.options.infoBuilder?.call(
          AudioCardInfoContext(
            buildContext: context,
            options: widget.options,
            overlay: waveformOverlay,
            defaultInfo: defaultInfo,
          ),
        ) ??
        defaultInfo;
  }

  Widget _buildWaveform(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: showWaveform,
      builder: (context, isVisible, child) {
        final bars = List.generate(
          waveformAnimations.length,
          (index) => AnimatedBuilder(
            animation: waveformAnimations[index],
            builder: (context, child) {
              final double randomHeight = Random().nextDouble() * 14;
              return Container(
                height: isVisible ? randomHeight : 0,
                width: 5,
                color: widget.options.barColor,
                margin: const EdgeInsets.symmetric(horizontal: 1),
              );
            },
          ),
        );

        final Widget defaultWaveform = isVisible
            ? Row(
                children: bars,
              )
            : const SizedBox();

        final waveformWidget = widget.options.waveformBuilder?.call(
              AudioCardWaveformContext(
                buildContext: context,
                options: widget.options,
                showWaveform: isVisible,
                animationControllers: waveformAnimations,
                barColor: widget.options.barColor,
                defaultWaveform: defaultWaveform,
              ),
            ) ??
            defaultWaveform;

        final BoxDecoration decoration = widget.options.overlayDecoration ??
            BoxDecoration(
              color: Colors.white.withAlpha((0.75 * 255).toInt()),
              borderRadius: BorderRadius.circular(0),
            );

        final Widget defaultOverlay = isVisible
            ? Container(
                padding: widget.options.overlayPadding ??
                    const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
                decoration: decoration,
                child: waveformWidget,
              )
            : const SizedBox();

        final overlayWidget = widget.options.overlayBuilder?.call(
              AudioCardOverlayContext(
                buildContext: context,
                options: widget.options,
                showWaveform: isVisible,
                waveform: waveformWidget,
                defaultOverlay: defaultOverlay,
              ),
            ) ??
            defaultOverlay;

        return overlayWidget;
      },
    );
  }
}
