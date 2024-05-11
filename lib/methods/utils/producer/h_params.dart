/// Map containing the H.264 encoding parameters.
///
/// The `hParams` map contains the following keys:
/// - `encodings`: A list of encoding configurations, each represented as a map.
///   - `rid`: The RID (RtpStreamId) of the encoding.
///   - `maxBitrate`: The maximum bitrate for the encoding.
///   - `initialAvailableBitrate`: The initial available bitrate for the encoding.
///   - `minBitrate`: The minimum bitrate for the encoding.
///   - `scalabilityMode`: The scalability mode for the encoding.
///   - `scaleResolutionDownBy`: The scale resolution factor for the encoding.
/// - `codecOptions`: A map containing codec-specific options.
///   - `videoGoogleStartBitrate`: The start bitrate for the video codec.
const Map<String, dynamic> hParams = {
  'encodings': [
    {
      'rid': 'r8',
      'maxBitrate': 240000,
      'initialAvailableBitrate': 96000,
      'minBitrate': 48000,
      'scalabilityMode': 'L1T3',
      'scaleResolutionDownBy': 4.0,
    },
    {
      'rid': 'r9',
      'maxBitrate': 480000,
      'initialAvailableBitrate': 192000,
      'minBitrate': 96000,
      'scalabilityMode': 'L1T3',
      'scaleResolutionDownBy': 2.0,
    },
    {
      'rid': 'r10',
      'maxBitrate': 960000,
      'initialAvailableBitrate': 384000,
      'minBitrate': 192000,
      'scalabilityMode': 'L1T3',
    },
  ],
  'codecOptions': {
    'videoGoogleStartBitrate': 384,
  },
};
