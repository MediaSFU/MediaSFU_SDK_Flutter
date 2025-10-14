import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:socket_io_client/socket_io_client.dart' as io;
import './mini_card.dart' show MiniCard, MiniCardOptions;
import '../../consumers/control_media.dart'
    show controlMedia, ControlMediaType, ControlMediaOptions;
import '../../types/types.dart'
    show Participant, ShowAlert, EventType, CoHostResponsibility, AudioDecibels;

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

/// AudioCardOptions - Configuration options for the `AudioCard` widget.
///
/// Example:
/// ```dart
/// // Using the default AudioCard
/// AudioCard(
///   options: AudioCardOptions(
///     name: "Participant Name",
///     customStyle: BoxDecoration(color: Colors.grey),
///     participant: participantData,
///     barColor: Colors.red,
///     parameters: parameters,
///   ),
/// );
///
/// // Using a custom AudioCard builder
/// Widget myCustomAudioCard({required AudioCardOptions options}) {
///   return Container(
///     decoration: BoxDecoration(
///       color: Colors.orange,
///       borderRadius: BorderRadius.circular(15),
///     ),
///     child: Row(
///       children: [
///         Icon(Icons.person),
///         Text('Custom: ${options.name}'),
///         // Your custom audio controls here
///       ],
///     ),
///   );
/// }
///
/// AudioCard(
///   options: AudioCardOptions(
///     name: "Participant Name",
///     customStyle: BoxDecoration(color: Colors.grey),
///     participant: participantData,
///     barColor: Colors.red,
///     parameters: parameters,
///     customBuilder: myCustomAudioCard, // Pass the custom builder
///   ),
/// );
/// );
/// ```
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

/// AudioCard - A card widget for displaying audio-related information and controls for a participant.
///
/// Example:
/// ```dart
/// AudioCard(
///   options: AudioCardOptions(
///     name: "Participant Name",
///     customStyle: BoxDecoration(color: Colors.grey),
///     participant: participantData,
///     barColor: Colors.red,
///     parameters: parameters,
///   ),
/// );
/// ```
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
