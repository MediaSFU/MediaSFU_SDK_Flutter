import 'package:flutter/foundation.dart';
import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';

/// Options for creating a mediasoup client device.
class CreateDeviceClientOptions {
  RtpCapabilities? rtpCapabilities;

  CreateDeviceClientOptions({required this.rtpCapabilities});
}

typedef CreateDeviceClientType = Future<Device?> Function(
    {required CreateDeviceClientOptions options});

/// Creates a mediasoup client device with the provided RTP capabilities.
///
/// The [CreateDeviceClientOptions] is required and must contain the RTP capabilities.
///
/// Returns a [Device] object representing the created mediasoup client device or
/// throws an [Exception] if the device creation is not supported.
///
/// Example usage:
/// ```dart
/// final device = await createDeviceClient(
///   options: CreateDeviceClientOptions(rtpCapabilities: rtpCapabilities),
/// );
/// if (device != null) {
///   print("Device created successfully");
/// } else {
///   print("Failed to create device");
/// }
/// ```
Future<Device?> createDeviceClient(
    {required CreateDeviceClientOptions options}) async {
  try {
    // Check if rtpCapabilities is provided
    if (options.rtpCapabilities == null) {
      throw Exception('RTP capabilities must be provided.');
    }

    // Initialize the mediasoup client device
    Device device = Device();

    // Remove orientation capabilities if present in rtpCapabilities directly
    options.rtpCapabilities!.headerExtensions.removeWhere(
      (ext) => ext.uri == 'urn:3gpp:video-orientation',
    );

    // Load the provided RTP capabilities into the device
    await device.load(routerRtpCapabilities: options.rtpCapabilities!);

    return device;
  } catch (error) {
    if (error.runtimeType.toString() == 'UnsupportedError') {
      if (kDebugMode) {
        print('Device creation is not supported on this device.');
      }
      return null;
    }
    rethrow;
  }
}
