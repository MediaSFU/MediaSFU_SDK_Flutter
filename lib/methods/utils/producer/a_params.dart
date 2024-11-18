import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart'
    show RtpEncodingParameters;
import '../../../types/types.dart' show ProducerOptionsType;

/// Represents audio encoding parameters for audio sharing

/// Constant `aParams` representing default encoding parameters for audio sharing.
final ProducerOptionsType aParams = ProducerOptionsType(
  encodings: [
    RtpEncodingParameters(
      rid: 'r0',
      maxBitrate: 64000,
    ),
  ],
);
