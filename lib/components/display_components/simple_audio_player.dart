import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// A simple, invisible audio player widget for translation audio.
///
/// This widget creates an RTCVideoRenderer, attaches the provided MediaStream,
/// and renders nothing visible (zero size). The audio plays automatically.
class SimpleAudioPlayer extends StatefulWidget {
  final MediaStream? stream;
  final String producerId;

  const SimpleAudioPlayer({
    super.key,
    required this.stream,
    required this.producerId,
  });

  @override
  State<SimpleAudioPlayer> createState() => _SimpleAudioPlayerState();
}

class _SimpleAudioPlayerState extends State<SimpleAudioPlayer> {
  late RTCVideoRenderer _renderer;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initRenderer();
  }

  Future<void> _initRenderer() async {
    _renderer = RTCVideoRenderer();
    await _renderer.initialize();
    if (widget.stream != null && mounted) {
      _renderer.srcObject = widget.stream;
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void didUpdateWidget(covariant SimpleAudioPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stream != oldWidget.stream && _isInitialized) {
      _renderer.srcObject = widget.stream;
    }
  }

  @override
  void dispose() {
    _renderer.srcObject = null;
    _renderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Invisible widget - just renders the RTCVideoView at 0x0 size for audio playback
    if (!_isInitialized) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: 0,
      height: 0,
      child: RTCVideoView(
        _renderer,
        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
      ),
    );
  }
}
