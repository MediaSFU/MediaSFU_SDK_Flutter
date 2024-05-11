/// This file contains constants for video capture constraints used in the application.
/// The constants define various display sizes and frame rates for different orientations and aspect ratios.
/// These values can be used to set the video capture constraints when capturing video in the application.
// Landscape display sizes
const qnHDCons = {'width': 320, 'height': 180};
const sdCons = {'width': 640, 'height': 360};
const hdCons = {'width': 1280, 'height': 720};

// Portrait display sizes
const qnHDConsPort = {'width': 180, 'height': 320};
const sdConsPort = {'width': 360, 'height': 640};
const hdConsPort = {'width': 720, 'height': 1280};

// Neutral (Square) display sizes
const qnHDConsNeu = {'width': 240, 'height': 240};
const sdConsNeu = {'width': 480, 'height': 480};
const hdConsNeu = {'width': 960, 'height': 960};

// Frame rates for video capture
const qnHDFrameRate = 5;
const sdFrameRate = 10;
const hdFrameRate = 15;
const screenFrameRate = 30;
