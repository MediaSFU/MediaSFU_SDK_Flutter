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
    animateWaveform();
    try {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
          color: widget.options.backgroundColor,
        ),
        child: Stack(
          children: [
            CardVideoDisplay(
              options: CardVideoDisplayOptions(
                  remoteProducerId: widget.options.remoteProducerId,
                  eventType: widget.options.eventType,
                  forceFullDisplay: widget.options.forceFullDisplay,
                  videoStream: widget.options.videoStream!,
                  backgroundColor: widget.options.backgroundColor,
                  doMirror: widget.options.doMirror),
            ),
            Positioned(
              top: widget.options.infoPosition.toLowerCase().contains('top')
                  ? 0
                  : null,
              left: widget.options.infoPosition.toLowerCase().contains('left')
                  ? 0
                  : null,
              bottom:
                  widget.options.infoPosition.toLowerCase().contains('bottom')
                      ? 0
                      : null,
              right: widget.options.infoPosition.toLowerCase().contains('right')
                  ? 0
                  : null,
              child: widget.options.videoInfoComponent ??
                  (widget.options.showInfo
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 2, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withAlpha((0.25 * 255).toInt()),
                                borderRadius: BorderRadius.circular(0),
                              ),
                              child: Text(
                                widget.options.participant.name,
                                style: TextStyle(
                                  color: widget.options.textColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            ValueListenableBuilder<bool>(
                              valueListenable: showWaveform,
                              builder: (context, show, child) {
                                return show
                                    ? Row(
                                        children: List.generate(
                                          waveformAnimations.length,
                                          (index) => AnimatedBuilder(
                                            animation:
                                                waveformAnimations[index],
                                            builder: (context, child) {
                                              final randomHeight =
                                                  Random().nextDouble() * 14;
                                              return Container(
                                                height: show ? randomHeight : 0,
                                                width: 5,
                                                color: widget.options.barColor,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 1),
                                              );
                                            },
                                          ),
                                        ),
                                      )
                                    : const SizedBox();
                              },
                            ),
                          ],
                        )
                      : const SizedBox()),
            ),
            widget.options.showControls
                ? Positioned(
                    top: widget.options.controlsPosition
                            .toLowerCase()
                            .contains('top')
                        ? 0
                        : null,
                    left: widget.options.controlsPosition
                            .toLowerCase()
                            .contains('left')
                        ? 0
                        : null,
                    bottom: widget.options.controlsPosition
                            .toLowerCase()
                            .contains('bottom')
                        ? 0
                        : null,
                    right: widget.options.controlsPosition
                            .toLowerCase()
                            .contains('right')
                        ? 0
                        : null,
                    child: Container(
                      child: renderControls(),
                    ),
                  )
                : const SizedBox(),
            // Add AudioDecibelCheck widget to control the showWaveform status
            AudioDecibelCheck(
                options: AudioDecibelCheckOptions(
              animateWaveform: animateWaveform,
              resetWaveform: resetWaveform,
              name: widget.options.name,
              participant: widget.options.participant,
              parameters: widget.options.parameters,
              onShowWaveformChanged: updateShowWaveform,
            )),
          ],
        ),
      );
    } catch (error) {
      if (kDebugMode) {
        print('Error adding widget: $error');
      }
      return ErrorWidget(error.toString());
    }
  }
}
