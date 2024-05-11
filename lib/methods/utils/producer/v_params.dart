/// A map containing video parameters for encoding.
///
/// The `vParams` map consists of two main properties:
/// - `encodings`: A list of encoding configurations for different video qualities.
/// - `codecOptions`: Additional options for the video codec.
///
/// Each encoding configuration is represented by a map with the following properties:
/// - `rid`: The unique identifier for the encoding.
/// - `maxBitrate`: The maximum bitrate for the encoding in bits per second.
/// - `initialAvailableBitrate`: The initial available bitrate for the encoding in bits per second.
/// - `minBitrate`: The minimum bitrate for the encoding in bits per second.
/// - `scalabilityMode`: The scalability mode for the encoding.
/// - `scaleResolutionDownBy`: The factor by which the resolution should be scaled down.
///
/// The `codecOptions` map contains additional options for the video codec.
/// Currently, it only includes the `videoGoogleStartBitrate` property, which represents
/// the start bitrate for the video codec in bits per second.
const Map<String, dynamic> vParams = {
  'encodings': [
    {
      'rid': 'r3',
      'maxBitrate': 200000,
      'initialAvailableBitrate': 80000,
      'minBitrate': 40000,
      'scalabilityMode': 'L1T3',
      'scaleResolutionDownBy': 4.0,
    },
    {
      'rid': 'r4',
      'maxBitrate': 400000,
      'initialAvailableBitrate': 160000,
      'minBitrate': 80000,
      'scalabilityMode': 'L1T3',
      'scaleResolutionDownBy': 2.0,
    },
    {
      'rid': 'r5',
      'maxBitrate': 800000,
      'initialAvailableBitrate': 320000,
      'minBitrate': 160000,
      'scalabilityMode': 'L1T3',
    },
  ],
  'codecOptions': {
    'videoGoogleStartBitrate': 320,
  },
};
