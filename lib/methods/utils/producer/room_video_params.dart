import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart'
    show ProducerCodecOptions, RtpEncodingParameters;
import '../../../types/types.dart' show ProducerOptionsType;

/// Returns independent room video options from a shared preset.
ProducerOptionsType freshRoomVideoParams(ProducerOptionsType base) {
  return ProducerOptionsType(
    encodings: base.encodings
        .map(
          (encoding) => RtpEncodingParameters(
            rid: encoding.rid,
            maxBitrate: encoding.maxBitrate,
            minBitrate: encoding.minBitrate,
            scalabilityMode: encoding.scalabilityMode,
            scaleResolutionDownBy: encoding.scaleResolutionDownBy,
          ),
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
