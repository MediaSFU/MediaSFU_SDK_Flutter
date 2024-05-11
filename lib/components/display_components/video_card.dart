import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import './card_video_display.dart' show CardVideoDisplay;
import './audio_decibel_check.dart' show AudioDecibelCheck;
import '../../consumers/control_media.dart' show controlMedia;
import 'dart:math';

/// VideoCard - A widget for displaying a video card with customizable features.
///
/// This widget allows you to display a video card with various customization options such as controls,
/// information display, and waveform animations.
///
/// The custom styling options for the video card.
///final Map<String, dynamic>? customStyle;
///
/// The name associated with the video.
///final String? name;
///
/// The color of the bars in the controls.
///final Color? barColor;
///
/// The color of the text in the controls.
///final Color? textColor;
///
/// The source of the image to display in the video card.
///final String? imageSource;
///
/// A flag indicating whether to round the edges of the image.
///final bool? roundedImage;
///
/// The style options for the image.
///final Map<String, dynamic>? imageStyle;
///
/// The ID of the remote producer associated with the video.
///final String? remoteProducerId;
///
/// The type of event associated with the video.
///final String? eventType;
///
/// A flag indicating whether to force full display of the video.
///final bool? forceFullDisplay;
///
/// The video stream to display in the card.
///final dynamic videoStream;
///
/// A flag indicating whether to show controls for the video.
///final bool? showControls;
///
/// A flag indicating whether to show information about the video.
///final bool? showInfo;
///
/// The component to display video information.
///final Widget? videoInfoComponent;
///
/// The component to display video controls.
///final Widget? videoControlsComponent;
///
/// The position of the controls.
///final String? controlsPosition;
///
/// The position of the information display.
///final String? infoPosition;
///
/// The participant associated with the video.
///final dynamic participant;
///
/// The background color of the video card.
///final Color? backgroundColor;
///
/// The audio decibels of the video.
///final Map<String, dynamic>? audioDecibels;
///
/// A flag indicating whether to mirror the video.
///final bool? doMirror;
///
/// The parameters associated with the video.
///final Map<String, dynamic> parameters;

class VideoCard extends StatefulWidget {
  final Map<String, dynamic>? customStyle;
  final String? name;
  final Color? barColor;
  final Color? textColor;
  final String? imageSource;
  final bool? roundedImage;
  final Map<String, dynamic>? imageStyle;
  final String? remoteProducerId;
  final String? eventType;
  final bool? forceFullDisplay;
  final dynamic videoStream;
  final bool? showControls;
  final bool? showInfo;
  final Widget? videoInfoComponent;
  final Widget? videoControlsComponent;
  final String? controlsPosition;
  final String? infoPosition;
  final dynamic participant;
  final Color? backgroundColor;
  final Map<String, dynamic>? audioDecibels;
  final bool? doMirror;
  final Map<String, dynamic> parameters;

  const VideoCard({
    super.key,
    this.customStyle,
    this.name,
    this.barColor = const Color.fromARGB(255, 232, 46, 46),
    this.textColor = const Color.fromARGB(255, 25, 25, 25),
    this.imageSource,
    this.roundedImage,
    this.imageStyle,
    this.remoteProducerId,
    this.eventType,
    this.forceFullDisplay,
    required this.videoStream,
    this.showControls,
    this.showInfo,
    this.videoInfoComponent,
    this.videoControlsComponent,
    this.controlsPosition = 'topLeft',
    this.infoPosition = 'topRight',
    required this.participant,
    this.backgroundColor,
    this.audioDecibels,
    this.doMirror,
    required this.parameters,
  });

  @override
  // ignore: library_private_types_in_public_api
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
            vsync: this, duration: const Duration(seconds: 1)));
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
    if (!widget.showControls!) {
      return const SizedBox();
    }

    final controlsComponent = widget.videoControlsComponent ??
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: toggleAudio,
              child: Container(
                padding: const EdgeInsets.all(2), // Adjust padding here
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(0),
                ),
                child: Icon(
                  widget.participant?['muted'] ?? false
                      ? Icons.mic_off
                      : Icons.mic_none,
                  color: widget.participant?['muted'] ?? false
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
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(0),
                ),
                child: Icon(
                  widget.participant?['videoOn'] ?? true
                      ? Icons.videocam
                      : Icons.videocam_off,
                  color: widget.participant?['videoOn'] ?? true
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
    if (widget.participant?['muted'] ?? false) {
      // Handle when participant is muted
    } else {
      // Handle when participant is not muted
      await controlMedia(
        participantId: widget.participant['id'],
        participantName: widget.participant['name'],
        type: 'audio',
        parameters: widget.parameters,
      );
    }
  }

  void toggleVideo() async {
    if (widget.participant?['videoOn'] ?? false) {
      // Handle when participant's video is on
      await controlMedia(
        participantId: widget.participant['id'],
        participantName: widget.participant['name'],
        type: 'video',
        parameters: widget.parameters,
      );
    } else {
      // Handle when participant's video is off
    }
  }

  @override
  Widget build(BuildContext context) {
    animateWaveform();
    try {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
          color: widget.backgroundColor ?? const Color(0xFF2c678f),
        ),
        child: Stack(
          children: [
            CardVideoDisplay(
              remoteProducerId: widget.remoteProducerId!,
              eventType: widget.eventType!,
              forceFullDisplay: widget.forceFullDisplay!,
              videoStream: widget.videoStream,
              backgroundColor: widget.backgroundColor!,
              doMirror: widget.doMirror!,
            ),
            Positioned(
              top: widget.infoPosition! == 'topLeft'
                  ? 0
                  : widget.infoPosition! == 'topRight'
                      ? 0
                      : null,
              left: widget.infoPosition! == 'topLeft'
                  ? 0
                  : widget.infoPosition! == 'bottomLeft'
                      ? 0
                      : null,
              bottom: widget.infoPosition! == 'bottomLeft'
                  ? 0
                  : widget.infoPosition! == 'bottomRight'
                      ? 0
                      : null,
              right: widget.infoPosition! == 'topRight'
                  ? 0
                  : widget.infoPosition! == 'bottomRight'
                      ? 0
                      : null,
              child: widget.videoInfoComponent ??
                  (widget.showInfo!
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 2, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(
                                    0.25), // Adjust opacity as needed
                                borderRadius: BorderRadius.circular(
                                    0), // Adjust border radius as needed
                              ),
                              child: Text(
                                widget.participant?['name'] ?? '',
                                style: TextStyle(
                                  color: widget.textColor!,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            showWaveform.value
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 2, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(
                                          0.25), // Adjust opacity as needed
                                      borderRadius: BorderRadius.circular(
                                          0), // Adjust border radius as needed
                                    ),
                                    child: ValueListenableBuilder<bool>(
                                        valueListenable: showWaveform,
                                        builder:
                                            (context, showWaveform, child) {
                                          return showWaveform
                                              ? Row(
                                                  children: List.generate(
                                                    waveformAnimations.length,
                                                    (index) => AnimatedBuilder(
                                                      animation:
                                                          waveformAnimations[
                                                              index],
                                                      builder:
                                                          (context, child) {
                                                        // Generate a random height between 1 and 14
                                                        final randomHeight =
                                                            Random().nextDouble() *
                                                                14;
                                                        return Container(
                                                          height: showWaveform
                                                              ? randomHeight
                                                              : 0, // Show or hide waveform based on the showWaveform flag
                                                          width: 5,
                                                          color:
                                                              widget.barColor!,
                                                          margin:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      1),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox();
                                        }))
                                : const SizedBox(),
                          ],
                        )
                      : const SizedBox()),
            ),
            widget.showControls == true
                ? Positioned(
                    top: widget.controlsPosition == 'topLeft' ||
                            widget.controlsPosition == 'topRight'
                        ? 0
                        : null,
                    left: widget.controlsPosition == 'topLeft' ||
                            widget.controlsPosition == 'bottomLeft'
                        ? 0
                        : null,
                    bottom: widget.controlsPosition == 'bottomLeft' ||
                            widget.controlsPosition == 'bottomRight'
                        ? 0
                        : null,
                    right: widget.controlsPosition == 'topRight' ||
                            widget.controlsPosition == 'bottomRight'
                        ? 0
                        : null,
                    child: Container(
                      // padding: EdgeInsets.all(2),
                      child: renderControls(),
                    ),
                  )
                : const SizedBox(),
            // Add AudioDecibelCheck widget to control the showWaveform status
            AudioDecibelCheck(
              animateWaveform: animateWaveform,
              resetWaveform: resetWaveform,
              name: widget.name!,
              participant: widget.participant!,
              parameters: widget.parameters,
              onShowWaveformChanged: updateShowWaveform,
            ),
          ],
        ),
      );
    } catch (error) {
      if (kDebugMode) {
        // print('Error add widget: $error');
      }

      return ErrorWidget(error.toString());
    }
  }
}
