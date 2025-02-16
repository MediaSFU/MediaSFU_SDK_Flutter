import 'package:flutter/material.dart';
import 'dart:math';

/// `MiniAudioOptions` - Configuration options for the `MiniAudio` widget.
///
/// ### Properties:
/// - `visible` (`bool`): Controls the visibility of the `MiniAudio` widget (default is `true`).
/// - `customStyle` (`Map<String, dynamic>`): Custom styles for the widget (default is an empty map).
/// - `name` (`String`): The name of the audio track, displayed at the top.
/// - `showWaveform` (`bool`): Toggles the display of a waveform animation (default is `false`).
/// - `overlayPosition` (`String`): Sets the position of the overlay (default is 'topRight').
/// - `barColor` (`Color`): Color of the waveform bars (default is `Color(0xFFF51C1C)`).
/// - `textColor` (`Color`): Color of the text displayed on the widget (default is `Color(0xFF181818)`).
/// - `nameTextStyling` (`TextStyle`): Text style for the name (default is bold white text).
/// - `imageSource` (`String`): URL for the image to display as the background.
/// - `roundedImage` (`bool`): Sets the image as rounded if `true` (default is `false`).
/// - `imageStyle` (`Map<String, dynamic>`): Additional styling options for the image.
///
/// ### Example Usage:
/// ```dart
/// MiniAudio(
///   options: MiniAudioOptions(
///     name: "Sample Audio",
///     showWaveform: true,
///     imageSource: "https://example.com/image.jpg",
///     roundedImage: true,
///   ),
/// );
/// ```
class MiniAudioOptions {
  final bool visible;
  final Map<String, dynamic> customStyle;
  final String name;
  final bool showWaveform;
  final String overlayPosition;
  final Color barColor;
  final Color textColor;
  final TextStyle nameTextStyling;
  final String imageSource;
  final bool roundedImage;
  final Map<String, dynamic> imageStyle;

  MiniAudioOptions({
    this.visible = true,
    this.customStyle = const {},
    required this.name,
    this.showWaveform = false,
    this.overlayPosition = 'topRight',
    this.barColor = const Color.fromARGB(255, 245, 28, 28),
    this.textColor = const Color.fromARGB(255, 24, 24, 24),
    this.nameTextStyling =
        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    this.imageSource = 'https://mediasfu.com/images/logo192.png',
    this.roundedImage = false,
    this.imageStyle = const {},
  });
}

typedef MiniAudioType = Widget Function({required MiniAudioOptions options});

/// `MiniAudio` - A widget that displays a mini audio card with customizable audio information.
///
/// This widget provides an overlay for audio tracks, displaying a customizable name,
/// optional waveform animation, and image background. It supports drag-and-drop positioning
/// on the screen and allows for visual customization of waveform and image.
///
/// ### Parameters:
/// - `options` (`MiniAudioOptions`): The configuration options for the widget.
///
/// ### Structure:
/// - Displays the widget as a draggable overlay with the following elements:
///   - Background image (optional) - Loaded from the specified URL or falls back to initials.
///   - Audio waveform (optional) - An animated series of bars, shown based on `showWaveform`.
///   - Audio name - Displayed as a semi-transparent overlay at the top.
///
/// ### Example Usage:
/// ```dart
/// MiniAudio(
///   options: MiniAudioOptions(
///     name: "Now Playing",
///     showWaveform: true,
///     barColor: Colors.green,
///   ),
/// );
/// ```
///
/// ### Notes:
/// - The waveform animation is randomly generated to give a dynamic visual effect.
class MiniAudio extends StatefulWidget {
  final MiniAudioOptions options;

  const MiniAudio({super.key, required this.options});

  @override
  _MiniAudioState createState() => _MiniAudioState();
}

class _MiniAudioState extends State<MiniAudio> with TickerProviderStateMixin {
  late List<AnimationController> waveformAnimations;
  late Offset position;
  late OverlayEntry overlayEntry;
  bool isDragging = false;

  @override
  void initState() {
    super.initState();
    waveformAnimations = List.generate(
      9,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(seconds: 1),
      )..repeat(reverse: true),
    );

    position = const Offset(50, 50); // Starting position of the widget
    overlayEntry = OverlayEntry(builder: (context) => buildMiniAudio());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Overlay.of(context).insert(overlayEntry);
    });
  }

  @override
  void dispose() {
    overlayEntry.remove();
    for (var controller in waveformAnimations) {
      controller.dispose();
    }
    super.dispose();
  }

  // Builds the main widget with drag handling, image, waveform, and name display
  Widget buildMiniAudio() {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          if (!mounted) return;
          setState(() {
            position += details.delta;
            overlayEntry.markNeedsBuild();
          });
        },
        onPanEnd: (_) => setState(() => isDragging = false),
        child: AnimatedOpacity(
          opacity: widget.options.visible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: Card(
              color: const Color(0xFF2C678F),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(widget.options.roundedImage ? 20 : 0),
              ),
              child: Stack(
                children: [
                  // Image Widget
                  if (widget.options.imageSource.isNotEmpty)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            widget.options.roundedImage ? 20 : 0),
                        child: Image.network(
                          widget.options.imageSource,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildInitials(),
                        ),
                      ),
                    ),
                  // Waveform Widget
                  if (widget.options.showWaveform)
                    Positioned.fill(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          waveformAnimations.length,
                          (index) => AnimatedBuilder(
                            animation: waveformAnimations[index],
                            builder: (context, child) {
                              final randomHeight = Random().nextDouble() * 30;
                              return Container(
                                height: widget.options.showWaveform
                                    ? randomHeight
                                    : 0, // Show or hide waveform based on the showWaveform flag
                                width: 8,
                                color: widget.options.barColor,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 1),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  // Name Text Widget
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      color: Colors.black.withAlpha((0.5 * 255).toInt()),
                      child: Text(
                        widget.options.name,
                        textAlign: TextAlign.center,
                        style: widget.options.nameTextStyling,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInitials() {
    return Center(
      child: Text(
        widget.options.name.substring(0, 2).toUpperCase(),
        style: TextStyle(
          fontSize: 20,
          color: widget.options.textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox
        .shrink(); // No visible widget is required in the main build
  }
}
