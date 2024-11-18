import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'dart:async';

/// Defines options for launching the media settings modal, including visibility toggling,
/// available audio/video devices, and update functions.
class LaunchMediaSettingsOptions {
  final void Function(bool isVisible) updateIsMediaSettingsModalVisible;
  final bool isMediaSettingsModalVisible;
  final List<MediaDeviceInfo> audioInputs;
  final List<MediaDeviceInfo> videoInputs;
  final void Function(List<MediaDeviceInfo>) updateAudioInputs;
  final void Function(List<MediaDeviceInfo>) updateVideoInputs;
  final bool videoAlreadyOn;
  final bool audioAlreadyOn;
  final bool onWeb;
  final void Function(bool) updateIsLoadingModalVisible;

  LaunchMediaSettingsOptions({
    required this.updateIsMediaSettingsModalVisible,
    required this.isMediaSettingsModalVisible,
    required this.audioInputs,
    required this.videoInputs,
    required this.updateAudioInputs,
    required this.updateVideoInputs,
    required this.videoAlreadyOn,
    required this.audioAlreadyOn,
    required this.onWeb,
    required this.updateIsLoadingModalVisible,
  });
}

/// Type definition for the function that launches the media settings modal.
typedef LaunchMediaSettingsType = Future<void> Function(
    LaunchMediaSettingsOptions options);

/// Launches the media settings modal and updates the available audio and video input devices.
///
/// This function checks if the media settings modal is not currently visible, and if so,
/// it attempts to get the media stream to force the permission prompt, then retrieves the
/// available media devices and updates the audio and video inputs lists.
///
/// Example:
/// ```dart
/// final options = LaunchMediaSettingsOptions(
///   updateIsMediaSettingsModalVisible: (isVisible) => print("Modal visibility: $isVisible"),
///   isMediaSettingsModalVisible: false,
///   audioInputs: [],
///   videoInputs: [],
///   updateAudioInputs: (inputs) => print("Audio Inputs: $inputs"),
///   updateVideoInputs: (inputs) => print("Video Inputs: $inputs"),
///   videoAlreadyOn: false,
///   audioAlreadyOn: false,
///   onWeb: true,
///   updateIsLoadingModalVisible: (isVisible) => print("Loading modal: $isVisible"),
/// );
///
/// await launchMediaSettings(options);
/// ```
///
Future<void> launchMediaSettings(LaunchMediaSettingsOptions options) async {
  if (!options.isMediaSettingsModalVisible) {
    try {
      // Force permission prompt by attempting to get media stream
      options.updateIsLoadingModalVisible(true);

      if (options.onWeb && !options.videoAlreadyOn && !options.audioAlreadyOn) {
        MediaStream stream = await navigator.mediaDevices.getUserMedia({
          'audio': true,
          'video': true,
        });

        // Close the stream as it's not needed
        for (var track in stream.getTracks()) {
          track.stop();
        }
      }

      // Get the list of all available media devices
      List<MediaDeviceInfo> devices =
          await navigator.mediaDevices.enumerateDevices();

      // Filter devices to get only audio and video input devices
      options.updateVideoInputs(
          devices.where((device) => device.kind == 'videoinput').toList());
      options.updateAudioInputs(
          devices.where((device) => device.kind == 'audioinput').toList());

      options.updateIsLoadingModalVisible(false);
    } catch (error) {
      options.updateIsLoadingModalVisible(false);
      if (kDebugMode) {
        print('Error getting media devices: $error');
      }
    }
  }

  // Toggle the media settings modal visibility
  options
      .updateIsMediaSettingsModalVisible(!options.isMediaSettingsModalVisible);
}
