// Custom builder typedefs for MediaSFU components
import 'package:flutter/material.dart';
import 'types.dart' show Participant, Stream;
import '../methods/utils/mediasfu_parameters.dart' show MediasfuParameters;

/// Custom builder function type for VideoCard component.
/// Allows complete customization of video participant display.
typedef VideoCardType = Widget Function({
  required Participant participant,
  required Stream stream,
  required double width,
  required double height,
  int? imageSize,
  String? doMirror,
  bool? showControls,
  bool? showInfo,
  String? name,
  Color? backgroundColor,
  VoidCallback? onVideoPress,
  dynamic parameters,
});

/// Custom builder function type for AudioCard component.
/// Allows complete customization of audio-only participant display.
typedef AudioCardType = Widget Function({
  required String name,
  required bool barColor,
  required Color textColor,
  required String imageSource,
  required double roundedImage,
  required Color imageStyle,
  dynamic parameters,
});

/// Custom builder function type for MiniCard component.
/// Allows complete customization of inactive participant display.
typedef MiniCardType = Widget Function({
  required String initials,
  required String fontSize,
  bool? customStyle,
  required String name,
  required bool showVideoIcon,
  required bool showAudioIcon,
  required String imageSource,
  required double roundedImage,
  required Color imageStyle,
  dynamic parameters,
});

/// Custom widget function type for complete MediaSFU component replacement.
/// Allows users to provide their own widget instead of the default MediaSFU interface.
/// The function receives MediasfuParameters with all the current state and methods.
typedef CustomComponentType = Widget Function({
  required MediasfuParameters parameters,
});
