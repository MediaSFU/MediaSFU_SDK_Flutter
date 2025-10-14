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
  show AudioDecibels, Participant, CoHostResponsibility, ShowAlert, EventType;

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

  VideoCardParameters Function() get getUpdatedAllParams;

  // dynamic operator [](String key);
}

/// Configuration options for the `VideoCard` widget.
///
/// The `VideoCardOptions` class provides a comprehensive set of configuration options to customize
/// the appearance and behavior of the `VideoCard` widget, including parameters for audio and video control,
/// waveform animations, and display options.
///
/// ### Example:
/// ```dart
/// // Using the default VideoCard
/// VideoCard(
///   options: VideoCardOptions(
///     parameters: VideoCardParametersImplementation(),
///     name: "John Doe",
///     remoteProducerId: "12345",
///     eventType: EventType.video,
///     videoStream: mediaStream,
///     participant: participant,
///   ),
/// );
///
/// // Using a custom VideoCard builder
/// Widget myCustomVideoCard({required VideoCardOptions options}) {
///   return Container(
///     decoration: BoxDecoration(
///       color: Colors.purple,
///       borderRadius: BorderRadius.circular(20),
///     ),
///     child: Column(
///       children: [
///         Text('Custom: ${options.name}'),
///         // Your custom video display logic here
///       ],
///     ),
///   );
/// }
///
/// VideoCard(
///   options: VideoCardOptions(
///     parameters: VideoCardParametersImplementation(),
///     name: "John Doe",
///     remoteProducerId: "12345",
///     eventType: EventType.video,
///     videoStream: mediaStream,
///     participant: participant,
///     customBuilder: myCustomVideoCard, // Pass the custom builder
///   ),
/// );
/// ```
///
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
  });
}

typedef VideoCardType = Widget Function({required VideoCardOptions options});

/// VideoCard - A widget for displaying a video card with customizable features.
///
/// The `VideoCard` widget provides an interface for rendering video streams, participant information,
/// audio waveform animations, and control options in a structured card format. It offers options
/// for displaying audio waveform feedback based on audio decibel levels, control buttons
/// for managing audio and video settings, and additional participant details.
///
/// ### Parameters:
/// - `options` (`VideoCardOptions`): Configuration options for the video card.
///
/// ### Example Usage:
/// ```dart
/// VideoCard(
///   options: VideoCardOptions(
///     parameters: VideoCardParametersImplementation(),
///     name: "John Doe",
///     remoteProducerId: "12345",
///     eventType: EventType.video,
///     videoStream: mediaStream,
///     participant: participant,
///   ),
/// );
/// ```
///
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
      final stackChildren = <Widget>[
        Positioned.fill(child: _buildVideoDisplay()),
        _buildOverlayPositioned(context),
        if (widget.options.showControls) _buildControlsPositioned(),
        _buildAudioDecibelCheck(),
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

  Widget _buildOverlay(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: showWaveform,
      builder: (context, isVisible, child) {
        final waveform = _buildWaveform(context, isVisible);
        final info = _buildInfo(context, waveform);

        Widget defaultOverlay = info;

        final hasOverlayStyling =
            widget.options.overlayDecoration != null ||
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

    final decoration = widget.options.nameContainerDecoration ?? defaultDecoration;
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
