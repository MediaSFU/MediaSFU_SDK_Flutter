/// Audio parameters for encoding for audio sharing
///
/// This constant represents a map of audio encoding parameters used for audio sharing.
/// It contains a list of encodings, where each encoding is represented by a map with
/// the following properties:
///   - 'rid': The identifier for the encoding.
///   - 'maxBitrate': The maximum bitrate for the encoding in kilobits per second (kbps).
///
/// Example usage:
/// ```dart
/// const Map<String, dynamic> aParams = {
///   'encodings': [
///     {
///       'rid': 'r0',
///       'maxBitrate': 84000,
///     },
///   ],
/// };
/// ```
const Map<String, dynamic> aParams = {
  'encodings': [
    {
      'rid': 'r0',
      'maxBitrate': 84000,
    },
  ],
};
