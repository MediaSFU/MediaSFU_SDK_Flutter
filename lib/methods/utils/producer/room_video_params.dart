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

/// Camera bitrate per room tier (Oct 2026). Factors scale the base vParams/
/// hParams ladder (SD = 1), sized for webcam content at each tier's frame
/// rate. MediaSFU sets these per tier; they are not an app option. They must
/// match the media server's tables (DSFU2/mediasoup/incomingBitrateCap.cjs),
/// which cap what a sender may use.
const Map<String, double> cameraBitrateFactors = {
  'QnHD': 0.125,
  'sd': 0.5625,
  'hd': 2.25,
  'fhd': 3.0,
  'qhd': 10.0,
};

/// Factor applied to the base camera ladder for a room tier. Unknown tiers
/// scale like SD.
double cameraBitrateFactor(String targetResolution) {
  return cameraBitrateFactors[targetResolution] ?? cameraBitrateFactors['sd']!;
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
  final factor = cameraBitrateFactor(targetResolution);
  for (final encoding in params.encodings) {
    if (encoding.maxBitrate != null) {
      encoding.maxBitrate = (encoding.maxBitrate! * factor).toInt();
    }
    if (encoding.minBitrate != null) {
      encoding.minBitrate = (encoding.minBitrate! * factor).toInt();
    }
  }

  // The start bitrate shrinks with the ladder (never grows it).
  final startBitrate = params.codecOptions?.videoGoogleStartBitrate;
  if (factor < 1 && startBitrate != null) {
    params.codecOptions = ProducerCodecOptions(
      videoGoogleStartBitrate: (startBitrate * factor).toInt(),
    );
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
