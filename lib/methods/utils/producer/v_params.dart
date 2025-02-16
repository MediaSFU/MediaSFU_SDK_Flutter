import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart'
    show RtpEncodingParameters, ProducerCodecOptions;
import '../../../types/types.dart' show ProducerOptionsType;

/// Represents video parameters for encoding, particularly for scalable video encoding

/// Constant `vParams` representing the video encoding parameters and codec options.
final ProducerOptionsType vParams = ProducerOptionsType(
  encodings: [
    RtpEncodingParameters(
      rid: 'r2',
      maxBitrate: 200000,
      minBitrate: 40000,
      scalabilityMode: 'L1T3',
      scaleResolutionDownBy: 4.0,
    ),
    RtpEncodingParameters(
      rid: 'r1',
      maxBitrate: 400000,
      minBitrate: 80000,
      scalabilityMode: 'L1T3',
      scaleResolutionDownBy: 2.0,
    ),
    RtpEncodingParameters(
      rid: 'r0',
      maxBitrate: 800000,
      minBitrate: 160000,
      scalabilityMode: 'L1T3',
    ),
  ],
  codecOptions: ProducerCodecOptions(
    videoGoogleStartBitrate: 320,
    // Add any other codec-specific options as needed
  ),
);
