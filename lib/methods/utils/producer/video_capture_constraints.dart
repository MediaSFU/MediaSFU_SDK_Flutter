import '../../../types/types.dart' show VidCons;

/// This file contains constants for video capture constraints used in the application.
/// The constants define various display sizes and frame rates for different orientations and aspect ratios.
/// These values can be used to set the video capture constraints when capturing video in the application.
// Landscape display sizes
VidCons qnHDCons = VidCons.fromMap({'width': 320, 'height': 180});
VidCons sdCons = VidCons.fromMap({'width': 640, 'height': 360});
VidCons hdCons = VidCons.fromMap({'width': 1280, 'height': 720});
VidCons fhdCons = VidCons.fromMap({'width': 1920, 'height': 1080});
VidCons qhdCons = VidCons.fromMap({'width': 2560, 'height': 1440});

// Portrait display sizes
VidCons qnHDConsPort = VidCons.fromMap({'width': 180, 'height': 320});
VidCons sdConsPort = VidCons.fromMap({'width': 360, 'height': 640});
VidCons hdConsPort = VidCons.fromMap({'width': 720, 'height': 1280});
VidCons fhdConsPort = VidCons.fromMap({'width': 1080, 'height': 1920});
VidCons qhdConsPort = VidCons.fromMap({'width': 1440, 'height': 2560});

// Neutral (Square) display sizes
VidCons qnHDConsNeu = VidCons.fromMap({'width': 240, 'height': 240});
VidCons sdConsNeu = VidCons.fromMap({'width': 480, 'height': 480});
VidCons hdConsNeu = VidCons.fromMap({'width': 960, 'height': 960});
VidCons fhdConsNeu = VidCons.fromMap({'width': 1440, 'height': 1440});
VidCons qhdConsNeu = VidCons.fromMap({'width': 1920, 'height': 1920});

// Frame rates for video capture
int qnHDFrameRate = 5;
int sdFrameRate = 10;
int hdFrameRate = 15;
int fhdFrameRate = 20;
int qhdFrameRate = 25;
int screenFrameRate = 30;
