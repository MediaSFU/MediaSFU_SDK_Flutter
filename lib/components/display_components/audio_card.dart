import 'dart:async';
import 'package:flutter/material.dart';
import './mini_card.dart' show MiniCard;
import 'dart:math';
import '../../consumers/control_media.dart' show controlMedia;

/// AudioCard - A card widget for displaying audio-related information and controls.
///
/// This widget represents a card that displays audio-related information, such as
/// participant name, audio waveform, and audio controls (e.g., mute/unmute).
///
/// Required parameters:
/// - [customStyle]: The custom decoration style for the card.
/// - [name]: The name of the participant associated with the audio.
/// - [onHide]: A function to handle hiding the audio card.
/// - [parameters]: Additional parameters for customizing the audio card behavior.
///
/// Optional parameters:
/// - [barColor]: The color of the audio waveform bars. Defaults to red.
/// - [textColor]: The color of the text in the audio card. Defaults to white.
/// - [imageSource]: The image source for the participant avatar.
/// - [roundedImage]: Whether the participant avatar should have rounded corners. Defaults to false.
/// - [imageStyle]: The decoration style for the participant avatar image.
/// - [showControls]: Whether to display audio controls. Defaults to true.
/// - [showInfo]: Whether to display participant information. Defaults to true.
/// - [videoInfoComponent]: A custom widget for displaying video-related information.
/// - [videoControlsComponent]: A custom widget for displaying video controls.
/// - [controlsPosition]: The position of the audio controls (topLeft, topRight, bottomLeft, bottomRight). Defaults to topLeft.
/// - [infoPosition]: The position of the participant information (topLeft, topRight, bottomLeft, bottomRight). Defaults to topRight.
/// - [backgroundColor]: The background color of the audio card. Defaults to white.
///
/// Example:
/// ```dart
/// AudioCard(
///   customStyle: BoxDecoration(
///     color: Colors.blueGrey,
///     borderRadius: BorderRadius.circular(10),
///   ),
///   name: 'John Doe',
///   onHide: () {
///     // Logic to hide the audio card
///   },
///   parameters: {
///     // Additional parameters here
///   },
/// );
/// ```

class AudioCard extends StatefulWidget {
  final BoxDecoration customStyle;
  final String? name;
  final Color? barColor;
  final Color? textColor;
  final String? imageSource;
  final bool? roundedImage;
  final BoxDecoration? imageStyle; // Update the type to BoxDecoration?
  final bool? showControls;
  final bool? showInfo;
  final Widget? videoInfoComponent;
  final Widget? videoControlsComponent;
  final String? controlsPosition;
  final String? infoPosition;
  final Map<String, dynamic> participant;
  final Map<String, dynamic>? audioDecibels;
  final Map<String, dynamic> parameters;
  final Color? backgroundColor;

  const AudioCard({
    super.key,
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
    this.participant = const {},
    this.audioDecibels,
    required this.parameters,
    this.backgroundColor = Colors.white,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AudioCardState createState() => _AudioCardState();
}

class _AudioCardState extends State<AudioCard> with TickerProviderStateMixin {
  late List<AnimationController> waveformAnimations;
  ValueNotifier<bool> showWaveform = ValueNotifier<bool>(false);
  late Map<String, dynamic>? participant;

  @override
  void initState() {
    super.initState();
    waveformAnimations = List.generate(
        9,
        (_) => AnimationController(
            vsync: this, duration: const Duration(seconds: 1)));
    animateWaveform();
    showWaveform.value = true;
    participant = widget.parameters['participants'].firstWhere(
        (participant) => participant!['name'] == widget.name,
        orElse: () => null);

    animateWaveformChecker();
  }

  void animateWaveformChecker() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      final audioDecibels =
          widget.parameters['getUpdatedAllParams']()['audioDecibels'];
      final participants =
          widget.parameters['getUpdatedAllParams']()['participants'];

      // Find the existing audio entry and participant based on the name.
      final existingEntry = audioDecibels?.firstWhere(
        (entry) => entry['name'] == widget.name,
        orElse: () => null,
      );
      participant = participants?.firstWhere(
        (participant) => participant['name'] == widget.name,
        orElse: () => null,
      );
      if (existingEntry != null &&
          existingEntry['averageLoudness'] > 127.5 &&
          participant != null &&
          !participant!['muted']) {
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
                  widget.participant['muted'] ?? false
                      ? Icons.mic_off
                      : Icons.mic_none,
                  color: widget.participant['muted'] ?? false
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
                  widget.participant['videoOn'] ?? true
                      ? Icons.videocam
                      : Icons.videocam_off,
                  color: widget.participant['videoOn'] ?? true
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
    // Implement audio toggle functionality here
    if (participant!['muted']) {
    } else {
      await controlMedia(
        participantId: participant!['id'],
        participantName: widget.name!,
        type: 'audio',
        parameters: widget.parameters,
      );
    }
  }

  void toggleVideo() async {
    // Implement video toggle functionality here
    if (participant!['videoOn']) {
      await controlMedia(
        participantId: participant!['id'],
        participantName: widget.name!,
        type: 'video',
        parameters: widget.parameters,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.customStyle.color,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Stack(
        children: [
          // Use MiniCard widget instead of Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: MiniCard(
              initials: widget.name!.isNotEmpty ? widget.name! : '',
              fontSize: 24,
              imageSource: widget.imageSource,
              roundedImage: widget.roundedImage ?? false,
              imageStyle: widget.imageStyle, // Use imageStyle here
            ),
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
              child: widget.showInfo!
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Container(
                        //   padding: const EdgeInsets.symmetric(
                        //       horizontal: 2, vertical: 3),
                        //   decoration: BoxDecoration(
                        //     color: Colors.white
                        //         .withOpacity(0.25), // Adjust opacity as needed
                        //     borderRadius: BorderRadius.circular(
                        //         0), // Adjust border radius as needed
                        //   ),
                        //   child: Text(
                        //     widget.participant['name'] ?? '',
                        //     style: TextStyle(
                        //       color: widget.textColor!,
                        //       fontSize: 14,
                        //       fontWeight: FontWeight.bold,
                        //     ),
                        //   ),
                        // ),
                        const SizedBox(width: 5),
                        Container(
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
                                builder: (context, showWaveform, child) {
                                  return showWaveform
                                      ? Row(
                                          children: List.generate(
                                            waveformAnimations.length,
                                            (index) => AnimatedBuilder(
                                              animation:
                                                  waveformAnimations[index],
                                              builder: (context, child) {
                                                // Generate a random height between 1 and 14
                                                final randomHeight =
                                                    Random().nextDouble() * 14;
                                                return Container(
                                                  height: showWaveform
                                                      ? randomHeight
                                                      : 0, // Show or hide waveform based on the showWaveform flag
                                                  width: 5,
                                                  color: widget.barColor!,
                                                  margin: const EdgeInsets
                                                      .symmetric(horizontal: 1),
                                                );
                                              },
                                            ),
                                          ),
                                        )
                                      : const SizedBox();
                                })),
                      ],
                    )
                  : const SizedBox()),
          Positioned(
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
            child: renderControls(),
          )
        ],
      ),
    );
  }
}
