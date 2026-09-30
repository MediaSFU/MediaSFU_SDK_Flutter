import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart'
    show ProducerCodecOptions, RtpEncodingParameters;
import '../../../types/types.dart' show ProducerOptionsType;

/// Returns independent room video options from a shared preset.
ProducerOptionsType freshRoomVideoParams(ProducerOptionsType base) {
  return ProducerOptionsType(
    encodings: base.encodings
        .map(
          (encoding) => RtpEncodingParameters.fromMap(encoding.toMap()),
        )
        .toList(),
    codecOptions: base.codecOptions == null
        ? null
        : ProducerCodecOptions(
            videoGoogleStartBitrate: base.codecOptions!.videoGoogleStartBitrate,
          ),
    track: base.track,
    stream: base.stream,
    codec: base.codec,
  );
}

/// Builds camera encodings for a room without mutating a shared preset.
/// Recording availability deliberately does not change the bitrate budget.
/// Capacity means the configured room limit, never the current member count.
ProducerOptionsType roomVideoParams(
  ProducerOptionsType base, {
  required String targetResolution,
  required bool isChat,
  int? capacity,
  bool simulcastOff = false,
}) {
  final params = freshRoomVideoParams(base);
  final factor = switch (targetResolution) {
    'hd' => 4.0,
    'fhd' => 8.0,
    'qhd' => 16.0,
    'QnHD' => 0.25,
    _ => 1.0,
  };
  for (final encoding in params.encodings) {
    if (encoding.maxBitrate != null) {
      encoding.maxBitrate = (encoding.maxBitrate! * factor).toInt();
    }
    if (encoding.minBitrate != null) {
      encoding.minBitrate = (encoding.minBitrate! * factor).toInt();
    }
  }

  if ((simulcastOff || isChat || capacity == 2) &&
      params.encodings.isNotEmpty) {
    // Presets normally run low -> high, but select by resolution rather than
    // list position. Keeping the first encoding would quarter camera size.
    final full = params.encodings.reduce((previous, current) {
      final previousScale = previous.scaleResolutionDownBy ?? 1.0;
      final currentScale = current.scaleResolutionDownBy ?? 1.0;
      return currentScale <= previousScale ? current : previous;
    });
    final encoding = full.toMap()
      ..remove('rid')
      ..['scaleResolutionDownBy'] = 1.0;
    // No spatial scalability when opting out; temporal adaptation is retained.
    if (encoding['scalabilityMode'] != null) {
      encoding['scalabilityMode'] = 'L1T3';
    }
    params.encodings = [RtpEncodingParameters.fromMap(encoding)];
  }
  return params;
}
