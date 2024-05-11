/// Screen parameters for video encoding for screen sharing
///
/// This constant [screenParams] represents the screen parameters used for video encoding during screen sharing.
/// It contains information about the encoding settings, such as the maximum bitrate and initial available bitrate,
/// as well as codec options like the video start bitrate.
const Map<String, dynamic> screenParams = {
  'encodings': [
    {
      'rid': 'r7',
      'maxBitrate': 3000000,
      'initialAvailableBitrate': 1500000,
    }
  ],
  'codecOptions': {
    'videoGoogleStartBitrate': 1000,
  },
};
