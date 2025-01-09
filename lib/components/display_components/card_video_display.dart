import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../types/types.dart' show EventType;

/// CardVideoDisplayOptions - Configuration options for the `CardVideoDisplay` widget.
///
/// Example:
/// ```dart
/// CardVideoDisplayOptions(
///   remoteProducerId: 'remote_producer_123',
///   eventType: 'video_event',
///   forceFullDisplay: true,
///   videoStream: myVideoStream,
///   backgroundColor: Colors.black,
///   doMirror: true,
/// )
/// ```

class CardVideoDisplayOptions {
  final String remoteProducerId;
  final EventType eventType;
  final bool forceFullDisplay;
  final MediaStream videoStream;
  final Color backgroundColor;
  final bool doMirror;

  CardVideoDisplayOptions({
    required this.remoteProducerId,
    required this.eventType,
    required this.forceFullDisplay,
    required this.videoStream,
    this.backgroundColor = Colors.transparent,
    this.doMirror = false,
  });
}

typedef CardVideoDisplayType = Widget Function({
  required CardVideoDisplayOptions options,
});

/// CardVideoDisplay - A widget to display video streams in a card format based on [CardVideoDisplayOptions].
///
/// Example:
/// ```dart
/// CardVideoDisplay(
///   options: CardVideoDisplayOptions(
///     remoteProducerId: 'remote_producer_123',
///     eventType: 'video_event',
///     forceFullDisplay: true,
///     videoStream: myVideoStream,
///     backgroundColor: Colors.black,
///     doMirror: true,
///   ),
/// )
/// ```
///
class CardVideoDisplay extends StatefulWidget {
  final CardVideoDisplayOptions options;

  const CardVideoDisplay({super.key, required this.options});

  @override
  _CardVideoDisplayState createState() => _CardVideoDisplayState();
}

class _CardVideoDisplayState extends State<CardVideoDisplay> {
  late RTCVideoRenderer _renderer;

  @override
  void initState() {
    super.initState();
    _renderer = RTCVideoRenderer();
    _initRenderer();
  }

  void checkStreamReady() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (widget.options.videoStream.getVideoTracks().isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _renderer.srcObject = widget.options.videoStream;
        });
      } else {
        checkStreamReady(); // Keep checking
      }
    });
  }

  Future<void> _initRenderer() async {
    await _renderer.initialize();
    checkStreamReady();
  }

  @override
  void dispose() {
    _renderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.options.backgroundColor,
      child: RTCVideoView(
        _renderer,
        mirror: widget.options.doMirror,
        objectFit: widget.options.forceFullDisplay
            ? RTCVideoViewObjectFit.RTCVideoViewObjectFitCover
            : RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
      ),
    );
  }
}
