import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart'
    show RtpEncodingParameters, ProducerCodecOptions;
import '../../../types/types.dart' show ProducerOptionsType;

/// Represents the H.264 encoding parameters and codec options.
/// Constant `hParams` representing encoding configurations with codec options.
final ProducerOptionsType hParams = ProducerOptionsType(
  encodings: [
    RtpEncodingParameters(
      rid: 'r2',
      maxBitrate: 240000,
      scalabilityMode: 'L1T3',
      scaleResolutionDownBy: 4.0,
      minBitrate: 48000,
    ),
    RtpEncodingParameters(
      rid: 'r1',
      maxBitrate: 480000,
      scalabilityMode: 'L1T3',
      scaleResolutionDownBy: 2.0,
      minBitrate: 96000,
    ),
    RtpEncodingParameters(
      rid: 'r0',
      maxBitrate: 960000,
      scalabilityMode: 'L1T3',
      minBitrate: 192000,
    ),
  ],
  codecOptions: ProducerCodecOptions(
    videoGoogleStartBitrate: 384,
    // Add any other codec-specific options as necessary
  ),
);
