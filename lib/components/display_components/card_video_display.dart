import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// CardVideoDisplay is a widget used to display video streams in a card format.
///
/// It takes in a [remoteProducerId] to identify the remote producer associated with the video stream,
/// an [eventType] to indicate the type of event related to the video stream, a [forceFullDisplay] flag
/// to determine whether to force full display of the video, a [videoStream] to be displayed,
/// a [backgroundColor] to specify the background color of the video display container,
/// and a [doMirror] flag to indicate whether to mirror the video display.
///
/// The [CardVideoDisplay] widget internally manages an [RTCVideoRenderer] for rendering the video stream.
///
/// Example:
/// ```dart
/// CardVideoDisplay(
///   remoteProducerId: 'remote_producer_123',
///   eventType: 'video_event',
///   forceFullDisplay: true,
///   videoStream: myVideoStream,
///   backgroundColor: Colors.black,
///   doMirror: false,
/// )
/// ```

class CardVideoDisplay extends StatefulWidget {
  final String remoteProducerId;
  final String eventType;
  final bool forceFullDisplay;
  final MediaStream videoStream;
  final Color backgroundColor;
  final bool doMirror;

  // ignore: prefer_const_constructors_in_immutables
  CardVideoDisplay({
    super.key,
    required this.remoteProducerId,
    required this.eventType,
    required this.forceFullDisplay,
    required this.videoStream,
    this.backgroundColor = Colors.transparent,
    required this.doMirror,
  });

  @override
  // ignore: library_private_types_in_public_api
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

  @override
  void dispose() {
    _renderer.dispose();
    super.dispose();
  }

  Future<void> _initRenderer() async {
    await _renderer.initialize();
    _renderer.srcObject = widget.videoStream;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: widget.backgroundColor,
        child: Container(
          color: widget.backgroundColor,
          child: RTCVideoView(_renderer,
              mirror: widget.doMirror,
              objectFit: widget.forceFullDisplay
                  ? RTCVideoViewObjectFit.RTCVideoViewObjectFitCover
                  : RTCVideoViewObjectFit.RTCVideoViewObjectFitContain),
        ));
  }
}
