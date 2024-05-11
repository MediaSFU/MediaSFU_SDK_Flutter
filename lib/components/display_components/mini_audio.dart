import 'package:flutter/material.dart';
import 'dart:math';

/// A compact widget for displaying audio information with customizable style and position.
///
/// This widget allows you to display audio information in a compact format with options
/// to show an image, waveform visualization, and text. It provides flexibility in
/// customizing the appearance and positioning of the audio widget.
/// A flag indicating whether the mini audio widget is visible.
///
/// Defaults to true if not provided.
///final bool visible;

/// Custom styles to apply to the mini audio widget.
///
/// These styles can be used to customize the appearance of the widget.
///final Map<String, dynamic> customStyle;

/// The name of the audio being displayed.
///final String name;

/// A flag indicating whether to show the waveform visualization.
///
/// Defaults to false if not provided.
///final bool showWaveform;

/// The position of the mini audio widget overlay on the screen.
///
/// The position can be specified as 'topRight', 'topLeft', 'bottomRight',
/// or 'bottomLeft'. Defaults to 'topRight' if not provided.
///final String overlayPosition;

/// The color of the waveform bars.
///
/// Defaults to a shade of red if not provided.
///final Color barColor;

/// The color of the text displayed on the mini audio widget.
///
/// Defaults to a shade of gray if not provided.
///final Color textColor;

/// The text style for the name of the audio.
///
/// Defaults to white color with bold font weight if not provided.
///final TextStyle nameTextStyling;

/// The source of the image to display on the mini audio widget.
///
/// Defaults to a placeholder image if not provided.
///final String imageSource;

/// A flag indicating whether to display the image with rounded corners.
///
/// Defaults to false if not provided.
///final bool roundedImage;

/// Custom styles to apply to the image displayed on the mini audio widget.
///final Map<String, dynamic> imageStyle;

/// Creates a mini audio widget with the specified parameters.
///
/// The [name] parameter is required. Other parameters have default values
/// and can be customized as needed.

class MiniAudio extends StatefulWidget {
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

  const MiniAudio({
    super.key,
    this.visible = true,
    this.customStyle = const {},
    required this.name,
    this.showWaveform = false,
    this.overlayPosition =
        'topRight', // 'topRight', 'topLeft', 'bottomRight', 'bottomLeft'
    this.barColor = const Color.fromARGB(255, 245, 28, 28),
    this.textColor = const Color.fromARGB(255, 24, 24, 24),
    this.nameTextStyling =
        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    this.imageSource = 'https://mediasfu.com/images/logo192.png',
    this.roundedImage = false,
    this.imageStyle = const {},
  });

  @override
  // ignore: library_private_types_in_public_api
  _MiniAudioState createState() => _MiniAudioState();
}

class _MiniAudioState extends State<MiniAudio> with TickerProviderStateMixin {
  late List<AnimationController> waveformAnimations;

  late OverlayEntry _overlayEntry;
  late Offset _position = Offset.zero;

  @override
  void initState() {
    super.initState();
    _overlayEntry = OverlayEntry(
      builder: (context) => buildMiniAudio(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Overlay.of(context).insert(_overlayEntry);
    });
    waveformAnimations = List.generate(
      9,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(seconds: 1),
      )..repeat(reverse: true),
    );
  }

  @override
  void dispose() {
    _overlayEntry.remove(); // Remove the existing overlay entry
    for (var controller in waveformAnimations) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget buildMiniAudio() {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _position += details.delta;
            _overlayEntry.markNeedsBuild();
          });
        },
        child: AnimatedOpacity(
          opacity: widget.visible ? 1.0 : 0.0,
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
                    BorderRadius.circular(widget.roundedImage ? 20 : 0),
              ),
              child: Stack(
                children: [
                  // Image Widget
                  if (widget.imageSource.isNotEmpty)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(widget.roundedImage ? 20 : 0),
                        child: Image.network(
                          widget.imageSource,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  // Waveform Widget
                  if (widget.showWaveform)
                    Positioned.fill(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          waveformAnimations.length,
                          (index) => AnimatedBuilder(
                            animation: waveformAnimations[index],
                            builder: (context, child) {
                              // Generate a random height between 1 and 30
                              final randomHeight = Random().nextDouble() * 30;
                              return Container(
                                height: widget.showWaveform
                                    ? randomHeight
                                    : 0, // Show or hide waveform based on the showWaveform flag
                                width: 8,
                                color: widget.barColor,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 1),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                  // Text Widget
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      color: Colors.black.withOpacity(0.5),
                      child: Text(
                        widget.name,
                        textAlign: TextAlign.center,
                        style: widget.nameTextStyling,
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

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // No visible widget needed
  }
}
