import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'dart:async';

/// Launches the media settings modal and updates the available audio and video input devices.
///
/// The [parameters] map should contain the following keys:
/// - 'updateIsMediaSettingsModalVisible': A function that updates the visibility state of the media settings modal.
/// - 'isMediaSettingsModalVisible': A boolean indicating whether the media settings modal is currently visible.
/// - 'audioInputs': A list of [MediaDeviceInfo] representing the available audio input devices.
/// - 'videoInputs': A list of [MediaDeviceInfo] representing the available video input devices.
/// - 'updateAudioInputs': A function that updates the available audio input devices.
/// - 'updateVideoInputs': A function that updates the available video input devices.
/// - 'updateIsLoadingModalVisible': A function that updates the visibility state of the loading modal.
/// - 'videoAlreadyOn': A boolean indicating whether the video is already turned on.
/// - 'audioAlreadyOn': A boolean indicating whether the audio is already turned on.
/// - 'onWeb': A boolean indicating whether the app is running on the web platform.
///
/// If the media settings modal is not currently visible, this function attempts to get the media stream
/// to force the permission prompt. It then retrieves the list of all available media devices and filters
/// them to get only audio and video input devices. The available audio and video input devices are then
/// updated using the provided update functions. If an error occurs while getting the media devices, the
/// loading modal visibility is updated accordingly.
///
/// Finally, this function toggles the visibility state of the media settings modal.

typedef UpdateBoolFunction = void Function(bool);
typedef UpdateListFunction = void Function(List<MediaDeviceInfo>);
typedef UpdateIsLoadingModalVisible = void Function(bool value);

Future<void> launchMediaSettings({
  required Map<String, dynamic> parameters,
}) async {
  // Destructure parameters for ease of use
  final UpdateBoolFunction updateIsMediaSettingsModalVisible =
      parameters['updateIsMediaSettingsModalVisible'];
  final bool isMediaSettingsModalVisible =
      parameters['isMediaSettingsModalVisible'];
  List<MediaDeviceInfo>? audioInputs = parameters['audioInputs'];
  List<MediaDeviceInfo>? videoInputs = parameters['videoInputs'];
  final UpdateListFunction updateAudioInputs = parameters['updateAudioInputs'];
  final UpdateListFunction updateVideoInputs = parameters['updateVideoInputs'];
  final UpdateIsLoadingModalVisible updateIsLoadingModalVisible =
      parameters['updateIsLoadingModalVisible'] ?? (_) {};

  bool videoAlreadyOn = parameters['videoAlreadyOn'] ?? false;
  bool audioAlreadyOn = parameters['audioAlreadyOn'] ?? false;
  bool onWeb = parameters['onWeb'] ?? false;

  // Check if media settings modal is not visible and update available audio and video input devices
  if (!isMediaSettingsModalVisible) {
    try {
      // Force permission prompt by attempting to get media stream
      updateIsLoadingModalVisible(true);
      if (onWeb && (!videoAlreadyOn && !audioAlreadyOn)) {
        MediaStream stream = await navigator.mediaDevices.getUserMedia({
          'audio': true, // Request audio access
          'video': true, // Request video access
        });

        // Close the stream as it's not needed
        for (var track in stream.getTracks().toList()) {
          track.stop();
        }
      }

      // Get the list of all available media devices
      List<MediaDeviceInfo> devices =
          await navigator.mediaDevices.enumerateDevices();

      // Filter the devices to get only audio and video input devices
      videoInputs =
          devices.where((device) => device.kind == 'videoinput').toList();
      audioInputs =
          devices.where((device) => device.kind == 'audioinput').toList();

      // Update the available audio and video input devices
      updateVideoInputs(videoInputs);
      updateAudioInputs(audioInputs);
      updateIsLoadingModalVisible(false);
    } catch (error) {
      updateIsLoadingModalVisible(false);
      if (kDebugMode) {
        print('Error getting media devices: $error');
      }
    }
  }

  // Open or close the media settings modal based on its current visibility state
  updateIsMediaSettingsModalVisible(!isMediaSettingsModalVisible);
}
