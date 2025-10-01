/// Retrieves the list of available media devices.
///
/// This function enumerates all available media devices and filters them
/// based on the specified [kind] parameter. It includes permission handling
/// to ensure proper device enumeration.
///
/// **Parameters:**
/// - [kind] (`String`): The type of media device to filter.
///   - `'videoinput'`: Video input devices (cameras)
///   - `'audioinput'`: Audio input devices (microphones)
///
/// **Returns:**
/// - `Future<List<MediaDeviceInfo>>`: A list of media devices matching the specified kind.
///   Returns an empty list if an error occurs.
///
/// **Example:**
/// ```dart
/// // Get all video input devices (cameras)
/// final videoDevices = await getMediaDevicesList('videoinput');
/// for (var device in videoDevices) {
///   print('Camera: ${device.label}');
/// }
///
/// // Get all audio input devices (microphones)
/// final audioDevices = await getMediaDevicesList('audioinput');
/// for (var device in audioDevices) {
///   print('Microphone: ${device.label}');
/// }
/// ```
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// Type definition for the getMediaDevicesList function.
typedef GetMediaDevicesListType = Future<List<MediaDeviceInfo>> Function(
    String kind);

/// Retrieves a filtered list of media devices based on the specified kind.
///
/// This function attempts to get user media permissions before enumerating devices
/// to ensure proper device labels and information are available.
Future<List<MediaDeviceInfo>> getMediaDevicesList(String kind) async {
  try {
    // Attempt to get media stream to trigger permission prompt if needed
    // This ensures device labels are available
    try {
      final constraints = <String, dynamic>{};
      
      if (kind == 'videoinput') {
        constraints['video'] = true;
        constraints['audio'] = false;
      } else if (kind == 'audioinput') {
        constraints['audio'] = true;
        constraints['video'] = false;
      } else {
        // If kind is not recognized, try to get both
        constraints['audio'] = true;
        constraints['video'] = true;
      }

      // Get user media to trigger permission prompt
      try {
        MediaStream stream = await navigator.mediaDevices.getUserMedia(constraints);
        
        // Close the stream immediately as we don't need it
        for (var track in stream.getTracks()) {
          track.stop();
        }
      } catch (permissionError) {
        // Permission denied or not available, continue anyway
        // Devices may still be enumerated but with limited information
        if (kDebugMode) {
          print('Permission not granted for media devices: $permissionError');
        }
      }
    } catch (e) {
      // Continue even if getUserMedia fails
      if (kDebugMode) {
        print('Could not get user media: $e');
      }
    }

    // Enumerate all available media devices
    final devices = await navigator.mediaDevices.enumerateDevices();

    // Filter devices based on the specified kind
    final filtered = devices.where((device) => device.kind == kind).toList();

    return filtered;
  } catch (e) {
    // Return an empty list if an error occurs
    if (kDebugMode) {
      print('Error getting media devices list: $e');
    }
    return [];
  }
}
