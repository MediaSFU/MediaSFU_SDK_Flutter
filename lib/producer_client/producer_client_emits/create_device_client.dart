import 'package:mediasfu_mediasoup_client/mediasfu_mediasoup_client.dart';

/// Creates a mediasoup client device with the provided RTP capabilities.
///
/// The [rtpCapabilities] parameter is required and should be a dynamic object
/// representing the RTP capabilities of the device.
///
/// Throws an [Exception] if [rtpCapabilities] is null.
/// Throws an [Exception] if the device is unsupported.
///
/// Returns a [Future] that completes with a [Device] object representing the
/// created mediasoup client device.

Future<Device> createDeviceClient({required dynamic rtpCapabilities}) async {
  try {
    // Validate input parameters
    if (rtpCapabilities == null) {
      throw Exception('RTP capabilities required.');
    }

    // Create a mediasoup client device
    Device device = Device();

    // Remove orientation capabilities
    if (rtpCapabilities is Map<String, dynamic>) {
      List<dynamic>? headerExtensions = rtpCapabilities['headerExtensions'];
      if (headerExtensions != null) {
        rtpCapabilities['headerExtensions'] = headerExtensions
            .where((ext) => ext['uri'] != 'urn:3gpp:video-orientation')
            .toList();
      }
    }

    // Load the provided RTP capabilities into the device

    RtpCapabilities rtpCapabilities_ = RtpCapabilities.fromMap(rtpCapabilities);
    await device.load(routerRtpCapabilities: rtpCapabilities_);

    // Perform additional initialization, e.g., loading spinner and retrieving messages

    return device;
  } catch (error) {
    // Handle specific errors, e.g., UnsupportedError
    if (error.runtimeType.toString() == 'UnsupportedError') {
      throw Exception('Unsupported device.');
    }

    rethrow; // Propagate other errors
  }
}
