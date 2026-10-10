import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart'
    show Consumer;
import '../../../components/display_components/mini_audio.dart'
    show MiniAudio, MiniAudioOptions;
import '../../../utils/image_utils.dart' show kDefaultMediaSFULogo;

/// Plays audio shared with a screen share. While it plays, it shows an audio card ("<name> · Screen audio") with a
/// waveform, like other audio-only sources; it never marks the sharer as speaking. Tapping the card mutes or unmutes it
/// for this listener only.
class ScreenAudioPlayer extends StatefulWidget {
  final MediaStream stream;
  final String remoteProducerId;
  final Consumer? consumer;
  final String ownerName;

  /// Replace the card (same props map as MiniAudioPlayer's `miniAudioComponent`).
  final Widget Function(Map<String, dynamic> props)? cardBuilder;

  /// Hide the card entirely (audio still plays).
  final bool hideCard;

  const ScreenAudioPlayer({
    super.key,
    required this.stream,
    required this.remoteProducerId,
    this.consumer,
    this.ownerName = '',
    this.cardBuilder,
    this.hideCard = false,
  });

  @override
  State<ScreenAudioPlayer> createState() => _ScreenAudioPlayerState();
}

class _ScreenAudioPlayerState extends State<ScreenAudioPlayer> {
  static const double _levelThreshold = 0.01;
  final RTCVideoRenderer _renderer = RTCVideoRenderer();
  Timer? _timer;
  bool _active = false;
  bool _muted = false;

  @override
  void initState() {
    super.initState();
    _initRenderer();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _pollLevel());
  }

  Future<void> _initRenderer() async {
    // On web the renderer owns the audio element; on native platforms remote audio plays by itself.
    await _renderer.initialize();
    _renderer.srcObject = widget.stream;
    if (mounted) setState(() {});
  }

  Future<void> _pollLevel() async {
    double level = 0;
    try {
      final stats = await widget.consumer?.rtpReceiver?.getStats();
      stats?.forEach((report) {
        if (report.type == 'inbound-rtp' && report.values['audioLevel'] != null) {
          level = (report.values['audioLevel'] as num).toDouble();
        }
      });
    } catch (_) {}
    final active = level > _levelThreshold;
    if (mounted && active != _active) setState(() => _active = active);
  }

  void _toggleMute() {
    final next = !_muted;
    for (final track in widget.stream.getAudioTracks()) {
      track.enabled = !next;
    }
    setState(() => _muted = next);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _renderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = '${widget.ownerName.isNotEmpty ? '${widget.ownerName} · ' : ''}'
        'Screen audio${_muted ? ' (muted)' : ''}';
    final visible = !widget.hideCard && (_active || _muted);
    final props = <String, dynamic>{
      'name': label,
      'showWaveform': _active && !_muted,
      'visible': visible,
      'screenAudio': true,
      'muted': _muted,
    };
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(width: 1, height: 1, child: RTCVideoView(_renderer)),
        if (visible)
          GestureDetector(
            onTap: _toggleMute,
            child: Semantics(
              button: true,
              label: _muted ? 'Unmute screen audio' : 'Mute screen audio',
              child: widget.cardBuilder != null
                  ? widget.cardBuilder!(props)
                  : MiniAudio(
                      options: MiniAudioOptions(
                        name: label,
                        showWaveform: _active && !_muted,
                        visible: true,
                        barColor: Colors.white,
                        textColor: Colors.white,
                        imageSource: kDefaultMediaSFULogo,
                        roundedImage: true,
                      ),
                    ),
            ),
          ),
      ],
    );
  }
}
