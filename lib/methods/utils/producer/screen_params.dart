import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart'
    show RtpEncodingParameters, ProducerCodecOptions;
import '../../../types/types.dart' show ProducerOptionsType;

/// Represents screen parameters for video encoding, particularly for screen sharing.

/// Constant `screenParams` representing screen encoding parameters and codec options for screen sharing.
final ProducerOptionsType screenParams = ProducerOptionsType(
  encodings: [
    RtpEncodingParameters(
      rid: 'r0',
      maxBitrate: 3000000,
      minBitrate: 500000,
    ),
  ],
  codecOptions: ProducerCodecOptions(
    videoGoogleStartBitrate: 1000,
    // Add any other codec-specific options if required
  ),
);
